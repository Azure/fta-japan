Azure Monitoring # **[prev](./overview.md)** | **[home](./README.md)** 

# 3. Azure の監視の実装 <!-- no toc -->

本章では、サンプルのシナリオを用意し、Azure の監視を実装する方法を紹介します。

## 目次 <!-- omit in toc -->

- [3. Azure の監視の実装](#3-azure-の監視の実装)
  - [3.1. シナリオ](#31-シナリオ)
  - [3.2. 監視の実装例](#32-監視の実装例)
    - [Log Analytics ワークスペース](#log-analytics-ワークスペース)
    - [アプリケーション](#アプリケーション)
    - [仮想マシン](#仮想マシン)
    - [ネットワーク](#ネットワーク)
    - [マネージドサービス](#マネージドサービス)
    - [Azure AD](#azure-ad)
    - [サブスクリプション](#サブスクリプション)
    - [コスト](#コスト)
    - [正常性アラート](#正常性アラート)

## 3.1. シナリオ

![](./images/imple-overview.png)

- 想定するストーリー
  - オンプレミスにあるサーバー群を Azure に移行しそれらのサーバーを監視する
- ワークロードと利用するサービス
  - 仮想マシン
    - Web サーバー(企業の Web サイト)
    - DB サーバー(Web サーバーのバックエンド DB)
    - ファイルサーバー
    - 業務システムで利用するそのほかのサーバー
  - Application Gateway
    - Web サーバーのフロントに配置しインターネットからのアクセスを制御する
  - Azure Firewall
    - サーバーからのデータ送信を制御する
- ネットワーク
  - ハブアンドスポーク構成
  - ハブに Azure Firewall と ExpressRoute Gateway を配置
  - 外部との接続が必要なWeb サーバーとそのほかのサーバーは VNet を分割
  - 各サーバーからの送信接続は Azure Firewall を経由

※シナリオの構成をすぐに試すために、[Terraform](./terraform/)を作成しました。サブスクリプションに展開して設定方法を確認できます。

## 3.2. 監視の実装例

### Log Analytics ワークスペース

Log Analytics ワークスペースは共有サブスクリプションに1つ展開します。このワークスペースにほかのサブスクリプションのログの収集も行います。

### アプリケーション

今回のシナリオでは、Web サーバーにホストされたアプリケーションを対象として考えます。Web サーバーは、インターネットに公開された企業の Web サイトをホストします。

企業の Web サイトであることから、SLA は特にないものとします。しかし、Web サイトがダウンすることは企業イメージへの悪影響を与えることが考えられることから、SLI/SLO を設けることとします。

Web アプリケーションの SLI の一例を以下に挙げます。

|SLI|SLO|
|:---|:---|
|HTTP ステータスコードが 200 以外の割合|0.1 %以下|
|レスポンスにかかる時間が 100 msec以上の割合|0.1 %以下|

Azure では、アプリケーションの監視として、Application Insights が利用できます。フロントエンドやバックエンドのアプリケーションにコードを埋め込むことで APM を実装できます。また、ブラックボックス監視として、可用性テストが利用できます。

可用性テストは、アプリケーションに変更を加えることなく、パフォーマンスやエラーを簡易的にテストできるサービスです。アラートも設定可能です。

可用性テストを使うにあたってアプリケーションにヘルスエンドポイントを実装しておきます。ヘルスエンドポイントにアクセスすると Web サーバーからバックエンドのデータベースへのアクセスまで通しの監視ができます。

### 仮想マシン

仮想マシンの監視は、Azure Monitor によるメトリックとログをもとに行います。Azure Monitor を利用すると以下の項目を監視できます。

- 仮想マシンホストのメトリック
- 仮想マシンの OS メトリック
- 仮想マシンの OS ログ

仮想マシンの監視は、Azure Monitor エージェントを使用します。前章で紹介したように、2つのエージェントが存在しますが、Azure Monitor エージェント を利用することを検討します。

Azure Monitor エージェントで仮想マシンを監視する為の手順は以下の通りです。

1. Log Analytics ワークスペースを作成する
2. データ収集ルールを作成する
   - データ ソースとターゲットを設定する
   - リソースを設定する

仮想マシンからのデータ収集の設定は、データ収集ルールで行います。データ収集ルールを使用すると、複数の仮想マシンからのデータ収集を柔軟に設定できます。たとえば、あるサーバーに対しては CPU 使用率のメトリックとアプリケーション ログを収集し、別のサーバーはセキュリティ イベントのログも追加で収集したい場合があります。またそれらのログを同じ Log Analytics ワークスペースへ集約するということが可能です。

以下は、データ収集ルールの概念です。

![](./images/imple-dcr.png)

データ収集ルールで必要な設定は`データソース`、`ターゲット`、`リソース`です。

`データソース`は、パフォーマンス カウンター、Windows イベント ログ、Linux Syslog があります。それぞれ、収集するカウンターやログの種類、ログレベルを設定します。収集するログは Windows イベントの XPath クエリや Syslog のログレベル、ファシリティでフィルタできます。収集するログを限定することで取り込みと保存のコストを抑えることができます。

`ターゲット`は、データの送信先です。メトリックデータベース、Log Anaytics ワークスペースが設定できます。パフォーマンスカウンターを Log Analytics ワークスペースへ送信することでログとしてメトリックを保存ができます。ターゲットは複数指定できます。

データ収集ルールの`データ ソース`から各データソースを追加します。

![](./images/imple-dcr-config.png)

データソースによって、取得するカウンターやログの種類、ログレベルを設定します。

![](./images/imple-dcr-datasource-perf.png)
![](./images/imple-dcr-datasource-winlog.png)
![](./images/imple-dcr-datasource-syslog.png)
![](./images/imple-dcr-datasource-perf-target.png)

以下のようにカウンターをカスタムするとプロセス監視としても利用ができます。以下の例では、`% Processor Time` をカウンターとして追加しています。点線はプロセスが存在しなかった期間です。

![](./images/imple-dcr-datasource-perf-edge.png)
![](./images/imple-dcr-datasource-perf-edge-metric.png)

`リソース`は、収集対象の仮想マシンを設定します。

![](./images/imple-dcr-resource.png)

データ収集ルールを設定すると、仮想マシンのマネージド ID の有効化と拡張機能としてエージェントがインストールされ、仮想マシンからのデータ収集が開始されます。

以下のサポートチームのブログ記事でも分かりやすく解説されています。

[Azure VM の監視について](https://jpazmon-integ.github.io/blog/LogAnalytics/MonitorAzVM_logs/)

### ネットワーク

今回のシナリオでネットワークの監視が必要なポイントとしてオンプレミスから Azure への接続を考えます。オンプレミスから Azure への接続は、ExpressRoute を使用した閉域接続を使用しています。このようなネットワーク構成はオンプレミスのルーターやサービスプロバイダーの設備、Azure のゲートウェイ等のネットワークに関するコンポーネントが存在することになります。

この構成を個々のコンポーネントで監視もできますが、システム全体が稼働しているかどうかを確認するためにはエンドツーエンドの監視が効果的です。

Azure では、Network Watcher の機能の1つとして、接続モニターがあります。接続モニターを使用すると、オンプレミスのサーバーから Azure 上の仮想マシンまでのチェックの失敗率やラウンドトリップ時間を測定できます。接続モニターを有効にすると仮想マシンに自動的に拡張機能がインストールされます。接続モニターによって収集されたデータは、Log Analytics ワークスペースへ保存されます。

[Azure portal を使用して接続モニターでモニターを作成する](https://learn.microsoft.com/ja-jp/azure/network-watcher/connection-monitor-create-using-portal?source=recommendations)

以下は接続モニターのダッシュボードです。

![](./images/imple-connmon-create.png)

接続モニターによってテストを行うソースとターゲットの仮想マシンを指定します。

![](./images/imple-connmon-source.png)
![](./images/imple-connmon-target.png)

テストは、HTTP/TCP/ICMP を選択できます。

![](./images/imple-common-testconfig.png)

テスト グループで複数のテストをまとめることができます。

![](./images/imple-connmon-testgroup.png)

テスト結果は、テスト グループ、ソース、ターゲットごとに詳細に確認できます。

![](./images/imple-connmon-metric.png)
![](./images/imple-connmon-perf.png)

失敗したテストは失敗状態として表示されます。アラートを設定することで、失敗したテストを通知できます。以下は、Web サーバーをシャットダウンした状態です。

![](./images/imple-connmon-fail.png)

同時に、可用性テストや Application Gateway のメトリックでも失敗状態となります。以下は可用性テストのダッシュボードです。

![](./images/imple-connmon-fail-test.png)
![](./images/imple-connmon-fail-test2.png)

接続モニターによるエンドツーエンド以外の監視としてゲートウェイや ExpressRoute 回線が持っているメトリックを活用できます。

### マネージドサービス

マネージドサービスの監視は、診断設定で行います。今回のシナリオでは、Azure Firewall と Application Gateway がマネージドサービスとして存在します。いずれのサービスもデータパスとしてトラフィックを処理するサービスであり、トラフィックを監視する必要があります。

#### Azure Firewall

Azure Firewall は、ファイアーウォールを通過したすべてのトラフィックをロギングしているため、ログを分析することで許可されたトラフィック、拒否されたトラフィック、IDPS により検知された悪意のあるトラフィック等を監視できます。

以下は、Azure Firewall の診断設定です。Azure Firewall はリソース固有のテーブルへのエクスポートが可能です。リソース固有のテーブルへデータを保存することで、Policy Analyticsが利用できます。(2022/11現在プレビュー)

![](./images/imple-azfw-diag.png)

以下は Azure Firewall のログを Log Analytics で表示した例です。あらかじめ用意されたクエリを利用することで簡単にログを分析できます。

![](./images/imple-azfw-log.png)

また、Azure Firewall のブックを利用するとログからトラフィックの傾向を分析できます。

[Azure Firewall ブックを使用してログを監視する](https://learn.microsoft.com/ja-jp/azure/firewall/firewall-workbook)

![](./images/imple-azfw-workbook.png)

#### Application Gateway

Application Gateway も同様に、リソースを通過したトラフィックをロギングしています。Application Gateway は HTTP を扱い、コネクションを終端する役割を持っているため、トラブルシューティングの際のログとしても活用できます。また、WAF によって検出されたトラフィックもログに記録されます。

以下は Application Gateway のログを Log Analytics で表示した例です。あらかじめ用意されたクエリを利用することで簡単にログを分析できます。

![](./images/imple-appgw-log.png)

Application Gateway はリバースプロキシの特性上、多くのメトリックを持っています。それぞれのメトリックの意味を理解しておく必要があります。以下のドキュメントが参考になります。

[Application Gateway のメトリック](https://learn.microsoft.com/ja-jp/azure/application-gateway/application-gateway-metrics)

![](./images/application-gateway-metrics.png)

### Azure AD

Azure AD のログはセキュリティ監視としても活用できるサインインやユーザーのアクションがロギングされます。Azure AD のログは膨大に記録される傾向にあり、そのログからセキュリティとしてクリティカルなログを見つける必要があります。ログの分析には時間がかかり専門的に扱う必要があるため、専任のセキュリティエンジニアをアサインします。ログの分析が難しい場合、Identity Protection を利用すると Azure AD の機能によってリスク検出と修復を自動化できます。

[Identity Protection とは](https://learn.microsoft.com/ja-jp/azure/active-directory/identity-protection/overview-identity-protection)

Azure AD のログもマネージドサービスと同様に診断設定で Log Analytics ワークスペース等に送信できます。以下は Application Gateway のログを Log Analytics で表示した例です。

![](images/imple-aad-log.png)

既定で展開されているワークブックを活用すると、ワークスペースのログが簡単に可視化できます。

![](./images/imple-aad-workbook.png)

### サブスクリプション

リソースの作成、削除や設定変更の記録としてサブスクリプションのログを保存します。サブスクリプションのログはエラーや障害が発生した場合のトラブルシューティングとしても活用できます。サブスクリプションのログも診断設定から Log Analytics ワークスペースに送信できます。

以下は、Azure の管理操作を失敗したユーザーのリストと対象のリソースを表示しています。

![](./images/imple-subscription-log.png)


### コスト

見積もり以上のコストの利用にいち早く気付くために予算を設定します。また、定期的にコストのレビューをします。

異常アラートを設定し、日々のコストの異常があった時に通知を受信します。

[異常アラートを作成する](https://learn.microsoft.com/ja-jp/azure/cost-management-billing/understand/analyze-unexpected-charges#create-an-anomaly-alert)

### 正常性アラート

障害やメンテナンスの通知を受け取るために正常性アラートを設定します。ノイズにならないように、利用しているサービスやリージョンに限定して設定します。

![](./images/imple-health-alert.png)