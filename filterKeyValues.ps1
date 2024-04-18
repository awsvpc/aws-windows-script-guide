# Sample filter list output
$filterlist = @"
Key         Value
----        -----
Environment NONPROD
TIER        MGT
"@

# Function to verify if keys exist
function Verify-KeysExist {
    param(
        [string]$FilterList,
        [string[]]$Keys
    )

    $filterTable = ConvertFrom-Csv -InputObject $FilterList -Delimiter " "
    $missingKeys = @()

    foreach ($key in $Keys) {
        if (-not ($filterTable | Where-Object { $_.Key -eq $key })) {
            $missingKeys += $key
        }
    }

    if ($missingKeys.Count -eq 0) {
        Write-Host "All keys exist"
    } else {
        Write-Host "The following keys are missing: $($missingKeys -join ", ")"
    }
}

# Call the function to verify keys
Verify-KeysExist -FilterList $filterlist -Keys "Environment", "TIER"

# Function to get values of specific keys
function Get-ValuesForKey {
    param(
        [string]$FilterList,
        [string[]]$Keys
    )

    $filterTable = ConvertFrom-Csv -InputObject $FilterList -Delimiter " "
    
    foreach ($key in $Keys) {
        $value = ($filterTable | Where-Object { $_.Key -eq $key }).Value
        Write-Host "Value for key '$key' is: $value"
    }
}

# Call the function to get values for specific keys
Get-ValuesForKey -FilterList $filterlist -Keys "Environment", "TIER"
