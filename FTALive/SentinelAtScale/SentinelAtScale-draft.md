# Sentinel at Scale

## Microsoft Cloud Security Benchmark と NIST Cybersecurity Framework

リスクが効果的に管理された状態のためには包括的なセキュリティ コントロールが組織に展開されている必要があります。セキュリティ コントロールは多岐にわたるため、適切なセキュリティ運用が行われていなくて既存の指針がないような環境でセキュリティ コントロールを展開しようとすると、幅が広すぎて何から手をつければよいかわからない、という状況になります。

[Cybersecurity Framework (CSF)](https://www.nist.gov/cyberframework) は組織が実装すべきセキュリティ コントロールをコンパクトに整理していて、粒度が細かすぎず、荒すぎず、シンプルで使いやすいという特徴があります。このため、当初は重要インフラを保護することを目的に作られましたが、様々な組織で利用されるようになっています。日本でも [IPA が翻訳を公開](https://www.ipa.go.jp/files/000071204.pdf)しています。

組織のセキュリティ機能を Identify、Protect、Detect、Respond、Recover の 5 つのカテゴリーに分類していて、この順番に考えていくと効率的にセキュリティ機能を展開できるようになっています。セキュリティ運用が存在しない中でセキュリティ製品を展開する必要があったり、セキュリティ運用に自信がない場合の現状の把握など、多くの組織にお勧めできるフレームワークです。よく使われているセキュリティ標準（ISO 27001 / NIST SP 800-53 / CIS CSC など) へのマッピングを持つため、これらの標準を既に使っている場合には重ね合わせて使うこともできます。

