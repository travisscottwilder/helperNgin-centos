# PURPOSE
Automates building a LAMP + C9 stack on a fresh install of ARM centos 7 for the Raspberry pi.
  - Installs misc usability items (git,wget,nano,iptables,yum-utils)
  - Installs php72
  - Installs apache
  - Create additional vhosts
  - Installs mysqld (mariadb)
  - Creates SSH user
  - Creates mysql user
  - Installs C9





# HOW TO USE
Download the .sh script, make it executable, run it, and go through the wizard.

`curl https://raw.githubusercontent.com/travisscottwilder/CentosDevServerInstaller/main/CentosDevServerInstaller.sh > CentosDevServerInstaller.sh;chmod +x CentosDevServerInstaller.sh;./CentosDevServerInstaller.sh;`

<br>

![Menu selection](/menu_select.png)


# REQUIREMENTS
  - Must be connected to the internet
  - Need id_rsa.pub value (public key) if creating SSH user (use `ssh-keygen` to generate keys)
  - Keyboard to type answers asked by wizard
