#!/bin/bash 
#
#	if you get special character error:
#		NOTEPAD++: 	Edit --> EOL Conversion --> UNIX/OSX Format
#		LINUX:		sed -i -e 's/\r$//' scriptname.sh
#

STARTTIME=$(date +%s)

red=$'\e[01;31m'
green=$'\e[01;32m'
yellow=$'\e[01;33m'
blue=$'\e[01;34m'
magenta=$'\e[01;35m'
resetColor=$'\e[0m'

exe_twoFresh=false;
exe_threePHP=false;
exe_fourVHOST=false;
exe_fiveMYSQL=false;
exe_sixMYSQLUSER=false;
exe_sevenSSHUSER= ;
exe_eightC9=false;
exe_nineUpdateRootSSHUser=false;
exe_actionDone="NA";

vhosts_added="";

c9portToUse=9191;




#
#
#
#
#
#
freshCentosInstall() {
	echo "";
	echo "${blue}--- Fresh Install - updating System --------------------------------------------${resetColor}"

	rootfs-expand;
	yum -y remove postfix;
	yum update -y;
	yum clean all;
	yum -y install git wget nano iptables-services yum-utils;
	systemctl enable iptables;
	sudo service iptables start;
	yum clean all;
	yum update -y;
	
	echo "${blue}----------------------------------------------------------------------------------------------------------${resetColor}"
}



#
#
#
#
#
#
#
installReposApachePhp() {
	echo "";
	echo "${blue}--- Adding REPOS --------------------------------------------${resetColor}"
	
	touch /etc/yum.repos.d/epel.repo
	touch /etc/yum.repos.d/remi.repo
	touch /etc/yum.repos.d/php72-testing.repo
	
	
	cat > /etc/yum.repos.d/epel.repo <<EOF
[epel]
name=Epel rebuild for armhfp
baseurl=https://armv7.dev.centos.org/repodir/epel-pass-1/
enabled=1
gpgcheck=0
EOF
	
	cat > /etc/yum.repos.d/php72-testing.repo <<EOF
[php72-testing]
name=Remi php72 rebuild for armhfp
baseurl=https://armv7.dev.centos.org/repodir/community-php72-testing/
enabled=1
gpgcheck=0
EOF
	
	cat > /etc/yum.repos.d/remi.repo <<EOF
[remi]
name=Remi's RPM repository for Enterprise Linux 7 - $basearch
mirrorlist=http://cdn.remirepo.net/enterprise/7/remi/mirror
enabled=1
gpgcheck=1
gpgkey=https://rpms.remirepo.net/RPM-GPG-KEY-remi
EOF
	
	echo "${blue}--- Installing apache --------------------------------------------${resetColor}"
	echo "";
	
	yum clean all;
	yum update -y;
	yum -y install httpd php php-common php-cli php-devel php-fpm php-gd php-imap php-intl php-mysql php-process php-xml php-xmlrpc php-zts;
	
	service httpd start;
	service httpd restart;
	chkconfig httpd on;
	sudo iptables -A INPUT -p tcp --dport 80 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT;
	sudo iptables -A INPUT -p tcp --dport $c9portToUse -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT;
	sudo service iptables save;
	sudo iptables --flush;
	
	makePHPFilesPriority
}



#
#
#
#
#
makePHPFilesPriority(){
	echo "";
	
	echo "${blue}--- Updating apache to prioritize PHP files over HTML --------------------------------------------${resetColor}"
	
	sed -i '/DirectoryIndex index.html/c\DirectoryIndex index.php index.html' /etc/httpd/conf/httpd.conf
	service httpd restart;
	
}


