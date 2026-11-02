CREATE DATABASE SQL_SUBQUERIES_CTE_ASSIGNMENT
use SQL_SUBQUERIES_CTE_ASSIGNMENT

SELECT * 
FROM items

SELECT * 
FROM company

SELECT * 
FROM employees

SELECT * 
FROM departments


--Return company_name and average_price.
SELECT c.company_name,AVG(i.price) AS Average_Price
FROM items i
JOIN company c 
	on i.company_id=c.company_id
GROUP BY company_name
---1
SELECT company_name,(
	SELECT AVG(price)
	FROM items i
	WHERE i.company_id=c.company_id
)as Average_Price
FROM company c

--2
SELECT c.company_name,(
	SELECT AVG(price)
	FROM items i 
	where i.company_id=c.company_id
) as Average_Price
FROM company c
WHERE 
(SELECT AVG(price)
	FROM items i 
	where i.company_id=c.company_id
) > (
	SELECT AVG(price)
	FROM items i )

--3
SELECT item_id,item_name,price,company_id
FROM items 
WHERE price >(
	SELECT AVG(i.price)
	FROM items i
)

--4
SELECT emp_id, emp_fname, emp_lname,emp_dept
FROM employees
WHERE emp_dept in (
	SELECT dept_code
	FROM departments
	WHERE dept_budget > (
		SELECT AVG(dept_budget)
		FROM departments
	)
)

--5


WITH Emp_count as 
(
	SELECT emp_dept,count(emp_id) as Emp_Count
	FROM employees
	group by emp_dept
)

SELECT dept_code,dept_name
FROM departments
WHERE dept_code IN(
	SELECT emp_dept
	FROM Emp_count
	WHERE Emp_Count >(
		SELECT AVG(Emp_Count)
		FROM Emp_count
	)
)

--6
SELECT item_id,item_name,price,company_id
FROM items
WHERE price <(
	SELECT avg(i.price)
	FROM items i
	WHERE company_id=i.company_id
)

--7
SELECT dept_code,dept_name,(
		SELECT count(emp_id)
		FROM employees e
		WHERE e.emp_dept=d.dept_code
)as emp_Count
FROM departments d
WHERE (SELECT count(emp_id)
		FROM employees e
		WHERE e.emp_dept=d.dept_code)=1

--8
WITH AvgPrice AS
(
    SELECT
        company_id,
        AVG(price) AS average_price
    FROM items
    GROUP BY company_id
)

SELECT
    c.company_name,
    ap.average_price
FROM company c
JOIN AvgPrice ap
    ON c.company_id = ap.company_id
WHERE ap.average_price = (
    SELECT MIN(average_price)
    FROM AvgPrice
);

--9
WITH DEPT_budget as (

SELECT avg(dept_budget)as avgbudget
FROM departments
)
SELECT emp_id, emp_fname, emp_lname,d.dept_code
FROM employees e
join departments d on d.dept_code=e.emp_dept
cross join DEPT_budget a
WHERE a.avgbudget> d.dept_budget


-------------------------------------------------------------
-------------------------------------------------------------

--Q1
WITH AvrPrice  AS (

SELECT AVG(price) as average_price
FROM items
)
SELECT item_id,item_name,company_id
FROM items
WHERE price > (
	SELECT average_price
	FROM AvrPrice
)

--	Q2
WITH ItemCount  AS (

SELECT company_id,COUNT(item_id) as itemscount
FROM items
WHERE company_id = company_id
GROUP BY company_id
)

SELECT company_name,ic.itemscount
FROM company c
join ItemCount ic on c.company_id=ic.company_id

--	Q3
WITH AvgPrice AS (

SELECT company_id,AVG(price) AS average_price
FROM items
GROUP BY company_id
)

SELECT c.company_name , ap.average_price
FROM company c
join AvgPrice ap on c.company_id=ap.company_id
WHERE ap.average_price>2000

--	Q4
WITH employees_new AS (

SELECT emp_id,CONCAT(emp_fname,emp_lname) as FullName,emp_dept
FROM employees
)
SELECT e.emp_id,e.FullName,d.dept_name
FROM departments d
join employees_new e on e.emp_dept=d.dept_code

--	 Q5
WITH AvgBudget AS (

SELECT AVG(dept_budget) as averagebudget
FROM departments
)

SELECT dept_code,dept_name,dept_budget
FROM departments d
WHERE dept_budget > (
		SELECT averagebudget
		FROM AvgBudget
)

--	Q6
WITH EMP_NUM AS (

SELECT emp_dept,COUNT(emp_id) AS Employee_Number
FROM employees
WHERE emp_dept=emp_dept
group by emp_dept
)
SELECT d.dept_code,d.dept_name,Employee_Number
FROM departments d
join EMP_NUM em on d.dept_code=em.emp_dept
WHERE Employee_Number >1

--	 Q7
WITH AvgItemPrice AS (

SELECT AVG(price) as average_item_price
FROM items

),
companyavg  as(
SELECT company_id,AVG(price) as company_avg
FROM items
WHERE company_id=company_id
group by company_id
)

SELECT c.company_id,c.company_name
FROM company c
join  companyavg ca on c.company_id=ca.company_id
cross join AvgItemPrice aip
WHERE aip.average_item_price < ca.company_avg