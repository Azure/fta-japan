[&larr; モニター](./5-monitoring.md) | Part 6 of 6

# ワークロードデプロイの自動化

## アジェンダ

- アプリケーションログ (part 5 からのパーキング) - 5 分
- Pod Identity と Workload Identity (part 2 からのパーキング) - 15 分
- Key Vault Integration (part 2 からのパーキング) - 10 分
- ワークロードデプロイ - 25 分
  - Push モデル (従来の CI/CD)
  - Pull モデル (GitOps)
- バージョニングとリリース - 5 分
  - イメージのプロモーション
  - ディストリビューション vs 構成管理

## 残されたトピック

### アプリケーションログ

_このトピックは part 5 で残されたものです。_

- [Azure Docs: アプリケーションインサイトの仕組み](https://docs.microsoft.com/ja-jp/azure/azure-monitor/app/app-insights-overview#how-application-insights-works)
- Node.js のデモ
  - [アプリケーションインサイトで Node.js サービスとアプリを監視する](https://docs.microsoft.com/ja-jp/azure/azure-monitor/app/nodejs)
  - Middleware コードの例: [app/middleware/monitor.js](
  - Azure Portal のスクリーンショット  
    <img src="./images/appinsights-loganalytics-portal.png" width="400">
- ファイルシステムにログを出力するレガシーアプリ？ [Tailing Sidecars Pattern (learnk8s.io)](https://learnk8s.io/sidecar-containers-patterns#tailing-logs) を試してみてください。

### Pod Identity と Workload Identity

_このトピックは part 2 で残されたものです。_

- [Azure AD の Workload Identity](https://azure.github.io/azure-workload-identity/docs/) - pod identity の後継
- [Azure AD の Pod Identity](https://azure.github.io/aad-pod-identity/) - 新規プロジェクトにはお勧めしません。[アナウンス](https://cloudblogs.microsoft.com/opensource/2022/01/18/announcing-azure-active-directory-azure-ad-workload-identity-for-kubernetes/) をご覧ください。

### Key Vault Integration (エンドツーエンド)


_このトピックは part 2 で残されたものです。_


- [シークレットストア CSI ドライバーの Key Vault プロバイダー](https://github.com/Azure/secrets-store-csi-driver-provider-azure) - [Helm](https://azure.github.io/secrets-store-csi-driver-provider-azure/docs/getting-started/installation/#deployment-using-helm) を使った自己インストール
- [AKS クラスターでシークレットストア CSI ドライバーの Key Vault プロバイダーを使用する](https://docs.microsoft.com/ja-jp/azure/aks/csi-secrets-store-driver) - Azure 管理のアドオンとして

## ワークロードのデプロイを自動化する


### プルモデル (GitOps)

- [Flux CD](https://fluxcd.io/) - the GitOps family of projects
- [Argo CD](https://argoproj.github.io/cd/) - Declarative continuous delivery with a fully-loaded UI

### プッシュモデル (従来の CI/CD)

- [Demo Node.js App with GitHub Workflows](https://github.com/julie-ng/cloud-architecture-review/tree/main/.github/workflows)

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

- [セマンティック バージョニング 2.0.0 仕様](https://semver.org/)
- [Helm](https://helm.sh/) - Kubernetes のパッケージマネージャー
  - 例: [csi-secrets-store-provider-azure](https://github.com/Azure/secrets-store-csi-driver-provider-azure/tree/master/charts/csi-secrets-store-provider-azure) Helm Chart
- [Kustomize](https://kustomize.io/) - Kubernetes ネイティブの構成管理

### Pod の終了

- [Kubernetes Docs > コンセプト > Pod Lifecycle > Temination](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#pod-termination)
- [デモからの例: サーバーまたは DB 接続を閉じる](https://github.com/julie-ng/cloud-architecture-review/blob/main/server/express.js#L35)
  
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

