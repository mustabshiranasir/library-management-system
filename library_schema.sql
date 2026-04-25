-- ============================================================
--  LIBRARY MANAGEMENT SYSTEM — DATABASE SCHEMA
--  COMSATS University Islamabad, Attock Campus
--  Course: Database System (Lab) | Instructor: Mr. Shahzad Rizwan
-- ============================================================

CREATE DATABASE IF NOT EXISTS LibraryDB;
USE LibraryDB;

-- ─────────────────────────────────────────────────────────────
-- 1. BOOKS
-- ─────────────────────────────────────────────────────────────
CREATE TABLE Books (
    Book_ID     INT PRIMARY KEY AUTO_INCREMENT,
    Title       VARCHAR(255)  NOT NULL,
    Edition     VARCHAR(50),
    ISBN        VARCHAR(20)   UNIQUE NOT NULL
);

CREATE TABLE Book_Authors (
    Book_ID     INT           NOT NULL,
    Author      VARCHAR(150)  NOT NULL,
    PRIMARY KEY (Book_ID, Author),
    FOREIGN KEY (Book_ID) REFERENCES Books(Book_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Book_Categories (
    Book_ID     INT           NOT NULL,
    Category    VARCHAR(100)  NOT NULL,
    PRIMARY KEY (Book_ID, Category),
    FOREIGN KEY (Book_ID) REFERENCES Books(Book_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ─────────────────────────────────────────────────────────────
-- 2. PUBLISHERS
-- ─────────────────────────────────────────────────────────────
CREATE TABLE Publishers (
    Publisher_ID    INT          PRIMARY KEY AUTO_INCREMENT,
    Name            VARCHAR(150) NOT NULL,
    Address         VARCHAR(255),
    Contact_Number  VARCHAR(20)
);

CREATE TABLE Book_Publishers (
    Book_ID         INT NOT NULL,
    Publisher_ID    INT NOT NULL,
    PRIMARY KEY (Book_ID, Publisher_ID),
    FOREIGN KEY (Book_ID)      REFERENCES Books(Book_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (Publisher_ID) REFERENCES Publishers(Publisher_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ─────────────────────────────────────────────────────────────
-- 3. MEMBERS
-- ─────────────────────────────────────────────────────────────
CREATE TABLE Members (
    Member_ID       INT          PRIMARY KEY AUTO_INCREMENT,
    Name            VARCHAR(150) NOT NULL,
    Membership_Type ENUM('Student','Faculty','Staff','Guest') NOT NULL DEFAULT 'Student'
);

CREATE TABLE Member_Contacts (
    Member_ID    INT          NOT NULL,
    Phone_Number VARCHAR(20)  NOT NULL,
    PRIMARY KEY (Member_ID, Phone_Number),
    FOREIGN KEY (Member_ID) REFERENCES Members(Member_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Member_Address (
    Member_ID   INT          NOT NULL,
    Address     VARCHAR(255) NOT NULL,
    PRIMARY KEY (Member_ID),
    FOREIGN KEY (Member_ID) REFERENCES Members(Member_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ─────────────────────────────────────────────────────────────
-- 4. STAFF
-- ─────────────────────────────────────────────────────────────
CREATE TABLE Staff (
    Staff_ID    INT          PRIMARY KEY AUTO_INCREMENT,
    Name        VARCHAR(150) NOT NULL,
    Role        VARCHAR(100) NOT NULL
);

CREATE TABLE Staff_Contacts (
    Staff_ID     INT         NOT NULL,
    Phone_Number VARCHAR(20) NOT NULL,
    PRIMARY KEY (Staff_ID, Phone_Number),
    FOREIGN KEY (Staff_ID) REFERENCES Staff(Staff_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Staff_Address (
    Staff_ID    INT          NOT NULL,
    Address     VARCHAR(255) NOT NULL,
    PRIMARY KEY (Staff_ID),
    FOREIGN KEY (Staff_ID) REFERENCES Staff(Staff_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Staff_Sections (
    Staff_ID         INT          NOT NULL,
    Assigned_Section VARCHAR(100) NOT NULL,
    PRIMARY KEY (Staff_ID, Assigned_Section),
    FOREIGN KEY (Staff_ID) REFERENCES Staff(Staff_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ─────────────────────────────────────────────────────────────
-- 5. LOANS
-- ─────────────────────────────────────────────────────────────
CREATE TABLE Loans (
    Loan_ID        INT  PRIMARY KEY AUTO_INCREMENT,
    Member_ID      INT  NOT NULL,
    Issued_Book_ID INT  NOT NULL,
    Issue_Date     DATE NOT NULL,
    Due_Date       DATE NOT NULL,
    Return_Date    DATE DEFAULT NULL,
    FOREIGN KEY (Member_ID)      REFERENCES Members(Member_ID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (Issued_Book_ID) REFERENCES Books(Book_ID)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ─────────────────────────────────────────────────────────────
-- 6. INVENTORY
-- ─────────────────────────────────────────────────────────────
CREATE TABLE Inventory (
    Inventory_ID    INT          PRIMARY KEY AUTO_INCREMENT,
    Book_ID         INT          NOT NULL UNIQUE,
    Title           VARCHAR(255) NOT NULL,
    Shelf_Location  VARCHAR(50),
    Stock_Count     INT          NOT NULL DEFAULT 0 CHECK (Stock_Count >= 0),
    Total_Count     INT          NOT NULL DEFAULT 0 CHECK (Total_Count >= 0),
    FOREIGN KEY (Book_ID) REFERENCES Books(Book_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ─────────────────────────────────────────────────────────────
-- 7. FINES
-- ─────────────────────────────────────────────────────────────
CREATE TABLE Fines (
    Fine_ID         INT            PRIMARY KEY AUTO_INCREMENT,
    Member_ID       INT            NOT NULL,
    Overdue_Book_ID INT            NOT NULL,
    Overdue_Days    INT            NOT NULL CHECK (Overdue_Days > 0),
    Fine_Amount     DECIMAL(8,2)   NOT NULL CHECK (Fine_Amount >= 0),
    Payment_Status  ENUM('Paid','Unpaid') NOT NULL DEFAULT 'Unpaid',
    FOREIGN KEY (Member_ID)       REFERENCES Members(Member_ID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (Overdue_Book_ID) REFERENCES Books(Book_ID)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ─────────────────────────────────────────────────────────────
-- 8. REQUESTS
-- ─────────────────────────────────────────────────────────────
CREATE TABLE Requests (
    Request_ID         INT  PRIMARY KEY AUTO_INCREMENT,
    Member_ID          INT  NOT NULL,
    Requested_Book_ID  INT  NOT NULL,
    Request_Date       DATE NOT NULL DEFAULT (CURRENT_DATE),
    Request_Status     ENUM('Pending','Approved','Rejected','Fulfilled') NOT NULL DEFAULT 'Pending',
    FOREIGN KEY (Member_ID)         REFERENCES Members(Member_ID)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (Requested_Book_ID) REFERENCES Books(Book_ID)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ─────────────────────────────────────────────────────────────
-- INDEXES (for frequently queried columns)
-- ─────────────────────────────────────────────────────────────
CREATE INDEX idx_books_title      ON Books(Title);
CREATE INDEX idx_loans_member     ON Loans(Member_ID);
CREATE INDEX idx_loans_book       ON Loans(Issued_Book_ID);
CREATE INDEX idx_fines_member     ON Fines(Member_ID);
CREATE INDEX idx_requests_member  ON Requests(Member_ID);
CREATE INDEX idx_requests_status  ON Requests(Request_Status);
