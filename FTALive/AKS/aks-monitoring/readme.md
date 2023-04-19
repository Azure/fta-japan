# AKS モニタリング

このセクションでは、下から上へのボトムアップアプローチを示します。各レイヤーには、異なるモニタリング要件があります。

これらのレイヤーは、[Monitor AKS with Azure Monitor for container insight](https://docs.microsoft.com/azure/aks/monitor-aks#monitor-layers-of-aks-with-container-insights)で説明されています。

- クラスタレベルコンポーネント
- Managed AKS コンポーネント
- Kubernetes オブジェクトとワークロード
- アプリケーション/ホストされたワークロード
- AKS以外のリソース

## ログクエリの例とアラートの作成方法に関する参照

- [コンテナーインサイトからのログクエリ](https://docs.microsoft.com/azure/azure-monitor/containers/container-insights-log-query)
- [ログアラートルールの作成](https://docs.microsoft.com/ja-jp/azure/azure-monitor/containers/container-insights-log-alerts)

## 推奨されるメトリックアラートとデータ参照

- [コンテナーインサイトからの推奨されるメトリックアラート](https://docs.microsoft.com/ja-jp/azure/azure-monitor/containers/container-insights-metric-alerts)

- [AKSのモニタリングデータ参照](https://docs.microsoft.com/ja-jp/azure/aks/monitor-aks-reference)

## 今、各レイヤーでモニタリングすべきものは何ですか？

### クラスターインフラストラクチャとクラスターレベルコンポーネントをモニタリングする

- ノードとノードプールの状態を監視します。

Kubernetes は、ノードプール（同じ VM SKU を使用するため、同一のノードを使用する）を使用し、多くの本番環境では、自動スケーリングを使用するノードプールを使用するため、ノードとノードプールの監視は重要です。

もし、Azure monitor for containers を使用している場合は、[ポータル](https://docs.microsoft.com/azure/azure-monitor/containers/container-insights-analyze#view-performance-directly-from-a-cluster)からノードのパフォーマンスを直接表示できます。

[コンテナーインサイトを使用してKubernetesクラスターのパフォーマンスを監視する](https://docs.microsoft.com/ja-jp/azure/azure-monitor/containers/container-insights-analyze)

ライトモニターとしきい値を使用してアラートを有効にして、積極的に対応します。

| 名前 | 目的/説明 | メトリックとリソースログ |
|:-----|:----------|:------------------------|
| ノードの状態を監視する - [準備ができていないステータス](https://docs.microsoft.com/azure/azure-monitor/containers/container-insights-metric-alerts)| ノードの状態を監視して、ヘルスステータスを確認します。準備ができていないか、不明| メトリックとリソースログ |
| リソース圧迫のノード - [ノードの状態](https://kubernetes.io/docs/concepts/architecture/nodes/#condition) | CPU、メモリ、PID、ディスクの圧迫などのリソース圧迫のノードを監視します。| リソースログ |
| ノードレベルのCPU使用率 - [CPU使用率](https://docs.microsoft.com/azure/azure-monitor/containers/container-insights-metric-alerts)| 個々のノードとノードプールでCPU使用率を監視します。| メトリック |
| ノードレベルのメモリ使用率 - [メモリ使用率](https://docs.microsoft.com/azure/azure-monitor/containers/container-insights-metric-alerts)	| 個々のノードとノードプールでメモリ使用率を監視します。| メトリック |
| アクティブなノードとスケールアウト%	| ノードプールのスケールアウト%を監視します	| リソースログ |

### AKSコンポーネントをモニタリングする

AKS クラスターの問題のトラブルシューティングと深い洞察を得るために、AKS マスターノードのログの収集を有効にします。コントロールプレーンの「診断」設定を有効にして、Azure Storage または Log Analytics などのログ集約ソリューション、または EventHubs 経由のサードパーティにログをストリーミングします。

Azure Monitor for container を使用している場合の [サポートされるプラットフォームメトリックの一覧](https://docs.microsoft.com/ja-jp/azure/azure-monitor/essentials/metrics-supported#microsoftcontainerservicemanagedclusters)

| 名前 | 目的/説明 | メトリックとリソースログ |
|:-----|:----------|:------------------------|
| API サーバー | API サーバーのログを監視します | リソースログ |
| スケジュール可能なリソースの可用性 | ポッド/コンテナのスケジュールに使用できるリソースの量を監視します。スケジュール可能なメモリとCPU | メトリックとリソースログ |
| スケジュール待ちのポッド | 長時間スケジュール待ちの状態を監視します。リソースの不足が原因である可能性があります。 | リソースログ |
| オートスケーラー - スケーリングイベント | スケーリングイベントを監視して、予期されたものかどうかを判断します (スケールアウトまたはスケールインイベント)。 | メトリック |
| Kubelet ステータス - [AKS クラスターノードから kubelet ログを取得する](https://docs.microsoft.com/ja-jp/azure/aks/kubelet-logs) | ポッドの削除と OOM キルの kubelet ステータスを監視します。 | メトリック |
| クラスターの健康状態 | | メトリック |
| スケジュール不可能なポッド | スケジュール不可能なポッドを監視します。 | メトリック |

### クラスターの可用性をモニタリングする (Kubernetes ポッド、レプリカセット、デーモンセット)

Kubernetes は、安定したクラスター操作のために、システムサービスのポッドを望ましい状態で実行する必要があります。重要なシステムサービスのポッドを監視することは、最低限の要件です。

| 名前 | 目的/説明 | メトリックとリソースログ |
|:-----|:----------|:------------------------|
| システムポッドとコンテナの再起動 | 重要なシステムサービスのポッドの継続的な再起動は、クラスター操作の不安定性を引き起こす可能性があります。kube-system 名前空間のポッド/コンテナを監視します。それらのいくつかは、たとえば、coredns、metric-server です。 | メトリックとリソースログ |
| システムポッドに固有のレプリカセット ** | ほとんどのシステムサービスは、望ましい状態として 2 つのレプリカを持っています。利用不可能になったり、非安定な状態 (実行/準備状態以外の状態) になった場合に警告を発生させるために、適切なしきい値を設定します。 | メトリックとリソースログ |
| システムポッドに固有のデーモンセット | 望ましい状態よりも少ない実行状態は、常に問題を引き起こさないことがあります。ただし、一部のノードが必要なデーモンセットを実行していないため、一時的な振る舞いが発生する可能性があります。kube-system 名前空間のポッドを監視します。 | メトリックとリソースログ |

** *ローリングアップデート戦略は、一般的に PDB を 1 に設定し、25% の最大サージで利用不可能にします。これは、監視頻度と期間が過度に激しい場合に、ローリングアップデート中に誤検知を引き起こす可能性があります。*

### ワークロード/ホストされたアプリケーションをモニタリングする

| 名前 | 目的/説明 | メトリックとリソースログ |
|:-----|:----------|:------------------------|
| ポッドとコンテナの可用性 ** | アプリケーションのポッドの可用性を監視します。 | メトリックとリソースログ |
| デプロイメントのスケールアウト % - [Container Insight で HPA メトリック](https://docs.microsoft.com/ja-jp/azure/azure-monitor/containers/container-insights-deployment-hpa-metrics) | 現在のレプリカ数と最大スケールアウト制限の数。デプロイメントがスケール制限に達したことを検出するのに役立ちます。 | リソースログ |
| ポッドとデプロイメントのステータス - [Container Insight で HPA メトリック](https://docs.microsoft.com/ja-jp/azure/azure-monitor/containers/container-insights-deployment-hpa-metrics) | デプロイメントによってターゲットとされた準備状態のポッドの数を監視します。 | メトリック |
| ポッドのリソース要求と制限 | 各デプロイメントでリソース (CPU およびメモリ) の要求と制限の構成を監視します。オーバーコミットされたノードを判断するのに役立ちます。 | メトリック |
| コントローラー レベルの CPU とメモリー使用量 | アプリケーションの CPU とメモリー使用量をコントローラー レベルで監視します。 | リソースログ |

** *ポッド/コンテナの状態、再起動回数に基づいて可用性を監視できます。レプリカセットの場合、個々のポッドの利用不可はサービスに影響を与えない可能性があるため、正しいしきい値を設定すると、完全にダウンする前に問題を解決するための十分な時間を確保できます。レプリカの数と望ましい状態の数を監視します。*


## AKS への追加リソースのモニタリング

### Application Gateway をモニタリングする

- [Applicaiton Gateway のための推奨されるアラートルール](https://docs.microsoft.com/ja-jp/azure/application-gateway/monitor-application-gateway#alerts)

- [Application Gateway がサポートするメトリックの一覧](https://docs.microsoft.com/ja-jp/azure/application-gateway/monitor-application-gateway-reference)

| 名前 | 目的/説明 | メトリックとリソースログ |
|:-----|:----------|:------------------------|
| Compute 単位の利用率 | Application Gateway の計算単位は、Application Gateway の計算利用率の単位です。 | リソースログ |
| 容量単位の利用率 | 容量単位は、スループット、計算、接続数の観点からのゲートウェイの全体的な利用率を表します。 | リソースログ |
| 不健康なホスト数 | Application Gateway が正常にプローブできないバックエンド サーバーの数を示します。 | メトリックとリソースログ |
| バックエンドの応答時間 | バックエンドの応答遅延を監視します。 | メトリック |
| http ステータス 4xx、5xx | バッドゲートウェイの http ステータス コード 4xx、および 5xx を監視します。 | リソースログ |

## Azure load balancer の監視

- [メトリック、アラート、リソースヘルスと Azure Standard load balancers の診断](https://docs.microsoft.com/ja-jp/azure/load-balancer/load-balancer-standard-diagnostics)

- [Load Balancer での一般的なアラートルールと推奨ルール](https://docs.microsoft.com/ja-jp/azure/load-balancer/monitor-load-balancer#alerts)

| 名前 | 目的/説明 | メトリックとリソースログ |
|:-----|:----------|:------------------------|
| SNAT ポートの枯渇を監視する | 使用された SNAT ポートが割り当てられたポート数 (またはしきい値より大きい) よりも大きい場合に警告します。 | メトリック |
| 失敗したアウトバウンド接続を監視する | SNAT 接続数を接続状態 = 失敗にフィルターした場合、警告を発生させます。 | メトリック |

## Azure Firewall の監視

- [Firewall 健全状態の監視](https://docs.microsoft.com/en-us/azure/firewall/logs-and-metrics#metrics)
  - 可能なステータスは、「Healthy」、「Degraded」、「Unhealthy」です。
  - SNAT ポートの利用率 - 利用された SNAT ポートの割合

