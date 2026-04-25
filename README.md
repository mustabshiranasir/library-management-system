# 📚 Library Management System

> **A fully-normalized relational database project for COMSATS University Islamabad, Attock Campus**  
> Course: *Database Systems (Lab)* &nbsp;|&nbsp; Instructor: *Mr. Shahzad Rizwan*

---

## 🗂️ Project Overview

The **Library Management System (LMS)** is a complete relational database application designed to manage all core library operations — book cataloguing, member registration, loans, fines, inventory tracking, and book requests. It is built on **MySQL 8** with a 3NF-normalized schema, 22 analytical SQL queries, and a self-contained HTML dashboard frontend.

---

## 📁 File Structure

| File | Description |
|------|-------------|
| `library_schema.sql` | DDL — Creates `LibraryDB`, all 16 tables, constraints & indexes |
| `library_data.sql` | DML — Populates all tables with realistic sample data |
| `library_queries.sql` | 22 SQL queries covering all functional areas + advanced analytics |
| `library_frontend.html` | Single-page dashboard — open directly in any browser (no server needed) |

---

## 🛠️ Setup Instructions

### Prerequisites
- MySQL 8.0 or higher
- MySQL Workbench / DBeaver / any MySQL client
- Any modern browser (Chrome, Firefox, Edge)

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/your-username/library-management-system.git
cd library-management-system

# 2. Open your MySQL client and run the files in order:
#    Step 1 — Create schema
source library_schema.sql

#    Step 2 — Insert sample data
source library_data.sql

#    Step 3 — Run queries (optional, for exploration)
source library_queries.sql

# 3. Open the dashboard
#    Simply open library_frontend.html in your browser — no server required.
```

---

## 🗄️ Database Schema

The database `LibraryDB` contains **16 tables** organized into 8 modules:

```
LibraryDB
├── Books
│   ├── Book_Authors        (multi-valued: supports multiple authors per book)
│   ├── Book_Categories     (multi-valued: supports multiple categories per book)
│   └── Book_Publishers     (junction: M:N between Books and Publishers)
├── Publishers
├── Members
│   ├── Member_Contacts     (multi-valued: supports multiple phone numbers)
│   └── Member_Address
├── Staff
│   ├── Staff_Contacts
│   ├── Staff_Address
│   └── Staff_Sections      (multi-valued: staff assigned to multiple sections)
├── Inventory
├── Loans
├── Fines
└── Requests
```

### Key Design Decisions

- **3NF Normalization** — All multi-valued attributes extracted to satellite tables
- **ENUM types** — `Membership_Type`, `Payment_Status`, `Request_Status` use ENUM for state safety
- **CASCADE / RESTRICT** — Foreign key actions chosen per business rule (e.g., prevent deleting members with active loans)
- **CHECK constraints** — `Stock_Count ≥ 0`, `Fine_Amount ≥ 0`, `Overdue_Days > 0`
- **Indexes** — 6 optimized indexes on frequently filtered columns

---

## 📊 Sample Data Summary

| Entity | Records |
|--------|---------|
| Books | 10 |
| Authors | 14 (across 10 books) |
| Members | 8 (Students, Faculty, Staff) |
| Staff | 4 |
| Publishers | 5 |
| Active Loans | 6 |
| Fines | 5 (4 unpaid / 1 paid) |
| Requests | 7 |
| Inventory | 10 (all books tracked) |

---

## 🔍 Query Reference (22 Queries)

| # | Section | Description |
|---|---------|-------------|
| Q1 | Books | All books with authors and categories (`GROUP_CONCAT`) |
| Q2 | Books | Books by a specific author (`LIKE`) |
| Q3 | Books | Books in a specific category |
| Q4 | Books | Books with publisher info (3-table JOIN) |
| Q5 | Members | All members with contacts and address |
| Q6 | Members | Members currently holding loans |
| Q7 | Members | Members with unpaid fines (total per member) |
| Q8 | Loans | All active loans with overdue days (`DATEDIFF`) |
| Q9 | Loans | Overdue loans past due date |
| Q10 | Loans | Loan history for a specific member (`CASE`) |
| Q11 | Loans | Total loans per member (ranking) |
| Q12 | Inventory | Inventory status with availability % |
| Q13 | Inventory | Low-stock books (< 3 copies) |
| Q14 | Fines | All fines with member and book details |
| Q15 | Fines | Total collected vs outstanding fines |
| Q16 | Requests | All pending requests |
| Q17 | Requests | Most requested books |
| Q18 | Staff | Staff with sections and contacts |
| Q19 | Advanced | Most borrowed books (Top 5) |
| Q20 | Advanced | Books never borrowed (`LEFT JOIN IS NULL`) |
| Q21 | Advanced | Dashboard summary (6 scalar subqueries) |
| Q22 | Advanced | Members who borrowed more than average (correlated subquery) |

---

## 🖥️ Frontend Dashboard

The `library_frontend.html` file is a **zero-dependency** single-page dashboard built with:

- **Vanilla HTML / CSS / JavaScript** — no frameworks, no build step
- **Dark theme** with gold, teal, and blue accent colors
- **Sections:** Dashboard KPIs, Books, Members, Staff, Loans, Fines, Inventory, Requests
- **Color-coded badges** for loan status, fine payment, request status
- **Availability indicators** for inventory stock levels
- **Google Fonts:** DM Sans, DM Serif Display, DM Mono

To use: simply double-click `library_frontend.html` or open it in any browser.

---

## 📈 Dashboard KPIs

| Metric | Value |
|--------|-------|
| Total Books | 10 |
| Total Members | 8 |
| Active Loans | 6 |
| Unpaid Fines | 4 |
| Outstanding Amount | $32.00 |
| Pending Requests | 4 |

---

## 🏛️ Normalization

The schema satisfies **Third Normal Form (3NF)**:

- **1NF** — No repeating groups; all multi-valued attributes are in separate tables
- **2NF** — No partial dependencies (all non-key attributes depend on the full primary key)
- **3NF** — No transitive dependencies (no non-key attribute depends on another non-key attribute)

---

## 👨‍💻 Author

**COMSATS University Islamabad — Attock Campus**  
Department of Computer Science  
Course: Database Systems (Lab)  
Instructor: Mr. Shahzad Rizwan  
Academic Year: 2024–2025

---

## 📄 License

This project is submitted as academic coursework. Feel free to use it as a reference for learning database design and SQL.
