#!/bin/sh

echo "Vicidial installation AlmaLinux/RockyLinux with CyburPhone and Dynamic portal"

# Function to prompt user for input
prompt() {
    local varname=$1
    local prompt_text=$2
    local default_value=$3
    read -p "$prompt_text [$default_value]: " input
    export $varname="${input:-$default_value}"
}

echo "Getting Machine info - No hostname? Enter the IP Address"
echo "**************************************************************************"
prompt hostname "Enter the hostname:" "$hostname"
echo "Press Enter to continue"
read
hostnamectl set-hostname $hostname
# Retrieve the Hostname
hostname=$(hostname | awk '{print $1}')
echo "Hostname\t: $hostname"
# Retrieve the IP address
ip_address=$(hostname -I | awk '{print $1}')
echo "IP Address\t: $ip_address"
echo "**************************************************************************"
echo "Enter to continue..."
read	

export LC_ALL=C


dnf groupinstall "Development Tools" -y
dnf install perl perl-core perl-devel perl-ExtUtils-MakeMaker perl-ExtUtils-Manifest perl-CPAN -y

yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
yum -y install yum-utils
dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm -y
dnf install https://rpms.remirepo.net/enterprise/remi-release-10.rpm -y
dnf module enable php:remi-7.4 -y
dnf module enable mariadb:10.5 -y

dnf -y install dnf-plugins-core


yum install -y php screen php-mcrypt subversion php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo php-opcache -y 
sleep 2
yum in -y wget unzip make patch gcc gcc-c++ subversion php php-devel php-gd gd-devel readline-devel php-mbstring php-mcrypt 
sleep 2
yum in -y php-imap php-ldap php-mysqli php-odbc php-pear php-xml php-xmlrpc curl curl-devel perl-libwww-perl ImageMagick 
sleep 3
yum in -y newt-devel libxml2-devel kernel-devel sqlite-devel libuuid-devel sox sendmail lame-devel htop iftop perl-File-Which
sleep 2
yum in -y php-opcache libss7 mariadb-devel libss7* libopen*
sleep 1
yum in -y initscripts pv python3-pip firewalld
sudo dnf install firewalld -y
sudo systemctl enable --now firewalld
pip install mysql-connector-python
yum copr enable irontec/sngrep -y
dnf install sngrep bind-utils -y
yum install php-mysqli -y
dnf install glibc-headers glibc-devel -y


sudo yum install -y kernel-devel-$(uname -r) kernel-headers-$(uname -r)

dnf --enablerepo=crb install libsrtp-devel -y
dnf config-manager --set-enabled crb
yum install libsrtp-devel -y

### Install cockpit
yum -y install cockpit cockpit-storaged cockpit-navigator
sed -i s/root/"#root"/g /etc/cockpit/disallowed-users
systemctl enable cockpit.socket

sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

tee -a /etc/php.ini <<EOF

error_reporting  =  E_ALL & ~E_NOTICE
memory_limit = 448M
short_open_tag = On
max_execution_time = 3330
max_input_time = 3360
post_max_size = 448M
upload_max_filesize = 442M
default_socket_timeout = 3360
date.timezone = America/New_York
max_input_vars = 50000
EOF


systemctl restart httpd

yum in -y sqlite-devel httpd mod_ssl nano chkconfig htop atop mytop iftop
yum in -y libedit-devel uuid* libxml2* speex-devel speex* postfix dovecot s-nail roundcubemail inxi
dnf install -y mariadb-server mariadb

dnf -y install dnf-plugins-core
dnf config-manager --set-enabled powertools


systemctl enable mariadb

cp /etc/my.cnf /etc/my.cnf.original
echo "" > /etc/my.cnf


cat <<MYSQLCONF>> /etc/my.cnf
[mysql.server]
user = mysql
#basedir = /var/lib

[client]
port = 3306
socket = /var/lib/mysql/mysql.sock

[mysqld]
datadir = /var/lib/mysql
#tmpdir = /home/mysql_tmp
socket = /var/lib/mysql/mysql.sock
user = mysql
old_passwords = 0
ft_min_word_len = 3
max_connections = 800
max_allowed_packet = 32M
skip-external-locking
sql_mode="NO_ENGINE_SUBSTITUTION"

log-error = /var/log/mysqld/mysqld.log

query-cache-type = 1
query-cache-size = 32M

long_query_time = 1
#slow_query_log = 1
#slow_query_log_file = /var/log/mysqld/slow-queries.log

tmp_table_size = 128M
table_cache = 1024

join_buffer_size = 1M
key_buffer = 512M
sort_buffer_size = 6M
read_buffer_size = 4M
read_rnd_buffer_size = 16M
myisam_sort_buffer_size = 64M

max_tmp_tables = 64

thread_cache_size = 8
thread_concurrency = 8

# If using replication, uncomment log-bin below
#log-bin = mysql-bin

[mysqldump]
quick
max_allowed_packet = 16M

[mysql]
no-auto-rehash

[isamchk]
key_buffer = 256M
sort_buffer_size = 256M
read_buffer = 2M
write_buffer = 2M

[myisamchk]
key_buffer = 256M
sort_buffer_size = 256M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout

[mysqld_safe]
#log-error = /var/log/mysqld/mysqld.log
#pid-file = /var/run/mysqld/mysqld.pid
MYSQLCONF

mkdir /var/log/mysqld
touch /var/log/mysqld/slow-queries.log
chown -R mysql:mysql /var/log/mysqld
systemctl restart mariadb

systemctl enable httpd.service
systemctl enable mariadb.service
systemctl restart httpd.service
systemctl restart mariadb.service

#Install Perl Modules

echo "Install Perl"

yum install -y perl-CPAN perl-YAML perl-CPAN-DistnameInfo perl-libwww-perl perl-DBI perl-DBD-MySQL perl-GD perl-Env perl-Term-ReadLine-Gnu perl-SelfLoader perl-open.noarch 

#CPM install
cd /usr/src/vicidial-install-scripts
curl -fsSL https://raw.githubusercontent.com/skaji/cpm/main/cpm | perl - install -g App::cpm
/usr/local/bin/cpm install -g

#Install Asterisk Perl
cd /usr/src
wget http://download.vicidial.com/required-apps/asterisk-perl-0.08.tar.gz
tar xzf asterisk-perl-0.08.tar.gz
cd asterisk-perl-0.08
perl Makefile.PL
make all
make install 

yum install libsrtp-devel -y
yum install -y elfutils-libelf-devel libedit-devel


#Install Lame
cd /usr/src
wget http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz
tar -zxf lame-3.99.5.tar.gz
cd lame-3.99.5
./configure
make
make install


#Install Jansson
cd /usr/src/
wget https://digip.org/jansson/releases/jansson-2.13.tar.gz
tar xvzf jansson*
cd jansson-2.13
./configure
make clean
make
make install 
ldconfig

