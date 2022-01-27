



## [Azure セキュリティ ベンチマーク](https://docs.microsoft.com/ja-jp/security/benchmark/azure/)

Defender for Cloud は既定として Azure セキュリティ ベンチマークを使用してワークロードの評価を行います。Azure セキュリティ ベンチマークには ネットワーク、ID 管理、特権アクセス、ログと脅威検出などにカテゴリ分けされたセキュリティ コントロールと、Azure リソースごと考慮すべき個別のセキュリティ コントロールが記載されたセキュリティ ベースラインで構成されています。セキュリティ ベースラインに記載されている一部のセキュリティ コントロールには Defender for Cloud が使用する Azure Policy との対応が記載されています。
重要な点として Defender for Cloud の全ての推奨事項に対応することで、セキュリティ ベースラインに記載された全ての推奨項目が充足されるわけではありません。よりセキュアな環境のためには Defender for Cloud の推奨事項を自動化されたベースラインとして活用しながら、各リソースのセキュリティ ベースラインを個別に理解し、必要なセキュリティ コントロールを実装してください。

Defender for Cloud が検出できないコントロールは特に人間が介在しなければならないカテゴリに多く含まれ、管理アカウントの運用を記載した  [特権管理] や、セキュリティ イベントが発生した場合の対応を行う [インシデント対応] 、組織の体制が記載されている [ガバナンスと戦略] など組織のプロセスとともに実装していく必要があります。



## [Microsoft Sentinel ワークスペース アーキテクチャのベスト プラクティス](https://docs.microsoft.com/ja-jp/azure/sentinel/best-practices-workspace-architecture)

セキュリティ監視に使う Log Analytics ワークスペースは可能な限り少なくすることが推奨で、多くの場合１つのテナントに１つのワークスペースを作成することをお薦めしています。
データの保存場所などのコンプライアンス上の要求がある場合や、データ間通信で大きなコストが発生する場合にはワークスペースを分割することを検討します。
アクセス権によってワークスペースを分けたい場合には、ワークスペースを分ける代わりに「リソース コンテキスト」のアクセス権や「テーブル レベルの Azure RBAC」で代替することができるかどうかを検討してください。
- [Azure のアクセス許可を使用してアクセスを管理する](https://docs.microsoft.com/ja-jp/azure/azure-monitor/logs/manage-access#manage-access-using-azure-permissions)
- [テーブル レベルの Azure RBAC](https://docs.microsoft.com/ja-jp/azure/azure-monitor/logs/manage-access#table-level-azure-rbac)






## [Microsoft Defender for Cloud の強化されたセキュリティ機能](https://docs.microsoft.com/ja-jp/azure/defender-for-cloud/enhanced-security-features-overview#can-i-enable-microsoft-defender-for-servers-on-a-subset-of-servers-in-my-subscription)

Microsoft defender for Cloud の強化されたセキュリティ機能はサブスクリプションに存在するリソースごとに有効化されます。Azure Virtual Desktop が含まれる環境などでは、サーバーワークロードの VM は Microsoft Defender for Cloud で保護を行い、それ以外のクライアント用の VM については Defender for Cloud を使いたくないような場合にはサブスクリプションは分割しておく必要があります。


>自分のサブスクリプションで、サーバーのサブセットに対して Microsoft Defender for servers を有効にすることはできますか?
>
>いいえ。 サブスクリプションで Microsoft Defender for servers を有効にすると、サブスクリプション内のすべてのマシンが Defender for servers によって保護されます。
>また、Log Analytics ワークスペース レベルで Microsoft Defender for servers を有効にする方法もあります。 この場合、そのワークスペースにレポートするサーバーだけが保護され、課金されるようになります。 ただし、いくつかの機能が利用できなくなります。 それらの例としては、Just-in-Time VM アクセス、ネットワーク検出、規制コンプライアンス、アダプティブ ネットワークのセキュリティ強化機能、適応型アプリケーション制御などが挙げられます。

## [Azure Monitor エージェントの概要](https://techcommunity.microsoft.com/t5/microsoft-defender-for-cloud/become-a-microsoft-defender-for-cloud-ninja/ba-p/1608761)



>Log Analytics エージェントは、次のような場合に使用します。
>- Azure の外部でホストされている Azure 仮想マシンまたはハイブリッド マシンから、ログとパフォーマンス データを収集する。
>- データを Log Analytics ワークスペースに送信して、ログ クエリなど、Azure Monitor ログでサポートされている機能を活用する。
>- マシンを大規模に監視し、そのプロセスや他のリソースおよび外部プロセスに対する依存関係を監視できる、VM insights を使用する。
>- Microsoft Defender for Cloud または Microsoft Sentinel を利用してマシンのセキュリティを管理します。
>- マシンを大規模に監視し、そのプロセスや他のリソースおよび外部プロセスに対する依存関係を監視できる、VM insights を使用する。
>- さまざまなソリューションを使用して、特定のサービスまたはアプリケーションを監視する。
> 


### Windows エージェントの比較
|                    |Azure Monitor エージェント| 診断拡張機能 (WAD) | Log Analyticsエージェント | 依存関係エージェント|
| ---- | ---- | ---- | ---- | ---- |
|サポートされている環境|Azure<br>その他のクラウド(Azure Arc)<br>オンプレミス (Azure Arc)|Azure |Azure<br>その他のクラウド<br>オンプレミス|Azure<br>その他のクラウド<br>オンプレミス|
|エージェントの要件    |なし|なし|なし|Log Analytics エージェントが必要|                               
|収集されるデータ	|イベント ログ<br>パフォーマンス|イベント ログ<br>ETW イベント<br>パフォーマンス<br>ファイル ベース ログ<br>IIS ログ<br>.NET アプリ ログ<br>クラッシュ ダンプ<br>エージェント診断ログ|イベント ログ<br>パフォーマンス<br>ファイル ベース ログ<br>IIS ログ<br>分析情報とソリューション<br>その他のサービス|プロセスの依存関係<br>ネットワーク接続のメトリック|
|送信されるデータ	|Azure Monitor ログ<br>Azure Monitor メトリック|Azure Storage<br>Azure Monitor メトリック<br>イベント ハブ|Azure Monitor ログ|Azure Monitor ログ(Log Analytics エージェント経由)|
|サービスとfeaturesサポート対象|Log Analytics<br>メトリックス エクスプローラー|メトリックス エクスプローラー|VM insights  <br>Log Analytics<br>Azure Automation<br>Microsoft Defender for Cloud<br>Microsoft Sentinel|VM insights<br>サービス マップ|


[Kubernetes 用の Azure Policy について理解する](https://docs.microsoft.com/ja-jp/azure/governance/policy/concepts/policy-for-kubernetes)


[Azure Policy でクラスターをセキュリティで保護する](https://docs.microsoft.com/ja-jp/azure/aks/use-azure-policy?toc=/azure/governance/policy/toc.json&bc=/azure/governance/policy/breadcrumb/toc.json)


[Permissions in Microsoft Defender for Cloud](https://docs.microsoft.com/ja-jp/azure/defender-for-cloud/permissions)


[Connect your non-Azure machines to Microsoft Defender for Cloud](https://docs.microsoft.com/ja-jp/azure/defender-for-cloud/quickstart-onboard-machines?pivots=azure-arc)




[Become a Microsoft Defender for Cloud Ninja](https://techcommunity.microsoft.com/t5/microsoft-defender-for-cloud/become-a-microsoft-defender-for-cloud-ninja/ba-p/1608761)