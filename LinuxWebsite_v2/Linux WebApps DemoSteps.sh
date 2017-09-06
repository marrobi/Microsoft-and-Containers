# Do in BASH!

# connect to docker for windows
export DOCKER_HOST=tcp://0.0.0.0:2375

# change to Windows file system source lcoation
cd /mnt/c/Repos/Microsoft-and-Containers/LinuxWebsite

# open "dockerfile"

# build continer
docker build --tag 'linuxwebsite' . 

# run container
docker run -d -p 80:80 linuxwebsite

# check all works
http://localhost

# login to Azure Container Registry
docker login -u 'ce72d709-728d-45f7-ab6e-cd8e1c432b4d' containerregistry-microsoft.azurecr.io

# Tag image with registry
docker tag  'linuxwebsite' 'containerregistry-microsoft.azurecr.io/linuxwebsite:latest'

# Push image
docker push 'containerregistry-microsoft.azurecr.io/linuxwebsite:latest'

# create webapp
# browse to https://ms.portal.azure.com/#create/Microsoft.AppSvcLinux
# image: containerregistry-microsoft.azurecr.io/linuxwebsite:latest
# regsitry url:  https://containerregistry-microsoft.azurecr.io
# username: "ce72d709-728d-45f7-ab6e-cd8e1c432b4d"

