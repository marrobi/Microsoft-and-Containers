# Creating a Docker Image running a simple website
During this post we will add a website to the image running IIS.

## Creating the docker file and building the image
1. Create a new directory called ```CoreWindowsWebsite```.
2. Create a new file within the folder called ```dockerfile```, with no file extension.
3. Inside the file add the following line:

    <code>FROM servercoreiis:latest</code>
    
    This tells Docker we want to start from the image we created earlier.
    
4. Under that add the following:

    <code>
    ADD WindowsWebsite.zip /
    </code>

    This tells Docker to add the file WindowsWebsite.zip from the current directory to the root directory of the  image.

5. Under that add the line:

    <code>
    SHELL ["powershell","-command"]
    </code>

    The changes the default shell for the following RUN commands to use PowerShell.

6. Next add the following line:

    <code>RUN Expand-Archive -Path WindowsWebsite.zip  -DestinationPath c:\inetpub\wwwroot\ -Force</code>

    This will extract the contents of the zip file to  c:\inetpub\wwwroot\ to be served by IIS.

7. Under that add the line:

    <code>CMD ["powershell"]</code>
    
    The container will only continue to run if a process is running in the current context. For this reason we start a PowerShell prompt.
    
8. Verify that the content of your docker file looks like:

    <code>
   
   FROM servercoreiis:latest

    ADD WindowsWebsite.zip /

    SHELL ["powershell","-command"]

    RUN Expand-Archive -Path WindowsWebsite.zip  -DestinationPath c:\inetpub\wwwroot -Force

    CMD powershell 
        
    </code>
    
    The Dockerfile could include many more ```RUN``` commands to add additional features and carry out further configuration.

9. Open a command prompt and ensure the working directory the ```CoreWindowsWebsite``` folder you created in step 1.

10. Ensure the docker client is connected to Windows Server Core and run the following command:

    <code>docker build --tag 'corewindowswebsite' .</code> 

This creates an image tagged (a name/alias) with ```corewindowswebsite```. You will see the image get built one layer at a time, this will take a few minutes. Ensure you include the ```.``` at the end that specifies the location of the docker file, i.e. the current directory.

## Create a container using the image
1. To start a new container based on the image created earlier run the following command:

    <code>
    docker run --name 'windowswebsite1' -d -p 50002:80 'corewindowswebsite'
    </code>
    
    The ```--name``` parameter specified the name of the new container, ```-d``` means the container is detached, i.e. runs in the background rather than interactively, ```-p 50001:80``` maps port 50001 on the host network to port 80 on the container.
    
2. Open a web browser with the IP address of the server core instance directed to port 50001.

    <code>http://&lt;server_ip_address&gt;50002</code>

    You should now be able to see IIS running. Move onto the next post that will provide steps for deploying your website to a container.