# Microsoft Sentinel のオートメーション


## Microsoft Sentinel 用のプレイブックを作成する

機能や UI に変更があり、Web 上の記事と最新の設定項目が異なっていることで質問を受ける機会が多いため、新しい UI を使用した設定の例を示すためにこの記事を作成しています。

Sentinel のプレイブックで使用する Logic App の基本的な作り方や注意点は以下のドキュメントを参照してください。

[チュートリアル: Microsoft Sentinel でオートメーション ルールとプレイブックを使用する](https://docs.microsoft.com/ja-jp/azure/sentinel/tutorial-respond-threats-playbook)

例ではアラート トリガーのオートメーションを作成します。Seentinel の `オートメーション` から `アラート トリガーを使用したプレイブック` を選択すると簡単です。

![Sentinel Automation](./images/soar-sentinel-automation.png)


## プレイブックで Function を使用する

従量課金プランで作成されたサーバレスの Function を Logic Apps から呼び出します。
ここでは以下の構成で作成した Function を呼び出し、Managed ID によるアクセス制限を行います。  
> ※ Managed ID による認証が全てのセキュリティ要件を満たすことを意味するものではありません。ネットワーク機能や他のワークロードを組み合わせることで多層的な制御を追加することができますが、幅広いトピックに触れる必要があるためここでは扱いません。

Function App の設定
- 基本
    - サブスクリプション：任意
    - リソース グループ：任意
    - 関数アプリ名：任意
    - 公開：コード
    - ランタイム スタック：.NET
    - バージョン：6
    - 地域：任意
- ホスティング
    - ストレージアカウント：任意
    - オペレーティング システム：Windows
    - プランの種類：消費量（サーバーレス）
- ネットワーク
    - ネットワーク インジェクションを有効にする：オフ（変更不可）
- 監視
    - Application Insights を有効にする：任意
- タグ
    - 既定

- Function の設定
    - 開発環境：ポータルでの開発
    - テンプレート：HTTP trigger 
    - 新しい関数：任意
    - Authorization level: Anonymous

作成した直後の Function は認証を必要としないためインターネット上からアクセスすることができます。PowerShell で以下のコマンドを実行するとステータス コードは 200 でアクセスに成功します。

```
PS> Invoke-RestMethod -Method Get -Uri https://<関数アプリ名>.azurewebsites.net/api/<新しい関数>
```




### Logic Apps の Managed ID の作成

Function に対して Managed ID で認証を行うために、Logic Apps で Managed ID を有効化します。プレイブック用に作成した Logic Apps の `ID` を `オン` に設定し、保存します。

![Managed Identity](./images/soar-logicapps-identity.png)

Managed ID を設定すると Azure AD のエンタープライズ アプリケーションに Logic Apps の名前に対応する Managed ID が作成されます。`フィルタで マネージド ID` を選択すると Managed ID が表示されます。

![Enterprise Application](./images/soar-logicapps-identity-app.png)

### Function によるアクセス制限

作成した関数アプリに認証を追加します。Function App のメニューから `認証` - `ID プロバイダーを追加` を選択します。

![Function Auth](./images/soar-function-authn.png)


`ID プロバイダーの追加` は以下の設定を行います。

- 基本
    - ID プロバイダー：Microsoft
    - アプリ登録の種類：アプリの登録を新規作成する
    - 名前：既定
    - サポートされているアカウントの種類：現在のテナント - 単一テナント
    - アクセスを制限する：認証が必要
    - 認証されていない要求：任意
    - トークンストア：既定
- アクセス許可
    - 既定

![Function ID Provider](./images/soar-function-idp.png)


作成された ID プロバイダー - `Microsoft(Function App名)` のハイパーリンクからから登録されたアプリケーションを開き、アプリケーション(クライアント) ID をコピーします。

![Function ID Provider](./images/soar-function-appid.png)


### Logic Apps からの Function の呼び出し 

Logic Apps から Function を呼び出すためには Logic Apps デザイナーで `Azure Functions` アクションを追加します。続く画面で `Function App` - `Function` の順に作成した Function を選択します。
![Action Functions](./images/soar-logicapps-action.png)

`要求本文` には Function で処理したいデータを指定します。`本文` を指定するとアラートのデータ全体が Function に渡されます。

`認証` にチェックを追加し、以下の設定を行います。
- 認証
    - 認証の種類：マネージドID
    - マネージドID：システム割り当てマネージドID
    - 対象ユーザー：コピーした Function App のアプリケーション（クライアント） ID  

![Action Functions](./images/soar-logicapps-authn.png)

Logic Apps を保存し、任意の分析ルールから起動すると、Function で Sentinel のアラートの情報をうけとることができます。アクセスには Managed ID による認証が使われています。
![Action Functions](./images/soar-logicapps-result.png)


認証を持たないアクセスは拒否されるため、インターネット上から匿名でアクセスすることはできません。Function の URL は処理結果を返すことがなくなります。応答は Function App の `認証` の設定によって異なり、既定では別の HTTP 302 で Microsoft サイトにリダイレクトされます。HTTP 401 や HTTP 403 のエラーコードを設定することもできます。

```
PS > Invoke-RestMethod -Method Get -Uri https://<関数アプリ名>.azurewebsites.net/api/<新しい関数>
```

## 参考リンク
[Azure Functions を使用してコードを作成し、Azure Logic Apps のワークフローから呼び出す](https://docs.microsoft.com/ja-jp/azure/logic-apps/logic-apps-azure-functions?tabs=consumption)

[チュートリアル: Microsoft Sentinel でオートメーション ルールとプレイブックを使用する](https://docs.microsoft.com/ja-jp/azure/sentinel/tutorial-respond-threats-playbook)