#Install Dahdi
echo "Install Dahdi"
ln -sf /usr/lib/modules/$(uname -r)/vmlinux.xz /boot/
cd /etc/include
wget https://dialer.one/newt.h

cd /usr/src/
mkdir dahdi-linux-complete-3.4.0+3.4.0
cd dahdi-linux-complete-3.4.0+3.4.0
wget https://cybur-dial.com/downloads/dahdi-alma10.zip
unzip dahdi-alma10.zip
yum in newt* -y

##ExecStart=/usr/sbin/dahdi_cfg -vv

make clean
make
make install
make install-config

yum -y install dahdi-tools-libs

cd tools
make clean
make
make install
make install-config

cp /usr/src/dahdi-linux-complete-3.4.0+3.4.0/tools/.libs/libtonezone.so.2.0.0 /usr/lib64/
ln -sf /usr/lib64/libtonezone.so.2.0.0 /usr/lib64/libtonezone.so.2
ln -sf /usr/lib64/libtonezone.so.2 /usr/lib64/libtonezone.so

echo "/usr/lib64" > /etc/ld.so.conf.d/dahdi.conf
ldconfig

cp /etc/dahdi/system.conf.sample /etc/dahdi/system.conf
modprobe dahdi
modprobe dahdi_dummy
/usr/sbin/dahdi_cfg -vvvvvvvvvvvvv

systemctl enable dahdi
service dahdi start
service dahdi status

read -p 'Press Enter to continue: '

echo 'Continuing...'

#Install Asterisk and LibPRI
mkdir /usr/src/asterisk
cd /usr/src/asterisk
wget https://downloads.asterisk.org/pub/telephony/libpri/libpri-1.6.1.tar.gz
wget https://download.vicidial.com/required-apps/asterisk-18.21.0-vici.tar.gz
tar -xvzf asterisk-18.21.0-vici.tar.gz
tar -xvzf libpri-*

cd /usr/src
wget https://github.com/cisco/libsrtp/archive/v2.1.0.tar.gz
tar xfv v2.1.0.tar.gz
cd libsrtp-2.1.0
./configure --prefix=/usr --enable-openssl
make shared_library && sudo make install
ldconfig

# cd /usr/src/asterisk/asterisk-18.18.1/
cd /usr/src/asterisk/asterisk-18.21.0-vici/

yum in libuuid-devel libxml2-devel -y

: ${JOBS:=$(( $(nproc) + $(nproc) / 2 ))}
./configure --libdir=/usr/lib64 --with-gsm=internal --enable-opus --enable-srtp --with-ssl --enable-asteriskssl --with-pjproject-bundled --with-jansson-bundled

make menuselect/menuselect menuselect-tree menuselect.makeopts
#enable app_meetme
menuselect/menuselect --enable app_meetme menuselect.makeopts
#enable res_http_websocket
menuselect/menuselect --enable res_http_websocket menuselect.makeopts
#enable res_srtp
menuselect/menuselect --enable res_srtp menuselect.makeopts
make samples
sed -i 's|noload = chan_sip.so|;noload = chan_sip.so|g' /etc/asterisk/modules.conf
make -j ${JOBS} all
make install


read -p 'Press Enter to continue: '

echo 'Continuing...'

#Install astguiclient
echo "Installing astguiclient"
mkdir /usr/src/astguiclient
cd /usr/src/astguiclient
svn checkout svn://svn.eflo.net/agc_2-X/trunk
cd /usr/src/astguiclient/trunk

#Add mysql users and Databases
echo "%%%%%%%%%%%%%%%Please Enter Mysql Password Or Just Press Enter if you Dont have Password%%%%%%%%%%%%%%%%%%%%%%%%%%"
mysql -u root -p << MYSQLCREOF
CREATE DATABASE asterisk DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
CREATE USER 'cron'@'localhost' IDENTIFIED BY '1234';
GRANT SELECT,CREATE,ALTER,INSERT,UPDATE,DELETE,LOCK TABLES on asterisk.* TO cron@'%' IDENTIFIED BY '1234';
GRANT SELECT,CREATE,ALTER,INSERT,UPDATE,DELETE,LOCK TABLES on asterisk.* TO cron@localhost IDENTIFIED BY '1234';
GRANT RELOAD ON *.* TO cron@'%';
GRANT RELOAD ON *.* TO cron@localhost;
CREATE USER 'custom'@'localhost' IDENTIFIED BY 'custom1234';
GRANT SELECT,CREATE,ALTER,INSERT,UPDATE,DELETE,LOCK TABLES on asterisk.* TO custom@'%' IDENTIFIED BY 'custom1234';
GRANT SELECT,CREATE,ALTER,INSERT,UPDATE,DELETE,LOCK TABLES on asterisk.* TO custom@localhost IDENTIFIED BY 'custom1234';
GRANT RELOAD ON *.* TO custom@'%';
GRANT RELOAD ON *.* TO custom@localhost;
flush privileges;

SET GLOBAL connect_timeout=60;

use asterisk;
\. /usr/src/astguiclient/trunk/extras/MySQL_AST_CREATE_tables.sql
\. /usr/src/astguiclient/trunk/extras/first_server_install.sql
update servers set asterisk_version='18.21.1-vici';
quit
MYSQLCREOF

read -p 'Press Enter to continue: '

echo 'Continuing...'

#Get astguiclient.conf file
cat <<ASTGUI>> /etc/astguiclient.conf
# astguiclient.conf - configuration elements for the astguiclient package
# this is the astguiclient configuration file
# all comments will be lost if you run install.pl again

# Paths used by astGUIclient
PATHhome => /usr/share/astguiclient
PATHlogs => /var/log/astguiclient
PATHagi => /var/lib/asterisk/agi-bin
PATHweb => /var/www/html
PATHsounds => /var/lib/asterisk/sounds
PATHmonitor => /var/spool/asterisk/monitor
PATHDONEmonitor => /var/spool/asterisk/monitorDONE

# The IP address of this machine
VARserver_ip => SERVERIP

# Database connection information
VARDB_server => localhost
VARDB_database => asterisk
VARDB_user => cron
VARDB_pass => 1234
VARDB_custom_user => custom
VARDB_custom_pass => custom1234
VARDB_port => 3306

# Alpha-Numeric list of the astGUIclient processes to be kept running
# (value should be listing of characters with no spaces: 123456)
#  X - NO KEEPALIVE PROCESSES (use only if you want none to be keepalive)
#  1 - AST_update
#  2 - AST_send_listen
#  3 - AST_VDauto_dial
#  4 - AST_VDremote_agents
#  5 - AST_VDadapt (If multi-server system, this must only be on one server)
#  6 - FastAGI_log
#  7 - AST_VDauto_dial_FILL (only for multi-server, this must only be on one server)
#  8 - ip_relay (used for blind agent monitoring)
#  9 - Timeclock auto logout
#  E - Email processor, (If multi-server system, this must only be on one server)
#  S - SIP Logger (Patched Asterisk 13 required)
VARactive_keepalives => 12345689EC

