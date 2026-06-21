-- ============================================================
--  LIBRARY MANAGEMENT SYSTEM — SAMPLE DATA
-- ============================================================

USE LibraryDB;

-- ─────────────────────────────────────────────────────────────
-- BOOKS
-- ─────────────────────────────────────────────────────────────
INSERT INTO Books (Book_ID, Title, Edition, ISBN) VALUES
(101, 'Data Structures',          '3rd', '978-123456789'),
(102, 'Database Systems',         '7th', '978-987654321'),
(103, 'Algorithms',               '5th', '978-135794680'),
(104, 'Operating Systems',        '4th', '978-246813579'),
(105, 'Computer Networks',        '6th', '978-369258147'),
(106, 'Artificial Intelligence',  '2nd', '978-112233445'),
(107, 'Software Engineering',     '9th', '978-998877665'),
(108, 'Discrete Mathematics',     '1st', '978-334455667'),
(109, 'Linear Algebra',           '3rd', '978-556677889'),
(110, 'Calculus',                 '8th', '978-778899001');

-- ─────────────────────────────────────────────────────────────
-- BOOK AUTHORS
-- ─────────────────────────────────────────────────────────────
INSERT INTO Book_Authors VALUES
(101, 'Ellis Horowitz'),
(101, 'Sartaj Sahni'),
(102, 'C.J. Date'),
(102, 'A. Kannan'),
(103, 'Thomas H. Cormen'),
(103, 'Charles E. Leiserson'),
(104, 'Abraham Silberschatz'),
(105, 'Andrew Tanenbaum'),
(106, 'Stuart Russell'),
(106, 'Peter Norvig'),
(107, 'Ian Sommerville'),
(108, 'Kenneth H. Rosen'),
(109, 'Gilbert Strang'),
(110, 'James Stewart');

-- ─────────────────────────────────────────────────────────────
-- BOOK CATEGORIES
-- ─────────────────────────────────────────────────────────────
INSERT INTO Book_Categories VALUES
(101, 'Programming'), (101, 'Computer Science'),
(102, 'DBMS'),        (102, 'Computer Science'),
(103, 'Algorithms'),  (103, 'Computer Science'),
(104, 'Systems'),     (104, 'Computer Science'),
(105, 'Networking'),  (105, 'Computer Science'),
(106, 'AI'),          (106, 'Computer Science'),
(107, 'Engineering'), (107, 'Software'),
(108, 'Mathematics'), (108, 'Discrete Math'),
(109, 'Mathematics'), (109, 'Algebra'),
(110, 'Mathematics'), (110, 'Calculus');

-- ─────────────────────────────────────────────────────────────
-- PUBLISHERS
-- ─────────────────────────────────────────────────────────────
INSERT INTO Publishers (Publisher_ID, Name, Address, Contact_Number) VALUES
(1, 'Pearson',       '10 Tech Road, New York',       '555-7890'),
(2, 'McGraw Hill',   '22 Education St, Chicago',     '555-8901'),
(3, 'Prentice Hall', '5 Knowledge Ave, Boston',      '555-2233'),
(4, 'MIT Press',     '77 Mass Ave, Cambridge MA',    '555-4455'),
(5, 'Wiley',         '111 River St, Hoboken NJ',     '555-6677');

INSERT INTO Book_Publishers VALUES
(101, 1), (102, 2), (103, 4),
(104, 3), (105, 3), (106, 4),
(107, 5), (108, 1), (109, 4), (110, 5);

-- ─────────────────────────────────────────────────────────────
-- MEMBERS
-- ─────────────────────────────────────────────────────────────
INSERT INTO Members (Member_ID, Name, Membership_Type) VALUES
(1, 'John Doe',       'Student'),
(2, 'Jane Smith',     'Faculty'),
(3, 'Ali Hassan',     'Student'),
(4, 'Sara Ahmed',     'Student'),
(5, 'Dr. Malik',      'Faculty'),
(6, 'Usman Tariq',    'Staff'),
(7, 'Ayesha Khan',    'Student'),
(8, 'Bilal Chaudhry', 'Student');

INSERT INTO Member_Contacts VALUES
(1, '555-1234'), (1, '555-5678'),
(2, '555-9876'),
(3, '555-1111'),
(4, '555-2222'),
(5, '555-3333'), (5, '555-4444'),
(6, '555-5555'),
(7, '555-6666'),
(8, '555-7777');

