
[&larr; セキュリティベストプラクティス](./2-security-best-practices.md) | Part 3 of 6 | [運用 &rarr;](./4-operations.md)

# クラスターデプロイの自動化

概要

- なぜ AKS を使う必要があるのか？
- なぜクラスターデプロイの自動化を行う必要があるのか？
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


## なぜ AKS を使うのか？

- クラウドネイティブなアプリケーションの開発と運用のための、オープンソースのコンテナオーケストレーションプラットフォーム
- [AKS とは？](https://learn.microsoft.com/ja-jp/azure/aks/intro-kubernetes)

## なぜ AKS のクラスターデプロイの自動化を行う必要があるのか？

> - 前回の記事でも触れましたが、Kubernetes のリリースサイクル及び、AKSのリリースサイクルは比較的早く、バージョンアップを行う際に、クラスターの再作成が必要になるケースがあります。
> - また、何らかの理由でクラスターが不安定な状態になった場合は、クラスターの再作成が必要になります。
> - 今回の記事の中であげる、スタンプパターンを用いて、多くのリージョンに展開が必要となった場合は、クラスターの自動化により展開が楽になります。
 
## AKS のための"現実的な" IaC の例

AKS のための Infrastructure as Code の例

- [Azure Kubernetes Service (AKS) ベースラインクラスター](https://github.com/mspnp/aks-baseline/)  
  マイクロソフトパターンアンドプラクティスチームによる ARM テンプレートとシェルスクリプトのドキュメント
  - パブリックテンプレートとして公開
  - :rocket: 上記の[日本語訳](https://github.com/sasukeh/aks-baseline)をしました！
  
- [cloudkube.io AKS Clusters (demo)](https://github.com/julie-ng/cloudkube-aks-clusters)  
  複数環境のための Terraform の IaC の例（以下に説明するシナリオなど、 Managed ID と Key Vault  統合など）

- [Infrastructure as Code (IaC) の比較（英語）](https://github.com/Azure/FTALive-Sessions/tree/main/content/devops/cicd-infra#infrastructure-as-code-iac-comparison) - ARM, Bicep vs Terraform 比較表 [FTA Live for Infra as Code 配布資料（英語）](https://github.com/Azure/FTALive-Sessions/tree/main/content/devops/cicd-infra#infrastructure-as-code-iac-comparison)

### Key Vault の統合

- [Azure Docs: AKS クラスターで、シークレットストア CSI Driverのための Azure Key Vault プロバイダー を使う](https://docs.microsoft.com/azure/aks/csi-secrets-store-driver) - アドオンとしての有効化と利用方法
- [CSI Driver ホームページ](https://azure.github.io/secrets-store-csi-driver-provider-azure/docs/) - 技術的な詳細、Helm chart を使ったマニュアルインストールなどが、記載しています。

## シナリオ - アプリケーションプラットフォームとしての AKS

下記のコンセプトと構成は、**[Cloud Adoption Framework: Compare common cloud operating models](https://docs.microsoft.com/ja-jp/azure/cloud-adoption-framework/operating-model/compare)** の簡略バージョンです

### 運用モデル

- 非中央集権的運用
- 中央集権的運用
- エンタープライズの運用

#### 注意点

- ワークロード
- プラットフォーム
- ランディングゾーン
- クラウドの基本

#### 構成図

上記のコンセプトの実装例（アプリケーションプラットフォームとしてのAKS）

![CI/CD Separations of Concerns](../images/cicd-separation-of-concerns.png)

## 参照リンク

重要なリンク

- [Azure アーキテクチャーセンター >  リファレンスアーキテクチャ > AKS ベースラインの保護](https://learn.microsoft.com/azure/cloud-adoption-framework/operating-model/compare)

その他雑多なリンク

- イングレスコントローラー
  - [Traefik (オープンソース)](https://doc.traefik.io/traefik/providers/kubernetes-ingress/)
  - [nginx (オープンソース)](https://kubernetes.github.io/ingress-nginx/)
  - [App Gateway イングレスコントローラー (MSFT)](https://docs.microsoft.com/en-us/azure/application-gateway/ingress-controller-overview)
- デモ関連の Terraform ファイル
  - [共通インフラ](https://github.com/julie-ng/cloudkube-shared-infra) - Azure DNS, Key Vauilt の中の TLS Cert のためのロールアサインなど
  - [workload infrastructure.tf](https://github.com/julie-ng/cloud-architecture-review/blob/main/infrastructure.tf)
    - ワークロードが指定された Azure コンテナーレジストリーの作成
    - ACR への kubelet のプルアクセスを与える
    - 自己所有 namespace への GitHub Workflows デプロイメントのためのサービスプリンシパルの作成