![Framework Version 1.1](https://www.nist.gov/sites/default/files/styles/220_x_220_limit/public/images/2019/10/18/framework_functions_wheel.png?itok=1KLGPsFQ)

- **Identify**：ビジネス状況と資産を特定し、リスク アセスメントを実施する
- **Protect**：アクセス制御と保護を展開する
- **Detect**：イベントの収集、監視を行い脅威を検知するプロセスを展開する
- **Respond**：インシデント検知時の対応やコミュニケーションを展開する
- **Recover**: 復旧し、学びを反映する

Microsoft Sentinel はこの機能の中で主に `Detect` と `Respond` を担当する製品です。脅威検知製品を活用することで、特定の組織や資産に依存しない脅威の検知を行うことができますが、Identify の機能が適切であれば企業固有の資産に対する具体的な脅威を見つけることが期待できますし、Protect が適切であれば監視すべき攻撃面を小さくすることができるため、ログのコスト効率と脅威検知の効率の両方を高めることができます。逆に Identify が行われていない場合には目的のないログが大量に保存され、コストを圧迫したり、必要なログが保存されていないなどの問題が発生します。

継続的にメンテナンスされている展も重要で、現在発行されているCSF は 1.1 ですが、今後リリースされる [2.0](https://www.nist.gov/system/files/documents/2023/01/19/CSF_2.0_Concept_Paper_01-18-23.pdf) は上の 5 つの機能に加えて、Govern が追加されるようです。リスク管理は組織としての意思決定が重要ですが、この点が強調される形です。

Microsoft はクラウドを運用する際に必要となるセキュリティ コントロールを Microsoft Cloud Security Benchmark (MCSB) として公開しています。コントロールはメンテナンスしやすい適度な粒度になっているのでセキュリティ コントロールのベースとしてお勧めです。Defender for Cloud のセキュリティ態勢管理（CSPM - 無償機能）はこのコントロールに基づいて環境のリソースのセキュリティ状態を評価します。CSPM は CSF において `Identity` と `Protect` をカバーするため、Microsoft Sentinel と併せて使うと効果的です。Defender for Cloud については FTA Live でセッションがあるため、詳しく知りたい方はこちらにご参加ください。

[FTA Live - Defender for Cloud](https://github.com/Azure/fta-japan/blob/main/FTALive/DefenderForCloud/Pre-requisites.md)

## Microsoft Sentinel の概要

### Security Information and Event Management (SIEM)

SIEM は組織のセキュリティに関するログを収集し、正規化と関連付けを行うことで検索を可能にし、分析を行うための機能です。セキュリティに関係するログは OS やアプリケーション、ネットワーク機器など様々なソースから生成され、その生成元によって文字コードやレコードの形式、日付時刻の書式などが異なるため、SIEM はログを整形して関連付けを行い、検索可能な状態に管理します。ログは複数の仕組みによって分析され、攻撃パターンや異常を検知した場合にはセキュリティ アラートが作られます。

Microsoft Sentinel は発見されたセキュリティ アラートを `インシデント` としてライフサイクルを管理しながら調査を行うための機能を持っています。この機能の中には担当者をアサインし、調査の状況を記録するものや、ログの中から意味を持つ情報を `エンティティ` として抽出し、関係するセキュリティ アラートを可視化する機能が含まれています。

- 様々なソースに対応したデータの収集
- 巨大な容量をカバーする拡張性
- UEBA や AI による高度な分析、ビルトインのルールによる容易な分析

> **Log Analytics と KQL**  
 Microsoft Sentinel はデータストアとして Log Analytics ワークスペースを使用し、Kusto Query Language (KQL) でデータ検索や操作を記述します。
KQL は Log Analytics ワークスペースで Azure Monitor や Microsoft Sentinel のログを検索する他、リソース グラフで Azure リソースの状態を確認したり、Microsoft Defender Endpoit の高度な追及の中でハンティングを行うためにも使うことができます。

### Security Orchestration, Automation and Response (SOAR)

SOAR は繰り返し発生するセキュリティ オペレーションを自動化する機能です。担当者のアサインなど簡単なものであれば GUI を使用して設定することができますが、Logic Apps と連携して複雑なワーク フローを実行することができます。自動化を行うために特別なサーバーを構築、管理したり、自動化機能のための高額なライセンスや初期投資は必要ありません。  

利用シナリオの例：

- 発生したインシデントに対する担当者の割り当て
- 条件に応じた担当者へのメッセージ通知、Teams への投稿
- 侵害されたリソースのネットワーク隔離
- VirusTotal などの SaaS サービスと連携し、インシデントに含まれるエンティティ情報のエンリッチメント

Logic Apps は使用量に応じた課金と専用インスタンスの確認の２つのオプションがあります。  
[Logic Apps の価格](https://azure.microsoft.com/ja-jp/pricing/details/logic-apps/)

## ログのインジェスト

Microsoft Sentinel は Log Analytics ワークスペースで管理されるログに対して様々な機能を提供するソリューションなので Log Analytics ワークスペースの設計が必要になります。管理や検索を簡単にするためにワークスペースは 1 つであるほうが良いですが、ベストプラクティスには複数のワークスペースを検討するための主要な考慮点が記載されています。  
[Microsoft Sentinel ワークスペース アーキテクチャのベスト プラクティス](https://learn.microsoft.com/ja-jp/azure/sentinel/best-practices-workspace-architecture)

>意思決定ツリーを含む、より詳細な情報は次のドキュメントに記載されています。  
[Microsoft Sentinel ワークスペース アーキテクチャを設計する](https://learn.microsoft.com/ja-jp/azure/sentinel/design-your-workspace-architecture)

### Azure AD テナントが複数である場合

Sentinel ではデータコネクタ（後述）を使用して様々なリソースからログを取り込みますが、Azure AD のテナントが異なる場合、ログの取り込みができないものが存在します。このため、Azure AD テナントが複数ある場合にはそれぞれのテナントで Log Analytics ワークスペースを持つことを検討してください。

 [Azure Lighthouse](https://learn.microsoft.com/ja-jp/azure/lighthouse/how-to/onboard-customer) を使用するとサブスクリプションやリソースに対する権限を別のテナントのユーザーに委任することができるため、複数のテナントに跨った Sentinel  を 1 箇所から管理できるようになります。

### データのコンプライアンス要件や規制が存在する場合

地域によっては個人情報を域外に持ち出す場合に特別な前提条件や認定が必要になる場合があります。[EU の一般データ保護規則](https://blogs.microsoft.com/eupolicy/2021/05/06/eu-data-boundary/) が有名ですが、セキュリティ ログを保管する場合、これらの規制の影響を含む情報が保存される可能性があるため、ログの生成元と同じリージョンの Log Analytics ワークスペースにデータを保持した方が良い場合があります。

### データのアクセス権を分割する必要がある場合

複数のセキュリティ チームがあり、アクセスできるログを分離する必要がある場合、Log Analytics ワークスペースを分割する場合があります。例えば複数の子会社に跨ってセキュリティ監視を検討する場合などは会社ごとにワークススペースを持つことは要件としてもよくあります。リソースの管理者が自身のリソースのログにアクセスしたり、あるユーザーやグループが特定の種類のリソースのログを閲覧する権限が必要である場合、リソースに基づいた RBAC や、テーブル レベルのアクセス権を使って制御するという選択肢もあります。詳細については次のドキュメントを参照してください。

[リソースによる Microsoft Sentinel データへのアクセスを管理する](https://learn.microsoft.com/ja-jp/azure/sentinel/resource-context-rbac#explicitly-configure-resource-context-rbac)

### セキュリティに関係がない大量のデータが存在する場合

Microsoft Sentinel は Log Analytics ワークスペースに対して様々な機能を追加するため、Microsoft Sentinel のコストは概ね Log Analytics ワークスペースのデータの量に比例します。運用の監視などを行っており、既に Log Analytics で大量のログが存在しているような環境でワークスペースに対して Microsoft Sentinel を有効化すると、セキュリティ監視ではほとんど活用されない巨大なログに対して Microsoft Sentinel の課金が追加で発生することになるため、分割を検討したほうが良い場合があります。

[Azure Sentinel の価格](https://azure.microsoft.com/ja-jp/pricing/details/microsoft-sentinel/)

## コンテンツハブ

Microsoft Sentinel で利用する様々な機能は必要に応じて追加することができるようになっています。利用可能な機能はコンテンツハブで管理されており、機能の種類に応じて 8 種類に分類されています。

[Microsoft Sentinel コンテンツ ハブ カタログ](https://learn.microsoft.com/ja-jp/azure/sentinel/sentinel-solutions-catalog)

- **データコネクタ**：SIEM において最も重要なコンテンツで、様々なソースからデータを取り込みます。[データコネクタ] メニューに表示されます。
- **パーサー**：取り込まれたログを検索が容易になるように整形します。Log Analytics ワークスペースの中で使われます。
- **ブック**：ダッシュボード機能です。様々なソースのログの状態やアラートを可視化し、[ブック] メニューからアクセスすることができます。
- **分析ルール**：KQL でログを分析し、セキュリティ アラートやインシデントを生成する機能です。[分析ルール] メニューに表示されます。
- **ハンティング　クエリ**：インシデントの調査で組織が実行するクエリです。[ハンティング] メニューに表示されます。
- **Notebook**：Jupyter ノートブックです。ハンティングの手順と実施するアクションを１か所にまとめることができます。[ノートブック] に表示されます。
- **Watchlist**：ログの分析を行う際の検索条件や除外条件をテーブルとして保持するための機能です。[ウォッチリスト] に表示されます。
- **プレイブックとカスタムコネクタ**：SOAR 機能で使われる Logic Apps と、Logic Apps が必要なリソースにアクセスするためのコネクタです。[オートメーション] メニューからアクセスすることができるほか、Logic Apps のリソースから直接管理することもできます。

<!--
## データコネクタ

データコネクタは Sentinel の設計において最も重要で、ソースによって様々なものがあるため、

### ネイティブのログインジェスト

[Microsoft Sentinel データ コネクタ](https://learn.microsoft.com/ja-jp/azure/sentinel/connect-data-sources)

[Microsoft 365 Defender と Microsoft Sentinel の統合](https://learn.microsoft.com/ja-jp/azure/sentinel/microsoft-365-defender-sentinel-integration)

### Microsoft Monitoring Agent / Azure Monitor Agent

### Logstash

### ログ収集の順番
-->
## ログのコスト

Sentinel の利用料金は取り込むログの量に概ね比例しますが、コストをコントロールする機能が用意されています。コストが予測できない場合には[ログ取り込みの日次上限](https://learn.microsoft.com/ja-jp/azure/azure-monitor/logs/daily-cap) を設定して評価を行うと安全です。

[Azure Sentinel の価格](https://azure.microsoft.com/ja-jp/pricing/details/microsoft-sentinel/)

[コストを計画し、Microsoft Sentinel の価格と課金を理解する](https://learn.microsoft.com/ja-jp/azure/sentinel/billing?tabs=commitment-tier)

### 分析ログ

Log Analytics ワークスペースの主要なログです。対話型で高速な分析が可能ですが、90 日 (Microsoft Sentinel が有効化されていないワークスペースでは30日) 以上の保持には追加の料金がかかります。長期間保存する必要はあるものの、対話型で頻繁にアクセスする必要が無い場合には保持ポリシーを構成し、アーカイブすることができます。  
[データ保持とアーカイブの各ポリシーを Azure Monitor ログで構成する](https://learn.microsoft.com/ja-jp/azure/azure-monitor/logs/data-retention-archive?tabs=portal-1%2Cportal-2)

アーカイブされたログは[検索ジョブを実行](https://learn.microsoft.com/ja-jp/azure/azure-monitor/logs/search-jobs?tabs=portal-1%2Cportal-2)する、あるいは一時的に対話型で[検索可能なテーブルを復元](https://learn.microsoft.com/ja-jp/azure/azure-monitor/logs/restore?tabs=api-1)してログを検索することができます。

### 基本ログ (Basic ログ)

いくつかのログは基本ログをサポートしています。基本ログは分析ログに比べて安価で、検索を行ったデータに対して従量課金でコストが発生します。トラブルシューティングや監査の際に参照する可能性はあるものの、日常的な分析は行わない、セキュリティ上の価値の高くないログを安価に保持するために利用することが想定されています。  
[テーブルのログ データプランを Basic または Analytics に設定する](https://learn.microsoft.com/ja-jp/azure/azure-monitor/logs/basic-logs-configure?tabs=portal-1)

- ８日以降はアーカイブされる
- 実行できる [KQL 言語が制限](https://learn.microsoft.com/ja-jp/azure/azure-monitor/logs/basic-logs-query?tabs=portal-1#limitations)される
- 基本ログを構成できる[テーブルは限られている](https://learn.microsoft.com/ja-jp/azure/azure-monitor/logs/basic-logs-configure?msclkid=3c629183cfef11ecbd520ceb6ff77849&tabs=portal-1#when-should-i-use-basic-logs)
- クエリでスキャンされたデータに対して課金が発生する

<!--
#### Azure Data Explorer

#### ストレージアカウントなど

#### 取り込み時データ変換
-->

[Microsoft Sentinel のカスタム データ インジェストと変換](https://learn.microsoft.com/ja-jp/azure/sentinel/data-transformation)

## よく使うログの取り込み (ハンズオン)

Microsoft Sentinel では 100 を超えるデータコネクタが提供さていて、様々なソースからログの取り込みを行うことができます。Microsoft が提供する データコネクタ を使用し、よく使われるログを取り込んでインシデントの検知と対応の流れを学習します。

![Data ingestion methods](./images/data-ingestion.png)

### **Microsoft 365 Defender**

次のドキュメントに従って Microsoft 365 Defender を接続します。  
[Microsoft 365 Defender から Microsoft Azure Sentinel にデータを接続する](https://learn.microsoft.com/ja-jp/azure/sentinel/connect-microsoft-365-defender?tabs=MDE)

Microsoft 365 Defender のデータ コネクタは 3 種類の構成を含んでいます。

#### **インシデントとアラートを接続する**

「インシデントとアラートを接続する」を選択することで次の製品のインシデントとアラートを Sentinel に取り込むことができます。

- Microsoft Defender for Endpoint
- Microsoft Defender for Identity
- Microsoft Defender for Office 365
- Microsoft Defender for Cloud Apps
- Microsoft Defender のアラート
- Microsoft Defender 脆弱性の管理
- Microsoft Purview データ損失防止
- Azure Active Directory Identity Protection

接続されたインシデントの オープン / クローズなどの状態は双方向で同期されるため、Microsoft Sentinel をインシデント管理の集中ダッシュボードとして使うことができるようになります。このログは [無料データソース](https://learn.microsoft.com/ja-jp/azure/sentinel/billing?tabs=commitment-tier#free-data-sources) に含まれるため、Microsoft Sentinel のコストには影響を与えません。

#### **エンティティの接続**

「エンティティの接続」では [Microsoft Derfender for Identity](https://learn.microsoft.com/ja-jp/defender-for-identity/what-is) (オンプレミスの Windows Server Active Direcotry のセキュリティ監視を行う製品) と連携し、エンティティの情報を Sentinel に取り込みます。エンティティの情報は後程扱う UEBA 機能で処理され、ユーザーのふるまいに関するインサイトを提供します。UEBA 機能は独自のテーブルを作成するため、若干のコストがかかります。

#### **イベントの接続**

「イベントの接続」 では Microsoft Defender 製品の生ログを取り込みます。このログは課金対象となり、環境によってはそれなりのログの量になります。シナリオは[このドキュメント](https://learn.microsoft.com/ja-jp/azure/sentinel/microsoft-365-defender-sentinel-integration#advanced-hunting-event-collection)で紹介されていますが、次のような要求がある場合に活用することができます。

- Microsoft Sentinel が管理する様々なログと、Microsoft Defender 製品のログを関連付けて分析を行いたい
- Microsoft Defender 製品のログの保存期間を越えてログを保存しておきたい

### Defender for Cloud の連携

次のドキュメントに従って Defender for Cloud のアラートを接続します。  
[Microsoft Defender for Cloud アラートを Microsoft Sentinel に接続する](https://learn.microsoft.com/ja-jp/azure/sentinel/connect-microsoft-365-defender?tabs=MDE)

このデータコネクタによって接続されるのは Defender for Cloud のクラウド ワークロード保護機能です。主にクラウド ワークロードに対する脅威検知を行う機能で、Defender for Cloud の環境設定から有効化することができます。30 日間無料試用版を使うことができます。課金は保護するリソースによって異なり、例えば VM や App Service であればインスタンスごと、ストレージ アカウントやリソースグループの操作の監視であればトランザクション量に比例した課金になります。  
[強化されたセキュリティフィーチャーを取得するための Defender プランを有効にする](https://learn.microsoft.com/ja-jp/azure/defender-for-cloud/enable-enhanced-security)

### Azure Active Directory

次のドキュメントに従って Azure Active Directory のログを接続します。  
[Azure Active Directory (Azure AD) データを Microsoft Azure Sentinel に接続する](https://learn.microsoft.com/ja-jp/azure/sentinel/connect-azure-active-directory)

脅威が検知された場合、侵害範囲の特定や原因の調査のためにユーザー ディレクトリのログが必要になります。このため、ほとんどのシナリオで Azure Active Direcotry のログを収集しておくことを推奨しています。少なくとも次のログについては実際に内容を確認し、有効性について評価を行うことをお勧めします。

- サインイン ログ：ログインの成否、多要素認証の状況などユーザーによる対話型のサインインに関する情報を含みます。
- 監査ログ：ユーザーやグループの管理、ディレクトリに対する操作の情報などが含まれます。

>サインイン ログを取り込むためには Azure AD P1 または P2 ライセンスが必要になります。その他のログの取り込みには特別なライセンスは必要ありません。

### Azure Activity

次のドキュメントに従って Azure Activity のログを接続します。  
[新しい Azure アクティビティ コネクタにアップグレードする](https://learn.microsoft.com/ja-jp/azure/sentinel/data-connectors-reference#upgrade-to-the-new-azure-activity-connector)

Azure Activity はサブスクリプションやリソースに対する操作が行われた場合に記録されるログで、リソースの作成、変更や削除、権限の付与などの管理操作を記録しています。Azure 環境に対する操作の監査ログとしてもよく使われるため、Microsoft Sentinel に取り込んでおくことをお勧めしています。

## 仮想マシンの接続

仮想マシンを接続することで仮想マシンのパフォーマンス情報やログの情報を Microsoft Sentinel に取り込むことができるようになります。仮想マシンのこれらの情報を取り込むかどうかは組織の監視や監査の要件に寄りますが、仮想マシンが接続を行う仕組みはネットワーク機器などからログを収集するデータコネクタの前提条件になるため、いくつかの仮想マシンを接続し、ログが取り込まれる流れを理解しておくことをお勧めします。

### Microsoft Monitoring Agent と Azure Monitor Agent

仮想マシンを Microsoft Sentinel に接続するためには Microsoft Monitoring Agent (Log Analytics Agent とも呼ばれます) または Azure Monitor Agent を使用する必要があります。Microsoft Monitoring Agent はレガシーなエージェントで [2024 年 8 月の廃止が予定](https://learn.microsoft.com/ja-jp/azure/azure-monitor/agents/log-analytics-agent)されています。Azure Monitor Agent は Log Analytics Agent を置き換える新しいエージェントで、既に Log Analytics Agent の持つ様々な機能を一般提供でサポートしています。  
[Azure Monitor Agent がサポートするサービスと機能](https://learn.microsoft.com/ja-jp/azure/azure-monitor/agents/agents-overview#supported-services-and-features)

Microsoft Sentinel の機能に対する一般提供は限定的で、Windows のイベントログや Linux の Sylog を収集するようなシナリオは一般提供の機能でカバーすることができますが、Azure Monitor Agent を他のデータコネクタの中で使用し、Syslog や CEF のフォワード先として使うようなシナリオでは注意が必要です。利用するデータコネクタごとにサポートの可否を確認することをお勧めします。  
[Microsoft Sentinel の AMA 移行](https://learn.microsoft.com/ja-jp/azure/sentinel/ama-migrate)

### Windows のセキュリティ ログ

次のドキュメントに従って Windows イベントのログを接続します。  
[Microsoft Azure Sentinel を Azure、Windows、Microsoft、および Amazon サービスに接続する](https://learn.microsoft.com/ja-jp/azure/sentinel/connect-azure-windows-microsoft-services?tabs=SA%2CAMA#windows-agent-based-connections)

Azure Monitor Agent はデータ収集ルールに基づいて仮想マシンからログやパフォーマンス カウンタを収集します。Windows のイベントログは [XPath クエリを使用して](https://learn.microsoft.com/ja-jp/azure/azure-monitor/agents/data-collection-rule-azure-monitor-agent?tabs=portal#filter-events-using-xpath-queries)任意のイベントを抽出することができるため、一部のイベントを収集したい、といったシナリオに対応することができます。

この手順で収集されるイベントログは XML 形式のフィールドを解析する必要があるため、セキュリティ イベントの分析であれば [AMA  を使用した Windows セキュリティ イベント](https://learn.microsoft.com/ja-jp/azure/sentinel/data-connectors-reference#windows-security-events-via-ama)が適しています。
<!--
### Azure Arc


### Linux のログ

次のドキュメントに従って Linux の syslog を接続します。

### ワークブック

### XDR の確認 （ハンズオン）

## 脅威の発見

### エンティティ

[Microsoft Sentinel でエンティティを使用してデータを分類および分析する](https://learn.microsoft.com/ja-jp/azure/sentinel/entities)

### ASIM

[正規化と Advanced Security Information Model (ASIM)](https://learn.microsoft.com/ja-jp/azure/sentinel/normalization)

### Anomary

### UEBA

### Threat Intelligence

## ログの連携

### Windows VM

### Linux VM

### Azure Arc

### NVA - Log Analytics Agent

## ログの分析（ハンズオン）

### MS

[Microsoft セキュリティ アラートからインシデントを自動的に作成する](https://learn.microsoft.com/ja-jp/azure/sentinel/create-incidents-from-alerts)

### 組み込みの脅威分析ルール

[難しい設定なしで脅威を検出する](https://learn.microsoft.com/ja-jp/azure/sentinel/detect-threats-built-in)

### NRT

[Microsoft Sentinel でほぼリアルタイム (NRT) の分析ルールを使用し、脅威をすばやく検出する](https://learn.microsoft.com/ja-jp/azure/sentinel/near-real-time-rules)

### 大規模なデータセットに対する調査

[大規模なデータセット内のイベントを検索して調査を開始する](https://learn.microsoft.com/ja-jp/azure/sentinel/investigate-large-datasets)

[Microsoft Sentinel でエンティティ ページを使用してエンティティを調査する](https://learn.microsoft.com/ja-jp/azure/sentinel/entity-pages)

### 偽陽性の処理

[Microsoft Sentinel での擬陽性の処理](https://learn.microsoft.com/ja-jp/azure/sentinel/false-positives)

## SOAR

-->
