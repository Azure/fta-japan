# 仮想ネットワーク

## Q: Private Endpoint に対応したサービスをオンプレミスから利用する場合のベストプラクティスを教えてください

> **(注意事項)** 一般的なガイダンスについては[こちらの公式ドキュメント](https://docs.microsoft.com/ja-jp/azure/private-link/private-endpoint-dns#on-premises-workloads-using-a-dns-forwarde)にまとめられています。
より詳細な内容や内部動作についての情報が必要な場合はマイクロソフト社員によって書かれた[こちらの Github ページ(英文のみ)](https://github.com/dmauser/PrivateLink/tree/master/DNS-Integration-Scenarios)から確認できます。

>ここで記載する内容は上述のドキュメントに則った上で、それを補足する目的で記載するものです。

オンプレミスから Private Endpint (Private IP) 経由で Azure PaaS サービスに接続する際に最も重要なポイントはオンプレミス側からの名前解決をどうするかということです。これを実現する場合のベストプラクティスはオンプレミス側で名前解決を行う DNS サーバー側で条件付きフォワーダーを設定し、特定のゾーンに対する名前解決要求を Azure 側にフォワードすることになります。

この流れを一枚の絵にすると、以下のようになります。
![overalldesign](images/image15.png)
>https://github.com/dmauser/PrivateLink/tree/master/DNS-Integration-Scenarios からの引用

まず、この図の中に記載されている登場人物と役割について解説します。

1. Private Endpoint リソース
    - PaaS サービスに対して Private IP で接続する際に必要なリソースです。FQDN に対する名前解決要求は最終的にこの Private IP に解決されます。

2. Private DNS リソース
    - Azure PaaS サービスに対する名前解決要求は既定で Public IP に変換されますが、それを Private IP に変換されるように上書きするために必要です。Private Endpoint リソース作成時に既定で作成されます。Private DNS リソースは任意の仮想ネットワーク (VNet) リソースに関連付けることで、その仮想ネットワーク内だけで有効になります。

3. Azure 提供の DNS (168.63.129.16)
    - Azure 上の VM からの名前解決要求を受け付けるために既定で用意されているサービスです。Azure 内部からのみアクセスでき、オンプレからはアクセスできません。(2) の Private DNS の設定は VM がこの DNS サービス（168.63.129.16）を参照する際にのみ動作します。

3. Azure 上のカスタム DNS サーバー VM (Azure Firewall で代替可能)
    - (2) で Private DNS を紐づけた VNet 内に DNS サーバー VM を配置し、オンプレミス側からフォワードされた名前解決要求を Private IP に解決します。VM を配置しない場合はマネージドな L7 Firewall サービスである Azure Firewall を利用することもできます。その場合は[こちらのドキュメント](https://docs.microsoft.com/ja-jp/azure/firewall/dns-settings#dns-proxy-configuration)に従って設定できます。

4. オンプレミス上の DNS サーバー
    - オンプレミス上で名前解決を行う既存の DNS サーバー対して条件付きフォワーダーの設定が必要です。例えば Blob ストレージ サービスに対して Private Endpint でアクセスしたい場合には上述した図のように "blob.core.windows.net" ゾーンに対する名前解決要求を (4) で設置した Azure 上の DNS サーバーの IP にフォワードするように条件付きフォワーダーの設定を追加する必要があります。これは Private Endpoint を利用したい PaaS サービス毎に追加する必要があります。サービス毎のゾーンの一覧は[こちらのドキュメント](https://docs.microsoft.com/ja-jp/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration)に纏められています。

オンプレミスからの名前解決要求は上述した5つの要素が上述した図の番号の順序で連携することで初めて動作します。一度こちらの仕組みができてしまえば、同じ種類の PaaS のサービス（2つめ以降の Blob ストレージなど）を Private Endpoint 経由で作った場合でも追加の設定なしにそれを Private IP 経由で利用できるようになります。

また、この仕組みを使う場合の注意点は以下の通りです。

1. Private Endpint を設定していないリソースに対する名前解決
    - 例えばオンプレミスから Blob ストレージ サービスにアクセスする場合、そのリソースに対して Private Endpoit の設定をしていない場合でも名前解決要求は条件付きフォワーダーの設定に従って Azure 上の DNS サーバーに転送されます。結果として返される Public IP は設定前と同じであり、Public IP が返された後の実データの流れも以前と同じですが、DNS クエリーのネットワークフローが変わることについては注意が必要です。DNS システムの可用性を考えると Auzre 上に設置する DNS サーバー VM は2台以上で冗長化するか、既定で冗長構成が取られている Auzre Firewall を利用することが望ましいと考えられます。

2.　別拠点からの Private Endpoint の利用
    - 条件付きフォワーダーの設定が複製されないオンプレミス上の別の拠点からは上記の仕組みが動作しないため、別途条件付きフォワーダーの設定を追加する必要があります。その場合はその拠点から Azure 上の DNS サーバー VM や Private Endpoint に対してネットワーク的に到達可能であることを予め確認しておきます。

