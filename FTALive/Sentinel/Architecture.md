#### [home](./welcome.md)  | [next](./.md)

<!-- 
持って帰るもの
・実装の時に考える要件にはどんなものがあるか、適切なアーキテクチャを選択することができる
・セキュリティ監視に必要な情報にはどんなものがあるか、適切に分析を行うことができる
-->


# Microsoft Sentinel アーキテクチャの計画
## ワークスペースの計画
[複数の Microsoft Sentinel ワークスペースを使用する必要がある場合](https://docs.microsoft.com/ja-jp/azure/sentinel/extend-sentinel-across-workspaces-tenants#the-need-to-use-multiple-microsoft-sentinel-workspaces)  
Microsoft Sentinel は Log Analytics ワークスペースを使用します。ワークスペースは少ないほど管理が容易になるため、可能な限り少数のワークスペースになるように設計を行います。ワークスペースの分割を考慮する主な要因は以下のとおりです。

- **`主権と規制のコンプライアンス`** - ワークスペースは、特定のリージョンに結び付けられます。 規制の要件を満たすためにデータを異なる Azure の地域に保持する必要がある場合は、別のワークスペースに分割する必要があります。
- **`データ所有権`** - データ所有権の境界 (たとえば、子会社や関連会社など) は、個別のワークスペースを使用するとより適切に線引きできます。	
- **`複数の Azure テナント`** - Microsoft Sentinel では、自身が所属する Azure Active Directory (Azure AD) テナントの境界内にある Microsoft と Azure の SaaS リソースからのデータ収集だけがサポートされています。 そのため、Azure AD テナントごとに個別のワークスペースが必要です。

これに対して次の要件の場合他の緩和策が有効な場合があります。  
- `詳細なデータ アクセスの制御` ログへのアクセスはテーブル レベルやデータを生成したリソース レベルの RBAC でアクセス制御を行うことができます。
- `詳細な保有期間の設定` ワークスペースのデータはテーブル レベルで保有期間を設定することができます。
- `課金を分割する` 使用状況のレポートを使用し、課金を計算することを検討してください。



Log Analytics ワークスペースをまたいだクエリ（クロス ワークスペース クエリ）を実行することもできますが、[Log Analytics ワークスペースの制限が存在する](https://docs.microsoft.com/ja-jp/azure/azure-monitor/logs/cross-workspace-query#cross-resource-query-limits)他、分析ルールでクロス ワークスペース クエリを実行する場合にも制限があり、[パフォーマンスの問題となる可能性があるため](https://docs.microsoft.com/ja-jp/azure/sentinel/extend-sentinel-across-workspaces-tenants#cross-workspace-analytics-rules)積極的な活用は推奨されていません。  
また、調査時に外部のワークスペース頻繁に参照するとクエリの記述が面倒になるため、頻繁に検索を行う可能性が高いログは１つのワークスペースにまとめることを検討してください。

追加の設計のヒントが次のドキュメントに記載されています  
[Microsoft Sentinel ワークスペース アーキテクチャを設計する](https://docs.microsoft.com/ja-jp/azure/sentinel/design-your-workspace-architecture)  

<details><summary>デシジョン ツリーを展開</summary><div>  

![Decision Tree](https://docs.microsoft.com/ja-jp/azure/sentinel/media/best-practices/workspace-decision-tree.png#lightbox)
</div></details>  

- SOC に含めないログは存在するか、そのログはデータの取り込みが 100GB / 日を上回るか
- 通信コストが高い、通信帯域が狭いネットワークを経由して大量のデータ転送が発生する

## アクセスの設計

### Microsoft Sentinel で主に使用される RBAC

| RBAC | プレイブックを<br>作成して実行する | Microsoft Sentinel<br>リソースを作成およ<br>び編集する | インシデントを管理する<br>(無視、割り当てなど) | データ、インシデント、<br>ブックなどのリソースを<br>表示する | ロールを割り当てる<br>リソースグループ | 組織のロール |
| - | - | - | - | - | - | - |
| Microsoft Sentinel 閲覧者 | - | - | - | ✔ |  |  |
| Microsoft Sentinel レスポンダー | - | - | ✔ | ✔ | Microsoft Sentinel の<br>リソースグループ | セキュリティ アナリスト |
| Microsoft Sentinel 共同作成者 | - | ✔ | ✔ | ✔ | Microsoft Sentinel の<br>リソースグループ | セキュリティ エンジニア<br>サービス プリンシパル |
| ロジック アプリの共同作成者 | ✔ | - | - | - | Microsoft Sentinel のリ<br>ソースグループまたは<br>プレイブックのリソースグループ | セキュリティ アナリスト<br>セキュリティ エンジニア |  

[Microsoft Azure Sentinel のアクセス許可](https://docs.microsoft.com/ja-jp/azure/sentinel/roles)


### リソース レベル / テーブルレベルのアクセス制御  
ワークスペースに蓄えられたログに対するアクセス権は、Microsoft Sentinel の RBAC に加えて、次のアクセス制御を追加することができます。特定のユーザーには見せたくない / 特定のユーザーに閲覧させたいという要件に対してはこれらのアクセス制御を検討してください。

[リソースのアクセス許可](https://docs.microsoft.com/ja-jp/azure/azure-monitor/logs/manage-access#resource-permissions)  
 リソースのアクセス許可またはリソースコンテキストを使用すると、ユーザーはアクセス権を持つリソースのログのみを表示できます。 ワークスペースのアクセス モードは、ユーザー リソースまたはワークスペースのアクセス許可に設定する必要があります。 Microsoft Sentinel のログ ページの検索結果には、ユーザーがアクセス許可を持っているリソースに関連するテーブルのみが含まれます。このアクセス制御はログに付与されたリソース ID によって行われるため、外部から送信されるログに対して適用するためには[明示的にログにリソース ID を付与](https://docs.microsoft.com/ja-jp/azure/sentinel/resource-context-rbac#explicitly-configure-resource-context-rbac)する必要があります。

[テーブル レベルの Azure RBAC](https://docs.microsoft.com/ja-jp/azure/azure-monitor/logs/manage-access#table-level-azure-rbac)  
テーブルレベルの RBAC では、他のアクセス許可に加えて、Log Analytics ワークスペースのデータをさらにきめ細かく定義できます。 この制御を使用すると、特定のユーザーやグループのみがアクセスできる特定のデータ型を定義できます。

### Lighthouse  
[エンタープライズ シナリオにおける Azure Lighthouse](https://docs.microsoft.com/ja-jp/azure/lighthouse/concepts/enterprise)  
Azure Lighthouse は異なる Azure AD テナントのユーザー（グループ、サービス プリンシパルも含む）に対して権限の委任を可能にするための仕組みです。委任されたユーザーは自分が所属する Azure AD の権限で委任元のリソースを管理することができ、各リソースが所属するテナントの Azure AD にサインインする必要はありません。複数の Azure AD テナントが存在する組織や、MSP が複数にサービスを提供している管理している環境で、管理を簡素化するために利用することができます。

委任を行うスコープはサブスクリプション レベルとリソース グループ レベルであり、管理グループや単体のリソースの権限を委任することはできません。また、委任できるロールは組み込みロールであり、カスタム ロールはサポートされていません。

[Azure Lighthouse の制限事項](https://docs.microsoft.com/ja-jp/azure/lighthouse/concepts/cross-tenant-management-experience#current-limitations)


## 価格に関する計画
Microsoft Sentinel を使用する際には Log Analytics に対するコストと Microsoft Sentinel に対するコストが発生します。
- [Log Analytics の価格](https://azure.microsoft.com/ja-jp/pricing/details/monitor/)
- [Sentinel の価格](https://azure.microsoft.com/ja-jp/pricing/details/microsoft-sentinel/)

どちらの料金体系にもコミットメントレベルが用意されており、大きなサイズのログを取り込む場合にはコミットメント レベルを使用すると割引された価格でデータを取り込むことができます。  
その他にも以下のような無料枠が用意されています。

- Microsoft 365 E5、A5、F5、G5 セキュリティを使用しているお客様はユーザー当たり１日 5MB のデータを無料で取り込むことができます。
- Defender for Servers Plan 2 が有効になっている VM １台当たり 1 日 500 MB のデータを無料で取り込むことができます。

次のドキュメントに Microsoft Sentinel でコストを削減する方法が記載されています。  
[Microsoft Sentinel のコストを削減する](https://docs.microsoft.com/ja-jp/azure/sentinel/billing-reduce-costs)

## アーキテクチャの例


# Microsoft Sentinel の SIEM 機能

## ログの収集
SIEM は様々なソースからのログを集約し、関連付ける機能を提供します。Microsoft Sentinel は Log Analytics に収集されたログを使用しますが、様々なデータソースからログを収集するためのコネクタを提供しています。コネクタはいくつかの方式があり、それに応じて展開方法に違いがあります。


### 診断設定ベースの接続
`追加のリソースは不要`  
Azure リソースが生成するリソース ログはほとんどの場合このコネクタが使われます。Azure Firewall や Application Gateway など様々な Azure リソースや、Azure AD のサインイン ログはこのカテゴリに分類されます。Azure リソースの「診断設定」メニューでインジェストするログを選択し、インジェストする Log Analytics ワークスペースを指定します。  

[Azure リソース ログの共通およびサービス固有のスキーマ](https://docs.microsoft.com/azure/azure-monitor/essentials/resource-logs-schema)

### API ベースの接続
`追加のリソースは不要`  
Azure 以外の SaaS サービスのデータ ソースを接続する場合に使われることが多く、サービスが Log Analytics の API ([Data Collector API](https://docs.microsoft.com/ja-jp/azure/azure-monitor/logs/data-collector-api)) を使用してデータをインジェストします。コネクタの設定には Log Analytics のワークスペース ID とキーが表示され、この情報をデータソースに設定することでデータのインジェストが開始されます。  
Microsoft の SaaS サービス、例えば Azure Active Directory Identity Protection などは [接続] ボタンが用意されており、ワンクリックで接続を行うことができます。

[データ ソースを Microsoft Sentinel データ コレクター API に接続してデータを取り込む](https://docs.microsoft.com/ja-jp/azure/sentinel/connect-rest-api-template)

### エージェント ベースの接続
`コンピューターにエージェントをインストールする必要がある`  
Windows と Linux のログを収集するためにはエージェントを使用します。エージェントには Log Analytics エージェントと Azure Monitor エージェントの２種類が存在します。今後新機能は Azure Monitor エージェントでのみ提供される予定で、Log Analytics エージェントは将来廃止予定のため、Azure Monitor エージェントを使用することが推奨ですが、現時点では Log Analytics エージェントでのみ使用できる機能があります。
例えば Defender for Cloud のサポートや、ファイルからログを読み込むファイルベースのログなどは Log Analytics エージェントでのみ一般提供されている機能であるため、しばらくは Log Analytics エージェントを使用しなければならない場合があります。

Log Analytics エージェントとAzure Monitor エージェントの併用はサポートされています。

[Azure Monitor エージェントの概要](https://docs.microsoft.com/ja-jp/azure/azure-monitor/agents/azure-monitor-agent-overview)  
[Azure Monitor エージェントでサポートされているサービスと機能](https://docs.microsoft.com/ja-jp/azure/azure-monitor/agents/azure-monitor-agent-overview?tabs=PowerShellWindows#supported-services-and-features)

- Windows エージェント

|  | 	Azure Monitor エージェント | Log Analytics<br>エージェント |
| - | - | - |
| サポートされている環境 | Azure<br>その他のクラウド (Azure Arc)<br>オンプレミス (Azure Arc)<br>Windows クライアント OS (プレビュー) | Azure<br>その他のクラウド<br>オンプレミス |
| 収集されるデータ | イベント ログ<br>パフォーマンス<br>ファイル ベースのログ (プレビュー) | イベント ログ<br>パフォーマンス<br>ファイル ベース ログ<br>IIS ログ<br>分析情報とソリューション<br>その他のサービス |
| サービスと<br>features<br>サポート対象 | Log Analytics<br>メトリックス エクスプローラー<br>Microsoft Sentinel  | VM insights<br>Log Analytics<br>Azure Automation<br>Microsoft Defender for Cloud<br>Microsoft Sentinel |

- Linux エージェント

|  | 	Azure Monitor エージェント | Log Analytics<br>エージェント |
| - | - | - |
| サポートされている環境 | Azure<br>その他のクラウド (Azure Arc)<br>オンプレミス (Azure Arc) | Azure<br>その他のクラウド<br>オンプレミス |
| 収集されるデータ | イベント ログ<br>パフォーマンス<br>ファイル ベースのログ (プレビュー) | 	syslog<br>パフォーマンス |
| サービスと<br>features<br>サポート対象 | Log Analytics<br>メトリックス エクスプローラー<br>Microsoft Sentinel | VM insights<br>Log Analytics<br>Azure Automation<br>Microsoft Defender for Cloud<br>Microsoft Sentinel |

これらのエージェントは特にオンプレミスの環境など、インターネットに直接接続できないコンピューターに対しては Log Analytics Gateway を使用してログのインジェストを行うことができます。
![Log Analytics Gateway](https://docs.microsoft.com/ja-jp/azure/azure-monitor/agents/media/gateway/oms-omsgateway-agentdirectconnect.png)
[インターネットにアクセスできないコンピューターを Azure Monitor で Log Analytics ゲートウェイを使って接続する](https://docs.microsoft.com/ja-jp/azure/azure-monitor/agents/gateway)

### カスタム ログの収集
`コンピューターにエージェントをインストールする必要がある`  
アプリケーションやサービスがイベントログではなくテキスト ファイルを使用したログを残す場合にはカスタム ログを使用してテキスト ファイルのログを収集することができる場合があります。カスタム ログの収集は Log Analytics エージェントによって行われるため、情報を収集するコンピューターには Log Analytics エージェントのインストールと構成が行われている必要があります。  

収集できるログには以下のような制限があり、詳細は参考リンクを参照してください。
- ログでは 1 行につき 1 エントリとするか、各エントリの先頭に指定の形式に一致するタイムスタンプを使用する必要がある
- 循環ログはサポートされず、ファイルは上書きされる必要がある
- ASCII または UTF-8 フォーマット

[Log Analytics エージェントを使用してカスタム ログ形式のデータを Microsoft Sentinel に収集する](https://docs.microsoft.com/ja-jp/azure/sentinel/connect-custom-logs?tabs=DCG)  
[Azure Monitor で Log Analytics エージェントを使用して テキスト ログを収集する](https://docs.microsoft.com/ja-jp/azure/azure-monitor/agents/data-sources-custom-logs)

### Syslog / Syslog を介した CEF
`環境に Linux サーバー (物理、VM) を準備する必要がある`  
Linux VM 上に構築されたセキュリティ製品や、アプライアンスなどのログを送信する際に使用されるコネクタです。エージェント ベースのコネクタで使用した Linux 用 Log Analytics エージェントを Linux マシンにインストールして Syslog を収集します。 

![Syslog agent](https://docs.microsoft.com/ja-jp/azure/sentinel/media/connect-syslog/syslog-diagram.png)


Linux 上に直接 Log Analytics エージェントをインストールしてログの収集を行うことができる他、フォワーダーを構成し、バックエンドの Linux にはエージェントをインストールせずにフォワーダーにのみ Log Analytics エージェントをインストールする構成を選択することもできます。

![Syslog forwarder](https://docs.microsoft.com/ja-jp/azure/sentinel/media/connect-syslog/syslog-forwarder-diagram.png)

[Syslog を使用して Linux ベースのソースからデータを収集する](https://docs.microsoft.com/ja-jp/azure/sentinel/connect-syslog)

[デバイスまたはアプライアンスの CEF 形式のログを Microsoft Sentinel に取得する](https://docs.microsoft.com/ja-jp/azure/sentinel/connect-common-event-format)

[ログ フォワーダーをデプロイして Syslog および CEF ログを Microsoft Sentinel に取り込む](https://docs.microsoft.com/ja-jp/azure/sentinel/connect-log-forwarder?tabs=rsyslog)

### Azure Functions と REST API
`Azure 上に Azure Functions を準備する必要がある`  
データ ソースがログを提供するための API を持ち、能動的に Microsoft Sentinel の API に対応していない場合にはこのカテゴリのコネクタを使用することになります。Azure 上に Functions でアプリケーションを構築し、データソースからはデータソースが提供する API を使用してログを取得し、Microsoft Sentinel に対しては API を使用してデータをインジェストします。

[Azure Functions を使用して Microsoft Sentinel をデータ ソースに接続する](https://docs.microsoft.com/ja-jp/azure/sentinel/connect-azure-functions-template?tabs=ARM)


[データ収集のベスト プラクティス](https://docs.microsoft.com/ja-jp/azure/sentinel/best-practices-data)


## ログの変換
- **Logstash** - Logstash はオープン ソースのデータ変換ツールで、様々なデータソースからデータを取り込み、変換やフィルタ処理を行い、様々なターゲットに格納する機能を持ちます。ワークスペースにデータをインジェストする前に不要なデータを取り除いたり、データを加工することができます。Logstash を動作させるためのコンピューターを準備する必要があります。  
![Log Stash Architecture](https://docs.microsoft.com/ja-jp/azure/sentinel/media/connect-logstash/logstash-architecture.png)  
[Logstash を使用して Microsoft Sentinel にデータ ソースを接続する(プレビュー)](https://docs.microsoft.com/ja-jp/azure/sentinel/connect-logstash)

- **取り込み時のデータ変換** - ワークスペースのテーブルに対して設定を行い、データインジェスト時にログのフィルタリングや変換を行う機能です。ワークスペースに対する設定のため追加のリソースは必要ありません。
[Microsoft Sentinel で取り込み時にデータを変換またはカスタマイズする (プレビュー)](https://docs.microsoft.com/ja-jp/azure/sentinel/configure-data-transformation)

## ログの管理
データソースの正常性はワークブック (Data collection health monitoring) や、専用のテーブル (SentinelHealth) で確認することができます。
- [データ コネクタの正常性を監視する](https://docs.microsoft.com/ja-jp/azure/sentinel/monitor-data-connector-health)

Log Analytics では最長 730 日間検索可能な形式でログを保存することができますが、さらに長期間保存したい場合にはいくつかのオプションがあります。
- [テーブル別に保持ポリシーとアーカイブ ポリシーを設定する](https://docs.microsoft.com/ja-jp/azure/azure-monitor/logs/data-retention-archive?tabs=api-1%2Capi-2#set-retention-and-archive-policy-by-table)  
- [Azure Monitor の Log Analytics ワークスペース データ エクスポート](https://docs.microsoft.com/ja-jp/azure/azure-monitor/logs/logs-data-export?tabs=portal#supported-tables)  
- [ロジック アプリを使用して Log Analytics ワークスペースから Azure ストレージにデータをアーカイブする](https://docs.microsoft.com/ja-jp/azure/azure-monitor/logs/logs-export-logic-app)  
- [長期的なログ保持のために Azure Data Explorer を統合する](https://docs.microsoft.com/ja-jp/azure/sentinel/store-logs-in-azure-data-explorer?tabs=adx-event-hub)





## ログの分析
ログの分析は Microsoft Sentinel の主要な機能の一つで、収集されたログを分析し、ルールに基づいてセキュリティ アラートを作成します。
アラートからは担当者のアサインとライフサイクルの管理を行うためのインシデントを作成することもできます。アラートを生成するための分析ルールは以下です。

###  Microsoft インシデントの作成規則
最初に活用すべき分析ルールです。これは Microsoft Defender for Cloud や Microsoft Defender for Identity など、Microsoft が提供するセキュリティ ソリューションからのアラートを処理し、インシデントを作成します。  
セキュリティ監視は分析ルールのメンテナンスと擬陽性アラートの戦いです。この分析ルールで選択することができるそれぞれのセキュリティ ソリューションは、Microsoft のセキュリティ エンジニアによって分析ルールがメンテナンスされているため、高品質なアラートを利用することができます。

### マルチステージ攻撃の検出 (Fusion) ルール
組織を対象としたサイバー攻撃は偵察から内部ネットワークでの永続化、データの持ち出しなど複数のステージを経由することが多く、セキュリティ監視ではソリューションを横断したログの分析をおこなう必要があります。Fusion は Microsoft Sentinel に接続されているアラートやログを自動的に分析、関連付けを行い、複数のステージに跨る攻撃を検出します。
この分析ルールは既定で有効になっており、接続されているログを自動的に分析します。

### スケジュール済みクエリルール
セキュリティ エンジニアが主にメンテナンスすることになる分析ルールです。KQL で検出ルールを記載しますが、ビルトインのテンプレートが用意されているので参考にすることができます。ビルトインのテンプレートはコネクタを作成する際に、そのデータソースに関連するものが表示されるため、コネクタ作成時に併せて有効化することもできます。
Microsoft Sentinel の UI にはコミュニティのリソースへのリンクも用意されています。

分析ルールでは作成時にエンティティを指定することができます。エンティティは分析ルールで検出されるレコードに対して特定の意味を持たせることを意味し、ユーザー名やコンピューター、IP アドレス、URL といった意味を持つ列を指定することができます。この情報はアラートやインシデントの相互の関連付けに利用されます。例えばあるアカウントが関連するインシデントが複数ある場合、インシデントの分析画面では関連するインシデントが視覚的に表現されます


## 脅威情報の活用

セキュリティ運用には一般的に何らかの脅威情報を活用します。
以下は [NIST SP800-150](https://csrc.nist.gov/publications/detail/sp/800-150/final) による分類と要約です。

- `脅威インテリジェンス レポート` - 一般に、TTP、攻撃主体、標的とされているシステムと情報の種類、その他の脅威関連情報を記述した文書で、組織の意思決定プロセスに必要な文脈を提供するために、集約、変換、分析、解釈、または強化された脅威情報です。


- `セキュリティ アラート` - セキュリティ・アラートは、アドバイザリー、脆弱性ノートとも呼ばれ、現在の脆弱性、悪用、その他のセキュリティ問題を記述した、通常人間が読む技術的な通知です。


- `TTP (Tactics, Techniques, Procedures)` - 戦術、テクニック、手順攻撃者の行動を記述するもので、Tactics はハイレベルな行動、Techniques は行動の詳細な記述、Procedures はさらに低レベルで非常に詳細な記述です。


- `脅威インジケーター` - 攻撃が差し迫っていること、現在進行中であること、または侵害が既に発生している可能性を示唆する技術的な成果物や観測値を指します。IP アドレス、URL、DNS名、メールの件名などが含まれます。


- `ツールの構成` - 脅威情報の自動収集、交換、処理、分析、および使用を支援するツール（機構）の設定と使用に関する推奨事項です。


### TTP (Tactics, Techniques, Procedures)
分析ルールの作成は大まかに次の流れになります。
1. 攻撃者がどのような活動を行うか
2. その結果どのような痕跡を残しうるか
3. 痕跡を記録しうるログは何か
4. ログから痕跡を検出するためにはどのようなルールが必要か

1 と 2 が非常に重要で、分析ルールの運用を行いたいが、攻撃を想定することができないため効果的な分析ルールが書けないという問題が発生します。
TTP が提供する攻撃のテクニックを参照することで攻撃の具体的な内容や検出の方針関する情報を入手することができます。[MITRE ATT&CK](https://attack.mitre.org/) では TTP の他に、攻撃者グループの情報も公開しています。この情報には攻撃者グループが使用する TTP が列挙されているため、特定の攻撃者を想定した一連のシナリオで攻撃の開始から目的の達成までの流れをシミュレートすることができます。実際の攻撃者が同じ TTP を使用するとは限りませんが、数多くの TTP の中から意図をもって特定の TTP を調べていくことができるため、集中して学習しやすいというメリットがあります。


### 脅威インジケーター
脅威インジケーターは Sentinel の分析とオートメーションと連携します。Sentinel では脅威インテリジェンス プラットフォームと、STIX、TAXII 脅威インテリジェンス フィードに対するコネクタを作成することができ、これらのソースからリスクの高い IP アドレス、ドメイン名、メールの情報といった脅威インジケーターを取り込むことができます。様々なソースから取り込まれたログデータには様々なエンティティ情報が含まれていますが、この脅威インジケーターと比較することでリスクの高いログを検出することができます。
が取り込まれた脅威インジケーターに対応したビルトインのテンプレートが複数用意されてます。


何かのアラートに含まれるエンティティについてリスク情報を確認したい場合には、エンリッチメント処理ソースを使用してエンティティの情報を調べ、インシデント対応の負荷を軽減することができます。[RiskIQ](https://www.riskiq.com/products/passivetotal/) や [Virus Total](https://developers.virustotal.com/v3.0/reference) などのエンリッチメント処理ソースは与えられたエンティティ情報に対してレピュテーション情報を返す API を持つため、これらの追加情報に基づいてインシデントを自動的に処理したり、アナリストがアサインされる前にエンティティに関する情報を付与するなどの自動化を行うことができます。
インシデントに対してエンリッチメントを行うビルトインのプレイブック テンプレートが用意されています。  
[Microsoft Sentinel への脅威インテリジェンスの統合](https://docs.microsoft.com/ja-jp/azure/sentinel/threat-intelligence-integration)




# Microsoft Sentinel の SOAR 機能


## オートメーション機能
- プレイブック - Logic Apps を使用して自動化された処理を実行します。実行のトリガーにはアラートとインシデントの両方を使用することができます。インシデント トリガーで起動された Logic Apps はインシデントに含まれるすべてのアラートを受け取ります。
- オートメーション ルール - インシデントが作成された際に実行される自動処理です。条件に応じた担当者のアサインやインシデントの状態の変更を行うことができる他、インシデント トリガーのプレイブックを実行することもできます。

マルチテナントの環境でプレイブックを使用する場合、顧客テナントに作成されたプレイブックをインシデント トリガーで呼び出すためには [Azure Security Insights] アプリに対する [Microsoft Sentinel Automation 共同作成者] ロールを委任する必要があります。
![Multi Tenant Automation](https://docs.microsoft.com/ja-jp/azure/sentinel/media/automate-incident-handling-with-automation-rules/automation-rule-multi-tenant.png)
[マルチテナント アーキテクチャにおけるアクセス許可](https://docs.microsoft.com/ja-jp/azure/sentinel/automate-incident-handling-with-automation-rules#permissions-in-a-multi-tenant-architecture)


## オートメーションのユースケース
- **エンリッチメント** - インシデントが作成された際に、エンジニアがアサインされる前にエンティティの調査を自動実行し、追加のコメントをインシデントのコメントに追加します。

- **双方向の同期** - 他のチケットシステムがあるような場合にSentinel のインシデントをチケットシステムに連携します。

- **オーケストレーション** - インシデントが作成された際に Teams や Slack などに通知を行い、ワークフローを実行してユーザーの応答に従って自動処理を実行します。

- **レスポンス** - 頻繁に発生する、対応が決まっているインシデントに対して自動的に処理を実行し、迅速に脅威に対処します。



# 参考リンク

[Microsoft Cybersecurity リファレンス アーキテクチャ](https://docs.microsoft.com/ja-jp/security/cybersecurity-reference-architecture/mcra)



[Azure Data Explorerのクエリを記述する(KQL)](https://docs.microsoft.com/ja-jp/azure/data-explorer/write-queries)
