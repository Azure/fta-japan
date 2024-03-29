# 仮想ネットワーク

## Q: Private Endpoint に対応したサービスをオンプレミスから利用する場合のベストプラクティスを教えてください

> **(注意事項)** 一般的なガイダンスについては[こちらの公式ドキュメント](https://docs.microsoft.com/ja-jp/azure/private-link/private-endpoint-dns#on-premises-workloads-using-a-dns-forwarde)にまとめられています。
より詳細な内容や内部動作についての情報が必要な場合はマイクロソフト社員によって書かれた[こちらの Github ページ(英文のみ)](https://github.com/dmauser/PrivateLink/tree/master/DNS-Integration-Scenarios)から確認できます。

>ここで記載する内容は上述のドキュメントに則った上で、それを補足する目的で記載するものです。

オンプレミスから Private Endpoint (Private IP) 経由で Azure PaaS サービスに接続する際に最も重要なポイントはオンプレミス側からの名前解決です。これを実現する場合のベストプラクティスはオンプレミス側の既存の DNS サーバーに条件付きフォワーダーの設定を追加し、PaaS サービスの種類毎に存在する DNS ゾーンに対する名前解決要求を Azure 側にフォワードすることになります。

この流れを一枚の絵にすると、以下のようになります。
![overalldesign](images/image15.png)
>https://github.com/dmauser/PrivateLink/tree/master/DNS-Integration-Scenarios からの引用

以下、このベストプラクティスを採用した場合の設計上のポイントについて、この図の中に記載されている登場人物とその役割を解説しながら説明していきます。

- Private Endpoint リソース
    - PaaS サービスに対して Private IP で接続する際に必要なリソースです。FQDN に対する名前解決要求は最終的にこの Private IP に解決されます。

- Private DNS リソース
    - Azure PaaS サービスに対する名前解決要求は既定で Public IP に解決されますが、それを Private Endpoint の Private IP に解決するよう上書きするために必要です。Private Endpoint リソース作成時に既定で作成されます。Private DNS リソースは任意の仮想ネットワーク (VNet) リソースに関連付けることで、その仮想ネットワーク内だけで有効になります。

- Azure 提供の DNS (IP アドレス：168.63.129.16)
    - Azure 上の VM からの名前解決要求を受け付けるために既定で用意されている DNS サービス (固定の IP アドレス) です。Azure VNet からのみアクセスでき、オンプレからはアクセスできません。上述した Private DNS リソースへの設定は VNet 内の VM がこの DNS サービス（168.63.129.16）を参照する際にのみ動作します。これがオンプレミスから直接 Private DNS を参照して Private Endpoint の Private IP に解決することができない理由です。

- Azure 上のカスタム DNS サーバー VM (Azure Firewall で代替可能)
    - Private DNS を紐づけた VNet 内に配置する DNS サーバーです。オンプレミス側からフォワードされた名前解決要求を受け、 PaaS サービスの FQDN を Private IP に解決するために必要です。VM を配置しない場合はマネージドな Firewall サービスである Azure Firewall で代替することもできます。その場合は[こちらのドキュメント](https://docs.microsoft.com/ja-jp/azure/firewall/dns-settings#dns-proxy-configuration)に従って設定できます。

- オンプレミス上の DNS サーバー
    - オンプレミスにある既存の DNS サーバーに条件付きフォワーダーの設定が必要です。例えば Blob ストレージ サービスに対して Private Endpoint でアクセスしたい場合には上述した図のように "blob.core.windows.net" ゾーンに対する名前解決要求を上述した "Azure 上の カスタム DNS サーバー" の IP にフォワードするように条件付きフォワーダーの設定を追加する必要があります。これは Private Endpoint を利用したい PaaS サービスの種類毎に追加する必要があります。サービス毎のゾーンの一覧は[こちらのドキュメント](https://docs.microsoft.com/ja-jp/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration)に纏められています。

オンプレミスからの名前解決要求はこれら5つの要素が上述した図の番号の順序で連携することで初めて動作します。一度こちらの仕組みができてしまえば、同じ種類の PaaS サービス（2つめ以降の Blob ストレージなど）に対して Private Endpoint リソースを作成した場合でもオンプレミス側での追加の設定なしにそれを利用できるようになります。

また、この仕組みを使う場合の注意点は以下の通りです。

- Private Endpoint を設定していない既存の PaaS サービスに対する影響
    - 例えばオンプレミスから Private Endpoint の設定をしていない Blob ストレージ サービスにアクセスする場合でも、名前解決要求は条件付きフォワーダーの設定に従って Azure 上の DNS サーバーに転送されます。結果として返される Public IP は設定前と同じであり、Public IP が返された後の実データの流れも以前と同じですが、DNS クエリーのネットワークフローが変わることについては注意が必要です。そのため DNS システムの可用性を考えると Azure 上に設置する DNS サーバー VM は2台以上で冗長化するか、既定で冗長構成が取られている Azure Firewall を利用することが望ましいと考えられます。

- 別拠点からの Private Endpoint の利用
    - 条件付きフォワーダーの設定がオンプレミス上の別の拠点に複製されない場合は上記の仕組みが動作しないため、別途その拠点の DNS サーバーに対して条件付きフォワーダーの設定を追加する必要があります。この場合はその拠点から Azure 上の DNS サーバー VM や Private Endpoint に対してネットワーク的に到達可能であることを予め確認しておく必要があります。

