## はじめに
`Eventhub`を使い始める上でよく出てくる質問をここに記載します。誤植などを見つけた場合は`Issue`にてお知らせください。

## EventHubのSAS(共有アクセス署名)をどのようにして得ればいいですか？（ポータル編）

下記の手順でEventhubからSASを得ることができます。

1. この画面の左パネルにある共有アクセスポリシーをクリックしてください。
![Eventhub001](https://media.githubusercontent.com/media/Azure/fta-japan/main/FAQ/App/Eventhub/asset/eventhub001.png)

2. アクセスするとこのような画面が見えます。Eventhubを作った状態だとデフォルトで下記のアクセスキー（SAS）の項目が設定されています。さらにアクセスキー（SAS）の項目を選択します。
![Eventhub002](https://media.githubusercontent.com/media/Azure/fta-japan/main/FAQ/App/Eventhub/asset/eventhub002.png)

3. このような形でアクセスキーや接続文字列にアクセスすることができます。
![Eventhub003](https://media.githubusercontent.com/media/Azure/fta-japan/main/FAQ/App/Eventhub/asset/eventhub003.png)


## EventHubの性能設定はどこからできますか？

1. この画面の左パネルにあるスケーリングをクリックしてください。
![Eventhub004](https://media.githubusercontent.com/media/Azure/fta-japan/main/FAQ/App/Eventhub/asset/eventhub004.png)

2. EventHubはスループットユニットによって性能を調整できます。
![Eventhub005](https://media.githubusercontent.com/media/Azure/fta-japan/main/FAQ/App/Eventhub/asset/eventhub005.png)
初期値は1となっており、1スループットユニットあたりの参考性能は以下のとおりです。
>イングレス: 1 秒あたり最大で 1 MB または 1,000 イベント (どちらか先に到達した方)  
>エグレス: 1 秒あたり最大で 2 MB または 4,096 イベント

3. さらに、上記の参考性能を上回った場合に自動スケールする自動インフレという機能もあります。`Standard` SKU から利用可能です。
![Eventhub006](https://media.githubusercontent.com/media/Azure/fta-japan/main/FAQ/App/Eventhub/asset/eventhub006.png)

性能設定に関する詳しい説明は以下のドキュメントをご参照ください。  
[Event Hubs によるスケーリング](https://docs.microsoft.com/ja-jp/azure/event-hubs/event-hubs-scalability)