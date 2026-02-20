For those of you who don't know who I am, I am carpenox from the ViciDial forums and as most people can confirm, I help out of the goodness of my heart to our community. I want us all to succeed together! With that being said, If my knowledge base or my github has helped you or your business, please feel free to donate to help me keep the help going.

# AI AMD - We also offer AI Driven Answering Machine Detection(AMD) available, email info@cyburdial.com for more info.

# www.dialer.one for our full knowledge base

# Need help? Join the Discord: https://discord.gg/ymGZJvF6hK
# Have I helped you? Please feel free to donate here: https://www.paypal.me/TheDialerOne


# VICIDIAL INSTALLATION SCRIPTS (Default is Eastern Time Zone US)
# Centos, Rocky and AlmaLinux Vicidial Install pre_requisites 
# I have created a faster auto installer for Alma and Rocky 9 that will also install the dynamic portal and the CyburPhone

## Copy & Paste the part below:

```
# Install english language pack
dnf install -y glibc-langpack-en

# Configure new locale. This basically just edits /etc/locale.conf
localectl set-locale en_US.UTF-8

timedatectl set-timezone America/New_York

yum check-update
yum update -y
yum -y install epel-release
yum update -y
yum install git -y
yum install kernel* --exclude=kernel-debug* -y


#Disable SELINUX
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config    

cd /usr/src/
git clone https://github.com/carpenox/vicidial-install-scripts.git

reboot

````
  

This first installer is the one I keep most up to date and use personally for all my clients. it is the one I recommend that you use.
If you do not install the SSL cert during the initiial install, you have to turn the firewall off before trying to do it after a reboot. Dont forget to turn it back on. Also, by default the firewall will leave port 443 open to the public, so you can login and change the default password. Make sure you remove it from the public zone once your setup is done. Check this article for use of firewalld: https://dialer.one/index.php/how-to-use-firewalld-via-command-line/

# AI AMD - We also offer AI Driven Answering Machine Detection(AMD) available, email info@cyburdial.com for more info.

# Follow this article for post install: https://dialer.one/index.php/how-to-use-the-full-functionality-of-the-vicidial-installer-by-carpenox/

## Alma10 installer is not working correctly and will be fixed over the next couple weeks.

# main installer to use for Alma/Rocky 9 w/ Dynamic portal, WebPhone, SSL cert & Asterisk 18 with Confbridges

```
cd /usr/src/vicidial-install-scripts
chmod +x main-installer.sh
./main-installer.sh
```

# Above installer but with PHP8 instead of PHP7 (Beta Release)

```
cd /usr/src/vicidial-install-scripts
chmod +x main-installer-php8.sh
./main-installer-php8.sh
```

# NEW Installer for add on dialers on Alma or Rocky 9

```
cd /usr/src/vicidial-install-scripts
chmod +x addon-dialer-alma9.sh
./addon-dialer-alma9.sh
```

### Alma/Rocky 9 Installer with Dynamic portal and CyburPhone with SSL cert with Asterisk 18

```
cd /usr/src/vicidial-install-scripts
chmod +x alma-rocky9-ast18.sh
./alma-rocky9-ast18.sh
```

Make sure you update your SSL cert location in /etc/httpd/conf.d/viciportal-ssl.conf


### Alma/Rocky 9 Installer with Dynamic portal, CyburPhone, SSL Cert and Asterisk 16

```
cd /usr/src/vicidial-install-scripts
chmod +x alma-rocky9-ast16.sh
./alma-rocky9-ast16.sh
```

## Install a default database with everything setup ready to go - Password CyburDial2024 (need to add "a" to phone login on users accounts, oops)

```
cd /usr/src/vicidial-install-scripts
chmod +x standard-db.sh
./standard-db.sh
```

# See tools section at the bottom for cluster db with 7 servers, 150 users and phones ready to go

### Alma/Rocky 9 Installer with Dynamic portal and CyburPhone with SSL cert with Asterisk 18 for CONTABO ONLY

```
cd /usr/src/vicidial-install-scripts
chmod +x alma-rocky-centos-9-ast18-contabo.sh
./alma-rocky-centos-9-ast18-contabo.sh
```

### Alma 8 Add on telephony server for a cluster

```
cd /usr/src/vicidial-install-scripts
chmod +x Vici-alma-dialer-install.sh
./Vici-alma-dialer-install.sh
```

### Execute Centos7 Vicidial Install
```
cd /usr/src/vicidial-install-scripts
chmod +x vicidial-install-c7.sh
./vicidial-install-c7.sh
```

### Execute Alma/Rocky 8 Linux Vicidial Install - Ast 16
```
cd /usr/src/vicidial-install-scripts
chmod +x alma-rocky-centos8-ast16.sh
./alma-rocky-centos8-ast16.sh
```

### Execute Alma/Rocky 8 Linux Vicidial Install - Ast 18

```
cd /usr/src/vicidial-install-scripts
chmod +x alma-rocky-centos-8-ast18.sh
./alma-rocky-centos-8-ast18.sh
```

## USEFUL TOOLS ##

## Cluster Database with 7 servers ready with 150 users and phones

```
cd /usr/src/vicidial-install-scripts
chmod +x cluster-db.sh
./cluster-db.sh
```

# These 2 steps below can be used to cluster servers after they have been installed with one of the above installers. Example: main-installer.sh

## Step 1: Add dialers into database POST install - This is to be used to add dialer servers into a cluster with conferences and confbridges

```
cd /usr/src/vicidial-install-scripts
chmod +x add-dialer-to-DB.sh
./add-dialer-to-DB.sh
```

## Step 2: Link Dialers to the database - run this on each dialer

```
cd /usr/src/vicidial-install-scripts
chmod +x run-on-dialer-servers-cluster.sh
./run-on-dialer-servers-cluster.sh
```

## Repeat steps 1 and 2 in order as you do each server

## Install Webphone and SSL cert for VICIDIAL
## DO THIS IF YOU HAVE PUBLIC DOMAIN WITH PUBLIC IP ONLY

```
cd /usr/src/vicidial-install-scripts
chmod +x vicidial-enable-webrtc.sh
./vicidial-enable-webrtc.sh
```
