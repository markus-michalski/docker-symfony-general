# Docker setup for use with Symfony

This Docker setup installs an environment with latest Symfony Cli and a Symfony 7.1 standard web project in /var/www/html
Also the following packs:
debug
apache-pack

This setup is meant to be used just like a real Linux webserver, so you have to connect to it via SSH and SFTP. 

It has no Docker volumes to not slow it down with file management and symlink stuff when used in Windows.
This also means that when the containers are deleted the files in it are gone - so beware.  

I use it with PHPStorm in a remote host with SFTP access configuration.

Replace in the dockerfile under git configuration the global e-mail and name with your preferred credentials.

## Important URLs
Shop: https://localhost  
phpmyadmin: http://localhost:8080/ (Login: docker // docker)  
SSH/SFTP: root@localhost Port: 2222 (Login: docker)

## Docker setup
### Create container
docker-compose build
### Fire up container
docker-compose up -d  
  
To create multiple setups, name your setup manually:    
docker-compose -pMYPROJECT up -d
