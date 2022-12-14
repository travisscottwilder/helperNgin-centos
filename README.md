# PURPOSE
Automates building a LAMP (web server) + C9 IDE stack on a fresh install of ARM centos 7 for the Raspberry pi. (CentOS-Userland-7-armv7hl-RaspberryPI-Minimal-2009-sda.raw)
  - Installs misc usability items (git,wget,nano,iptables,yum-utils)
  - Installs php72
  - Installs apache
  - Installs C9 IDE locally
  - Installs mysqld (mariadb)
  - Creates additional vhosts
  - Creates mysql user
  - Creates SSH user

<br>

![Menu selection](/images/menu_select.png)



# HOW TO USE
ssh into your centos box `ssh root@IP_HERE` 
<br>*[default password is `centos`]*

Download the .sh script, make it executable, run it, and go through the wizard using:

```curl https://raw.githubusercontent.com/travisscottwilder/helperNgin-centos/main/CentosDevServerInstaller.sh > CentosDevServerInstaller.sh;chmod +x CentosDevServerInstaller.sh;./CentosDevServerInstaller.sh;```

<br>
Assuming a full install (item 1)- the installer takes about 35 minutes on a Raspberry Pi 3.
Your input will be needed at the beginning and at the very end. It is safe to walk away and make a sandwich.
<br><br>

![summary](/images/summary.png)


# REQUIREMENTS
  - Must be connected to the internet
  - Need id_rsa.pub value (public key) if creating SSH user (use `ssh-keygen` to generate keys)
  - Centos 7 for raspberry Pi [https://mirror.math.princeton.edu/pub/centos-altarch/7/isos/armhfp/CentOS-Userland-7-armv7hl-RaspberryPI-Minimal-2009-sda.raw.xz]


# NOTES
This is intended to be used only on a development local environment as the configuration/security of this installer is not of production quality due to *at least*
  - /var/www is made 777
  - MySQL user created is given % host & full admin privileges 
  - ssh root user has password enabled
  - https is not enabled or forced
  - php72 is used instead of php73
  - Username and passwords are supplied via command line input

<br>

![C9](/images/c9.jpg)
