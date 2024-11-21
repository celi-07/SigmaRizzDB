USE library;

DELIMITER $$


-- Adding data

CREATE PROCEDURE addBook (
    IN book_title VARCHAR(100),
    IN book_authorId CHAR(36),
    IN book_ISBN CHAR(17),
    IN book_stock INT
)
BEGIN
    DECLARE book_id CHAR(36);

    START TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM Author WHERE Id = book_authorId) THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Failed [1]: No Matching Author Id Found';
    ELSEIF book_stock < 1 OR NOT(book_stock REGEXP '^[0-9]+$') THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Failed [2]: Invalid Book Stock';
    ELSEIF NOT(book_ISBN REGEXP'^(978|979)-[0-9]{1,5}-[0-9]{1,7}-[0-9]{1,7}-[0-9]$') THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Failed [3]: ISBN is Not Valid';
    ELSEIF LEN(book_ISBN) != 17 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Failed [4]: ISBN length should be 17 characters';
    ELSE
        INSERT INTO Book(Title, ISBN, AuthorId)
        VALUES(book_title, book_ISBN, book_authorId);

        SELECT Id INTO book_id FROM book WHERE ISBN = book_ISBN;

        INSERT INTO STOCK(BookId, Stock, InitialStock)
        VALUES(book_id, book_stock, book_stock);

        COMMIT;
    END IF; 
END $$

CREATE PROCEDURE addUser (
    IN user_name VARCHAR(100),
    IN user_address VARCHAR(100)
)
BEGIN
    START TRANSACTION;

    INSERT INTO `User`(Name, Address)
    VALUES(user_name, user_address);

    COMMIT;
END $$

CREATE PROCEDURE addAuthor (
    IN author_name VARCHAR(100),
    IN author_birthdate DATE
)
BEGIN
    START TRANSACTION;

    INSERT INTO Author(Name, Birthdate)
    VALUES(author_name, author_birthdate);

    COMMIT;
END $$


-- Borrow Book

CREATE PROCEDURE borrowBook (
    IN book_id CHAR(38),
    IN user_id CHAR(38)
)
BEGIN
    DECLARE curr_stock INT;

    START TRANSACTION;

    SELECT Stock INTO curr_stock FROM Stock WHERE BookId = book_id;

    IF NOT EXISTS (SELECT 1 FROM Book WHERE Id = book_id) THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Failed [5]: Book Not Found';
    ELSEIF NOT EXISTS (SELECT 1 FROM `User` WHERE Id = user_id) THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Failed [6]: User Not Found';
    ELSEIF EXISTS (SELECT 1 FROM Loan WHERE BookId = book_id AND UserId = user_id AND ReturnDate IS NULL) THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Failed [7]: Book has not been Returned';
    ELSEIF curr_stock > 0 THEN 
        INSERT INTO Loan(ReturnDate, BookId, UserId)
        VALUES(NULL, book_id, user_id);

        COMMIT;
    ELSE
        INSERT INTO Reservation(BookId, UserId)
        VALUES(book_id, user_id);

        COMMIT; 
    END IF;
END $$


-- Trigger to automatically reduce stock for every loan insert

CREATE TRIGGER onInsertLoan
    AFTER INSERT
    ON Loan
    FOR EACH ROW
BEGIN
    UPDATE Stock
    SET Stock = Stock - 1
    WHERE BookId = NEW.bookId;
END $$

-- Return Book

CREATE PROCEDURE returnBook (
    IN book_id CHAR(38),
    IN user_id CHAR(38)
)
BEGIN
    DECLARE curr_stock INT;
    DECLARE reserve_user CHAR(36);

    START TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM Book WHERE Id = book_id) THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Failed [5]: Book Not Found';
    ELSEIF NOT EXISTS (SELECT 1 FROM `User` WHERE Id = user_id) THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Failed [6]: User Not Found';
    ELSEIF EXISTS (SELECT 1 FROM Loan WHERE BookId = book_id AND UserId = user_id AND ReturnDate IS NULL) THEN 
        UPDATE Stock
        SET Stock = Stock + 1
        WHERE BookId = book_id;

        UPDATE Loan
        SET ReturnDate = NOW()
        WHERE BookId = book_id AND UserId = user_id AND ReturnDate IS NULL;

        SELECT Stock INTO curr_stock FROM Stock WHERE BookId = book_id; 

        IF EXISTS (SELECT 1 FROM Reservation) THEN 
            SELECT UserId INTO reserve_user FROM Reservation ORDER BY ReserveDate LIMIT 1;
            DELETE FROM Reservation WHERE BookId = book_id AND UserId = reserve_user;

            INSERT INTO Loan(BookId, UserId) 
            VALUES(book_id, user_id);
        END IF;

        COMMIT;
    ELSE
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Failed [8]: No Loan With the Following User and Book'; 
    END IF;
END $$


-- Delete User

CREATE PROCEDURE deleteUser(
    IN user_id CHAR(36)
)
BEGIN
    START TRANSACTION;

    IF EXISTS (SELECT 1 FROM Loan WHERE UserId = user_id AND ReturnDate IS NULL) THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Failed [9]: User Still Have Existing Loan(s)';
    ELSEIF EXISTS (SELECT 1 FROM Reservation WHERE UserId = user_id) THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Failed [10]: User Still Have Existing Reservation(s)';
    ELSEIF NOT EXISTS (SELECT 1 FROM `User` WHERE Id = user_id) THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Failed [6]: User Not Found';
    ELSE 
        DELETE FROM `User` WHERE Id = user_id;
        COMMIT;
    END IF;
END $$


-- Searching for Book

CREATE PROCEDURE searchBook(
    IN searchQuery VARCHAR(100)
)
BEGIN
    SELECT Book.Title AS 'Book Title', Author.Name AS 'Author Name'
    FROM Book
    JOIN Author ON Author.Id = Book.AuthorId
    WHERE 
        Book.Title LIKE CONCAT(searchQuery, '%')
        OR Author.Name LIKE CONCAT(searchQuery, '%')
        OR MATCH (Book.Title) AGAINST (searchQuery IN BOOLEAN MODE) 
        OR MATCH (Author.Name) AGAINST (searchQuery IN BOOLEAN MODE)
    ORDER BY
        CASE
            WHEN Book.Title LIKE CONCAT(searchQuery, '%') THEN 1
            WHEN Author.Name LIKE CONCAT(searchQuery, '%') THEN 2
            WHEN MATCH (Book.Title) AGAINST (searchQuery IN BOOLEAN MODE) THEN 3
            WHEN MATCH (Author.Name) AGAINST (searchQuery IN BOOLEAN MODE) THEN 4
            ELSE 5
        END,
        Book.Title;
END $$

DELIMITER ;
