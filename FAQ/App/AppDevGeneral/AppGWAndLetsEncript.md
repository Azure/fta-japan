# はじめに

HTTP/2 のメリットやセキュリティの観点から、常時 SSL/TLS にすることが推奨されています。2018年7月リリースの Google Chrome 68 より SSL/TLS ないサイトについて、接続が保護されていないと警告が出るようになっています。また、2017年1月より iOS アプリから接続される Web ページの SSL/TLS の利用が必須となっています。

また、Azure では、App Service や Front door では、Microsoft が発行する証明書を利用することができますが、Application Gateway では、認証局による証明書の発行が必要です。自己認証局＋自己署名証明書でも良いのですが、こちらも上記クライアントの警告対象となるので、やはり信頼のある認証局を利用するのが一般的です。

- App Service の例
[TLS/SSL 証明書を追加および管理する - Azure App Service | Microsoft Docs](https://docs.microsoft.com/ja-jp/azure/app-service/configure-ssl-certificate?tabs=apex%2Cportal#create-a-free-managed-certificate)

- Front door の例
[チュートリアル - Azure Front Door 用のカスタム ドメインで HTTPS を構成する | Microsoft Docs](https://docs.microsoft.com/ja-jp/azure/frontdoor/front-door-custom-domain-https)

上記の理由により、証明書を使いたいけれど、テスト目的なので証明書を発行するためにコスト負担したくないというお悩みがあると思います。それを解決するのが、米国の非営利団体 Internet Security Research Group が管理する Let's encript です。

[Let's Encrypt - フリーな SSL/TLS 証明書 (letsencrypt.org)](https://letsencrypt.org/ja/)

Let's Encript では、ACME（アクミー）プロトコルを使ってドメイン所有者を確認します。

[RFC 8555 - Automatic Certificate Management Environment (ACME) (ietf.org)](https://datatracker.ietf.org/doc/html/rfc8555)

## 手順

### Windows の場合

- 前提条件
  - [GitHub - win-acme/win-acme: A simple ACME client for Windows (for use with Let's Encrypt et al.)](https://github.com/win-acme/win-acme) がインストールされていること

#### 証明書の発行

1. 管理者権限を持つ Powershell もしくは Windows Terminal を起動

2. wacs.exe を実行  
![image001](./AppGWAsset/Pasted%20image%2020220329101625.png)

3. "N"を選択  
![image002](./AppGWAsset/Pasted%20image%2020220329101712.png)

4. "2"を選択  
![image003](./AppGWAsset/Pasted%20image%2020220329101757.png)

5. ドメイン名を入力  
![image004](./AppGWAsset/Pasted%20image%2020220329101854.png)

6. "6" を選択  
![image005](./AppGWAsset/Pasted%20image%2020220329102633.png)

7. "2" を選択  
![image006](./AppGWAsset/Pasted%20image%2020220329102705.png)

8. "3" を選択  
![image007](./AppGWAsset/Pasted%20image%2020220329102955.png)

9. "." を入力  
![image008](./AppGWAsset/Pasted%20image%2020220329103019.png)

10. "2" を入力し、パスワードを入力、"n"を入力  
※パスワードは後ほど証明書を AppGW に追加するときに使います。  
![image009](./AppGWAsset/Pasted%20image%2020220329103223.png)

11. "5" を入力  
![image010](./AppGWAsset/Pasted%20image%2020220329103309.png)

12. "3" を入力  
![image011](./AppGWAsset/Pasted%20image%2020220329103427.png)

13. "n" を入力、"y" を入力、問い合わせ先メールアドレスを入力  
![image012](./AppGWAsset/Pasted%20image%2020220329103752.png)

14. 当該ドメインを管理しているDNSサーバーに対して、上記のレコードを登録する。※Azure DNSの例 ダブルクオートは入れない  
![image013](./AppGWAsset/Pasted%20image%2020220329104043.png)

15. Enter を入力  
![image014](./AppGWAsset/Pasted%20image%2020220329104346.png)

16. レコードを削除し、Enterを入力  
![image015](./AppGWAsset/Pasted%20image%2020220329104708.png)

17. "n" を入力  
![image016](./AppGWAsset/Pasted%20image%2020220329104821.png)

18. 最後に "q" を入力
19. 証明書の存在を確認  
![image017](./AppGWAsset/Pasted%20image%2020220329105025.png)

##### Application Gateway への登録

1. Listeners を選択  
![image018](./AppGWAsset/Pasted%20image%2020220329105537.png)

1. Add listener を選択  
![image019](./AppGWAsset/Pasted%20image%2020220329105558.png)

1. 設定を入れる、Addを押下  
![image020](./AppGWAsset/Pasted%20image%2020220329105730.png)

#### WSL/Linux/Mac の場合

※こちらの項目は編集中です。
certbot を使う

