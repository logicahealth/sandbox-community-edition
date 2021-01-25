# Sandbox Community Edition
Repository for the free community edition of the sandbox

##Installation
The following document will outline downloading and installing the Logica Sandbox Community Edition and getting it running.
This document is broken into four sections. An “Overview” which outlines what is required to get the system running and then three installation sections… one each for MacOS, Linux, and Windows installations. Versions of the operating systems used and tested and the versions of any tools will be explicitly stated where appropriate. We recognize tools change over time and the content of this document may be out-of-date by the time you read this. We hope to give you enough information to adjust to new versions as needed. Some of the information in this document may seem remedial but we are including it anyway for those who may not be as familiar with the command line and other tools involved in the setup.
NOTE: The community edition is currently using HAPI 4.2.0. The Enterprise edition currently running online will soon be at HAPI 5.2.0. 
WARNING: Follow these instructions VERY carefully. If you miss a step… you will likely get pages and pages of errors.

##Overview
Running the sandbox locally on any OS requires the following:
* Docker (tested with Docker Desktop v3.0.4)
* MySQL container populated from sql scripts
* Keycloak server container
* Sandbox containers
* FHIR server containers

In the current configuration there will be a total of 8 containers. These containers listen on specific network TCP ports as described in the next section.

Setting up the networking environment on your machine:
The sandbox makes use of the following TCP ports and may conflict with services already running on your system:
* 3001 - http (user interface) server
* 3306 - MySQL 5.7 database server
* 8060 - OAuth server
* 8070 - FHIR R4 server
* 8078 - FHIR DSTU2 server
* 8079 - FHIR STU3 server
* 8080 - Keycloak authentication server
* 12000 - Sandbox manager server

Stop any current services running on these ports before running the containers. A script to check for anything listening on these ports (check-ports.sh and check-ports.bat) is included in the community-edition.zip file. Most conflicts will occur when a developer has something running on one of these ports. If you have a MySQL server running you will likely get a conflict on port 3306.

The sandbox also uses a number of internal redirects built into the user interface requiring modification of the hosts file (/etc/hosts on macOS and linux)

* 127.0.0.1 keycloak
* 127.0.0.1 sandbox-mysql
* 127.0.0.1 sandbox-manager-api
* 127.0.0.1 reference-auth
* 127.0.0.1 dstu2
* 127.0.0.1 stu3
* 127.0.0.1 r4

This tells the web browser on the local machine that, for example, “http://r4/”  will be found listening on the local machine… assuming the container is running.
Installation directory:

## MacOS Install

OSX Install (tested under macOS Catalina 10.15.7):
There are two options to install Docker Desktop. Either install it by going to the website, downloading it, and running the dmg file… or install “homebrew” and then use homebrew to install it. For the minimum… just install Docker Desktop. Homebrew is a package manager for installing all sorts of tools and utilities… but you may not want it. If docker is already installed please skip ahead to setting it up to give the containers enough memory.

NOTE: If you want to install docker using homebrew you’ll find installation instructions in the appendix.

Install Docker Desktop from the Docker website:
	Browse to: https://www.docker.com/products/docker-desktop
	Download and run the installer
	

Setting up Docker Desktop:
	Run the Docker Desktop app and set the memory allocation requirements by clicking on the gear in the top right corner of the main dialog… then Resources… then ADVANCED:

Set Memory to a minimum of 8.00 GB:

Now instances will get the memory they require to run correctly. If you are running into memory issues with the containers this is most likely the culprit.

## Download and Install
First, download community-edition.zip and unzip it into /Users/Shared. When finished… you should have the directory /Users/Shared/community-edition containing the docker-compose.yml file, a number of .sql files, and a number of .sh and .bat files.

NOTE: If homebrew and curl are installed you can do all this with the following command:
Open a terminal window and run the following command:
curl https://neuronsong.com/_/_upload/server/php/files/community-edition.zip | tar -xf - --C -C /Users/Shared
This pulls down a copy of the community-edition.zip and unzips it into /Users/Shared
If everything went well you will now have the required files in:
/Users/Shared/community-edition
Change into the directory created from the zip file
      cd /Users/Shared/community-edition
Set up a logical network for docker to use
      docker network create logica-network
Download and run the mysql instance
      docker-compose up -d sandbox-mysql
Populate the mysql database from the sql scripts
NOTE: let’s make this a script… seed-database.sh maybe?
     for i in *.sql; do docker exec -i communityedition_sandbox-mysql mysql -uroot -ppassword < $i; done
## Confirm that the database schemas imported successfully (optional step)
Run the following command to go to the bash prompt of the MySQL container. 
    docker exec -it communityedition_sandbox-mysql bash
Run this to connect to the database and list out the schemas
mysql -uroot -ppassword -e "show databases;"
    
This should list out the database schemas:
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
Make sure that the schemas listed above show up. There may be additional schemas listed, but that is not an issue.
Exit the bash prompt of the MySQL container by running the following command
   exit
## Starting the sandbox
In the same terminal window… or another terminal window... run the following:
	docker-compose up
This will start the services for the sandbox. Images for the containers will be downloaded from docker hub. This process may take a while the first time… and produce a lot of logging output.
To check if things are running open another terminal window and run:
	docker-compose ps
You should see something like this… showing the running instances… and the ports they are listening on. All the states should say “Up”:


In a web browser (preferably Chrome) go to http://localhost:3001. You should see a Keycloak login screen like the following. Click on register and fill in your details.
 You will be able to use this username and password to login to the sandbox from now on whenever you run it. NOTE: If you ever lose or forget this password… look in the appendices to find out how to reset it.
