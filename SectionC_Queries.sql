-- Create indexes to improve query performance
CREATE INDEX idx_borrower_clientid ON Borrower (ClientID);
CREATE INDEX idx_borrower_bookid ON Borrower (BookID);
CREATE INDEX idx_book_authorid ON Book (AuthorID);

-- 1. Display all contents of the Clients table
/*Pulls all (*) rows and columns from the Client table */
SELECT * FROM Client;

-- 2. First names, last names, ages and occupations of all clients
/* YEAR(CURDATE()) - ClientDOB calculates the age of the client and returns the column name as Age */
SELECT ClientFirstName, ClientLastName, YEAR(CURDATE()) - ClientDOB AS Age, Occupation 
FROM Client;

-- 3. First and last names of clients that borrowed books in March 2018
/* Inner join is used to combine the Client and Borrower tables where the ClientID is the same in both tables. 
MONTH(BorrowDate) = 3 AND YEAR(BorrowDate) = 2018 filters the results to only include rows where the BorrowDate is in March 2018 */
SELECT ClientFirstName, ClientLastName
FROM Client
INNER JOIN Borrower
ON Client.ClientID = Borrower.ClientID
WHERE MONTH(BorrowDate) = 3 AND YEAR(BorrowDate) = 2018;

-- 4. First and last names of the top 5 authors clients borrowed in 2017
/* Inner join is used to combine the Author, Book, and Borrower tables where the AuthorID is the same in the Author and Book tables 
and the BookID is the same in the Book and Borrower tables. Moreover, a Where clause is used to filter borrow date to only 2017 while
grouping results by Author First and Last Name and sorting the results by the total count per Author in descending order, limiting the top 5 results */
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
/* Inner join is used to combine the Author, Book, and Borrower tables where the AuthorID is the same in the Author and Book tables
and the BookID is the same in the Book and Borrower tables. Moreover, a Where clause is used to filter borrow date between 2015-2017 while
grouping by Authornationality and ordering by count of rows in ascending order limiting to the top 5 results */
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
/* Inner join is used to combine the Book and Borrower tables where the BookID is the same in both tables.
Moreover, a Where clause is used to filter borrow date between 2015-2017 while grouping by BookTitle and ordering
 by count of rows in descending order limiting to the top 1 result */
SELECT BookTitle
FROM Book
INNER JOIN Borrower
ON Book.BookID = Borrower.BookID
WHERE YEAR(BorrowDate) BETWEEN 2015 AND 2017
GROUP BY BookTitle
ORDER BY COUNT(*) DESC
LIMIT 1;

-- 7. Top borrowed genres for client born in years 1970-1980
/* Inner join is used to combine the Book, Borrower, and Client tables where the BookID is the same in the Book and Borrower tables
and the ClientID is the same in the Borrower and Client tables. Moreover, a Where clause is used to filter client date of birth between 1970-1980 while grouping
by Genre and ordering by count of rows in descending order */
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
/* Inner join is used to combine the Client and Borrower tables where the ClientID is the same in both tables.
Moreover, a Where clause is used to filter borrow date to only 2016 while grouping by Occupation and ordering by count of rows in descending order
limiting the top 5 results */
SELECT Occupation
FROM Client
INNER JOIN Borrower
ON Client.ClientID = Borrower.ClientID
WHERE YEAR(BorrowDate) = 2016
GROUP BY Occupation
ORDER BY COUNT(*) DESC
LIMIT 5;

-- 9. Average number of borrowed books by job title
/* Inner join is used to combine the Client and Borrower tables where the ClientID is the same in both tables.
Moreover, a subquery is used to group by Occupation and ClientID to calculate the count of books borrowed by each client.
The outer query then groups by Occupation and calculates the average number of borrowed books per occupation */
SELECT Occupation, AVG(BorrowCount) AS AverageBorrowedBooks
FROM (
    SELECT Occupation, Client.ClientID, COUNT(*) AS BorrowCount
    FROM Client
    INNER JOIN Borrower ON Client.ClientID = Borrower.ClientID
    GROUP BY Occupation, Client.ClientID
) AS OccupationCounts
GROUP BY Occupation;

-- 10. Create a VIEW and display the titles that were borrowed by at least 20% of clients
/* A view is created to store the results of the query that retrieves the BookTitle and the count of Borrower.BookID.
The query then joins the Borrower and Book tables on the BookID, groups by BookTitle, and filters the results to only include
books that were borrowed by at least 20% of clients. */
CREATE VIEW BBB20POC AS -- To test, code SELECT * FROM BBB20POC;
SELECT BookTitle, COUNT(Borrower.BookID) AS BorrowedTimes
FROM Borrower
INNER JOIN Book ON Borrower.BookID = Book.BookID
GROUP BY BookTitle
HAVING COUNT(Borrower.BookID) >= (0.2 * (SELECT COUNT(DISTINCT ClientID) FROM Borrower)
);

-- 11. The top month of borrows in 2017
/* A query is used to select the month and count of borrowers from the Borrower table where the borrow date is in 2017.
The results are then grouped by month, ordered by the count of borrowers in descending order, and limited to the top 5 results. */
SELECT MONTH(BorrowDate) AS Month, COUNT(BorrowerID) AS BorrowCount
FROM Borrower
WHERE YEAR(BorrowDate) = 2017
GROUP BY MONTH(BorrowDate)
ORDER BY COUNT(BorrowerID) DESC
LIMIT 5;

-- 12. Average number of borrows by age
/* A subquery is used to calculate the age of each client and the count of books borrowed by each client.
The outer query then groups by age and calculates the average number of borrowed books per age group. */
SELECT Age, AVG(BorrowCount) AS AverageBorrowedBooks
FROM (
    SELECT YEAR(CURDATE()) - ClientDOB AS Age, Client.ClientID, COUNT(*) AS BorrowCount
    FROM Client
    INNER JOIN Borrower ON Client.ClientID = Borrower.ClientID
    GROUP BY Age, Client.ClientID
) AS AgeCounts
GROUP BY Age;

-- 13. The oldest and the youngest clients of the library
/* Two queries are used to find the youngest and oldest clients by calculating the age of each client and ordering the results accordingly. */
SELECT ClientFirstName, ClientLastName, YEAR(CURDATE()) - ClientDOB AS AgeOfYoungestClient
FROM Client
ORDER BY AgeOfYoungestClient ASC
LIMIT 1;

SELECT ClientFirstName, ClientLastName, YEAR(CURDATE()) - ClientDOB AS AgeOfOldestClient
FROM Client
ORDER BY AgeOfOldestClient DESC
LIMIT 1;

-- 14. First and last names of authors that wrote books in more than one genre
/* Inner join is used to combine the Author and Book tables where the AuthorID is the same in both tables.
The query then groups by AuthorFirstName and AuthorLastName, calculates the count of distinct genres for each author,
and filters the results to only include authors who wrote books in more than one genre. */
SELECT AuthorFirstName, AuthorLastName, COUNT(DISTINCT Genre) AS GenreCount
FROM Author
INNER JOIN Book
ON Author.AuthorID = Book.AuthorID
GROUP BY AuthorFirstName, AuthorLastName
HAVING COUNT(DISTINCT Genre) > 1;