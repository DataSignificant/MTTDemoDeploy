# Import AZ Module
Install-Module -Name Az -Scope CurrentUser



# Connect to Azure Account
$azAccount = Connect-AzAccount -Subscription "ME-MngEnvMCAP734805-jeanjoseph-1"


<# Set Azure default -Subscription
Set-AzContext -Subscription "Internal Microsoft Subscription"
#>
Set-AzContext -Subscription "ME-MngEnvMCAP734805-jeanjoseph-1"



# Defining variables value
$AzResourceGroup  = "DP-300-Labs-Demo"
$Location         = "eastus"
$AzSqlServerName  = "svr-dp300-labs"
$sql_admin_user   = "az_sql_admin_user"
$sql_admin_pw     = "P@s!W0rD1"
$databaseName     = "sql-db-dp300-lab"
# The ip address range that you want to allow to access your server
$startIp = "0.0.0.0"
$endIp = "0.0.0.0"



# Create AZ Resource Group if not exists
IF(!((Get-AzResourceGroup).ResourceGroupName -eq $AzResourceGroup))
{
    New-AzResourceGroup -Name $AzResourceGroup -Location $Location
}



# Creating a Logical Azure SQL Server Instance
if(!((Get-AzSqlServer -ResourceGroupName $AzResourceGroup) -eq $AzSqlServerName ))
{
   Write-Warning "Creating $AzSqlServerName Logical Azure SQL Server Instance"
   $sqlserver = New-AzSqlServer -ResourceGroupName $AzResourceGroup `
      -ServerName $AzSqlServerName `
      -Location $location `
      -SqlAdministratorCredentials $(New-Object -TypeName System.Management.Automation.PSCredential `
      -ArgumentList $sql_admin_user, $(ConvertTo-SecureString -String $sql_admin_pw -AsPlainText -Force))  
      Write-Warning "$($server.FullyQualifiedDomainName) has been created successfully"
}



# Configuring server firewall rule   
if(!($server.FullyQualifiedDomainName))
{
   Write-host "Configuring server firewall rule..."
   $serverFirewallRule = New-AzSqlServerFirewallRule -ResourceGroupName $AzResourceGroup `
      -ServerName $AzSqlServerName `
      -FirewallRuleName "AllowedIPs" -StartIpAddress $startIp -EndIpAddress $endIp
   $serverFirewallRule
}



if(!((Get-AzSqlDatabase -ServerName $AzSqlServerName -ResourceGroupName $AzResourceGroup).DatabaseName -eq $databaseName))
{
   Write-host "Creating a gen5 2 vCore serverless database..."
   $database = New-AzSqlDatabase  -ResourceGroupName $AzResourceGroup `
      -ServerName $AzSqlServerName `
      -DatabaseName $databaseName `
      -Edition GeneralPurpose `
      -ComputeModel Serverless `
      -ComputeGeneration Gen5 `
      -VCore 2 `
      -MinimumCapacity 2 `
      -SampleName "AdventureWorksLT"
   $database
}




# clean up
# Remove-AzResourceGroup -Name $AzResourceGroup -force


#Remove-AzSqlServer -ServerName "svr-dp300-labs" -ResourceGroupName "DP-300"
