#region Prep

    # Start VMs, login to services

    $SPNUsername = "ce72d709-728d-45f7-ab6e-cd8e1c432b4d"
    

    $SPNPassword = [System.Runtime.InteropServices.Marshal]::ptrToStringAuto([System.Runtime.InteropServices.Marshal]::SecurestringToBstr((Get-Credential -Message "Password" -UserName $SPNUsername ).Password))

    Login-AzureRmAccount -ServicePrincipal -Tenant  "72f988bf-86f1-41af-91ab-2d7cd011db47" -Credential (Get-Credential -Message "Password" -UserName $SPNUsername )

    docker login marcusreg.azurecr.io
        
    
        Select-AzureRmSubscription  -SubscriptionName "Demos"
    
        Get-AzureRMVM -ResourceGroupName "DevOpsDemo-ContainerHost" | Start-AzureRMVM   
        Get-AzureRMVM -ResourceGroupName Demo-k8s | Start-AzureRMVM
   #     Get-AzureRMVM -ResourceGroupName Demo-k8s-win | Start-AzureRMVM
        Get-AzureRMVM -ResourceGroupName MC_Demo-AKS-1_aks1_ukwest | Start-AzureRMVM
        
        Get-AzureRMVMSS -ResourceGroupName Demo-SFWinContainers | Start-AzureRMVMSS
    #    Get-AzureRMVM -ResourceGroupName Demo-k8shybrid | Start-AzureRMVM
        
        # Move to demo dir and get IPs
        $SessionDir = "C:\Repos\Microsoft-and-Containers"
        Set-Location $SessionDir 
        $ServerCoreIP =  (Get-AzureRmPublicIpAddress -Name ContainerHost-IP -ResourceGroupName DevOpsDemo-ContainerHost).IpAddress
        $UbuntuIP =  (Get-AzureRmPublicIpAddress -Name dockerubuntu-IP -ResourceGroupName DevOpsDemo-ContainerHost).IpAddress
    
     
    
    ## cloud shell
    
        cd ./batch-shipyard/
        source ./venv/bin/activate
    
    
        ./shipyard.py jobs del  --configdir ~/clouddrive/batch 
        
        ./shipyard.py pool add --configdir ~/clouddrive/batch 

        exit
    ## end cloud shell
     # BASH
        # new terminal
    
        ubuntu
     cd /mnt/c/Repos/Microsoft-and-Container
        az account list 
    
        # az login
        read -s AZURE_CLIENT_KEY
        echo $AZURE_CLIENT_KEY

     #   az acs kubernetes get-credentials --resource-group=Demo-k8s-win  --name=mK8sWinCluster   
      #  kubectl get nodes
       # kubectl delete deployment,service windowswebsite
      
       az aks  get-credentials --resource-group=Demo-AKS-1 --name=aks1
       kubectl get nodes
        kubectl delete deployment,service linuxwebsite
        kubectl delete deploy,pod linuxwebsite-aci
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
       
        docker pull marcusreg.azurecr.io/linuxwebsite
        docker tag marcusreg.azurecr.io/linuxwebsite  marcusreg.azurecr.io/linuxwebsite:prod
        docker push  marcusreg.azurecr.io/linuxwebsite:prod
    
        docker rm -f $(docker ps -qa)
        docker rmi 'marcusreg.azurecr.io/linuxwebsite:prod'
    
    #endregion
    
    #region bits and pieces

# kubectl create secret docker-registry azure-registry --docker-server=marcusreg.azurecr.io --docker-username=ce72d709-728d-45f7-ab6e-cd8e1c432b4d --docker-password=$AZURE_CLIENT_KEY --docker-email 'me@me.com'

#end region