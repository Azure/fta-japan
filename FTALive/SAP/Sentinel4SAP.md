# FTA Live - SAP® アプリケーション用の Microsoft Sentinel ソリューション
<!-- 全体１時間半 -->
## Microsoft Sentinel の概要

SAP® アプリケーション用の Microsoft Sentinel ソリューション (以下 SAP ソリューション) は Microsoft Sentinel の一部として動作するため、最初に Microsoft Sentinel の概要と、基本的な考慮事項を紹介します。

![Cyber Security Framework](./images/cyber-security-framework.png)

<!-- 概要、ログのインジェスト、コンテンツハブを紹介 -->

[Sentinel at Scale ドキュメント](https://github.com/Azure/fta-japan/blob/main/FTALive/SentinelAtScale/SentinelAtScale-draft.md)

## SAP ソリューションの特徴

脅威を検出するためにはアプリケーションに固有の特徴を考慮する必要があります。例えば SAP アプリケーションでは少なくとも以下のことを知っておく必要があります。

- SAP アプリケーションに対する知識
- SAP アプリケーションに対してどのような攻撃テクニックがあるか
- SAP アプリケーションはどのようなログを生成するか
- ログをどのように分析すれば脅威を見つけることができるか

これらの全てを習熟している組織は稀ですが、SAP ソリューションを利用することで、多くの部分をカバーすることができ、速やかに脅威の検出を行うことができます。

![SAP Diagram](./images/SAP-diagram.png)

### 特別なデータ コネクタ

SAP ソリューションでは SAP アプリケーションからログを収集するために特別なデータ コネクタが用意されています。データコネクタはログの生成元からログを抽出し、Sentinel のデータ ストアに連携するための仕組みです。SAP ソリューションのデータコネクタは Linux 上で動作するコンテナとして設計されていて、オンプレミス、クラウドを問わず様々な場所で展開することができます。

SAP アプリケーションは複数の重要なログを生成しますが、データコネクタなこれらのログを定期的に収集し、分析しやすい形式に変換しながら、Microsoft Sentinel のデータストアに格納します。

### 専用の分析ルール

SAP アプリケーションの脅威を発見するためには、SAP アプリケーションの仕組みに対する知識と、 その仕組みを悪用した攻撃の知識の両方の知識が必要になります。SAP ソリューションには脅威を発見するための分析ルールが数多く含まれているため、セキュリティ監視の運用が成熟しておらず分析ルールのメンテナンスを行うノウハウが蓄積されていない組織でも、ソリューションを展開するだけで速やかにセキュリティ監視を開始することができます。

SAP アプリケーションは複雑で、様々な分析の側面を持っています。例えば特権を持つ重要なユーザーや重要な意味を持つトランザクションなど運用において比較的頻繁に変更される可能性があり、この変更に伴い分析ルールも更新される必要があります。SAP ソリューションではこのように日々変化する分析すべき対象を Watchlist という特別なテーブルでカスタマイズすることができます。これによりアナリストは分析ルールの開発に集中することができ、オペレータは複雑な分析ルールに立ち入らずに、更新された監視対象をメンテナンスすることができるように設計されています。

## SAP ソリューションの展開

### SAP の構成

SAP環境の前提条件

[SAP® アプリケーション用の Microsoft Sentinel ソリューションをデプロイするための前提条件](https://learn.microsoft.com/ja-jp/azure/sentinel/sap/prerequisites-for-deploying-sap-continuous-threat-monitoring#create-and-configure-a-role-required)

- サポートされているSAPバージョン：SAP_BASIS バージョン 731以降を推奨
- SAP データコネクター接続用のSAP NetWeaver RFC SDK 7.50 [こちらからダウンロード](https://me.sap.com/notes/2573790)

以下の手順は全てSAP環境で実施します。

- ロールを作成
  - SAP データコネクタが SAP システムに接続できるようにするためにロールを作成します。
    - CR:NPLK900271 (K900271.NPL, R900271.NPL) をデプロイするか、[MSFTSEN_SENTINEL_CONNECTOR_ROLE_V0.0.27.SAP ファイル](https://github.com/Azure/Azure-Sentinel/tree/master/Solutions/SAP/Sample%20Authorizations%20Role%20File)からロールの承認を読み込んで作成。
    - SAP Basisのバージョン(740 or 750以降)によって追加で[SAP から追加情報を取得する (省略可能)](https://learn.microsoft.com/ja-jp/azure/sentinel/sap/prerequisites-for-deploying-sap-continuous-threat-monitoring#retrieve-additional-information-from-sap-optional)のCRをデプロイ。※「省略可能」と記載がありますが、適用してください。

- CR の適用

[SAP Change Request をデプロイして認可を構成する](https://learn.microsoft.com/ja-jp/azure/sentinel/sap/preparing-sap)  

- SAP 環境に対象のCRをダウンロードして展開します。
  - 各 CR は、2つのファイル (1 つは K で始まり、もう 1 つは R で始まります) で構成されていることに注目してください。
  - 移送ディレクトリ(/usr/sap/trans)にcofilesとデータファイルをコピーします。  
- CR をインポート(T-cd: STMS_IMPORT)。
- ロールの構成
  - CR:NPLK900271 でデプロイした場合、SAP 環境に "/MSFTSEN/SENTINEL_CONNECTOR" というロールが作成されます。
  - T-cd: PFCG から当該ロールのプロフィルを生成する必要があります。
- ユーザの作成
  - SAP 環境上にSentinel 接続用のユーザを作成します。（ユーザ名は任意でOK）
  - 上記で作成した「ロール名 /MSFTSEN/SENTINEL_CONNECTOR」を当該ユーザへ割り当てます。

### データコネクタの展開

SAP アプリケーションに接続し、ログを収集するためのデータコネクタを展開します。

[SAP データ コネクタ エージェントをホストするコンテナーをデプロイして構成する](https://learn.microsoft.com/ja-jp/azure/sentinel/sap/deploy-data-connector-agent-container?tabs=managed-identity)

- Linux マシンの準備
  - データコネクタ エージェントを展開するための Linux マシンを準備します。Linux マシンは Azure 上の VM でも、オンプレや他クラウドで動作する物理 / 仮想マシンでも問題ありません。
    - Ubuntu 18.04 以降
    - SLES バージョン 15 以降
    - RHEL バージョン 7.7 以降

- KeyVault の作成
  - SAP アプリケーションに接続するための資格情報を保存する KeyVault を作成します。
  - KeyVault へのアクセスはシステム割り当てマネージド ID (Azure VM)、または登録済みアプリケーション サービスプリンシパル(Azure VM 以外)により制御されます。

- データコネクタのデプロイ
  - Linux マシンに [SAP NetWeaver SDK](https://me.sap.com/swdcproduct/%20_APP=00200682500000001943&_EVENT=DISPHIER&HEADER=Y&FUNCTIONBAR=N&EVENT=TREE&NE=NAVIGATE&ENR=01200314690100002214&V=MAINT&TA=ACTUAL&PAGE=SEARCH/SAP%20NW%20RFC%20SDK) を転送します。
  - Kickstart スクリプトを実行します。
    - Kickstart スクリプトの中で、接続する SAP アプリケーションや KeyVault を指定します。
  - データコネクタ用のコンテナが自動的に起動されるように構成します。

**関連情報**

[Microsoft Sentinel の SAP データ コネクタ エージェントを更新する](https://learn.microsoft.com/ja-jp/azure/sentinel/sap/update-sap-data-connector)

## Microsoft Sentinel の構成

Microsoft Sentinel で SAP アプリケーション用のソリューションを展開します。

- 分析ルールの展開:  
  分析ルールは集約されたログの中からセキュリティ上意味のあるログを見つけ出し、セキュリティ アラートを作成するための仕組みです。検出されたセキュリティ アラートはセキュリティ インシデントを作成することもできます。セキュリティ インシデントは担当者を割り当てて、クローズまでのライフサイクルを管理するための枠であり、調査を効率的に行うための UI や、調査状況を記録するための機能が用意されています。  
  次のグループに従って、既定で 50 種類以上の分析ルールが提供されています。

  - 初期アクセス
  - データ窃盗
  - 永続化
  - SAP のセキュリティ メカニズムを回避する試み
  - 疑わしい特権操作
  
  分析ルールの一覧は次のドキュメントに記載されています：  
  [組み込みの分析ルール](https://learn.microsoft.com/ja-jp/azure/sentinel/sap/sap-solution-security-content#built-in-analytics-rules)

- Watchilist の構成:  
  分析ルールの中には、特定のシステムを対象として監視を行ったり、重要なプログラムやユーザー、トランザクションなど特定のプロセスやサブジェクトを対象として分析を行うものがあります。SAP ソリューションではこれらの分析の条件を Watchlist としてルールの外部に切り出しています。  Watchlist を使用することで、分析ルールを直接変更することなく、分析ルールの検知対象や、除外の条件をメンテナンスすることができます。  
  従来分析ルールのメンテナンスには KQL の深い知識が必要でしたが、簡単なメンテナンスであれば KQL の知識を持たない担当者でも簡単に検知のメンテナンスができるようになりました。  
  SAP の次の側面をコードを変更せずにカスタマイズすることができるようになります：
  - 監視対象の / 監視から除外する SAP システム、ネットワーク、ユーザー
  - 重要な ABAP プログラム、トランザクション、関数モジュール、プロファイル、テーブル、ロール
  - 古いプログラムと関数モジュール、FTP サーバー
  - システムパラメーター、クリティカルな認可オブジェクト
  SAP - クリティカルな認可オブジェクト

  [使用可能なウォッチリスト](https://learn.microsoft.com/ja-jp/azure/sentinel/sap/sap-solution-security-content#available-watchlists)

- ワークブックの展開：
  SAP アプリケーションに関連するセキュリティ イベントを可視化するためのダッシュボードとして 4 つのワークブックが用意されています。

  - 監査ログ ブラウザ
  - 不審な特権を使用したオペレーション
  - SAP のセキュリティ機構のバイパスを試みるアクセス
  - SAP に対する永続化、大量のデータ持ち出し

**関連情報**  
[SAP® アプリケーション用の Microsoft Sentinel ソリューション: セキュリティ コンテンツ リファレンス](https://learn.microsoft.com/ja-jp/azure/sentinel/sap/sap-solution-security-content#available-watchlists)

## Sentinel for SAP の運用

### インシデント対応

SAP アプリケーションに対して発生する可能性のある脅威のシナリオと、その際の対応について、いくつかの例を紹介します。

#### シナリオ１. 特権ユーザ（Privileged Users）の利用と監視
  
ほとんどのセキュリティ インシデントでは攻撃者は高権限のユーザーを使用してシステムをコントロールします。広く知られているビルトイン アカウントはまず狙われるアカウントなので監視の対象にします。その他にも運用で使われる高権限アカウントがあれば、その使用を追跡する必要があります。  
システム管理権限を保有するいくつかのユーザで SAP システムにログインします。これらのユーザは、SAP システム内で全ての操作が実行可能な高権限プロファイル「SAP_ALL」を保有するユーザです。

1. SAPシステムに以下のユーザで順番にログインします。  

    - SAPシステムにおけるスーパーユーザー「SAP*」  
      ※SAP のインストール時に作成される特別なユーザー
    - ABAPディクショナリの管理ユーザ「DDIC」  
      ※SAP のインストール時に作成される特別なユーザー
    - 一般ユーザ（ダイアログユーザ）に権限プロファイル「SAP_ALL」を付与したユーザ「BPINST」
    - これらのユーザーは、Watchlist `SAP - Privileged Users` で管理されています。

2. Microsoft Sentinel でユーザーのログインを記録するログを確認します。このログは `ABAPAuditLog_CL` というテーブルに格納されます。このテーブルはさらに SAPAuditLog という関数でエンリッチされ、分析ルールで参照されます。

3. 特権ユーザーのログインは分析ルール `SAP - Sensitive Privileged User Logged in` によって定期的に分析されます。  
  この分析ルールは Watchlist  `SAP - Privileged Users` に記載されたユーザーのログインがあった場合にインシデントを生成します。

4. インシデント `SAP - Sensitive Privileged User Logged in` が生成されていることを確認します。  
  インシデントには関連するエンティティとしてログインを行ったユーザー、コンピューター、IP アドレス、SAP システムの情報が含まれます。

#### シナリオ２. 機密性の高いトランザクション（Sensitive Transactions）の実行と監視  

システム管理者を装った悪意のあるユーザが、システム管理権限（SAP_ALL, S_A.SYSTEM）を保有する「BPINST」で SAP システムへログオンします。このユーザが SAP システム上でシステム管理者が実行するトランザクションコードを実行します。システム 管理系のトランザクションコードは重要な変更を示唆するため、セキュリティ監視の対象となります。
  
  1. SAP システム上で、システム管理者による操作が想定されるトランザクションコード「SM19, SM20, SE38, SE37, RZ10, RZ11」を実行します。  それぞれのコードは以下の意味を持ちます。
      - T-cd:SM19を実行して監査ログの設定を無効化しようとしています。監査ログが記録されなくなることで SAP システム上で発生するトランザクションの履歴（監査証跡）が残らなくなってしまいます。
      - T-cd:SM20を実行して監査ログに記録されている[推奨される監査カテゴリ](https://learn.microsoft.com/ja-jp/azure/sentinel/sap/configure-audit)に示されるようなメッセージIDに該当する操作（ダイアログログオン、RFC/CPICログオン、RFC汎用モジュール呼出、トランザクション開始、レポート開始、ユーザマスタ変更など）を盗み見ることで、例えば外部システムとの連携情報など SAP システム以外のシステムとの接続情報が盗聴される可能性があります。
      - T-cd:SE38 (ABAPエディター)を実行して、例えば財務会計に関連したレポートプログラム（RFBVOR00 – 会社間取引の一覧、RFBUST10 – 会社間振替転記）を実行してグループ会社間の伝票明細レベルの取引状況や会社間取引の自動転記処理などが実行されることで、企業の決算に関わる重大なインシデントになる可能性があります。
      - T-cd:SM37(汎用モジュールビルダー)を実行して、悪意のある汎用モジュールをプログラミングされてしまう可能性があります。
      - T-cd:RZ10(プロファイルパラメータ変更)、RZ11(プロファイルパラメータ更新)を実行して、SAP システム全体の動作を管理する重要な設定値を変更し、システムの安定稼働に重大なダメージを与えたり（オンライン中にSAPシステムを停止したり、起動できなくしたり・・）、ダイアログユーザのパスワード入力の失敗回数によりアカウントのロックを制御するプロファイルパラメータ（login/fails_to_user_lock）を意図的に操作することにより、ユーザが SAP システムにアクセスできなくなる可能性があります。
      - これらのトランザクションコードは、Sentinel Workspace上の Watchlist `SAP - Sensitive Transactions` で管理されています。

  2. SAP システム上で、SM20を実行し SAP 監査ログに上記で実行したトランザクションコードが記録されていることを確認します。

  3. Microsoft Sentinel でユーザーのログインを記録するログを確認します。このログは `ABAPAuditLog_CL` というテーブルに格納されます。
  4. 分析ルール `SAP - Execution of a Sensitive Transaction Code` が 5 分ごとに分析を実行しています。
    この分析ルールは Watchlist `SAP - Sensitive Transactions` に記載されたトランザクションが記録された場合インシデントを生成します。

  5. 分析ルールがトランザクション コードを発見すると、インシデント `SAP - Execution of a Sensitive Transaction Code` が生成されます。

  6. 生成されたインシデントは関連するエンティティの情報をもちます。今回のトランザクションを実行したユーザーの他、過去に発生した同一のエンティティを持つインシデントは同じ UI から調査を行うことができます。

#### シナリオ３. 機密性の高いテーブル（Sensitive Tables）の閲覧と監視

SAP システムには機微な情報を格納するテーブルがあります。通常これらのテーブルはアプリケーションが利用しますが、攻撃者は興味のある情報をてっとり早く参照するために直接テーブルを参照することがあります。SAP ソリューションは機微なテーブルへのアクセスを監視することができます。  

システム管理権限を保有するユーザ「BPINST」がSAPシステム上でログオンデータを管理するテーブル「USR02」にアクセスし、特定のユーザの最終ログオン日時やパスワードのハッシュ値などを読み取る（窃盗）可能性があります。また、従業員の基本給を管理するテーブル「PA0008：HR Master Record」へアクセスし、給与データを閲覧され従業員の個人データが漏洩する可能性があります。

1. SAP 上で、トランザクションコード「SE38」を実行しABAPプログラム「/1BCDWB/DBUSR02」を実行し、ユーザのログオンデータを管理するテーブル「USR02」へアクセスします。  
このテーブルには最新のログオン日次とパスワードのハッシュが含まれています。

2. SAP 上で、トランザクションコード「SE16」を実行し、テーブル「PA0008」へアクセスします。  
このテーブルには従業員の基本給の情報が管理されています。

3. 機微なテーブルの情報は Watchlist `SAP - Sensitive Tables` で管理されています。

4. 機密性の高いテーブルへの直接アクセスは分析ルール `SAP - Sensitive Tables Direct Access By RFC Logon` によって分析が行われ、インシデントが生成されます。

#### シナリオ４. 機密性の高いプログラム（Sensitive ABAP Programs）の実行と監視

ABAP プログラムは様々な処理を実行し、例えば変更文書オブジェクトの履歴操作（ログの削除）はABAPプログラムから実行されます。ビジネスデータ（オブジェクト）の変更や更新を記録・管理する「変更文書」にアクセスし、企業の監査に関わる重要なビジネスログが削除される可能性があります。

1. SAP 上で、トランザクションコード「SE38」を実行しABAPプログラム「RSCDOK99」を指定し、変更文書の削除プログラムを実行します。この操作により監査に利用される受注伝票オブジェクト「VERKBELEG」の変更文書が削除されます。

2. これらのトランザクションコードは、Sentinel Workspace上の Watchlist `SAP - Sensitive ABAP Programs` で管理されています。

3. 分析ルール `SAP - Execution of a Sensitive ABAP Program` が 重要な ABAP プログラムの実行を監視していて、インシデントが生成されます。

**関連情報**  
[Microsoft Sentinel での SAP 監査を有効にして構成する](https://learn.microsoft.com/ja-jp/azure/sentinel/sap/configure-audit?source=recommendations)

[Microsoft Sentinel で SAP HANA 監査ログを収集する（プレビュー）](https://learn.microsoft.com/ja-jp/azure/sentinel/sap/collect-sap-hana-audit-logs)

- SAP HANA データベースの監査ログを Syslog で構成している場合は、Syslog ファイルを収集するように Log Analytics エージェントも構成する必要があります。
- SAP ノート 0002624117 の説明に従って、Syslog を使用するように SAP HANA 監査ログ証跡が構成されていることを確認します。

## RISE with SAP と Sentinel 連携

### SAP 認定

SAP ソリューションは、 SAP S/4HANA®Cloud, private edition (RISE with SAP), SAP S/4HANA (on-premise software)、S/4-BC-XAL 1.0/S/4 外部アラートおよびモニタリング 1.0 (S/4 用) 経由のSAP ECC との統合シナリオについて、SAP 社より認定を受けたソリューションです。

<img width="409" alt="image" src="https://user-images.githubusercontent.com/57655797/230809063-8d8b7c85-f624-4169-bbea-d2a08cce94bd.png">

SAP 認定ソリューションディレクトリ: [Microsoft Sentinel 1.0](https://www.sap.com/dmc/exp/2013_09_adpd/enEN/#/solutions?id=s:33db1376-91ae-4f36-a435-aafa892a88d8)

#### 関連情報

[What's new with Microsoft Sentinel at Secure](https://techcommunity.microsoft.com/t5/microsoft-sentinel-blog/what-s-new-with-microsoft-sentinel-at-secure/ba-p/3780900)

### Sentinel for SAP BTP ※プレビュー

Microsoft Sentinel ソリューション for SAP Business Technology Platform (SAP BTP) が限定ユーザを対象にプレビュー中です。

プレビュー プログラムへの参加に関心がある場合は、こちらに[サインアップ](https://forms.office.com/pages/responsepage.aspx?id=DQSIkWdsW0yxEjajBLZtrQAAAAAAAAAAAAYAAI_bnbFUMFNKRVlLQVhGV0tFM1NHVTVKUVFRRk5MSi4u)してください。

#### 主な特徴

※Cloud Foundry 環境のサブアカウントの**監査ログ取得API（Audit Log Management Service）** の使用が前提となります

- SAP BTP 専用の分析ルール
- SAP BTP 専用のブック

#### デプロイ

[SAP® BTP 向け Microsoft Sentinel ソリューションをデプロイする](https://learn.microsoft.com/ja-jp/azure/sentinel/sap/deploy-sap-btp-solution)を参照し BTP 向けの Sentinel を構築します。

#### 関連情報

[What’s new: Sentinel Solution for SAP BTP](https://techcommunity.microsoft.com/t5/microsoft-sentinel-blog/what-s-new-sentinel-solution-for-sap-btp/ba-p/3780794)

### ネットワーク接続

#### SAP RISE/ECSとの仮想ネットワーク接続

RISE with SAP Enterprise Cloud Services (ECS) とお客様独自のAzure環境を接続するための基本(推奨)として、[仮想ネットワーク(Vnet)ピアリング](https://learn.microsoft.com/ja-jp/azure/virtual-network/virtual-network-peering-overview) を利用します。

- SAP Vnet とお客様の Vnet の両方が[ネットワーク セキュリティ グループ (NSG)](https://learn.microsoft.com/ja-jp/azure/virtual-network/network-security-groups-overview) で保護され、Vnet ピアリングを介した SAP ポートとデータベース ポートでの通信が可能になります。 ピアリングされたVnet間の通信は、これらの NSG を介してセキュリティで保護され、お客様の SAP 環境への通信が制限されます。
- Vnet ピアリングは、SAP マネージド環境と同じリージョン内に設定できるだけでなく、任意の 2 つの Azure リージョン間のグローバル Vnet ピアリングを使用しても設定できます。 SAP RISE/ECS を Azure 上で利用できる場合、ネットワークの待機時間と Vnet ピアリングにかかるコストにより、Azure のリージョンはお客様の仮想ネットワークで実行されているワークロードと一致していることが望ましいです。 ただし、複数の国や地域から中央の SAP インスタンスをご利用のお客様は、グローバル Vnet ピアリングを使って、Azure リージョン間で仮想ネットワークを接続する必要があります。

<img width="775" alt="image" src="https://user-images.githubusercontent.com/57655797/231385822-1183d949-5240-4a1b-85af-1fad890744f8.png">

※注意

- SAP RISE/ECS は SAP の Azure テナントとサブスクリプションで実行されるため、 異なるテナント間で仮想ネットワーク ピアリングを設定します。
- これを実現するには、SAP が提供するネットワークの Azure リソース ID を使用してピアリングを設定し、ピアリングを SAP に承認してもらう必要があります。
- 手順の詳細については、[vnet ピアリングの作成 - 異なるサブスクリプション](https://learn.microsoft.com/ja-jp/azure/virtual-network/create-peering-different-subscriptions?tabs=create-peering-portal)に記載されているプロセスに従いますが、正確な手順については SAP 担当者への問い合わせが必要です。

#### SAP RISE/ECSとSentinelの接続

<img width="723" alt="image" src="https://user-images.githubusercontent.com/57655797/231384345-f616da27-171c-4cbf-b323-9b5e38e52beb.png">

- SAP RISE/ECS の場合、Microsoft Sentinel ソリューションをお客様のAzureサブスクリプション上にデプロイします。（Sentinelの管理主体はお客様自身となります）
- SAP RISE/ECS との接続は、お客様の Vnet からのプライベートなネットワーク接続が必要です。通常は、Vnet ピアリングを介して接続します。
- SAP RISE/ECS でサポートされている認証方法は、SAP ユーザー名とパスワード、または X509/SNC 証明書。現在、SAP RISE/ECS 環境では RFC ベースの接続のみが可能です。

＜SAP RISE/ECS 環境でSentinelを実行する際の注意＞

1. 次のログフィールド/ソースには、追加の変更要求（移送依頼）が必要です。
  - SAP セキュリティ監査ログからのクライアント IP アドレス情報、DB テーブル ログ (プレビュー)、スプール出力ログ。
  - 手順は、[SAP から追加情報を取得する (省略可能)](https://learn.microsoft.com/ja-jp/azure/sentinel/sap/prerequisites-for-deploying-sap-continuous-threat-monitoring)に従い実施してください。 

2. SAP システムのインフラストラクチャとオペレーティングシステムのログは、SAP システムを実行しているVM、SAPControl（SAPの起動停止の管理機能）データソース、ECS 内に配置されたネットワークリソースなど、RISE と接続するために構築した Sentinel では使用することができません。　　　　　　　　　
3. SAP は、Azureインフラストラクチャとオペレーションシステムの要素を個別に監視しています。

#### 関連情報

[Azure と SAP RISE マネージド ワークロードの統合](https://learn.microsoft.com/ja-jp/azure/sap/workloads/rise-integration#microsoft-sentinel-with-sap-rise)

<!-- ## SOAR （時間がないからいらないかも）

→ 自動的に気の利いたメール送ってワークフローの Yes / No ボタン表示するようなモノを作っておく

-->
