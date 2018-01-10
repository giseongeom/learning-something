## Table of Contents

- [Why?](#why)
- [Setup](#setup)
- [Usage](#usage)
  * [Show version, help](#show-version-help)
  * [Display AWS profile configured](#display-aws-profile-configured)
  * [Specify AWS profile](#specify-aws-profile)
  * [Specify AWS Default Region](#specify-aws-default-region)
  
## Why?

* 관리해야 할 AWS 계정이 많다.
* AWS CLI 도구의 ``--profile``, ``--region`` 옵션을 매번 타이핑하기 싫다.
* 대부분의 AWS 호환 프로그램은 ``AWS_ACCESS_KEY_ID``, ``AWS_SECRET_ACCESS_KEY`` 등의 쉘 환경변수를 인식한다. [여기](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html#cli-environment) 참고
* terraform 과 같은 3rd party 도구를 사용할 때에는 환경변수 방식이 편하다. 각종 소스코드에 credential 또는 profile 정보를 넣지 않아도 된다.




## Setup

* ``.bash_functions_aws`` 파일을 ``$HOME`` 경로에 복사한다.
* ``.bashrc`` 파일에 다음 내용을 추가한다.
```bash
if [ -f "${HOME}/.bash_functions_aws" ]; then
  source "${HOME}/.bash_functions_aws"
fi
```
* bash 쉘을 다시 실행하거나 Terminal을 닫았다가 다시 실행해 본다.
* 테스트 환경
    * git-bash / Windows 10 x64

## Usage

* 예제 credential 파일의 내용

```
[default]
aws_access_key_id = A2IAJW4ARYY5K6X77771
aws_secret_access_key = 999999999999999999999999999999Z+sjPb4o1t
[personal]
aws_access_key_id = A3IAJW4ARYY5K6X1118A
aws_secret_access_key = 777777777777777777777777777777Z+sjPb4o2t
[boss]
aws_access_key_id = A4IAJW4ARYY5K6X9909A
aws_secret_access_key = aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaZ+sjPb4o3t
```


### Show version, help

* 버전 정보, 도움말 표시 

```
$ aws-profile-select

-------------------------------------------------------------------------------------
#
#    Usage: aws-profile-select [ -l | -p PROFILE | -r REGION ]
#    Options:
#         -l             List the Region names and AWS Credential currently stored.
#         -p PROFILE     Set the AWS Default Credential, using the given AWS profile.
#         -r REGION      Set the AWS Default Region, using the given city name.
#
#                                                         Version: 0.3.4-build-20161209
-------------------------------------------------------------------------------------
```

### Display AWS profile configured

* ``$HOME/.aws/credentials`` 파일만 있으면 된다.
* ``-l`` 옵션을 사용한다.
    * 하드코딩되어 있는 region 목록을 출력
    * ``$HOME/.aws/credentials`` 파일의 ``profile``, ``access_key_id``, ``secret_access_key`` 정보를 표시
    * SecretAccessKey의 경우 일부 정보를 감추고 표시 

```
$ aws-profile-select -l

 AWS Region: tokyo [ap-northeast-1]
 AWS Region: seoul [ap-northeast-2]
 AWS Region: n.virgina [us-east-1]
 AWS Region: ohio [us-east-2]
 AWS Region: n.california [us-west-1]
 AWS Region: oregon [us-west-2]
 AWS Region: canada [ca-central-1]
 AWS Region: singapore [ap-southeast-1]
 AWS Region: sydney [ap-southeast-2]
 AWS Region: mumbai [ap-south-1]
 AWS Region: saopaulo [sa-east-1]
 AWS Region: ireland [eu-west-1]
 AWS Region: frankfurt [eu-central-1]

 AWS Profile: default
     AccessKeyId: A2IAJW4ARYY5K6X77771
     SecretAccessKey: **********b4o1t
 AWS Profile: personal
     AccessKeyId: A3IAJW4ARYY5K6X1118A
     SecretAccessKey: **********b4o2t
 AWS Profile: boss
     AccessKeyId: A4IAJW4ARYY5K6X9909A
     SecretAccessKey: **********b4o3t

```


### Specify AWS profile

* `boss` profile 을 선택
```
$ aws-profile-select -p boss

---------------------------------------------------------------------
AWS_ACCESS_KEY_ID: A4IAJW4ARYY5K6X9909A [boss]
AWS_SECRET_ACCESS_KEY: **********b4o3t
---------------------------------------------------------------------
```
* 그냥 실행하면 기존에 선택된 profile 정보를 표시
```
$ aws-profile-select
AWS_ACCESS_KEY_ID: A4IAJW4ARYY5K6X9909A [boss]
AWS_SECRET_ACCESS_KEY: **********b4o3t

-------------------------------------------------------------------------------------
#
#    Usage: aws-profile-select [ -l | -p PROFILE | -r REGION ]
#    Options:
#         -l             List the Region names and AWS Credential currently stored.
#         -p PROFILE     Set the AWS Default Credential, using the given AWS profile.
#         -r REGION      Set the AWS Default Region, using the given city name.
#
#                                                         Version: 0.3.5-build-20170125
-------------------------------------------------------------------------------------

```

### Specify AWS Default Region

* `tokyo` region 을 지정
```
$ aws-profile-select -r tokyo

---------------------------------------------------------------------
AWS_DEFAULT_REGION: tokyo [ap-northeast-1]
---------------------------------------------------------------------
```
* 그냥 실행하면 기존에 선택된 profile 정보와 함께 region 정보를 표시
```
AWS_DEFAULT_REGION: tokyo [ap-northeast-1]
AWS_ACCESS_KEY_ID: A4IAJW4ARYY5K6X9909A [boss]
AWS_SECRET_ACCESS_KEY: **********b4o3t

-------------------------------------------------------------------------------------
#
#    Usage: aws-profile-select [ -l | -p PROFILE | -r REGION ]
#    Options:
#         -l             List the Region names and AWS Credential currently stored.
#         -p PROFILE     Set the AWS Default Credential, using the given AWS profile.
#         -r REGION      Set the AWS Default Region, using the given city name.
#
#                                                         Version: 0.3.5-build-20170125
-------------------------------------------------------------------------------------
```
