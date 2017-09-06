#region Prep
Login-AzureRmAccount -ServicePrincipal -Tenant  "72f988bf-86f1-41af-91ab-2d7cd011db47"  -Credential (Get-Credential -Message "Password" -UserName "ce72d709-728d-45f7-ab6e-cd8e1c432b4d" )

Select-AzureRmSubscription  -SubscriptionName "Demos"

Start-AzureRMVM -Name containerhost  -ResourceGroupName "DevOpsDemo-ContainerHost"  
Get-AzureRMVM -ResourceGroupName Demo-k8s | Start-AzureRMVM


# move to dir and get IP
$SessionDir = "C:\Repos\Microsoft-and-Containers"
Set-Location $SessionDir 
$ServerCoreIP =  (Get-AzureRmPublicIpAddress -Name ContainerHost-IP -ResourceGroupName DevOpsDemo-ContainerHost).IpAddress

$UbuntuIP =  (Get-AzureRmPublicIpAddress -Name dockerubuntu-IP -ResourceGroupName DevOpsDemo-ContainerHost).IpAddress

Start-Process "http://$($UbuntuIP):80"

# BASH
bash
az login
#ubuntuIP=$(az network public-ip show  --name dockerubuntu-ip --resource-group "DevOpsDemo-ContainerHost"  --query "{ address: ipAddress }" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")


#cleanup previous demo

$env:DOCKER_HOST = "tcp://$($ServerCoreIP):2375"
Get-Container  | Remove-Container -Force
Get-ContainerImage | Where-Object { $_.RepoTags -notlike '*microsoft/windowsservercore*' -notlike '*servercoreiis*'}  | Remove-ContainerImage

$env:DOCKER_HOST = "tcp://$($UbuntuIP):2375"
docker login marcusreg.azurecr.io

docker tag marcusreg.azurecr.io/linuxwebsite  marcusreg.azurecr.io/linuxwebsite:prod
docker push  marcusreg.azurecr.io/linuxwebsite:prod

Get-Container  | Remove-Container -Force
Get-ContainerImage | Where-Object { $_.RepoTags -like '*website'  }  | Remove-ContainerImage  -Force


#endregion


#region build

# Windows
docker build --tag 'marcusreg.azurecr.io/windowswebsite' .\CoreWindowsWebsite

# Linux

docker build --tag 'marcusreg.azurecr.io/linuxwebsite' .\LinuxWebsite

#endregion

#region ship
docker login marcusreg.azurecr.io

# Windows
docker push 'marcusreg.azurecr.io/windowswebsite'

# Linux
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

# bash

# az group create -n 'tmpACIDemo' -l westeurope

# Windows
# az container create --name 'windows-website-demo' --image 'marrrobi/windowswebsite' --os-type Windows --cpu 2 --memory 3.5 --registry-login-server 'marcusreg.azurecr.io' --registry-username 'marcusreg' --registry-password 'N5/fv9qyfP2MZh9iDEvGc6sOG4tspr52' --ip-address public -g 'tmpACIDemo'

# az container show --name 'windows-website-demo' --resource-group 'tmpACIDemo' --query state

# az container logs --name 'windows-website-demo' --resource-group 'tmpACIDemo'

# az container show --name 'windows-website-demo' --resource-group 'tmpACIDemo' --query ipAddress.ip

# az container delete --name  'windows-website-demo' --resource-group 'tmpACIDemo' --yes

# Linux
# az container create --name 'linux-website-demo' --image 'marrobi/linuxwebsite' --ip-address public -g 'tmpACIDemo'

# az container delete --name  'linux-website-demo' --resource-group 'tmpACIDemo' --yes

# troubleshooting

    # az container show --name 'linux-website-demo' --resource-group 'tmpACIDemo' 

    # az container logs --name 'linux-website-demo' --resource-group 'tmpACIDemo'

#end region


#region ACS

az acs kubernetes get-credentials --resource-group=Demo-k8s  --name=myK8SCluster

az acs kubernetes browse --resource-group Demo-k8s --name=myK8SCluster 

kubectl get nodes

kubectl create -f k8s/linuxwebsite-pod.yaml

kubectl get pod -w -o wide

#endregion


#region ACS + ACI
read -s AZURE_CLIENT_KEY

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
    kubectl delete deploy aci-connector
    kubectl delete node aci-connector
#endregion

#region ACS troubleshooting
    # kubectl logs linuxwebsite
    # az container logs --name 'linux-website-demo' --resource-group 'tmpACIDemo'
    # kubectl logs deploy/aci-connector
    # kubectl describe node/aci-connector
#endregion
#region ACS Povisioning

    # az group create --name=Demo-k8s --location=westeurope

    # az acs create --orchestrator-type=kubernetes --resource-group=Demo-k8s  --name=myK8SCluster --generate-ssh-keys --agent-count 1

    # az acs kubernetes install-cli 
#endregion

#region Azure Batch Shipyard

source ~/batch-shipyard/venv/bin/activate
cd ~/clouddrive/batch
# shipyard pool add --config config.json --credentials credentials.json --pool pool.json

~/batch-shipyard/shipyard.py pool add --config config.json --credentials credentials.json --pool pool.json
~/batch-shipyard/shipyard.py jobs add --jobs jobs.json --credentials credentials.json  --config config.json  --pool pool.json

~/batch-shipyard/shipyard.py jobs del  --jobs jobs.json --credentials credentials.json  --config config.json  --pool pool.json
~/batch-shipyard/shipyard.py pool del --config config.json --credentials credentials.json --pool pool.json

#region Linux WebApps

$env:DOCKER_HOST = "tcp://$($UbuntuIP):2375"


docker tag marcusreg.azurecr.io/linuxwebsite  marcusreg.azurecr.io/linuxwebsite:prod

docker push  marcusreg.azurecr.io/linuxwebsite:prod

# Portal: Create Web App using :prod, view site, slots, scaling, enable continous delivery.

docker build -t marcusreg.azurecr.io/linuxwebsite:v2 ./LinuxWebsite_v2 

docker tag marcusreg.azurecr.io/linuxwebsite:v2  marcusreg.azurecr.io/linuxwebsite:prod

docker push  marcusreg.azurecr.io/linuxwebsite:prod




#end region

#region bits and pieces

kubectl create secret docker-registry azure-registry --docker-server=marcusreg.azurecr.io --docker-username=ce72d709-728d-45f7-ab6e-cd8e1c432b4d --docker-password=$AZURE_CLIENT_KEY --docker-email 'me@me.com'

#end region