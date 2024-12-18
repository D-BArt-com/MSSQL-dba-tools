#Path to the query plan xml
[xml]$Plan = Get-Content 'C:\Temp\QueryPlan.sqlplan'
#Retrieve parameters from the plan
$Parameters = $Plan.GetElementsByTagName('ParameterList') | Where-object {$PsItem.ColumnReference -ne $null} | Select-Object -ExpandProperty ColumnReference
#Initialize ouptut variable
$Output = "DECLARE`r`n"
#Loop trough the parameters
Foreach ($Parameter in $Parameters)
{
  $ColumnReference        = $Parameter.Column
  $ParameterDataType      = $Parameter.ParameterDataType
  $ParameterCompiledValue = $Parameter.ParameterCompiledValue
  $Output                += "$($ColumnReference) $($ParameterDataType) = $($ParameterCompiledValue),`r`n"
}
#Remove the comma from the last value
$Output =  $Output.Substring(0,$Output.Length-3)
#write the output and also copy to the clipboard
Write-Output $Output
$Output | Set-Clipboard
