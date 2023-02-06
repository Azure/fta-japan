[&larr; 運用](./4-operations.md) | Part 5 of 6 | [ワークロードのデプロイ自動化 &rarr;](./6-workload-deployments-automation.md)

# AKS モニタリング

## パート1 - イントロダクション: モニタリングの概念と戦略

### コンセプト

- [ブラックボックス モニタリング](https://docs.microsoft.com/ja-jp/azure/architecture/framework/devops/health-monitoring#black-box-monitoring) vs. [ホワイトボックス モニタリング](https://docs.microsoft.com/ja-jp/azure/architecture/framework/devops/health-monitoring#white-box-monitoring)
- メトリックス vs ログ
- シグナル vs ノイズ

### USE メソッド

インフラストラクチャの観点から、制約とボトルネックを素早く特定します。

- U = 利用率
- S = 過負荷
- E = エラー

この考え方は、[Brendan Gregg](https://www.brendangregg.com/usemethod.html) によって提唱されました。

### RED メソッド

クライアントからの観点でモニタリングし、インフラストラクチャを無視します。

- R = レート
- E = エラー
- D = 持続時間/間隔

[Tom Willke](https://grafana.com/blog/2018/08/02/the-red-method-how-to-instrument-your-services) (VP Technology, Granfana Labs) によって広く普及しました。

## パート2 - ディープダイブ: AKS モニタリング

### ツール


- Azure モニター
- アラート
- クエリーログのコンテナーインサイト

### Azure Monitor for Containers を有効にする

```bash
# サブスクリプション コンテキストをセットします
az account set --subscription <subscriptionId>

# 既存のクラスターでモニタリングを有効にします
az aks enable-addons -a monitoring -n <clustername> -g <resourcegroupname>

# 既存のクラスターで既存のワークスペースを使用してモニタリングを有効にします
az aks enable-addons -a monitoring -n <clustername> -g <resourcegroupname> --workspace-resource-id "/subscriptions/<subscriptionId>/resourcegroups/<resourcegroupname>/providers/microsoft.operationalinsights/workspaces/<workspacename>"

# ステータスとエージェントのバージョンを確認します
kubectl get ds omsagent --namespace kube-system

# Windows ノードプールで実行されているエージェントのバージョンを確認します
kubectl get ds omsagent-win --namespace kube-system

# 既存のクラスターの接続されたワークスペースの詳細を確認します
az aks show -g <resourcegroupname> -n <clustername> | grep -i "logAnalyticsWorkspaceResourceID"

# Azure Monitor for Containers アドオンを無効にするには
az aks disable-addons -a monitoring -g <resourcegroupname> -n <clustername>

````

### モニタリングするものは何か？

- このセッションは、[Monitor AKS with Azure Monitor for Container Insights](https://docs.microsoft.com/azure/aks/monitor-aks#monitor-layers-of-aks-with-container-insights) で示されている構造に従います。

- [Layer 1 - クラスター レベルのインフラストラクチャ コンポーネント](#layer-1---cluster-level-infrastructure-components)
- [Layer 2 - AKS 管理コンポーネント](#layer-2---aks-managed-components)
- [Layer 3 - クラスターの可用性 (Kubernetes pods, replicasets, and daemonsets)](#layer-3---cluster-availability-kubernetes-pods-replicasets-and-daemonsets)
- [Layer 4 - ワークロードとホストされたアプリケーション](#layer-4---workloads-and-hosted-applications)
- [Layer 5 - AKS 以外のリソース](#layer-5---resources-additional-to-aks)

![AKS Monitoring Layers](https://docs.microsoft.com/en-us/azure/aks/media/monitor-aks/layers.png)

## Layer 1 - クラスター レベルのインフラストラクチャ コンポーネント

- ノード
- ノード プール

Kubenetes は、ノード プール (VM SKU が同じノード) を使用し、多くの本番環境では、ノードとノード プールを監視する自動スケーリングを使用します。

適切なモニターとしきい値を使用してアラートを有効にして、積極的に対応します。

| 名前 | 目的 / 説明 | メトリクス と リソース ログ |
|:-----|:------------------------|:------------------------|
| ノードの状態を監視する - [Not ready status](https://docs.microsoft.com/azure/azure-monitor/containers/container-insights-metric-alerts)| ノードの状態を監視して、ヘルス ステータスを確認します。Not Ready または Unknown| メトリクス と リソース ログ |
| リソース圧迫下のノードを監視する - [Node conditions](https://kubernetes.io/docs/concepts/architecture/nodes/#condition) | CPU、メモリ、PID、ディスクの圧迫などのリソース圧迫下のノードを監視します。| リソース ログ |
| ノード レベルの CPU 利用率を監視する - [CPU Utilization](https://docs.microsoft.com/azure/azure-monitor/containers/container-insights-metric-alerts)| 個々のノードの CPU 利用率と、ノード プールで集計された CPU 利用率を監視します。| メトリクス |
| ノード レベルのメモリ利用率を監視する - [Memory Utilization](https://docs.microsoft.com/azure/azure-monitor/containers/container-insights-metric-alerts)	| 個々のノードのメモリ利用率と、ノード プールで集計されたメモリ利用率を監視します。| メトリクス |
| アクティブなノードとスケール アウト %	| ノード プールのスケール アウト % を監視します	| リソース ログ |

# ヒント - Azure Portal でノードのパフォーマンスを表示する

もし Azure monitor for containers を使用している場合、[ポータル](https://docs.microsoft.com/azure/azure-monitor/containers/container-insights-analyze#view-performance-directly-from-a-cluster) からノードのパフォーマンスを直接表示できます。

## Layer 2 - AKS 管理されたコンポーネント

- AKS コントロール プレーン コンポーネント
- Kubernetes API サービス
- コントローラー
- Kubelet
- その他

### ヒント - "Diagnostic" セッションを有効にする

AKS クラスターの問題のトラブルシューティングを支援し、より深い洞察を得るために、AKS マスターノードのログの収集を有効にします。コントロール プレーンの "Diagnostic" 設定を有効にして、Azure ストレージまたはログ分析、または EventHubs を介したサード パーティにログをストリーミングします。

### サポートされているメトリクス

[サポートされているプラットフォーム メトリクスのリスト](https://docs.microsoft.com/azure/azure-monitor/essentials/metrics-supported#microsoftcontainerservicemanagedclusters)、Azure Monitor for container を使用している場合。

| 名前 | 目的/説明 | メトリクスとリソース ログ |
|:-----|:----------|:------------------------|
| API サーバー | API サーバーのログを監視します | リソース ログ |
| スケジュール可能なリソースの可用性 | ポッド/コンテナのスケジュールに使用できるリソースの量を監視します。スケジュール可能なメモリと CPU | メトリクスとリソース ログ |
| スケジュール待ちのポッド | スケジュール待ちの長い状態を監視します。これは、リソースの利用不可のために発生する可能性があります。 | リソース ログ |
| オートスケーラー - スケーリング イベント | スケーリング イベントを監視して、予期されたものかどうか (スケール アウトまたはスケール イン イベント) を判断します。 | メトリクス |
| Kubelet ステータス - [AKS クラスター ノードから kubelet ログを取得する](https://docs.microsoft.com/azure/aks/kubelet-logs) | ポッドの強制終了と OOM キルの kubelet ステータスを監視します。 | メトリクス |
| クラスターの状態 | | メトリクス |
| スケジュール不可能なポッド | スケジュール不可能なポッドを監視します。 | メトリクス |

## Layer 3 - クラスターの可用性 (Kubernetes ポッド、レプリカセット、およびデーモンセット)

Kubernetes では、システム サービスのポッドを安定したクラスター操作のための目的状態で実行する必要があります。システム サービスの重要なポッドを監視することは、最低限の要件です。

| 名前 | 目的/説明 | メトリクスとリソース ログ |
|:------|:----------|:-------------------------|
| システム ポッドとコンテナの再起動 | 重要なシステム サービスの継続的な再起動は、クラスター操作の不安定性を引き起こす可能性があります。kube-system 名前空間の下のポッド/コンテナを監視します。それらの一部は、たとえば、coredns、metric-server です。 | メトリクスとリソース ログ |
| システム ポッドに固有のレプリカセット ** | ほとんどのシステム サービスは、目的状態として 2 つのレプリカを持っています。利用不可になったり、安定していない状態 (実行/準備状態以外の状態) になった場合に警告するために、適切なしきい値を設定します。 | メトリクスとリソース ログ |
| システム ポッドに固有のデーモンセット | 目的状態より少ない実行状態は、常に問題を引き起こさないことがあります。ただし、一部のノードが必要なデーモンセットを実行していない場合、これは一時的な動作を引き起こす可能性があります。kube-system 名前空間の下のポッドを監視します。 | メトリクスとリソース ログ |

** *ローリング アップデート戦略では、一般的に PDB が 1 で、利用不可になる最大サージが 25% に設定されます。これは、監視頻度と期間が過度に激しい場合に、ローリング アップデート中に誤検知を引き起こす可能性があります。*

## Layer 4 - ワークロードとホストされたアプリケーション

| 名前 | 目的/説明 | メトリクスとリソース ログ |
|:------|:----------|:-------------------------|
| ポッドとコンテナの可用性 ** | アプリケーション ポッドの可用性を監視します。 | メトリクスとリソース ログ |
| デプロイメントのスケール アウト % - [コンテナ インサイトでの HPA メトリクス](https://docs.microsoft.com/ja-jp/azure/azure-monitor/containers/container-insights-deployment-hpa-metrics) | 現在のレプリカ数と最大スケール アウト制限の数。デプロイメントがスケール制限に達したことを検出するのに役立ちます。 | リソース ログ |
| ポッドとデプロイメントのステータス - [コンテナ インサイトでの HPA メトリクス](https://docs.microsoft.com/ja-jp/azure/azure-monitor/containers/container-insights-deployment-hpa-metrics) | デプロイメントによってターゲットとされた準備状態のポッドの数を監視します。 | メトリクス |
| ポッドのリソース要求と制限 | 各デプロイメントでリソース (CPU およびメモリ) の要求と制限の構成を監視します。オーバーコミットされたノードを判断するのに役立ちます。 | メトリクス |
| コントローラー レベルの CPU とメモリー使用 | アプリケーションの CPU とメモリー使用をコントローラー レベルで監視します。 | リソース ログ |

** *可用性は、ポッド/コンテナのステータス、再起動回数に基づいて監視できます。レプリカセットの場合、個々のポッドの利用不可はサービスに影響を与えない場合があります。正しいしきい値を設定すると、可用性を監視し、完全にダウンする前に問題を解決するのに十分な時間を確保できます。レプリカの数と目的の状態を監視します。*

## Layer 5 - AKS 以外のリソース

### Azure Application gateway の監視

- [Application Gateway の推奨アラート ルール](https://docs.microsoft.com/ja-jp/azure/application-gateway/monitor-application-gateway#alerts)
- [Application Gateway がサポートするメトリクスの一覧](https://docs.microsoft.com/ja-jp/azure/application-gateway/monitor-application-gateway-reference)

| 名前 | 目的/説明 | メトリクスとリソース ログ |
|:------|:----------|:-------------------------|
| コンピューティング ユニットの使用率 | コンピューティング ユニットは、Application Gateway のコンピューティングの使用率を測定する単位です。 | リソース ログ |
| 容量ユニットの使用率 | 容量ユニットは、スループット、コンピューティング、接続数の観点から、ゲートウェイの全体的な使用率を表します。 | リソース ログ |
| 不健康なホスト数 | Application Gateway が正常にプローブできないバックエンド サーバーの数を示します。 | メトリクスとリソース ログ |
| バックエンドの応答時間 | バックエンドの応答遅延を監視します。 | メトリクス |
| http ステータス 4xx、5xx | 不良ゲートウェイの http ステータス コード 4xx および 5xx を監視します。 | リソース ログ |

### Azure Load Balancer の監視

- [Azure Standard load balancers の診断 (メトリクス、アラート、リソース ヘルス)](https://docs.microsoft.com/ja-jp/azure/load-balancer/load-balancer-standard-diagnostics)
- [Load Balancer の一般的なおよび推奨アラート ルール](https://docs.microsoft.com/ja-jp/azure/load-balancer/monitor-load-balancer#alerts)

| 名前 | 目的/説明 | メトリクスとリソース ログ |
|:------|:----------|:-------------------------|
| SNAT ポートの枯渇を監視 | 使用された SNAT ポートが割り当てられたポート数 (またはしきい値) よりも大きい場合に警告します。 | メトリクス |
| 失敗したアウトバウンド接続の監視 | SNAT 接続数を接続状態 = 失敗にフィルタリングした場合、警告を発生させます。 | メトリクス |

### Azure Firewall の監視

- [Monitor Firewall health state](https://docs.microsoft.com/en-us/azure/firewall/logs-and-metrics#metrics)
- Possible status are "Healthy", "Degraded" & "Unhealthy"
- SNAT port utilization - The percentage of SNAT port that has been utilized

- [Firewall のヘルス状態を監視する](https://docs.microsoft.com/ja-jp/azure/firewall/logs-and-metrics#metrics)
- 可能なステータスは "Healthy"、"Degraded" および "Unhealthy" です。
- SNAT ポートの使用率 - 使用された SNAT ポートの割合

## その他の参考資料

### コンセプト2

- [WeaveWorks Blog: the RED Method: key metrics for microservices architecture](https://www.weave.works/blog/the-red-method-key-metrics-for-microservices-architecture/)
- [Monitor Kubernetes cluster performance with Container Insights](https://docs.microsoft.com/azure/azure-monitor/containers/container-insights-analyze)

### ログとアラート

- [Container insights からのログ クエリ](https://docs.microsoft.com/ja-jp/azure/azure-monitor/containers/container-insights-log-query)
- [ログ アラート ルールの作成](https://docs.microsoft.com/ja-jp/azure/azure-monitor/containers/container-insights-log-alerts)

### 参考資料と推奨メトリクス

- [サポートされているプラットフォーム メトリクス](https://docs.microsoft.com/ja-jp/azure/azure-monitor/essentials/metrics-supported#microsoftcontainerservicemanagedclusters) (Azure Monitor for Containers を使用する場合)
- [Container insights からの推奨メトリクス アラート (プレビュー)](https://docs.microsoft.com/ja-jp/azure/azure-monitor/containers/container-insights-metric-alerts)
