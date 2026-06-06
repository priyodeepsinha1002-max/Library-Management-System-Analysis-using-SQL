-- Library management System Project 2

Create table branch(
branch_id varchar(10) Primary key,
manager_id varchar(10),
branch_address varchar(55),
contact_no varchar(10)
);
alter table branch
alter column branch_id type varchar(50);



-----
DROP TABLE IF EXISTS employees CASCADE;

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100),
    position VARCHAR(100),
    salary FLOAT,
    branch_id INT
);

alter table employees
alter column emp_id type varchar(50);

alter table employees
alter column branch_id type varchar(50);

--------


create table books(
isbn varchar(20) Primary key,
book_title varchar(75),
category varchar(10),
rental_price float,
status varchar(15),
author varchar(35),
publisher varchar (55)
);

alter table books
alter column category type varchar(50);

create table members(
member_id varchar(10) Primary key,
member_name varchar(25),
member_address varchar (75),
reg_date date
);

create table issued_status(
issued_id varchar(10) Primary key,
issued_member_id varchar(10), --FK
issued_book_name varchar(75), 
issued_date date,
issued_book_isbn varchar(25), --FK
issued_emp_id varchar(10) --FK
);

create table return_status(
return_id varchar(10) Primary key,
issued_id varchar(10),
return_book_name varchar(75),
return_date date,
return_book_isbn varchar(20)
);

-- Establishing foreign key

Alter table issued_status
add constraint fk_members
Foreign key(issued_member_id)
references members(member_id);

Alter table issued_status
add constraint fk_books
Foreign key(issued_book_isbn)
references books(isbn);

Alter table issued_status
add constraint fk_employees
Foreign key(issued_emp_id)
references employees(emp_id);


Alter table employees
add constraint fk_branch
Foreign key(branch_id)
references branch(branch_id);

Alter table return_status
add constraint fk_issued_status
Foreign key(return_id)
references issued_status(issued_id);

ALTER TABLE employees DROP CONSTRAINT IF EXISTS fk_branch CASCADE;
ALTER TABLE return_status DROP CONSTRAINT IF EXISTS fk_members CASCADE;
ALTER TABLE return_status DROP CONSTRAINT IF EXISTS fk_return CASCADE;

 -- 1. Fix the main members table ID column to accept text data
ALTER TABLE members ALTER COLUMN member_id TYPE VARCHAR(25);

-- 2. Fix the tracking table column that links to it so they match
ALTER TABLE issued_status ALTER COLUMN issued_member_id TYPE VARCHAR(25);




ALTER TABLE return_status DROP CONSTRAINT IF EXISTS fk_issued_status CASCADE;

TRUNCATE TABLE return_status CASCADE;

ALTER TABLE return_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY (issued_id) REFERENCES issued_status(issued_id);

ALTER TABLE return_status DROP CONSTRAINT IF EXISTS fk_issued_status CASCADE;




