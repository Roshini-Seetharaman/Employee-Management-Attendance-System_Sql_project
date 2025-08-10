-- schema.sql
DROP DATABASE IF EXISTS cts_employee;
CREATE DATABASE cts_employee;
USE cts_employee;

-- Departments
CREATE TABLE departments (
    dept_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Roles
CREATE TABLE roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100) NOT NULL UNIQUE,
    base_salary DECIMAL(12,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Employees
CREATE TABLE employees (
    emp_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50),
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(20),
    dept_id INT,
    role_id INT,
    date_of_joining DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id) ON DELETE SET NULL,
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE SET NULL
);

-- Attendance
CREATE TABLE attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT NOT NULL,
    att_date DATE NOT NULL,
    check_in TIME NULL,
    check_out TIME NULL,
    status ENUM('Present','Absent','On Leave','Half Day') DEFAULT 'Present',
    note VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (emp_id, att_date),
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id) ON DELETE CASCADE
);

-- Leaves
CREATE TABLE leaves (
    leave_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT NOT NULL,
    leave_from DATE NOT NULL,
    leave_to DATE NOT NULL,
    leave_type ENUM('Casual','Sick','Privilege') DEFAULT 'Casual',
    status ENUM('Pending','Approved','Rejected') DEFAULT 'Pending',
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id) ON DELETE CASCADE
);

-- Salary payments (monthly)
CREATE TABLE salaries (
    salary_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT NOT NULL,
    salary_month YEAR_MONTH NOT NULL,
    basic DECIMAL(12,2) NOT NULL,
    hra DECIMAL(12,2) DEFAULT 0,
    allowances DECIMAL(12,2) DEFAULT 0,
    deductions DECIMAL(12,2) DEFAULT 0,
    net_pay DECIMAL(12,2) GENERATED ALWAYS AS (basic + hra + allowances - deductions) STORED,
    paid_on DATE,
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id) ON DELETE CASCADE,
    UNIQUE (emp_id, salary_month)
);

-- Indexes for performance
CREATE INDEX idx_emp_dept ON employees(dept_id);
CREATE INDEX idx_att_date ON attendance(att_date);
CREATE INDEX idx_leaves_emp ON leaves(emp_id);

-- Trigger: prevent adding attendance for future dates
DELIMITER $$
CREATE TRIGGER trg_att_before_insert
BEFORE INSERT ON attendance
FOR EACH ROW
BEGIN
    IF NEW.att_date > CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Attendance date cannot be in the future.';
    END IF;
END $$
DELIMITER ;

-- Trigger: update employees.updated_at already handled by ON UPDATE TIMESTAMP

-- View: monthly attendance summary per employee
CREATE VIEW view_monthly_attendance AS
SELECT e.emp_id, CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
       MONTH(a.att_date) AS month, YEAR(a.att_date) AS year,
       SUM(a.status = 'Present') AS present_days,
       SUM(a.status = 'Absent') AS absent_days,
       SUM(a.status = 'On Leave') AS leave_days
FROM employees e
LEFT JOIN attendance a ON e.emp_id = a.emp_id
GROUP BY e.emp_id, YEAR(a.att_date), MONTH(a.att_date);

-- Simple user for testing (optional)
CREATE USER IF NOT EXISTS 'cts_user'@'localhost' IDENTIFIED BY 'cts_pass';
GRANT ALL PRIVILEGES ON cts_employee.* TO 'cts_user'@'localhost';
FLUSH PRIVILEGES;
