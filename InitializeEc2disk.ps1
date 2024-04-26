Function Initialize-EC2Disk {            
    param(            
             [parameter (mandatory=$true)][string] $InstanceId            
         )            
    $Commands = @(            
        'Get-Disk | `
        Where partitionstyle -eq "raw" | `
        Initialize-Disk -PartitionStyle MBR -PassThru | `
        New-Partition -AssignDriveLetter -UseMaximumSize | `
        Format-Volume -FileSystem NTFS -Confirm:$false -force'            
        )            
    $Parameter = @{            
          commands = $Commands            
    }            
    $Document = 'AWS-RunPowerShellScript'            
    Write-Host ""            
    Write-Host "Initializing disk..." -ForegroundColor Green            
    Try {            
    $Cmd = Send-SSMCommand -DocumentName $Document -Parameter $Parameter -InstanceId $InstanceId            
    While ($Cmd.Status -ne 'Success')            
    {            
        $Cmd = Get-SSMCommand -CommandId $Cmd.CommandId            
        Start-Sleep 10            
    }            
    Write-Host ""            
    Write-Host "Disk is initialized & formatted" -ForegroundColor Green            
    }            
    Catch {            
        Write-Host ""            
        Write-Host "Failed to initialize disk" -ForegroundColor Red            
    }            
}