INSERT INTO Member_Address VALUES
(1, '123 Elm Street'),
(2, '456 Maple Avenue'),
(3, '789 Oak Lane'),
(4, '12 Pine Road'),
(5, '34 Cedar Blvd'),
(6, '56 Walnut Drive'),
(7, '78 Birch Court'),
(8, '90 Spruce Terrace');

-- ─────────────────────────────────────────────────────────────
-- STAFF
-- ─────────────────────────────────────────────────────────────
INSERT INTO Staff (Staff_ID, Name, Role) VALUES
(1, 'Alice Johnson', 'Librarian'),
(2, 'Bob Brown',     'Assistant'),
(3, 'Carol White',   'Cataloger'),
(4, 'David Lee',     'Security');

INSERT INTO Staff_Contacts VALUES
(1, '555-2345'),
(2, '555-3456'), (2, '555-6789'),
(3, '555-9012'),
(4, '555-3210');

INSERT INTO Staff_Address VALUES
(1, '12 Green Lane'),
(2, '34 Blue Street'),
(3, '56 Red Avenue'),
(4, '78 Yellow Road');

INSERT INTO Staff_Sections VALUES
(1, 'Fiction'), (1, 'Science'),
(2, 'Technology'), (2, 'Reference'),
(3, 'Cataloging'), (3, 'Archives'),
(4, 'Entrance'), (4, 'Main Hall');

-- ─────────────────────────────────────────────────────────────
-- INVENTORY
-- ─────────────────────────────────────────────────────────────
INSERT INTO Inventory (Book_ID, Title, Shelf_Location, Stock_Count, Total_Count) VALUES
(101, 'Data Structures',         'A-1-10', 5, 10),
(102, 'Database Systems',        'B-2-20', 3,  8),
(103, 'Algorithms',              'A-2-05', 6, 12),
(104, 'Operating Systems',       'C-1-15', 4,  7),
(105, 'Computer Networks',       'C-2-10', 2,  5),
(106, 'Artificial Intelligence', 'D-1-08', 7, 10),
(107, 'Software Engineering',    'D-2-12', 3,  6),
(108, 'Discrete Mathematics',    'E-1-03', 8, 15),
(109, 'Linear Algebra',          'E-2-07', 5,  9),
(110, 'Calculus',                'F-1-20', 4, 11);

-- ─────────────────────────────────────────────────────────────
-- LOANS
-- ─────────────────────────────────────────────────────────────
INSERT INTO Loans (Member_ID, Issued_Book_ID, Issue_Date, Due_Date, Return_Date) VALUES
(1, 101, '2024-12-01', '2024-12-15', NULL),
(1, 102, '2024-12-03', '2024-12-17', NULL),
(2, 103, '2024-12-05', '2024-12-20', NULL),
(3, 104, '2024-12-02', '2024-12-16', '2024-12-14'),
(4, 105, '2024-12-10', '2024-12-24', NULL),
(5, 106, '2024-11-25', '2024-12-09', '2024-12-08'),
(7, 108, '2024-12-07', '2024-12-21', NULL),
(8, 109, '2024-12-08', '2024-12-22', NULL);

-- ─────────────────────────────────────────────────────────────
-- FINES
-- ─────────────────────────────────────────────────────────────
INSERT INTO Fines (Member_ID, Overdue_Book_ID, Overdue_Days, Fine_Amount, Payment_Status) VALUES
(1, 101,  5, 10.00, 'Unpaid'),
(1, 102,  3, 10.00, 'Unpaid'),
(2, 103,  7,  7.00, 'Paid'),
(4, 105,  2,  4.00, 'Unpaid'),
(8, 109,  4,  8.00, 'Unpaid');

-- ─────────────────────────────────────────────────────────────
-- REQUESTS
-- ─────────────────────────────────────────────────────────────
INSERT INTO Requests (Member_ID, Requested_Book_ID, Request_Date, Request_Status) VALUES
(1, 106, '2024-12-05', 'Pending'),
(1, 107, '2024-12-05', 'Pending'),
(2, 110, '2024-12-06', 'Approved'),
(3, 108, '2024-12-07', 'Fulfilled'),
(4, 109, '2024-12-08', 'Pending'),
(7, 103, '2024-12-09', 'Approved'),
(8, 101, '2024-12-10', 'Pending');
