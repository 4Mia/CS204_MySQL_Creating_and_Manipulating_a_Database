/* Write the SQL statements in order to create the tables for the database. 
Use the Entity Relationship Diagram (ERD) of the database shown in Figure 1. 
For simplicity, we are assuming in this project that a book cannot be written 
by more than one author. You need to create the tables as well as the required 
constraints, including the keys (primary & foreign), & the relationships between tables. */

-- Ensure no library database pre exists
DROP DATABASE IF EXISTS library;
-- Create library database
CREATE DATABASE library;
-- Specify database to command all subsequent SQL statements
USE library;
-- Create Author Table
CREATE TABLE Author (
    AuthorID INT PRIMARY KEY AUTO_INCREMENT,
    AuthorFirstName VARCHAR(50) NOT NULL,
    AuthorLastName VARCHAR(50) NOT NULL,
    AuthorNationality VARCHAR(50) NOT NULL
);
-- Create Book Table
CREATE TABLE Book (
    BookID INT PRIMARY KEY AUTO_INCREMENT,
    BookTitle VARCHAR(100) NOT NULL,
    Genre VARCHAR(50) NOT NULL,
    AuthorID INT,
    FOREIGN KEY (AuthorID) REFERENCES Author(AuthorID)
);
-- Create Client Table
CREATE TABLE Client (
    ClientID INT PRIMARY KEY AUTO_INCREMENT,
    ClientFirstName VARCHAR(50) NOT NULL,
    ClientLastName VARCHAR(50) NOT NULL,
    ClientDOB YEAR NOT NULL,
    Occupation VARCHAR(50) NOT NULL
);
-- Create Borrower Table
CREATE TABLE Borrower (
    BorrowerID INT PRIMARY KEY AUTO_INCREMENT,
    ClientID INT,
    BookID INT,
    BorrowDate DATE NOT NULL,
    FOREIGN KEY (BookID) REFERENCES Book(BookID),
    FOREIGN KEY (ClientID) REFERENCES Client(ClientID)
);