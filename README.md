# DBMS Library System: Road to Sigma Rizz DBA, for B27 database technology Computer Science Global Class

This project is a database management system project that is developed for the needs of B27's Database Technology course. The management system includes several important aspects of DBMS, from `indexing`, `storage management`, `procedures and triggers` to `full text search` and `backup and restoration`.

## Design Creation
Entity Relationship Diagram:
The Entity Relationship Diagram below is created with having 6 tables which are `User`, `Author`, `Book`, `Stock`, `Reservation`, and `Loan`.

![ERD](erd/EntityRelationshipDiagramLibraryDatabase.jpg)

## Schema Creation
Entities and Relationships:
### 1. User
```sql
CREATE TABLE `User` (
    Id CHAR(36) PRIMARY KEY DEFAULT UUID(),
    Name VARCHAR(100) NOT NULL,
    Address VARCHAR(100) NOT NULL
) ENGINE = InnoDB;
```
The table has the following relationship:\
One `User` can have many `Reservations`

The table has the following attributes:\
| Attributes     | Description                                                                     |
|----------------|---------------------------------------------------------------------------------|
|`Id`            | The unique idenfier of the table which is configured with UUID [`PRIMARY KEY`]\ |
|`Name`          | The name of the user\                                                           |
|`Address`       | The address of the user                                                         |

### 2. Author
```sql
CREATE TABLE Author (
    Id CHAR(36) PRIMARY KEY DEFAULT UUID(),
    Name VARCHAR(100) NOT NULL,
    Birthdate date NOT NULL,
    FULLTEXT(Name)
) ENGINE = InnoDB;
```
The table has the following relationship:

One `Author` can have many `Books`

The table has the following attributes:

`Id`         : The unique identifier of the table which is configured with UUID [`PRIMARY KEY`]

`Name`       : The name of the author. Added `FULLTEXT` for fast searching.

`Birthdate`  : The birthdate of the author

### 3. Book
```sql
CREATE TABLE Book (
    Id CHAR(36) PRIMARY KEY DEFAULT UUID(),
    ISBN CHAR(17) UNIQUE NOT NULL,
    CHECK(ISBN REGEXP'^(978|979)-[0-9]{1,5}-[0-9]{1,7}-[0-9]{1,7}-[0-9]$'),
    Title VARCHAR(100) NOT NULL,
    AuthorId VARCHAR(100) NOT NULL,
    FOREIGN KEY (AuthorId) REFERENCES Author(Id) ON UPDATE CASCADE ON DELETE CASCADE,
    FULLTEXT(Title)
) ENGINE = InnoDB;
```
The table has the following relationship:
One `Book` can have many `Reservation` but can only have one `Stock`

The table has the following attributes:
`Id`         : The unique identifier of the table which is configured with UUID
`ISBN`       : The unique code of each book. Added `CHECK` to make sure the `ISBN` is valid.
`Title`      : The book title
`AuthorId`   : Refers to the `Id` of the `Author`

## SSL Encryption Set Up

### 1. Create Virtual Host
Add the following lines at the end of `httpd-vhosts.conf` file located in `.../xampp/apache/conf/extra`. The port can change based on your need but by default it is port 80. Yet, if you are using other ports additional set ups are required.
```apache
<VirtualHost *:80>
   DocumentRoot "C:/xampp/htdocs/"
   ServerName localhost
   SSLEngine on	
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

### 5. Checking
If the server only runs when in `https://localhost` and return `400: Bad Gateway` in `localhost` then you have finished setting up ssl encryption.

## Backup and Restore

### 1. Create bat file
This bat file will act as the file the backups the database. Code may vary depending on your `file location` and `variable names`. This script is made on `Windows` operating system.
```php
@echo off
set BACKUP_DIR="E:\-- Semester 3\Database Technology\BackUp and Restoration"
set DATABASE_NAME=library

for /f "tokens=2 delims==" %%I in ('wmic OS GET localdatetime /VALUE') do set datetime=%%I

set YYYY=%datetime:~0,4%
set MM=%datetime:~4,2%
set DD=%datetime:~6,2%
set HH=%datetime:~8,2%
set MIN=%datetime:~10,2%
set SS=%datetime:~12,2%

set TIMESTAMP=%YYYY%-%MM%-%DD%_%HH%-%MIN%-%SS%
set MYSQL_USER=admin
set MYSQL_PASSWORD=password

"C:\xampp\mysql\bin\mysqldump.exe" -u %MYSQL_USER% -p%MYSQL_PASSWORD% %DATABASE_NAME% > %BACKUP_DIR%\backup_%DATABASE_NAME%_%TIMESTAMP%.sql

if %ERRORLEVEL% EQU 0 (
    echo Backup completed successfully.
) else (
    echo Backup failed. Check your settings and permissions.
)
pause
```

### 2. Create the user
Run the following query with `username` and `password` same as what you wrote in the `backup.bat` file.
```sql
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'password';
GRANT 'admin' TO 'admin'@'localhost';
```

### 3. Automate the backup
In `Windows`, the `Task Scheduler` can help you create automatic recurring runs for the `backup.bat` file.
#### Step 1:
<img src="assets/TaskScheduler1.png" alt="TaskScheduler1" width="400">

#### Step 2:
<img src="assets/TaskScheduler2.png" alt="TaskScheduler2" width="400">

#### Step 3:
<img src="assets/TaskScheduler3.png" alt="TaskScheduler3" width="400">

#### Step 4:
<img src="assets/TaskScheduler4.png" alt="TaskScheduler4" width="400">

#### Step 5:
<img src="assets/TaskScheduler5.png" alt="TaskScheduler5" width="400">

#### Step 6:
<img src="assets/TaskScheduler6.png" alt="TaskScheduler6" width="400">

#### Step 7:
<img src="assets/TaskScheduler7.png" alt="TaskScheduler7" width="400">
