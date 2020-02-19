[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
###############################################
# Configure variable below, you will be prompted for your SNOW login
###############################################
$SNOWURL = "https://dev60890.service-now.com/"
################################################################################
# Nothing to configure below this line - Starting the main function 
################################################################################
###############################################
# Prompting & saving SNOW credentials, delete the XML file created to reset
###############################################
# Setting credential file
$SNOWCredentialsFile = ".\SNOWCredentials.xml"
# Testing if file exists
$SNOWCredentialsFileTest =  Test-Path $SNOWCredentialsFile
# IF doesn't exist, prompting and saving credentials
IF ($SNOWCredentialsFileTest -eq $False)
{
$SNOWCredentials = Get-Credential -Message "Enter SNOW login credentials"
$SNOWCredentials | EXPORT-CLIXML $SNOWCredentialsFile -Force
}
# Importing credentials
$SNOWCredentials = IMPORT-CLIXML $SNOWCredentialsFile
# Setting the username and password from the credential file (run at the start of each script)
$SNOWUsername = $SNOWCredentials.UserName
$SNOWPassword = $SNOWCredentials.GetNetworkCredential().Password
##################################
# Building Authentication Header & setting content type
##################################
$HeaderAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $SNOWUsername, $SNOWPassword)))
$SNOWSessionHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$SNOWSessionHeader.Add('Authorization',('Basic {0}' -f $HeaderAuth))
$SNOWSessionHeader.Add('Accept','application/json')
$Type = "application/json"
###############################################
# Getting list of Incidents
###############################################
$AssignGroup='Hardware'
$IncidentListURL = $SNOWURL+"api/now/table/incident?sysparm_query=assignment_group.name=$AssignGroup"

$Method = 'get'

$Response = Invoke-RestMethod -Headers $SNOWSessionHeader -Method $Method -Uri $IncidentListURL -ContentType $Type 

$snowResult = $Response.result|Select-Object number,sys_id ,priority,state
$snowResult
#$snowResult|Export-Csv -Path ./result.csv -NoTypeInformation

##########################################################################################################################