# Create Log Table

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

# Create Table
$Query = "CREATE TABLE logs (Id int(255), LevelDisplayName varchar(100), LogName varchar(100), MachineName varchar(255), Message LONGTEXT, ProviderName varchar(255), RecordId int(255) NOT NULL UNIQUE, TaskDisplayName varchar(255), TimeCreated varchar(255));"

Invoke-SqlUpdate $Query

Close-SqlConnection