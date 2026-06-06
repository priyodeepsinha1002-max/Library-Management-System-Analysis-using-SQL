SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;



-- Task 1. Create a New Book Record 
-- -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

insert into books(isbn, book_title, category, rental_price, status, author, publisher)
values('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co');

select * from books;

-- Task 2: Update an Existing Member's Address

Update members
set member_address ='125 Oak St'
Where member_id= 'C103';

-- Task 3: Delete a Record from the Issued Status Table 
-- -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

Delete from issued_status
where issued_id= 'IS121';

-- Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'

SELECT * FROM issued_status
where issued_emp_id= 'E101';

-- Task 5: List Members Who Have Issued More Than One Book
-- Objective: Use GROUP BY to find members who have issued more than one book.

select issued_emp_id, count(*) as numbers_issued
from issued_status
group by 1
having count(*)>1;


-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

SELECT * FROM books;
SELECT * FROM issued_status;

create table book_count as
select 
b.isbn,
b.book_title,
count(ist.issued_id)as numbers
from books as b
join 
issued_status as ist
on ist.issued_book_isbn= b.isbn
group by 1;

SELECT * FROM book_count;

-- Task 7. Retrieve All Books in a Specific Category:
SELECT * FROM books;
SELECT * FROM issued_status;

SELECT * 
FROM books
where category= 'Classic';

-- Task 8: Find Total Rental Income by Category:

SELECT * FROM books;
SELECT * FROM issued_status;

select b.category, sum(rental_price)
from books as b
join 
issued_status as ist
on b.isbn=ist.issued_book_isbn
group by 1;


-- List Members Who Registered in the Last 180 Days:

SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days'    
    

INSERT INTO members(member_id, member_name, member_address, reg_date)
VALUES
('C118', 'sam', '145 Main St', '2024-06-01'),
('C119', 'john', '133 Main St', '2024-05-01');



-- task 10 List Employees with Their Branch Manager's Name and their branch details:

SELECT 
    e1.*,
    b.manager_id,
    e2.emp_name as manager
FROM employees as e1
JOIN  
branch as b
ON b.branch_id = e1.branch_id
JOIN
employees as e2
ON b.manager_id = e2.emp_id


-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 7USD:

CREATE TABLE books_price_greater_than_seven
AS    
SELECT * FROM Books
WHERE rental_price > 7

SELECT * FROM 
books_price_greater_than_seven


-- Task 12: Retrieve the List of Books Not Yet Returned

SELECT 
    DISTINCT ist.issued_book_name
FROM issued_status as ist
LEFT JOIN
return_status as rs
ON ist.issued_id = rs.issued_id
WHERE rs.return_id IS NULL

    
SELECT * FROM return_status


-- Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period).
-- Display the member's_id, member's name, book title, issue date, and days overdue.

SELECT 
    ist.issued_member_id,
    m.member_name,
    bk.book_title,
    ist.issued_date,
    -- rs.return_date,
    CURRENT_DATE - ist.issued_date as over_dues_days
FROM issued_status as ist
JOIN 
members as m
    ON m.member_id = ist.issued_member_id
JOIN 
books as bk
ON bk.isbn = ist.issued_book_isbn
LEFT JOIN 
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE 
    rs.return_date IS NULL
    AND
    (CURRENT_DATE - ist.issued_date) > 30
ORDER BY 1


-- Task 14: Update Book Status on Return
-- Write a query to update the status of books in the books table to "Yes" when they are returned 
-- (based on entries in the return_status table).



DROP PROCEDURE IF EXISTS add_return_records(varchar, varchar, varchar);