# Asterisk version VICIDIAL is installed for
VARasterisk_version => 18.X

# FTP recording archive connection information
VARFTP_host => 10.0.0.4
VARFTP_user => cron
VARFTP_pass => test
VARFTP_port => 21
VARFTP_dir => RECORDINGS
VARHTTP_path => http://10.0.0.4

# REPORT server connection information
VARREPORT_host => 10.0.0.4
VARREPORT_user => cron
VARREPORT_pass => test
VARREPORT_port => 21
VARREPORT_dir => REPORTS

# Settings for FastAGI logging server
VARfastagi_log_min_servers => 3
VARfastagi_log_max_servers => 16
VARfastagi_log_min_spare_servers => 2
VARfastagi_log_max_spare_servers => 8
VARfastagi_log_max_requests => 1000
VARfastagi_log_checkfordead => 30
VARfastagi_log_checkforwait => 60

# Expected DB Schema version for this install
ExpectedDBSchema => 1720
ASTGUI

echo "Replace IP address in Default"
#echo "%%%%%%%%%Please Enter This Server IP ADD%%%%%%%%%%%%"
#read serveripadd
sed -i s/SERVERIP/"$ip_address"/g /etc/astguiclient.conf

echo "Install VICIDIAL"
perl install.pl --no-prompt --copy_sample_conf_files=Y

#Secure Manager 
sed -i s/0.0.0.0/127.0.0.1/g /etc/asterisk/manager.conf

sed -i '$ a\ noload => res_timing_timerfd.so\ noload => res_timing_kqueue.so\ noload => res_timing_pthread.so' /etc/asterisk/modules.conf

