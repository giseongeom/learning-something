# GKE 2대 생성
## Create 1st gke
```bash
$ gcloud container clusters create demo-gke-gcgs-1 \
    --cluster-version=1.21 \
    --tags=game-server \
    --scopes=gke-default \
    --num-nodes=3 \
    --no-enable-autoupgrade \
    --machine-type=e2-standard-2 \
    --zone=asia-northeast3-a
```

## Create 2nd gke
```bash
$ gcloud container clusters create demo-gke-gcgs-2 \
    --cluster-version=1.21 \
    --tags=game-server \
    --scopes=gke-default \
    --num-nodes=3 \
    --no-enable-autoupgrade \
    --machine-type=e2-standard-2 \
    --zone=asia-northeast3-a
```

# Agones 설치
## Prepare helm
```bash
$ helm repo add agones https://agones.dev/chart/stable
$ helm repo update
$ helm install my-release --namespace agones-system --create-namespace agones/agones
```

## Install agones / 1st gke
```bash
$ kubectl config use-context gke_serviceinfratest_asia-northeast3-a_demo-gke-gcgs-1
$ helm install my-release --namespace agones-system --create-namespace agones/agones
```

## Install agones / 2nd gke
```bash
$ kubectl config use-context gke_serviceinfratest_asia-northeast3-a_demo-gke-gcgs-2
$ helm install my-release --namespace agones-system --create-namespace agones/agones
```


# Allocator service 유효한 인증서 설정
## Allocator service / 1st gke
```bash
$ kubectl config use-context gke_serviceinfratest_asia-northeast3-a_demo-gke-gcgs-1
$ kubectl get svc -n agones-system
$ EIP=$(kubectl get svc agones-allocator -n agones-system -o json | jq -r '.status.loadBalancer.ingress[0].ip')
$ echo $EIP
$ helm upgrade my-release --install --set agones.allocator.http.loadBalancerIP=$EIP --set agones.allocator.service.loadBalancerIP=$EIP --namespace agones-system --create-namespace agones/agones
```

## Allocator service / 2nd gke
```bash
$ kubectl config use-context gke_serviceinfratest_asia-northeast3-a_demo-gke-gcgs-2
$ kubectl get svc -n agones-system
$ EIP=$(kubectl get svc agones-allocator -n agones-system -o json | jq -r '.status.loadBalancer.ingress[0].ip')
$ echo $EIP
$ helm upgrade my-release --install --set agones.allocator.http.loadBalancerIP=$EIP --set agones.allocator.service.loadBalancerIP=$EIP --namespace agones-system --create-namespace agones/agones
```

# Citadel 설치
## Citadel / 1st gke
```bash
$ git clone -b release-1.5 https://github.com/istio/istio.git

$ kubectl config use-context gke_serviceinfratest_asia-northeast3-a_demo-gke-gcgs-1
$ kubectl create ns istio-system
$ helm template istio/install/kubernetes/helm/istio --name-template istio --namespace istio-system \
    -s charts/security/templates/serviceaccount.yaml \
    -s charts/security/templates/clusterrole.yaml \
    -s charts/security/templates/clusterrolebinding.yaml \
    -s charts/security/templates/deployment.yaml > citadel.yaml
$ kubectl apply -f citadel.yaml
$ kubectl get pods -n istio-system
```

## Citadel / 2nd gke
```bash
$ kubectl config use-context gke_serviceinfratest_asia-northeast3-a_demo-gke-gcgs-2
$ kubectl create ns istio-system
$ helm template istio/install/kubernetes/helm/istio --name-template istio --namespace istio-system \
    -s charts/security/templates/serviceaccount.yaml \
    -s charts/security/templates/clusterrole.yaml \
    -s charts/security/templates/clusterrolebinding.yaml \
    -s charts/security/templates/deployment.yaml > citadel.yaml
$ kubectl apply -f citadel.yaml
$ kubectl get pods -n istio-system
```


# GameServer Deployment & Config 생성

# GameServer 확인
## 1st gke
```bash
$ kubectl config use-context gke_serviceinfratest_asia-northeast3-a_demo-gke-gcgs-1
$ kubectl get fleet
NAME                 SCHEDULING   DESIRED   CURRENT   ALLOCATED   READY   AGE
fleet-gs-deploy-v1   Packed       5         5         0           5       31s

$ kubectl get gs
NAME                             STATE   ADDRESS         PORT   NODE                                             AGE
fleet-gs-deploy-v1-7fq82-5lzbr   Ready   34.64.164.253   7054   gke-demo-gke-gcgs-1-default-pool-584989ce-69j7   32s
fleet-gs-deploy-v1-7fq82-bsk4c   Ready   34.64.204.235   7533   gke-demo-gke-gcgs-1-default-pool-584989ce-qxw1   32s
fleet-gs-deploy-v1-7fq82-ftl2x   Ready   34.64.164.253   7307   gke-demo-gke-gcgs-1-default-pool-584989ce-69j7   32s
fleet-gs-deploy-v1-7fq82-m5dcc   Ready   34.64.204.235   7315   gke-demo-gke-gcgs-1-default-pool-584989ce-qxw1   32s
fleet-gs-deploy-v1-7fq82-qhxbh   Ready   34.64.204.235   7440   gke-demo-gke-gcgs-1-default-pool-584989ce-qxw1   32s

```

