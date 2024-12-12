# Fill Log Table -- Test Edition

# ---------------------------------------------- #
# Create Connection / Credentials
Install-Module SimplySql

$DBUser = 'voidlog'
$DBPassword = ConvertTo-SecureString -String 'voidpass' -AsPlainText -Force
$DBDatabase = 'logdb'
$DBServer = 'voidlog' #'192.168.1.3'

$Creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DBUser, $DBPassword
$SqlConnect = Open-MySqlConnection -Server $DBServer -Database $DBDatabase -Credential $Creds #-WarningAction SilentlyContinue

# ---------------------------------------------- #

# Get Existing Forwarded Events
$Events = Get-WinEvent ForwardedEvents |  Select-Object ID, LevelDisplayName, LogName, MachineName, Message, ProviderName, RecordID, TaskDisplayName, TimeCreated

# Some Variables for Convenience

$DataTable = New-Object "System.Data.DataTable"

### Build our Table ###

# Columns / Header
$Columns = $Events | Select -First 1 | Get-Member -MemberType NoteProperty | Select -Expand Name
ForEach ($Col in $Columns)  {
    $Temp = $DataTable.Columns.Add($Col)
}

# Rows
ForEach ($Event in $Events) {
    $NewRow = $DataTable.NewRow()

    ForEach ($Col in $Columns) {
        $NewRow.Item($Col) = $Event.$Col
    }

    $DataTable.Rows.Add($NewRow)
}

# Push Each Row
ForEach ($Row in $DataTable) {
    $ID = [int]$Row['ID']
    $LevelDisplayName = $Row['LevelDisplayName'].ToString()
    $LogName = $Row['LogName'].ToString()
    $MachineName = $Row['MachineName'].ToString()
    $Message = $Row['Message'].ToString().Replace("'", "*").Trim("'") #fixing my damn strings so they dont cause errors lol.
    $ProviderName = $Row['ProviderName'].ToString()
    $RecordID = [int]$Row['RecordID']
    $TaskDisplayName = $Row['TaskDisplayName'].ToString()
    $TimeCreated = $Row['TimeCreated'].ToString()

    $Query = "INSERT INTO logs (ID, LevelDisplayName, LogName, MachineName, Message, ProviderName, RecordID, TaskDisplayName, TimeCreated) VALUES ($ID ,'$LevelDisplayName', '$LogName', '$MachineName', '$Message', '$ProviderName', $RecordID, '$TaskDisplayName', '$TimeCreated');"
    #$Query #-- Output for testing.
    Invoke-SqlUpdate $Query #-- Commented out just incase lol
}

## FORMATTING - DONT UNCOMMENT ##
<#
#$Query = "INSERT INTO testlog (id,LogName,message) VALUES ($ID, '$NAME', '$MESSAGE');"
#Invoke-SqlUpdate $Query
#>

Close-SqlConnection