## App Gateway 経由で App Service にアクセスする際のセキュアな CORS 設定方法

### はじめに

ウェブアプリケーションの開発において、CORS（クロスオリジンリソースシェアリング）の設定は非常に重要です。特に、App Gateway 経由で App Service にアクセスする際には、セキュリティを確保するために適切な CORS 設定が必要です。この記事では、セキュアな CORS 設定方法と Azure CLI を使用した具体的な設定手順、および JavaScript の axios を使用した例について詳しく解説します。

### ワイルドカード (`*`) の使用を避ける

`Access-Control-Allow-Origin` ヘッダーにワイルドカード (`*`) を使用すると、あらゆるドメインからのアクセスが許可されるため、セキュリティリスクが高まります。セキュアな設定を行うためには、信頼できるドメインのみを指定することが重要です。

#### 例
```json
{
  "AllowedOrigins": ["https://trusted-domain1.com", "https://trusted-domain2.com"]
}
```

#### Azure CLI 設定例
```bash
az webapp cors add --resource-group <ResourceGroupName> --name <AppName> --allowed-origins "https://trusted-domain1.com" "https://trusted-domain2.com"
```

### `Access-Control-Allow-Credentials` の使用は慎重に

`Access-Control-Allow-Credentials` ヘッダーは、クッキーやその他の資格情報をクロスオリジンリクエストに含めることを許可します。このヘッダーを有効にする場合は、信頼できるオリジンのみがリクエストできるように設定しましょう。

#### 例
```json
{
  "AllowCredentials": true
}
```

#### Azure CLI 設定例
`Access-Control-Allow-Credentials` は、直接 Azure CLI で設定することはできません。必要に応じて、アプリケーションのコードや設定ファイル内で適切に設定してください。

#### JavaScript (axios) 設定例
`Access-Control-Allow-Credentials` ヘッダーを使用する場合、JavaScript の axios を使用してリクエストを送信する方法は以下の通りです。

```javascript
const axios = require('axios');

axios.defaults.withCredentials = true;

axios.get('https://trusted-domain1.com/api/endpoint', {
  headers: {
    'Authorization': 'Bearer <your-token>'
  }
})
.then(response => {
  console.log(response.data);
})
.catch(error => {
  console.error('Error making request:', error);
});
```

### 許可するメソッドとヘッダーを明確に指定

許可する HTTP メソッド（例：GET, POST, PUT）やヘッダー（例：Content-Type, Authorization）を明確に指定することで、リクエストの種類を制限し、攻撃のリスクを減少させることができます。

#### 例
```json
{
  "AllowedMethods": ["GET", "POST", "PUT"],
  "AllowedHeaders": ["Content-Type", "Authorization"]
}
```

#### Azure CLI 設定例
こちらも `AllowedMethods` と `AllowedHeaders` は直接 Azure CLI で設定することはできません。必要に応じて、アプリケーションのコードや設定ファイル内で適切に設定してください。

#### JavaScript (axios) 設定例
指定したメソッドとヘッダーを使用してリクエストを送信する例です。

```javascript
const axios = require('axios');

axios.post('https://trusted-domain1.com/api/endpoint', {
  data: { key: 'value' }
}, {
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer <your-token>'
  }
})
.then(response => {
  console.log(response.data);
})
.catch(error => {
  console.error('Error making request:', error);
});
```

### 環境ごとに異なる CORS 設定を使用

開発、ステージング、本番などの環境ごとに異なる CORS 設定を使用することをお勧めします。本番環境では、必要なドメインのみを許可するように設定しましょう。

#### Azure CLI 設定例
環境ごとの設定は、それぞれの環境用に設定スクリプトを用意し、適切なリソースグループやアプリ名で実行してください。

```bash
# 開発環境用
az webapp cors add --resource-group <DevResourceGroupName> --name <DevAppName> --allowed-origins "https://dev-trusted-domain.com"

# ステージング環境用
az webapp cors add --resource-group <StagingResourceGroupName> --name <StagingAppName> --allowed-origins "https://staging-trusted-domain.com"

# 本番環境用
az webapp cors add --resource-group <ProdResourceGroupName> --name <ProdAppName> --allowed-origins "https://trusted-domain1.com" "https://trusted-domain2.com"
```

### 定期的な CORS ポリシーの見直しと更新

CORS ポリシーは一度設定したら終わりではありません。定期的に見直し、セキュリティ要件に合致しているかを確認し、不要なオリジンや設定を削除・更新することが重要です。

#### Azure CLI 設定例
CORS 設定を見直し、不要なオリジンを削除するには次のコマンドを使用します。

```bash
az webapp cors remove --resource-group <ResourceGroupName> --name <AppName> --allowed-origins "https://untrusted-domain.com"
```

### まとめ

CORS 設定はウェブアプリケーションのセキュリティにおいて非常に重要な要素です。具体的なドメイン、メソッド、ヘッダーのみを許可し、環境ごとに適切な設定を行うことで、セキュリティリスクを最小限に抑えることができます。定期的な見直しと更新を行い、常に最適な CORS 設定を維持しましょう。