#Add confbridge conferences to asterisk DB
mysql -u root -e "use asterisk; INSERT INTO vicidial_confbridges VALUES (9600000,'10.10.10.15','','0',NULL),(9600001,'10.10.10.15','','0',NULL),(9600002,'10.10.10.15','','0',NULL),(9600003,'10.10.10.15','','0',NULL),(9600004,'10.10.10.15','','0',NULL),(9600005,'10.10.10.15','','0',NULL),(9600006,'10.10.10.15','','0',NULL),(9600007,'10.10.10.15','','0',NULL),(9600008,'10.10.10.15','','0',NULL),(9600009,'10.10.10.15','','0',NULL),(9600010,'10.10.10.15','','0',NULL),(9600011,'10.10.10.15','','0',NULL),(9600012,'10.10.10.15','','0',NULL),(9600013,'10.10.10.15','','0',NULL),(9600014,'10.10.10.15','','0',NULL),(9600015,'10.10.10.15','','0',NULL),(9600016,'10.10.10.15','','0',NULL),(9600017,'10.10.10.15','','0',NULL),(9600018,'10.10.10.15','','0',NULL),(9600019,'10.10.10.15','','0',NULL),(9600020,'10.10.10.15','','0',NULL),(9600021,'10.10.10.15','','0',NULL),(9600022,'10.10.10.15','','0',NULL),(9600023,'10.10.10.15','','0',NULL),(9600024,'10.10.10.15','','0',NULL),(9600025,'10.10.10.15','','0',NULL),(9600026,'10.10.10.15','','0',NULL),(9600027,'10.10.10.15','','0',NULL),(9600028,'10.10.10.15','','0',NULL),(9600029,'10.10.10.15','','0',NULL),(9600030,'10.10.10.15','','0',NULL),(9600031,'10.10.10.15','','0',NULL),(9600032,'10.10.10.15','','0',NULL),(9600033,'10.10.10.15','','0',NULL),(9600034,'10.10.10.15','','0',NULL),(9600035,'10.10.10.15','','0',NULL),(9600036,'10.10.10.15','','0',NULL),(9600037,'10.10.10.15','','0',NULL),(9600038,'10.10.10.15','','0',NULL),(9600039,'10.10.10.15','','0',NULL),(9600040,'10.10.10.15','','0',NULL),(9600041,'10.10.10.15','','0',NULL),(9600042,'10.10.10.15','','0',NULL),(9600043,'10.10.10.15','','0',NULL),(9600044,'10.10.10.15','','0',NULL),(9600045,'10.10.10.15','','0',NULL),(9600046,'10.10.10.15','','0',NULL),(9600047,'10.10.10.15','','0',NULL),(9600048,'10.10.10.15','','0',NULL),(9600049,'10.10.10.15','','0',NULL),(9600050,'10.10.10.15','','0',NULL),(9600051,'10.10.10.15','','0',NULL),(9600052,'10.10.10.15','','0',NULL),(9600054,'10.10.10.15','','0',NULL),(9600055,'10.10.10.15','','0',NULL),(9600056,'10.10.10.15','','0',NULL),(9600057,'10.10.10.15','','0',NULL),(9600058,'10.10.10.15','','0',NULL),(9600059,'10.10.10.15','','0',NULL),(9600060,'10.10.10.15','','0',NULL),(9600061,'10.10.10.15','','0',NULL),
(9600062,'10.10.10.15','','0',NULL),(9600063,'10.10.10.15','','0',NULL),(9600064,'10.10.10.15','','0',NULL),(9600065,'10.10.10.15','','0',NULL),(9600066,'10.10.10.15','','0',NULL),(9600067,'10.10.10.15','','0',NULL),(9600068,'10.10.10.15','','0',NULL),(9600069,'10.10.10.15','','0',NULL),(9600070,'10.10.10.15','','0',NULL),(9600071,'10.10.10.15','','0',NULL),(9600072,'10.10.10.15','','0',NULL),(9600073,'10.10.10.15','','0',NULL),(9600074,'10.10.10.15','','0',NULL),(9600075,'10.10.10.15','','0',NULL),(9600076,'10.10.10.15','','0',NULL),(9600077,'10.10.10.15','','0',NULL),(9600078,'10.10.10.15','','0',NULL),(9600079,'10.10.10.15','','0',NULL),(9600080,'10.10.10.15','','0',NULL),(9600081,'10.10.10.15','','0',NULL),(9600082,'10.10.10.15','','0',NULL),(9600083,'10.10.10.15','','0',NULL),(9600084,'10.10.10.15','','0',NULL),(9600085,'10.10.10.15','','0',NULL),(9600086,'10.10.10.15','','0',NULL),(9600087,'10.10.10.15','','0',NULL),(9600088,'10.10.10.15','','0',NULL),(9600089,'10.10.10.15','','0',NULL),(9600090,'10.10.10.15','','0',NULL),(9600091,'10.10.10.15','','0',NULL),(9600092,'10.10.10.15','','0',NULL),(9600093,'10.10.10.15','','0',NULL),(9600094,'10.10.10.15','','0',NULL),(9600095,'10.10.10.15','','0',NULL),(9600096,'10.10.10.15','','0',NULL),(9600097,'10.10.10.15','','0',NULL),(9600098,'10.10.10.15','','0',NULL),(9600099,'10.10.10.15','','0',NULL),(9600100,'10.10.10.15','','0',NULL),(9600101,'10.10.10.15','','0',NULL),(9600102,'10.10.10.15','','0',NULL),(9600103,'10.10.10.15','','0',NULL),(9600104,'10.10.10.15','','0',NULL),(9600105,'10.10.10.15','','0',NULL),(9600106,'10.10.10.15','','0',NULL),(9600107,'10.10.10.15','','0',NULL),(9600108,'10.10.10.15','','0',NULL),(9600109,'10.10.10.15','','0',NULL),(9600110,'10.10.10.15','','0',NULL),(9600111,'10.10.10.15','','0',NULL),(9600112,'10.10.10.15','','0',NULL),(9600113,'10.10.10.15','','0',NULL),(9600114,'10.10.10.15','','0',NULL),(9600115,'10.10.10.15','','0',NULL),(9600116,'10.10.10.15','','0',NULL),(9600117,'10.10.10.15','','0',NULL),(9600118,'10.10.10.15','','0',NULL),(9600119,'10.10.10.15','','0',NULL),(9600120,'10.10.10.15','','0',NULL),(9600121,'10.10.10.15','','0',NULL),(9600122,'10.10.10.15','','0',NULL),(9600123,'10.10.10.15','','0',NULL),(9600124,'10.10.10.15','','0',NULL),(9600125,'10.10.10.15','','0',NULL),(9600126,'10.10.10.15','','0',NULL),(9600127,'10.10.10.15','','0',NULL),(9600128,'10.10.10.15','','0',NULL),(9600129,'10.10.10.15','','0',NULL),(9600130,'10.10.10.15','','0',NULL),(9600131,'10.10.10.15','','0',NULL),(9600132,'10.10.10.15','','0',NULL),(9600133,'10.10.10.15','','0',NULL),(9600134,'10.10.10.15','','0',NULL),(9600135,'10.10.10.15','','0',NULL),(9600136,'10.10.10.15','','0',NULL),(9600137,'10.10.10.15','','0',NULL),(9600138,'10.10.10.15','','0',NULL),(9600139,'10.10.10.15','','0',NULL),(9600140,'10.10.10.15','','0',NULL),(9600141,'10.10.10.15','','0',NULL),(9600142,'10.10.10.15','','0',NULL),(9600143,'10.10.10.15','','0',NULL),(9600144,'10.10.10.15','','0',NULL),(9600145,'10.10.10.15','','0',NULL),(9600146,'10.10.10.15','','0',NULL),(9600147,'10.10.10.15','','0',NULL),(9600148,'10.10.10.15','','0',NULL),(9600149,'10.10.10.15','','0',NULL),(9600150,'10.10.10.15','','0',NULL),(9600151,'10.10.10.15','','0',NULL),(9600152,'10.10.10.15','','0',NULL),(9600153,'10.10.10.15','','0',NULL),(9600154,'10.10.10.15','','0',NULL),(9600155,'10.10.10.15','','0',NULL),(9600156,'10.10.10.15','','0',NULL),(9600157,'10.10.10.15','','0',NULL),(9600158,'10.10.10.15','','0',NULL),(9600159,'10.10.10.15','','0',NULL),(9600160,'10.10.10.15','','0',NULL),(9600161,'10.10.10.15','','0',NULL),(9600162,'10.10.10.15','','0',NULL),(9600163,'10.10.10.15','','0',NULL),(9600164,'10.10.10.15','','0',NULL),(9600165,'10.10.10.15','','0',NULL),(9600166,'10.10.10.15','','0',NULL),(9600167,'10.10.10.15','','0',NULL),(9600168,'10.10.10.15','','0',NULL),(9600169,'10.10.10.15','','0',NULL),(9600170,'10.10.10.15','','0',NULL),(9600171,'10.10.10.15','','0',NULL),(9600172,'10.10.10.15','','0',NULL),(9600173,'10.10.10.15','','0',NULL),(9600174,'10.10.10.15','','0',NULL),(9600175,'10.10.10.15','','0',NULL),(9600176,'10.10.10.15','','0',NULL),(9600177,'10.10.10.15','','0',NULL),(9600178,'10.10.10.15','','0',NULL),(9600179,'10.10.10.15','','0',NULL),(9600180,'10.10.10.15','','0',NULL),(9600181,'10.10.10.15','','0',NULL),(9600182,'10.10.10.15','','0',NULL),(9600183,'10.10.10.15','','0',NULL),(9600184,'10.10.10.15','','0',NULL),(9600185,'10.10.10.15','','0',NULL),(9600186,'10.10.10.15','','0',NULL),(9600187,'10.10.10.15','','0',NULL),(9600188,'10.10.10.15','','0',NULL),(9600189,'10.10.10.15','','0',NULL),(9600190,'10.10.10.15','','0',NULL),(9600191,'10.10.10.15','','0',NULL),(9600192,'10.10.10.15','','0',NULL),(9600193,'10.10.10.15','','0',NULL),(9600194,'10.10.10.15','','0',NULL),(9600195,'10.10.10.15','','0',NULL),(9600196,'10.10.10.15','','0',NULL),(9600197,'10.10.10.15','','0',NULL),(9600198,'10.10.10.15','','0',NULL),(9600199,'10.10.10.15','','0',NULL),(9600200,'10.10.10.15','','0',NULL),(9600201,'10.10.10.15','','0',NULL),(9600202,'10.10.10.15','','0',NULL),(9600203,'10.10.10.15','','0',NULL),(9600204,'10.10.10.15','','0',NULL),(9600205,'10.10.10.15','','0',NULL),(9600206,'10.10.10.15','','0',NULL),(9600207,'10.10.10.15','','0',NULL),(9600208,'10.10.10.15','','0',NULL),(9600209,'10.10.10.15','','0',NULL),(9600210,'10.10.10.15','','0',NULL),(9600211,'10.10.10.15','','0',NULL),(9600212,'10.10.10.15','','0',NULL),(9600213,'10.10.10.15','','0',NULL),(9600214,'10.10.10.15','','0',NULL),(9600215,'10.10.10.15','','0',NULL),(9600216,'10.10.10.15','','0',NULL),(9600217,'10.10.10.15','','0',NULL),(9600218,'10.10.10.15','','0',NULL),(9600219,'10.10.10.15','','0',NULL),(9600220,'10.10.10.15','','0',NULL),(9600221,'10.10.10.15','','0',NULL),(9600222,'10.10.10.15','','0',NULL),(9600223,'10.10.10.15','','0',NULL),(9600224,'10.10.10.15','','0',NULL),(9600225,'10.10.10.15','','0',NULL),(9600226,'10.10.10.15','','0',NULL),(9600227,'10.10.10.15','','0',NULL),(9600228,'10.10.10.15','','0',NULL),(9600229,'10.10.10.15','','0',NULL),(9600230,'10.10.10.15','','0',NULL),(9600231,'10.10.10.15','','0',NULL),(9600232,'10.10.10.15','','0',NULL),(9600233,'10.10.10.15','','0',NULL),(9600234,'10.10.10.15','','0',NULL),(9600235,'10.10.10.15','','0',NULL),(9600236,'10.10.10.15','','0',NULL),(9600237,'10.10.10.15','','0',NULL),(9600238,'10.10.10.15','','0',NULL),(9600239,'10.10.10.15','','0',NULL),(9600240,'10.10.10.15','','0',NULL),(9600241,'10.10.10.15','','0',NULL),(9600242,'10.10.10.15','','0',NULL),(9600243,'10.10.10.15','','0',NULL),(9600244,'10.10.10.15','','0',NULL),(9600245,'10.10.10.15','','0',NULL),(9600246,'10.10.10.15','','0',NULL),(9600247,'10.10.10.15','','0',NULL),(9600248,'10.10.10.15','','0',NULL),(9600249,'10.10.10.15','','0',NULL),(9600250,'10.10.10.15','','0',NULL),(9600251,'10.10.10.15','','0',NULL),(9600252,'10.10.10.15','','0',NULL),(9600253,'10.10.10.15','','0',NULL),(9600254,'10.10.10.15','','0',NULL),(9600255,'10.10.10.15','','0',NULL),(9600256,'10.10.10.15','','0',NULL),(9600257,'10.10.10.15','','0',NULL),(9600258,'10.10.10.15','','0',NULL),(9600259,'10.10.10.15','','0',NULL),(9600260,'10.10.10.15','','0',NULL),(9600261,'10.10.10.15','','0',NULL),(9600262,'10.10.10.15','','0',NULL),(9600263,'10.10.10.15','','0',NULL),(9600264,'10.10.10.15','','0',NULL),(9600265,'10.10.10.15','','0',NULL),(9600266,'10.10.10.15','','0',NULL),(9600267,'10.10.10.15','','0',NULL),(9600268,'10.10.10.15','','0',NULL),(9600269,'10.10.10.15','','0',NULL),(9600270,'10.10.10.15','','0',NULL),(9600271,'10.10.10.15','','0',NULL),(9600272,'10.10.10.15','','0',NULL),(9600273,'10.10.10.15','','0',NULL),(9600274,'10.10.10.15','','0',NULL),(9600275,'10.10.10.15','','0',NULL),(9600276,'10.10.10.15','','0',NULL),(9600277,'10.10.10.15','','0',NULL),(9600278,'10.10.10.15','','0',NULL),(9600279,'10.10.10.15','','0',NULL),(9600280,'10.10.10.15','','0',NULL),(9600281,'10.10.10.15','','0',NULL),(9600282,'10.10.10.15','','0',NULL),(9600283,'10.10.10.15','','0',NULL),(9600284,'10.10.10.15','','0',NULL),(9600285,'10.10.10.15','','0',NULL),(9600286,'10.10.10.15','','0',NULL),(9600287,'10.10.10.15','','0',NULL),(9600288,'10.10.10.15','','0',NULL),(9600289,'10.10.10.15','','0',NULL),(9600290,'10.10.10.15','','0',NULL),(9600291,'10.10.10.15','','0',NULL),(9600292,'10.10.10.15','','0',NULL),(9600293,'10.10.10.15','','0',NULL),(9600294,'10.10.10.15','','0',NULL),(9600295,'10.10.10.15','','0',NULL),(9600296,'10.10.10.15','','0',NULL),(9600297,'10.10.10.15','','0',NULL),(9600298,'10.10.10.15','','0',NULL),(9600299,'10.10.10.15','','0',NULL);"



