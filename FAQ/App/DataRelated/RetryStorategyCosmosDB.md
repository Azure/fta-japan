
# Cosmos DB でのリトライ戦略

CosmosDB SDK のリトライ戦略
### 1. **固定リトライ (Fixed Retry)**

固定リトライは、エラーが発生した場合に、一定の時間間隔でリトライを行う戦略です。この戦略では、リトライ間の待機時間が常に一定です。

- **特徴**: 一貫したリトライ間隔を使用するため、シンプルですが、システムの負荷が高い場合には適切でない場合があります。
- **適用例**: 短期間のネットワーク遅延が頻発する環境での再試行に向いています。

```typescript
const options = {
    retryOptions: {
        maxRetryAttemptsOnThrottledRequests: 5,  // リトライ回数
        fixedRetryIntervalInMilliseconds: 1000, // リトライ間隔
    }
};
const client = new CosmosClient({ endpoint, key, options });
```

### 2. **指数的バックオフ (Exponential Backoff)**

指数的バックオフは、リトライの間隔をリトライごとに増加させる戦略です。初回リトライは短い間隔で行われ、その後のリトライは徐々に時間を増加させていきます。

- **特徴**: サーバーへの負荷を軽減するために効果的で、サーバーが一時的に過負荷になっている場合などに適しています。一定回数を超えるとリトライを停止します。
- **適用例**: サーバーが過負荷状態やレート制限に達している場合に有効です。

```typescript
const options = {
    retryOptions: {
        maxRetryAttemptsOnThrottledRequests: 5,  // リトライ回数
        initialRetryIntervalInMilliseconds: 100, // 初回リトライ間隔
        maxRetryWaitTimeInSeconds: 30,           // 最大リトライ待機時間
    }
};
const client = new CosmosClient({ endpoint, key, options });
```

### 3. **カスタムリトライ戦略 (Custom Retry Strategy)**

CosmosDB SDK では、独自のリトライロジックを定義することも可能です。特定の条件やビジネスロジックに基づいてリトライをカスタマイズできます。例えば、特定のステータスコードやエラーが発生した場合にのみリトライを行うなどの制御が可能です。

- **特徴**: より柔軟なリトライ制御が可能で、特定の条件でのみリトライしたい場合に適しています。
- **適用例**: 特定のエラーに対してだけリトライを実行したい場合や、リトライのタイミングを柔軟に管理したい場合に有効です。

```typescript
const customRetryLogic = (error) => {
    // 例: 404エラーはリトライしない
    if (error.code === 404) {
        return false;
    }
    return true; // その他のエラーはリトライする
};

const options = {
    retryOptions: {
        maxRetryAttemptsOnThrottledRequests: 5,
        maxRetryWaitTimeInSeconds: 30,
        customRetryPolicy: customRetryLogic // カスタムリトライロジック
    }
};

const client = new CosmosClient({ endpoint, key, options });
```

### 4. **サーキットブレーカー (Circuit Breaker) の導入**

リトライ戦略に加えて、リトライを繰り返しすぎるとサービスに悪影響が出る可能性があるため、サーキットブレーカーを導入することも検討できます。これにより、失敗が続く場合は一定時間リトライを停止して、システムの負荷を軽減することが可能です。

### まとめ

CosmosDB SDK のリトライ戦略には、シンプルな固定リトライから、指数的バックオフ、カスタムリトライ戦略まで複数の選択肢があります。使用するケースやアプリケーションの要件に応じて、最適な戦略を選ぶことが重要です。