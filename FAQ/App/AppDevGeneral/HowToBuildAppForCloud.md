Azure 上 もしくは、一般的なパブリッククラウド上でアプリケーションを実行する場合に気を付けなければならないことがあります。
Azure アーキテクチャセンター というドキュメントがあり、その中で、[Azure アプリケーションの設計原則 - Azure Architecture Center | Microsoft Docs](https://docs.microsoft.com/ja-jp/azure/architecture/guide/design-principles/) という資料があります。

一般的には、[The Twelve-Factor App （日本語訳） (12factor.net)](https://12factor.net/ja/) に書かれている 12の原則が大事なことですが、このようなことも踏まえて Azure のサービスの例を挙げているものが、Azure アプリケーションの設計原則です。

#### 10の原則
※日本語をわかりやすくするためにドキュメントの項目に変更を加えています。
1. 自動修復の設計（[自己復旧の設計 - Azure Application Architecture Guide | Microsoft Docs](https://docs.microsoft.com/ja-jp/azure/architecture/guide/design-principles/self-healing)）
2. 単一障害点の排除（[すべてを冗長化 - Azure Application Architecture Guide | Microsoft Docs](https://docs.microsoft.com/ja-jp/azure/architecture/guide/design-principles/redundancy)）
3. ノード間でのトランザクション差異の最小化（[調整を最小限に抑える - Azure Architecture Center | Microsoft Docs](https://docs.microsoft.com/ja-jp/azure/architecture/guide/design-principles/minimize-coordination)）
4. スケールアウトの設計（[スケールアウトのための設計 - Azure Application Architecture Guide | Microsoft Docs](https://docs.microsoft.com/ja-jp/azure/architecture/guide/design-principles/scale-out)）
5. パーティション分割による制限の回避（[パーティション分割による制限の回避 - Azure Application Architecture Guide | Microsoft Docs](https://docs.microsoft.com/ja-jp/azure/architecture/guide/design-principles/partition)）
6. オペレーション（運用）に合わせた設計（[操作に合わせた設計 - Azure Application Architecture Guide | Microsoft Docs](https://docs.microsoft.com/ja-jp/azure/architecture/guide/design-principles/design-for-operations)）
7. PaaS（App,DBなど）のオプションを選択する（[サービスとしてのプラットフォーム (PaaS) オプションを使用する - Azure Application Architecture Guide | Microsoft Docs](https://docs.microsoft.com/ja-jp/azure/architecture/guide/design-principles/managed-services)）
8. 最適なデータストアの選択（[ジョブに最適なデータ ストアの使用 - Azure Application Architecture Guide | Microsoft Docs](https://docs.microsoft.com/ja-jp/azure/architecture/guide/design-principles/use-the-best-data-store)）
9. アプリケーションデリバリ、デプロイの計画に合わせた設計（[変更を見込んだ設計 - Azure Application Architecture Guide | Microsoft Docs](https://docs.microsoft.com/ja-jp/azure/architecture/guide/design-principles/design-for-evolution)）
10. ビジネス要件に合わせた構成、構築（[ビジネス ニーズに合わせた構築 - Azure Application Architecture Guide | Microsoft Docs](https://docs.microsoft.com/ja-jp/azure/architecture/guide/design-principles/build-for-business)）

特に重要な項目が、#1と#5の項目です。基本的にAzure 自体が仮想基盤、ストレージ、ネットワークなどの共有基盤の上で実行されるため、一つのお客様がリソースを占有しないように、リミットやクオーターの設定がしてあります。そのため、リミットやクオーターを把握しておくことはもちろんのこと、それらに引っかかった場合でもアプリケーション上で正しくエラーハンドリングをすることが大事です。また、場合によっては、HTTP の Response Code を見て、リトライの仕組み（サーキットブレイカーやバルクヘッドの実装パターン）をアプリケーションに組み込んでおくのが良いでしょう。

これらの具体的な実装パターンについては、[クラウド設計パターン - Azure Architecture Center | Microsoft Docs](https://docs.microsoft.com/ja-jp/azure/architecture/patterns/) に例が挙げられています。デザインパターンといえば、GoFパターン（[デザインパターン (ソフトウェア) - Wikipedia](https://ja.wikipedia.org/wiki/%E3%83%87%E3%82%B6%E3%82%A4%E3%83%B3%E3%83%91%E3%82%BF%E3%83%BC%E3%83%B3_(%E3%82%BD%E3%83%95%E3%83%88%E3%82%A6%E3%82%A7%E3%82%A2))）のようなものが有名ですが、それらの思想と先にあげた`Twelve-factor App`やMartin Fawlar（[martinfowler.com](https://martinfowler.com/)）によってまとめられたの思想がクラウド設計パターンに反映されています。




