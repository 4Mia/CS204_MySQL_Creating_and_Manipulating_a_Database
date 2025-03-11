-- Create indexes to improve query performance
CREATE INDEX idx_borrower_clientid ON Borrower (ClientID);
CREATE INDEX idx_borrower_bookid ON Borrower (BookID);
CREATE INDEX idx_book_authorid ON Book (AuthorID);

-- 1. Display all contents of the Clients table
SELECT * FROM Client;

-- 2. First names, last names, ages and occupations of all clients
SELECT ClientFirstName, ClientLastName, YEAR(CURDATE()) - ClientDOB AS Age, Occupation 
FROM Client;

-- 3. First and last names of clients that borrowed books in March 2018
SELECT ClientFirstName, ClientLastName
FROM Client
INNER JOIN Borrower
ON Client.ClientID = Borrower.ClientID
WHERE MONTH(BorrowDate) = 3 AND YEAR(BorrowDate) = 2018;

-- 4. First and last names of the top 5 authors clients borrowed in 2017
SELECT AuthorFirstName, AuthorLastName
FROM Author
INNER JOIN Book
ON Author.AuthorID = Book.AuthorID
INNER JOIN Borrower
ON Book.BookID = Borrower.BookID
WHERE YEAR(BorrowDate) = 2017
GROUP BY AuthorFirstName, AuthorLastName
ORDER BY COUNT(*) DESC
LIMIT 5;

-- 5. Nationalities of the least 5 authors that clients borrowed during the years 2015-2017
SELECT AuthorNationality
FROM Author
INNER JOIN Book
ON Author.AuthorID = Book.AuthorID
INNER JOIN Borrower
ON Book.BookID = Borrower.BookID
WHERE YEAR(BorrowDate) BETWEEN 2015 AND 2017
GROUP BY AuthorNationality
ORDER BY Count(*)
LIMIT 5;

-- 6. The book that was most borrowed during the years 2015-2017
SELECT BookTitle
FROM Book
INNER JOIN Borrower
ON Book.BookID = Borrower.BookID
WHERE YEAR(BorrowDate) BETWEEN 2015 AND 2017
GROUP BY BookTitle
ORDER BY COUNT(*) DESC
LIMIT 1;

-- 7. Top borrowed genres for client born in years 1970-1980
SELECT Genre
FROM Book
INNER JOIN Borrower
ON Book.BookID = Borrower.BookID
INNER JOIN Client
ON Borrower.ClientID = Client.ClientID
WHERE ClientDOB BETWEEN 1970 AND 1980
GROUP BY Genre
ORDER BY COUNT(*) DESC;

-- 8. Top 5 occupations that borrowed the most in 2016
SELECT Occupation
FROM Client
INNER JOIN Borrower
ON Client.ClientID = Borrower.ClientID
WHERE YEAR(BorrowDate) = 2016
GROUP BY Occupation
ORDER BY COUNT(*) DESC
LIMIT 5;

-- 9. Average number of borrowed books by job title
SELECT Occupation, AVG(BorrowCount) AS AverageBorrowedBooks
FROM (
    SELECT Occupation, Client.ClientID, COUNT(*) AS BorrowCount
    FROM Client
    INNER JOIN Borrower ON Client.ClientID = Borrower.ClientID
    GROUP BY Occupation, Client.ClientID
) AS OccupationCounts
GROUP BY Occupation;

-- 10. Create a VIEW and display the titles that were borrowed by at least 20% of clients
CREATE VIEW BBB20POC AS -- To test, code SELECT * FROM BBB20POC;
SELECT BookTitle, COUNT(Borrower.BookID) AS BorrowedTimes
FROM Borrower
INNER JOIN Book ON Borrower.BookID = Book.BookID
GROUP BY BookTitle
HAVING COUNT(Borrower.BookID) >= (0.2 * (SELECT COUNT(DISTINCT ClientID) FROM Borrower)
);

-- 11. The top month of borrows in 2017
SELECT MONTH(BorrowDate) AS Month, COUNT(BorrowerID) AS BorrowCount
FROM Borrower
WHERE YEAR(BorrowDate) = 2017
GROUP BY MONTH(BorrowDate)
ORDER BY COUNT(BorrowerID) DESC
LIMIT 5;

-- 12. Average number of borrows by age
SELECT Age, AVG(BorrowCount) AS AverageBorrowedBooks
FROM (
    SELECT YEAR(CURDATE()) - ClientDOB AS Age, Client.ClientID, COUNT(*) AS BorrowCount
    FROM Client
    INNER JOIN Borrower ON Client.ClientID = Borrower.ClientID
    GROUP BY Age, Client.ClientID
) AS AgeCounts
GROUP BY Age;

-- 13. The oldest and the youngest clients of the library
SELECT ClientFirstName, ClientLastName, YEAR(CURDATE()) - ClientDOB AS AgeOfYoungestClient
FROM Client
ORDER BY AgeOfYoungestClient ASC
LIMIT 1;

SELECT ClientFirstName, ClientLastName, YEAR(CURDATE()) - ClientDOB AS AgeOfOldestClient
FROM Client
ORDER BY AgeOfOldestClient DESC
LIMIT 1;

-- 14. First and last names of authors that wrote books in more than one genre
SELECT AuthorFirstName, AuthorLastName, COUNT(DISTINCT Genre) AS GenreCount
FROM Author
INNER JOIN Book
ON Author.AuthorID = Book.AuthorID
GROUP BY AuthorFirstName, AuthorLastName
HAVING COUNT(DISTINCT Genre) > 1;

/* As you work on these queries, create indexes that will increase your queries' performance. */