echo "Populate AREA CODES"
/usr/share/astguiclient/ADMIN_area_code_populate.pl


perl install.pl --no-prompt


#Install Crontab
cat <<CRONTAB>> /root/crontab-file


### Change dialing to timezones based on zip or postal code (uncomment)
#5 * * * * /usr/bin/mysql -e "use asterisk; update vicidal_lists SET time_zone_setting ='POSTAL_CODE'"

###Audio Sync hourly
* 1 * * * /usr/share/astguiclient/ADMIN_audio_store_sync.pl --upload --quiet

### Daily Backups ###
0 2 * * * /usr/share/astguiclient/ADMIN_backup.pl

###certbot renew
@monthly /usr/src/vicidial-install-scripts/certbot.sh

### recording mixing/compressing/ftping scripts
#0,3,6,9,12,15,18,21,24,27,30,33,36,39,42,45,48,51,54,57 * * * * /usr/share/astguiclient/AST_CRON_audio_1_move_mix.pl
0,3,6,9,12,15,18,21,24,27,30,33,36,39,42,45,48,51,54,57 * * * * /usr/share/astguiclient/AST_CRON_audio_1_move_mix.pl --MIX
0,3,6,9,12,15,18,21,24,27,30,33,36,39,42,45,48,51,54,57 * * * * /usr/share/astguiclient/AST_CRON_audio_1_move_VDonly.pl
1,4,7,10,13,16,19,22,25,28,31,34,37,40,43,46,49,52,55,58 * * * * /usr/share/astguiclient/AST_CRON_audio_2_compress.pl --MP3 --HTTPS
#2,5,8,11,14,17,20,23,26,29,32,35,38,41,44,47,50,53,56,59 * * * * /usr/share/astguiclient/AST_CRON_audio_3_ftp.pl --MP3

### keepalive script for astguiclient processes
* * * * * /usr/share/astguiclient/ADMIN_keepalive_ALL.pl

### kill Hangup script for Asterisk updaters
* * * * * /usr/share/astguiclient/AST_manager_kill_hung_congested.pl

### updater for voicemail
* * * * * /usr/share/astguiclient/AST_vm_update.pl

### updater for conference validator
#* * * * * /usr/share/astguiclient/AST_conf_update.pl

### flush queue DB table every hour for entries older than 1 hour
11 * * * * /usr/share/astguiclient/AST_flush_DBqueue.pl -q

### fix the vicidial_agent_log once every hour and the full day run at night
33 * * * * /usr/share/astguiclient/AST_cleanup_agent_log.pl
50 0 * * * /usr/share/astguiclient/AST_cleanup_agent_log.pl --last-24hours

## uncomment below if using QueueMetrics
#*/5 * * * * /usr/share/astguiclient/AST_cleanup_agent_log.pl --only-qm-live-call-check

## uncomment below if using Vtiger
#1 1 * * * /usr/share/astguiclient/Vtiger_optimize_all_tables.pl --quiet

### updater for VICIDIAL hopper
* * * * * /usr/share/astguiclient/AST_VDhopper.pl -q

### adjust the GMT offset for the leads in the vicidial_list table
1 1,7 * * * /usr/share/astguiclient/ADMIN_adjust_GMTnow_on_leads.pl --debug

### reset several temporary-info tables in the database
2 1 * * * /usr/share/astguiclient/AST_reset_mysql_vars.pl

### optimize the database tables within the asterisk database
3 1 * * * /usr/share/astguiclient/AST_DB_optimize.pl

