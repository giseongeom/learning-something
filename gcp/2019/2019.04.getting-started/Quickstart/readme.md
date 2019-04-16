HOW TO BUILD & DEPLOY
============================


## Create deployment

- `gcloud deployment-manager deployments create [DEPLOYMENT_NAME] --config [DEPLOYMENT_CONFIG.yaml]`

```powershell
PS > gcloud deployment-manager deployments create quickstart --config vm.yaml

The fingerprint of the deployment is wBuD08qjWiAPONGEoasZgw==
Waiting for create [operation-1555377230618-5869b7b52a094-06135c93-7117038e]...done.
Create operation operation-1555377230618-5869b7b52a094-06135c93-7117038e completed successfully.
NAME                         TYPE                 STATE      ERRORS  INTENT
quickstart-deployment-vm-jp  compute.v1.instance  COMPLETED  []
```



## List and view details of deployment 

- `gcloud deployment-manager deployments list`
- `gcloud deployment-manager deployments describe [DEPLOYMENT_NAME]`
- `gcloud compute instances list`

```powershell
PS > gcloud deployment-manager deployments list
NAME        LAST_OPERATION_TYPE  STATUS  DESCRIPTION  MANIFEST                ERRORS
quickstart  insert               DONE                 manifest-1555377230995  []


PS > gcloud deployment-manager deployments describe quickstart
---
fingerprint: ****
id: '****'
insertTime: '2019-04-15T18:13:50.993-07:00'
manifest: manifest-1555377230995
name: quickstart
operation:
  endTime: '2019-04-15T18:14:35.138-07:00'
  name: operation-1555377230618-5869b7b52a094-06135c93-7117038e
  operationType: insert
  progress: 100
  startTime: '2019-04-15T18:13:51.017-07:00'
  status: DONE
  user: ****
NAME                         TYPE                 STATE      INTENT
quickstart-deployment-vm-jp  compute.v1.instance  COMPLETED


PS > gcloud compute instances list
NAME                         ZONE               MACHINE_TYPE  PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP    STATUS
quickstart-deployment-vm-jp  asia-northeast1-c  f1-micro                   10.146.0.7   35.243.118.89  RUNNING
```


## Delete deployment


- `gcloud deployment-manager deployments delete [DEPLOYMENT_NAME]`


```powershell
PS > gcloud deployment-manager deployments delete quickstart
The following deployments will be deleted:
- quickstart

Do you want to continue (y/N)?  y

Waiting for delete [operation-1555381151413-5869c650534e7-361ef802-de065791]...done.
Delete operation operation-1555381151413-5869c650534e7-361ef802-de065791 completed successfully.

PS > gcloud compute instances list
Listed 0 items.
```