#
#
#
#
#
createAllVhostDomains(){
	echo "";
	

	echo "";
	echo "${yellow}--- Name of website you would like to add (IE: travis.com) --------------------------------------------${resetColor}"
	read websiteToCreate	
	touch /etc/httpd/conf.d/$websiteToCreate.conf;		
	mkdir -p /var/www/$websiteToCreate;
	chmod 777 /var/www -R;
	
	
	cat > /etc/httpd/conf.d/$websiteToCreate.conf <<EOF
<VirtualHost *:80>
ServerName $websiteToCreate
ServerAlias www.$websiteToCreate
DocumentRoot /var/www/$websiteToCreate
ErrorLog /etc/httpd/logs/error_log
CustomLog /etc/httpd/logs/access_log combined
</VirtualHost>
EOF
	
	touch /var/www/$websiteToCreate/index.html;
	echo "[PHP] index page inside [$websiteToCreate]" > /var/www/$websiteToCreate/index.html;
	
	touch /var/www/$websiteToCreate/index.php;
	echo "[PHP] index page inside [$websiteToCreate]" > /var/www/$websiteToCreate/index.php;
	
	echo "";
	
	echo "${green}--- successfully added $websiteToCreate --------------------------------------------${resetColor}";
	echo "";
	
	vhosts_added+="${websiteToCreate},"
	
	while true; do
		read -p "${yellow}--- Would you like to install an additional site (vhost) onto this box? [y/n] --------------------------------------------${resetColor}" yn
		case $yn in
			[Yy]* )  
				createAllVhostDomains			
				break;;
			[Nn]* ) break;;
			* ) echo "Please answer [y/n].";;
		esac
	done

	service httpd restart;
}




#
#
#
#
installMySQL(){
	echo ""
	echo "${blue}--- Installing Mysql, doing secure installation, and creating user --------------------------------------------${resetColor}"
	echo "";
	
	sudo yum -y install mariadb-server mariadb;
	sudo systemctl start mariadb;
	sudo systemctl enable mariadb.service;
	
	
	#TODO GIVE INFO WHAT IS HAPPENING
	clear;
	echo ""
	echo "${blue}--- The system is now going to run through securing MYSQL --------------------------------------------${resetColor}"
	echo ""
	sudo mysql_secure_installation;
	
}

#
#
#
#
installMysqlUser() {
	echo ""
	echo "${blue}--- accessing MYSQL to create a user --------------------------------------------${resetColor}"
	echo "";
	echo "${yellow}--- Type in your ROOT password for ${red}MYSQL${yellow} so user [$userToUse] can be created --------------------------------------------${resetColor}"
	echo "";
	
	mysql -u root -p <<EOF
CREATE USER '$userToUse'@'%' IDENTIFIED BY '$mysqlUserPass';
GRANT ALL PRIVILEGES ON *.* TO '$userToUse'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

#TODO create phpuser that only has select privledges and only from localhost

}



#
#
#
#
creationSSHUser() {
	echo ""
	echo "${blue}--- Installing SSH user [$userToUse] --------------------------------------------${resetColor}"
	echo "";

	sudo useradd -m -d /home/$userToUse -s /bin/bash $userToUse;
	
	mkdir /home/$userToUse/.ssh;
	touch /home/$userToUse/.ssh/authorized_keys;
	echo $sshUserPublicKey > /home/$userToUse/.ssh/authorized_keys
	
	chown -R $userToUse:$userToUse /home/$userToUse/.ssh;
	chmod 700 /home/$userToUse/.ssh;
	chmod 600 /home/$userToUse/.ssh/authorized_keys;
}


#
#
#
#
createInstallC9() {
	
	sudo yum update -y;
	sudo yum -y install epel-release npm;
	sudo yum -y groupinstall 'Development Tools';
	sudo yum -y install make nodejs git gcc glibc-static ncurses-devel;
	
	
	cd /home/$userToUse;
	
	npm install forever -g;
	npm i forever -g;
	
	chmod 777 /var/www -R;
	
	su -c 'git clone https://github.com/c9/core.git c9sdk;cd c9sdk; pwd;scripts/install-sdk.sh;' $userToUse
	su -c "forever start /home/$userToUse/c9sdk/server.js -w /var/www -l 0.0.0.0 -p $c9portToUse -a $userToUse:$c9userPass;" $userToUse

	# node start /home/tdub/c9sdk/server.js -w /var/www -l 0.0.0.0 -p 9191 -a tdub:tdubtdub;
	#-> forever stop /home/tdub/c9sdk/server.js;
	
}






#
#
#
drawIntroScreen(){
	clear
	echo "";
	echo "";
	echo "${green}";
	echo "------------------------------------------------"
	echo "------------------------------------------------"
	echo "-- ${magenta}DEV OPS WEB SERVER INSTALLER HELPER${green} --"
	echo "------------------------------------------------"
	echo "------------------------------------------------${resetColor}"
	echo ""
	echo ""
}






