#region ACS (bash)
    #region Linux

        # az group create --name=Demo-k8s --location=westeurope

        # az acs create --orchestrator-type=kubernetes --resource-group=Demo-k8s  --name=myK8SCluster --generate-ssh-keys --agent-count 1

        az acs kubernetes get-credentials --resource-group=Demo-k8s  --name=myK8SCluster

        kubectl proxy

        kubectl get nodes

        kubectl create -f k8s/linuxwebsite-deployment.yaml

        kubectl create -f k8s/linuxwebsite-service.yaml

        kubectl get deployment -o wide

        kubectl get pod -o wide

        kubectl get service -o wide
    #endregion
    #region windows
       az acs kubernetes get-credentials --resource-group=Demo-k8s-win  --name=mK8sWinCluster
    
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


    az acs kubernetes get-credentials --resource-group=Demo-k8s  --name=myK8SCluster

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