# Do in BASH!

# connect to docker for windows
export DOCKER_HOST=tcp://0.0.0.0:2375

# change to Windows file system source lcoation
cd /mnt/c/Repos/Microsoft-and-Containers/LinuxWebsite

"/mnt/c/Program Files (x86)/Microsoft VS Code/Code.exe" "dockerfile"

# build continer
docker build --tag 'linuxwebsite' . 

# run container
docker run -d -p 80:80 linuxwebsite

# check all works
http://localhost

# login to Azure Container Registry
docker login -u '74824f88-020e-446b-ba3e-35f75f376987' containerregistry-microsoft.azurecr.io

# Tag image with registry
docker tag  'linuxwebsite' 'containerregistry-microsoft.azurecr.io/linuxwebsite:latest'

# Push image
docker push 'containerregistry-microsoft.azurecr.io/linuxwebsite:latest'

# create webapp

# image: containerregistry-microsoft.azurecr.io/linuxwebsite:latest
# regsitry url:  https://containerregistry-microsoft.azurecr.io
# username: "74824f88-020e-446b-ba3e-35f75f376987"

