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



#region ACI (bash)

    az group create -n 'tmpACIDemo' -l westeurope

    #region Windows
        az container create --name 'windows-website-demo' --image 'marrobi/windowswebsite' --os-type Windows --cpu 1 --memory 1 --ip-address public -g 'tmpACIDemo'

        az container show --name 'windows-website-demo' --resource-group 'tmpACIDemo' --query state

        az container logs --name 'windows-website-demo' --resource-group 'tmpACIDemo'

        az container show --name 'windows-website-demo' --resource-group 'tmpACIDemo' --query ipAddress.ip

        az container delete --name  'windows-website-demo' --resource-group 'tmpACIDemo' --yes
    #endregion
    #region Linux
        az container create --name 'linux-website-demo' --image 'marrobi/linuxwebsite' --ip-address public --port 80  -g 'tmpACIDemo' 

        
        az container show --name 'linux-website-demo' --resource-group 'tmpACIDemo' --query state

        az container show --name 'linux-website-demo' --resource-group 'tmpACIDemo' --query ipAddress.ip

        az container delete --name  'linux-website-demo' --resource-group 'tmpACIDemo' --yes
    #endregion
    #region troubleshooting

     az container show --name 'linux-website-demo' --resource-group 'tmpACIDemo' 

     az container logs --name 'linux-website-demo' --resource-group 'tmpACIDemo'
    #endregion
#endregion


#region ACS (bash)
    #region Linux

        # az group create --name=Demo-k8s --location=westeurope

        # az acs create --orchestrator-type=kubernetes --resource-group=Demo-k8s  --name=myK8SCluster --generate-ssh-keys --agent-count 1

        az aks get-credentials --resource-group=Demo-AKS-1 --name=aks1

       # kubectl proxy
       az aks browse --resource-group=Demo-AKS-1 --name=aks1
         
        kubectl get nodes

        kubectl create -f k8s/linuxwebsite-deployment.yaml

        kubectl create -f k8s/linuxwebsite-service.yaml

        kubectl get deployment -o wide

        kubectl get pod -o wide

        kubectl get service -o wide -w
    #endregion
    #region windows
    
    az aks get-credentials --resource-group=Demo-AKS-1 --name=aks1
    
        kubectl proxy
    
      kubectl get nodes
    
       kubectl create -f k8s/windowswebsite-deployment.yaml
    
        kubectl create -f k8s/windowswebsite-service.yaml
    
        kubectl get deployment -o wide
    
        kubectl get pod -o wide
    
        kubectl get service -o wide
    

    #endregion
#endregion


#region ACS + ACI


   
    az aks get-credentials --resource-group=Demo-AKS-1 --name=aks1

    kubectl get nodes

    cat ./k8s/aci-connector.yaml | AZURE_CLIENT_KEY=$AZURE_CLIENT_KEY envsubst | kubectl create -f -

    kubectl get deploy -w

    kubectl get nodes

    kubectl create -f k8s/linuxwebsite-deployment-aci.yaml

    kubectl get pod -o wide

    kubectl scale --replicas 10 deployment/linuxwebsite-aci

    kubectl get pod -o wide

    # cleanup
    kubectl delete deploy,pod linuxwebsite-aci

    ./k8s/del.sh

    https://ms.portal.azure.com/
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

    # az group create --name=Demo-k8s-Win --location=westeurope

    # az acs create --orchestrator-type=kubernetes --resource-group=Demo-k8s-Win  --name=mK8sWinCluster --generate-ssh-keys --agent-count 1  --windows  --admin-password Password1docker

    # az acs kubernetes install-cli 
#endregion

#region Service Fabric

    Start-Process "http://demo-sf-win.westeurope.cloudapp.azure.com:19080/Explorer/index.html"

    Connect-ServiceFabricCluster -ConnectionEndpoint 'demo-sf-win.westeurope.cloudapp.azure.com:19000'

    New-ServiceFabricComposeApplication -ApplicationName fabric:/WindowsWebsite -Compose .\Compose\docker-compose.yml -RegistryUserName $SPNUsername -RegistryPassword $SPNPassword 

    Start-Process "http://demo-sf-win.westeurope.cloudapp.azure.com:19080/Explorer/index.html"


    Start-Process "http://demo-sf-win.westeurope.cloudapp.azure.com"

    Remove-ServiceFabricComposeApplication  -ApplicationName fabric:/WindowsWebsite

#endregion

#region Linux WebApps
# PowerShell

    # Edit V2 Site.

    $env:DOCKER_HOST = "tcp://$($UbuntuIP):2375"


    docker build -t marcusreg.azurecr.io/linuxwebsite:v2 ./LinuxWebsite_v2 

    docker tag marcusreg.azurecr.io/linuxwebsite:v2  marcusreg.azurecr.io/linuxwebsite:prod

    docker push  marcusreg.azurecr.io/linuxwebsite:prod


# Portal: Create Web App using :prod, view site, slots, scaling, enable continous delivery.

    Start-Process https://ms.portal.azure.com/

#end region
#region Azure Batch Shipyard
# Cloud Shell
    cd ./batch-shipyard/
    source ./venv/bin/activate

# ./shipyard.py pool add --configdir /mnt/c/Repos/Microsoft-and-Containers/BatchShipyard --credentials credentials.json 

    ./shipyard.py jobs add --configdir ~/clouddrive/batch 

    https://ms.portal.azure.com/

#clean up
#./shipyard.py jobs del  --configdir /mnt/c/Repos/Microsoft-and-Containers/BatchShipyard  --credentials credentials.json 
#./shipyard.py pool del --configdir /mnt/c/Repos/Microsoft-and-Containers/BatchShipyard  --credentials credentials.json 

exit


#end region

