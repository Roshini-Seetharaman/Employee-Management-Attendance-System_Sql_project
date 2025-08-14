# Employee Management & Attendance System — SQL Project

A complete MySQL-based Employee Management & Attendance System demonstrating core SQL skills:

- **Database Design:** 6+ relational tables with PK, FK, unique constraints, indexes.
- **Advanced SQL:** Stored procedures, triggers, views, functions for reporting & automation.
- **Data Integrity:** Referential constraints, ENUM validations, and a trigger preventing invalid entries.
- **Reports:** Monthly attendance, salary register via views and stored procedures.
- **Integration:** Flask web app to interact with the database (CRUD operations, attendance marking, reporting).

## Key Highlights
This project covers real-world SQL features expected in industry:
1. Schema design (1NF–3NF) 
2. Sample data for demo  
3. Stored procedures for business logic  
4. Views for quick reporting  
5. Trigger-based validation  
6. MySQL + Python integration  

---

## Prerequisites
- MySQL server installed and running
- Python 3.8+
- pip

## Setup DB
Login to MySQL and run:
```sql
SOURCE schema.sql;
SOURCE sample_data.sql;
SOURCE procedures.sql;

python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python app.py
