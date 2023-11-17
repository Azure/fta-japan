Azure Networking #1 - アプリケーション配信基盤の設計・展開 # **[prev](./why.md)** | **[home](./appdelivery/README.md)**  | **[next](./appdelivery/application-delivery.md)**
<!--Azure Networking #1 - Azure ネットワークの基礎とハイブリッドネットワークの設計・展開 # **[prev](./why.md)** | **[home](./core/README.md)**  | **[next](./core/hybrid-network.md)**-->


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

|:question: Tips: Microsoft のバックボーンネットワークにルーティングされたトラフィックの経路|
|:-----------------------------------------|
|Microsoft のトラフィックは可能な限り Microsoft のバックボーンにとどまるように設計されています。ユーザーに近いエッジから Microsoft のバックボーンにルーティングされ、データセンターやリージョン間、Virtual Machins や Microsoft 365、Xbox 等の Microsoft サービス間トラフィックは、パブリックインターネットを経由することはありません。|

以下のドキュメントや動画は Azure のネットワークを理解する上で非常に役立ちますのでぜひご覧ください。

- 参考ドキュメント
  - [マイクロソフトのグローバル ネットワーク](https://docs.microsoft.com/ja-jp/azure/networking/microsoft-global-network)
  - [Azure ネットワーク アーキテクチャ](https://docs.microsoft.com/ja-jp/azure/security/fundamentals/infrastructure-network)
  - [Azure ネットワーク ラウンドトリップ待ち時間統計](https://docs.microsoft.com/ja-jp/azure/networking/azure-network-latency)
  - [Advancing global network reliability through intelligent software—part 1 of 2](https://azure.microsoft.com/ja-jp/blog/advancing-global-network-reliability-through-intelligent-software-part-1-of-2/)
  - [Advancing global network reliability through intelligent software—part 2 of 2](https://azure.microsoft.com/ja-jp/blog/advancing-global-network-reliability-through-intelligent-software-part-2-of-2/)
  - [Business as usual for Azure customers despite 2.4 Tbps DDoS attack](https://azure.microsoft.com/ja-jp/blog/business-as-usual-for-azure-customers-despite-24-tbps-ddos-attack/)
  - [Beyond the mega-data center: networking multi-data center regions (SIGCOMM 2020 Talk)](https://www.youtube.com/watch?v=FQ6_NxUNpEU&t=2s)

上記で説明してきたように、Azure のネットワークは非常に大規模であり、高度に抽象化・自動化され可用性が高いサービスとなっています。従ってオンプレミス環境では考慮が必要だったルーターの冗長化や VLAN 等によるネットワークの分離、個別のハードウェアの障害復旧などは、Azure を利用する上で考慮する必要はありません。一方で、ルーティングのしくみやファイアウォール等オンプレミスでも検討していたポイントを Azure のネットワークでも検討しなければならないこともあります。Azure のネットワークを理解するには、どの部分がどのように抽象化され、それがどのようなサービスで提供されているかを意識すると良いでしょう。

## 2.2 Azure Network に関するサービスやコンポーネント

これまで見てきた通り、Azure のネットワークは一口にネットワークと言っても、インターネットとの境界から仮想マシンが存在するラック内のネットワーク機器まで広範囲に渡ります。従って、ネットワークに関するサービスや機能も非常に多く用意されています。まずはどのようなサービスがあるのか全体像を俯瞰してみましょう。

![Azure Network overview](./images/picture1.png)

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

それぞれのサービスがどのような機能を持っているかざっくり理解いただくために代表的な機能をいくつか紹介します。

### 2.2.1 Core

Core カテゴリは主に IaaS 環境を構築する場合に使われるサービス群です。Azure のネットワークの最も基本的な機能を提供します。

#### Virtual Network(仮想ネットワーク)

<details>
  <summary>解説を開く</summary>

Azure 上に仮想マシンを展開する場合、必ずユーザーが定義・作成するプライベートなネットワーク空間に所属する必要があります。そのネットワーク空間を表しているサービスが Virtual Network(仮想ネットワーク) です。

仮想ネットワークは境界として扱うことができます。つまり、仮想ネットワークを分割することでネットワーク的な接続性を遮断できるため、セキュリティ要件やアドレス空間の要件に応じて複数の仮想ネットワークを展開できます。

仮想ネットワークの展開は論理的なリソースであり、課金の発生するようなリソースが展開されることはありません。

以下に仮想ネットワークの特徴を紹介します。

- 仮想ネットワークは、特定のリージョンに展開する
  - 仮想マシンや関連するリソースの展開先と同じリージョンを指定する必要がある
- 仮想ネットワークに課金は発生しない
- 仮想ネットワークは、作成時にアドレス空間を指定する
  - 推奨されるアドレス範囲は、10/8、172.16/12、192.168/16 の 3つのアドレス空間
  - ブロードキャストアドレスやマルチキャストアドレス等利用できないアドレス空間がある
  - DHCP や GRE 等使えないサービスがある
  - 予約されている IP アドレス(先頭の 3 アドレスとブロードキャストアドレス)が存在する
- 仮想ネットワークは、複数のアドレス空間、サブネットを持つことができる
- 仮想ネットワークや仮想ネットワーク内のサブネットは、可用性ゾーンを意識することはない
  - 仮想ネットワークに展開される仮想マシンの可用性ゾーンに依存する
  - 可用性ゾーン間の通信には料金が発生する
- 同一仮想ネットワーク内のサブネット間は既定で通信ができる
  - DMZ の設置等あえてサブネット間の通信を拒否したい場合は NSG の設定が必要
- 複数の仮想ネットワーク間を接続できる
  - `ピアリング`や`仮想ネットワーク ゲートウェイ`、`ExpressRoute`を使用した接続が可能
  - `ピアリング`は送受信方向で料金が発生する
  - 上記方法で接続しない限り、仮想ネットワーク間での通信はできない=仮想ネットワークの単位でネットワーク境界ができる
  - `ピアリング`は非推移的なため、すべての仮想ネットワーク間の接続をする場合はフルメッシュでの接続が必要
- Azure 既定の DNS サーバーが存在するため、DNS サーバーは必須でない
  - 既定の DNS サーバーの IP アドレスは`168.63.129.16`
  - Active Directory へのドメイン参加等要件に応じて独自の DNS サーバーを展開することも可能

![VNet](images/vnet.png)

また、仮想マシンを展開する場合、NIC(ネットワーク インターフェース)も必要なため、併せてその特徴を紹介します。

- Azure ネットワークの DHCP のしくみにより自動的にプライベート IP アドレスが割り当てられる
- プライベート IP アドレスを固定できる
  - ただし可搬性を考慮し、OS の設定ではなく NIC の設定で固定することが推奨
- 仮想マシンには複数の NIC を接続できる
- 1 つの NIC に複数の IP アドレスを割り当てることができる
- MAC アドレスは指定できないが VM が停止されても維持される
- NIC 単位で DNS サーバーの IP アドレスを指定できる

|:question: Tips: 冗長目的で複数 NIC を設定する必要はあるか|
|:-----------------------------------------|
|オンプレミスのネットワークでは、上位のスイッチとともに冗長化や高速化を目的としてチーミングやボンディングを行うことがあります。また、影響を限定的にするためにサービス LAN と管理 LAN を分ける構成をすることもあります。Azure でも同様の構成はできますが、あくまでも NIC は仮想的なリソースであり、複数の NIC 付けたとしても冗長性を確保することにはなりません。また、ネットワークの帯域も数 Gbps ～数 10 Gpbs のスループットが出せることから、帯域の影響を理由として サービス LANと管理 LAN を分ける必要性もないと考えられます。|

</details>

#### Network Security Group

<details>
  <summary>解説を開く</summary>

Network Security Group(NSG)を使うと、L4 のファイアウォールを設定できます。DMZ の設定やインターネットからの受信トラフィックの制御などに使用できます。NSG は Azure の仮想ネットワークでフィルタリングをするための最も基礎的なリソースです。FQDN によるフィルターや IDS/IPS 機能はありませんがシンプルなサービスのため、Azure のさまざまなサービスと組み合わせて使用できます。

以下に NSG の特徴を紹介します。

- NSG は特定のリージョンに展開する
  - 仮想ネットワークや NIC に割り当てるには同じリージョンに展開する必要がある
- IP アドレスベースでのフィルタリングができる
- 送信元先の IP アドレス、送信元先のポート番号、プロトコル、許可・拒否設定、優先度設定ができる
- NSG の割り当て先として、NIC もしくはサブネットを指定できる
  - NIC と サブネットの両方に割り当てられる
  - 仮想マシンからの送信時は NIC -> サブネットの順番で評価され、受信時はサブネット -> NIC の順番で評価される
- `サービス タグ`を使用し、あらかじめ定義された IP アドレスのグループを指定できる
  - 例) IP アドレスが特定されていない Windows Update へのアウトバウンド通信をサービスタグで許可することが可能
- Windows のラインセスサーバーへの通信は NSG によって拒否されることはない

![NSG](images/network-security-group-interaction.png)

</details>


#### Public IP Address

<details>
  <summary>解説を開く</summary>

Azure のさまざまなリソースに対してインターネットからアクセスする際に必要なサービスです。仮想マシンの NIC に対する関連付けや、Azure Firewall・Application Gateway 等のフロントエンドへの利用ができます。PaaS 等 Azure によって管理されるサービスでは、Public IP Address がなくても既定でインターネットからアクセスできるサービスもあります。

以下に Public IP Address の特徴を紹介します。

- Public IP Address は特定のリージョンに展開する
- Standard と Basic がある
- ゾーン冗長に対応しており、ゾーン冗長は Standard のみ利用できる
- DNS ラベルをつけることができる
- ゾーン冗長ではない Public IP Address をゾーン冗長の Application Gateway や仮想マシン等のサービスに関連付けることはできない

|:question: Tips: 仮想マシンからインターネットへ送信接続(アウトバウンド)する方法|
|:------------------------------------------|
|Azure の仮想マシンがインターネットへアクセスする方法はさまざまあり、要件に応じて適切な方法を選択する必要があります。インターネットへアクセスするには、仮想マシンが持つ プライベート IP アドレスをインターネット空間で通信できるグローバル IP アドレスに変換する必要があり、これを `SNAT` と呼びます。Azure では `SNAT` する方法にいくつか種類があり、適切な選択をしない場合、意図しない送信接続やパフォーマンスに影響することがあります。また、外部の API 呼び出し等で送信元 IP アドレスを制限する場合に IP アドレスを固定的にしたい場合にも考慮が必要です。仮想マシンがインターネットへアクセスするパターン(`SNAT`の方法)を見てみましょう。|

1. Public IP Address  
   仮想マシン(NIC)に Public IP Address を関連付けることで、その Public IP Address リソースの IP アドレスをソース(送信元)として SNAT します。1 つの Public IP Address が 1 つの仮想マシンに紐づくため、構成としては分かりやすい構成です。ただし、複数の仮想マシンを展開する場合、個別に管理が必要になるため運用が難しくなります。割り当てられる最大のポート数は 64,000 ポートです。
1. 外部 ロード バランサー  
   本来負荷分散のために用いられるロード バランサーの機能を用いて送信接続します。ロード バランサーのバックエンドプールにある仮想マシンからインターネットへ送信方向に接続が発生した場合、ロード バランサーに設定した送信規則に従って`SNAT`されます。バックエンドプールの仮想マシンの台数によって静的にポートの割り当てが行われるため、ある程度の送信接続数が予測できる場合に使用できます。
1. NAT Gateway  
   `SNAT`を行うことを目的としたサービスです。サブネットにリンクすることで、そのサブネットに所属するすべての仮想マシンからの送信方向を`SNAT`します。動的にポートを確保するためスケーラビリティが高い方法です。1 つの NAT Gateway に 16 個の Public IP Address が設定でき、1 つの Public IP Address ごとに 64,000 ポートが利用できるため、最大 16 * 64,000 = 1,0240,000 ポートが利用できます。
1. Azure Firewall 等の NVA  
   Azure Firewall 等の NVA によって`SNAT`する方法です。その仕様動作は NVA によって異なります。NVA であっても Public IP Address やロード バランサーの制約を受けることになります。Azure Firewall の場合、Public IP Address ごとに 2496 ポートが利用できます。
1. 既定の送信アクセス
   Public IP Address やロード バランサー等のバックエンドにない仮想マシンの場合であってもインターネットへの接続が可能です。これは、Azure によって管理される Public IP Address によって送信接続が自動的に設定されるためです。従って、送信元の IP アドレスはランダムとなり、ポートも最大 1024 ポートまでと限定的な性能が提供されます。

![NAT](images/flow-direction4.png)

|:exclamation: 既定の送信アクセスの廃止|
|:------------------------------------------|
|2023 年 9 月に既定の送信アクセスの提供終了がアナウンスされました([link](https://azure.microsoft.com/en-us/updates/default-outbound-access-for-vms-in-azure-will-be-retired-updates-and-more-information/))。このアナウンスでは、2025 年 9 月 30 日に既定の送信アクセスの提供がリタイアすることが述べられています。この影響により、仮想マシンがインターネット接続を行う場合、先に挙げた`既定の送信アクセス`以外の方法で送信接続する方法をユーザーが実装する必要があります。[サポートチームのブログ](https://jpaztech.github.io/blog/network/default-outbound-access-for-vms-will-be-retired/) もご確認ください。|


どの方法が最も適しているかは、要件によって異なるため一概にお勧めをお伝えすることはできません。さまざまな送信接続の方法があるということを理解したうえで適切な方法を検討してください。

- 参考: [送信接続での送信元ネットワーク アドレス変換 (SNAT)を使用する](https://docs.microsoft.com/ja-jp/azure/load-balancer/load-balancer-outbound-connections)
- 参考: [NAT ゲートウェイを使用して仮想ネットワークを設計する](https://docs.microsoft.com/ja-jp/azure/virtual-network/nat-gateway/nat-gateway-resource)
- 参考: [Azure NAT ゲートウェイの Azure Well-Architected Framework のレビュー](https://docs.microsoft.com/ja-jp/azure/architecture/networking/guide/well-architected-network-address-translation-gateway)

</details>

#### Load Balancer

<details>
  <summary>解説を開く</summary>

いわゆる L4 のロードバランサーです。バックエンドのサーバーに冗長を目的として負荷分散をするために用いられるサービスです。Web サービスや SQL Server などのサービスを負荷分散する場合に利用します。L4 のロードバランサーのため、Cookie を使ったセッションアフィニティや TLS のオフロード、WAF の機能はありません。そのような機能が必要な場合は、L7 のロードバランサーである、Application Gateway 等を使う必要があります。

Azure の Load Balancer を理解する上で重要なことは、Load Balancer は**仮想マシン(OS)によるインスタンスで実現されているわけではない** ということです。Azure の Load Balancer は `MUX` と呼ばれる小さなネットワークのコンポーネントと、仮想マシンホスト上に展開される `Host Agent` によって実現されています。このようなしくみからロードバランサーとして状態を持つことはせず、それによりたとえば、バックエンドのサーバーの負荷やラウンドロビンで振り分け先を分散する機能はありません。また、ロードバランサーにアクセスしたログを確認できるようなしくみもありません。トラフィックを負荷分散する方法として、後に紹介する Application Gateway 等ほかの方法もあるため、機能・非機能の要件に応じてどの負荷分散のしくみを利用するかを検討する必要があります。

Azure の Load Balancer に関する詳細な技術情報は論文で公開されているため詳しく知りたい方は以下の参考情報をご参照ください。

- [論文: Ananta: Cloud Scale Load Balancing](http://conferences.sigcomm.org/sigcomm/2013/papers/sigcomm/p207.pdf)
- [発表資料: Ananta: Cloud Scale Load Balancing](https://view.officeapps.live.com/op/view.aspx?src=http%3A%2F%2Fconferences.sigcomm.org%2Fsigcomm%2F2013%2Fslides%2Fsigcomm%2F19.pptx&wdOrigin=BROWSELINK)

以下に Load Balancer の特徴を紹介します。

- Load Balancer は特定のリージョンに展開する
- 外部ロード バランサーと内部ロード バランサーがある
  - フロントエンドに Public IP Address を関連付け、外部(インターネット)との通信を可能とする外部 Load Balancer を展開できる
  - フロントエンドに仮想ネットワークのプライベート IP アドレスを使用し、内部通信を可能とする内部 Load Balancer を展開できる
- Standard と Basic の 2 つの SKU がある
  - Basic のロード バランサーは、2025 年 9 月 30 日にリタイアする
  - 99.99 % の SLA が定義されている SKU は Standard のみ
  - バックエンドに IP アドレスを指定できるのは Standard のみ
  - メトリックを取得できるのは Standard のみ
  - そのほかの比較は [こちら](https://docs.microsoft.com/ja-jp/azure/load-balancer/skus#skus) のドキュメントを参照
- 特定のゾーンへの展開(ピン留め)か、ゾーンをまたがった展開(ゾーン冗長)ができる
  - ゾーンは Standard のみで構成可能
- ウォームアップやインスタンスの数のような考え方がない
- 負荷分散はクライアントの送信元 IP アドレス、送信元ポート番号、宛先の IP アドレス、宛先ポート番号、プロトコルのハッシュで行われる
  - ハッシュのもととなるデータとして、送信元 IP アドレスとポート番号の 2 タプルにする等変更できる
  - FTP のように 1 つのサービスで関連する複数のコネクションが発生する場合は、同じバックエンドサーバーに振り分ける必要があるため、この構成を変更する必要がある
- Load Balancer からのプローブは `168.63.129.16` から行われる
  - この IP アドレスをブロックすると Load Balancer は正常に機能しなくなる
- インバウンド NAT 規則を構成すると DNAT ができる
  - Load Balancer のフロントエンドの IP アドレスとバックエンドサーバーを紐づけられる
- 送信規則を構成すると SNAT のルールを構成でき、外部へのアウトバウンドを行える
- Cross-region Load Balancer を用いるとリージョンをまたいだ L4 の負荷分散ができる

</details>

#### Application Gateway

<details>
  <summary>解説を開く</summary>

いわゆる L7 のロードバランサーです。HTTP/HTTPS 通信をバックエンドの Web サーバーに負荷分散をするために用いられるサービスです。Application Gateway は仮想マシンベースのリソースであり、課金や監視の考え方にも関係する部分があります。

以下に Application Gateway の特徴を紹介します。

- Application Gateway は特定のリージョンに展開する
- ゾーン冗長ができる
- Application Gateway v1(IIS ベース) と v2(nginx ベース) がある
  - v1 ベースの Application Gateway は 2026 年 4 月 28 日にリタイアする
  - 基本的に v2 を選択する(以下断りがない場合 v2 の特徴とする)
- Application Gateway は仮想ネットワークに展開する
  - `/24` のアドレス空間のサブネットが推奨
- SSL オフロードが使用できる
- インスタンスの自動スケールができる
- Web アプリケーション ファイアウォール機能がある
  - OWASP のルールにもとづいたポリシーの設定が可能
- URL ベースのルーティング、複数サイトのホスティングができる
- Cookie ベースのセッション アフィニティ機能が利用できる
- 接続のドレインができる
- HTTP ヘッダー、 URL の書き換えができる

Application Gateway を含め、HTTP トラフィックを扱う多くの場合、アプリケーションとの連携を考える必要があります。特に運用フェーズを考慮すると、問題が発生した際のログの取得や監視の方法を十分理解しておくことが必要です。ログの設定等は設計フェーズで検討しておく必要があります。

以下に Application Gateway の運用フェーズで気にしておくいくつかのポイントを挙げます。

- ログの保存
  - Application Gateway はほかの PaaS リソース同様、診断設定で Log Analytics にログを保存しておくことを検討します。バックエンドのアプリケーションやサーバーのメンテナンス、不具合また Application Gateway 自体のメンテナンスや障害において、セッションが切断されることがあります。その際にどのコンポーネントがどのリクエストを処理したかを追跡できるようしておきます
  - Application Gateway で処理されるすべてのリクエストには GUID が付与され、診断ログの `transactionId` として確認ができます。また、この値は `x-appgw-trace-id` ヘッダーとして追加されるため、Web サーバーやアプリケーションでも確認できます
  - 参考: [アプリケーション ゲートウェイの動作](https://docs.microsoft.com/ja-jp/azure/application-gateway/how-application-gateway-works#modifications-to-the-request)
- メトリック
  - Application Gateway(L7 ロードバランサー) のしくみ上、HTTP のコネクションに関わるメトリックを確認することが重要です。たとえば、Application Gateway では、バックエンドサーバーとの 3-way ハンドシェイクにかかった時間や、バックエンドサーバーとのリクエスト・レスポンスにかかった合計時間等を取得できます。
  - メトリックは特に設定なく確認ができます。
  - 参考: [Application Gateway のメトリック](https://docs.microsoft.com/ja-jp/azure/application-gateway/application-gateway-metrics)
- 設定変更時のコネクションの切断
  - Application Gateway に対する設定変更では、TCP のコネクションが切断が確認されています。設定変更には、新規の設定追加や証明書の更新が含まれます。従って設定変更ができるようにメンテナンス期間を設けておく必要があります
  - 参考: [Application Gateway 設定変更の影響](https://jpaztech.github.io/blog/network/appgw-configchange/)

</details>

### 2.2.2 Hybrid

#### ハイブリッドネットワーク接続(オンプレミスとのネットワーク接続)

ハイブリッドに関する各サービスの紹介の前にオンプレミスとのネットワーク接続のパターンをいくつか紹介します。

![Hybrid network](images/connect-onprem.png)

Azure と Azure 外のネットワークを接続する方法としては、主にインターネットを介す方法と閉域網を利用する方法があります。インターネットを介す方法はいわゆる VPN を使用して、Azure のゲートウェイと接続します。一方で閉域網を利用する方法は、サービスプロバイダーが提供するネットワークを使用し、インターネットを介さない方法です。

一般的にインターネットは不安定な回線であり、セキュリティやレイテンシーの観点で特にエンタープライズの環境では避けられるケースが多い接続方式です。一方で閉域網を使用する方法は、ユーザーとサービスプロバイダー、またサービスプロバイダーと Microsoft のデータセンターの距離が近く、プロバイダーによって管理されているネットワークです。そのため、インターネットに比べ高品質なネットワークが提供されており、エンタープライズではよく使われている接続方式です。

当然ながら閉域網の方がネットワーク品質のメリットはあるもののサービスプロバイダーとの契約が必要となり、インターネットを介す方法に比べて高価になります。ネットワークの要件によってどちらを選択すべきか検討する必要があります。

#### VPN Gateway

<details>
  <summary>解説を開く</summary>

Azure のネットワークとオンプレミスを含めた Azure 外のネットワークを接続するために必要なリソースが VPN Gateway です。VPN Gateway は、主に 2 つの回線を接続する機能があります。
1 つ目はインターネット回線を介した VPN、2 つ目はサービス プロバイダーが提供する ExpressRoute 回線です。また、VPN にも接続方式の種類があり、ネットワーク機器と接続しネットワーク全体を接続する Site-to-Site と、特定の端末と接続する Point-to-Site があります。

いずれの方法でも、VPN Gateway を展開して接続します(ExpressRoute のみを使う場合でも必要なリソースです)。

以下に VPN Gateway の特徴を紹介します。

- VPN Gateway は特定のリージョンに展開する
- VPN 接続と ExpressRoute 接続でそれぞれ別のゲートウェイを展開する
  - VPN Gateway の作成時にゲートウェイの種類(VPN もしくは ExpressRoute)を選択
- `GatewaySubnet` という名前の専用のサブネットに展開する
  - サブネットのサイズは、`/27` 以上のアドレス空間を推奨
- スループットや機能に応じて適切な SKU を選択する
  - VPN 接続と ExpressRoute 接続で SKU が異なる
  - Basic SKU は本番環境では非推奨
  - 参考: [VPN のゲートウェイの SKU](https://docs.microsoft.com/ja-jp/azure/vpn-gateway/vpn-gateway-about-vpn-gateway-settings#gwsku)
  - 参考: [ExpressRoute のゲートウェイの SKU](https://docs.microsoft.com/ja-jp/azure/expressroute/expressroute-about-virtual-network-gateways#gwsku)
- VPN 接続の可用性を高めるためにアクティブ/アクティブ接続を採用する
  - 参考: [高可用性のクロスプレミス接続および VNet 間接続](https://docs.microsoft.com/ja-jp/azure/vpn-gateway/vpn-gateway-highlyavailable)
- オンプレミスの接続デバイスは十分に検証する
  - 検証済みデバイスの使用を前提とする
  - 参考: [検証済みの VPN デバイスとデバイス構成ガイド](https://docs.microsoft.com/ja-jp/azure/vpn-gateway/vpn-gateway-about-vpn-devices#devicetable)

上記で紹介した内容はごく一部の特徴・機能です。VPN Gateway を使用したオンプレミスとの接続には、オンプレミスのネットワーク構成や使用しているデバイス、Azure へ接続するネットワークの要件、可用性の要件等さまざまな要素があります。実際に設計・構築する際は要件に応じて使用する機能や設定があるため、ドキュメントを十分に確認し理解したうえで利用しましょう。

|:question: Tips: 仮想ネットワーク間の接続は ピアリングか VPN Gateway か|
|:------------------------------------------|
|Azure の仮想ネットワーク間の接続の方法として、VPN Gateway を使用することもできます。つまり、双方の仮想ネットワークに VPN Gateway を展開し、IP Sec で接続をする方法です。また、別の方法として仮想ネットワークのピアリングがあります。ピアリングは VPN Gateway の展開は不要です。仮想ネットワーク間の接続でどちらの方法が良いか議論になることがありますが、現在ではまず始めにピアリングを検討してください。理由として、VPN Gateway の方法ではゲートウェイのリソースを展開する必要があり、ゲートウェイリソースを介さないことによりゲートウェイの制限(帯域幅等)にしばられること、パブリック IP アドレスが必要になること、セットアップに時間がかかること、専用のサブネットが必要になること等が挙げられます。ただし、ピアリングで実現できないこととして、BGP によるネットワークの推移性があります。これによりピアリングのようにフルメッシュの構成にしなくても複数の仮想ネットワークを接続でき、管理が容易になるというメリットがあります。要件に応じて適切な接続方法をご検討ください。<br>参考: [仮想ネットワーク ピアリングと VPN ゲートウェイのいずれかを選択](https://docs.microsoft.com/ja-jp/azure/architecture/reference-architectures/hybrid-networking/vnet-peering)|

</details>

#### ExpressRoute

<details>
  <summary>解説を開く</summary>

ExpressRoute はサービスプロバイダーの回線を閉域網として使用するサービスです。ExpressRoute を使用するにはまずはサービスプロバイダーとの契約が必要です。以下のドキュメントにサービスプロバイダーの一覧が記載されています。

- [ExpressRoute 接続パートナーとピアリングの場所](https://docs.microsoft.com/ja-jp/azure/expressroute/expressroute-locations)

![ER](images/expressroute-basic.png)

以下に ExpressRoute の特徴を紹介します。

- BGP によりルーティングを制御する
  - オンプレミスのネットワーク機器に BGP を扱える機器が必要
- ExpressRoute には Microsoft ピアリングと プライベート ピアリングの2種類がある
  - プライベート ピアリングは、ユーザーの仮想ネットワークへ閉域接続するために使用
  - Microsoft ピアリングは、Azure の PaaS リソース(グローバル IP アドレスを持つサービス)へ閉域接続するために使用
  - 参考: [ExpressRoute 回線とピアリング](https://docs.microsoft.com/ja-jp/azure/expressroute/expressroute-circuit-peerings)
- サービスプロバイダーのサービス提供形態として L3 プロバイダーと L2 プロバイダーがある
  - L2 プロバイダーは回線を提供。BGP の設定やルーター運用はユーザーが実施
  - L3 プロバイダーは回線のみでなく BGP の設定やルーター運用を含めプロバイダーがサービスを提供
- Premium アドオン を利用するとほかのリージョンのゲートウェイに接続できる
  - たとえば、東京にある回線を海外リージョンの接続ポイントに接続する場合は Premium アドオンが必要
  - 接続先が同一地理的リージョン(e.g. 東京に展開された回線を西日本リージョンに接続する)場合においては、Premium アドオンは不要
- ほかのテナント・ほかのサブスクリプションにある ExpressRoute 回線とゲートウェイを接続できる
  - 1 つの回線を使いまわすことでネットワーク制御の統一化・コストを削減
- 回線接続には制限がある
  - 参考: [ExpressRoute の FAQ](https://docs.microsoft.com/ja-jp/azure/expressroute/expressroute-faqs#can-i-link-to-more-than-one-virtual-network-to-an-expressroute-circuit)

ExpressRoute を理解するコツは、サービスプロバイダーの存在、BGP によるルーティングの制御、オンプレミスネットワークの構成を把握することです。

サービスプロバイダーは、各プロバイダーによってサービス内容や管理方法が異なるため、要件に合った機能が利用できるか確認します。また、VPN 接続にはないプロバイダーの設備や Microsoft Enterprise Edge(MSEE) が存在するため、監視やトラブルシューティング時に意識する必要があります。

BGP によるルーティングの制御は、特にサービスプロバイダーとして L2 プロバイダーを採用する際に考慮が必要です。つまり、BGP の設定やルーターの運用をユーザー自身が行うこととなるため十分に知識のあるネットワークエンジニアの支援が必要です。同様に、オンプレミスネットワークの設計ポリシーや構成を把握しておく必要があります。複数の拠点間接続や冗長性を考慮した構成になっている等構成が複雑な場合、ExpressRoute の接続による影響を十分考慮しておく必要があります。

![ER topology](images/er-topology.png)

</details>

#### Virtual WAN

<details>
  <summary>解説を開く</summary>

Virtual WAN は、Azure のさまざまなネットワークサービスを接続して、Azure のネットワークを WAN のように利用できることをコンセプトとしたサービスです。複数の仮想ネットワークや ExpressRoute、VPN を Virtual WAN のハブに接続し、さらに Virtual WAN どうしを接続することによって、相互に接続を可能とします。

仮想ネットワーク ゲートウェイやピアリング、ルート サーバー、Azure Firewall 等のサービスを組み合わせて Virtual WAN とおおむね同様の構成を展開できますが、個別の機能を管理する手間がかかります。Virtual WAN を用いることで、ネットワークの展開や管理工数を抑えながら、Azure の有する強力なネットワークを活用できる点がメリットです。

</details>

### 2.2.3 Global

#### Front Door

<details>
  <summary>解説を開く</summary>

Front Door はレイヤー 7 で HTTP/HTTPS を処理するグローバルサービスです。HTTP/HTTPS 通信をバックエンドのサービスへ負荷分散するために用いられるサービスです。リージョンを持たないため、災害対策としてリージョン間の冗長化や負荷分散で利用できます。Front Door は Azure ネットワークのエッジで動作するサービスであり、エニーキャストのしくみでアクセス元のネットワークに最も近い Azure データセンターへ接続されます。

また、新しい Front Door は、従来の Microsoft の Azure CDN と クラシックの Front Door を統合したサービスであり、従来の CDN の代替サービスとしても利用できます。

![](https://docs.microsoft.com/ja-jp/azure/frontdoor/media/tier-comparison/architecture.png)

以下に Front Door の特徴を紹介します。

- Front Door は特定のリージョンを持たない
  - 展開されるリソース グループのリージョンにメタデータを持つ
- 3 つの SKU がある
  - Standard / Premium / クラシック
  - 参考: [レベル間の機能の比較](https://docs.microsoft.com/ja-jp/azure/frontdoor/standard-premium/tier-comparison#feature-comparison-between-tiers)
- WAF 機能がある(Premium/クラシック)
- SSL オフロードが利用できる
- URL ベースのルーティング、複数サイトのホスティングができる
- Cookie ベースのセッション アフィニティ機能が利用できる
- HTTP ヘッダー、 URL の書き換えができる
- プライベート リンクが利用できる(Premium)
- キャッシュ機能を利用できる
- bot 保護機能を利用できる

|:question: Tips: 特定の Front Door からのアクセスのみにロックダウンする|
|:------------------------------------------|
|Front Door はグローバルリソースであることから Front Door の IP アドレスは全ユーザーで共通です。`AzureFrontDoor.Backend` サービス タグで Front Door からのアクセス元を限定したうえで、ヘッダーに含まれる `X-Azure-FDID` で Front Door の ID を指定する必要があります。<br>参考: [バックエンドへのアクセスを Azure Front Door のみにロックダウンするにはどうしたらよいですか?](https://docs.microsoft.com/ja-jp/azure/frontdoor/front-door-faq#--------------azure-front-door-------------------------)|

</details>

#### Traffic Manager

<details>
  <summary>解説を開く</summary>

Traffic Manager は DNS ベースの負荷分散サービスです。DNS ベースであるため、HTTP 以外のプロトコルであってもエンドポイントに対する負荷分散が可能です。ただし、インターネット上から名前解決やエンドポイントに対するアクセス可能なサービスが対象であり、仮想ネットワーク内部のリソースへの負荷分散には別のサービスを利用する必要があります。

またよくある誤解ですが、**クライアントからの通信を Traffic Manager が処理することはありません**。Traffic Manager はあくまでもクライアントからの通信開始時の名前解決において負荷分散をすることを目的としており、クライアントとエンドポイントは直接通信します。従ってエンドポイント側でのフィルターや、パフォーマンス/地理的なルーティングを使用する場合にクライアントの位置(名前解決の実行元)を意識しておく必要があります。

![](./images/trafficmanager-access.png)

以下に Traffic Manager の特徴を紹介します。

- Traffic Manager は特定のリージョンを持たない
- 負荷分散には複数の方法がある
  - パフォーマンス
  - 重み付け
  - 優先度
  - 地域
  - 複数値
  - サブネット
- エンドポイントとして以下が指定可能
  - Azure のサービス
  - 外部エンドポイント
  - Traffic Manager
- Real User Measurements が利用できる
  - Web サイトに JavaScript を埋め込むことでエンドユーザーの位置に応じたトラフィックルーティングが行われる
- フェールオーバーにかかる時間は以下の設定によって変化する
  - プローブ間隔
    - 通常のプローブ間隔: 30 秒
    - 高速プローブ間隔: 10 秒
  - 許容されるエラー数
  - タイムアウト値
  - DNS の TTL

以下はフェールオーバー時の動作を表した図です。
![](./images/trafficmanager.png)

</details>

### 2.2.4 Security

Azure のネットワークをセキュアにするために Azure ではさまざまなサービスが提供されています。セキュリティはネットワークだけでなくサービスごとの機能や認証にも関係してきますが、ここではネットワークの構成に特に関係するサービスを取り上げます。

#### Azure Firewall

<details>
  <summary>解説を開く</summary>

Azure Firewall は IDP/IDS を備えた L7 のファイアウォールサービスです。L7 によるフィルタリングによって FQDN・URL フィルタリングや Web カテゴリフィルタリングが可能です。また、HTTP/HTTPS (Web トラフィック) 以外のトラフィックのフィルタリングも対応しています。

Azure Firewall はいわゆる透過プロキシとして動作します。Azure Firewall を利用するには UDR 等を利用し、Azure Firewall へトラフィックをルーティングします。

![AzFW](images/azfw.png)

以下に Azure Firewall の特徴を紹介します。

- Azure Firewall は仮想ネットワークのサブネットに展開する
  - `AzureFirewallSubnet` という名前の専用のサブネットに展開
  - アドレス空間は `/26` を確保
- 可用性ゾーンに展開できる
- Basic と Standard、 Premium の SKU がある
  - Premium は IDP/IDS 機能や TLS インスペクション機能がある
  - それぞれのフィルタリング機能の詳細については以下ドキュメントを参照
  - 参考: [Azure Firewall Basic の機能](https://learn.microsoft.com/ja-jp/azure/firewall/basic-features)
  - 参考: [Azure Firewall Standard の機能](https://docs.microsoft.com/ja-jp/azure/firewall/features)
  - 参考: [Azure Firewall Premium の機能](https://docs.microsoft.com/ja-jp/azure/firewall/premium-features)
- 自動的にスケールアウト・スケールインを行う
- DNAT 機能によりフロントエンドの IP アドレスとバックエンドの IP アドレスを関連付けられる
  - バックエンドに Web サーバーを設置した場合等インバウンドトラフィックに対しても Azure Firewall を適用できる
- Firewall Policy / Azure Firewall Manager ポリシーを使用して複数の Azure Firewall を統合的に管理できる
  - ネットワーク全体の管理者と個別のサービスの管理者のような関係がある場合にルールを継承できる

Azure Firewall はハブアンドスポーク構成を展開する上でセキュアな構成をするための重要なサービスです。ハブネットワークに Azure Firewallを展開することでスポーク間のトラフィック、インターネットからの送受信トラフィック、オンプレミスへのトラフィックを制御・検査できます。

</details>

<!--
### 2.2.5 Integration

*作成中*

-->

### 2.2.6 Management

#### Azure Bastion

<details>
  <summary>解説を開く</summary>

Azure Bastion を使用すると、Azure の仮想マシンへ安全にログインできます。いわゆる踏み台サーバーを提供するサービスです。Azure Bastion をサブネットに展開すると、そのサブネットから到達可能なネットワーク上の仮想マシンへ RDP もしくは SSH でログインできます。また、Azure Bastion への認証は Azure AD による認証を使用するため、MFA のような Azure AD ならではの機能も活用できます。

Azure Bastion には `Developer` と `Basic`、 `Standard` の3 つの SKU があります。

`Basic` は Azure ポータルから仮想マシンに対してブラウザで RDP もしくは SSH が可能です。従って、操作性や機能はブラウザの機能に制限されることになりますが、ブラウザがあれば仮想マシンにログインができます。

`Standard` は ネイティブクライアントやノードのスケールに対応します。`Basic` と同様にブラウザベースでのログインも可能ですが、ネイティブクライアントを使用することで、ユーザーエクスペリエンスを向上できます。

`Developer` は最低限の機能を提供します。仮想マシンへのブラウザベースの接続ができますが、ピアリングされた VNet 上の仮想マシンへの接続が出来ない等の制約があります。

- 参照: [Azure Bastion とは](https://docs.microsoft.com/ja-jp/azure/bastion/bastion-overview)

![Bastion](./images/bastion.png)

</details>

#### Network Watcher

<details>
  <summary>解説を開く</summary>

Network Watcher は Azure のネットワークに関するサービスに対して監視機能や診断機能を提供しています。

代表的な機能として NSG フロー ログがあります。NSG フロー ログでは、NSG でフィルターされた際のログをストレージ アカウントに保存できます。NSG フロー ログには送信元先の IP アドレスやポート番号、プロトコル、許可・拒否情報、送受信バイト数が記録され、どのような通信が NSG を通過したかが記録されます。NSG フロー ログは、JSON 形式で保存されます。

- 参考: [ネットワーク セキュリティ グループのフローのログ記録の概要](https://docs.microsoft.com/ja-jp/azure/network-watcher/network-watcher-nsg-flow-logging-overview)

さらに、トラフィック 分析を使うと JSON 形式のログを解析し、Log Analytics へ送信できます。専用のダッシュボードが用意されているため、トラフィックの傾向を簡単に確認できます。

- 参考: [Traffic Analytics](https://docs.microsoft.com/ja-jp/azure/network-watcher/traffic-analytics)

![Traffic Analytics](./images/traffic-analytics-1.png)
![Traffic Analytics](./images/traffic-analytics-2.png)
</details>
