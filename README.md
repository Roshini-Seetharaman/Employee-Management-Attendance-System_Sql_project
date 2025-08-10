# Employee-Management-Attendance-System_Sql_project
This SQL-based Inventory &amp; Sales Management System streamlines product tracking, customer management, and sales reporting. It includes a relational database with optimized tables, stored procedures, triggers, and constraints for data integrity. 



## Prerequisites
- MySQL server installed and running
- Python 3.8+
- pip

## Setup DB
1. Login to MySQL and run:
   ```sql
   SOURCE schema.sql;
   SOURCE sample_data.sql;
   SOURCE procedures.sql;


python -m venv venv
source venv/bin/activate   
pip install -r requirements.txt

python app.py
