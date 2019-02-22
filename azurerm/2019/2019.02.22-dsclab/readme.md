

AzureRM template for DSC Lab
============================

## 필요한 것 

* azure-cli 2.0

​    


## LAB Deployment

```powershell
PS > az group create -l koreacentral -n [RESOURCE GROUP] --verbose


PS > az group deployment create -g [RESOURCE GROUP] --template-file .\azuredeploy.json --parameters `@azuredeploy.parameters.json --verbose


PS> az vm list-ip-addresses -g [RESOURCE GROUP] -o table
VirtualMachine    PublicIPAddresses    PrivateIPAddresses
----------------  -------------------  --------------------
dc                XXX.YYY.ZZZ.OOO        10.63.1.11
pull              XXX.YYY.ZZZ.OOO        10.63.1.21
ms1               XXX.YYY.ZZZ.OOO        10.63.1.31
ms2               XXX.YYY.ZZZ.OOO        10.63.1.32

```

​    

​    

## DSC Lab 구성내용

- ActiveDirectory Domain 자동 구성

  - Domain Name: `DSCLAB.local`

    | Hostname | Private IP |
    | :------- | ---------- |
    | DC       | 10.63.1.11 |
    | PULL     | 10.63.1.21 |
    | MS1      | 10.63.1.31 |
    | MS2      | 10.63.1.32 |

  - Domain Administrator

    - Username  :  `dscadmin@DSCLAB.local` 또는  `DSCLAB\dscadmin`
    - Password :  `Pa$$w0rd1234!`



- VNet IP Address: 10.63.0.0/16
- 모든 서버는 Windows Server 2019 Datacenter를 사용한다.
  - VM Size는 `Standard_DS3_v2`
- DC, PULL, MS1, MS2 순서로 VM 생성된다. 
  - DC는 자동으로 `DSCLAB.local Forest`를 생성한다.
  - 멤버 서버인 PULL, MS1, MS2는 자동으로 DSCLAB.local 도메인에 가입된다.

- 총 Deployment 시간은 약 20 ~ 30분 정도 필요함

