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

**Tips: Microsoft のバックボーンネットワークにルーティングされたトラフィックの経路**
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

これまで見てきた通り、Azure のネットワークは一口にネットワークと言っても、インターネットとの境界から仮想マシンが存在するラック内のネットワーク機器まで広範囲に渡ります。従って、ネットワークに関するサービスや機能も非常に多く用意されています。まずはどのようなサービスがあるのか全体像を俯瞰してみましょう。

![](./images/picture1.png)

こちらの図では Azure のネットワークに関するサービスを 6 つに分類してみました。

- Core
  - Azure 内部のネットワークを構成するための基本的なサービス群
- Hybrid
  - オンプレミスやほかのクラウドサービスと接続するためのサービス群
- Global
  - インターネットとの境界に位置するリージョンを持たないサービス群
- Security
  - ネットワークセキュリティに関わるサービス群
- Integration
  - 主に PaaS と Azure のユーザーネットワークを接続するために使用するサービス群
- Management
  - 監視やログ収集等ネットワークを管理するためのサービス群

それぞれの代表的な機能をいくつか紹介します。

### Core

Core カテゴリは主に IaaS 環境を構築する場合に使われるサービス群です。

#### Virtual Network(仮想ネットワーク)

Azure 上に仮想マシンを展開する場合、必ずユーザーが定義・作成するプライベートなネットワーク空間に所属する必要があります。そのネットワーク空間を表しているサービスが Virtual Network(仮想ネットワーク) です。

以下に仮想ネットワークの特徴を紹介します。

- 仮想ネットワークは、リージョンに展開する
  - 仮想マシンや関連するリソースの展開先と同じリージョンを指定する必要がある
- 仮想ネットワークは、作成時にアドレス空間を指定する
  - 推奨されるアドレス範囲は、10/8、172.16/12、192.168/16 の 3つのアドレス空間
  - ブロードキャストアドレスやマルチキャストアドレス等利用できないアドレス空間がある
  - DHCP や GRE 等使えないサービスがある
  - 予約されている IP アドレス(先頭の 3 アドレスとブロードキャストアドレス)が存在する
- 仮想ネットワークは、複数のアドレス空間、サブネットを持つことが可能
- 仮想ネットワークや仮想ネットワーク内のサブネットは、可用性ゾーンを意識することはない
  - 仮想ネットワークに展開される仮想マシンの可用性ゾーンに依存する
  - 可用性ゾーン間の通信には料金が発生する
- 同一仮想ネットワーク内のサブネット間は既定で通信が可能
  - DMZ の設置等あえてサブネット間の通信を拒否したい場合は NSG の設定が必要
- 複数の仮想ネットワーク間を接続できる
  - `ピアリング`や`仮想ネットワーク ゲートウェイ`、`ExpressRoute`を使用した接続が可能
  - `ピアリング`は送受信方向で料金が発生する
  - 上記方法で接続しない限り、仮想ネットワーク間での通信は出来ない
- Azure 既定の DNS サーバーが存在するため、DNS サーバーは必須ではない
  - Active Directory へのドメイン参加等要件に応じて独自の DNS サーバーを展開することも可能


また、仮想マシンを展開する場合、NIC(ネットワーク インターフェース)も必要なため、併せてその特徴を紹介します。

- 仮想マシンには複数の NIC を接続できる
- プライベート IP アドレスを固定できる
  - ただし可搬性を考慮し、OS の設定ではなく NIC の設定で固定する
- 1 つの NIC に複数の IP アドレスを割り当てることができる
- MAC アドレスは指定できないが VM が停止されても維持される
- NIC 単位で DNS サーバーの IP アドレスを指定できる

**Tips: 冗長目的で複数 NIC を設定する必要はあるか**
> オンプレミスのネットワークでは、上位のスイッチとともに冗長化や高速化を目的としてチーミングやボンディングを行うことがあります。また、影響を限定的にするためにサービス LAN と管理 LAN を分ける構成をすることもあります。Azure でも同様の構成はできますが、あくまでも NIC は仮想的なリソースであり、複数の NIC 付けたとしても冗長性を確保することにはなりません。また、ネットワークの帯域も数 Gbps ～数 10 Gpbs のスループットが出せることから、帯域の影響を理由として サービス LANと管理 LAN を分ける必要性もないと考えられます。

#### Network Security Group

Network Security Group(NSG)を使うと、L4 のファイアウォールを設定できます。

#### Load Balancer

#### Public IP
