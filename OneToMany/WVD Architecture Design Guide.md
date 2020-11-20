# WVD アーキテクチャー デザイン ガイド (Powered By FTA)
このドキュメントは FTA (FastTrack for Azure) のメンバーによって管理されているものであり、WVD (Windows Virtual Desktop) 環境を新たに作成されようとしている方に対して WVD に対する理解を深め、多様なビジネス要件を満たすために WVD や Azure が提供している機能やそのつながりを理解してもらうために作成されたものです。

内容は FTA のメンバーによって適宜更新されますが、内容の正しさを保証するものではありません。WVD に関する最新の情報や WVD の正確な仕様を確認する場合は必ず[公式ドキュメント](https://docs.microsoft.com/ja-jp/azure/virtual-desktop/overview)を参照してください。

FTA (FastTrack for Azure) 組織については[こちら](https://azure.microsoft.com/ja-jp/programs/azure-fasttrack/)を参照ください。

## 1. 必要条件
WVD は Microsoft Azure 上で動作する仮想デスクトップを提供するサービスです。WVD を動作させるには最低限以下のコンポーネントが必要です。

- Azure サブスクリプション
- Azure AD テナント
- Windows Active Directory 環境（Azure Active Directory Domain Service でも可）
- 適切なライセンス（https://azure.microsoft.com/ja-jp/pricing/details/virtual-desktop）




### ライセンス
Windows Virtual Desktop 

## 2. コンセプト
## 3. ネットワーク要件
## 4. デザイン パータン
ここでは一般的なエンタープライズの環境で既存のオンプレミス Active Directory 環境を活用しつつ、セキュリティを意識した形で WVD を利用する場合によく採用される構成を幾つか説明します。

![networkdesign1](https://github.com/Azure/fta-japan/tree/main/OneToMany/images/newtworkdesign1.png)



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
