# Function to get applied GPOs
function Get-AppliedGPOs {
    $gpoList = @()
    $appliedGPOs = Get-WmiObject -Namespace "root\rsop\computer" -Class RSOP_GPO | Select-Object -ExpandProperty name
    
    foreach ($gpo in $appliedGPOs) {
        $gpoList += $gpo
    }

    return $gpoList
}

# Main script
$appliedGPOs = Get-AppliedGPOs
Write-Host "Applied Group Policy Objects (GPOs):"
foreach ($gpo in $appliedGPOs) {
    Write-Host $gpo
}
