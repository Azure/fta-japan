
[&larr; セキュリティベストプラクティス](./2-security-best-practices.md) | Part 3 of 6 | [運用 &rarr;](./4-operations.md)

# クラスターデプロイの自動化

概要

- なぜAKSを使いますか？
- なぜクラスターデプロイの自動化を行いますか？
- AKS クラスター設定
  - ポータルのデモ
  - Azure CLI と シェルスクリプト
- Infrastructure as Code チュートリアル
  - ["スタンプパターン"](https://docs.microsoft.com/azure/architecture/patterns/deployment-stamp) or "Cookie Cutter(型抜き型)" デプロイ
  - 設定管理
  - Key Vault の導入
  - イングレスコントローラー、TLS と DNS
- ランディングゾーンの考慮事項
- ワークロードの考慮事項
- リソースのライフサイクル
- バージョン管理
 
## AKS のための"現実的な" IaC の例

オープンソースの AKS のための Infrastructure as Code の例

- [Azure Kubernetes Service (AKS) ベースラインクラスター](https://github.com/mspnp/aks-baseline/)  
  マイクロソフトパターンアンドプラクティスチームによる ARM テンプレートとシェルスクリプトのドキュメント
  
- [cloudkube.io AKS Clusters (demo)](https://github.com/julie-ng/cloudkube-aks-clusters)  
  複数環境のための Terraform の IaC の例（以下に説明するシナリオなど、 Managed ID と Key Vault  統合など）

- [Infrastructure as Code (IaC) の比較（英語）](https://github.com/Azure/FTALive-Sessions/tree/main/content/devops/cicd-infra#infrastructure-as-code-iac-comparison) - ARM, Bicep vs Terraform comparison table from the [FTA Live for Infra as Code 配布資料（英語）](https://github.com/Azure/FTALive-Sessions/tree/main/content/devops/cicd-infra#infrastructure-as-code-iac-comparison)

### Key Vault の統合

- [Azure Docs: Use the Azure Key Vault Provider for Secrets Store CSI Driver in an AKS cluster](https://docs.microsoft.com/azure/aks/csi-secrets-store-driver) - how to enable and use as addon
- [CSI Driver Homepage](https://azure.github.io/secrets-store-csi-driver-provider-azure/docs/) - more technical details, manual installation via Helm chart, etc.

## シナリオ - アプリケーションプラットフォームとしての AKS

The following concepts and structure are a simplified version from **[Cloud Adoption Framework: Compare common cloud operating models](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/operating-model/compare)**

下記のコンセプトと構成は、**[Cloud Adoption Framework: Compare common cloud operating models](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/operating-model/compare)** の簡略バージョンです

### Operating Models 運用モデル

- Decentralized Operations 非中央集権的運用
- Centralized Operations 中央集権的運用
- Enterprise Operations エンタープライズの運用

#### Concerns 注意点

- Workload ワークロード
- Platform プラットフォーム
- Landing Zone ランディングゾーン
- Cloud Foundation クラウドの基本

#### Diagram 構成図

上記のコンセプトの実装例（アプリケーションプラットフォームとしてのAKS）

![CI/CD Separations of Concerns](../images/cicd-separation-of-concerns.png)

## Reference Links 参照リンク

Important Links 重要なリンク

- [Azure Architecture Center >  Reference Architecture > Secure AKS Baseline](https://docs.microsoft.com/azure/architecture/reference-architectures/containers/aks/secure-baseline-aks)

Miscellaneous links その他雑多なリンク

- Ingress Controllers イングレスコントローラー
  - [Traefik (open source)](https://doc.traefik.io/traefik/providers/kubernetes-ingress/)
  - [nginx (open source)](https://kubernetes.github.io/ingress-nginx/)
  - [App Gateway Ingress Controller (MSFT)](https://docs.microsoft.com/en-us/azure/application-gateway/ingress-controller-overview)
- Demo Related Terraform Files デモ関連の Terraform ファイル
  - [shared infra](https://github.com/julie-ng/cloudkube-shared-infra) for Azure DNS, Role Assignments for TLS Certificates in Key Vault 
  　
  - [workload infrastructure.tf](https://github.com/julie-ng/cloud-architecture-review/blob/main/infrastructure.tf) meant to be run by admin (Julie) to
    - create workload specific Azure Container Registry (ACR)
    - give cluster kubelets pull access to our ACR
    - create service principles for GitHub Workflows deployments to its own *namespace*