#
#
#
drawOptionsMenu(){
	drawIntroScreen
	
	echo "${green}";
	
	echo "------------------------------------------------"
	echo "-- ${blue}Available Options${green} --"
	echo "------------------------------------------------"
	echo ""
	echo "${blue} 1 ${green} |${resetColor} Full Install"
	echo ""
	echo "${blue} 2 ${green} |${resetColor} Upgrade Usability & Security (git,wget,nano,iptables,yum-utils)"
	echo "${blue} 3 ${green} |${resetColor} Install php72+Apache"
	echo "${blue} 4 ${green} |${resetColor} Create new hosted zones (vhost)"
	echo "${blue} 5 ${green} |${resetColor} Install Mysql + Security"
	echo "${blue} 6 ${green} |${resetColor} Create MySQL User"
	echo "${blue} 7 ${green} |${resetColor} Create new SSH User"
	echo "${blue} 8 ${green} |${resetColor} Install C9 IDE"
	echo "${blue} 9 ${green} |${resetColor} Update Root SSH password"
	echo "";
	echo "${blue} q ${green} |${red} Quit${resetColor}"
	
	
	
	
	while true; do
		read -p "${yellow}--- Select an option to continue [1-9] --------------------------------------------${resetColor}" yn
		case $yn in
			[1]* )  
				exe_twoFresh=true;
				exe_threePHP=true;
				exe_fourVHOST=true;
				exe_fiveMYSQL=true;
				exe_sixMYSQLUSER=true;
				exe_sevenSSHUSER=true;
				exe_eightC9=true;
				exe_nineUpdateRootSSHUser=true;
				exe_actionDone="1) Full Install";
				break;;
			[2]* ) 
				exe_twoFresh=true;
				exe_actionDone="2) Upgraded Usability & Security";
				break;;
			[3]* ) 
				exe_threePHP=true;
				exe_actionDone="3) Installed PHP72+Apache";
				break;;
			[4]* ) 
				exe_fourVHOST=true;
				exe_actionDone="4) Created new hosted zone";
				break;;
			[5]* ) 
				exe_fiveMYSQL=true;
				exe_actionDone="5) Installed SQL + security";
				break;;
			[6]* ) 
				exe_sixMYSQLUSER=true;
				exe_actionDone="6) Created MySQL user";
				break;;
			[7]* ) 
				exe_sevenSSHUSER=true;
				exe_actionDone="7) Created new SSH user";
				break;;
			[8]* ) 
				exe_eightC9=true;
				exe_actionDone="8) Installed C9 IDE";
				break;;
			[9]* ) 
				exe_nineUpdateRootSSHUser=true;
				exe_actionDone="9) Updated root ssh password";
				break;;
			[qQquit]* ) exit;;
			
			
			* ) echo "Please answer a number [1-9].";;
		esac
	done
	
}






#
#
#
#
drawSummary() {
	drawIntroScreen

	echo "";
	echo "";
	echo "${green}";
	echo "------------------------------------------------"
	echo "------------------------------------------------"
	echo "-----------       ${red}SUMMARY${green}      -----------"
	echo "------------------------------------------------"
	secs_to_human "$(($(date +%s) - ${STARTTIME}))"
	echo "------------------------------------------------${resetColor}"
	echo ""
	echo "${blue}";
	echo "------------------------------------------------"
	echo "";
	echo "${red}Action Done               ${blue}|${resetColor} ${exe_actionDone}";
	echo "";
	
	
	if [[ "$exe_fourVHOST" = true ]]; then
		echo "${red}vHosts created            ${blue}|${resetColor} ${vhosts_added}";
	fi
	
	
	if [[ "$exe_sixMYSQLUSER" = true ]]; then
		echo "${red}MySQL access              ${blue}|${resetColor} ${userToUse}${yellow}:${resetColor}${mysqlUserPass}";
	fi 
	
	
	if [[ "$exe_sevenSSHUSER" = true ]]; then
		echo "${red}SSH User Created          ${blue}|${resetColor} ${userToUse}${resetColor}";
	fi
	
	
	if [[ "$exe_eightC9" = true ]]; then
		echo "${red}C9 IDE Access             ${blue}|${resetColor} ${userToUse}${yellow}:${resetColor}${c9userPass}";
	fi
	
	if [[ "$exe_nineUpdateRootSSHUser" = true ]]; then
		echo "${red}root password updated     ${blue}|${resetColor} root${yellow}:${resetColor}${rootUserPassword}";
	fi
	
	if [[ "$exe_fiveMYSQL" = true ]]; then
		echo "${red}MYSQL Root Password     ${blue}|${resetColor} It is possible the mysql root password was updated during mysql_secure_installation";
	fi

	
	echo "${blue}";
	echo "------------------------------------------------${resetColor}"
	echo "";
}






