# Sandbox Community Edition
Repository for the free community edition of the sandbox

## Installation
The following document will outline downloading and installing the Logica Sandbox Community Edition and getting it running.

This document is broken into four sections. An “Overview” which outlines what is required to get the system running and then three installation sections… one each for MacOS, Linux, and Windows installations. Versions of the operating systems used and tested and the versions of any tools will be explicitly stated where appropriate. We recognize tools change over time and the content of this document may be out-of-date by the time you read this. We hope to give you enough information to adjust to new versions as needed. Some of the information in this document may seem remedial but we are including it anyway for those who may not be as familiar with the command line and other tools involved in the setup.

NOTE: The community edition is currently using HAPI 4.2.0. The Enterprise edition currently running online will soon be at HAPI 5.2.0. 

WARNING: Follow these instructions VERY carefully. If you miss a step… you will likely get pages and pages of errors.

## Overview
Running the sandbox locally on any OS requires the following:
* Docker (tested with Docker Desktop v3.0.4)
* MySQL container populated from sql scripts
* Keycloak server container
* Sandbox containers
* FHIR server containers

In the current configuration there will be a total of 11 containers. These containers listen on specific network TCP ports as described in the next section.

Setting up the networking environment on your machine:

The sandbox makes use of the following TCP ports and may conflict with services already running on your system:
* 3001 - http (user interface) server
* 3306 - MySQL 5.7 database server
* 8060 - OAuth server
* 8070 - FHIR R4 server
* 8078 - FHIR DSTU2 server
* 8079 - FHIR STU3 server
* 8080 - Keycloak authentication server
* 8086 - Bilirubin Risk Chart sample app
* 8090 - Static content server
* 8096 - Patient Data Manager sample app
* 12000 - Sandbox Manager server

Stop any current services running on these ports before running the containers. A script to check for anything listening on these ports (check-ports.sh and check-ports.bat) is included in the community edition. Most conflicts will occur when a developer has something running on one of these ports. If you have a MySQL server running you will likely get a conflict on port 3306.

The sandbox also uses a number of internal redirects built into the user interface requiring modification of the hosts file (/etc/hosts on macOS and linux)

* 127.0.0.1 keycloak
* 127.0.0.1 sandbox-mysql
* 127.0.0.1 sandbox-manager-api
* 127.0.0.1 reference-auth
* 127.0.0.1 dstu2
* 127.0.0.1 stu3
* 127.0.0.1 r4
* 127.0.0.1 static-content

This tells the web browser on the local machine that, for example, “http://r4/”  will be found listening on the local machine… assuming the container is running.

## Mac OS Install

OSX Install (tested under macOS Catalina 10.15.7):

There are two options to install Docker Desktop. Either install it by going to the website, downloading it, and running the dmg file… or install “homebrew” and then use homebrew to install it. For the minimum… just install Docker Desktop. Homebrew is a package manager for installing all sorts of tools and utilities… but you may not want it. If docker is already installed please skip ahead to setting it up to give the containers enough memory.

NOTE: If you want to install docker using homebrew you’ll find installation instructions in the appendix.

Install Docker Desktop from the Docker website:

Browse to: https://www.docker.com/products/docker-desktop.
Download and run the installer
	

Setting up Docker Desktop:

Run the Docker Desktop app and set the memory allocation requirements by clicking on the gear in the top right corner of the main dialog… then Resources… then ADVANCED:
![Docker Settings](./images/docker_settings.png)

Set Memory to a minimum of 8.00 GB:
![Docker Memory](./images/docker_memory.png)
Now instances will get the memory they require to run correctly. If you are running into memory issues with the containers this is most likely the culprit.

## Download and Install
1. Clone this project 
	```sh
	git clone https://github.com/logicahealth/sandbox-community-edition.git
	```
2. Change to the new directory
	```sh
	cd sandbox-community-edition
	```
3. Set up an internal network for docker to use
    ```sh
   docker network create logica-network
   ```
4. Download and run the mysql instance
    ```sh 
    docker-compose up -d sandbox-mysql
    ```
5. Populate the mysql database from the sql scripts
NOTE: let’s make this a script… seed-database.sh maybe?
    ```sh 
   for i in *.sql; do 
        echo $i;
        docker exec -i communityedition_sandbox-mysql mysql -uroot -ppassword < $i; 
   done
   ```
