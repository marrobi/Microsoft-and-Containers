#region Prep

    # Start VMs, login to services
    Login-AzureRmAccount -ServicePrincipal -Tenant  "72f988bf-86f1-41af-91ab-2d7cd011db47"  -Credential (Get-Credential -Message "Password" -UserName "ce72d709-728d-45f7-ab6e-cd8e1c432b4d" )

    Select-AzureRmSubscription  -SubscriptionName "Demos"

    Get-AzureRMVM -ResourceGroupName "DevOpsDemo-ContainerHost" | Start-AzureRMVM   
    Get-AzureRMVM -ResourceGroupName Demo-k8s | Start-AzureRMVM

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

    bash.exe

    read -s AZURE_CLIENT_KEY

    # check windows directories.

    # back to PowerShell

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


#region Build & Ship

# Windows

    $env:DOCKER_HOST = "tcp://$($ServerCoreIP):2375"

    docker build --tag 'marcusreg.azurecr.io/windowswebsite' .\CoreWindowsWebsite

    #docker login marcusreg.azurecr.io

    docker push 'marcusreg.azurecr.io/windowswebsite'

# Linux

    $env:DOCKER_HOST = "tcp://$($UbuntuIP):2375"

    docker build --tag 'marcusreg.azurecr.io/linuxwebsite' .\LinuxWebsite

    #docker login marcusreg.azurecr.io

    docker push 'marcusreg.azurecr.io/linuxwebsite'



#endregion

#region IaaS

# Windows
    $env:DOCKER_HOST = "tcp://$($ServerCoreIP):2375"
    docker info

    # run container based on windows website image
    docker run -d -p 80:80 'marcusreg.azurecr.io/windowswebsite'

    # view web output
    Start-Process "http://$($ServerCoreIP):80"

# Linux
    $env:DOCKER_HOST = "tcp://$($UbuntuIP):2375"

    # run container based on linux website image
    docker run -d -p 80:80  'marcusreg.azurecr.io/linuxwebsite'
       
    # view web output
     Start-Process "http://$($UbuntuIP):80"
#endregion



#region ACI

# BASH

 az group create -n 'tmpACIDemo' -l westeurope

# Windows
#az container create --name 'windows-website-demo' --image 'marrobi/windowswebsite' --os-type Windows --cpu 1 --memory 1 --ip-address public -g 'tmpACIDemo'

# az container show --name 'windows-website-demo' --resource-group 'tmpACIDemo' --query state

# az container logs --name 'windows-website-demo' --resource-group 'tmpACIDemo'

# az container show --name 'windows-website-demo' --resource-group 'tmpACIDemo' --query ipAddress.ip

# az container delete --name  'windows-website-demo' --resource-group 'tmpACIDemo' --yes

# Linux
    az container create --name 'linux-website-demo' --image 'marrobi/linuxwebsite' --ip-address public -g 'tmpACIDemo'

    az container show --name 'linux-website-demo' --resource-group 'tmpACIDemo' --query state

    az container show --name 'linux-website-demo' --resource-group 'tmpACIDemo' --query ipAddress.ip

    az container delete --name  'linux-website-demo' --resource-group 'tmpACIDemo' --yes

# troubleshooting

    # az container show --name 'linux-website-demo' --resource-group 'tmpACIDemo' 

    # az container logs --name 'linux-website-demo' --resource-group 'tmpACIDemo'

#end region


#region ACS

    az acs kubernetes get-credentials --resource-group=Demo-k8s  --name=myK8SCluster

    kubectl proxy

    kubectl get nodes

    kubectl create -f k8s/linuxwebsite-deployment.yaml

    kubectl create -f k8s/linuxwebsite-service.yaml

    kubectl get deployment -o wide

    kubectl get pod -o wide

    kubectl get service -o wide

    #cleanup 

    kubectl delete deployment,service linuxwebsite
    

#endregion


#region ACS + ACI


    cat ./k8s/aci-connector.yaml | AZURE_CLIENT_KEY=$AZURE_CLIENT_KEY envsubst | kubectl create -f -

    kubectl get deploy -w

    kubectl get nodes

    kubectl create -f k8s/linuxwebsite-pod-aci.yaml

    kubectl get pod -o wide

    https://ms.portal.azure.com/

#endregion


#region ACS cleanup
    kubectl delete pod linuxwebsite
    kubectl delete pod linuxwebsite-aci
      
    kubectl delete deploy,node aci-connector
  
#endregion

#region ACS troubleshooting
    # kubectl logs linuxwebsite
    # az container logs --name 'linux-website-demo' --resource-group 'Demo-k8s'
    # kubectl logs deploy/aci-connector
    # kubectl describe node/aci-connector
#endregion
#region ACS Povisioning

    # az group create --name=Demo-k8s --location=westeurope

    # az acs create --orchestrator-type=kubernetes --resource-group=Demo-k8s  --name=myK8SCluster --generate-ssh-keys --agent-count 1

    # az acs kubernetes install-cli 
#endregion

#region Linux WebApps
# PowerShell

    $env:DOCKER_HOST = "tcp://$($UbuntuIP):2375"


    docker tag marcusreg.azurecr.io/linuxwebsite  marcusreg.azurecr.io/linuxwebsite:prod

    docker push  marcusreg.azurecr.io/linuxwebsite:prod

# Portal: Create Web App using :prod, view site, slots, scaling, enable continous delivery.

    Start-Process https://ms.portal.azure.com/

# docker build -t marcusreg.azurecr.io/linuxwebsite:v2 ./LinuxWebsite_v2 

# docker tag marcusreg.azurecr.io/linuxwebsite:v2  marcusreg.azurecr.io/linuxwebsite:prod

# docker push  marcusreg.azurecr.io/linuxwebsite:prod

#end region
#region Azure Batch Shipyard
# BASH
    cd /mnt/c/Repos/batch-shipyard
    source ./shipyard.venv/bin/activate

# ./shipyard.py pool add --configdir /mnt/c/Repos/Microsoft-and-Containers/BatchShipyard --credentials credentials.json 

    ./shipyard.py jobs add --configdir /mnt/c/Repos/Microsoft-and-Containers/BatchShipyard  --credentials credentials.json  

    https://ms.portal.azure.com/

#clean up
#./shipyard.py jobs del  --configdir /mnt/c/Repos/Microsoft-and-Containers/BatchShipyard  --credentials credentials.json 
#./shipyard.py pool del --configdir /mnt/c/Repos/Microsoft-and-Containers/BatchShipyard  --credentials credentials.json 

exit




#end region

#region bits and pieces

#kubectl create secret docker-registry azure-registry --docker-server=marcusreg.azurecr.io --docker-username=ce72d709-728d-45f7-ab6e-cd8e1c432b4d --docker-password=$AZURE_CLIENT_KEY --docker-email 'me@me.com'

#end region