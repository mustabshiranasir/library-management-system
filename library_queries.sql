-- ============================================================
--  LIBRARY MANAGEMENT SYSTEM — QUERIES
--  COMSATS University Islamabad, Attock Campus
-- ============================================================

USE LibraryDB;

-- ─────────────────────────────────────────────────────────────
-- SECTION 1: BOOKS QUERIES
-- ─────────────────────────────────────────────────────────────

-- Q1: List all books with their authors and categories
SELECT 
    b.Book_ID,
    b.Title,
    b.Edition,
    b.ISBN,
    GROUP_CONCAT(DISTINCT ba.Author     ORDER BY ba.Author     SEPARATOR ', ') AS Authors,
    GROUP_CONCAT(DISTINCT bc.Category   ORDER BY bc.Category   SEPARATOR ', ') AS Categories
FROM Books b
LEFT JOIN Book_Authors    ba ON b.Book_ID = ba.Book_ID
LEFT JOIN Book_Categories bc ON b.Book_ID = bc.Book_ID
GROUP BY b.Book_ID, b.Title, b.Edition, b.ISBN;

-- Q2: Find all books by a specific author
SELECT b.Book_ID, b.Title, b.Edition
FROM Books b
JOIN Book_Authors ba ON b.Book_ID = ba.Book_ID
WHERE ba.Author LIKE '%Cormen%';

-- Q3: Find all books in a specific category
SELECT b.Book_ID, b.Title, b.Edition
FROM Books b
JOIN Book_Categories bc ON b.Book_ID = bc.Book_ID
WHERE bc.Category = 'Computer Science';

-- Q4: Books with their publisher info
SELECT 
    b.Title,
    b.ISBN,
    p.Name AS Publisher,
    p.Contact_Number
FROM Books b
JOIN Book_Publishers bp ON b.Book_ID = bp.Book_ID
JOIN Publishers p ON bp.Publisher_ID = p.Publisher_ID
ORDER BY p.Name;

-- ─────────────────────────────────────────────────────────────
-- SECTION 2: MEMBER QUERIES
-- ─────────────────────────────────────────────────────────────

-- Q5: All members with their contact and address
SELECT 
    m.Member_ID,
    m.Name,
    m.Membership_Type,
    GROUP_CONCAT(mc.Phone_Number SEPARATOR ', ') AS Phone_Numbers,
    ma.Address
FROM Members m
LEFT JOIN Member_Contacts mc ON m.Member_ID = mc.Member_ID
LEFT JOIN Member_Address  ma ON m.Member_ID = ma.Member_ID
GROUP BY m.Member_ID, m.Name, m.Membership_Type, ma.Address;

-- Q6: Members who currently have books on loan (not returned)
SELECT DISTINCT 
    m.Member_ID,
    m.Name,
    m.Membership_Type
FROM Members m
JOIN Loans l ON m.Member_ID = l.Member_ID
WHERE l.Return_Date IS NULL;

-- Q7: Members with unpaid fines
SELECT 
    m.Name,
    m.Membership_Type,
    SUM(f.Fine_Amount) AS Total_Fine
FROM Members m
JOIN Fines f ON m.Member_ID = f.Member_ID
WHERE f.Payment_Status = 'Unpaid'
GROUP BY m.Member_ID, m.Name, m.Membership_Type
ORDER BY Total_Fine DESC;

-- ─────────────────────────────────────────────────────────────
-- SECTION 3: LOANS QUERIES
-- ─────────────────────────────────────────────────────────────

-- Q8: All active loans (books not yet returned)
SELECT 
    l.Loan_ID,
    m.Name AS Member_Name,
    m.Membership_Type,
    b.Title AS Book_Title,
    l.Issue_Date,
    l.Due_Date,
    DATEDIFF(CURDATE(), l.Due_Date) AS Days_Overdue
FROM Loans l
JOIN Members m ON l.Member_ID = m.Member_ID
JOIN Books   b ON l.Issued_Book_ID = b.Book_ID
WHERE l.Return_Date IS NULL
ORDER BY l.Due_Date;

-- Q9: Overdue loans (past due date and not returned)
SELECT 
    l.Loan_ID,
    m.Name AS Member_Name,
    b.Title,
    l.Due_Date,
    DATEDIFF(CURDATE(), l.Due_Date) AS Overdue_Days
FROM Loans l
JOIN Members m ON l.Member_ID = m.Member_ID
JOIN Books   b ON l.Issued_Book_ID = b.Book_ID
WHERE l.Return_Date IS NULL
  AND l.Due_Date < CURDATE()
ORDER BY Overdue_Days DESC;

-- Q10: Loan history for a specific member
SELECT 
    b.Title,
    l.Issue_Date,
    l.Due_Date,
    l.Return_Date,
    CASE WHEN l.Return_Date IS NULL THEN 'Active' ELSE 'Returned' END AS Status
FROM Loans l
JOIN Books b ON l.Issued_Book_ID = b.Book_ID
WHERE l.Member_ID = 1
ORDER BY l.Issue_Date DESC;

-- Q11: Total loans per member (ranking)
SELECT 
    m.Name,
    m.Membership_Type,
    COUNT(l.Loan_ID) AS Total_Loans
FROM Members m
LEFT JOIN Loans l ON m.Member_ID = l.Member_ID
GROUP BY m.Member_ID, m.Name, m.Membership_Type
ORDER BY Total_Loans DESC;

