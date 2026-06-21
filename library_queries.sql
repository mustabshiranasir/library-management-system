-- ============================================================
--  LIBRARY MANAGEMENT SYSTEM — QUERIES (SUPABASE / POSTGRESQL)
--  COMSATS University Islamabad, Attock Campus
-- ============================================================

-- ─────────────────────────────────────────────────────────────
-- SECTION 1: BOOKS QUERIES
-- ─────────────────────────────────────────────────────────────

-- Q1: List all books with their authors and categories
SELECT 
    b.book_id,
    b.title,
    b.edition,
    b.isbn,
    (SELECT string_agg(ba.author, ', ') FROM book_authors ba WHERE ba.book_id = b.book_id) AS authors,
    (SELECT string_agg(bc.category, ', ') FROM book_categories bc WHERE bc.book_id = b.book_id) AS categories
FROM books b;

-- Q2: Find all books by a specific author
SELECT b.book_id, b.title, b.edition
FROM books b
JOIN book_authors ba ON b.book_id = ba.book_id
WHERE ba.author ILIKE '%Cormen%';

-- Q3: Find all books in a specific category
SELECT b.book_id, b.title, b.edition
FROM books b
JOIN book_categories bc ON b.book_id = bc.book_id
WHERE bc.category = 'Computer Science';

-- Q4: Books with their publisher info
SELECT 
    b.title,
    b.isbn,
    p.name AS publisher,
    p.contact_number
FROM books b
JOIN book_publishers bp ON b.book_id = bp.book_id
JOIN publishers p ON bp.publisher_id = p.publisher_id
ORDER BY p.name;

-- ─────────────────────────────────────────────────────────────
-- SECTION 2: MEMBER QUERIES
-- ─────────────────────────────────────────────────────────────

-- Q5: All members with their contact and address
SELECT 
    m.member_id,
    m.name,
    m.membership_type,
    (SELECT string_agg(mc.phone_number, ', ') FROM member_contacts mc WHERE mc.member_id = m.member_id) AS phone_numbers,
    (SELECT ma.address FROM member_address ma WHERE ma.member_id = m.member_id LIMIT 1) AS address
FROM members m;

-- Q6: Members who currently have books on loan (not returned)
SELECT DISTINCT 
    m.member_id,
    m.name,
    m.membership_type
FROM members m
JOIN loans l ON m.member_id = l.member_id
WHERE l.return_date IS NULL;

-- Q7: Members with unpaid fines
SELECT 
    m.name,
    m.membership_type,
    SUM(f.fine_amount) AS total_fine
FROM members m
JOIN fines f ON m.member_id = f.member_id
WHERE f.payment_status = 'Unpaid'
GROUP BY m.member_id, m.name, m.membership_type
ORDER BY total_fine DESC;

-- ─────────────────────────────────────────────────────────────
-- SECTION 3: LOANS QUERIES
-- ─────────────────────────────────────────────────────────────

-- Q8: All active loans (books not yet returned)
SELECT 
    l.loan_id,
    m.name AS member_name,
    m.membership_type,
    b.title AS book_title,
    l.issue_date,
    l.due_date,
    (CURRENT_DATE - l.due_date) AS days_overdue
FROM loans l
JOIN members m ON l.member_id = m.member_id
JOIN books b ON l.issued_book_id = b.book_id
WHERE l.return_date IS NULL
ORDER BY l.due_date;

-- Q9: Overdue loans (past due date and not returned)
SELECT 
    l.loan_id,
    m.name AS member_name,
    b.title,
    l.due_date,
    (CURRENT_DATE - l.due_date) AS overdue_days
FROM loans l
JOIN members m ON l.member_id = m.member_id
JOIN books b ON l.issued_book_id = b.book_id
WHERE l.return_date IS NULL
  AND l.due_date < CURRENT_DATE
ORDER BY overdue_days DESC;

-- Q10: Loan history for a specific member
SELECT 
    b.title,
    l.issue_date,
    l.due_date,
    l.return_date,
    CASE WHEN l.return_date IS NULL THEN 'Active' ELSE 'Returned' END AS status
FROM loans l
JOIN books b ON l.issued_book_id = b.book_id
WHERE l.member_id = 1
ORDER BY l.issue_date DESC;

-- Q11: Total loans per member (ranking)
SELECT 
    m.name,
    m.membership_type,
    COUNT(l.loan_id) AS total_loans
FROM members m
LEFT JOIN loans l ON m.member_id = l.member_id
GROUP BY m.member_id, m.name, m.membership_type
ORDER BY total_loans DESC;

