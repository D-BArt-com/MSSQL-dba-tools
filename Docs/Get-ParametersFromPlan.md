# Extract Parameters from SQL Server Execution Plan (PowerShell)
This PowerShell script automatically extracts all parameters from a SQL Server `.sqlplan` (execution plan XML file) and generates a clean `DECLARE` statement. It's especially useful for DBAs who need to reproduce queries for troubleshooting or performance tuning.

## 🧠 What It Does
- Accepts a `.sqlplan` path as a parameter
- Reads a `.sqlplan` file (XML format)
- Finds the `ParameterList` in the execution plan
- Extracts:
  - Parameter name
  - Data type
  - Runtime or compiled value
- Outputs a valid `DECLARE` block
- Copies the result to the clipboard for easy reuse

## 🔧 Usage
1. Save your SQL Server query plan as a `.sqlplan` file.
2. Run the script like this:
  .\Extract-QueryPlanParameters.ps1 -SqlPlanPath "C:\Temp\MyQueryPlan.sqlplan"

## 📄 Example Output
DECLARE
@UserId int = 123,
@Status varchar(20) = 'Active',
@IsArchived bit = 0

## 🙋‍♂️ Questions or Feedback?
Feel free to open an issue or reach out on LinkedIn — always happy to connect and talk SQL Server, automation, and scripting.
https://www.linkedin.com/in/bart-vernaillen-25abaa83/ 