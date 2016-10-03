# Creating a Docker Image using Windows Server Core
Docker images are defined using a Dockerfile. The image can then be run as a container or be used as the starting point for another image.

During this post we will create an extremely simple image using Windows Server Core and IIS.

## Creating the docker file and building the image
1. Create a new directory called ```ServerCoreIIS```.
2. Create a new file within the folder called ```dockerfile```, with no file extension.
3. Inside the file add the following line:

    <code>FROM microsoft/windowsservercore:latest</code>
    
    This tells Docker we want to start from the latest microsoft/windowsservercore base image.
4. Under that add the following:

    <code>
    RUN powershell -Command Add-WindowsFeature Web-Server</code>

    This tells Docker to run the PowerShell command ```Add-WindowsFeature Web-Server``` which will install IIS.

5. Under that add the line:

    <code>CMD ["powershell"]</code>
    
    The container will only continue to run if a process is running in the current context. For this reason we start a PowerShell prompt.

6. Verify that the content of your docker file looks like:

    <code>
    FROM microsoft/windowsservercore:latest
    
    RUN powershell -Command Add-WindowsFeature Web-Server
    
    CMD ["powershell"]
    </code>
    
    The Dockerfile could include many more ```RUN``` commands to add additional features and carry out further configuration.

7. Open a command prompt and ensure the working directory the ```ServerCoreIIS``` folder you created in step 1.

8. Ensure the docker client is connected to Windows Server Core and run the following command:

    <code>docker build --tag 'servercoreiis' .</code> 

This creates an image tagged (a name/alias) with ```servercoreiis```. You will see the image get built one layer at a time, this will take a few minutes. Ensure you include the ```.``` at the end that specifies the location of the docker file, i.e. the current directory.

## Create a container using the image
1. To start a new container based on the image created earlier run the following command:

    <code>
    docker run --name 'servercoreiis1' -d -p 50001:80 'servercoreiis'
    </code>
    
    The ```--name``` parameter specified the name of the new container, ```-d``` means the container is detached, i.e. runs in the background rather than interactively, ```-p 50001:80``` maps port 50001 on the host network to port 80 on the container.
    
2. Open a web browser with the IP address of the server core instance directed to port 50001.

    <code>http://&lt;server_ip_address&gt;50001</code>

    You should now be able to see IIS running. Move onto the next post that will provide steps for deploying your website to a container.