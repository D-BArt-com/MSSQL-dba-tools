#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!!!!!!!!!!!!!!!!!!!!!!!DO NOT EXECUTE THIS ON A PROD DATABASE!!!!!!!!!!!!!!!!!!!!!!!
#!!!!!!!!!!!!!!!THIS SCRIPT CAN AND PROBABLY WILL CAUSE LOCKING ISSUSES!!!!!!!!!!!!!!
#!!!!!!!!!!!!!!!-------------------------------------------------------!!!!!!!!!!!!!!
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#==================================================================================================
#Test if the sqlserver module is installed.
#==================================================================================================

  if (Get-Module -ListAvailable -Name SqlServer) {
      Write-Output "SqlServer module is installed."
      return $true
  } else {
      Write-Output "SqlServer module is not installed."
      return $false
  }

# Test if the sqlserver module is installed.
if (Get-Module -ListAvailable -Name SqlServer) 
{
  $version = (Get-Module -ListAvailable -Name SqlServer).Version
  if ($version.Major -ge 22) 
  {
      Write-Output "SqlServer module is installed and the version ($version) is 22 or higher."
  } else 
  {
    Write-Output "SqlServer module is installed but the version ($version) is lower than 22. Trying to update it."
    try 
    {
      Update-Module -Name SqlServer -Force -ErrorAction Stop
      $version = (Get-Module -ListAvailable -Name SqlServer).Version
      if ($version.Major -ge 22) 
      {
        Write-Output "SqlServer module is updated and the version ($version) is 22 or higher."
      } 
      else 
      {
        Write-Error "Failed to update SqlServer module to a version higher than 22."
      }
    } 
    catch 
    {
      Write-Error "Failed to update SqlServer module."
    }
  }
} 
else 
{
  # Try to install the module
  Write-Output "SqlServer module is not installed. Trying to install it."
  try 
  {
    Install-Module -Name SqlServer -Force -AllowClobber -Scope CurrentUser -ErrorAction Stop
    $version = (Get-Module -ListAvailable -Name SqlServer).Version
    if ($version.Major -ge 22) 
    {
      Write-Output "SqlServer module is installed and the version ($version) is 22 or higher."
    } 
    else 
    {
      Write-Output "SqlServer module is installed but the version ($version) is lower than 22."
    }
  } 
  catch 
  {
    Write-Error "Failed to install SqlServer module."
    return $false
  }
}
#==================================================================================================
#Define variables.
#==================================================================================================
$SqlFullName = '.'                  #=> Sqlserver name can be Server1 or Server1\Instance1
$DbName      = 'WideWorldImporters' #=> Name of the database
$Schema      = 'Application'        #=>  Schema name of the table
$Table       = 'Countries'          #=>  Table name
#==================================================================================================
#Create datatable
#==================================================================================================
$DataTable = New-Object system.Data.DataTable
[void]$DataTable.Columns.Add("schema_name"            , "System.String")
[void]$DataTable.Columns.Add("table_name"             , "System.String")
[void]$DataTable.Columns.Add("column_name"            , "System.String")
[void]$DataTable.Columns.Add("column_datatype"        , "System.String")
[void]$DataTable.Columns.Add("column_defined_max"     , "System.string")
[void]$DataTable.Columns.Add("column_actual_max"      , "System.int64")
[void]$DataTable.Columns.Add("column_percentuage_used", "System.string")
#==================================================================================================
#Get the columns.
#==================================================================================================
#retrieve columns with a collation type => character columns
$Query = "SELECT
            c.[name] AS [column_name],
            st.[name] AS [type_name],
            [max_length]  
          FROM
            [sys].[columns] c INNER JOIN
            [sys].[systypes] st ON st.xusertype = c.system_type_id INNER JOIN
            [sys].[tables] t ON c.[object_id] = t.[object_id] INNER JOIN
            [sys].[schemas] sc ON t.[schema_id] = sc.[schema_id]
          WHERE
            sc.[name] = '$Schema' AND
            t.[name]  = '$Table' AND
            collation_name IS NOT NULL"
try
{
  $Columns = Invoke-Sqlcmd -TrustServerCertificate -ServerInstance $SqlFullName -Database $DbName -Query $Query -ErrorAction Stop
}
catch
{
  Throw
}
#==================================================================================================
#Get the max length of value in a column
#==================================================================================================
try
{
  foreach ($Column in  $Columns)
  {
    $ColumnName      = $Column.column_name #eg. CountryName
    $ColumnDataType  = $Column.type_name   #eg. varchar, nvarchar, char, nchar
    $ColumnMaxLength = $Column.max_length  #eg. 50, 100, 200, 4000, -1
    if($ColumnMaxLength -eq -1)
    {
      $ColumnMaxLength = 'max'
    }
    
    $Query            = "SELECT COALESCE(MAX(DATALENGTH([$ColumnName])),0) AS [max_length]  FROM [$Schema].[$Table]" #get the max length of the column
    $MaxLength        = (Invoke-Sqlcmd -ServerInstance $SqlFullName -Database $DbName -Query $Query -ErrorAction Stop -TrustServerCertificate).max_length
    Switch($ColumnMaxLength)
    {
      'max'   {[string]$PercentUsed = 'Undefined';break} #no percentage for max columns
      default {$PercentUsed = [math]::Round(100 / $ColumnMaxLength * $MaxLength);break} #percentage of used space
                 
    }
    [void]$DataTable.Rows.Add($Schema,$Table,$ColumnName,$ColumnDataType,$ColumnMaxLength,$MaxLength,$PercentUsed)
  }
}
catch
{
  throw
}
#==================================================================================================
#Write output to a Grid and to the clipboard
#==================================================================================================
$DataTable | Out-GridView