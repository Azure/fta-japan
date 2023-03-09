[&larr; モニター](./5-monitoring.md) | Part 6 of 6

# ワークロードデプロイの自動化

## アジェンダ

- ワークロードデプロイ - 25 分
  - Push モデル (従来の CI/CD)
  - Pull モデル (GitOps)
- バージョニングとリリース - 5 分
  - イメージのプロモーション
  - ディストリビューション vs 構成管理

- 補足事項
  - アプリケーションログ - 5 分
  - Pod Identity と Workload Identity - 15 分
  - Key Vault Integration - 10 分

## ワークロードデプロイ

本セッションでは、AKS に限った話ではありませんが、Kubernetes のワークロードデプロイメントパターンについて説明します。

一般的な Kubernetes のワークロードのデプロイパターンは、様々ありますが、手動でデプロイを行う事はほとんどありません。代わりに、CI/CD パイプラインを使用して、コードの変更をトリガーにして、自動的にデプロイを行います。

自動的にデプロイを実施することで、開発者はコードの変更を行った後、手動でデプロイを行う必要がなくなります。また、デプロイの失敗を防ぐことができますし、デプロイの失敗時には、自動的にロールバックを行うことができます。

段階的に、Kubernetes のデプロイに慣れて行く必要がありますし、いきなり GitOps に移行するのも難しいと思います。そのため、まずは従来の CI/CD パイプラインを使用して、デプロイを自動化することをお勧めします。

## ワークロードのデプロイを自動化する

### プッシュモデル (従来の CI/CD)

プッシュモデルでは、コードの変更をトリガーにして、自動的にデプロイを行います。

