# はじめに

クラウド環境に移行すると、展開されたワークロードを適切にコントロールすることが大きな課題になります。様々な調査では CEO や CIO などは、クラウドの全体を把握できるかどうかという可視性について懸念を抱いていることがわかっています。

Microsoft Defender for Cloud を活用することでクラウド環境の把握とコントロールが可能になります。

![Cyber Security Framework](./images/csf-product.png)
[NIST Cyber Security Framework](https://www.nist.gov/cyberframework)

## クラウド セキュリティ態勢管理 (CSPM)

CSPM の機能は無償の「基本的な CSPM」と有償の「Defender クラウド セキュリティ態勢管理 (CSPM)」の２つのプランが用意されており、サーバー、ストレージ、SQL、ネットワーク、アプリケーション、ワークロードなど、Azureで稼働しているクラウド リソースのセキュリティ状態を確認することができます。

[Microsoft Docs](https://docs.microsoft.com/ja-jp/azure/security-center/security-center-introduction) からの引用 - Microsoft Defender for Cloud は、3 つの緊急性が高いセキュリティの課題を対処します:

* **急速に変化するワークロード** – これはクラウドの強みであり、課題でもあります。 一方、エンド ユーザーはより多くの処理を実行できます。 さらに、使用および作成されている常に変化するサービスが、お客様のセキュリティ基準に準拠し、セキュリティのベスト プラクティスに従っていることを確認するにはどうすればよいでしょうか。

* **ますます高度になる攻撃** - ワークロードをどこで実行する場合でも、攻撃はますます高度になっています。 パブリック クラウドのワークロードを保護する必要があります。これは実質的にインターネットに接続しているワークロードであり、セキュリティのベスト プラクティスに従わないと、さらに脆弱になる可能性があります。

* **セキュリティ スキルの不足** - セキュリティ アラートとアラート システムの数は、環境が保護されているかどうかを確認するために必要な経歴と経験を持つ管理者の数を上回っています。 最近の攻撃の最新情報を把握し続けることは常に課題であり、セキュリティの世界が絶え間なく変化する最前線に立ち続けることは不可能です。

Microsoft Defender for Cloud の最大のメリットは、['Secure Score'](https://docs.microsoft.com/en-us/azure/security-center/secure-score-security-controls#security-controls-and-their-recommendations)です。セキュアスコアは、現状を把握し、効果的かつ効率的にセキュリティを向上させることを目的としています。セキュアスコアは、リソースのセキュリティ問題を継続的に評価し、それらを1つのスコアに集約することで、現在のセキュリティ態勢を確認することができます。スコアが高ければ高いほど、特定されたリスクレベルは低くなります。これは、[Microsoft Cloud Security Benchmark](https://docs.microsoft.com/en-us/security/benchmark/azure/baselines/security-center-security-baseline?toc=/azure/security-center/TOC.json)と呼ばれるポリシーによって制御されます。このポリシーは、推奨されるベストプラクティスに基づいて構築され、Center for Internet Security Benchmark の内容も考慮しています。

この機能は 「基本的な CSPM」に含まれており、無償で使用することができます。

「Defender クラウド セキュリティ態勢管理 (CSPM)」はこの機能に加えて規制コンプライアンス（ISO 27001 や PCI-DSS などの標準に基づいてリソースの評価を行う機能）や、攻撃パスの分析などさらなる可視性を得るための機能を利用することができます。

### Microsoft Cloud Security Benchmark

Microsoft が推奨するクラウド サービスを利用する際のセキュリティ コントロール（管理策）とその実装ガイダンスです。セキュリティ コントロールはクラウド サービスの利用に最低限必要なものを、数が多くなりすぎないように提供されています(12カテゴリ、86種)。このため、人的リソースが限られている組織でも全体を把握することが容易です。

#### 重要な標準を参照

Microsoft Cloud Security Benchmark が提供するコントロールは広く使われている重要なセキュリティ標準を参照しています。これにより、最小限必要なものを選んでいるものの、従来考慮されていた必要なセキュリティに対して、大きな欠落がないことを期待することができます。また、これらのコントロールを既に採用している場合には Microsoft Cloud Security Benchmark を簡単に取り込むことができます。

* CIS Critical Controls v8  
[Center for Internet Security](https://www.cisecurity.org/) が提供するセキュリティコントロールです。クラウド以外の環境も対象とする包括的なセキュリティ コントロールになっていて、20 カテゴリに約 150 のコントロールが定義されています。CIS は CIS Benchmark として、様々な製品のセキュアな構成を提供していて、特にマルチ ベンダーの環境を 1 つのセキュリティ基準で統一したい場合に良く使われています。

* NIST SP 800-53  
米国国立標準技術研究所（NIST）が発行する連邦情報システムの標準的なフレームワークです。20 のカテゴリに分類された数百のセキュリティ コントロールを含んでいます。網羅性が高く詳細であり、各セキュリティコントロールには解説や実装のガイドが記載されているため、様々な組織でセキュリティ コントロールを実装する際のリファレンスとしても活用することができます。個別の製品についての実装は言及されていないという点は注意する必要があります。

* PCI-DSS  
PCI DSS（Payment Card Industry Data Security Standard）は、クレジットカード情報を扱う事業者や組織に対して、その取り扱いに関するセキュリティ基準を規定した業界標準です。様々な組織で採用されている長い実績があり、アクセス制御や暗号化など、IT 機器に実装しやすい基準も定義されています。

#### AWS と GCP に対するガイダンスを提供

Microsoft Cloud Security Benchmark のセキュリティ コントロールでは Azure だけでなく AWS と GCP に対するガイダンスと追加のコンテキスト（関連リンク）も提供されています。これによりクラウド サービスごとに基準を個別に管理するという手間を省き、マルチクラウドのセキュリティを１つの基準で管理することができるようになります。

#### 個別のリソースに対する実装ガイダンスと Microsoft Defender for Cloud

Microsoft Cloud Security Benchmark ではセキュリティ ベースラインとして個別のリソースに対して考慮すべきセキュリティ コントロールがメンテナンスされています。例えば環境で App Service を利用する場合には [App Service のセキュリティ ベースライン](https://learn.microsoft.com/ja-jp/security/benchmark/azure/baselines/app-service-security-baseline) を、Storage Account を使用する場合には [Storage のセキュリティ ベースライン](https://learn.microsoft.com/ja-jp/security/benchmark/azure/baselines/storage-security-baseline) を参照することで、各リソースで考慮すべきセキュリティ コントロールと、その実装ガイドを確認することができます。また、設定は Azure Policy で継続的に評価が行われ、Microsoft Defender for Cloud で準拠状況を追跡することができます。

### 基本的な CSPM 機能

* Microsoft Cloud Security Benchmark
* クラウド リソースのセキュリティ構成の継続的な評価
* 構成の誤りと弱点を修正するためのセキュリティに関するレコメンデーション
* セキュリティ スコア

![secure score](./images/securescore.png)

#### 有効化の手順

[Microsoft Defender for Cloud] - [環境設定] - [<目的のサブスクリプション>] - [セキュリティ ポリシー] を開き、[Microsoft cloud security benchmark] のトグルスイッチを [有効] に設定します。
![enable basic cspm](./images/defaultpolicy.png)

* [AWS の接続](https://learn.microsoft.com/ja-jp/azure/defender-for-cloud/concept-aws-connector)
* [GCP の接続](https://learn.microsoft.com/ja-jp/azure/defender-for-cloud/concept-gcp-connector)

#### 推奨事項への対応

推奨事項には基本的な情報として、検出された項目の重要度とともに検出項目の概要の説明、修復の手順、影響を受けるリソースが表示されます。内容を確認し、必要性を判断したうえで対処を行ってください。推奨事項によっては自動修復が利用できます。  
また、対処が不要な項目は、セキュアスコアに対する影響を除外し、将来検出されることがないように、[適用除外]を選択を行います。適用除外では除外するスコープと除外の有効期限、除外のカテゴリを選択することができます。除外の理由は将来見直しが必要になる可能性があるため、永続的に除外をするのではなく、半年や四半期ごとなど一定のタイミングで設定の見直しが行われるように除外の有効期限を設定することをお勧めしています。
![sample findings](./images/findings.png)

#### 注意が必要な検出項目

* コンピューティングとストレージのリソース間で一時ディスク、キャッシュ、データ フローを仮想マシンによって暗号化する必要がある  
Azure Disc Encription (ADE) で暗号化されている場合は正常、それ以外は異常（あるいは適用不可）と表示されます。これは現在の Defender for Cloud の制限で、将来的にはホストでの暗号化についても正常と判定されるようになる予定です。
格暗号化オプションによる暗号化されるデータの詳細な比較は[こちら](https://docs.microsoft.com/ja-jp/azure/virtual-machines/disk-encryption-overview#comparison)を参照してください。
どのデータを暗号化するかについて詳細な要件は存在しないケースが多いですが、SSE やホストでの暗号化で保護されたディスクはエクスポートや VM へのアタッチによりデータの読み書きが可能であるため、このような脅威シナリオを想定する必要がある環境では注意が必要です。

  * **サーバー側暗号化 (SSE)、ホストでの暗号化:** ディスクに物理的にアクセスされるようなシナリオからデータを保護することができますが、ディスクを VM にアタッチしたり、ディスクをエクスポートするようなシナリオからデータを保護することはできません。
  * **Azure Disk Encryption:** ディスクのアタッチやエクスポートなどシナリオからデータを保護することができます。ホストの CPU リソースを消費します。

  ディスクのエクスポートによる脅威を緩和策は、上記の ADE による暗号化の他、他アクセス可能なネットワークを制限することでも防ぐことができます。  
[参考：Azure Private Link を使用してマネージド ディスクに対するインポートおよびエクスポートのアクセスを制限する](https://docs.microsoft.com/ja-jp/azure/virtual-machines/disks-enable-private-links-for-import-export-portal)

* Azure SQL Database のパブリック ネットワーク アクセスを無効にする必要がある  
これは設定の背景を十分に理解する必要があります。  
  Azure SQL のセキュリティのベストプラクティスでは、 Azure SQL のアクセスはパブリック インターネットからのアクセスを拒否し、プライベート エンドポイント経由のアクセスのみに制限することです。多くのお客様の環境では Azure SQL のファイアウォールの機能でアクセス制御を行っているケースがあります。

  Azure SQL データベースではサーバーのレベルで複数のデータベース全体へのアクセスが拒否されていても、個別のデータベースのアクセスが先に評価されます。このため、サーバーレベルでアクセスを禁止している場合でも、各データベースの管理者が個別にデータベース レベルのファイアウォールを設定し、任意のネットワークからのアクセスを許可する可能性があります。もし Azure SQL のファイアウォールでネットワークアクセスを制限している場合、これらデータベース レベルのネットワーク アクセスも定期的に監査し、不要なネットワーク アクセスが許可されていないことを確認してください。

  [参考：Azure SQL Database と Azure Synapse の IP ファイアウォール規則]("https://learn.microsoft.com/ja-jp/azure/azure-sql/database/firewall-configure?view=azuresql")

  ![Azure SQL Firewall Rule](https://learn.microsoft.com/ja-jp/azure/azure-sql/database/media/firewall-configure/sqldb-firewall-1.png?view=azuresql)

### Defender CSPM

有償の CSPM プランです。
基本的な CSPM 機能に加えて、以下の機能を利用することができます。

* [クラウド セキュリティ エクスプローラー](https://learn.microsoft.com/ja-jp/azure/defender-for-cloud/how-to-manage-cloud-security-explorer)
* [攻撃パス分析](https://learn.microsoft.com/ja-jp/azure/defender-for-cloud/how-to-manage-attack-path)
* [マシンのエージェントレス スキャン](https://learn.microsoft.com/ja-jp/azure/defender-for-cloud/enable-vulnerability-assessment-agentless)
* [規制コンプライアンス](https://learn.microsoft.com/ja-jp/azure/defender-for-cloud/regulatory-compliance-dashboard)
* [ガバナンス ルール](https://learn.microsoft.com/ja-jp/azure/defender-for-cloud/governance-rules)
* [データ対応セキュリティ態勢](https://learn.microsoft.com/ja-jp/azure/defender-for-cloud/concept-data-security-posture)

CSPM 機能の一覧：[基本的な CSPM と クラウド セキュリティ態勢管理 (CSPM) の機能比較](https://learn.microsoft.com/ja-jp/azure/defender-for-cloud/concept-cloud-security-posture-management)

### Azure Policy とは?

Azure Policy は、セキュリティ標準による評価を実施し、大規模な環境でもコンプライアンス評価を自動的に行うことができる。ビジネスルールを Azure Policy として定義すると、Azure Policy がリソースのプロパティを定義されたビジネスルールと比較して、全体の状態を把握することができると考えてください。様々なリソースに対して許可する構成、許可しない構成、自動的な監査、許可しない構成のブロックなどを行うことができます。

## クラウド ワークロード保護 (CWP)

Microsoft Defender for Cloud を構成する2 つめの要素は "強化されたセキュリティ" で 「クラウド ワークロード 保護 (Cloud Workload Protection)」 ツールと呼ばれるものです。

これは様々なものを指しています。"強化されたセキュリティ" は単一の機能ではなく、異なった種類のリソースを保護するために設計された複数の高度なツールを含んでいます。Microsoft Defender for Endpoint による脅威対策と、Just In Time 管理や Adaptive Application Control などの高度なクラウド保護機能が統合されています。複数の異なるセキュリティ機能を統一的に管理する場所を提供し、ハイブリッドクラウドのワークロードに対応する機能を提供します。

* [Defender for API](https://learn.microsoft.com/ja-jp/azure/defender-for-cloud/defender-for-apis-introduction)
* [Defender for Servers](https://learn.microsoft.com/ja-jp/azure/defender-for-cloud/defender-for-servers-introduction)
* [Defender for Containers](https://learn.microsoft.com/ja-jp/azure/defender-for-cloud/defender-for-containers-introduction)
* [データベースの保護](https://learn.microsoft.com/ja-jp/azure/defender-for-cloud/quickstart-enable-database-protections)
* [Defender for App Service](https://learn.microsoft.com/ja-jp/azure/defender-for-cloud/defender-for-app-service-introduction)
* [Defender for Storage](https://learn.microsoft.com/ja-jp/azure/defender-for-cloud/defender-for-storage-introduction)
* [Defender for Key Vault](https://learn.microsoft.com/ja-jp/azure/defender-for-cloud/defender-for-key-vault-introduction)
* [Defender for Resource Manager](https://learn.microsoft.com/ja-jp/azure/defender-for-cloud/defender-for-resource-manager-introduction)
* [Defender for DNS](https://learn.microsoft.com/ja-jp/azure/defender-for-cloud/defender-for-dns-introduction)
* [Defender for DevOps](https://learn.microsoft.com/ja-jp/azure/defender-for-cloud/defender-for-devops-introduction)

アラートの一覧：[セキュリティ アラート - リファレンス ガイド](https://learn.microsoft.com/ja-jp/azure/defender-for-cloud/alerts-reference)

### コンピューティングに関連する Microsoft Defender

### Microsoft Defender for Cloud

Microsoft Defendr for Cloud はこれまで解説した通り、Azure が提供する CSPM と CWP の機能です。
過去には Azure Security Center や、Azure Defender (CWP 機能) と呼ばれていました。

### Microsoft Defender for Server

Microsoft Defender for Cloud のサーバー向け CWP 機能です。
2022 年 4 月から Plan 1 と Plan 2 の２つの価格体系で提供されるようになりました。従来の Microsoft Defender for Servers はプラン 2 に該当します。

* Microsoft Defender for Servers プラン 1
  * Microsoft Defender for Endpoint の自動展開、時間単位の課金

* Microsoft Defender for Servers プラン 2
  * (Plan 1 に加えて)
  * 500 MB / 日のログ分析が含まれる (全ノードの平均、テーブルの種類に制限がある)
  * 規制コンプライアンス
  * Just-In-Time VM アクセス
  * Adaptive Application Control
  * ファイル整合性の監視 (File Integrity Monitoring : FIM)
    など

プランの違いの詳細：  
[Microsoft Defender for Servers の概要](https://docs.microsoft.com/ja-jp/azure/defender-for-cloud/defender-for-servers-introduction)

[Microsoft Defender for Servers の価格](https://azure.microsoft.com/ja-jp/pricing/details/defender-for-cloud/)

>Microsoft Defender for Endpoint をサーバー OS で動かすことだけを Microsoft Defender for Server と呼ぶわけではありません。

2024 年 8 月の Log Analytics Agent の廃止に伴い、Defender for Server の機能は変更が予定されています。

* **OS レベルのアラート** - Microsoft Defender for Endpoint (MDE) を使用します。
* **3rd party** のアンチマルウェアによるアクション失敗の検出 - 廃止されます。
* **Adaptive Application Control** - Defender for Endpoitn と Windows Defender Application Control を使用する方法での置き換えが検討されています
* **エンドポイント保護の検出と推奨** - エージェント レスの実装で置き換えられ、Defender for Servers Plan 2 および Defender CSPM のコンポーネントとしてのみ提供される予定です。オンプレミスまたは Azure Arc 対応サーバーは対象外になります。
* **OSパッチ（システムアップデート）の欠落** - Azure Update Management で一般提供されています。
* **OS の設定不備** - 2024年4月にMDVMプレミアム機能との統合に基づく新バージョンが提供される予定です。このアップグレードの一環として、この機能は Defender for Servers Plan 2 のコンポーネントとしてのみ提供されます。
* **File Integrity monitoring (FIM)** - 2024年4月にMDEによる新バージョンが提供される予定です。現在の AMA を使用する機能は廃止される予定です。
* **500MB の無料ログ** - AMA を使用して利用することができます。

[参照：Microsoft Defender for Cloud - strategy and plan towards Log Analytics Agent (MMA) deprecation](https://techcommunity.microsoft.com/t5/microsoft-defender-for-cloud/microsoft-defender-for-cloud-strategy-and-plan-towards-log/ba-p/3883341)

### Microsoft Defender for Endpoint

EDR 機能です。エンタープライズネットワークによる高度な脅威の防止、検出、調査、および応答を支援します。
アンチマルウェア機能は次の項目の Microsoft Defender ウイルス対策 を使用しますが、サードパーティのアンチ マルウェアと組み合わせることもできます。

[Microsoft Defender for Endpoint Plan 1 and Plan 2](https://docs.microsoft.com/ja-jp/microsoft-365/security/defender-endpoint/defender-endpoint-plan-1-2?view=o365-worldwide)

> Microsoft Defender for Endpoint は Microsoft Defender for Cloud に統合されていて、 Microsoft Defender for Server の機能の一部として使われます。既に Defender for Ednpoint のライセンスをお持ちの場合には割引を受けることができます。  

[FAQ : Microsoft Defender for Endpoint のライセンスが既にある場合、Defender for Servers の割引を受けることはできますか?](https://docs.microsoft.com/ja-jp/azure/defender-for-cloud/enhanced-security-features-overview#if-i-already-have-a-license-for-microsoft-defender-for-endpoint-can-i-get-a-discount-for-defender-for-servers)

### Microsoft Defender ウイルス対策

Windows にビルトインされているアンチマルウェア機能です。 定義ファイルに基づいたマルウェアの検出や、一部挙動検知などの機能を備えています。
Azure の標準イメージから作成された Windows OS では既定で有効化されています。Defender for Endpoint を使わずに集中管理を行うためには Microsoft Endpoint Manager (MEM : クライアント OSの管理) や Microsoft Endpoint Configuration Manager (MECM) を使用することができます。

[Windows の Microsoft Defender ウイルス対策](https://docs.microsoft.com/ja-jp/microsoft-365/security/defender-endpoint/microsoft-defender-antivirus-windows?view=o365-worldwide)  
[MEM : Microsoft エンドポイント マネージャーの概要](https://docs.microsoft.com/ja-jp/mem/endpoint-manager-overview)  
[MECM : Configuration Manager とは](https://docs.microsoft.com/ja-jp/mem/configmgr/core/understand/introduction)

> Windows OS でウィルス対策だけを使用したい場合、Microsoft Defender for Server や Defender for Endpoint を有効化する必要はありません。