## adjust time on the server with ntp
#30 * * * * /usr/sbin/ntpdate -u pool.ntp.org 2>/dev/null 1>&amp;2

### VICIDIAL agent time log weekly and daily summary report generation
2 0 * * 0 /usr/share/astguiclient/AST_agent_week.pl
22 0 * * * /usr/share/astguiclient/AST_agent_day.pl

### VICIDIAL campaign export scripts (OPTIONAL)
#32 0 * * * /usr/share/astguiclient/AST_VDsales_export.pl
#42 0 * * * /usr/share/astguiclient/AST_sourceID_summary_export.pl

### remove old recordings
#24 0 * * * /usr/bin/find /var/spool/asterisk/monitorDONE -maxdepth 2 -type f -mtime +7 -print | xargs rm -f
#26 1 * * * /usr/bin/find /var/spool/asterisk/monitorDONE/MP3 -maxdepth 2 -type f -mtime +65 -print | xargs rm -f
#25 1 * * * /usr/bin/find /var/spool/asterisk/monitorDONE/FTP -maxdepth 2 -type f -mtime +1 -print | xargs rm -f
24 1 * * * /usr/bin/find /var/spool/asterisk/monitorDONE/ORIG -maxdepth 2 -type f -mtime +1 -print | xargs rm -f


### roll logs monthly on high-volume dialing systems
30 1 1 * * /usr/share/astguiclient/ADMIN_archive_log_tables.pl --days=90

### remove old vicidial logs and asterisk logs more than 2 days old
28 0 * * * /usr/bin/find /var/log/astguiclient -maxdepth 1 -type f -mtime +2 -print | xargs rm -f
29 0 * * * /usr/bin/find /var/log/asterisk -maxdepth 3 -type f -mtime +2 -print | xargs rm -f
30 0 * * * /usr/bin/find / -maxdepth 1 -name "screenlog.0*" -mtime +4 -print | xargs rm -f

### cleanup of the scheduled callback records
25 0 * * * /usr/share/astguiclient/AST_DB_dead_cb_purge.pl --purge-non-cb -q

### GMT adjust script - uncomment to enable
#45 0 * * * /usr/share/astguiclient/ADMIN_adjust_GMTnow_on_leads.pl --list-settings

### Dialer Inventory Report
1 7 * * * /usr/share/astguiclient/AST_dialer_inventory_snapshot.pl -q --override-24hours

### inbound email parser - not enabled by default
#* * * * * /usr/share/astguiclient/AST_inbound_email_parser.pl

### Daily Reboot
#30 6 * * * /sbin/reboot

######TILTIX GARBAGE FILES DELETE
#00 22 * * * root cd /tmp/ && find . -name '*TILTXtmp*' -type f -delete

### Dynportal
@reboot /usr/bin/VB-firewall --whitelist=ViciWhite --dynamic --quiet
* * * * * /usr/bin/VB-firewall --whitelist=ViciWhite --dynamic --quiet
* * * * * sleep 10; /usr/bin/VB-firewall --white --dynamic --quiet
* * * * * sleep 20; /usr/bin/VB-firewall --white --dynamic --quiet
* * * * * sleep 30; /usr/bin/VB-firewall --white --dynamic --quiet
* * * * * sleep 40; /usr/bin/VB-firewall --white --dynamic --quiet
* * * * * sleep 50; /usr/bin/VB-firewall --white --dynamic --quiet


CRONTAB

crontab /root/crontab-file
crontab -l

#Asterisk service
tee -a /etc/systemd/system/asterisk.service <<EOF

[Unit]
Description=Asterisk PBX
Wants=nss-lookup.target
Wants=network-online.target
After=network-online.target

[Service]
PIDFile=/run/asterisk/asterisk.pid
ExecStart=/usr/sbin/asterisk -fn
ExecReload=/bin/kill -HUP $MAINPID

[Install]
WantedBy=basic.target
Also=systemd-networkd-wait-online.service
EOF
#Install rc.local

sudo sed -i 's|exit 0|### exit 0|g' /etc/rc.d/rc.local

tee -a /etc/rc.d/rc.local <<EOF


# OPTIONAL enable ip_relay(for same-machine trunking and blind monitoring)

/usr/share/astguiclient/ip_relay/relay_control start 2>/dev/null 1>&2


# Disable console blanking and powersaving

/usr/bin/setterm -blank

/usr/bin/setterm -powersave off

/usr/bin/setterm -powerdown


### start up the MySQL server

systemctl start mariadb.service


### start up the apache web server

systemctl start httpd.service


### roll the Asterisk logs upon reboot

/usr/share/astguiclient/ADMIN_restart_roll_logs.pl


### clear the server-related records from the database

/usr/share/astguiclient/AST_reset_mysql_vars.pl


### load dahdi drivers

modprobe dahdi
modprobe dahdi_dummy

/usr/sbin/dahdi_cfg -vvvvvvvvvvvvv


### sleep for 20 seconds before launching Asterisk

sleep 20


### start up asterisk

/usr/share/astguiclient/start_asterisk_boot.pl

exit 0

EOF

chmod +x /etc/rc.d/rc.local
systemctl enable rc-local
systemctl start rc-local

### Install cockpit
yum -y install cockpit cockpit-storaged cockpit-navigator
sed -i s/root/"#root"/g /etc/cockpit/disallowed-users
systemctl enable cockpit.socket

##Install CyburPhone
cd /var/www/html
git clone https://github.com/carpenox/CyburPhone.git
chmod -R 744 CyburPhone
chown -R apache:apache CyburPhone

##Install Dynportal
yum install -y firewalld
cd /home
wget https://dialer.one/dynportal.zip --no-check-certificate
wget https://dialer.one/firewall.zip --no-check-certificate
wget https://dialer.one/aggregate --no-check-certificate
wget https://dialer.one/VB-firewall --no-check-certificate

mkdir -p /var/www/vhosts/dynportal
mv /home/dynportal.zip /var/www/vhosts/dynportal/
mv /home/firewall.zip /etc/firewalld/
cd /var/www/vhosts/dynportal/
unzip dynportal.zip
chmod -R 755 *
chown -R apache:apache *
cd etc/httpd/conf.d/
mv viciportal.conf /etc/httpd/conf.d/
cd /etc/firewalld/
unzip -o firewall.zip
cd zones/
rm -rf public.xml trusted.xml
cd /etc/firewalld/
mv -bf public.xml trusted.xml /etc/firewalld/zones/
mv /home/aggregate /usr/bin/
chmod +x /usr/bin/aggregate
mv /home/VB-firewall /usr/bin/
chmod +x /usr/bin/VB-firewall


## mv -f /root/defaults.inc.php /var/www/vhosts/dynportal/inc/defaults.inc.php
## mv -f /home/viciportal-ssl.conf /etc/httpd/conf.d/viciportal-ssl.conf

firewall-offline-cmd --add-port=446/tcp --zone=public

