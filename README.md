# DBMS Library System: Road to Sigma Rizz DBA, for B27 database technology CS GC

## SSL Encryption Set Up

### 1. Create Virtual Host
Add the following lines at the end of `httpd-vhosts.conf` file located in `.../xampp/apache/conf/extra` 
```apache
<VirtualHost *:443>
   DocumentRoot "C:/xampp/htdocs/"
   ServerName localhost
   SSLEngine Oon	
   SSLCertificateFile "conf/ssl.crt/server.crt"
   SSLCertificateKeyFile "conf/ssl.key/server.key"
   <Directory "C:/xampp/htdocs/">
    Options All
    AllowOverride All
    Require all granted
   </Directory>
   ErrorLog "logs/dummy-host2.example.com-error.log"
   CustomLog "logs/dummy-host2.example.com-access.log" common
 </VirtualHost>
```
### 2. Create Certificate
Generate SSL Certificate by running `makecert.bat` in `xampp/apache` and fill in your data. You can simply enter to fill the data with its default data provided.
![sslMakecert](assets/sslMakecert.png)
After the setup, the files `ssl.crt/server.crt` and `ssl.key/server.key` should be created in `.../xampp/apache/conf`. These are the files needed for apache to validate the security protocol.
### 3. Modifying Virtual Host
Add the following line at the end of `httpd.conf` file located in `.../xampp/apache/conf`
```apache 
Include conf/extra/httpd-vhosts.conf
```
### 4. Install Certificate
To install the certificate open `server.crt` located in `.../xampp/apache/conf/ssl.crt` and follow the following steps:
#### Step 1: 
<img src="assets/InstallCert1.png" alt="InstallCert1" width="400">

#### Step 2:
<img src="assets/InstallCert2.png" alt="InstallCert2" width="400">

#### Step 3:
<img src="assets/InstallCert3.png" alt="InstallCert3" width="400">

#### Step 4:
<img src="assets/InstallCert4.png" alt="InstallCert4" width="400">

#### Step 5:
<img src="assets/InstallCert5.png" alt="InstallCert5" width="400">
