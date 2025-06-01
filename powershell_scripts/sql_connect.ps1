param (
    [string]$password
)

# Construct the sqlcmd command
$sqlcmd = "sqlcmd -S localhost -U sa -P $password"

# Execute the command
Invoke-Expression $sqlcmd