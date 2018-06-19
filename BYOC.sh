#region Prep


        az group create --name tmp-BYOC-AKS --location westeurope

        az aks create -g tmp-BYOC-AKS   --name cluster1

      
        #cloud shell
        cd ./batch-shipyard/
        source ./venv/bin/activate
    
    
        ./shipyard.py jobs del  --configdir ~/clouddrive/batch 
        
        ./shipyard.py pool add --configdir ~/clouddrive/batch 

#endregion


#region ACR Build
    cd /mnt/c/Repos/Microsoft-and-Containers/
    ACR_NAME="marcusreg"
    EVENT="test"

    az acr build --registry $ACR_NAME --image linuxwebsite:$EVENT --file ./LinuxWebsite/dockerfile https://github.com/marrobi/Microsoft-and-Containers.git

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

        ACR_PASSWORD=$( az acr credential show --name $ACR_NAME --query "passwords[0].value" | sed "s/\"//g" )
        IMAGE=$ACR_NAME'.azurecr.io/linuxwebsite:'$EVENT 


        az container create --name 'linux-website-demo' --image $IMAGE --ip-address public --port 80  -g 'tmpACIDemo' --registry-login-server $ACR_NAME'.azurecr.io' --registry-username $ACR_NAME --registry-password $ACR_PASSWORD 

    
        az container show --name 'linux-website-demo' --resource-group 'tmpACIDemo' --query provisioningState

        az container show --name 'linux-website-demo' --resource-group 'tmpACIDemo' --query ipAddress.ip

        az container delete --name  'linux-website-demo' --resource-group 'tmpACIDemo' --yes
    #endregion
    #region troubleshooting

     az container show --name 'linux-website-demo' --resource-group 'tmpACIDemo' 

     az container logs --name 'linux-website-demo' --resource-group 'tmpACIDemo'
    #endregion
#endregion


#region AKS
    #region Linux

            
        az aks get-credentials  -g tmp-BYOC-AKS   --name cluster1

        # az aks browse  -g tmp-BYOC-AKS   --name cluster1
         
        kubectl get nodes

        kubectl apply -f k8s/linuxwebsite-deployment.yaml

        kubectl apply -f k8s/linuxwebsite-service.yaml

        kubectl get deployment -o wide

        kubectl get pod -o wide

        kubectl get service -o wide -w

    #endregion
    #region windows
    
        az aks get-credentials --resource-group tmp-BYOC-AKS  --name cluster1
    
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


    kubectl get nodes


    az aks install-connector  -g tmp-BYOC-AKS   --name cluster1 --name cluster1 --connector-name connector1
    
    kubectl get deploy -w

    kubectl get nodes

    kubectl create -f k8s/linuxwebsite-deployment-aci.yaml

    kubectl get pod -o wide

    kubectl scale --replicas 10 deployment/linuxwebsite-aci

    kubectl get pod -o wide

    # cleanup

    kubectl delete deploy linuxwebsite-aci

     az aks remove-connector -g tmp-BYOC-AKS  --name cluster1 --connector-name connector1

#endregion

#region ACI troubleshooting
    # kubectl logs linuxwebsite
    # az container logs --name 'linux-website-demo' --resource-group 'Demo-k8s'
    # kubectl logs deploy/aci-connector
    # kubectl describe node/aci-connector

    
#endregion

#region AKS + ACI clean up
    az group delete --name tmp-BYOC-AKS -y
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
    # Edit V2 Site.

    

    # Portal: Create Web App using :prod, view site, slots, scaling, enable continous delivery.

    Start-Process https://ms.portal.azure.com/
    
    az acr build --registry $ACR_NAME --image linuxwebsite:$EVENT --file dockerfile ./LinuxWebsite_v2

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

