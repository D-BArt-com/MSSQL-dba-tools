#==================================================================================================
#Parameter to set the path to the SQL file.  
#==================================================================================================
param ([Parameter(Mandatory = $true)][string]$Path)
#==================================================================================================
#Set the error action preference to stop.  
#==================================================================================================
$ErrorActionPreference = "Stop"
#==================================================================================================
#Read the plan xml.  
#==================================================================================================
[xml]$Plan = Get-Content $Path
#==================================================================================================
#Retrieve parameters from the plan.  
#==================================================================================================
$Parameters = $Plan.GetElementsByTagName('ParameterList') | Where-object {$PsItem.ColumnReference -ne $null} | Select-Object -ExpandProperty ColumnReference
#==================================================================================================
#Check if parameters are found.  
#==================================================================================================
if($null -eq $Parameters)
{
  Write-Warning "There are no parameters found in this plan."
  return
}
#==================================================================================================
#Loop trough the parameters.  
#==================================================================================================
$Output = "DECLARE`r`n"
foreach ($Parameter in $Parameters)
{
  $ColumnReference   = $Parameter.Column
  $ParameterDataType = $Parameter.ParameterDataType
  $ParameterValue    = $Parameter.ParameterRuntimeValue
  if($null -eq $ParameterValue) #if the runtime value is null, use the compiled value
  {
    $ParameterValue = $Parameter.ParameterCompiledValue
  }
  $Output += "$($ColumnReference) $($ParameterDataType) = $($ParameterValue),`r`n"
}
$Output =  $Output.Substring(0,$Output.Length-3) #Remove the comma from the last value
#==================================================================================================
#write the output and also copy to the clipboard.  
#==================================================================================================
Write-Output $Output
$Output | Set-Clipboard