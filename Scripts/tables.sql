-- Database Initialization

DROP DATABASE IF EXISTS library;

CREATE DATABASE library;

USE library;

SET GLOBAL innodb_buffer_pool_size = 8 * 1024 * 1024 * 1024;     -- 8 GB
SET GLOBAL query_cache_size = 64 * 1024 * 1024;                  -- 64MB

-- Table User

CREATE TABLE `User` (
    Id CHAR(36) PRIMARY KEY DEFAULT UUID(),
    Name VARCHAR(100) NOT NULL,
    Address VARCHAR(100) NOT NULL
) ENGINE = InnoDB;

CREATE INDEX userNameIndex ON `User`(Id);


-- Table Author

CREATE TABLE Author (
    Id CHAR(36) PRIMARY KEY DEFAULT UUID(),
    Name VARCHAR(100) NOT NULL,
    Birthdate date NOT NULL,
    FULLTEXT(Name)
) ENGINE = InnoDB;

CREATE INDEX authorIdIndex ON Author(Id);


-- Table Book

CREATE TABLE Book (
    Id CHAR(36) PRIMARY KEY DEFAULT UUID(),
    ISBN CHAR(17) UNIQUE NOT NULL,
    CHECK(ISBN REGEXP'^(978|979)-[0-9]{1,5}-[0-9]{1,7}-[0-9]{1,7}-[0-9]$'),
    Title VARCHAR(100) NOT NULL,
    AuthorId VARCHAR(100) NOT NULL,
    FOREIGN KEY (AuthorId) REFERENCES Author(Id) ON UPDATE CASCADE ON DELETE CASCADE,
    FULLTEXT(Title)
) ENGINE = InnoDB;

CREATE INDEX bookTitleIndex ON Book(Title);
CREATE INDEX bookAuthorIdIndex ON Book(AuthorId);


-- Table Stock

CREATE TABLE Stock (
    BookId CHAR(36) PRIMARY KEY,
    Stock INT NOT NULL,
    CHECK(Stock >= 0 AND Stock <= InitialStock),
    InitialStock INT NOT NULL,
    FOREIGN KEY (BookId) REFERENCES Book(Id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB;


-- Table Reservation

CREATE TABLE Reservation (
    BookId CHAR(36) NOT NULL,
    UserId CHAR(36) NOT NULL,
    ReserveDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY(BookId, UserId),
    FOREIGN KEY (BookId) REFERENCES Book(Id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (UserId) REFERENCES `User`(Id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE INDEX reservationBookIdIndex ON Reservation(BookId);
CREATE INDEX reservationUserIdIndex ON Reservation(UserId);


-- Table Loan

CREATE TABLE Loan (
    Id CHAR(36) PRIMARY KEY DEFAULT UUID(),
    LoanDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ReturnDate TIMESTAMP NULL,
    BookId CHAR(36) NOT NULL,
    UserId CHAR(36) NOT NULL,
    FOREIGN KEY (UserId) REFERENCES `User`(Id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (BookId) REFERENCES Book(Id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE INDEX loanLoanDateIndex ON Loan(LoanDate);
CREATE INDEX loanUserIdIndex ON Loan(UserId);
CREATE INDEX loanBookIdIndex ON Loan(BookId);