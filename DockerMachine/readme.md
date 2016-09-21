# Using Docker Machine to provision a VM running Docker on Azure

_Docker Machine_ facilitates the creation and management of virtual hosts running Docker engine [https://docs.docker.com/machine/overview/](https://docs.docker.com/machine/overview/) . This could be a host running within a VM on your local machine, via technologies such as Hyper-V or in a public cloud such as Microsoft Azure. Docker Machine uses _drivers_ to enable deployment to different platforms

During this exercise we will provision a VM running Docker on Microsoft Azure and deploying containers to the VM. We will use the Azure driver for Docker Machine which is documented here [https://docs.docker.com/machine/drivers/azure/](https://docs.docker.com/machine/drivers/azure/) .

# Install Prerequisites

## PowerShell

If you haven't already got PowerShell installed on your system (potentially a none Windows OS) follow the instructions applicable for your operating system: [https://github.com/PowerShell/PowerShell](https://github.com/PowerShell/PowerShell)

## Azure PowerShell Module

1. Open a PowerShell prompt

2. Run the command:

```
Install-ModuleAzureRM-Force
```
## Docker

### Docker for Windows/Mac

Includes Docker CLI Client, Docker Engine, Docker Compose and Docker Machine:

- Windows: [https://docs.docker.com/machine/install-machine/](https://docs.docker.com/machine/install-machine/)
- Mac: [https://docs.docker.com/docker-for-mac/](https://docs.docker.com/docker-for-mac/)

### Linux:

Requires individual installation of Docker components

- Docker Engine: [https://docs.docker.com/engine/installation/](https://docs.docker.com/engine/installation/)
- Docker Machine: [https://docs.docker.com/machine/install-machine/](https://docs.docker.com/machine/install-machine/)

## Visual Studio Code

- [https://code.visualstudio.com/](https://code.visualstudio.com/)

# Retrieve your Azure Subscription ID

1. Log in to Azure:
```
Login-AzureRmAccount
```
2. Retrieve your subscription ID:
    - If you only have one Azure subscription:
```
$SubscriptionId = (Get-AzureRmSubscription).SubscriptionId
```
    - If you have multiple Azure subscriptions
    1. View list of subscriptions:
```
Get-AzureRmSubscription
```
        - Replace <your_subscription_name> with the name of your Azure Subscription:

```
$SubscriptionId= (Get-AzureRmSubscription-SubscriptionName <your_subscription_name>).SubscriptionId
```


# Create a virtual machine on Azure running Docker Engine

1. To configure variables required to provision the VM run the following lines with your preferred values. Maybe split
```
$DockerMachineVMName=&quot;&lt;vm\_name&gt;&quot;

$Region=&quot;&lt;azure\_region&gt;&quot;

$ResourceGroup=&quot;&lt;resource\_group\_name&gt;&quot;
```
1. To create the VM, run the following command: explain about parameters
```
docker-machinecreate--driverazure `

    --azure-subscription-id$SubscriptionId `

    --azure-location$Region `

    --azure-resource-group  $ResourceGroup `

    --azure-image&quot;canonical:UbuntuServer:16.04.0-LTS:latest&quot;  `

     $DockerMachineVMName
```
Wait while the virtual machine is provisioned. This may take 5 minutes or more.

# Connect to the VM

1. Run the following command to view the details required to connect Docker Machine to the VM:
```
docker-machineenv$DockerMachineVMName
```
1. To connect Docker  machine
```
docker-machineenv$DockerMachineVMName|Invoke-Expression
```
1. 3.Verify connected to Docker Engine on the VM:
```
dockerinfo
```

Congratulations you are now connected to your new Docker VM.