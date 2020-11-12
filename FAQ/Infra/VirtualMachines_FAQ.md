# 仮想マシン

## Q: VM の OS ディスクを小さくすることは可能でしょうか？　　
A: できません。基本的にどのディスクでもサイズを大きくすることはできても小さくすることはできません。詳細は下記のドキュメントを参照してください。なお、 Azure Market Place の Windows Server のイメージには、[smalldisk] とラベルされた30GBサイズのイメージも用意されていますので、これを使って VM をデプロイすると、OS ディスクが30GBで作成され、大きなディスク容量が不要な場合コストを節約できます。ポータルから Market Place -> Windows Server -> 「作成」でドリルダウンすると、様々なバージョンの Windows Servr について、通常サイズまたは smalldisk サイズのイメージが表示され選択することができます。
**マネージドディスクのサイズを変更する** https://docs.microsoft.com/ja-jp/azure/virtual-machines/windows/expand-os-disk#resize-a-managed-disk  

## Q: VM 2台で可用性セットを構成する場合、2台分のサーバー構築および費用が必要になりますか？　　
A: 可用性セット自体には追加の費用はかかりませんので、2台の VM で可用性セットを構成する場合、VM 2台分の費用となります。VM の料金については下記のドキュメントを参照してください。  
**可用性セット** https://docs.microsoft.com/ja-jp/azure/virtual-machines/availability#availability-sets  
**Windows Virtual Machines の料金** https://azure.microsoft.com/ja-jp/pricing/details/virtual-machines/windows/  
**Linux Virtual Machines の料金** https://azure.microsoft.com/ja-jp/pricing/details/virtual-machines/linux/  

## Q: 可用性セットを構成せずに VM をデプロイした場合でも、同一ラック内で、ホストや電源、スイッチなどは冗長構成は取られていますか？  
A: 可用性セットを構成しない場合、VM は1台の物理ハードウェア上でホストされ、冗長化されていないため、ホストを収納するラックのスイッチや電源の故障の影響から免れることはできません。単一 VM の SLA は、接続されるマネージドディスクの種類によって異なります。詳細は下記のドキュメントを参照してください。  
**可用性セット** https://docs.microsoft.com/ja-jp/azure/virtual-machines/availability#availability-sets  
**仮想マシンの SLA** https://azure.microsoft.com/ja-jp/support/legal/sla/virtual-machines/v1_9/  

## Q: VM 2台で可用性セットを組む場合、VM 2台間のデータ同期はどうなるのでしょう？例えば、DB 2台で可用性セットを組む場合、ユーザーはどちらか一方のサーバーのデータを更新するが、そのデータはいつ、どうやって他方に同期されるのでしょうか？2台ともに動いている状態でしょうか？  
A: データを同期する仕組みは別に用意しなければいけません。例えば、SQL Server Always-On 可用性グループを構成する場合は、SQL Server自体がデータをレプリケートする役割を持ちます。あるいは、FCI(Failover Cluster Instance)を構成する場合は、1) Azure 共有ディスクを使う 2) S2Dクラスターを構成する 3) Premium 共有ファイルを利用する 4) 3rd partyツール（SIOS DataKeeper, NEC ClusterPro等）を使ってディスクのレプリケーションを行う、といった手法が使われます。詳細は下記のドキュメントを参照してください。  
**Azure のみ:高可用性ソリューション** https://docs.microsoft.com/ja-jp/azure/azure-sql/virtual-machines/windows/business-continuity-high-availability-disaster-recovery-hadr-overview#azure-only-high-availability-solutions    

## Q: サーバー構築時に VM にパブリック IP アドレスを付加しました。サーバー構築後はパブリック IP アドレスは不要のため、プライベート IP アドレスを残したまま、パブリック IP アドレスを削除できますか？削除した場合、後からパブリック IP アドレスを付加できますか？  
A: VM のネットワークインターフェースの IP 構成から、パブリック IP アドレスの関連付けを解除することができます。その後、必要に応じて、パブリック IP アドレスのリソースを削除します。同様に、新規のパブリック IP アドレスを作成して、VM のネットワークインターフェースに関連付けることが可能です。詳細は下記のドキュメントを参照してください。  
**パブリック IP アドレスの関連付けを VM から削除する** https://docs.microsoft.com/ja-jp/azure/virtual-network/remove-public-ip-address-vm  
**VM VM へのパブリック IP アドレスの関連付け**   https://docs.microsoft.com/ja-jp/azure/virtual-network/associate-public-ip-address-vm  
