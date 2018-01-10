Function AWS-Profile-Select
{
# changelog
# 0.1 initial release

Param(
  [Parameter(Mandatory=$false)]
  [switch]$l,

  [Parameter(Mandatory=$false)]
  [string]$p,

  [Parameter(Mandatory=$false)]
  [string]$r
)

$local:_isAWSModuleExist=(get-module -Name AWSPowerShell -ListAvailable)
$local:_func_name=$MyInvocation.InvocationName
$local:_func_version='0.1-build-20170126'

$local:_AWS_RZ_SELECTION=""
$local:_AWS_PROFILE_SELECTION=""
$local:_CRED_PROFILE_NAME_LIST=""
$local:_REGION_LIST=[ordered]@{
"tokyo"="ap-northeast-1";
"seoul"="ap-northeast-2";
"virginia"="us-east-1";
"ohio"="us-east-2";
"california"="us-west-1";
"oregon"="us-west-2";
"canada"="ca-central-1";
"singapore"="ap-southeast-1";
"sydney"="ap-southeast-2";
"mumbai"="ap-south-1";
"saopaulo"="sa-east-1";
"ireland"="eu-west-1";
"frankfurt"="eu-central-1"
}

$local:_USAGE="
-------------------------------------------------------------------------------------
#    
#    Usage: $_func_name [ -l | -p PROFILE | -r REGION ]
#    Options:
#         -l             List the Region names and AWS Credential currently stored.
#         -p PROFILE     Set the AWS Default Credential, using the given AWS profile.
#         -r REGION      Set the AWS Default Region, using the given city name.
#
#                                                         Version: $_func_version
-------------------------------------------------------------------------------------
"

if ($l) { 
  $local:_REGION_LIST.Keys | 
    % { $city=$_ ; Write-Host " AWS Region:" $city '['$local:_REGION_LIST.Item($city)']' }
}

}