6. Confirm that the database schemas imported successfully (optional step). Run the following command to go to the bash prompt of the MySQL container. 
   ```sh
   docker exec -it communityedition_sandbox-mysql bash
   ```
    
    Run this to connect to the database and list out the schemas
    ```sh
    mysql -uroot -ppassword -e "show databases;"
   ```
    
    This should list out the database schemas:

    ```
    +-------------------------+
    | Database                |
    +-------------------------+
    | hspc_8_MasterDstu2Empty |
    | hspc_8_MasterDstu2Smart |
    | hspc_8_MasterR4Empty    |
    | hspc_8_MasterR4Smart    |
    | hspc_8_MasterStu3Empty  |
    | hspc_8_MasterStu3Smart  |
    | hspc_8_hspc10           |
    | hspc_8_hspc8            |
    | hspc_8_hspc9            |
    | oic                     |
    | sandman                 |
    | sys                     |
    +-------------------------+
    ```

    Make sure that the schemas listed above show up. There may be additional schemas listed, but that is not an issue.
    Exit the bash prompt of the MySQL container by running the following command

   ```sh
    exit
   ```
## Starting the sandbox
In the same terminal window… or another terminal window... run the following:
   ```sh
    docker-compose up
   ```
	
This will start the services for the sandbox. Images for the containers will be downloaded from docker hub. This process may take a while the first time… and produce a lot of logging output.

To check if things are running open another terminal window and run:
   ```sh
    docker-compose ps
   ```
	
You should see something like this… showing the running instances… and the ports they are listening on. All the states should say “Up”:
```
                        Name                                       Command               State                         Ports                      
--------------------------------------------------------------------------------------------------------------------------------------------------
communityedition_sandbox-mysql                          docker-entrypoint.sh mysqld      Up      0.0.0.0:3306->3306/tcp, 33060/tcp                
sandbox-community-edition_bilirubin-risk-chart_1        docker-entrypoint.sh npm r ...   Up      0.0.0.0:8086->8086/tcp                           
sandbox-community-edition_dstu2_1                       sh -c java $JAVA_OPTS -jar ...   Up      0.0.0.0:8078->8078/tcp                           
sandbox-community-edition_keycloak_1                    /opt/jboss/tools/docker-en ...   Up      0.0.0.0:8080->8080/tcp, 8443/tcp                 
sandbox-community-edition_patient-data-manager_1        docker-entrypoint.sh npm r ...   Up      0.0.0.0:8096->8096/tcp                           
sandbox-community-edition_r4_1                          sh -c java $JAVA_OPTS -jar ...   Up      0.0.0.0:8070->8070/tcp                           
sandbox-community-edition_reference-auth_1              sh -c java $JAVA_OPTS -Dja ...   Up      0.0.0.0:8060->8060/tcp                           
sandbox-community-edition_sandbox-manager-api_1         sh -c java $JAVA_OPTS -jar ...   Up      0.0.0.0:12000->12000/tcp                         
sandbox-community-edition_sandbox-manager-prototype_1   /sbin/entrypoint.sh /usr/s ...   Up      1935/tcp, 0.0.0.0:3001->3000/tcp, 443/tcp, 80/tcp
sandbox-community-edition_static-content_1              /docker-entrypoint.sh ngin ...   Up      0.0.0.0:8090->80/tcp                             
sandbox-community-edition_stu3_1                        sh -c java $JAVA_OPTS -jar ...   Up      0.0.0.0:8079->8079/tcp    
```

In a web browser (preferably Chrome) go to http://localhost:3001. You should see a Keycloak login screen like the following. Click on register and fill in your details.
![Keycloak registration](./images/keycloak_registration.png)
You will be able to use this username and password to login to the sandbox from now on whenever you run it. NOTE: If you ever lose or forget this password… look in the appendices to find out how to reset it.
After logging in, you should see the following screen with no sandboxes. Click the NEW SANDBOX button to create a sandbox.

After you have created a sandbox you will see them listed:
![First Login](./images/first_login.png)

## Starting and stopping the sandbox
Start the servers.
   ```sh
    docker-compose up
   ```
In another terminal window show the running servers
   ```sh
    docker-compose ps
   ```
