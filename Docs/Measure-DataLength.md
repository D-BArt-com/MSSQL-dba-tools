Measure-DataLength.ps1
This PowerShell script is designed to measure the data length of specific columns in a SQL Server database. It creates a DataTable object and populates it with information about the columns of a specified table in a specified database.

WARNING
DO NOT EXECUTE THIS SCRIPT ON A PRODUCTION DATABASE. THIS SCRIPT CAN AND PROBABLY WILL CAUSE LOCKING ISSUES.

Usage
The script requires the following parameters:

$SqlFullName: The full name of the SQL Server instance. This can be a single server (e.g., 'Server1') or a server and instance (e.g., 'Server1\Instance1').
$DbName: The name of the database.
$Schema: The schema name of the table.
$Table: The table name.
The script creates a DataTable with the following columns:

schema_name
table_name
column_name
column_datatype
column_defined_max
column_actual_max
column_percentage_used
The script then retrieves columns with a collation type (character columns) from the specified table and populates the DataTable with this information.

Example
In this example, the script will retrieve column information from the 'Countries' table in the 'Application' schema of the 'WideWorldImporters' database on the local SQL Server instance.

Note
This script is intended for use in a development or testing environment. It should not be used on a production database due to the potential for causing locking issues.