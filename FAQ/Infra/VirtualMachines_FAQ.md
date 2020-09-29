# 仮想マシン

## Q: VM の OS ディスクを小さくすることは可能でしょうか？　　
A: できません。基本的にどのディスクでもサイズを大きくすることはできても小さくすることはできません。詳細は下記のドキュメントを参照してください。  
**マネージドディスクのサイズを変更する** https://docs.microsoft.com/ja-jp/azure/virtual-machines/windows/expand-os-disk#resize-a-managed-disk  

## Q: VM 2台で可用性セットを構成する場合、2台分のサーバー構築および費用が必要になりますか？　　
A: 可用性セット自体には追加の費用はかかりませんので、2台の VM で可用性セットを構成する場合、VM 2台分の費用となります。VM の料金については下記のドキュメントを参照してください。  
**Windows Virtual Machines の料金** https://azure.microsoft.com/ja-jp/pricing/details/virtual-machines/windows/  
**Linux Virtual Machines の料金** https://azure.microsoft.com/ja-jp/pricing/details/virtual-machines/linux/  

## Q: VM 2台で可用性セットを組む場合、VM 2台間のデータ同期はどうなるのでしょう？例えば、DB 2台で可用性セットを組む場合、ユーザーはどちらか一方のサーバーのデータを更新するが、そのデータはいつ、どうやって他方に同期されるのでしょうか？2台ともに動いている状態でしょうか？  
A: データを同期する仕組みは別に用意しなければいけません。例えば、SQL Server Always-On 可用性グループを構成する場合は、SQL Server自体がデータをレプリケートする役割を持ちます。あるいは、FCI(Failover Cluster Instance)を構成する場合は、1) S2Dクラスターを構成する 2) Premium 共有ファイルを利用する 3) 3rd partyツール（SIOS DataKeeper, NEC ClusterPro等）を使ってディスクのレプリケーションを行う、といった手法が使われます。詳細は下記のドキュメントを参照してください。  
**Azure のみ:高可用性ソリューション** https://docs.microsoft.com/ja-jp/azure/azure-sql/virtual-machines/windows/business-continuity-high-availability-disaster-recovery-hadr-overview#azure-only-high-availability-solutions    
なお、この上記ドキュメントに記載されている、Premium SSDを使った共有ディスクは、まだ米国中西部リージョンでしかサポートされていません。(2020年9月29日現在)　　
