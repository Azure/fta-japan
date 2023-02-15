# AKS 6 part series 1/6

Part 1 of 6 | [セキュリティベストプラクティス &rarr;](./2-security-best-practices.md)

# ネットワーク

> **メモ**
> _この配布資料は、事前に用意されており、実際のセッションの内容とは、議論によって異なる可能性があります_
> 

## 概念

まず、AKS クラスターを作成する前に以下の内容を理解しておく必要があります。
[Azure Kubernetes Service (AKS) クラスターのベースライン アーキテクチャ](https://learn.microsoft.com/ja-jp/azure/architecture/reference-architectures/containers/aks/baseline-aks) では、ネットワークの構成、クラスター構成、ID管理、データフローのセキュリティ保護、ビジネス継続性、オペレーションについての記載があります。
今回は、ネットワークについてですので、上記のドキュメントのネットワーク・トポロジーとIPアドレスの計画（割り当て）、イングレスリソースのデプロイを扱います。

### ネットワーク・トポロジー

![ネットワーク・トポロジー図](./images/AKS_topology.png)

下記にベストプラクティスを含む、 AKS クラスターをデプロイする場合の一般的なネットワーク・トポロジーを示します。ポイントは以下のとおりです。

1. 分離された管理、ガバナンスの適用と最小特権の原則の遵守
2. Azure のリソースを直接インターネットに公開することを防ぐ
3. 将来的なネットワークの拡張、ワークロードの分離などのために、ハブ・スポークモデルを採用する
   1. 複数のサブスクリプションを使う場合
   2. 新しいワークロードを追加する場合に、スポークを追加するだけなので、ネットワーク・トポロジーの再設計が不要
   3. FW や DNS などの特定のリソースを共有化できる
4. すべてのWebアプリケーションに HTTP のトラフィックフロー管理に役立つ WAF を導入する

ハブアンドスポークの詳しい内容は、[Azure エンタープライズ規模のランディングゾーン](https://learn.microsoft.com/ja-jp/azure/cloud-adoption-framework/ready/enterprise-scale/implementation) を参照してください。

ハブに用意するサブネットに紐づくリソースは以下のとおりです。

- Azure Firewall
- Bastion (踏み台として)
- VPN ゲートウェイ

スポークに用意するサブネットに紐づくリソースは以下の通りです。

- Azure Application Gateway
- イングレスリソース（イングレスコントローラー）
- クラスターノード
- プライベートリンク・エンドポイント

### IPアドレスの計画

AKS を使う上でIPアドレス空間について十分大きなものを用意する必要があります。
その理由の一部は以下の通りです。

1. アップグレード  
   アップグレードをする場合、ポッドの可用性を担保しながら、クラスターをアップグレードする必要があります。その場合、古いポッドの正常終了と新しいポッドの正常起動を確認して、新しいポッドへ接続を開始します。その瞬間、一時的ではありますが、ポッドのIPアドレスを消費することになります。
2. スケーラビリティ  
   もし、必要なワークロードが大きくなり、ワーカーノードを増やす必要性があった場合、4倍のクラスターを用意するとしたら、4倍のアドレス空間が必要になります。
3. プライベートリンク  
   新たなリソースを追加する場合、プライベートリンクを使うことになります。プライベートリンクを使う場合、プライベートIPアドレスを割り当てる必要があります。そのため、プライベートIPアドレスを割り当てるためには、十分なアドレス空間が必要になります。
4. 予約アドレスは使用不可  
  [IPアドレスの使用に関する制限](https://learn.microsoft.com/ja-jp/azure/virtual-network/virtual-networks-faq#are-there-any-restrictions-on-using-ip-addresses-within-these-subnets)
   >  Azure では、各サブネット内で最初の 4 つの IP アドレスと最後の IP アドレスの合計 5 つの IP アドレスが予約されます。
   > たとえば、IP アドレスの範囲が 192.168.1.0/24 の場合、次のアドレスが予約されます。
   >
   > - 192.168.1.0: ネットワーク アドレス
   > - 192.168.1.1: 既定のゲートウェイ用に Azure によって予約されます
   > - 192.168.1.2、192.168.1.3: Azure DNS IP を VNet 空間にマッピングするために Azure によって予約されます
   > - 192.168.1.255: ネットワーク ブロードキャスト アドレス。

上記に記載した内容は例であり、一部分です。デプロイする要件に応じて十分大きなアドレス空間を確保する必要があります。

![IPアドレス設計](./images/aks-baseline-network-topology.png)

### イングレスリソースのデプロイ

イングレスリソースは、クラスターの外部からクラスター内部へのアクセスを許可するために必要です。クラスターへの着信トラフィックのルーティングと分散を行います。概ね2つの役割があります。

1. 内部ロードバランサー
   プライベートな静的IPアドレスを持ち、クラスター内部のポッドに対してトラフィックを分散します。
2. イングレスコントローラー
   いくつかの種類のイングレスコントローラーがありますが、例えば、Azure Application Gatewayを使う場合、外部からの着信トラフィックを受け付け、クラスター内部のロードバランサーにルーティングします。一方で、Nginx や Traefik などを使う場合、ロードバランサーで受け付けたトラフィックを クラスター内部の Pod で構成された、Nginx や Traefik にルーティングします。

#### イングレスコントローラーを使う場合の注意点

イングレスコントローラー、特に、Nginx や Treafik を使う場合には、クラスター内のリソースとして十分な考慮が必要になります。

- イングレスコントローラーがアクセスできる範囲を、コントローラーと特定のワークロードのポッドへのアクセスに制限します。
- 負荷分散とノードがダウンしたときを考慮し、`podAntiAffinity`を使い、同じノードにレプリカを配置しないようにします。
- ポッドがユーザー（ワーカー）ノードプールでのみ、スケジューリングされるように、`nodeSelecotors` を使用します。これにより、システムノードにて、ワークロードを実行するポッドが稼働しないように制限できます。
- イングレスコントローラーとポッド間で必要なポートとプロトコルだけを受け付けるように設定します。
- イングレスコントローラーからポッドの正常性を確認するために、`redinessProbe`と`livenessProbe`を設定します。
- イングレスコントローラーについて、 Kubernetes の RBAC を使って、特定のリソースへのアクセスと特定のアクションのみを実行するように制限してください。例えば、 Kubenetes の `ClusterRole` のルールを使って、イングレスコントローラーにサービスとエンドポイントを監視、取得、一覧表示するためのアクセス許可を付与することができます。

### [AKS ネットワーク接続とセキュリティに関するベストプラクティス](https://learn.microsoft.com/ja-jp/azure/aks/operator-best-practices-network)

> 注意： 次回のセキュリティのベストプラクティスでは、これよりも深い内容で多角的に説明をしますので、そちらも合わせてご参加ください。

- 適切なネットワークモデルを選択する
  AKSには、2つのネットワークモデルがあります
  - CNIネットワーク
  - Kubenet ネットワーク
  - この2つのネットワークの違いを理解するために以下の資料が役に立ちます
    - 参考：[ネットワークモデルの比較表 - Kubenet vs Azure CNI](https://learn.microsoft.com/ja-jp/azure/aks/concepts-network#compare-network-models)
- Ingress トラフィックを分散する
  - Ingress リソース（yamlファイルの例）
  - Ingress コントローラー
    - Nginx だけでなく、Contour、HAProxy、Traefik なども使えます
- WAF を使ったトラフィックの保護
  - 外部からのトラフィックを保護するために、Azure Application Gateway、Azure Front Door、Azure Firewall を使う
  - 例では、Azure Application Gateway を使っています
- ネットワークポリシーを使用してトラフィックフローを制御する
- 踏み台ホストを介してノードに安全に接続する
  - Azure Bastion Service を使う

### Azure の VNET と AKS を接続するには？

この疑問を解消するために以下の2つの記事が役にたちます。シンプルな例ですが、これらの記事を参考にして、自分の環境に適したネットワークモデルを選択してください。

- [仮想ネットワークとkubenet](https://docs.microsoft.com/azure/aks/configure-kubenet)
  - こちらの記事では、kubenet を利用して AKS と VNET を接続する方法を説明しています
- [仮想ネットワークとAzure CNI](https://docs.microsoft.com/azure/aks/configure-azure-cni)
  - こちらの記事では、Azure CNIを利用して AKS と VNET を接続する方法を説明しています

### Cloud Adoption Framework (CAF) 推奨事項

- [AKS ネットワークデザインの推奨事項](https://docs.microsoft.com/azure/cloud-adoption-framework/scenarios/app-platform/aks/network-topology-and-connectivity#design-recommendations)
  - ネットワークモデルの選択
    - Kubenet vs　Azure CNI
  - 仮想ネットワークサブネットのネットワークサイズの指定
  - DDoSなどからの保護
    - Azure Firewall または、WAF　を使用する場合以外のシナリオでの、仮想ネットワークの保護には、Azure DDoS Protection Standard を使います
  - DNSの構成
    - Azure VirtualWAN or ハブスポーク構成、AzureのDNSゾーン、独自のDNSなど全体のネットワークで使われるDNS構成を使います
  - Private Link の活用
    - マネージド Azure サービス (Azure Storage、Azure Container Registry、Azure SQL Database、Azure Key Vault など) にプライベート IP ベースの接続をします
  - Ingress Controller の選択
    - 高度なHTTPルーティングとセキュリティを提供する目的で、アプリケーションのための単一エンドポイントを提供します（ゲートウェイパターン）
  - Incoming Traffic の暗号化
    - Ingress の通信には、全てTLS暗号化を使用します
  - 外部 Ingress コントローラーの利用
    - 必要に応じて、クラスターの外にIngressコントローラを用意します
      - Application Gateway Ingress Controller アドオンの利用
      - AKS クラスターごとに、Application Gateway を用意します
      - AGIC が必要な機能を提供していない場合は、Nginx、Traefik その他のIngressコントローラを使用します
  - WAFの利用
    - インターネットの接続点を持っている場合、WAF を活用して、インターネットからのアクセスを保護します
  - 外向きの通信について
    - AKSクラスターからの外向きの送信インターネットトラフィックの制限がセキュリティポリシーにある場合は、Azure Firewall 及び、ハブにデプロイされたNVAを使って送信トラフィックに制限をかけます
  - プライベートクラスタでない場合は、許可されたIP範囲を使用する
  - Azure Load Balancer のSKU
    - Basic ではなく、Standard を使用してください
  - [プライベートAKSクラスターのデプロイ](https://learn.microsoft.com/ja-jp/azure/aks/private-clusters)
  - プライベートDNSの設定
    - システム
    - None
    - カスタムプライベートDNSゾーン
      - CUSTOM_PRIVATE_DNS_ZONE_RESOURCE_ID

## いただいた質問など

> 参加者の方から質問を受け付けます。今回回答できなかった内容については、後日こちらに記載しておきます。

例） グローバル・サービスを構築したいのですが、 Frontdoor と Application Gateway を組み合わせて利用することはできますか？ - はい、要件や状況に応じて使い分けてください。こちらのドキュメントが参考になります。
[Front Door の背後に Application Gateway をデプロイする必要はありますか?](https://learn.microsoft.com/ja-jp/azure/frontdoor/front-door-faq#front-door------application-gateway-----------------)


### 質問1 

> 【状況】
>  ・AKS を使用し、Application Gateway を介して外部からの通信を受け付けている 
>・DNS ゾーンには特定ドメインに対し、 A レコードで Application Gateway のパブリック IP を登録 
>
> ・Application Gateway のバックエンドプールには AKS のドメイン（~~~.japaneast.cloudapp.azure.com）？を指定（これでロードバランサー（AKS）に対して通信が流れる認識です・・・） 
>・AKS 内はイングレスコントローラー（pod）を Helm からデプロイし、ロードバランサー（AKS）から AKS 内サービスへの通信を実現 <br><br>
>上記の設定で、「Application Gateway -> ロードバランサー（AKS）-> イングレスコントローラー（pod）-> AKS 内のサービス」の流れができている認識です。<br><br>
>【質問】 そこで質問がございます。 SSL/TLS はApplication Gateway に設定して https で接続できることは確かめられておりますが、ロードバランサーやイングレスコントローラーには不要なのでしょうか？ 一時期は Application Gateway を使用していない時期があり、イングレスコントローラーに SSL/TLS 証明書をあてて https 通信をしておりました。 本日のセッションで Incoming Traffic はすべて暗号化するのがベストプラクティスとおっしゃっておりましたので、今の構成だと暗号化が不足しているのかもと思い、ぜひ教えていただきたいです。

> 【回答】
> ロードバランサー（AKS）は、L4までカバレッジを持ったサービスですので SSL/TLS 証明書をあてることができません。しかしながら、Application Gateway からの通信についても必要であれば、SSL/TLS 証明書をあてることができます。例えば、Nginx や Treafik をイングレスコントローラーに使っているケースでは、`Let's Encrypt` を利用して SSL/TLS 証明書を取得、設定することができます。<br><br>
> 参考1：[Let's Encrypt を使用して Ingress コントローラーに SSL/TLS 証明書を追加する](https://docs.microsoft.com/ja-jp/azure/aks/ingress-tls#use-lets-encrypt-to-add-an-ssltls-certificate-to-an-ingress-controller)
> <br>
>参考2：[TLS - Treafik 公式ページ](https://doc.traefik.io/traefik/https/tls/)
> <br><br>
> 基本的に、Application  Gateway からバックエンドの通信が Public に公開されることはありませんが、Microsoft DC の内部ネットワークにおいても暗号化通信が必要だというケースに上記を適用できるという認識をお持ちいただければと思います。
> 
