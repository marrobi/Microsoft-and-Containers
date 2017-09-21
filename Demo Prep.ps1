#region Prep

    # Start VMs, login to services

    $SPNUsername = "ce72d709-728d-45f7-ab6e-cd8e1c432b4d"
    

    $SPNPassword = [System.Runtime.InteropServices.Marshal]::ptrToStringAuto([System.Runtime.InteropServices.Marshal]::SecurestringToBstr((Get-Credential -Message "Password" -UserName $SPNUsername ).Password))

    Login-AzureRmAccount -ServicePrincipal -Tenant  "72f988bf-86f1-41af-91ab-2d7cd011db47" -Credential (Get-Credential -Message "Password" -UserName $SPNUsername )
    
        Select-AzureRmSubscription  -SubscriptionName "Demos"
    
        Get-AzureRMVM -ResourceGroupName "DevOpsDemo-ContainerHost" | Start-AzureRMVM   
        Get-AzureRMVM -ResourceGroupName Demo-k8s | Start-AzureRMVM
        Get-AzureRMVM -ResourceGroupName Demo-k8s-win | Start-AzureRMVM
        Get-AzureRMVMSS -ResourceGroupName Demo-SFWinContainers | Start-AzureRMVMSS
    
        # Move to demo dir and get IPs
        $SessionDir = "C:\Repos\Microsoft-and-Containers"
        Set-Location $SessionDir 
        $ServerCoreIP =  (Get-AzureRmPublicIpAddress -Name ContainerHost-IP -ResourceGroupName DevOpsDemo-ContainerHost).IpAddress
        $UbuntuIP =  (Get-AzureRmPublicIpAddress -Name dockerubuntu-IP -ResourceGroupName DevOpsDemo-ContainerHost).IpAddress
    
        # BASH
        # new terminal
    
        bash
        az account list 
    
        # az login
    
    
        cd /mnt/c/Repos/batch-shipyard
        source ./shipyard.venv/bin/activate
    
        ./shipyard.py jobs del  --configdir /mnt/c/Repos/Microsoft-and-Containers/BatchShipyard  --credentials credentials.json 
        
        ./shipyard.py pool add --configdir /mnt/c/Repos/Microsoft-and-Containers/BatchShipyard --credentials credentials.json 

        exit
    
        bash
    
        read -s AZURE_CLIENT_KEY

        az acs kubernetes get-credentials --resource-group=Demo-k8s-win  --name=mK8sWinCluster   
        kubectl get nodes
        kubectl delete deployment,service windowswebsite
      
        az acs kubernetes get-credentials --resource-group=Demo-k8s  --name=myK8SCluster
        kubectl get nodes
        kubectl delete deployment,service linuxwebsite
        kubectl delete pod linuxwebsite-aci
        kubectl delete deploy,node aci-connector

        clear
         
        # back to PowerShell
        # check windows directories.
    
        S:
        O:
        del *.*
    
    
        $env:DOCKER_HOST = "tcp://$($ServerCoreIP):2375"
        docker rm -f $(docker ps -qa)
        docker rmi 'marcusreg.azurecr.io/windowswebsite'
    
        $env:DOCKER_HOST = "tcp://$($UbuntuIP):2375"
        docker login marcusreg.azurecr.io
    
        docker pull marcusreg.azurecr.io/linuxwebsite
        docker tag marcusreg.azurecr.io/linuxwebsite  marcusreg.azurecr.io/linuxwebsite:prod
        docker push  marcusreg.azurecr.io/linuxwebsite:prod
    
        docker rm -f $(docker ps -qa)
        docker rmi 'marcusreg.azurecr.io/linuxwebsite:prod'
    
    #endregion
    
    #region bits and pieces

# kubectl create secret docker-registry azure-registry --docker-server=marcusreg.azurecr.io --docker-username=ce72d709-728d-45f7-ab6e-cd8e1c432b4d --docker-password=$AZURE_CLIENT_KEY --docker-email 'me@me.com'

#end region