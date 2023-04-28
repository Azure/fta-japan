# Single Server と Flexible Server の違いと優位性

## Single Server の概要と特徴

![Single Server Architecture](./img/01_03_SingleArchitecture.png)

### 開発された背景
- Availability（可用性）
- Elasticity　（スケーラビリティ）
- Security　（セキュリティ）
- Integration in ecosystem　（エコシステムへの統合）
- Industry leading TCO　（業界最高のTCO）
[Azure Database for PostgreSQL とは](https://learn.microsoft.com/ja-jp/azure/postgresql/single-server/overview)

### Notable Facts　（注目すべき事実）
- 開発のきっかけは User Voice (お客様からのフィードバック)
- Generally available in 2018 (2018 年に一般公開)
- Significant growth YoY (毎年大きな利用増加)
- Many Tier-1 workloads （多くの Tier-1 ワークロード）

## Single Server での課題と学び
### 1. アプリケーションレイテンシー

![Single Best case](./img/01_04_SingleBestCase.png)

![Single Middle Case](./img/01_05_SingleMiddleCase.png)

![Single Worst Case](./img/01_05_SingleWorstCase.png)

#### Key Points（重要なポイント）
- Limited control on resource placement（リソース配置に関する制御の限界）
- Once deployed, the compute placement can change due to scale operations or any failures（一度デプロイされると、スケール操作や障碍によってコンピューティングの配置が変更される可能性があります。）

#### Key Challenges（キーとなるチャレンジ）
- Connection through Gateway（ゲートウェイ経由の接続）
- No Availability zone locality or choice（アベイラビリティゾーンの選択肢がない）

#### Learnings（学び）
- Eliminate gateway（ゲートウェイの排除）
- Provide AZ colocation with application（アプリケーションとの AZ コロケーションの提供）


### 2. 接続
Example of connections command:
```bash
psql "host=mydb-pg11.postgres.database.azure.com port=5432 dbname=postgres user=sr@mydb-pg11 password=myPassword sslmode=require"
```
#### Key Points（重要なポイント）
- Not a regular Postgres username（通常の PostgreSQL ユーザー名ではありません）
- Recommended to use connection pooling – like PgBouncer for Postgres (PgBouncer などのコネクションプールの使用を推奨)
- Connection retry logic should have back off logic (接続再試行ロジックにはバックオフロジックが必要)

- [最大接続数](https://learn.microsoft.com/ja-jp/azure/postgresql/single-server/concepts-limits#maximum-connections)
- [Not all Postgres connection pooling is equal](https://techcommunity.microsoft.com/t5/azure-database-for-postgresql/not-all-postgres-connection-pooling-is-equal/ba-p/825717)
- [Azure Database for PostgreSQL - Single Server の一時的な接続エラーに対処する](https://learn.microsoft.com/ja-jp/azure/postgresql/single-server/concepts-connectivity)


#### Key Challenges（キーとなるチャレンジ）
- Connection requires - <username>@servername (接続には <username>@servername が必要)
- Establishing a new connection is expensive (新しい接続を確立するためにコストがかかる)
- Limits with # of connections per SKU (SKU　あたりの最大接続数の制限)

#### Learnings (学び)
- Remove @<servername> （@<servername>の削除）
- Reduce time to establish new connection (新しい接続を確立するための時間を短縮)
- Provide managed connection pooler（マネージドコネクションプールの提供）

[Azure Database for PostgreSQL の PgBouncer - フレキシブル サーバー](https://learn.microsoft.com/ja-jp/azure/postgresql/flexible-server/concepts-pgbouncer)


### 3. メンテナンス期間
![Maintenance Window](./img/01_06_MaintenanceWindow.png)
#### Key Points（重要なポイント）
- Fully system controlled （完全にシステム制御）
- Customers cannot choose the timing（お客様はタイミングを選択できません）
- Advanced Notification 72 hours. （72時間前の通知）
- Total span time 15 hours (5 pm to 8 am) but actual maintenance for a server (minutes)（合計時間は15時間（午後5時から午前8時）だが、サーバーごとの実際のメンテナンス時間は数分）

#### Key Challenge (キーとなるチャレンジ)
- Customer has limited to no control to align maintenance to their workload patterns（メンテナンスをワークロードパターンに合わせることができない）

#### Learnings(学び)
- Provide customer-controlled maintenance window（メンテナンス期間の提供）
- 
[Azure Database for PostgreSQL - 単一サーバーの計画メンテナンス通知](https://learn.microsoft.com/ja-jp/azure/postgresql/single-server/concepts-planned-maintenance-notification)
[Azure Database for PostgreSQL での予定メンテナンス - フレキシブル サーバー](https://learn.microsoft.com/ja-jp/azure/postgresql/flexible-server/concepts-maintenance)

### 4. 高可用性
![High Availability](./img/01_07_HighAvailability.png)

#### Key Features　（重要な機能）
- Region-level resiliency for compute failure (リージョンレベルのコンピューティング障碍に対するレジリエンシー)
- AZ-level resiliency with storage failure with 3 copies（AZレベルのストレージ障害に対するレジリエンシー）

#### Key Challenge(キーとなるチャレンジ)
- Failure of AZ where storage is provisioned can lead to downtime（ストレージがプロビジョニングされているAZの障害により、ダウンタイムが発生する）
[Azure Database for PostgreSQL - Single Server での高可用性](https://learn.microsoft.com/ja-jp/azure/postgresql/single-server/concepts-high-availability)

#### Learnings（学び）
- Provide AZ selection（AZの選択）
- Provide AZ resilient HA with Automatic failover with no data loss（AZレジリエントHAの提供）
[Azure Database for PostgreSQL - フレキシブル サーバーでの高可用性の概念](https://learn.microsoft.com/ja-jp/azure/postgresql/flexible-server/concepts-high-availability)



## Flexible Server (Strategic choice of service)

![Flexible Server architecture](./img/01_02_FlexibleArchitecture.png)

### Frequency asked Questions
#### Network deployment（閉じたネットワークでのデプロイメント）
- [Private Link for Azure Database for PostgreSQL-Single server](https://learn.microsoft.com/en-us/azure/postgresql/single-server/concepts-data-access-and-security-private-link)
- [Private access (VNet integration)](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-networking#private-access-vnet-integration)
- [Private Networking Patterns in Azure Database for Postgres Flexible Server](https://techcommunity.microsoft.com/t5/azure-database-for-postgresql/private-networking-patterns-in-azure-database-for-postgres/ba-p/3007149)


#### Extentions (拡張機能)
[Azure Database for PostgreSQL - フレキシブル サーバーの PostgreSQL 拡張機能](https://learn.microsoft.com/ja-jp/azure/postgresql/flexible-server/concepts-extensions)

## Summary of Single Server and Flexible Server
[Comparison chart - Azure Database for PostgreSQL Single Server and Flexible Server](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-compare-single-server-flexible-server)

- Username in connections string requires to modify application code.
- Both lc_collate and lc_ctype effects sorting results.
- [Read replica](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-read-replicas)
- [Azure Active Directory Support(AAD)](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-azure-ad-authentication)
- [Customer managed encryption key(BYOK)](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-data-encryption)
- Microsoft Defender for Cloud is not supported yet but we have roadmap.
- Azure Backup recovery service vault is not supported yet but we have roadmap.