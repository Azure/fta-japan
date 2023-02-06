# リソース管理

## Kubernetesでのリソース管理の仕組み

ポッドがスケジュールされるとき、Kubernetesのスケジューラーは、各ノードで現在の実際のリソース使用量を見るのではなく、ノードの`node allocatable`とノード上のすべてのポッドの`resource requests`の合計を使用して決定を行います。

- `resource limits`が定義されている場合、コンテナがリソースの制限を超えて使用しようとすると、以下のようになります。
  - 圧縮可能なCPUを超えて使用しようとすると、CPU時間が制限されます。
  - 圧縮不可能なメモリを超えて使用しようとすると、コンテナが終了します。

- スケジューラーは、ポッドをスケジュールするときに`resource requests`のみを使用するため、ノードは過剰に割り当てられる可能性があります。ノード上のすべてのポッドの`resource limits`の合計が、ノードの`node allocatable`よりも大きくなる可能性があります。

- ノードはリソース圧迫の下にあるとき、ノード上で実行されているポッドを削除してリソースを回収することができます。これを行う必要がある場合、次の順序で、どのポッドを最初に削除するかを識別します。
  1. ポッドのリソース使用量が`resource requests`を超えているかどうか
  2. ポッドの優先度
  3. ポッドのリソース使用量が`resource requests`に対する相対的な使用量

追加情報:

- [コンテナのリソース管理](https://kubernetes.io/ja/docs/concepts/configuration/manage-resources-containers/)
- [ノード圧迫による削除](https://kubernetes.io/ja/docs/concepts/scheduling-eviction/node-pressure-eviction/)
- [AKSのリソース予約](https://docs.microsoft.com/ja-jp/azure/aks/concepts-clusters-workloads#resource-reservations)

## リソース管理の推奨事項

ポッドのすべてのコンテナーに**リソース要求と制限**を定義します。本番環境の重要なポッドでは、リソース要求と制限を同じ数値に設定して、ポッドの[QoSクラス](https://kubernetes.io/docs/tasks/configure-pod-container/quality-service-pod/)を**Guaranteed**に設定します。

- 同じクラスター上で実行されている異なるアプリケーションの副作用を減らすために、**リソースクォータ**をネームスペースに使用します。**LimitRange**を使用して、リソース要求と制限が定義されていないポッドにデフォルトの要求と制限を適用します。

- [Azure Policy](https://docs.microsoft.com/azure/aks/policy-reference)を有効にして、ポッドのCPUとメモリ制限を強制します。

- [Container Insights](https://docs.microsoft.com/azure/azure-monitor/containers/container-insights-overview)を有効にして、ポッドとノードのリソース使用状況を監視します。リソース要求と制限を適切に調整します。

- `OOM Killed Containers`、`Pods ready %`などのContainer Insightsの推奨メトリックアラートを有効にして、OOMKilledエラーを監視します。

- システムノードプールとユーザーノードプールを使用して、システムポッドとアプリケーションポッドを分離します。

- Kubernetesノードでは、Kubernetes以外のソフトウェアをインストールしないでください。ノードにソフトウェアをインストールする必要がある場合は、DaemonSetなどを使用して、Kubernetesのネイティブな方法を使用してください。

  > ⚠️
  > [AKSサポートポリシー](https://docs.microsoft.com/azure/aks/support-policies#shared-responsibility)に従って、IaaS APIのいずれかを使用してエージェントノードに直接変更を加えると、クラスターはサポートされなくなります。

追加情報:

- [AKS 運用者のベストプラクティス](https://docs.microsoft.com/azure/aks/operator-best-practices-scheduler)
- [Container insightsからの推奨メトリックアラート](https://docs.microsoft.com/azure/azure-monitor/containers/container-insights-metric-alerts)

## その他のツール

- Horizontal Pod Autoscaler (HPA)とCluster Autoscalerを使用して、ポッドとノードをオートスケールします。

  > ⚠️
  > AKSクラスターでは、ノードのオートスケールのみにCluster Autoscalerを使用します。VMSSのオートスケールを手動で有効にしたり、構成したりしないでください。



- スケールアウトできないワークロードの場合は、[Vertical Pod Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler) (VPA).を検討してください。`Off`アップデートモードを使用すると、VPAを使用して、ポッドのリソース制限を理解することもできます。
  
  > ⚠️
  > 本番環境でVPAを使用する場合は注意してください。Kubernetesの仕組みにより、`Auto`または`Recreate`アップデートモードでVPAを作成すると、リソース要求を変更する必要がある場合には、ポッドを削除します。これにより、ダウンタイムが発生する可能性があります。使用する前に、[制限事項](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler#known-limitations) を理解してください。

- [Kubecost](https://www.kubecost.com/)を使用して、コストとリソース使用パターンの洞察を得ることができます。
