# 2. Azure Networking の全体像と機能概要

## 2.1 Azure Network の全体像

クラウド(Azure)のネットワークはユーザーの目に触れる部分が少ないため、物理的な要素を忘れがちですが当然ながら物理的な回線やスイッチが存在します。Azure のネットワークを理解する上で、物理的なネットワークの構成を理解することは設計や運用時の考慮点として役立つことがあります。

### グローバル ネットワーク

Microsoft は全世界にクラウドを展開しており、大規模にサービスを展開できる設備を日々強化・運用しています。次のドキュメント内の画像には、Microsoft のネットワークのエッジやデータセンターが描かれています。

[マイクロソフトのグローバル ネットワーク](https://docs.microsoft.com/ja-jp/azure/networking/microsoft-global-network)

ご覧いただくと分かるように、Microsoft は独自のネットワーク回線や全世界に展開されている複数のデータセンターを所有しています。

それぞれのリージョンやデータセンターを高可用性・低遅延・セキュアな接続するために以下のようにいくつかのコンポーネントに分かれたアーキテクチャーが用いられています:

[ネットワーク トポロジとコンポーネント](https://docs.microsoft.com/ja-jp/azure/security/fundamentals/infrastructure-network#network-topology)

- 境界ネットワーク
  - Microsoft のバックボーンネットワークと、インターネットやサービスプロバイダーが提供する閉域網等の外部ネットワークを接続する
- ワイド エリア ネットワーク
  - リージョン間のネットワークを接続する
- リージョン ゲートウェイ
  - リージョン内のすべてのデータセンターを集約する
- データセンター ネットワーク
  - データセンター内のサーバー間を接続する

境界ネットワークでは、175 を超えるエッジ、4,000 を超えるインターネット ピアと接続し、インターネットや閉域網との接続による大容量のトラフィックの処理を行い、また数 Tbps に及ぶ DDoS 攻撃を防いでいます。リージョン ゲートウェイでは、リージョン内の数 100 Tbps に及ぶトラフィッを処理しています。データセンター内部では電源や冷却装置に障害が発生した際に影響を限定するためのセグメント化や、オープンソースのハードウェア、ネットワーク OS(SONiC)を用いたシンプルかつ堅牢なコンポーネントを採用しています。

このように、コンポーネントの階層化とそれぞれのコンポーネントの信頼性を向上することにより、堅牢で回復性の高いグローバルネットワークを実現しています。

**Tips**
> Microsoft のトラフィックは可能な限り Microsoft のバックボーンに留まるように設計されています。ユーザーに近いエッジから Microsoft のバックボーンにルーティングされ、データセンターやリージョン間、Virtual Machins や Microsoft 365、Xbox 等の Microsoft サービス間トラフィックは、パブリックインターネットを経由することはありません。

以下のドキュメントや動画は Azure のネットワークを理解する上で非常に役立ちますのでぜひご覧ください。

- 参考ドキュメント
  - [マイクロソフトのグローバル ネットワーク](https://docs.microsoft.com/ja-jp/azure/networking/microsoft-global-network)
  - [Azure ネットワーク アーキテクチャ](https://docs.microsoft.com/ja-jp/azure/security/fundamentals/infrastructure-network)
  - [Azure ネットワーク ラウンドトリップ待ち時間統計](https://docs.microsoft.com/ja-jp/azure/networking/azure-network-latency)
  - [Advancing global network reliability through intelligent software—part 1 of 2](https://azure.microsoft.com/ja-jp/blog/advancing-global-network-reliability-through-intelligent-software-part-1-of-2/)
  - [Advancing global network reliability through intelligent software—part 2 of 2](https://azure.microsoft.com/ja-jp/blog/advancing-global-network-reliability-through-intelligent-software-part-2-of-2/)
  - [Business as usual for Azure customers despite 2.4 Tbps DDoS attack](https://azure.microsoft.com/ja-jp/blog/business-as-usual-for-azure-customers-despite-24-tbps-ddos-attack/)
  - [Beyond the mega-data center: networking multi-data center regions (SIGCOMM 2020 Talk)](https://www.youtube.com/watch?v=FQ6_NxUNpEU&t=2s)

## 2.2 Azure Network に関するサービスやコンポーネント

これまで見てきた通り、Azure のネットワークは一口にネットワークと言っても広範囲に渡ります。従って、ネットワークに関するサービスや機能も非常に多く用意されています。まずはどのようなサービスがあるのか全体像を把握してみましょう。

Azure のネットワークは