After logging in, you should see the following screen with no sandboxes. Click the NEW SANDBOX button to create a sandbox.

After you have created a sandbox you will see them listed:

## Starting and stopping the sandbox
Start the servers.
$ docker-compose up
In another terminal window show the running servers
$ docker-compose ps

$ bash ./check-ports.sh

Use the following command to stop them.
$ docker-compose stop
You will see something like this as the containers are stopped:


If you run the “check-ports.sh” script… you will see no output once the containers are stopped.

Running “docker-compose ps” will show something like the following:

## Linux Install
Install docker desktop for your distribution of Linux.Create 

Create folder /Users/Shared using commands
$ cd /
$ sudo mkdir Users
$ cd Users
$ sudo mkdir Shared

Download community-edition.zip into the folder /Users/Shared

Extract the contents of the zip file using command
$ sudo unzip community-edition.zip

Go to the new folder using command
$ cd community-edition

Create a docker network using the command
$ sudo docker network create logica-network

Start the MySQL container 
$ sudo docker-compose up -d sandbox-mysql

Run the following command from folder /Users/Shared/community-edition to make sure that the MySQL container is up
$ sudo docker-compose ps

The service sandbox-mysql should be visible with status Up similar to what is shown below.

                    Name                                   Command                State                   Ports              
-----------------------------------------------------------------------------------------------------------------------------
communityedition_sandbox-mysql                  docker-entrypoint.sh mysqld      Up         0.0.0.0:3306->3306/tcp, 33060/tcp

Now run the following in order to seed the database
$ for i in *.sql; do docker exec -i communityedition_sandbox-mysql mysql -uroot -ppassword < $i; done
Run the following command to bring down the database
$ sudo docker-compose stop
Add the following rows to the file /etc/hosts using a text editor
127.0.0.1  keycloak
127.0.0.1  sandbox-mysql
127.0.0.1  sandbox-manager-api
127.0.0.1  reference-auth
127.0.0.1  dstu2
127.0.0.1  stu3
127.0.0.1  r4

Here is an example of using nano to edit /etc/hosts
$ sudo nano /etc/hosts
Now start the sandbox using the command
$ docker-compose up
Run the following command to see a list of docker processes that are running.
$ sudo docker-compose ps
You should see something similar to the screen print below showing that 8 processes are with status Up.
                    Name                                   Command               State                         Ports                      
------------------------------------------------------------------------------------------------------------------------------------------
community-edition_dstu2_1                       sh -c java $JAVA_OPTS -jar ...   Up      0.0.0.0:8078->8078/tcp                           
community-edition_keycloak_1                    /opt/jboss/tools/docker-en ...   Up      0.0.0.0:8080->8080/tcp, 8443/tcp                 
community-edition_r4_1                          sh -c java $JAVA_OPTS -jar ...   Up      0.0.0.0:8070->8070/tcp                           
community-edition_reference-auth_1              sh -c java $JAVA_OPTS -Dja ...   Up      0.0.0.0:8060->8060/tcp                           
community-edition_sandbox-manager-api_1         sh -c java $JAVA_OPTS -jar ...   Up      0.0.0.0:12000->12000/tcp                         
community-edition_sandbox-manager-prototype_1   /sbin/entrypoint.sh /usr/s ...   Up      1935/tcp, 0.0.0.0:3001->3000/tcp, 443/tcp, 80/tcp
community-edition_stu3_1                        sh -c java $JAVA_OPTS -jar ...   Up      0.0.0.0:8079->8079/tcp                           
communityedition_sandbox-mysql                  docker-entrypoint.sh mysqld      Up      0.0.0.0:3306->3306/tcp, 33060/tcp 

Go to http://localhost:3001 on a browser to go to the sandbox. You will need to register the first time you are there. Save your user and password information.
To stop the sandbox
$ sudo docker-compose stop

## Windows Install
Whatever



## FAQ
### Something is listening on a port… and I don’t know how to kill it:

### Lost or forgotten password: 

If you do not remember your username or password, you will need to go to the Keycloak server and login as an administrator. Go to http://localhost:8080/ on a browser and you will see the following screen.


Click on Administration Console and login with user admin and password admin. 

Now click on Users and View all users.



Click on the ID of your user and you will be able to see the username you need to login.



To reset your password, go to the Credentials tab.

Key in your new preferred password into Password and Password Confirmation. Toggle the Temporary setting to OFF. Click on Reset Password and press Reset password on the confirmation screen that pops up asking if you are sure. Now you can logoff as Keycloak administrator by clicking on the Admin drop down on the top right.

Go http://localhost:3001 and login with your new password.


### Containers won’t start up… oh noes...:

### How do I install homebrew:

Homebrew is a package manager for macOS and Linux. It turns out macOS comes with a minimal and fairly outdated set of command line tools… and no easy way to update and manage new versions. This provides a stable enough base for macOS. However, anyone who lives/eats/breathes command line… or is curious about all things UNIX… will want more. Installing Homebrew gives easy access to thousands of command line tools… and also regular macOS applications… like Docker Desktop.

Install homebrew:
	For information about Homebrew browse to https://brew.sh/
	To just skip to the chase and get it done… open a terminal and cut and paste the following commands and hit return:
	This command will install homebrew:
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	This command will install docker:
	brew install --cask docker-toolbox
	This command will install a VERY handy tool called curl:
brew install curl



### Memory issues:

If you are running into memory issues with the containers you need to double check you have allocated enough memory in Docker Desktop for the containers.


