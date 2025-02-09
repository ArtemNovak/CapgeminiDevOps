# This runbook creates a complete web server deployment including networking, VM, and IIS configuration through DSC
param(
    [Parameter(Mandatory = $false)]
    [string]$ResourceGroupName = "MyAutomationRGAN",
    
    [Parameter(Mandatory = $false)]
    [string]$Location = "eastus",
    
    [Parameter(Mandatory = $false)]
    [string]$VMName = "WebServerVM",
    
    [Parameter(Mandatory = $false)]
    [string]$VMSize = "Standard_B2s"
)

# Enhanced logging function with severity levels for better troubleshooting
function Write-Log {
    param(
        [string]$Message,
        [string]$Severity = "Information"
    )
    $logMessage = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [$Severity] $Message"
    Write-Output $logMessage
    Write-Verbose -Message $logMessage -Verbose
}

# Define resource tags for better management and tracking
$tags = @{
    "Environment" = "Lab"
    "Purpose" = "WebServer"
    "CreatedBy" = "Automation"
    "DeploymentDate" = (Get-Date -Format "yyyy-MM-dd")
}

try {
    Write-Log "Starting WebServer deployment process" "Information"

    # SECTION 1: AUTHENTICATION
    Write-Log "Initiating Azure authentication using Managed Identity" "Information"
    try {
        Disable-AzContextAutosave -Scope Process | Out-Null
        Clear-AzContext -Force

        $connectionResult = Connect-AzAccount -Identity -ErrorAction Stop
        Write-Log "Successfully connected using Managed Identity" "Information"

        $subscriptions = Get-AzSubscription -ErrorAction Stop
        if ($subscriptions) {
            $subId = $subscriptions[0].Id
            Set-AzContext -SubscriptionId $subId -ErrorAction Stop
            Write-Log "Successfully set context to subscription: $subId" "Information"
        } else {
            throw "No accessible subscriptions found"
        }
    } catch {
        Write-Log "Authentication failed: $($_.Exception.Message)" "Error"
        throw
    }

    Start-Sleep -Seconds 10

    # SECTION 2: NETWORKING
    Write-Log "Starting network configuration" "Information"
    try {
        $vnetName = "WebServerVNetAN"
        $subnetName = "WebServerSubnetAN"

        # Create subnet configuration
        $subnetConfig = New-AzVirtualNetworkSubnetConfig `
            -Name $subnetName `
            -AddressPrefix "172.16.1.0/24"

        # Create the virtual network
        $vnet = New-AzVirtualNetwork `
            -ResourceGroupName $ResourceGroupName `
            -Name $vnetName `
            -Location $Location `
            -AddressPrefix "172.16.0.0/16" `
            -Subnet $subnetConfig

        Start-Sleep -Seconds 30
        
        # Refresh virtual network reference
        $vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $ResourceGroupName
        if (-not $vnet) {
            throw "Failed to create Virtual Network"
        }

        # Get subnet reference
        $subnet = Get-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet
        if (-not $subnet) {
            throw "Failed to get subnet reference"
        }
        Write-Log "Network configuration completed successfully" "Information"
    } catch {
        Write-Log "Network configuration failed: $($_.Exception.Message)" "Error"
        throw
    }

    Start-Sleep -Seconds 10

    # SECTION 3: PUBLIC IP AND SECURITY GROUP
    Write-Log "Creating network resources" "Information"
    try {
        # Create Public IP
        $publicIP = New-AzPublicIpAddress `
            -ResourceGroupName $ResourceGroupName `
            -Name "WebServerIP" `
            -Location $Location `
            -AllocationMethod Dynamic `
            -Sku Basic

        Start-Sleep -Seconds 10

        # Create HTTP rule
        $httpRule = New-AzNetworkSecurityRuleConfig `
            -Name "AllowHTTP" `
            -Description "Allow HTTP" `
            -Access Allow `
            -Protocol Tcp `
            -Direction Inbound `
            -Priority 100 `
            -SourceAddressPrefix * `
            -SourcePortRange * `
            -DestinationAddressPrefix * `
            -DestinationPortRange 80

        # Create RDP rule
        $rdpRule = New-AzNetworkSecurityRuleConfig `
            -Name "AllowRDP" `
            -Description "Allow RDP" `
            -Access Allow `
            -Protocol Tcp `
            -Direction Inbound `
            -Priority 1000 `
            -SourceAddressPrefix * `
            -SourcePortRange * `
            -DestinationAddressPrefix * `
            -DestinationPortRange 3389

        # Create NSG with both rules
        $nsg = New-AzNetworkSecurityGroup `
            -ResourceGroupName $ResourceGroupName `
            -Location $Location `
            -Name "WebServerNSG" `
            -SecurityRules $httpRule,$rdpRule

        Start-Sleep -Seconds 10

        # Create network interface
        $nic = New-AzNetworkInterface `
            -Name "WebServerNIC" `
            -ResourceGroupName $ResourceGroupName `
            -Location $Location `
            -SubnetId $subnet.Id `
            -PublicIpAddressId $publicIP.Id `
            -NetworkSecurityGroupId $nsg.Id

        Start-Sleep -Seconds 10

        if (-not $nic) {
            throw "Failed to create network interface"
        }
        Write-Log "Network interface created successfully" "Information"
    } catch {
        Write-Log "Failed to create network resources: $($_.Exception.Message)" "Error"
        throw
    }

    # SECTION 4: VM CONFIGURATION
    Write-Log "Preparing VM configuration" "Information"
    try {
        $vmConfig = New-AzVMConfig -VMName $VMName -VMSize $VMSize

        $securePassword = ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force
        $cred = New-Object System.Management.Automation.PSCredential ("azureuser", $securePassword)

        $vmConfig = Set-AzVMOperatingSystem `
            -VM $vmConfig `
            -Windows `
            -ComputerName $VMName `
            -Credential $cred `
            -ProvisionVMAgent

        $vmConfig = Set-AzVMSourceImage `
            -VM $vmConfig `
            -PublisherName "MicrosoftWindowsServer" `
            -Offer "WindowsServer" `
            -Skus "2019-Datacenter" `
            -Version "latest"

        $vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id

        Write-Log "VM configuration completed" "Information"
    } catch {
        Write-Log "VM configuration failed: $($_.Exception.Message)" "Error"
        throw
    }

    Start-Sleep -Seconds 10

    # SECTION 5: VM CREATION
    Write-Log "Creating Virtual Machine" "Information"
    try {
        $vm = New-AzVM `
            -ResourceGroupName $ResourceGroupName `
            -Location $Location `
            -VM $vmConfig

        Start-Sleep -Seconds 30
        Write-Log "Virtual Machine created successfully" "Information"
    } catch {
        Write-Log "Failed to create VM: $($_.Exception.Message)" "Error"
        throw
    }

    # SECTION 6: DSC CONFIGURATION
    Write-Log "Setting up DSC configuration" "Information"
    try {
        $storageAccountName = "webserverdsc" + [System.Guid]::NewGuid().ToString().Split('-')[0]
        $storageAccount = New-AzStorageAccount `
            -ResourceGroupName $ResourceGroupName `
            -Name $storageAccountName `
            -Location $Location `
            -SkuName "Standard_LRS" `
            -Kind StorageV2

        Write-Log "Creating DSC configuration script" "Information"
        $dscConfigPath = Join-Path -Path $env:TEMP -ChildPath "WebServerConfig.ps1"

        @'
Configuration WebServerConfig {
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Node localhost {
        WindowsFeature IIS {
            Name = "Web-Server"
            Ensure = "Present"
        }
        WindowsFeature IISManagementTools {
            Name = "Web-Mgmt-Tools"
            Ensure = "Present"
            DependsOn = "[WindowsFeature]IIS"
        }
        File DefaultPage {
            DestinationPath = "C:\inetpub\wwwroot\index.html"
            Contents = "<html><body><h1>Hello from Azure Automation DSC!</h1></body></html>"
            Ensure = "Present"
            DependsOn = "[WindowsFeature]IIS"
            Type = "File"
        }
    }
}
'@ | Out-File -FilePath $dscConfigPath

        Write-Log "Publishing DSC configuration" "Information"
        $publishResult = Publish-AzVMDscConfiguration `
            -ConfigurationPath $dscConfigPath `
            -ResourceGroupName $ResourceGroupName `
            -StorageAccountName $storageAccountName `
            -Force

        Start-Sleep -Seconds 10

        Write-Log "Applying DSC configuration to VM" "Information"
        $dscResult = Set-AzVMDscExtension `
            -ResourceGroupName $ResourceGroupName `
            -VMName $VMName `
            -ArchiveStorageAccountName $storageAccountName `
            -ArchiveBlobName "WebServerConfig.ps1.zip" `
            -ConfigurationName "WebServerConfig" `
            -Version "2.83" `
            -Location $Location

        Start-Sleep -Seconds 30
        Write-Log "DSC configuration applied successfully" "Information"

    } catch {
        Write-Log "DSC configuration failed: $($_.Exception.Message)" "Error"
        throw
    }

    # SECTION 7: FINAL VERIFICATION
    try {
        $finalIP = Get-AzPublicIpAddress -ResourceGroupName $ResourceGroupName -Name "WebServerIP"
        if ($finalIP -and $finalIP.IpAddress) {
            Write-Log "Deployment completed successfully" "Information"
            Write-Log "Website will be available at: http://$($finalIP.IpAddress)" "Information"
            Write-Log "RDP access: $($finalIP.IpAddress):3389" "Information"
            Write-Log "Username: azureuser" "Information"
            Write-Log "Password: P@ssw0rd123!" "Information"
        } else {
            Write-Log "Deployment completed but couldn't retrieve public IP" "Warning"
        }
    } catch {
        Write-Log "Final verification failed: $($_.Exception.Message)" "Warning"
    }

} catch {
    Write-Log "Deployment failed: $($_.Exception.Message)" "Error"
    throw
} finally {
    Write-Log "Runbook execution completed" "Information"
}