-- ─────────────────────────────────────────────────────────────
-- SECTION 4: INVENTORY QUERIES
-- ─────────────────────────────────────────────────────────────

-- Q12: Current inventory status with availability percentage
SELECT 
    i.Inventory_ID,
    b.Title,
    i.Shelf_Location,
    i.Stock_Count,
    i.Total_Count,
    ROUND((i.Stock_Count / i.Total_Count) * 100, 1) AS Availability_Pct
FROM Inventory i
JOIN Books b ON i.Book_ID = b.Book_ID
ORDER BY Availability_Pct ASC;

-- Q13: Books with low stock (less than 3 copies available)
SELECT 
    b.Title,
    i.Shelf_Location,
    i.Stock_Count,
    i.Total_Count
FROM Inventory i
JOIN Books b ON i.Book_ID = b.Book_ID
WHERE i.Stock_Count < 3
ORDER BY i.Stock_Count;

-- ─────────────────────────────────────────────────────────────
-- SECTION 5: FINES QUERIES
-- ─────────────────────────────────────────────────────────────

-- Q14: All fines with member and book details
SELECT 
    f.Fine_ID,
    m.Name AS Member,
    b.Title AS Overdue_Book,
    f.Overdue_Days,
    f.Fine_Amount,
    f.Payment_Status
FROM Fines f
JOIN Members m ON f.Member_ID = m.Member_ID
JOIN Books   b ON f.Overdue_Book_ID = b.Book_ID
ORDER BY f.Payment_Status, f.Fine_Amount DESC;

-- Q15: Total fines collected vs outstanding
SELECT 
    Payment_Status,
    COUNT(*)            AS Records,
    SUM(Fine_Amount)    AS Total_Amount
FROM Fines
GROUP BY Payment_Status;

-- ─────────────────────────────────────────────────────────────
-- SECTION 6: REQUESTS QUERIES
-- ─────────────────────────────────────────────────────────────

-- Q16: All pending requests with member and book details
SELECT 
    r.Request_ID,
    m.Name        AS Member,
    b.Title       AS Requested_Book,
    r.Request_Date,
    r.Request_Status
FROM Requests r
JOIN Members m ON r.Member_ID = m.Member_ID
JOIN Books   b ON r.Requested_Book_ID = b.Book_ID
WHERE r.Request_Status = 'Pending'
ORDER BY r.Request_Date;

-- Q17: Most requested books
SELECT 
    b.Title,
    COUNT(r.Request_ID) AS Times_Requested
FROM Requests r
JOIN Books b ON r.Requested_Book_ID = b.Book_ID
GROUP BY b.Book_ID, b.Title
ORDER BY Times_Requested DESC;

-- ─────────────────────────────────────────────────────────────
-- SECTION 7: STAFF QUERIES
-- ─────────────────────────────────────────────────────────────

-- Q18: All staff with their sections
SELECT 
    s.Staff_ID,
    s.Name,
    s.Role,
    GROUP_CONCAT(ss.Assigned_Section SEPARATOR ', ') AS Sections,
    GROUP_CONCAT(sc.Phone_Number     SEPARATOR ', ') AS Phone_Numbers,
    sa.Address
FROM Staff s
LEFT JOIN Staff_Sections ss ON s.Staff_ID = ss.Staff_ID
LEFT JOIN Staff_Contacts sc ON s.Staff_ID = sc.Staff_ID
LEFT JOIN Staff_Address  sa ON s.Staff_ID = sa.Staff_ID
GROUP BY s.Staff_ID, s.Name, s.Role, sa.Address;

-- ─────────────────────────────────────────────────────────────
-- SECTION 8: ADVANCED / ANALYTICAL QUERIES
-- ─────────────────────────────────────────────────────────────

-- Q19: Most borrowed books
SELECT 
    b.Title,
    COUNT(l.Loan_ID) AS Borrow_Count
FROM Books b
JOIN Loans l ON b.Book_ID = l.Issued_Book_ID
GROUP BY b.Book_ID, b.Title
ORDER BY Borrow_Count DESC
LIMIT 5;

-- Q20: Books never borrowed
SELECT b.Book_ID, b.Title, b.Edition
FROM Books b
LEFT JOIN Loans l ON b.Book_ID = l.Issued_Book_ID
WHERE l.Loan_ID IS NULL;

-- Q21: Summary dashboard stats
SELECT
    (SELECT COUNT(*) FROM Books)                           AS Total_Books,
    (SELECT COUNT(*) FROM Members)                         AS Total_Members,
    (SELECT COUNT(*) FROM Loans WHERE Return_Date IS NULL) AS Active_Loans,
    (SELECT COUNT(*) FROM Fines  WHERE Payment_Status = 'Unpaid') AS Unpaid_Fines,
    (SELECT SUM(Fine_Amount) FROM Fines WHERE Payment_Status = 'Unpaid') AS Outstanding_Amount,
    (SELECT COUNT(*) FROM Requests WHERE Request_Status = 'Pending') AS Pending_Requests;

-- Q22: Subquery — members who borrowed more books than average
SELECT 
    m.Name,
    m.Membership_Type,
    COUNT(l.Loan_ID) AS Total_Loans
FROM Members m
JOIN Loans l ON m.Member_ID = l.Member_ID
GROUP BY m.Member_ID, m.Name, m.Membership_Type
HAVING COUNT(l.Loan_ID) > (
    SELECT AVG(loan_count)
    FROM (
        SELECT COUNT(*) AS loan_count
        FROM Loans
        GROUP BY Member_ID
    ) sub
);
