# WVD アーキテクチャー デザイン ガイド (Powered By FTA)
このドキュメントは FTA (FastTrack for Azure) のメンバーによって管理されているものであり、WVD (Windows Virtual Desktop) 環境を新たに作成されようとしている方に対して WVD に対する理解を深め、多様なビジネス要件を満たすために WVD や Azure が提供している機能やそのつながりを理解してもらうために作成したものです。

内容は FTA のメンバーによって適宜更新されますが、内容の正しさを保証するものではありません。WVD に関する最新の情報や WVD の正確な仕様を確認する場合は必ず[公式ドキュメント](https://docs.microsoft.com/ja-jp/azure/virtual-desktop/overview)を参照してください。また、ここでは Microsoft が提供する Native WVD についてのみ取り扱います。Citrix 社や VMWare 社によって提供される WVD については本資料では基本的には触れません。

FTA (FastTrack for Azure) 組織については[こちら](https://azure.microsoft.com/ja-jp/programs/azure-fasttrack/)を参照ください。

## 1. 必要条件
WVD は Microsoft Azure 上で動作する仮想デスクトップを提供するサービスです。WVD を動作させるには最低限以下のコンポーネントが必要です。

- Azure サブスクリプション
- Azure AD テナント
- Windows Active Directory 環境（Azure Active Directory Domain Service でも可）
- 適切なライセンス（https://azure.microsoft.com/ja-jp/pricing/details/virtual-desktop）

WVD は以下図のイメージでAzureサブスクリプションのvNet内に展開したVMにWVD Agentをインストールし、VDI として利用します。WVD を展開する際に必要となるコンポーネントについてご説明します。

![overalldesign](images/overalldesign1.png)

1．Active Directory Domain Service (ADDS)
- WVD VM が参加するドメインコントローラー
-  ADDS の選択肢は複数存在し、お客様のご要件に応じて柔軟に選択できます。
    - オンプレミスに存在する既存 AD
        - AzureとオンプレミスDCを専用線 / VPNで接続し、WVDで利用するAzure上のVMをオンプレミスのADに参加
    - Azure IaaS上に新規構築
    - Azure の AD サービス (Azure Active Directory Domain Service) を利用

2. Azure AD Connect
	- AD/DNSからUPNをAzure ADへ同期
	- 既存でAzure AD Connectを利用している場合は注意が必要
※AADCがサポートするトポロジ
	- Azure AD ConnectはWindows Serverに対してソフトウェアをインストールし、構成する
Azure AD ConnectでADからAzure ADへ同期する設定を実施する際には以下留意点が存在
・同期設定時、Azure ADのグローバル管理者権限をもったアカウントが必要
・同期設定時、ADへのエンタープライズ権限をもったアカウントが必要
・グローバル管理者は他のAzure ADからゲスト招待されているユーザーは不可

3. Azure AD
	- WVDにアクセスするユーザーはAzure ADの認証基盤でログイン認証を実施
	- 複数のAzure ADテナントが存在する場合は注意が必要
※構築の際に問題になることが多いPoint
	- WVDにアクセスする際にAADの多要素認証機能の利用が可能
・Azure AD Premier P1ライセンス以上が必要
	- AADにはWVDにアクセスするユーザーがADDSから同期されている
・別のAzure ADから招待されたゲストユーザー、AzureAD B2B はWVDへのアクセスが不可

![adtenant](images/adtenant.png)

4. Azure サブスクリプション
	- WVDのマシンを展開するAzureサブスクリプション
- WVDにアクセスするユーザーが存在するAzure ADテナントに紐づくAzureサブスクリプションが必要


## 2. コンセプト
<!--
2.	Concept of WVD (Managed Control plane and Win10 EVD and FSLogix are WVD specific)
-->
ここでは WVD とはいったい何なのか、従来の VDI / RDS ベースのソリューションとは一体どこが違うのか、主に技術的な観点で違いを説明します。

### マネージドな管理サーバー（WVD コントロール プレーン）
WVD とは既存のオンプレミス VDI (Virtual Desktop Infrastructure) や RDS (Remote Desktop Service) ソリューションを Microsoft Azure のクラウド サービスを使って置き換えるものです。
オンプレミスで VDI や RDS ソリューションを構築しようとすると、ホストへの接続を管理するブローカー サーバーやゲートウェイ サーバー、ライセンスを管理するライセンス サーバー、Web からのアクセスを受け付ける Web サーバーが必要でしたが、WVD ではこれらの管理系のサーバーが SaaS に近いマネージド サービスとして提供されるため、ユーザーがこれらの管理系のサーバーの運用や管理を行う必要がなくなります。また、1章で記載したライセンスを持っていればこれらの管理系のサービスに対する従量課金によるコストは発生しません。これが WVD を利用する上での大きなメリットになります。

![adtenant](images/managed_servers1.png)


### WVD 専用 OS 
WVD の利用形態は大きく分けて2つあります。VDI 型（仮想マシン占有型）と RDS 型 (仮想マシン共有型) です。

VDI 型で使用する OS はオンプレミスで使用する Windows 10 Enterprise (Professional は WVD では使用できません) と同じイメージを利用できますので、基本的には既存 VDI との違いは管理サーバーが Azure によるマネージド サービスかどうかだけです。

RDS 型では複数ユーザーによる同時ログインを実現するため、オンプレミスでは Windows Server がホスト OS として利用されてきましたが、WVD では Windows Server だけでなく、Windows 10 Enterprise Multisession という独自 OS を利用することが新たに可能になりました。この OS は WVD の利用を想定して Windows Server をベースに作成されたもので、従来の Windows 10 では実現できなかった複数ユーザーによる同時ログインを実現できるようになっており、これによって RDS 型のサービスを Windows 10 で提供することができるようになりました。

![windows10evd](images/windows10EVD.png)


### FSLogix によるプロファイル管理
主に Windows 10 Multisession OS に対する付加価値を与える機能として、従来の RDS ソリューションで使用されていたリモート ユーザー プロファイルは、FSLogix という Microsoft が買収した製品によって置き換わりました。Windows 10 Multisession を使用する際には必ず FSLogix を使わなければならないということではありませんが、パフォーマンスや信頼性に優れ、また GPO による細かな管理も可能であることから、仮想マシン共有型（プール型）で WVD を利用する際には利用が推奨されています。
  

## 3. ネットワーク要件
<!--
3.	WVD Networking (Required Traffic for both WVD session-host and client device)
-->
上述したように WVD ではゲートウェイや Web アクセスのためのサーバーがサービス化され、それらのサーバーに対する管理が必要なくなった半面、ユーザーが管理する必要があるセッション ホストと、Microsoft によって提供される管理系のサーバーが完全に分離された形となっています、そのため、これらがお互いに通信して WVD がサービスとして正常に動作するためのネットワークについては、オンプレミスとは全く異なる設計や考慮が必要になります。

具体的には以下のようなものになります。

###  1. オンプレミス Active Directory と Azure Active Directory の同期
WVD を利用する前提条件として記載したように、WVD は基本的にはオンプレミス Active Directory （もしくは Azure Active Directory Domain Service）と同期された Azure Active Directory が必要になります。これらは基本的には Azure AD Connect によりユーザーが同期されている必要がありますので、同期のためのネットワーク接続が必要です。

### 2. クライアントからの接続
WVD を使用したセッションホストへの接続は WVD コントロール プレーンと呼ばれるインターネットに公開されたエンドポイント経由で実施します。言い換えると、インターネット カフェやスマートフォンなどからもネットワーク的には接続が可能な状態となっているため、必要に応じてこれらのパブリック エンドポイントへのアクセスを制限するための考慮が必要になります。

WVD コントロールプレーンへの接続時には Azure AD での認証となるため、Azure AD 側の設定で MFA (Multi Factor Authentication) を導入したり、アクセス可能なソース IP 範囲を限定するような対応が一般的です（これらを利用するには Azure AD 条件付きアクセスという Azure AD Premium で利用できる機能が必要です）。

### 3. セッションホストと WVD コントロール プレーン間の接続
ユーザーが管理する Azure Virtual Network 内のセッションホストとパブリックなエンドポイントを持つ WVD コントロールプレーン間のネットワーク接続が必要です。細かい内容は [こちら](https://azure.microsoft.com/ja-jp/programs/azure-fasttrack/) を参照してもらえればと思いますが、具体的にはクライアントとの画面転送のためのトラフィックや、必要なエージェントをダウンロードしたり更新したりするための通信等となります。

### 4. セッションホストからインターネットへの接続
こちらは WVD 特有という意味ではありませんが、ユーザーがセッションホストに接続した後のインターネット接続に対する考慮が必要です。既定では Azure Virtual Network (Vnet) からインターネットに向けた通信は許可されており、監視等もされていないため、必要に応じてアクセスを制限したリプロキシ サーバーや Azure Firewall を経由させるなどの考慮が必要になります。こちらは WVD セッションホストに限らず、Virtual Machine を Azure 上にデプロイする際に一般的に考慮する必要があるものになります。










## 4. デザイン パターン
ここでは一般的なエンタープライズ環境で既存のオンプレミス Active Directory 環境を活用しつつ、WVD を利用する場合によく採用される構成を紹介します。

<!--
<img src="https://github.com/Azure/fta-japan/blob/main/OneToMany/images/NetworkDesign1.png" width=50%>
-->

### インターネット接続分離パターン
---

***
![networkdesign1](images/NetworkDesign1.png)
***

赤枠で囲っている仮想ネットワークに WVD のホストプールを配置しています。ホストプールが必要とする通信は大きく分けて2種類あり、一つは接続元のクライアントと WVD コントロールプレーンを経由した画面転送に関するもの。もう一つはホストプール接続後の Office 365 の利用や通常の Web ブラウジング等の通信で利用するものです。
多くのエンタープライズ環境では自社内にプロキシサーバーを設置しており、社内からインターネットへのアクセスにはプロキシサーバーを要件としている場合が多々あります。



1. 


## 5. ログとモニタリング
## 6. 各種ツール

<!---

7.	WVD  ID Security (Optional) 
  i.	Azure AD Conditional Access (Azure AD Premium) 
  ii.	Intune 
  iii.	MDATP
8.	WVD Image management (Optional) 
  i.	Capture images 
  ii.	Shared Image Gallery 
9.	WVD Misc (Optional)
  i.	vCPU Quota
  ii.	Scale limit (https://docs.microsoft.com/ja-jp/azure/architecture/example-scenario/wvd/windows-virtual-desktop)

-->
