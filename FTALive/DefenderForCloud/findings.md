#### [prev](./Pre-requisites.md) | [home](./welcome.md) 
# 展開前の考慮ポイント


## Defender for Cloud の検出項目について
[Microsoft クラウド セキュリティ ベンチマーク](https://docs.microsoft.com/ja-jp/security/benchmark/azure/)  
Defender for Cloud は既定として Microsoft クラウド セキュリティ ベンチマークを使用してワークロードの評価を行います。Microsoft クラウド セキュリティ ベンチマークには ネットワーク、ID 管理、特権アクセス、ログと脅威検出などにカテゴリ分けされたセキュリティ コントロールと、Azure リソースごと考慮すべき個別のセキュリティ コントロールが記載されたセキュリティ ベースラインで構成されています。セキュリティ ベースラインに記載されている一部のセキュリティ コントロールには Defender for Cloud が使用する Azure Policy との対応が記載されています。  

重要な点として Defender for Cloud の全ての推奨事項に対応することで、セキュリティ ベースラインに記載された全ての推奨項目が充足されるわけではありません。よりセキュアな環境のためには Defender for Cloud の推奨事項を自動化されたベースラインとして活用しながら、各リソースのセキュリティ ベースラインを個別に理解し、必要なセキュリティ コントロールを実装します。

## セキュア スコアの有効化
[セキュリティ ポリシー、イニシアチブ、および推奨事項とは](https://docs.microsoft.com/ja-jp/azure/defender-for-cloud/security-policy-concept)  
Defender for Cloud によるセキュリティ態勢の評価は Azure Policy のイニシアチブ "Azure セキュリティ ベンチマーク" の割り当てによって有効になります。もしセキュア スコアが表示されていない場合、Defender for Cloud の **[環境設定]** から現在のサブスクリプションを選択し、ポリシー タブから **[既定のイニシアチブ]** が割り当てられていることを確認してください。管理グループに割り当てると、管理グループに属する全てのサブスクリプションでセキュア スコアが有効になります。ルート管理グループで有効化した場合にはテナント全体の全てのサブスクリプションでセキュア スコアが計算されるようになります。  
ポリシーによるスキャンは定期的に実行されます。設定更新後にセキュアスコアにポータルに反映されるまでは項目によって 12 時間から 24 時間程度の時間がかかります。

![イニシアチブの有効化](./images/enabledefenderforcloud.png)

## サブスクリプションの分割について 
[Microsoft Defender for Cloud の強化されたセキュリティ機能](https://docs.microsoft.com/ja-jp/azure/defender-for-cloud/enhanced-security-features-overview#can-i-enable-microsoft-defender-for-servers-on-a-subset-of-servers-in-my-subscription)  
Microsoft defender for Cloud の強化されたセキュリティ機能はサブスクリプションに存在するリソースごとに有効化されます。Azure Virtual Desktop が含まれる環境などでは、サーバーワークロードの VM は Microsoft Defender for Cloud で保護を行い、それ以外のクライアント用の VM については Defender for Cloud を使いたくないような場合にはサブスクリプションは分割しておく必要があります。

>引用：  
>自分のサブスクリプションで、サーバーのサブセットに対して Microsoft Defender for servers を有効にすることはできますか?
>
>いいえ。 サブスクリプションで Microsoft Defender for servers を有効にすると、サブスクリプション内のすべてのマシンが Defender for servers によって保護されます。
>また、Log Analytics ワークスペース レベルで Microsoft Defender for servers を有効にする方法もあります。 この場合、そのワークスペースにレポートするサーバーだけが保護され、課金されるようになります。 ただし、いくつかの機能が利用できなくなります。 それらの例としては、Just-in-Time VM アクセス、ネットワーク検出、規制コンプライアンス、アダプティブ ネットワークのセキュリティ強化機能、適応型アプリケーション制御などが挙げられます。

## ワークスペースの構成について
[Microsoft Sentinel ワークスペース アーキテクチャのベスト プラクティス](https://docs.microsoft.com/ja-jp/azure/sentinel/best-practices-workspace-architecture)  
セキュリティ監視に使う Log Analytics ワークスペースは可能な限り少なくすることが推奨で、多くの場合１つのテナントに１つのワークスペースを作成することをお薦めしています。
データの保存場所などのコンプライアンス上の要求がある場合や、データ間通信で大きなコストが発生する場合にはワークスペースを分割することも検討します。
アクセス権によってワークスペースを分けたい場合には、ワークスペースを分ける代わりに「リソース コンテキスト」のアクセス権や「テーブル レベルの Azure RBAC」で代替することができるかどうかを検討してください。
- [Azure のアクセス許可を使用してアクセスを管理する](https://docs.microsoft.com/ja-jp/azure/azure-monitor/logs/manage-access#manage-access-using-azure-permissions)
- [テーブル レベルの Azure RBAC](https://docs.microsoft.com/ja-jp/azure/azure-monitor/logs/manage-access#table-level-azure-rbac)


  

## エージェントの構成について
Defender for Cloud は VM の内部の情報を Log Analytics エージェントを使用して情報を収集するため、一部の推奨項目を利用するためには Log Analytics エージェントのインストールが必要になります。Azure Monitor エージェントが VM に関する情報を収集するための新しい仕組みとしてリリースされています。Defender for Cloud に対しては現在パブリック プレビューでの機能サポートが提供されています。
これらのエージェントは同時にインストールすることができるため、Defender for Cloud の機能を利用するために Log Analytics エージェントを使用し、VM 内のパフォーマンスやイベント ログを収集するためには Azure Monitor エージェントを使用する、といった構成をとることができます。

[Azure Monitor エージェントの概要](https://docs.microsoft.com/ja-jp/azure/azure-monitor/agents/agents-overview)


# 推奨事項の解説

Microsoft Defender for Cloud の Posture Management は多くのリソースのセキュリティ状態を無償で測定することができます。ここでは実際のお客様とのエンゲージメントで頻繁に見つかったり、よく質問を受ける [検出項目 / 推奨事項](https://docs.microsoft.com/ja-jp/azure/security-center/recommendations-reference) についてコンピューティングとネットワークカテゴリの項目を中心に取り上げポイントを紹介します。



## サブスクリプションの所有者に関連する検出項目
- サブスクリプションで所有者アクセス許可を持つアカウントに対して MFA を有効にする必要がある
- サブスクリプションに複数の所有者が割り当てられている必要がある
- サブスクリプションには最大 3 人の所有者を指定する必要がある

高い権限を持つ管理アカウントは主要な攻撃のターゲットとなるため、適切な保護を行う必要があります。Microsoft Defender for Cloud は [Azure RBAC のベスト プラクティス](https://docs.microsoft.com/ja-jp/azure/role-based-access-control/best-practices) に従ってサブスクリプションの所有者のアカウントを確認します。特定の管理アカウントに問題があった際の備えとして複数の所有者を割り当てることが推奨ですが、多すぎる場合にはリスクと判断されます。また、パスワードだけの認証は安全ではないため、MFA の設定が推奨されています。
> Azure AD Premium などのライセンスがない場合でも [Azure AD のセキュリティの規定値群](https://docs.microsoft.com/ja-jp/azure/active-directory/fundamentals/concept-fundamentals-security-defaults)を有効化することで、モバイル アプリを使用した多要素を利用することができます。
>Azure AD Premium ライセンスがある場合には、より柔軟な条件付きアクセス (Azure AD Premium P1) や、一時的に特権の昇格を可能にする Azure AD Privilege Identity Management (Azure AD Premium P2) を利用することができます。


[特権アクセス: 戦略](https://docs.microsoft.com/ja-jp/security/compass/privileged-access-strategy)
![](https://docs.microsoft.com/ja-jp/security/compass/media/overview/end-to-end-approach.png)
特権アクセスの保護は従来からの重要な課題で、マイクロソフトではオンプレミスとクラウドをカバーする特権管理についてのの包括的なガイダンスを提供しています。  



## コンピューティングの推奨事項

### Azure Defender for Servers を有効にする必要がある /  ワークスペースで Azure Defender for servers を有効にする必要がある

Microsoft Defender for Cloud の強化されたセキュリティは様々なワークロードに対してリアルタイムの脅威の検出とアラートを提供します。サーバー向けの強化されたセキュリティは、これに加えて複数のセキュリティ機能があり、他の推奨項目と関連を持っています。以下にサーバー向け強化されたセキュリティの代表的な機能と、関連する推奨事項を紹介します。
>サーバー向け Microsoft Defender for Cloud の強化されたセキュリティはサブスクリプション単位とワークスペース単位で有効化することができます。ワークスペース単位で有効化した場合には一部の機能を使用することができません。

![Azure Defender](./images/sample-defender-dashboard.png)

### Microsoft Defender for Endpoint との統合
Microsoft Defender for Endpoint と統合されたサーバー向けの脅威検知機能です。サーバー上のアクティビティのふるまい検知を行いアラートを生成します。また、アラートが発生した際の対応に必要となる情報収集を行ったり、コンピューターのネットワーク接続を制限するなどインシデント対応機能も含まれています。Microsoft Defender for Endpoint はアンチ マルウェア機能とは別であり、機能に依存関係はありますが別で動作します。  
Microsoft Defender for Endpoint を使用し、サードパーティのアンチ マルウェア製品使用するという構成をとることもできます。この場合、アンチ マルウェア機能の構成変更や、Microsoft Defender for Endpoint の一部の機能が制限されるため注意してください。  
[Microsoft Defender ウイルス対策の他のセキュリティ製品との互換性](https://docs.microsoft.com/ja-jp/microsoft-365/security/defender-endpoint/microsoft-defender-antivirus-compatibility?view=o365-worldwide#microsoft-defender-antivirus-and-non-microsoft-antivirusantimalware-solutions)

> Microsoft Defender for Servers は Midrosoft Defender for Cloud が提供する一連のセキュリティ機能の集合であり、アンチマルウェア機能を指すものではありません。Azure の標準のイメージを使用して作成される Windows VM はクライアント、サーバー共にMicrosoft Defender ウイルス対策が既定で有効化されています。



### Just-in-Time VM アクセス 
特定のポートを限られた時間だけ特定の IP アドレスに向けて開くことができる機能です。パブリック ネットワークから管理作業を行いたい場合に、最小限の範囲にポートを開くために使用することができます。ただし、拠点のゲートウェイとなるパブリック IP に対してポートを開くような場合、拠点内ネットワークの意図しないコンピューターから通信が可能になるなどの懸念があるため注意してください。

関連する推奨事項
* 仮想マシンの管理ポートを閉じておく必要がある
* 仮想マシンの管理ポートは、Just-In-Time ネットワーク アクセス制御によって保護されている必要があります

###  Adaptive Application Control
コンピューター上で動作するプロセスを学習し、普段観測されないプロセスの起動をアラートします。サーバーワークロードは基本的に提供するサービスに応じて毎回決まったプロセスが起動するため、システムの変更が予定されていない期間などに今まで観測されていなかった新しいプロセスが起動する、というのは意図しない変更やセキュリティ侵害を示唆することになりますが、このようなイベントを検出することができます。

![Adaptive Application Control](./images/aac.png)

関連する推奨事項
* 安全なアプリケーションの定義のために適応型アプリケーション制御をマシンで有効にする必要がある
* 適応型アプリケーション制御ポリシーの許可リスト ルールを更新する必要がある

###  Adaptive Network Control 
ネットワーク通信を分析し、制限するポートを提案する機能です。開くポートは最小限にすることがセキュリティ上のベストプラクティスですが、この機能を活用することで実際の通信から使われていないポートを特定することができるため、可用性への影響を小さくすることができます。

![Adaptive Network Control](./images/anc.png)

関連する推奨事項
* アダプティブ ネットワーク強化の推奨事項をインターネット接続仮想マシンに適用する必要がある

###  ファイル整合性の確認 
ファイルやレジストリの改ざんを検出する機能です。この機能には様々な利用方法が考えられますが、例えば Web サービスを提供している VM で意図しないアプリケーションの変更やサイトの改ざんを検出したり、セキュリティ侵害時に変更される可能性が高いファイルをこの機能で監視することで侵害の兆候をアラートすることができます。

![File Integrity Monitoring](./images/fileintegrity.png)

関連する推奨事項
* サーバーでファイルの整合性の監視を有効にする必要がある


### 脆弱性スキャナ― 
Defender for Cloud は脆弱性スキャナを使用して、検出された仮想マシン上の脆弱性を表示します。一般的に Windows Update がカバーする OS やマイクロソフト製品についての脆弱性には定期的な対処が行われることが多いですが、サードパーティのソフトウェアやサービスは文書ベースで管理を行っていたり、全く管理が行われずに脆弱性が放置されたままになっていることがあります。
Defender for Cloud では既定で 2 種類の脆弱性スキャナを提供しており Qualys と、Microsoft Defender for Servers に組み込みの脆弱性スキャンを選択することができます。脆弱性スキャナを使用することで、Windows Update ではカバーされないサードパーティのソフトウェアやサービスに存在する既知の脆弱性を検出することができます。

関連する推奨事項
* 脆弱性評価ソリューションを仮想マシンで有効にする必要がある
* 仮想マシンの脆弱性を修復する必要がある






[参考：Azure Virtual Machines のトラステッド起動](https://docs.microsoft.com/ja-jp/azure/virtual-machines/trusted-launch)

## コンピューティングとストレージのリソース間で一時ディスク、キャッシュ、データ フローを仮想マシンによって暗号化する必要がある

Azure Disc Encription (ADE) で暗号化されている場合は正常、それ以外は異常（あるいは適用不可）と表示されます。これは現在の Defender for Cloud の制限で、将来的にはホストでの暗号化についても正常と判定されるようになる予定です。
格暗号化オプションによる暗号化されるデータのの詳細な比較は[こちら](https://docs.microsoft.com/ja-jp/azure/virtual-machines/disk-encryption-overview#comparison)を参照してください。
どのデータを暗号化するかについて詳細な要件は存在しないケースが多いですが、SSE やホストでの暗号化で保護されたディスクはエクスポートや VM へのアタッチによりデータの読み書きが可能であるため、このような脅威シナリオを想定する場合には注意が必要です。

- **サーバー側暗号化 (SSE)、ホストでの暗号化:** ディスクに物理的にアクセスされるようなシナリオからデータを保護することができますが、ディスクを VM にアタッチしたり、ディスクをエクスポートするようなシナリオからデータを保護することはできません。
- **Azure Disk Encryption:** ディスクのアタッチやエクスポートなどシナリオからデータを保護することができます。ホストの CPU リソースを消費します。

ディスクのエクスポートによる脅威を緩和策は、上記の ADE による暗号化の他、他アクセス可能なネットワークを制限することでも防ぐことができます。
[参考：Azure Private Link を使用してマネージド ディスクに対するインポートおよびエクスポートのアクセスを制限する](https://docs.microsoft.com/ja-jp/azure/virtual-machines/disks-enable-private-links-for-import-export-portal)


## vTPM を、サポートしている仮想マシンで有効にする必要があります

攻撃コードには OS 上に生成されるファイルやプロセスの他にも、OS が起動する前に動作することでセキュリティ機能による検出を避けるルートキットやブートキットとよばれる種類のものがあります。
Windows にはハードウェア ベースで OS の起動に至るまでのブートの流れを確認し、コードの整合性を保つ仕組みが導入されていて、Azure VM でも利用することができます。セキュアブートは起動コンポーネントのコード署名を確認し、予め登録された信頼できるバイナリだけが動作することを保証します。vTPM はブートに起動するコンポーネントを計測し、正常に起動した場合のブートとの比較を行い、正常に起動したことを証明します。これらの機能を有効化することで、攻撃の永続化をより困難にすることができます。特定の機能が制限される場合があるため、FAQ を確認してください。
[参考：Azure Virtual Machines のトラステッド起動](https://learn.microsoft.com/ja-jp/azure/virtual-machines/trusted-launch)

関連する推奨事項
* セキュア ブートを、サポートしている Windows 仮想マシンで有効にする必要があります
* vTPM を、サポートしている仮想マシンで有効にする必要があります
* 仮想マシンのゲスト構成証明の状態は正常である必要がある



# ネットワークに関する検出項目
## 仮想マシンの管理ポートは、Just-In-Time のネットワーク アクセス制御で保護する必要があります
RDP や SSH など、仮想マシンを管理するポートがパブリック インターネットに対して開かれている場合にこの項目が検出されます。システムの設計時にこのような設定になっているケースは少ないですが、運用中に新たに作成された VM に対して管理ポートが開かれていたり、構築時のトラブルシューティングのために開かれた管理ポートがそのままになっていたりするケースもあります。


>安全な管理を目的とした機能としてはには Azure Bastion があります。Azure Bastion は Azure Portal 上から管理アクセスを行う機能で、この機能は画面転送だけに制限されますが、インターネットには管理ポートは開かず、Azure Portal へのアクセスの際に条件付きアクセスや Azure MFA を適用することができるので、より安全に管理作業を行うことができます。



## <リソース> ではプライベート リンクを使用する必要がある
これは推奨事項の有効化に際して十分な注意が必要な項目の例です。一部の推奨事項は環境をセキュアにすることに貢献しますが、可用性や全体的なアーキテクチャに影響を与える可能性があります。

プライベート リンクは PaaS のコンポーネントに対してアクセスできる経路を仮想ネットワークに作成したプライベート エンドポイントからのアクセスを可能にする機能です。パブリック インターネットからのアクセスを禁止することもできるので、アクセスの制限をより厳しく実施することができます。

リソースのネットワーク アクセスをセキュアにすることができる半面、元々そののリソースに対してインターネット経由のアクセスが必要なコンポーネントがあった場合、この設定による影響を受けますので、事前に十分な調査と検証を行う必要があります。

[参考：Azure プライベート エンドポイントの DNS 構成](https://docs.microsoft.com/ja-jp/azure/private-link/private-endpoint-dns)  
[参考：Azure Private Link を使用して、ネットワークを Azure Monitor に接続する](https://docs.microsoft.com/ja-jp/azure/azure-monitor/logs/private-link-security)

## Azure SQL Database のパブリック ネットワーク アクセスを無効にする必要がある
これは設定の背景を十分に理解する必要があります。

Azure SQL のセキュリティのベストプラクティスでは、 Azure SQL のアクセスはパブリック インターネットからのアクセスを拒否し、プライベート エンドポイント経由のアクセスのみに制限することです。多くのお客様の環境では Azure SQL のファイアウォールの機能でアクセス制御を行っているケースがあります。

Azure SQL データベースではサーバーのレベルで複数のデータベース全体へのアクセスが拒否されていても、個別のデータベースのアクセスが先に評価されます。このため、サーバーレベルでアクセスを禁止している場合でも、各データベースの管理者が個別にデータベース レベルのファイアウォールを設定し、任意のネットワークからのアクセスを許可する可能性があります。もし Azure SQL のファイアウォールでネットワークアクセスを制限している場合、これらデータベース レベルのネットワーク アクセスも定期的に監査し、不要なネットワーク アクセスが許可されていないことを確認してください。

[参考：Azure SQL Database と Azure Synapse の IP ファイアウォール規則]("https://learn.microsoft.com/ja-jp/azure/azure-sql/database/firewall-configure?view=azuresql")

![Azure SQL Firewall Rule](https://learn.microsoft.com/ja-jp/azure/azure-sql/database/media/firewall-configure/sqldb-firewall-1.png?view=azuresql)


## Azure DDoS Protection Standard を有効にする必要がある
この推奨事項については実際の要件を十分に確認してください。
現在 Azure DDoS Protection には DDoS ネットワーク保護と DDoS IP 保護 (プレビュー) の 2 つの SKU が存在し、この推奨事項の Azure DDoS Protection Standard は DDoS ネットワーク保護を指しています。

[参考：Azure DDoS Protection SKU の比較について](https://learn.microsoft.com/ja-jp/azure/ddos-protection/ddos-protection-sku-comparison)

DDoS ネットワーク保護は月額料金に 100 個までの パブリック IP アドレスを含み、Application Gateway の WAF 機能を無償で使用することができるため、多くの IP アドレスに対する DDoS 攻撃対策を検討する場合には DDoS ネットワーク保護が有利な場合があります。

DDoS ネットワーク保護には DDoS Rapid Response に問い合わせを行うことができ、DDoS の検知や保護状況に関する問い合わせや、予定されているイベントにより大規模なネットワーク トラフィックが発生する可能性がある場合の調整を行うことができます。

[参考：Azure DDoS Rapid Response](https://learn.microsoft.com/ja-jp/azure/ddos-protection/ddos-rapid-response#when-to-engage-drr)


[参考：Azure DDoS Protection の参照アーキテクチャ](https://learn.microsoft.com/ja-jp/azure/ddos-protection/ddos-protection-reference-architectures)

![Azure Firewall と Azure Bastion を使用したハブアンドスポーク ネットワークトポロジ](https://learn.microsoft.com/ja-jp/azure/ddos-protection/media/reference-architectures/ddos-network-protection-azure-firewall-bastion.png)


DDoS 対策は [テスト パートナー](https://docs.microsoft.com/ja-jp/azure/ddos-protection/test-through-simulations) を試用してシミュレーションを行うことができます。シミューレーションでは攻撃対象のパブリック IP アドレスが申請者のサブスクリプションに属していることが確認されます。

## 仮想ネットワークは、Azure Firewall によって保護する必要がある

推奨事項には Azure Firewall の不足を検出するものがあります。Azure Firewall によってネットワーク アクセスを制御する場合、ネットワーク アーキテクチャの構成も併せて検討することで、コストの最適化と効果的なネットワーク アクセスの制御を実現することができます。

### ハブ & スポーク モデルと Azure Firewall

Azure で仮想マシンを動作させるには仮想ネットワーク (Vnet) という論理的なネットワークを作成し、そこに仮想マシンを接続させる必要があります。仮想ネットワークは複数のサブネットを持つことができます。同一仮想ネットワーク内のサブネットは既定で全ての通信が許可されるため、ネットワーク間の通信を制限したい場合、各サブネットに対してネットワーク通信を制限する NSG を設定することになります。この構成ではサブネットが追加されるに従ってルールのメンテナンスが煩雑になるため、拡張性と柔軟性が失われます。

そこで複数の仮想ネットワークを相互に接続し、システム毎の境界を仮想ネットワーク単位で分離する構成を取ることが、拡張性や柔軟性の観点で推奨されています。この構成は複数のシステムから共通して利用される Vnet を中心に一つだけ配置し、システム単位で作成した Vnet は中心の Vnet から車輪のスポークのように複数配置することからハブ & スポーク モデルと呼ばれています。

スポーク Vnet 同士は既定では互いに通信できないためセグメント間の分離が容易です。また、セキュリティ境界が分かれた新たなシステムを追加したい場合にもスポーク Vnet をハブに繋げればよく、将来に向けて拡張しやすい構成となります。

多くの環境では Azure 上のコンポーネントからパブリック インターネットに向けた通信を行う要件が発生します。特にサーバー用途の VM が多い場合、通常通信を行う対象は信頼できる宛先に制限を行いますが、NSG を使用した IP アドレスとポートに基づくネットワークレベルの制限はパブリック インターネットへのアウトバウンドの制御には不向きです。このため、ネットワーク仮想アプライアンス (NVA) を使用してアプリケーション層の制御を行うことが一般的です。Azure では 1st Party の NVA として Azure Firewall を使用することができます。

Azure Firewall の機能は Standard と Premium によって異なります。Standard はネットワークのアクセス制御を行うためのほとんどの機能を利用することができます。Azure ネットワークとの通信対象を IP、ポートや FQDN で制限したり、あらかじめ用意されているタグを制限に使用することができます。また、脅威インテリジェンスによる通信対象の脅威検知を行うことができます。 Premium ではより柔軟な URL による制御が可能になる他、TLS のインスペクションを実施することができるため、HTTPS によって暗号化された通信の内容に対する脅威検知を行うことができます。

Azure Firewall の通信やセキュリティ イベントは Azure Monitor ログに記録されるため、任意の監視ソリューションと連携することができます。

![Hub-Spoke](./images/hubspoke.png)

[Azure Firewall の機能](https://docs.microsoft.com/ja-jp/azure/firewall/features)
- FQDN フィルタリング
- ネットワーク トラフィックの フィルタリング
- FQDN タグ
- サービス タグ
- 脅威インテリジェンス
- DNAT / SNAT
- Azure Monitor によるログ
- 強制トンネリング
- Web カテゴリ (FQDN ベース)


[Azure Firewall Premium の機能](https://docs.microsoft.com/ja-jp/azure/firewall/premium-features)

- TLS インスペクション
- IDPS
- URL フィルタリング
- Web カテゴリ (URL ベース)


# リンク
[Become a Microsoft Defender for Cloud Ninja](https://techcommunity.microsoft.com/t5/microsoft-defender-for-cloud/become-a-microsoft-defender-for-cloud-ninja/ba-p/1608761)  
[Microsoft Defender for Cloud の 強化されたセキュリティ機能を有効にする](https://docs.microsoft.com/ja-jp/azure/defender-for-cloud/enable-enhanced-security)


