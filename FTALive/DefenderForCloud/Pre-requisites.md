#### [prev](./welcome.md) | [home](./welcome.md)  | [next](./findings.md)

# はじめに

クラウド環境に移行すると、展開されたワークロードを適切にコントロールすることが大きな課題になります。様々な調査では CEO や CIO などは、クラウドの全体を把握できるかどうかという可視性について懸念を抱いていることがわかっています。

Microsoft Defender for Cloud を活用することでクラウド環境の把握とコントロールが可能になります。



## クラウド セキュリティ態勢管理 (CSPM)

ここが最も重要な点で、Microsoft Defender for Cloud は、無償で利用できる機能と、有償の "強化されたセキュリティ" の 2つの要素から構成されています。

無償の機能は、「クラウド セキュリティ態勢管理 (Cloud Workload Posture Management)」ツールと呼ばれるもので。サーバー、ストレージ、SQL、ネットワーク、アプリケーション、ワークロードなど、Azureで稼働しているクラウド リソースのセキュリティ状態を確認することができます。

[Microsoft Docs](https://docs.microsoft.com/ja-jp/azure/security-center/security-center-introduction) からの引用 - Microsoft Defender for Cloud は、3 つの緊急性が高いセキュリティの課題を対処します:

* **急速に変化するワークロード** – これはクラウドの強みであり、課題でもあります。 一方、エンド ユーザーはより多くの処理を実行できます。 さらに、使用および作成されている常に変化するサービスが、お客様のセキュリティ基準に準拠し、セキュリティのベスト プラクティスに従っていることを確認するにはどうすればよいでしょうか。

* **ますます高度になる攻撃** - ワークロードをどこで実行する場合でも、攻撃はますます高度になっています。 パブリック クラウドのワークロードを保護する必要があります。これは実質的にインターネットに接続しているワークロードであり、セキュリティのベスト プラクティスに従わないと、さらに脆弱になる可能性があります。

* **セキュリティ スキルの不足** - セキュリティ アラートとアラート システムの数は、環境が保護されているかどうかを確認するために必要な経歴と経験を持つ管理者の数を上回っています。 最近の攻撃の最新情報を把握し続けることは常に課題であり、セキュリティの世界が絶え間なく変化する最前線に立ち続けることは不可能です。

Microsoft Defender for Cloud の最大のメリットは、['Secure Score'](https://docs.microsoft.com/en-us/azure/security-center/secure-score-security-controls#security-controls-and-their-recommendations)です。セキュアスコアは、現状を把握し、効果的かつ効率的にセキュリティを向上させることを目的としています。セキュアスコアは、リソースのセキュリティ問題を継続的に評価し、それらを1つのスコアに集約することで、現在のセキュリティ態勢を確認することができます。スコアが高ければ高いほど、特定されたリスクレベルは低くなります。これは、[Azure Security Benchmark](https://docs.microsoft.com/en-us/security/benchmark/azure/baselines/security-center-security-baseline?toc=/azure/security-center/TOC.json)と呼ばれるポリシーによって制御されます。このポリシーは、推奨されるベストプラクティスに基づいて構築され、Center for Internet Security Benchmark の内容も考慮しています。


## クラウド ワークロード保護 (CWP)

Microsoft Defender for Cloud を構成する2 つめの要素は "強化されたセキュリティ" で 「クラウド ワークロード 保護 (Cloud Workload Protection)」 ツールと呼ばれるものです。

これは様々なものを指しています。"強化されたセキュリティ" は単一の機能ではなく、異なった種類のリソースを保護するために設計された複数の高度なツールを含んでいます。。Microsoft Defender for Endpoint (Server)による脅威対策と、Just In Time 管理や Adaptive Application Control などの高度なクラウド保護機能が統合されています。複数の異なるセキュリティ機能を統一的に管理する場所を提供し、ハイブリッドクラウドのワークロードに対応する機能を提供します。また、Microsoft Defender for Cloud のベースラインによるチェックをさらに拡張し、ISO 27001 や CIS ベンチマークといったコンプライアンスや業界標準を使用してワークロードのセキュリティ状態をチェックする機能も "強化されたセキュリティ" に含まれます。


## Azure Policy とは?

Azure Policy は、セキュリティ標準による評価を実施し、大規模な環境でもコンプライアンス評価を自動的に行うことができる。ビジネスルールを Azure Policy として定義すると、Azure Policy がリソースのプロパティを定義されたビジネスルールと比較して、全体の状態を把握することができると考えてください。様々なリソースに対して許可する構成、許可しない構成、自動的な監査、許可しない構成のブロックなどを行うことができます。




#### [prev](./welcome.md) | [home](./welcome.md)  | [next](./findings.md)