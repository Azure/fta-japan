# 事業継続と災害復旧

## AKSのアップタイムSLA

- 課金して得られるアップタイムSLAは、Kubernetes APIサーバー用です。
  - アベイラビリティゾーンを使用するクラスター：**99.95％**
  - アベイラビリティゾーンを使用しないクラスター：**99.9％**
- クラスターが有料アップタイムSLAを選択しない場合のSLOは**99.5％**です。
- エージェントノードのSLAは、**Azureの仮想マシンSLA**によってカバーされます。
- **SLAは、SLAを満たさない場合にサービスクレジットを受け取ることを保証します。** もしアウトテージが発生した場合に、**影響のコスト**と**サービスクレジット**を評価し、BC/DR戦略を適切に計画します。

追加情報：

- [AKS Uptime SLA](https://docs.microsoft.com/azure/aks/uptime-sla)
- [SLA for AKS](https://azure.microsoft.com/support/legal/sla/kubernetes-service/v1_1/)

- [AKSのアップタイムSLA](https://docs.microsoft.com/ja-jp/azure/aks/uptime-sla)
- [AKSのSLA](https://azure.microsoft.com/ja-jp/support/legal/sla/kubernetes-service/v1_1/)

## BC/DRのベストプラクティス

- 課金して得られるアップタイムSLAは、本番環境のAKSクラスターに推奨されます。本番環境のAKSクラスターをアベイラビリティゾーンでデプロイします。

- AKSクラスターで実行するワークロードのSLAを定義します。AKSのSLAが要件を満たさない場合、または潜在的なアウトテージの影響が負担できない場合は、別のAKSクラスターを2番目のリージョンにデプロイすることを検討します。AKSがペアリングされたリージョンで利用可能な場合は、ペアリングされたリージョンが推奨されます。2番目のリージョンのクラスターは、プライマリリージョンのクラスターのホット、ウォーム、またはコールドスタンバイとして使用できます。
  - AKSプラットフォームの計画されたメンテナンスは、ペアリングされたリージョン間で少なくとも24時間の遅延を伴ってシリアル化されます。
  - 必要に応じてペアリングされたリージョンの回復作業が優先されます。

- リージョンの障害の場合にレジストリの耐障害性を実現するには、Azureコンテナレジストリでジオレプリケーションを有効にします。ジオレプリケーションを有効にすると、Azureコンテナレジストリは単一のレジストリとして機能し、複数のリージョンでマルチマスターリージョンレジストリを提供します。

- Infrastructure as Code（IaC）を使用してAKSクラスターをデプロイおよび構成します。IaCを使用すると、必要に応じてクラスターをすばやく再デプロイできます。
  - 任意の管理アクティビティ（つまり、パッチ、アップグレード、アイデンティティおよびアクセス管理）がセカンダリインスタンスに適用されていることを確認します
- CI/CDパイプラインを使用してアプリケーションをデプロイします。パイプラインに異なるリージョンのAKSクラスターを含めて、すべてのクラスターに最新のコードが同時にデプロイされるようにします。
  - [GitOps](https://docs.microsoft.com/azure/azure-arc/kubernetes/tutorial-use-gitops-flux2#for-azure-kubernetes-service-clusters)を検討して、プライマリおよびセカンダリクラスター間で一貫したデプロイを確実にします。

- できるだけAKSクラスターの外部で実行されるデータベースまたはその他のデータストアを使用して、アプリケーションの状態を外部化します。できるだけクラスター内にアプリケーションの状態を保存しないでください。
  
- クラスターに状態を保存する必要がある場合は、ストレージのバックアップ方法、複数のリージョンでデータを複製または移行する方法、RPO / RTOなど、状態のストレージの障害復旧戦略を考慮してください。
  - [ZRS](https://github.com/kubernetes-sigs/azuredisk-csi-driver/tree/master/deploy/example/topology#zrs-disk-support)ディスクを使用すると、ゾーンの障害を耐えられるボリュームを作成できます。マルチゾーンクラスターのステートフルワークロードは、ボリュームへの中断なしのアクセスを伴ってゾーン間で移動できます。

    > ⚠️ ZRSは現在、West Europe、North Europe、West US 2、およびFrance Centralリージョンでのみ利用できます。使用する前に、[制限事項](https://docs.microsoft.com/azure/virtual-machines/disks-redundancy#limitations)を確認してください。

  - [GlusterFS](https://docs.gluster.org/en/latest/)などの分散ストレージソリューション、または[Portworx](https://portworx.com/)などのKubernetes用のストレージソリューションを使用したインフラストラクチャベースの非同期ジオレプリケーションを構築します。
  - アプリケーションのバックアップとリストアおよびクラスターの永続ボリュームのバックアップとリストアには、[Velero](https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure) か [Kasten](https://www.kasten.io/)などのKubernetesバックアップツールを使用します。

    > 📘
    > Veleroを使用して、Azure Managed Diskに基づく永続ボリュームのアプリケーションと同様にバックアップできます。Azure Filesに基づく永続ボリュームには、[Velero with Restic](https://velero.io/docs/v1.6/restic/)を使用できます。ただし、使用する前にすべての制限事項を理解してください。代替手段としては、Azure Backupを使用してAzure Filesを別々にバックアップすることができます。

- AKSクラスターのDRプランを作成します。定期的に練習を行い、機能することを確認します。

追加情報：

- [AKSのビジネス継続性と災害復旧のベストプラクティス](https://docs.microsoft.com/azure/aks/operator-best-practices-multi-region)