## 2nd gke
```bash
$ kubectl config use-context gke_serviceinfratest_asia-northeast3-a_demo-gke-gcgs-2
$ kubectl get fleet
NAME                 SCHEDULING   DESIRED   CURRENT   ALLOCATED   READY   AGE
fleet-gs-deploy-v1   Packed       5         5         0           5       2m23s

$ kubectl get gs
NAME                             STATE   ADDRESS         PORT   NODE                                             AGE
fleet-gs-deploy-v1-4jjsc-4cgvj   Ready   34.64.56.20     7025   gke-demo-gke-gcgs-2-default-pool-1e8c3062-91q8   2m41s
fleet-gs-deploy-v1-4jjsc-8vvqm   Ready   34.64.102.167   7000   gke-demo-gke-gcgs-2-default-pool-1e8c3062-mm0v   2m41s
fleet-gs-deploy-v1-4jjsc-hhdjs   Ready   34.64.56.20     7959   gke-demo-gke-gcgs-2-default-pool-1e8c3062-91q8   2m41s
fleet-gs-deploy-v1-4jjsc-kg5lc   Ready   34.64.102.167   7827   gke-demo-gke-gcgs-2-default-pool-1e8c3062-mm0v   2m41s
fleet-gs-deploy-v1-4jjsc-rltrl   Ready   34.64.56.20     7561   gke-demo-gke-gcgs-2-default-pool-1e8c3062-91q8   2m41s

```


# GameServerAllocation
## 1st gke

```bash
$ kubectl config use-context gke_serviceinfratest_asia-northeast3-a_demo-gke-gcgs-1
$ kubectl create -f gs-allocation.yaml
$ kubectl get gs
NAME                             STATE       ADDRESS         PORT   NODE                                             AGE
fleet-gs-deploy-v1-7fq82-5lzbr   Ready       34.64.164.253   7054   gke-demo-gke-gcgs-1-default-pool-584989ce-69j7   7m11s
fleet-gs-deploy-v1-7fq82-bsk4c   Allocated   34.64.204.235   7533   gke-demo-gke-gcgs-1-default-pool-584989ce-qxw1   7m11s
fleet-gs-deploy-v1-7fq82-ftl2x   Ready       34.64.164.253   7307   gke-demo-gke-gcgs-1-default-pool-584989ce-69j7   7m11s
fleet-gs-deploy-v1-7fq82-m5dcc   Ready       34.64.204.235   7315   gke-demo-gke-gcgs-1-default-pool-584989ce-qxw1   7m11s
fleet-gs-deploy-v1-7fq82-qhxbh   Ready       34.64.204.235   7440   gke-demo-gke-gcgs-1-default-pool-584989ce-qxw1   7m11s
```

## 2nd gke
```bash
$ kubectl config use-context gke_serviceinfratest_asia-northeast3-a_demo-gke-gcgs-2
$ kubectl create -f gs-allocation.yaml
$ kubectl get gs
NAME                             STATE       ADDRESS         PORT   NODE                                             AGE
fleet-gs-deploy-v1-4jjsc-4cgvj   Ready       34.64.56.20     7025   gke-demo-gke-gcgs-2-default-pool-1e8c3062-91q8   10m
fleet-gs-deploy-v1-4jjsc-5k9bc   Allocated   34.64.56.20     7175   gke-demo-gke-gcgs-2-default-pool-1e8c3062-91q8   3m39s
fleet-gs-deploy-v1-4jjsc-8vvqm   Ready       34.64.102.167   7000   gke-demo-gke-gcgs-2-default-pool-1e8c3062-mm0v   10m
fleet-gs-deploy-v1-4jjsc-kg5lc   Ready       34.64.102.167   7827   gke-demo-gke-gcgs-2-default-pool-1e8c3062-mm0v   10m
fleet-gs-deploy-v1-4jjsc-v2ppx   Ready       34.64.36.123    7045   gke-demo-gke-gcgs-2-default-pool-1e8c3062-s7kj   3m25s
```