プッシュモデルの参考にできる、GitHub ワークフローを用意しているので、これをベースに考えます。
- [Demo Node.js App with GitHub Workflows](https://github.com/julie-ng/cloud-architecture-review/tree/main/.github/workflows)

基本的なパイプラインの流れとしては、この様になっています。
1. GitHub にコードをプッシュする
2. コードベースに従って、CIのパイプラインを使って、ビルド、テスト
3. Azure Container Registry の機能を使って、コンテナーイメージをビルド、プッシュ
4. `kubectl` を用いて、Kubernetes にデプロイする

### プルモデル (GitOps)

一方で、プルモデルは、Gitリポジトリとコンテナーレジストリーを Kubernetes 上の Agent からポーリングし、状態変化があれば、自動的にデプロイを行います。

- [Flux CD](https://fluxcd.io/) - the GitOps family of projects
  - [チュートリアル: GitOps with Flux v2 を使ってアプリケーションをデプロイする](https://learn.microsoft.com/ja-jp/azure/azure-arc/kubernetes/tutorial-use-gitops-flux2?tabs=azure-cli)
  - [チュートリアル: GitOps (Flux v2) を使用して CI/CD を実装する](https://learn.microsoft.com/ja-jp/azure/azure-arc/kubernetes/tutorial-gitops-flux2-ci-cd)
  - [チュートリアル: GitOps を使用したマルチクラスター環境でのワークロード管理](https://learn.microsoft.com/ja-jp/azure/azure-arc/kubernetes/tutorial-workload-management)
- [Argo CD](https://argoproj.github.io/cd/) - Declarative continuous delivery with a fully-loaded UI

### イメージのビルド

プッシュモデルとプルモデルの両方に関連

- ウォークスルー [`.github/workflows/_docker.yaml`](https://github.com/julie-ng/cloud-architecture-review/blob/main/.github/workflows/_docker.yaml)
- 以下のようなタグ付けの例

  | トリガー | タグの例 | 詳細 |
  |:--|:--|:--|
  | `main` ブランチへのプッシュ | `dev-e6c52a4` | git sha がイメージ名に追加されます |
  | `staging` ブランチへのプッシュ | `staging-e6c52a4` | 既存の dev イメージを取得し、プレフィックスを `staging-` に変更してレジストリに再プッシュします。|
  | タグのプッシュ、例えば `v0.1.0` | `0.1.0` | semver に従います。staging イメージを git sha を使って再タグ付けしてプロモートします (実装予定) |

 注記: ベストプラクティスは [production images をロック](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-image-lock) して不変性と削除を防ぐことです。

### バージョニングとリリース

リリース時のバージョン管理についてですが、マイクロサービスをデプロイするときには、バージョニングとリリースの概念が必要になります。例えば、コンテナーのバージョンをいつでも latest タグをつけてデプロイするのではなく、バージョンを明示的に指定するようにします。この場合、全てのリリースにおいて、バージョンを意識することで、コードベースのバージョンと実際に動いているコンテナーのバージョンを一致させることで、どの変更で、どのようなことが起きたかを把握することができるようになります。

バージョンの付け方は、様々ありますが、一般的に、セマンティックバージョニングを採用することが多いと思います。
- [セマンティック バージョニング 2.0.0 仕様](https://semver.org/)

また、リリースの管理については、以下のような方法があります。
- [Helm](https://helm.sh/) - Kubernetes のパッケージマネージャー
  - 例: [csi-secrets-store-provider-azure](https://github.com/Azure/secrets-store-csi-driver-provider-azure/tree/master/charts/csi-secrets-store-provider-azure) Helm Chart
- [Kustomize](https://kustomize.io/) - Kubernetes ネイティブの構成管理

### Container の Prove

pod をデプロイするときに、Kubernetes の Probe を設定することができます。これにより、コンテナー/pod が正常に動作しているかどうかを確認することができます。Kubernetes の Probe には、以下のようなものがあります。

- liveness Probe
  liveness Probe は、コンテナーが動作しているかどうかを確認するために使用されます。例えば、コンテナーが起動してから、一定時間経過しても、コンテナーが起動していない場合、コンテナーは再起動されます。
- rediness Probe
  rediness Probe は、コンテナーがリクエストを受け付ける準備ができているかどうかを確認するために使用されます。例えば、コンテナーが起動してから、一定時間経過しても、リクエストの反応がない場合には、コンテナーは再起動されます。
- startupProve
  startupProve は、コンテナーないのアプリケーションが正常に起動しているかをチェックします。startupProve が設定されている場合は、livenessProve と redinessProve は無視されます。

### Pod の終了

- [Kubernetes Docs > コンセプト > Pod Lifecycle > Temination](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#pod-termination)
- [デモからの例: サーバーまたは DB 接続を閉じる](https://github.com/julie-ng/cloud-architecture-review/blob/main/server/express.js#L35)
  

## 補足事項
### アプリケーションログ

_このトピックは part 5 の補足です。_

- [Azure Docs: アプリケーションインサイトの仕組み](https://docs.microsoft.com/ja-jp/azure/azure-monitor/app/app-insights-overview#how-application-insights-works)
- Node.js のデモ
  - [アプリケーションインサイトで Node.js サービスとアプリを監視する](https://docs.microsoft.com/ja-jp/azure/azure-monitor/app/nodejs)
  - Middleware コードの例: [app/middleware/monitor.js](
  - Azure Portal のスクリーンショット  
    <img src="./images/appinsights-loganalytics-portal.png" width="400">
- ファイルシステムにログを出力するレガシーアプリ？ [Tailing Sidecars Pattern (learnk8s.io)](https://learnk8s.io/sidecar-containers-patterns#tailing-logs) を試してみてください。

### Pod Identity と Workload Identity

_このトピックは part 2 の補足です。_

- [Azure AD の Workload Identity](https://azure.github.io/azure-workload-identity/docs/) - pod identity の後継
- [Azure AD の Pod Identity](https://azure.github.io/aad-pod-identity/) - 新規プロジェクトにはお勧めしません。[アナウンス](https://cloudblogs.microsoft.com/opensource/2022/01/18/announcing-azure-active-directory-azure-ad-workload-identity-for-kubernetes/) をご覧ください。

### Key Vault Integration (エンドツーエンド)

_このトピックは part 2 の補足です。_

- [シークレットストア CSI ドライバーの Key Vault プロバイダー](https://github.com/Azure/secrets-store-csi-driver-provider-azure) - [Helm](https://azure.github.io/secrets-store-csi-driver-provider-azure/docs/getting-started/installation/#deployment-using-helm) を使った自己インストール
- [AKS クラスターでシークレットストア CSI ドライバーの Key Vault プロバイダーを使用する](https://docs.microsoft.com/ja-jp/azure/aks/csi-secrets-store-driver) - Azure 管理のアドオンとして

## その他の参考資料

### Azure コンテナレジストリ

- [Azure コンテナレジストリのベストプラクティス](https://docs.microsoft.com/ja-jp/azure/container-registry/container-registry-best-practices)
- [コンテナイメージのタグ付けとバージョニングに関する推奨事項](https://docs.microsoft.com/ja-jp/azure/container-registry/container-registry-image-tag-version)
- [Azure コンテナレジストリに Helm チャートをプッシュおよびプルする](https://docs.microsoft.com/ja-jp/azure/container-registry/container-registry-helm-repos)
- [Azure コンテナレジストリからイメージを自動的に削除する](https://docs.microsoft.com/ja-jp/azure/container-registry/container-registry-auto-purge)

### kubelogin - AAD Integrated AKS クラスターへの認証

Kubernetes ローカルアカウントが [無効](https://docs.microsoft.com/ja-jp/azure/aks/managed-aad#disable-local-accounts) になっている場合に関連します。

- [kubelogin](https://github.com/azure/kubelogin) plugin は 2019 年に [Kubernetes in-tree provider authencation を置き換えました](https://kubernetes.io/blog/2019/04/17/the-future-of-cloud-providers-in-kubernetes/#in-tree-out-of-tree-providers)。
- Azure Pipelines - OOTB(Out of the Box) のソリューションはありません。
  [azure/kubelogin/issues/20](https://github.com/Azure/kubelogin/issues/20#issuecomment-922023848) スレッドを参照してください。

### Misc. Application Logging

### その他のアプリケーション ロギング

- [Azure クラウド コンピューティング辞書 - ミドルウェアとは?](https://azure.microsoft.com/ja-jp/resources/cloud-computing-dictionary/what-is-middleware/)
- ログのフォーマット  
  Node.js のベストプラクティスは、下流の処理を簡単かつ迅速に行うために JSON 形式でログを記録することです。
  - [例: Apache](https://httpd.apache.org/docs/2.4/logs.html)
  - [npm モジュール: natural json logger](https://github.com/pinojs/pino)
  - [npm モジュール: pino-pretty](https://github.com/pinojs/pino-pretty) - ローカル開発でログを人間が読めるようにパイプします。
