-- procedures.sql
USE cts_employee;
DELIMITER $$

-- Procedure: add employee
CREATE PROCEDURE add_employee(
    IN p_first VARCHAR(50),
    IN p_last VARCHAR(50),
    IN p_email VARCHAR(150),
    IN p_phone VARCHAR(20),
    IN p_dept INT,
    IN p_role INT,
    IN p_doj DATE
)
BEGIN
    INSERT INTO employees (first_name, last_name, email, phone, dept_id, role_id, date_of_joining)
    VALUES (p_first, p_last, p_email, p_phone, p_dept, p_role, p_doj);
END $$

-- Procedure: mark attendance (safe)
CREATE PROCEDURE mark_attendance(
    IN p_emp INT,
    IN p_date DATE,
    IN p_checkin TIME,
    IN p_checkout TIME,
    IN p_status ENUM('Present','Absent','On Leave','Half Day')
)
BEGIN
    -- Insert or update
    INSERT INTO attendance (emp_id, att_date, check_in, check_out, status)
    VALUES (p_emp, p_date, p_checkin, p_checkout, p_status)
    ON DUPLICATE KEY UPDATE
      check_in = VALUES(check_in),
      check_out = VALUES(check_out),
      status = VALUES(status);
END $$

-- Function: calculate employee tenure in days
CREATE FUNCTION emp_tenure_days(p_emp INT) RETURNS INT DETERMINISTIC
RETURN DATEDIFF(CURDATE(), (SELECT date_of_joining FROM employees WHERE emp_id = p_emp));

-- Procedure: monthly attendance report for an employee
CREATE PROCEDURE monthly_report(IN p_emp INT, IN p_year INT, IN p_month INT)
BEGIN
    SELECT e.emp_id, CONCAT(e.first_name,' ',e.last_name) AS employee_name,
           SUM(a.status='Present') AS present_days,
           SUM(a.status='Absent') AS absent_days,
           SUM(a.status='On Leave') AS leave_days
    FROM employees e
    LEFT JOIN attendance a ON e.emp_id = a.emp_id AND YEAR(a.att_date)=p_year AND MONTH(a.att_date)=p_month
    WHERE e.emp_id = p_emp
    GROUP BY e.emp_id;
END $$

DELIMITER ;
