# PURPOSE
Automates building a LAMP + C9 stack on a fresh install of ARM centos 7 for the Raspberry pi.
  - Installs misc usability items (git,wget,nano,iptables,yum-utils)
  - Installs php72
  - Installs apache
  - Creates additional vhosts
  - Installs mysqld (mariadb)
  - Creates SSH user
  - Creates mysql user
  - Installs C9 IDE locally





# HOW TO USE
ssh into your centos box `ssh root@IP_HERE` 
<br>*[default password is `centos`]*

Download the .sh script, make it executable, run it, and go through the wizard using:

```curl https://raw.githubusercontent.com/travisscottwilder/CentosDevServerInstaller/main/CentosDevServerInstaller.sh > CentosDevServerInstaller.sh;chmod +x CentosDevServerInstaller.sh;./CentosDevServerInstaller.sh;```

<br>

![Menu selection](/menu_select.png)


# REQUIREMENTS
  - Must be connected to the internet
  - Need id_rsa.pub value (public key) if creating SSH user (use `ssh-keygen` to generate keys)
  - Keyboard to type answers asked by wizard
  - Centos 7 for raspberry Pi [https://mirror.math.princeton.edu/pub/centos-altarch/7/isos/armhfp/CentOS-Userland-7-armv7hl-RaspberryPI-Minimal-2009-sda.raw.xz]


# NOTES
This is intended to be used only on a development local environment as the configuration/security of this installer is not of production quality due to *at least*
  - /var/www is made 777
  - MySQL user created is given % host & full admin priveldges 
  - ssh root user has password enabled
  - https is not enabled or forced
  - php72 is used instead of php73