CREATE OR REPLACE PROCEDURE add_return_records(
    p_return_id VARCHAR(10), 
    p_issued_id VARCHAR(10), 
    p_book_quality VARCHAR(10) 
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_isbn VARCHAR(50);
    v_book_name VARCHAR(80);
BEGIN
    SELECT issued_book_isbn, issued_book_name
    INTO v_isbn, v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    INSERT INTO return_status(return_id, issued_id, return_book_name, return_date, return_book_isbn)
    VALUES (p_return_id, p_issued_id, v_book_name, CURRENT_DATE, v_isbn);

    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    RAISE NOTICE 'Success! Book "%" has been safely returned.', v_book_name;
    
END;
$$;



CALL add_return_records('RS138', 'IS135', 'Good');

SELECT * FROM return_status ORDER BY return_id DESC;

SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM issued_status;
SELECT * FROM return_status;


-- Task 15: Branch Performance Report
-- Create a query that generates a performance report for each branch, showing 
-- the number of books issued, the number of books returned, and the total revenue generated from book rentals.


SELECT 
    b.branch_id,
    b.manager_id,
    b.branch_address,
    COALESCE(issue_counts.total_issued, 0) as number_book_issued,
    COALESCE(return_counts.total_returned, 0) as number_of_book_return,
    COALESCE(revenue_counts.total_revenue, 0) as total_revenue

FROM branch AS b

LEFT JOIN (
    SELECT e.branch_id, COUNT(ist.issued_id) as total_issued
    FROM issued_status AS ist
    JOIN employees AS e ON ist.issued_emp_id = e.emp_id
    GROUP BY e.branch_id
) AS issue_counts ON b.branch_id = issue_counts.branch_id

LEFT JOIN (
    SELECT e.branch_id, COUNT(rs.return_id) as total_returned
    FROM return_status AS rs
    JOIN issued_status AS ist ON rs.issued_id = ist.issued_id
    JOIN employees AS e ON ist.issued_emp_id = e.emp_id
    GROUP BY e.branch_id
) AS return_counts ON b.branch_id = return_counts.branch_id

LEFT JOIN (
    SELECT e.branch_id, SUM(bk.rental_price) as total_revenue
    FROM issued_status AS ist
    JOIN books AS bk ON ist.issued_book_isbn = bk.isbn
    JOIN employees AS e ON ist.issued_emp_id = e.emp_id
    GROUP BY e.branch_id
) AS revenue_counts ON b.branch_id = revenue_counts.branch_id;

-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a
-- new table active_members containing members who have issued at least one book in the last 2 months.

DROP TABLE IF EXISTS active_members;

CREATE TABLE active_members AS
SELECT DISTINCT
    m.member_id,
    m.member_name,
    m.reg_date
FROM issued_status AS ist
JOIN members AS m 
    ON ist.issued_member_id = m.member_id
WHERE ist.issued_date >= CURRENT_DATE - INTERVAL '2 months';

SELECT * FROM active_members;





-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed 
-- the most book issues. Display the employee name, number of books processed, and their branch.


SELECT 
    e.emp_name,
    b.branch_id,               
    b.branch_address,  
    COUNT(ist.issued_id) AS total_books_processed
FROM issued_status AS ist
JOIN employees AS e 
    ON ist.issued_emp_id = e.emp_id
JOIN branch AS b 
    ON e.branch_id = b.branch_id
GROUP BY e.emp_name, b.branch_id, b.branch_address
ORDER BY total_books_processed DESC
LIMIT 3;


-- Task 18: Identify Members Issuing High-Risk Books
-- Write a query to identify members who have issued books 
-- more than twice with the status "damaged" in the books table. 
-- Display the member name, book title, and the number of times they've issued damaged books.

SELECT 
    m.member_name,
    bk.book_title,
    COUNT(ist.issued_id) AS damaged_issue_count
FROM issued_status AS ist
JOIN members AS m 
    ON ist.issued_member_id = m.member_id
JOIN books AS bk 
    ON ist.issued_book_isbn = bk.isbn
WHERE LOWER(bk.status) = 'damaged'
GROUP BY m.member_name, bk.book_title
HAVING COUNT(ist.issued_id) > 2;

-- Task 19: Stored Procedure Objective: Create a stored procedure to manage 
-- the status of books in a library system. Description: Write a stored procedure
-- that updates the status of a book in the library based on its issuance. 
-- The procedure should function as follows: The stored procedure should take 
-- the book_id as an input parameter. The procedure should first check if the 
-- book is available (status = 'yes'). If the book is available, it should be 
-- issued, and the status in the books table should be updated to 'no'. If the 
-- book is not available (status = 'no'), the procedure should return an error
-- message indicating that the book is currently not available.


DROP PROCEDURE IF EXISTS issue_book_automation(varchar);

CREATE OR REPLACE PROCEDURE issue_book_automation(
    p_book_isbn VARCHAR(50) 
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_status VARCHAR(10);
BEGIN
    SELECT status 
    INTO v_current_status
    FROM books
    WHERE isbn = p_book_isbn;

    IF v_current_status = 'yes' THEN
        UPDATE books
        SET status = 'no'
        WHERE isbn = p_book_isbn;
        
        RAISE NOTICE 'Success! Book with ISBN % has been successfully checked out.', p_book_isbn;

    ELSE
        RAISE EXCEPTION 'Operation Denied: Book (ISBN %) is currently unavailable or checked out.', p_book_isbn;
    END IF;

END;
$$;

CALL issue_book_automation('978-0-307-58837-1');


-- Task 20: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select)
-- query to identify overdue books and calculate fines.

-- Description: Write a CTAS query to create a new table that lists each member and 
-- the books they have issued but not returned within 30 days. The table should include: 
-- The number of overdue books. The total fines, with each day's fine calculated at $0.50.
-- The number of books issued by each member. The resulting table should show: Member ID Number of overdue books Total fines
-- STEP 1: Clear old physical snapshot tables if they exist
DROP TABLE IF EXISTS overdue_billing_snapshot;

-- STEP 2: Bulk calculate and materialize the financial snapshot table
CREATE TABLE overdue_billing_snapshot AS
SELECT 
    ist.issued_member_id AS member_id,
    
    -- Calculate the precise count of books currently past their 30-day return window
    COUNT(
        CASE 
            WHEN (CURRENT_DATE - ist.issued_date) > 30 AND rs.return_id IS NULL 
            THEN 1 
        END
    ) AS number_of_overdue_books,
    
    -- Sum up the individual daily fines ($0.50 per day past the 30-day grace period)
    SUM(
        CASE 
            WHEN (CURRENT_DATE - ist.issued_date) > 30 AND rs.return_id IS NULL 
            THEN (CURRENT_DATE - (ist.issued_date + 30)) * 0.50
            ELSE 0
        END
    ) AS total_calculated_fines
    
FROM issued_status AS ist
LEFT JOIN return_status AS rs 
    ON ist.issued_id = rs.issued_id
GROUP BY ist.issued_member_id
HAVING COUNT(CASE WHEN (CURRENT_DATE - ist.issued_date) > 30 AND rs.return_id IS NULL THEN 1 END) > 0;

-- STEP 3: Audit verification query
SELECT * FROM overdue_billing_snapshot;