Run the `check-ports.sh` shell script to see the services listening on ports. If you get an error saying permission is denied, then run the command `chmod +x check-ports.sh`.
```
com.docke   698 gopalmenon   84u  IPv6 0xc9b8f9c3369a097      0t0  TCP *:3001 (LISTEN)
com.docke   698 gopalmenon   83u  IPv6 0xc9b8f9c227ec6f7      0t0  TCP *:3306 (LISTEN)
com.docke   698 gopalmenon   90u  IPv6 0xc9b8f9c35f4d3b7      0t0  TCP *:8060 (LISTEN)
com.docke   698 gopalmenon   92u  IPv6 0xc9b8f9c28be8d57      0t0  TCP *:8070 (LISTEN)
com.docke   698 gopalmenon   91u  IPv6 0xc9b8f9c20d0dd57      0t0  TCP *:8078 (LISTEN)
com.docke   698 gopalmenon   93u  IPv6 0xc9b8f9c35f4cd57      0t0  TCP *:8079 (LISTEN)
com.docke   698 gopalmenon   87u  IPv6 0xc9b8f9c2c86ea17      0t0  TCP *:8080 (LISTEN)
com.docke   698 gopalmenon   85u  IPv6 0xc9b8f9c3369b3b7      0t0  TCP *:8086 (LISTEN)
com.docke   698 gopalmenon   88u  IPv6 0xc9b8f9c2c86d6f7      0t0  TCP *:8090 (LISTEN)
com.docke   698 gopalmenon   86u  IPv6 0xc9b8f9c2c86e3b7      0t0  TCP *:8096 (LISTEN)
com.docke   698 gopalmenon   89u  IPv6 0xc9b8f9c2c86d097      0t0  TCP *:12000 (LISTEN)
```
Use the following command to stop them.
```sh
docker-compose stop
```
You will see something like this as the containers are stopped:
```
Stopping sandbox-community-edition_static-content_1            ... done
Stopping sandbox-community-edition_patient-data-manager_1      ... done
Stopping sandbox-community-edition_bilirubin-risk-chart_1      ... done
Stopping sandbox-community-edition_keycloak_1                  ... done
Stopping sandbox-community-edition_stu3_1                      ... done
Stopping sandbox-community-edition_r4_1                        ... done
Stopping sandbox-community-edition_dstu2_1                     ... done
Stopping sandbox-community-edition_sandbox-manager-api_1       ... done
Stopping sandbox-community-edition_reference-auth_1            ... done
Stopping communityedition_sandbox-mysql                        ... done
Stopping sandbox-community-edition_sandbox-manager-prototype_1 ... done
```

If you run the `check-ports.sh` shell script… you will see no output once the containers are stopped.

Running `docker-compose ps` will show something like the following:
```
                        Name                                       Command                State     Ports
---------------------------------------------------------------------------------------------------------
communityedition_sandbox-mysql                          docker-entrypoint.sh mysqld      Exit 0          
sandbox-community-edition_bilirubin-risk-chart_1        docker-entrypoint.sh npm r ...   Exit 0          
sandbox-community-edition_dstu2_1                       sh -c java $JAVA_OPTS -jar ...   Exit 137        
sandbox-community-edition_keycloak_1                    /opt/jboss/tools/docker-en ...   Exit 0          
sandbox-community-edition_patient-data-manager_1        docker-entrypoint.sh npm r ...   Exit 0          
sandbox-community-edition_r4_1                          sh -c java $JAVA_OPTS -jar ...   Exit 137        
sandbox-community-edition_reference-auth_1              sh -c java $JAVA_OPTS -Dja ...   Exit 137        
sandbox-community-edition_sandbox-manager-api_1         sh -c java $JAVA_OPTS -jar ...   Exit 137        
sandbox-community-edition_sandbox-manager-prototype_1   /sbin/entrypoint.sh /usr/s ...   Exit 0          
sandbox-community-edition_static-content_1              /docker-entrypoint.sh ngin ...   Exit 0          
sandbox-community-edition_stu3_1                        sh -c java $JAVA_OPTS -jar ...   Exit 137  
```
## Linux Install
Install docker desktop for your distribution of Linux. 

1. Clone this project 
	```sh
	git clone https://github.com/logicahealth/sandbox-community-edition.git
	```
2. Change to the new directory
	```sh
	cd sandbox-community-edition
	```
3. Create a docker network using the command
    ```sh
    sudo docker network create logica-network
    ```
4. Start the MySQL container 
    ```sh
    sudo docker-compose up -d sandbox-mysql
    ```
5. Run the following command to make sure that the MySQL container is up
    ```sh
    sudo docker-compose ps
    ```
    The service sandbox-mysql should be visible with status Up similar to what is shown below.
    ```sh
                        Name                                   Command                State                   Ports              
    -----------------------------------------------------------------------------------------------------------------------------
    communityedition_sandbox-mysql                  docker-entrypoint.sh mysqld      Up         0.0.0.0:3306->3306/tcp, 33060/tcp
    ```
6. Now run the following in order to seed the database
    ```sh
    for i in *.sql; do 
        echo $i;
        docker exec -i communityedition_sandbox-mysql mysql -uroot -ppassword < $i; 
   done
    ```
7. Run the following command to bring down the database
    ```sh
    sudo docker-compose stop
    ```
