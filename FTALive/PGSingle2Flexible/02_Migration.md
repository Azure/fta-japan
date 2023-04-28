# 移行について

## アセスメント
### データベースそのもののアセスメント

1. Database size を確認する

```sql
SELECT pg_size_pretty( pg_database_size('postgres') );
```

2. テーブル一覧を確認する
```sql
SELECT n.nspname as "Schema",
  c.relname as "Name",
  CASE c.relkind WHEN 'r' THEN 'table' WHEN 'v' THEN 'view' WHEN 'm' THEN 'materialized view' WHEN 'i' THEN 'index' WHEN 'S' THEN 'sequence' WHEN 's' THEN 'special' WHEN 'f' THEN 'foreign table' WHEN 'p' THEN 'partitioned table' WHEN 'I' THEN 'partitioned index' END as "Type",
  CASE c.relpersistence WHEN 'p' THEN 'permanent' WHEN 't' THEN 'temporary' WHEN 'u' THEN 'unlogged' END as "Persistence",
  pg_catalog.pg_size_pretty(pg_catalog.pg_table_size(c.oid)) as "Size"
FROM pg_catalog.pg_class c
     LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE c.relkind IN ('r','p','')
      AND n.nspname <> 'pg_catalog'
      AND n.nspname <> 'information_schema'
      AND n.nspname !~ '^pg_toast'
ORDER BY 1,2;
```

3. テーブル内のブロートの取得

```SQL
SELECT schemaname, relname, n_dead_tup, n_live_tup, round(n_dead_tup::float/n_live_tup::float*100) dead_pct ,autovacuum_count , last_vacuum, last_autovacuum ,last_autoanalyze
FROM pg_stat_user_tables  
WHERE n_live_tup > 0  
ORDER BY n_live_tup DESC;
```

> Bloat （ブロート）
未使用（自由）空間、あるいは古くなった行バージョンのように、現在の行バージョンを含まないデータページ内の空間

4. 拡張機能の確認
```SQL
SELECT e.extname AS "Name", e.extversion AS "Version", n.nspname AS "Schema", c.description AS "Description"
FROM pg_catalog.pg_extension e LEFT JOIN pg_catalog.pg_namespace n ON n.oid = e.extnamespace 
LEFT JOIN pg_catalog.pg_description c ON c.objoid = e.oid AND c.classoid = 'pg_catalog.pg_extension'::pg_catalog.regclass
ORDER BY 1;
```

5. ラージオブジェクトの確認
```SQL
SELECT oid as "ID",
  pg_catalog.pg_get_userbyid(lomowner) as "Owner",
  pg_catalog.obj_description(oid, 'pg_largeobject') as "Description"
  FROM pg_catalog.pg_largeobject_metadata   ORDER BY oid;
```

6. みなしごのラージオブジェクトの確認

```SQL
select oid from pg_largeobject_metadata m where not exists
(select 1 from <name_of_table>  where m.oid=name_of_oid_column);
```


### 現在のデプロイメント機能の確認
- SKU
- Network (Private link or Public)
- Read replica の有無
- Azure Backup の使用有無（Long time retention時のみ）
- データベースのバージョン

### 拡張機能の使用状況と対応状況の確認

- [Azure Database for PostgreSQL - フレキシブル サーバーの PostgreSQL 拡張機能](https://learn.microsoft.com/ja-jp/azure/postgresql/flexible-server/concepts-extensions)

注意する拡張機能は以下のとおり。

| NOTE |
| ---- |
|TIMESCALEDB, PG_PARTMAN, POSTGIS_TIGER_DECODER <br>__サポートリクエスト経由で支援依頼が必要__|



| TIP |
| ---- |
|PG_CRON, PG_HINT_PLAN, PG_PARTMAN_BGW, PG_PREWARM, PG_STAT_STATEMENTS, PG_AUDIT, PGLOGICAL, WAL2JSON <br> __"shared_preloar_libraries"から追加する必要がある。__|


## 移行計画
移行計画を作成するには、以下の情報が必要となる。
### DB バージョン
移行先のDBのバージョンは、11であれば11もしくはアップグレード可能な14を選択。（15がGAされたら、15も選択可能）
バージョン毎の機能差異は [Feature Matrix ](https://www.postgresql.org/about/featurematrix/) に記載されている。


### 移行先の SKU と移行時に使用する SKU を決定する
| IMPORTANT |
| ---- |
|移行エクスペリエンスを最適化するため、フレキシブル サーバーのバースト可能 SKU を使用した移行の実行はサポートされていません。 汎用またはメモリ最適化 SKU (4 仮想コア以上) をターゲット フレキシブル サーバーとして使用して、移行を実行してください。 移行が完了したら、必要に応じて、バースト可能なインスタンスにスケールダウンできます。|


### 移行リハーサルと所要時間の確認
本番環境と同等サイズのテスト環境があれば、テスト環境をソースとして移行リハーサルを実施する。
本番環境と同等サイズのテスト環境がない場合は、本番のバックアップを元にレプリカを作成してリハーサルを実施することも可能。
参考リンク：[ポイントインタイムリストア](https://learn.microsoft.com/ja-jp/azure/postgresql/single-server/how-to-restore-server-portal#point-in-time-restore)

所要時間の目安はドキュメントに記載があるが、スキーマ構成やソース環境のインフラ構成によって変わるため、実際に移行リハーサルを実施して所要時間を確認することが望ましい。

リハーサルでの主な確認項目
- 移行にかかる所要時間の目安
- リソースのサイズが適切かの確認（例、ソースのディスクIOPSが著しく高い場合は、移行元のIOPSを一時的に上げるためにディスク割り当て容量を増やすなど）
- 移行の具体的な手順
- アプリケーションの変更箇所の確認（主に接続文字列、コネクションプール由来の変更など）
- 移行後のアプリケーション確認項目の整理
- 移行作業のブロッカーの有無の確認（あれば、SR等を利用して解決）
- ワーストケース（切り戻し）の確認

## 移行作業とクリーンアップ
リハーサルで確認した移行手順を元に、本番環境の移行を実施する。
カットオーバー後にソースの Single Server を削除する。

