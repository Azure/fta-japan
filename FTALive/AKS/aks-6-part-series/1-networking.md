Part 1 of 6 | [セキュリティベストプラクティス &rarr;](./2-security-best-practices.md)

# ネットワーク

> **メモ**
> _この配布資料は、事前に用意されており、実際のセッションの内容とは、議論によって異なる可能性があります_

### 概念

- [AKS ネットワークの紹介](https://docs.microsoft.com/azure/aks/concepts-network)
- [AKS ネットワークのベストプラクティス](https://docs.microsoft.com/azure/aks/operator-best-practices-network)
- [ネットワークモデルの比較表 - Kubenet vs Azure CNI](https://docs.microsoft.com/en-us/azure/aks/concepts-network#compare-network-models)

### How-To Bring Your Own (BYO) Virtual Network

- [仮想ネットワークとkubenet](https://docs.microsoft.com/azure/aks/configure-kubenet)
- [仮想ネットワークとAzure CNI](https://docs.microsoft.com/azure/aks/configure-azure-cni)

### Cloud Adoption Framework (CAF) Recommendations

- [AKS ネットワークデザインの推奨事項](https://docs.microsoft.com/azure/cloud-adoption-framework/scenarios/app-platform/aks/network-topology-and-connectivity#design-recommendations)

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
