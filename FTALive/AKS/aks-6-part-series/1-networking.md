Part 1 of 6 | [セキュリティベストプラクティス &rarr;](./2-security-best-practices.md)

# ネットワーク

> **メモ**
> _この配布資料は、事前に用意されており、実際のセッションの内容とは、議論によって異なる可能性があります_

### 概念

- [AKS ネットワーク接続とセキュリティに関するベストプラクティス](https://learn.microsoft.com/ja-jp/azure/aks/operator-best-practices-network)
  - 適切なネットワークモデルを選択する
    AKSには、2つのネットワークモデルがあります
    - CNIネットワーク
    - Kubenet ネットワーク
    - この2つのネットワークの違いを理解するために以下の資料が役に立ちます
      - 参考：[ネットワークモデルの比較表 - Kubenet vs Azure CNI](https://learn.microsoft.com/ja-jp/azure/aks/concepts-network#compare-network-models)
  - Ingress トラフィックを分散する
    - Ingress リソース（yamlファイルの例）
    - Ingress コントローラー
      - Nginx だけでなく、Contour、HAProxy、Traefik なども使えます
  - WAF を使ったトラフィックの保護
    - 外部からのトラフィックを保護するために、Azure Application Gateway、Azure Front Door、Azure Firewall を使う
    - 例では、Azure Application Gateway を使っています
  - ネットワークポリシーを使用してトラフィックフローを制御する
  - 踏み台ホストを介してノードに安全に接続する
    - Azure Bastion Service を使う

### どのようにして、自分で管理している VNET を AKSに接続するのか？

この疑問を解消するために以下の2つの記事が役にたちます。シンプルな例ですが、これらの記事を参考にして、自分の環境に適したネットワークモデルを選択してください。

- [仮想ネットワークとkubenet](https://docs.microsoft.com/azure/aks/configure-kubenet)
  - こちらの記事では、kubenet を利用して AKS と VNET を接続する方法を説明しています
- [仮想ネットワークとAzure CNI](https://docs.microsoft.com/azure/aks/configure-azure-cni)
  - こちらの記事では、Azure CNIを利用して AKS と VNET を接続する方法を説明しています

### Cloud Adoption Framework (CAF) 推奨事項

- [AKS ネットワークデザインの推奨事項](https://docs.microsoft.com/azure/cloud-adoption-framework/scenarios/app-platform/aks/network-topology-and-connectivity#design-recommendations)
  - ネットワークモデルの選択
    - Kubenet vs　Azure CNI
  - 仮想ネットワークサブネットのネットワークサイズの指定
  - DDoSなどからの保護
    - Azure Firewall または、WAF　を使用する場合以外のシナリオでの、仮想ネットワークの保護には、Azure DDoS Protection Standard を使います
  - DNSの構成
    - Azure VirtualWAN or ハブスポーク構成、AzureのDNSゾーン、独自のDNSなど全体のネットワークで使われるDNS構成を使います
  - Private Link の活用
    - マネージド Azure サービス (Azure Storage、Azure Container Registry、Azure SQL Database、Azure Key Vault など) にプライベート IP ベースの接続をします
  - Ingress Controller の選択
    - 高度なHTTPルーティングとセキュリティを提供する目的で、アプリケーションのための単一エンドポイントを提供します（ゲートウェイパターン）
  - Incoming Traffic の暗号化
    - Ingress の通信には、全てTLS暗号化を使用します
  - 外部 Ingress コントローラーの利用
    - 必要に応じて、クラスターの外にIngressコントローラを用意します
      - Application Gateway Ingress Controller アドオンの利用
      - AKS クラスターごとに、Application Gateway を用意します
      - AGIC が必要な機能を提供していない場合は、Nginx、Traefik その他のIngressコントローラを使用します
  - WAFの利用
    - インターネットの接続点を持っている場合、WAF を活用して、インターネットからのアクセスを保護します
  - 外向きの通信について
    - AKSクラスターからの外向きの送信インターネットトラフィックの制限がセキュリティポリシーにある場合は、Azure Firewall 及び、ハブにデプロイされたNVAを使って送信トラフィックに制限をかけます
  - プライベートクラスタでない場合は、許可されたIP範囲を使用する
  - Azure Load Balancer のSKU
    - Basic ではなく、Standard を使用してください
  - [プライベートAKSクラスターのデプロイ](https://learn.microsoft.com/ja-jp/azure/aks/private-clusters)
  - プライベートDNSの設定
    - システム
    - None
    - カスタムプライベートDNSゾーン
      - CUSTOM_PRIVATE_DNS_ZONE_RESOURCE_ID

## Misc. Links

出席者の質問に基づいてチャットで共有されるリンク

### カスタムマネージドリソースグループネーム

For people who prefer different conventions, e.g. `-rg` suffix over default `MC_` prefix
AKSノードリソースグループに独自の名前を付けたい場合。例えば、"-rg", "MC_"以外の名前など。

- [MS Docs - FAQ](https://docs.microsoft.com/azure/aks/faq#can-i-provide-my-own-name-for-the-aks-node-resource-group)
- [Terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#node_resource_group)  `node_resource_group` 属性を利用する
- [Azure CLI](https://docs.microsoft.com/cli/azure/aks?view=azure-cli-latest#az-aks-create)  `--node-resource-group` オプションをクラスターを作るときに付与する

### Kubernetes のサービスタイプ

[Kubernetes Docs: サービスタイプ](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types)

- クラスターIP
- [ノードポート](https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport)
- [ロードバランサー](https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer)
- [エクスターナルネーム](https://kubernetes.io/docs/concepts/services-networking/service/#externalname)

### クラスターにはどのネットワークモデルがありますか？

[`az aks show command`](https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az-aks-show) で見つけることができます。
