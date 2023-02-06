# AKS セキュリティのベストプラクティス

## 目的

このセッションでは、AKS クラスターを実行するときに必要なセキュリティの考え方の全体像を学びます。
ただし、アプリケーションセキュリティについては、範囲に含まれていません。

## アジェンダ

クラスターレベルセキュリティの考慮点：

- マスターノード
- ノードセキュリティ
- 認証
- アップグレード
- Azure Defender for Containers

ネットワーク・セキュリティの考慮点

- ネットワークセキュリティ
- ネットワークポリシー
- エグレスのセキュリティ

開発者/設定の考慮点：

- コンテナーセキュリティ
- Azure ポリシー
- ワークロードアイデンティティ

イメージマネージメントの考慮点：

- イメージスキャン

## クラスターレベルの考慮点

以下の考慮点は、クラスターを作る前に考えておくべきことです。

### 一般的な参照ドキュメント

- コンセプト - [アプリケーションとAKS クラスターのためのセキュリティコンセプト](https://docs.microsoft.com/ja-jp/azure/aks/concepts-security)
- ベストプラクティス - [AKSのクラスタセキュリティとアップグレードのためのベストプラクティス](https://docs.microsoft.com/ja-jp/azure/aks/operator-best-practices-cluster-security)

### Kubernetes API コントロールプレーン

マスターノードについて言及することはありますが、これらのコンポーネントはマイクロソフトが管理しています。
[こちら](https://docs.microsoft.com/ja-jp/azure/aks/concepts-security) のドキュメントでは、AKS のセキュリティコンセプトについて説明しています。

```text
デフォルトで Kubernetes API サーバーは、パブリックIPとFQDNを使っています。承認されたIPアドレスレンジを使った API サーバーエンドポイントを使ってアクセスを制限することができます。
```

- [プライベートAKSクラスターをつくる](https://docs.microsoft.com/ja-jp/azure/aks/private-clusters)
- [AKSで承認されたIPアドレスレンジを使ったAPIサーバーへのアクセスを保護する](https://docs.microsoft.com/ja-jp/azure/aks/api-server-authorized-ip-ranges)
- [プライベートAPIクラスターへアクセスするために`command invoke`を使う](https://docs.microsoft.com/ja-jp/azure/aks/command-invoke)

### Azure AD 統合

- [ローカルアカウントの無効化](https://docs.microsoft.com/ja-jp/azure/aks/managed-aad#disable-local-accounts)
- [AKS管理のAAD統合](https://docs.microsoft.com/ja-jp/azure/aks/managed-aad)
- [K8sロールベースアクセスコントロールとAADアイデンティティを使ったクラスターリソースへのアクセスコントロール](https://docs.microsoft.com/ja-jp/azure/aks/azure-ad-rbac)
- [K8s認証のためのAzure RBAC利用](https://docs.microsoft.com/ja-jp/azure/aks/manage-azure-rbac)

### ノードセキュリティ

- [AKSでのLinuxノードのセキュリティとカーネルアップデートの適用](https://docs.microsoft.com/ja-jp/azure/aks/node-updates-kured)
- [AKSノードのイメージアップグレード](https://docs.microsoft.com/ja-jp/azure/aks/node-image-upgrade)
- [AKSクラスターのアップデート > オートアップグレードチャネルの設定](https://docs.microsoft.com/ja-jp/azure/aks/upgrade-cluster#set-auto-upgrade-channel)
- [GitHub Actions を使って、AKSノードへ自動的にセキュリティアップデートを適用する](https://docs.microsoft.com/ja-jp/azure/aks/node-upgrade-github-actions)
- [AKSのメンテナンスウィンドウをスケジュールするために計画メンテナンスを利用する](https://docs.microsoft.com/ja-jp/azure/aks/planned-maintenance)
- アップグレード中のアプリケーション可用性
  - [ノードサージアップグレードのカスタマイズ](https://docs.microsoft.com/ja-jp/azure/aks/upgrade-cluster#customize-node-surge-upgrade)
  - [ポッド中断バジェットを使用して可用性を計画する](https://docs.microsoft.com/ja-jp/azure/aks/operator-best-practices-scheduler#plan-for-availability-using-pod-disruption-budgets)
  - [複数の Availability Zones にまたがるノード プールに関する特別な考慮事項](https://docs.microsoft.com/ja-jp/azure/aks/upgrade-cluster#special-considerations-for-node-pools-that-span-multiple-availability-zones)
- [AKS Ubuntu イメージと Center for Internet Security (CIS) ベンチマークのアラインメント](https://docs.microsoft.com/ja-jp/azure/aks/security-hardened-vm-host-image)

### インスタンスメタデータAPIへのアクセス制限

- [AKS でのクラスターのセキュリティとアップグレードに関するベスト プラクティス](https://docs.microsoft.com/ja-jp/azure/aks/operator-best-practices-cluster-security) > [Instance Metadata API へのアクセスを制限する](https://docs.microsoft.com/ja-jp/azure/aks/operator-best-practices-cluster-security#restrict-access-to-instance-metadata-api)

### Kubernetes のバージョンアップグレード

- サポートについて、クラスターについては、n-2 の kubernetes バージョンをサポートします。詳細については、こちらを確認してください
- [Kubernetes バージョンサポートポリシー](https://docs.microsoft.com/ja-jp/azure/aks/supported-kubernetes-versions?tabs=azure-cli#kubernetes-version-support-policy)
- [自動アップグレードチャネルを考慮する](https://docs.microsoft.com/ja-jp/azure/aks/upgrade-cluster#set-auto-upgrade-channel)
- [通知を得るためにイベントにサブスクライブする](https://docs.microsoft.com/ja-jp/azure/aks/quickstart-event-grid)、さらに、新しいKubernetesバージョンを利用可能になったときに自動化する
- クラスターアップグレードが必要なとき、[node surges](https://docs.microsoft.com/ja-jp/azure/aks/upgrade-cluster#customize-node-surge-upgrade) のために、リソースクオーターとIPアドレスの余裕を確保する
  
### 定期的に、証明書をローテートする

- [AKSにおける、証明書のローテーション](https://docs.microsoft.com/ja-jp/azure/aks/certificate-rotation) - Note: there is a 30 min downtime for manually invoked certificate rotation operations.

### コンピュートノードの分離（必須ではない）

- [Azure の仮想マシン分離](https://docs.microsoft.com/ja-jp/azure/virtual-machines/isolation)
- 近傍ノードが同じハードウェアで動く懸念がある場合に分離仮想マシンタイプを利用する [AKS で システムノードを管理する方法](https://docs.microsoft.com/ja-jp/azure/aks/use-system-pools)
- ノート：これは、レジリエンシーのベストプラクティスであり、セキュリティに必要なものではありません

### コンテナーレジストリーとクラスターの統合

- [AKSからコンテナーレジストリーの認証をする](https://docs.microsoft.com/ja-jp/azure/aks/cluster-container-registry-integration?tabs=azure-cli)

### SSHの有効化（必須ではない）

- [メンテナンスとトラブルシューティングのためにAKSのクラスターノードに接続する](https://docs.microsoft.com/ja-jp/azure/aks/node-access)

### モニタリングとアラートの有効化

- `--enable-addons monitoring` フラグを使って[クラスターを作る](https://docs.microsoft.com/ja-jp/cli/azure/aks?view=azure-cli-latest#az-aks-create) 
- [コンテナーインサイトの概要](https://docs.microsoft.com/ja-jp/azure/azure-monitor/containers/container-insights-overview)
- [コンテナーインサイトを使ったプロメテウスのスクレイピングの設定](https://docs.microsoft.com/ja-jp/azure/azure-monitor/containers/container-insights-prometheus-integration)
- [リアルタイムでの Kubernetes ログ、イベント、ポッドメトリクスの見方](https://docs.microsoft.com/ja-jp/azure/azure-monitor/containers/container-insights-livedata-overview)
- アラートを有効化するための推奨メトリクスについてはこちらを御覧ください [コンテナーインサイトで使うべきメトリックアラート](https://docs.microsoft.com/ja-jp/azure/azure-monitor/containers/container-insights-metric-alerts#enable-alert-rules)

### Azure Defender for Container の有効化

- 課金されるためデフォルトでは有効化されていません
  - [Defender の価格表](https://azure.microsoft.com/pricing/details/defender-for-cloud/)

- [Defender for Container の概要](https://docs.microsoft.com/ja-jp/azure/defender-for-cloud/defender-for-containers-introduction)
  - [Kubernetesノードとクラスタのためのランタイム保護](https://docs.microsoft.com/ja-jp/azure/defender-for-cloud/defender-for-containers-introduction?tabs=defender-for-container-arch-aks#run-time-protection-for-kubernetes-nodes-and-clusters)
- Reference list [コンテナーとクラスターのためのアラート](https://docs.microsoft.com/ja-jp/azure/defender-for-cloud/alerts-reference#alerts-k8scluster)

### ノードプールをまたいだアプリの分離（必須ではない）

- [AKS クラスターのための複数ノードプールの作成と管理](https://docs.microsoft.com/ja-jp/azure/aks/use-multiple-node-pools)

### 暗号化

- [Azure ディスクのための自己所有キーの利用](https://docs.microsoft.com/ja-jp/azure/aks/azure-disk-customer-managed-keys)
- [AKS ホストの暗号化](https://docs.microsoft.com/ja-jp/azure/aks/enable-host-encryption)

### ネットワークの考慮点

- [AKS上のアプリのためのネットワークコンセプト](https://docs.microsoft.com/ja-jp/azure/aks/concepts-network)

### ネットワークセキュリティ

- AKSでは、クラスターノードの NIC に NSG をつけることはサポートされていません
- サブネット NSG について、管理トラフィックをブロックしていないことを確認してください
  - 詳細はこちら [Azure ネットワークセキュリティグループ](https://docs.microsoft.com/ja-jp/azure/aks/concepts-security#azure-network-security-groups)
- [AKS でネットワークポリシーを使いポッド間のトラフィックをセキュアにする](https://docs.microsoft.com/ja-jp/azure/aks/use-network-policies)

### プライベートリンク

- プライベートIPアドレス経由での Azureリソース に接続するとき可能であれば、[プライベートエンドポイント](https://docs.microsoft.com/ja-jp/azure/private-link/private-endpoint-overview) を使ってください
- [コンテナーレジストリーのためのプライベートリンク](https://docs.microsoft.com/ja-jp/azure/container-registry/container-registry-private-link?ref=akschecklist)
- [キーボルトのためのプライベートリンク](https://docs.microsoft.com/ja-jp/azure/key-vault/general/private-link-service?tabs=portal)

### ネットワークポリシー

- [AKSのネットワークポリシーを使ってポッド間トラフィックを保護する](https://docs.microsoft.com/ja-jp/azure/aks/use-network-policies)
  - [Azure と　Calico ポリシー間の違いとそれらの機能性](https://docs.microsoft.com/ja-jp/azure/aks/use-network-policies#differences-between-azure-and-calico-policies-and-their-capabilities)

### Kubernetes のサービスを公開する

- ロードバランスされたポッドを公開するためにパブリックIPアドレスを使うことを避ける
- リバースプロキシーへイングレスコントローラーを使い、Kubernetes の Service を束ねる
  - [AKSで内部仮想ネットワークへのIngressコントローラを作成する](https://docs.microsoft.com/ja-jp/azure/aks/ingress-internal-ip?tabs=azure-cli)
- Kubernetes クラスターの同じ仮想ネットワーク内で実行されるアプリケーションだけにアクセスさせるために、”Kubernetes クラスターでは内部ロード バランサーを使用する必要がある” [ポリシー](https://docs.microsoft.com/ja-jp/azure/aks/policy-reference)を使う

### エグレストラフィックのセキュリティ

- [AKSのクラスターノードのために エグレストラフィックを操作する](https://docs.microsoft.com/ja-jp/azure/aks/limit-egress-traffic)
  - プライベートクラスターとスタンダード LB でエグレストラフィックのためにパブリック IP の利用を避ける
- [クラスターエグレスをユーザー定義ルートでカスタマイズする](https://docs.microsoft.com/ja-jp/azure/aks/egress-outboundtype)
  - [`loadBalancer` の外部接続タイプ](https://docs.microsoft.com/ja-jp/azure/aks/egress-outboundtype#outbound-type-of-loadbalancer)
  - [`userDefinedRouting` の外部接続タイプ](https://docs.microsoft.com/ja-jp/azure/aks/egress-outboundtype#outbound-type-of-userdefinedrouting)

## 開発者/マニフェスト/設定の注意点

- [AKS でのポッドセキュリティのためのベストプラクティス](https://docs.microsoft.com/ja-jp/azure/aks/developer-best-practices-pod-security)
- [Pod もしくはコンテナーのためのセキュリティコンテキストの設定](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)
- [Azure ビルトインポリシー](https://docs.microsoft.com/ja-jp/azure/aks/policy-reference) "Kubernetes クラスターで特権コンテナーを許可しない"
  - [ポリシーの定義](https://portal.azure.com/#blade/Microsoft_Azure_Policy/PolicyDetailBlade/definitionId/%2Fproviders%2FMicrosoft.Authorization%2FpolicyDefinitions%2F95edb821-ddaf-4404-9732-666045e056b4) - Azure ポータルで開いてください
- [App Armor を使ってコンテナーアクションの制限](https://docs.microsoft.com/ja-jp/azure/aks/operator-best-practices-cluster-security#app-armor)

### シークレットの外部化

- [シークレットストア CSI ドライバーのための、Azure Key Vault](https://github.com/Azure/secrets-store-csi-driver-provider-azure)
- [AKS クラスターで、シークレットストア CSI ドライバーのための Azure Key Vault プロバイダーを使う](https://docs.microsoft.com/ja-jp/azure/aks/csi-secrets-store-driver)

### ワークロードアイデンティティ

- [Kubernetesのための AAD ワークロードアイデンティティの発表](https://cloudblogs.microsoft.com/opensource/2022/01/18/announcing-azure-active-directory-azure-ad-workload-identity-for-kubernetes/)
  - [サービスプリンシパルのサポート](https://learn.microsoft.com/ja-jp/azure/aks/kubernetes-service-principal?tabs=azure-cli)
  - [マネージドIDのサポート](https://learn.microsoft.com/ja-jp/azure/aks/use-managed-identity)
- [ワークロードIDフェデレーション](https://docs.microsoft.com/ja-jp/azure/active-directory/develop/workload-identity-federation)
- [ポッドアイデンティティ(プレビュー)](https://docs.microsoft.com/ja-jp/azure/aks/use-azure-ad-pod-identity) 
  - 数年前には、ポッドアイデンティティについてアナウンスしましたが、これは、GAしないことになりました。  
代わりに、[ワークロードID](https://learn.microsoft.com/ja-jp/azure/aks/workload-identity-overview)を使ってください。

### ネームスペースを使う

- [Kubernetesのドキュメンテーション: ネームスペース](https://kubernetes.io/ja/docs/concepts/overview/working-with-objects/namespaces/)

## ガバナンスの懸念点と Azure ポリシー

- [Kubernetes クラスターのための Azure ポリシーの理解](https://docs.microsoft.com/ja-jp/azure/governance/policy/concepts/policy-for-kubernetes)
- [AKS の Azure ポリシービルトイン定義](https://docs.microsoft.com/ja-jp/azure/aks/policy-reference)
- [Kubernetes Pod セキュリティ標準](https://kubernetes.io/docs/concepts/security/pod-security-standards/) 仕様の実装を表現する、[ポリシー イニシアティブ](https://docs.microsoft.com/ja-jp/azure/aks/policy-reference#initiatives)
- ポリシーエクステンションは、自動的に、 [Defender for Cloud 設定](https://docs.microsoft.com/ja-jp/azure/defender-for-cloud/kubernetes-workload-protections#configure-defender-for-containers-components) から自動的にプロビジョニングされます。

## イメージ管理の懸念点

下記の内容で、AKS クラスターとコンテナーイメージを保護します。

### イメージスキャン

- [脆弱性対応のために、Defernder for Container を使い、イメージをスキャンする](https://docs.microsoft.com/ja-jp/azure/defender-for-cloud/defender-for-container-registries-usage)
- [Defender for Containers の概要](https://docs.microsoft.com/ja-jp/azure/defender-for-cloud/defender-for-containers-introduction)
  - [ノードとクラスタのためのランタイム保護](https://docs.microsoft.com/ja-jp/azure/defender-for-cloud/defender-for-containers-introduction?tabs=defender-for-container-arch-aks#run-time-protection-for-kubernetes-nodes-and-clusters)
- [CI/CDワークフローの中で、コンテナーイメージの脆弱性を特定する](https://docs.microsoft.com/ja-jp/azure/defender-for-cloud/defender-for-container-registries-cicd)

### コンテナーレジストリーアクセス

- [Azure ビルトインポリシー](https://docs.microsoft.com/ja-jp/azure/aks/policy-reference#microsoftcontainerservice) "Kubernetes クラスター コンテナーでは、許可されているイメージのみを使用する必要がある"
  - [Policy Definition](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Kubernetes/ContainerAllowedImages.json)
- [Azure コンテナーレジストリーのロールと許可](https://docs.microsoft.com/ja-jp/azure/container-registry/container-registry-roles?tabs=azure-cli) を通じてレジストリーにアクセスする
- [Azure Private Link を使ったコンテナーレジストリーへの閉じた接続](https://docs.microsoft.com/ja-jp/azure/container-registry/container-registry-private-link)