##Fix ip_relay
cd /usr/src/astguiclient/trunk/extras/ip_relay/
unzip ip_relay_1.1.112705.zip
cd ip_relay_1.1/src/unix/
make
cp ip_relay ip_relay2
mv -f ip_relay /usr/bin/
mv -f ip_relay2 /usr/local/bin/ip_relay

cd /usr/lib64/asterisk/modules
wget http://asterisk.hosting.lv/bin/codec_g729-ast160-gcc4-glibc-x86_64-core2-sse4.so
mv codec_g729-ast160-gcc4-glibc-x86_64-core2-sse4.so codec_g729.so
chmod 777 codec_g729.so

tee -a /etc/httpd/conf/httpd.conf <<EOF

CustomLog /dev/null common

Alias /RECORDINGS/MP3 "/var/spool/asterisk/monitorDONE/MP3/"

<Directory "/var/spool/asterisk/monitorDONE/MP3/">
    Options Indexes MultiViews
    AllowOverride None
    Require all granted
</Directory>
EOF

##Install Sounds

cd /usr/src
wget http://downloads.asterisk.org/pub/telephony/sounds/asterisk-core-sounds-en-ulaw-current.tar.gz
wget http://downloads.asterisk.org/pub/telephony/sounds/asterisk-core-sounds-en-wav-current.tar.gz
wget http://downloads.asterisk.org/pub/telephony/sounds/asterisk-core-sounds-en-gsm-current.tar.gz
wget http://downloads.asterisk.org/pub/telephony/sounds/asterisk-extra-sounds-en-ulaw-current.tar.gz
wget http://downloads.asterisk.org/pub/telephony/sounds/asterisk-extra-sounds-en-wav-current.tar.gz
wget http://downloads.asterisk.org/pub/telephony/sounds/asterisk-extra-sounds-en-gsm-current.tar.gz
wget http://downloads.asterisk.org/pub/telephony/sounds/asterisk-moh-opsound-gsm-current.tar.gz
wget http://downloads.asterisk.org/pub/telephony/sounds/asterisk-moh-opsound-ulaw-current.tar.gz
wget http://downloads.asterisk.org/pub/telephony/sounds/asterisk-moh-opsound-wav-current.tar.gz

#Place the audio files in their proper places:
cd /var/lib/asterisk/sounds
tar -zxf /usr/src/asterisk-core-sounds-en-gsm-current.tar.gz
tar -zxf /usr/src/asterisk-core-sounds-en-ulaw-current.tar.gz
tar -zxf /usr/src/asterisk-core-sounds-en-wav-current.tar.gz
tar -zxf /usr/src/asterisk-extra-sounds-en-gsm-current.tar.gz
tar -zxf /usr/src/asterisk-extra-sounds-en-ulaw-current.tar.gz
tar -zxf /usr/src/asterisk-extra-sounds-en-wav-current.tar.gz

mkdir /var/lib/asterisk/mohmp3
mkdir /var/lib/asterisk/quiet-mp3
ln -s /var/lib/asterisk/mohmp3 /var/lib/asterisk/default

cd /var/lib/asterisk/mohmp3
tar -zxf /usr/src/asterisk-moh-opsound-gsm-current.tar.gz
tar -zxf /usr/src/asterisk-moh-opsound-ulaw-current.tar.gz
tar -zxf /usr/src/asterisk-moh-opsound-wav-current.tar.gz
rm -f CHANGES*
rm -f LICENSE*
rm -f CREDITS*

cd /var/lib/asterisk/moh
rm -f CHANGES*
rm -f LICENSE*
rm -f CREDITS*

cd /var/lib/asterisk/sounds
rm -f CHANGES*
rm -f LICENSE*
rm -f CREDITS*

yum -y in sox

cd /var/lib/asterisk/quiet-mp3
sox ../mohmp3/macroform-cold_day.wav macroform-cold_day.wav vol 0.25
sox ../mohmp3/macroform-cold_day.gsm macroform-cold_day.gsm vol 0.25
sox -t ul -r 8000 -c 1 ../mohmp3/macroform-cold_day.ulaw -t ul macroform-cold_day.ulaw vol 0.25
sox ../mohmp3/macroform-robot_dity.wav macroform-robot_dity.wav vol 0.25
sox ../mohmp3/macroform-robot_dity.gsm macroform-robot_dity.gsm vol 0.25
sox -t ul -r 8000 -c 1 ../mohmp3/macroform-robot_dity.ulaw -t ul macroform-robot_dity.ulaw vol 0.25
sox ../mohmp3/macroform-the_simplicity.wav macroform-the_simplicity.wav vol 0.25
sox ../mohmp3/macroform-the_simplicity.gsm macroform-the_simplicity.gsm vol 0.25
sox -t ul -r 8000 -c 1 ../mohmp3/macroform-the_simplicity.ulaw -t ul macroform-the_simplicity.ulaw vol 0.25
sox ../mohmp3/reno_project-system.wav reno_project-system.wav vol 0.25
sox ../mohmp3/reno_project-system.gsm reno_project-system.gsm vol 0.25
sox -t ul -r 8000 -c 1 ../mohmp3/reno_project-system.ulaw -t ul reno_project-system.ulaw vol 0.25
sox ../mohmp3/manolo_camp-morning_coffee.wav manolo_camp-morning_coffee.wav vol 0.25
sox ../mohmp3/manolo_camp-morning_coffee.gsm manolo_camp-morning_coffee.gsm vol 0.25
sox -t ul -r 8000 -c 1 ../mohmp3/manolo_camp-morning_coffee.ulaw -t ul manolo_camp-morning_coffee.ulaw vol 0.25

tee -a ~/.bashrc <<EOF

# Commands
/usr/share/astguiclient/ADMIN_keepalive_ALL.pl --cu3way
/usr/bin/systemctl status httpd --no-pager
/usr/bin/systemctl status firewalld --no-pager
/usr/bin/screen -ls
/usr/sbin/dahdi_cfg -v
/usr/sbin/asterisk -V
EOF


sed -i 's|#Banner none|Banner /etc/ssh/sshd_banner|g' /etc/ssh/sshd_config


tee -a /etc/ssh/sshd_banner <<EOF
Thank you for choosing CyburDial and carpenox's auto installer!

Visit our Knowledge Base at https://www.dialer.one

Support: info@dialer.one
Discord Live Chat Support: https://discord.gg/ymGZJvF6hK
EOF

## Remove debug kernel
dnf remove kernel-debug* -y

#add rc-local as a service - thx to ras
tee -a /etc/systemd/system/rc-local.service <<EOF
[Unit]
Description=/etc/rc.local Compatibility

[Service]
Type=oneshot
ExecStart=/etc/rc.local
TimeoutSec=0
StandardInput=tty
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

##fstab entry
tee -a /etc/fstab <<EOF
none /var/spool/asterisk/monitor tmpfs nodev,nosuid,noexec,nodiratime,size=2G 0 0
EOF

