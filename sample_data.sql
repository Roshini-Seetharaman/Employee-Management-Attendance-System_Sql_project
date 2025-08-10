-- sample_data.sql
USE cts_employee;

INSERT INTO departments (name) VALUES ('Engineering'), ('HR'), ('Finance'), ('Sales');

INSERT INTO roles (title, base_salary) VALUES 
('Software Engineer', 50000.00),
('Senior Software Engineer', 80000.00),
('HR Executive', 30000.00),
('Finance Analyst', 40000.00);

INSERT INTO employees (first_name, last_name, email, phone, dept_id, role_id, date_of_joining)
VALUES
('Amit', 'Kumar', 'amit.kumar@example.com', '9999000001', 1, 1, '2022-03-10'),
('Priya', 'Sharma', 'priya.sharma@example.com', '9999000002', 1, 2, '2020-01-15'),
('Rohit', 'Verma', 'rohit.verma@example.com', '9999000003', 2, 3, '2021-07-01'),
('Sana', 'Khan', 'sana.khan@example.com', '9999000004', 4, 4, '2023-02-20');

-- Attendance sample for Amit for March 2025 (few days)
INSERT INTO attendance (emp_id, att_date, check_in, check_out, status, note)
VALUES
(1, '2025-03-01', '09:05:00', '18:00:00', 'Present', NULL),
(1, '2025-03-02', NULL, NULL, 'Absent', 'Sick'),
(1, '2025-03-03', '09:20:00', '18:10:00', 'Present', NULL),
(2, '2025-03-01', '09:00:00', '18:00:00', 'Present', NULL);

-- Leaves
INSERT INTO leaves (emp_id, leave_from, leave_to, leave_type, status)
VALUES
(1, '2025-04-10', '2025-04-12', 'Casual', 'Approved'),
(3, '2025-05-05', '2025-05-06', 'Sick', 'Pending');

-- Salary (example)
INSERT INTO salaries (emp_id, salary_month, basic, hra, allowances, deductions, paid_on)
VALUES
(1, '2025-03', 50000.00, 10000.00, 2000.00, 1500.00, '2025-03-30'),
(2, '2025-03', 80000.00, 16000.00, 3000.00, 2000.00, '2025-03-30');
