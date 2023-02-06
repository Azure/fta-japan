# パッチとアップグレード

## AKS での Kubernetes バージョンのアップグレード

- Kubenetes バージョンは、[Semantic Versioning](https://semver.org/) の用語に従い、`major.minor.patch` の形式で表されます。たとえば、バージョン `1.23.3` では、`1` がメジャーバージョン、`23` がマイナーバージョン、`3` がパッチバージョンです。

- AKS は、3 つの GA Kubernetes マイナーバージョン (N - 2) をサポートし、各マイナーバージョンに対して 2 つの安定したパッチバージョンをサポートします。
  - Azure リージョンでサポートされているすべてのバージョンを確認するには、`az aks get-versions --location <location> --output table` を使用します。
  - クラスターがアップグレードできるバージョンを確認するには、`az aks get-upgrades --resource-group <resource group> --name <cluster name>` を使用します。

- パッチ/マイナーバージョンの削除から 30 日以内にサポートされているバージョンにアップグレードする必要があります。この時間枠内に行わないと、クラスターのサポート外となります。

- AKS クラスターをアップグレードすると、パッチバージョンをスキップできます。ただし、サポートされていないバージョンから最小サポートバージョンにアップグレードする場合を除き、コントロールプレーンのマイナーバージョンはスキップできません。ノードエージェントのマイナーバージョンは、コントロールプレーンのマイナーバージョンと同じか、コントロールプレーンのマイナーバージョンより 2 バージョン古くまでになります。以下の表は、[Version Skew Policy](https://kubernetes.io/releases/version-skew-policy/) に従ってサポートされているバージョンの SKU をまとめたものです。

    <table>
    <thead>
      <tr>
        <th>ノード</th>
        <th>コンポーネント</th>
        <th>サポートされているバージョンのSKU</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td rowspan="2">コントロールプレーン</td>
        <td>kube-apiserver</td>
        <td>- マイナーバージョンの差は 1 バージョン以内である必要があります</td>
      </tr>
      <tr>
        <td>kube-controller-manager<br>kube-scheduler<br>cloud-controller-manager</td>
        <td>- kube-apiserver より新しいバージョンであってはなりません<br>- kube-apiserver より 1 バージョン古いバージョンである必要があります</td>
      </tr>
      <tr>
        <td rowspan="2">ワーカーノード</td>
        <td>kubelet</td>
        <td>- kube-apiserver より新しいバージョンであってはなりません<br>- kube-apiserver より 2 バージョン古いバージョンである必要があります</td>
      </tr>
      <tr>
        <td>kube-proxy</td>
        <td>- kubelet と同じマイナーバージョンである必要があります</td>
      </tr>
      <tr>
        <td>クライアント</td>
        <td>kubectl</td>
        <td>- kube-apiserver より 1 バージョン新しいバージョンまたは古いバージョンである必要があります</td>
      </tr>
    </tbody>
    </table>

- AKS の Kubernetes アップグレードは、ロールバックまたはダウングレードできません。

- Kubernetes は 3 つのスコープでアップグレードできます。
  - **クラスターをアップグレードする**：`az aks upgrade --resource-group <resource group> --name <cluster name> --kubernetes-version <k8s version>`
  - **コントロールプレーンのみをアップグレードする**：`az aks upgrade --resource-group <resource group> --name <cluster name> --kubernetes-version <k8s version> --control-plane-only`
  - **ノードプールをアップグレードする**：`az aks nodepool upgrade --resource-group <resource group> --cluster-name <cluster name> --name <nodepool name> --kubernetes-version <k8s version>`

追加情報:

- [AKS のサポートされている Kubernetes バージョン](https://docs.microsoft.com/ja-jp/azure/aks/supported-kubernetes-versions)

## ノード OS をアップグレードする

- AKS クラスターの Linux ノードは、毎日更新をチェックして自動的にインストールします。しかし、更新がリブートを必要とする場合でも、AKS はノードを自動的にリブートしません。ノードを手動でリブートするか、[Kured](https://github.com/weaveworks/kured). のようなツールを使用してリブートする必要があります。ノードを手動でリブートするか、Kured を使用してリブートする場合は、キャパシティの影響に注意してください。

- AKS は、毎週最新の OS とランタイムの更新を含む新しいノードイメージを提供します。
  - ノードプールのイメージバージョンを確認するには、`az aks nodepool show --resource-group <resource group> --cluster-name <cluster name> -name <nodepool name> --query nodeImageVersion` を使用します。
  - ノードプールに利用可能な最新のイメージバージョンを確認するには、`az aks nodepool get-upgrades --resource-group <resource group> --cluster-name <cluster name> --nodepool-name <nodepool name>` を使用します。
  - クラスター内のすべてのノードのイメージをアップグレードするには、`az aks upgrade --resource-group <resource group> --name <cluster name> --node-image-only` を使用します。
  - ノードプールのイメージをアップグレードするには、`az aks nodepool upgrade --resource-group <resource group> --cluster-name <cluster name> --name <nodepool name> --node-image-only` を使用します。
- Windows ノードの OS は、イメージのみでアップグレードできます。

追加情報:

- [AKS node image upgrade](https://docs.microsoft.com/azure/aks/node-image-upgrade)

## AKS のアップグレードの仕組み

AKS は、AKS クラスターをアップグレードするための次のプロセスを実行します（デフォルトの最大サージは 1 です）。

- 指定された Kubernetes バージョンのバッファーノードがクラスターに追加されます。
- 古いノードがコーディネートされ、ドレインされます。
- 古いノードが新しいバッファーノードに再イメージされます。
- アップグレードが完了すると、最後のバッファーノードが削除されます。

## アップグレード戦略の推奨事項

- 中規模および大規模の AKS クラスターでは、まずコントロールプレーンの Kubernetes をアップグレードし、次にノードプールを一度に 1 つずつアップグレードします。クラスター全体を一度にアップグレードするのは避けてください。ただし、サポートされていないバージョンからサポートされているバージョンにクラスターをアップグレードする場合は、サポートされていないバージョンのスキューを避けるためにクラスター全体をアップグレードする必要があります。
- アップグレードの速度を向上させるには、ノードプールの最大サージを設定することを検討します。本番ノードプールでは、最大サージ設定を 33% にすることをお勧めします。

  > ⚠️
  > Azure CNI を使用している場合、最大サージを設定する場合は、ノードのサージに十分な IP アドレスがあることを確認してください。また、十分なコンピュートクォータがあることを確認してください。

- 本番環境の重要なワークロードには、[Pod Disruption Budget](https://kubernetes.io/docs/tasks/run-application/configure-pdb/) (PDB) を使用して、ワークロードの可用性を確保します。同時に、PDB がアップグレードプロセスをブロックしないことも確認してください。たとえば、`allowed disruptions` を少なくとも 1 にすることを確認してください。

- ノードプールのイメージを定期的にアップグレードすることをお勧めします。ノードプールイメージのアップグレードプロセスは、ノードを手動または Kured でパッチングおよび再起動するよりも優れています。CI/CD パイプラインまたは [auto-upgrade channel](https://docs.microsoft.com/azure/aks/upgrade-cluster#set-auto-upgrade-channel) を使用して、ノードプールのイメージを定期的にアップグレードできます。

- [Planned Maintenance](https://docs.microsoft.com/azure/aks/planned-maintenance) を使用して、アップグレードのスケジュールを制御します。

  > ⚠️
  > Auto-upgrade channel と Planned Maintenance はプレビュー機能です。

- 中規模および大規模の AKS クラスターのノードプールをアップグレードする場合、可能であれば **blue/green アップグレード戦略** を採用することを検討できます。

  > ⚠️
  > Azure CNI を使用する AKS クラスターでは、blue/green アップグレード戦略はサポートされていません。

追加情報:

- [AKS クラスターのアップグレード](https://docs.microsoft.com/azure/aks/upgrade-cluster)
- [GitHub Actions を使用した AKS ノードのアップグレード](https://docs.microsoft.com/azure/aks/node-upgrade-github-actions)
- [AKS Day-2 Operations](https://docs.microsoft.com/azure/architecture/operator-guides/aks/aks-upgrade-practices)