## FTP fix
##tee -a /etc/ssh/sshd_config << EOF
#Subsystem      sftp    /usr/libexec/openssh/sftp-server
##Subsystem sftp internal-sftp
##EOF

##confbridge fix
cd /usr/src/vicidial-install-scripts/
yes | cp -rf extensions.conf /etc/asterisk/extensions.conf
cp -rf confbridge-vicidial.conf /etc/asterisk/

tee -a /etc/asterisk/confbridge.conf <<EOF

#include confbridge-vicidial.conf
EOF

systemctl daemon-reload
sudo systemctl enable rc-local.service
sudo systemctl start rc-local.service

cat <<WELCOME>> /var/www/html/index.html
<META HTTP-EQUIV=REFRESH CONTENT="1; URL=/vicidial/welcome.php">
Please Hold while I redirect you!
WELCOME

#cd /usr/src/vicidial-install-scripts
#chmod +x confbridges.sh
#./confbridges.sh

mkdir /var/www/html/hgcjvmrjzqcngw47wf5zf4xjzd9n0k
cp -r /var/lib/asterisk/sounds/* /var/www/html/hgcjvmrjzqcngw47wf5zf4xjzd9n0k/

chkconfig asterisk off

sudo sed -i 's/SERVER_EXTERNAL_IP/0.0.0.0/' /etc/asterisk/pjsip.conf

## add confcron user
tee -a /etc/asterisk/manager.conf <<EOF

[confcron]
secret = 1234
read = command,reporting
write = command,reporting

eventfilter=Event: Meetme
eventfilter=Event: Confbridge
EOF


firewall-cmd --add-port=10000-20000/udp --permanent
firewall-cmd --add-service=http --permanent --zone=trusted
chmod +x /usr/src/vicidial-install-scripts/certbot.sh

chmod -R 777 /var/spool/asterisk/
chown -R apache:apache /var/spool/asterisk/

## mv /usr/src/vicidial-install-scripts/viciportal-ssl.conf /home/viciportal-ssl.conf
## sed -i s/DOMAINNAME/"$DOMAINNAME"/g /var/www/vhosts/dynportal/inc/defaults.inc.php
## sed -i s/DOMAINNAME/"$DOMAINNAME"/g /home/viciportal-ssl.conf

## mysql -e "use asterisk; update system_settings set active_voicemail_server='$ip_address', webphone_url='https://$hostname/CyburPhone/cyburphone.php', sounds_web_server='https://$hostname';"

echo "d /run/screen 1777 root root -" > /etc/tmpfiles.d/screen.conf
systemd-tmpfiles --create /etc/tmpfiles.d/screen.conf

# Standard DB installer and placeholder-fix helper
# Usage: run interactively inside your installer

# detect primary server IP (robust)
ip_address=$ip_address
if [ -z "$ip_address" ]; then
  ip_address="$(ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++){if($i=="src"){print $(i+1); exit}}}')" 
fi
if [ -z "$ip_address" ]; then
  echo "Could not detect server IP automatically. Please enter the server IP:"
  read -r ip_address
fi

# detect hostname (short)
hostname="$(hostname -s 2>/dev/null)"
if [ -z "$hostname" ]; then
  echo "Could not detect hostname automatically. Please enter the hostname:"
  read -r hostname
fi

echo "Detected IP: $ip_address"
echo "Detected Hostname: $hostname"
echo

read -r -p "Install standard ready-to-go database using standard-db.sh? [y/N]: " want_db
want_db="${want_db:-N}"

if echo "$want_db" | grep -iq '^y'; then
  # download standard-db.sh from the repo commit (use your raw URL / commit OID)
  STD_DB_URL="https://raw.githubusercontent.com/carpenox/vicidial-install-scripts/e3373b9b035d3b7534af2fc1eeb3d713b4b15c22/standard-db.sh"
  TMP_STDDB="/tmp/standard-db.sh"

  echo "Fetching standard-db.sh..."
  if ! curl -fsSL -o "$TMP_STDDB" "$STD_DB_URL"; then
    echo "Failed to download standard-db.sh from $STD_DB_URL"
    echo "If you have a local copy, set STDDB_PATH to its path and re-run."
    exit 1
  fi

  chmod +x "$TMP_STDDB"
  echo "Running $TMP_STDDB ..."
  /bin/sh "$TMP_STDDB" || {
    echo "standard-db.sh failed. Inspect output above."
    # continue — we still try to fix server IP / placeholders
  }

  # run astguiclient IP update (use --old-server_ip value used inside standard-db.sh if known)
  # standard-db.sh uses --old-server_ip=149.28.96.244 — we update to detected IP and run --auto
  if [ -x /usr/share/astguiclient/ADMIN_update_server_ip.pl ]; then
    echo "Updating server IP in astguiclient DB files..."
      /usr/share/astguiclient/ADMIN_update_server_ip.pl --old-server_ip=149.28.96.244 --server_ip=$ip_address --auto || \
      echo "ADMIN_update_server_ip.pl failed or returned non-zero."
  else
    echo "WARNING: /usr/share/astguiclient/ADMIN_update_server_ip.pl not found; skipping automatic DB IP update."
  fi



  # Update Vicidial system_settings table for webphone_url, sounds_web_server, active_voicemail_server
  echo "Applying Vicidial DB updates for webphone_url, sounds_web_server and active_voicemail_server (requires mysql client + root access)."
  if command -v mysql >/dev/null 2>&1; then
    # Attempt with no-password mysql first; if that fails, it will prompt or fail silently
    echo "mysql -u root -p -e \"USE asterisk; UPDATE system_settings SET active_voicemail_server='$ip_address', webphone_url='https://$hostname/CyburPhone/cyburphone.php', sounds_web_server='https://$hostname';\""
  else
    echo "mysql client not found; SKIPPING Vicidial DB updates. Run the command shown above manually once mysql client available."
  fi

  echo
  echo "Standard DB install and placeholder replacement finished. Please inspect backups (*.bak.std_replace) if needed."
else
  echo "Skipping standard DB install."
fi

yum in certbot -y
systemctl enable certbot-renew.timer
systemctl start certbot-renew.timer
cd /usr/src/vicidial-install-scripts
chmod +x vicidial-enable-webrtc.sh
service firewalld stop
./vicidial-enable-webrtc.sh
service firewalld start
systemctl enable firewalld

cp /etc/letsencrypt/live/$hostname/fullchain.pem /etc/cockpit/ws-certs.d/wildcart.$hostname.cert
cp /etc/letsencrypt/live/$hostname/privkey.pem /etc/cockpit/ws-certs.d/wildcart.$hostname.key
systemctl restart cockpit.socket

# Next: optionally update any other templates you know the exact paths of:
# Example:
# sed -i.bak "s/OLDHOSTNAME/$hostname/g" /var/www/html/CyburPhone/templates/webrtc_template.php
# mysql ... update any more DB rows if required

read -p 'Press Enter to Reboot: '

echo "Restarting AlmaLinux"

reboot
