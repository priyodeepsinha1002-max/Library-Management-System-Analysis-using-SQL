# Library Management System Analysis using SQL

📊 **Project Type:** Relational Database Architecture & Advanced Procedural SQL  
🛠️ **Database Engine:** PostgreSQL (pgAdmin 4)  
💾 **Dataset Context:** Library Inventory, Branch Operations, Member Subscriptions, and Transactional Issuance Logs

---

## Project Overview
This project delivers a robust data architecture solution for a library management tracking system. The goal is to build an integrated transactional database schema, inject historical record inventories, and write advanced analytical data workflows. 

The repository showcases core relational engineering practices—including data manipulation (DML), Table Materialization (CTAS), complex multi-layered `LEFT JOIN` operations, and custom automated database programs using **PostgreSQL PL/pgSQL Stored Procedures**.

---

## Database Schema Model
The architecture utilizes highly optimized table structures designed to enforce structural lookup integrity between books, local branch offices, active staff members, and library subscribers.

```sql
-- 1. Books Inventory Master Table
CREATE TABLE books (
    isbn         VARCHAR(50) PRIMARY KEY,
    book_title   VARCHAR(250),
    category     VARCHAR(100),
    rental_price NUMERIC(10,2),
    status       VARCHAR(10),
    author       VARCHAR(150),
    publisher    VARCHAR(150)
);

-- 2. Library Branch Operations Table
CREATE TABLE branch (
    branch_id      VARCHAR(10) PRIMARY KEY,
    manager_id     VARCHAR(10),
    branch_address VARCHAR(250)
);

-- 3. Employees Register Table
CREATE TABLE employees (
    emp_id         VARCHAR(10) PRIMARY KEY,
    emp_name       VARCHAR(150),
    position       VARCHAR(100),
    salary         NUMERIC(12,2),
    branch_id      VARCHAR(10) REFERENCES branch(branch_id)
);

-- 4. Library Subscribed Members Register
CREATE TABLE members (
    member_id      VARCHAR(10) PRIMARY KEY,
    member_name    VARCHAR(150),
    member_address VARCHAR(250),
    reg_date       DATE
);

-- 5. Transactional In-Memory Issue Status Logs
CREATE TABLE issued_status (
    issued_id         VARCHAR(10) PRIMARY KEY,
    issued_member_id  VARCHAR(10) REFERENCES members(member_id),
    issued_book_name  VARCHAR(250),
    issued_date       DATE,
    issued_book_isbn  VARCHAR(50) REFERENCES books(isbn),
    issued_emp_id     VARCHAR(10) REFERENCES employees(emp_id)
);

-- 6. Transactional Return Fulfillment Logs
CREATE TABLE return_status (
    return_id        VARCHAR(10) PRIMARY KEY,
    issued_id        VARCHAR(10) REFERENCES issued_status(issued_id),
    return_book_name VARCHAR(250),
    return_date      DATE,
    return_book_isbn VARCHAR(50) REFERENCES books(isbn)
);