secs_to_human() {
    if [[ -z ${1} || ${1} -lt 60 ]] ;then
        min=0 ; secs="${1}"
    else
        time_mins=$(echo "scale=2; ${1}/60" | bc)
        min=$(echo ${time_mins} | cut -d'.' -f1)
        secs="0.$(echo ${time_mins} | cut -d'.' -f2)"
        secs=$(echo ${secs}*60|bc|awk '{print int($1+0.5)}')
    fi
    
	echo "-------------- Took ${min}m & ${secs}s -------------"
}
















drawIntroScreen;



echo "${red} NOTE - This helper was created to be used on Centos 7 on a raspberry pi and has not been confirmed working on any other distros. ${resetColor}"
echo "";

while true; do
	read -p "${yellow}--- Would you like to continue? [y/n] --------------------------------------------${resetColor}" yn
	case $yn in
		[Yy]* )  
			break;;
		[Nn]* ) exit;;
		* ) echo "Please answer [y/n].";;
	esac
done






drawOptionsMenu;






if [[ "$exe_nineUpdateRootSSHUser" = true ]]; then
	echo "";
	echo "";
	echo "${yellow}--- [PASSWORD UPDATE] Enter in your new root password --------------------------------------------${resetColor}"
	echo "";
	read rootUserPassword
	
	echo "$rootUserPassword" | passwd --stdin root
fi

if [[ "$exe_sixMYSQLUSER" = true || "$exe_sevenSSHUSER" = true  || "$exe_eightC9" = true ]]; then
	echo "";
	echo "";
	echo "${yellow}--- Enter in the name of the user to create for SSH/C9/MySQL --------------------------------------------${resetColor}"
	echo "";
	read userToUse
fi


if [[ "$exe_sevenSSHUSER" = true ]]; then
	echo "";
	echo "";
	echo "${yellow}--- Enter in the ${red}ssh public key${yellow} for user [$userToUse] about to be created (id_rsa.pub)  --------------------------------------------${resetColor}"
	read sshUserPublicKey
fi



if [ "$exe_sixMYSQLUSER" = true ]; then
	echo "";
	echo "";
	echo "${yellow}--- Enter in the password for ${red}MySQL${yellow} user [$userToUse] about to be created --------------------------------------------${resetColor}"
	read mysqlUserPass
fi



if [ "$exe_eightC9" = true ]; then
	echo "";
	echo "";
	echo "${yellow}--- Enter in the password for ${red}C9${yellow} user [$userToUse] about to be created in order to access IDE --------------------------------------------${resetColor}"
	read c9userPass
	
fi






echo "";
echo "";


mysqlPhpPass="phppass"
#ask for mysql phpuser password



#TODO ask for root password to be updated
#todo remove root ssh from outside world
#echo "$mysqlUserPass" | passwd --stdin root




if [ "$exe_twoFresh" = true ]; then
	freshCentosInstall
fi

if [ "$exe_threePHP" = true ]; then
	installReposApachePhp
fi


if [ "$exe_sevenSSHUSER" = true ]; then
	#new ssh user
	creationSSHUser
fi

if [ "$exe_eightC9" = true ]; then
	#install c9 ide
	createInstallC9
fi


if [ "$exe_fiveMYSQL" = true ]; then
	#install mysql + security
	installMySQL
fi

if [ "$exe_sixMYSQLUSER" = true ]; then
	#install mysql user
	installMysqlUser
fi

if [ "$exe_fourVHOST" = true ]; then
	createAllVhostDomains
fi



drawSummary
