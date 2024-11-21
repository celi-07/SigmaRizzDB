USE library;

CREATE ROLE IF NOT EXISTS 'admin';
CREATE ROLE IF NOT EXISTS 'librarian';
CREATE ROLE IF NOT EXISTS 'reader';

GRANT ALL PRIVILEGES ON library.* TO 'admin';

GRANT ALL PRIVILEGES ON library.Author TO 'librarian';
GRANT ALL PRIVILEGES ON library.Book TO 'librarian';
GRANT SELECT, UPDATE, DELETE ON library.Loan TO 'librarian';

GRANT ALL PRIVILEGES ON library.User TO 'reader';
GRANT SELECT, INSERT, DELETE ON library.Reservation TO 'reader';
GRANT SELECT, INSERT ON library.Loan TO 'reader';