8. Add the following rows to the file /etc/hosts using a text editor
    ```
    127.0.0.1  keycloak
    127.0.0.1  sandbox-mysql
    127.0.0.1  sandbox-manager-api
    127.0.0.1  reference-auth
    127.0.0.1  dstu2
    127.0.0.1  stu3
    127.0.0.1  r4
    127.0.0.1  static-content
    ```

    Here is an example of using nano to edit `/etc/hosts`

    ```sh
    sudo nano /etc/hosts
    ```
9. Now start the sandbox using the command
    ```sh
    docker-compose up
    ```
10. Run the following command to see a list of docker processes that are running.
    ```sh
    sudo docker-compose ps
    ```
    You should see something similar to the screen print below showing that 11 processes are with status Up.
    ```
                            Name                                       Command               State                         Ports                      
    --------------------------------------------------------------------------------------------------------------------------------------------------
    communityedition_sandbox-mysql                          docker-entrypoint.sh mysqld      Up      0.0.0.0:3306->3306/tcp, 33060/tcp                
    sandbox-community-edition_bilirubin-risk-chart_1        docker-entrypoint.sh npm r ...   Up      0.0.0.0:8086->8086/tcp                           
    sandbox-community-edition_dstu2_1                       sh -c java $JAVA_OPTS -jar ...   Up      0.0.0.0:8078->8078/tcp                           
    sandbox-community-edition_keycloak_1                    /opt/jboss/tools/docker-en ...   Up      0.0.0.0:8080->8080/tcp, 8443/tcp                 
    sandbox-community-edition_patient-data-manager_1        docker-entrypoint.sh npm r ...   Up      0.0.0.0:8096->8096/tcp                           
    sandbox-community-edition_r4_1                          sh -c java $JAVA_OPTS -jar ...   Up      0.0.0.0:8070->8070/tcp                           
    sandbox-community-edition_reference-auth_1              sh -c java $JAVA_OPTS -Dja ...   Up      0.0.0.0:8060->8060/tcp                           
    sandbox-community-edition_sandbox-manager-api_1         sh -c java $JAVA_OPTS -jar ...   Up      0.0.0.0:12000->12000/tcp                         
    sandbox-community-edition_sandbox-manager-prototype_1   /sbin/entrypoint.sh /usr/s ...   Up      1935/tcp, 0.0.0.0:3001->3000/tcp, 443/tcp, 80/tcp
    sandbox-community-edition_static-content_1              /docker-entrypoint.sh ngin ...   Up      0.0.0.0:8090->80/tcp                             
    sandbox-community-edition_stu3_1                        sh -c java $JAVA_OPTS -jar ...   Up      0.0.0.0:8079->8079/tcp       
    ```
11. Go to http://localhost:3001 on a browser to go to the sandbox. You will need to register the first time you are there. Save your user and password information.
12. To stop the sandbox
    ```sh
    sudo docker-compose stop
    ```

## Windows Install
Whatever

## FAQ
### Something is listening on a port… and I don’t know how to kill it:

### Lost or forgotten password: 

If you do not remember your username or password, you will need to go to the Keycloak server and login as an administrator. Go to http://localhost:8080/ on a browser and you will see the following screen.
![Keycloak Console](./images/keycloak_console.png)

Click on Administration Console and login with user `admin` and password `admin`. 

Now click on Users and View all users.
![Keycloak Users](./images/keycloak_users.png)

Click on the ID of your user and you will be able to see the username you need to login.
![Keycloak User Details](./images/keycloak_user_details.png)

To reset your password, go to the Credentials tab.
![Keycloak User Credentials](./images/keycloak_user_credentials.png)
Key in your new preferred password into Password and Password Confirmation. Toggle the Temporary setting to OFF. Click on Reset Password and press Reset password on the confirmation screen that pops up asking if you are sure. Now you can logoff as Keycloak administrator by clicking on the Admin drop down on the top right.

Go http://localhost:3001 and login with your new password.


### Containers won’t start up… oh noes...:

### How do I install homebrew:

Homebrew is a package manager for macOS and Linux. It turns out macOS comes with a minimal and fairly outdated set of command line tools… and no easy way to update and manage new versions. This provides a stable enough base for macOS. However, anyone who lives/eats/breathes command line… or is curious about all things UNIX… will want more. Installing Homebrew gives easy access to thousands of command line tools… and also regular macOS applications… like Docker Desktop.

Install homebrew:
	For information about Homebrew browse to https://brew.sh/
	To just skip to the chase and get it done… open a terminal and cut and paste the following commands and hit return:
	This command will install homebrew:
```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

This command will install docker:
```sh
brew install --cask docker-toolbox
```
This command will install a VERY handy tool called curl:
```sh
brew install curl
```

### Memory issues:

If you are running into memory issues with the containers you need to double check you have allocated enough memory in Docker Desktop for the containers.
