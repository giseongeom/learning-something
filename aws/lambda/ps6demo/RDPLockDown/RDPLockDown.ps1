# PowerShell script file to be executed as a AWS Lambda function. 
# 
# When executing in Lambda the following variables will be predefined.
#   $LambdaInput - A PSObject that contains the Lambda function input data.
#   $LambdaContext - An Amazon.Lambda.Core.ILambdaContext object that contains information about the currently running Lambda environment.
#
# The last item in the PowerShell pipeline will be returned as the result of the Lambda function.
#
# To include PowerShell modules with your Lambda function, like the AWSPowerShell.NetCore module, add a "#Requires" statement 
# indicating the module and version.

#Requires -Modules @{ModuleName='AWSPowerShell.NetCore';ModuleVersion='3.3.450.0'}

# Uncomment to send the input event to CloudWatch Logs
# Write-Host (ConvertTo-Json -InputObject $LambdaInput -Compress -Depth 5)
$rulesDetected = 0

Get-EC2SecurityGroup | ForEach-Object -Process {

    $securityGroupId = $_.GroupId
    $_.IpPermission | ForEach-Object -Process {

        if ($_.ToPort -eq 3389) {
            Write-Host "Found open RDP port for $securityGroupId"
            $rulesDetected++
        }
    }
}

Write-Host "Scan complete and found $rulesDetected EC2 security group ingress rules"
