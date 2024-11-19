# DBMS Library System: Road to Sigma Rizz DBA, for B27 database technology CS GC

## SSL Encryption Set Up

### 1. Create Virtual Host
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
   ![sslMakecret](assets/sslMakecret.png)

### 3. Modifying Virtual Host
### 4. Install Certificate