-- ─────────────────────────────────────────────────────────────
-- SECTION 4: INVENTORY QUERIES
-- ─────────────────────────────────────────────────────────────

-- Q12: Current inventory status with availability percentage
SELECT 
    i.inventory_id,
    b.title,
    i.shelf_location,
    i.stock_count,
    i.total_count,
    ROUND((i.stock_count::numeric / GREATEST(i.total_count, 1)) * 100, 1) AS availability_pct
FROM inventory i
JOIN books b ON i.book_id = b.book_id
ORDER BY availability_pct ASC;

-- Q13: Books with low stock (less than 3 copies available)
SELECT 
    b.title,
    i.shelf_location,
    i.stock_count,
    i.total_count
FROM inventory i
JOIN books b ON i.book_id = b.book_id
WHERE i.stock_count < 3
ORDER BY i.stock_count;

-- ─────────────────────────────────────────────────────────────
-- SECTION 5: FINES QUERIES
-- ─────────────────────────────────────────────────────────────

-- Q14: All fines with member and book details
SELECT 
    f.fine_id,
    m.name AS member_name,
    b.title AS overdue_book,
    f.overdue_days,
    f.fine_amount,
    f.payment_status
FROM fines f
JOIN members m ON f.member_id = m.member_id
JOIN books b ON f.overdue_book_id = b.book_id
ORDER BY f.payment_status, f.fine_amount DESC;

-- Q15: Total fines collected vs outstanding
SELECT 
    payment_status,
    COUNT(*) AS records,
    SUM(fine_amount) AS total_amount
FROM fines
GROUP BY payment_status;

-- ─────────────────────────────────────────────────────────────
-- SECTION 6: REQUESTS QUERIES
-- ─────────────────────────────────────────────────────────────

-- Q16: All pending requests with member and book details
SELECT 
    r.request_id,
    m.name AS member_name,
    b.title AS requested_book,
    r.request_date,
    r.request_status
FROM requests r
JOIN members m ON r.member_id = m.member_id
JOIN books b ON r.requested_book_id = b.book_id
WHERE r.request_status = 'Pending'
ORDER BY r.request_date;

-- Q17: Most requested books
SELECT 
    b.title,
    COUNT(r.request_id) AS times_requested
FROM requests r
JOIN books b ON r.requested_book_id = b.book_id
GROUP BY b.book_id, b.title
ORDER BY times_requested DESC;

-- ─────────────────────────────────────────────────────────────
-- SECTION 7: STAFF QUERIES
-- ─────────────────────────────────────────────────────────────

-- Q18: All staff
SELECT 
    s.staff_id,
    s.name,
    s.role
FROM staff s;

-- ─────────────────────────────────────────────────────────────
-- SECTION 8: ADVANCED / ANALYTICAL QUERIES
-- ─────────────────────────────────────────────────────────────

-- Q19: Most borrowed books
SELECT 
    b.title,
    COUNT(l.loan_id) AS borrow_count
FROM books b
JOIN loans l ON b.book_id = l.issued_book_id
GROUP BY b.book_id, b.title
ORDER BY borrow_count DESC
LIMIT 5;

-- Q20: Books never borrowed
SELECT b.book_id, b.title, b.edition
FROM books b
LEFT JOIN loans l ON b.book_id = l.issued_book_id
WHERE l.loan_id IS NULL;

-- Q21: Summary dashboard stats
SELECT
    (SELECT COUNT(*) FROM books) AS total_books,
    (SELECT COUNT(*) FROM members) AS total_members,
    (SELECT COUNT(*) FROM loans WHERE return_date IS NULL) AS active_loans,
    (SELECT COUNT(*) FROM fines WHERE payment_status = 'Unpaid') AS unpaid_fines,
    (SELECT COALESCE(SUM(fine_amount), 0) FROM fines WHERE payment_status = 'Unpaid') AS outstanding_amount,
    (SELECT COUNT(*) FROM requests WHERE request_status = 'Pending') AS pending_requests;

-- Q22: Subquery — members who borrowed more books than average
SELECT 
    m.name,
    m.membership_type,
    COUNT(l.loan_id) AS total_loans
FROM members m
JOIN loans l ON m.member_id = l.member_id
GROUP BY m.member_id, m.name, m.membership_type
HAVING COUNT(l.loan_id) > (
    SELECT AVG(loan_count)
    FROM (
        SELECT COUNT(*) AS loan_count
        FROM loans
        GROUP BY member_id
    ) sub
);
