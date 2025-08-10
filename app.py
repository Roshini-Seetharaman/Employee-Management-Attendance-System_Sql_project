# app.py
from flask import Flask, render_template, request, redirect, url_for, flash
import mysql.connector
from mysql.connector import Error
from datetime import datetime

app = Flask(__name__)
app.secret_key = "change-me-to-a-secure-key"

# ---- DB config: change as needed ----
DB_CONFIG = {
    'host': 'localhost',
    'user': 'cts_user',      # or 'root'
    'password': 'cts_pass',  # your mysql password
    'database': 'cts_employee'
}

def get_db():
    conn = mysql.connector.connect(**DB_CONFIG)
    return conn

@app.route('/')
def index():
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    cur.execute("SELECT emp_id, first_name, last_name, email FROM employees ORDER BY emp_id")
    employees = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('index.html', employees=employees)

@app.route('/employee/<int:emp_id>')
def employee_detail(emp_id):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    cur.execute("SELECT * FROM employees WHERE emp_id=%s", (emp_id,))
    emp = cur.fetchone()
    # attendance last 30 days
    cur.execute("SELECT * FROM attendance WHERE emp_id=%s ORDER BY att_date DESC LIMIT 30", (emp_id,))
    attendance = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('employee.html', emp=emp, attendance=attendance)

@app.route('/add_employee', methods=['GET','POST'])
def add_employee():
    if request.method == 'POST':
        f = request.form
        conn = get_db()
        cur = conn.cursor()
        try:
            cur.callproc('add_employee', (f['first_name'], f.get('last_name'), f['email'], f.get('phone'), int(f['dept_id']), int(f['role_id']), f.get('date_of_joining')))
            conn.commit()
            flash("Employee added", "success")
            return redirect(url_for('index'))
        except Error as e:
            flash(f"Error: {e}", "danger")
            conn.rollback()
        finally:
            cur.close()
            conn.close()
    # load depts and roles
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    cur.execute("SELECT * FROM departments")
    depts = cur.fetchall()
    cur.execute("SELECT * FROM roles")
    roles = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('add_employee.html', depts=depts, roles=roles)

@app.route('/mark_attendance', methods=['POST'])
def mark_attendance():
    emp_id = request.form.get('emp_id')
    date_str = request.form.get('att_date')
    checkin = request.form.get('check_in') or None
    checkout = request.form.get('check_out') or None
    status = request.form.get('status') or 'Present'
    try:
        att_date = datetime.strptime(date_str, '%Y-%m-%d').date()
    except Exception:
        flash("Invalid date format. Use YYYY-MM-DD", "danger")
        return redirect(request.referrer)
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.callproc('mark_attendance', (int(emp_id), att_date, checkin, checkout, status))
        conn.commit()
        flash("Attendance recorded", "success")
    except Error as e:
        flash(f"Error: {e}", "danger")
        conn.rollback()
    finally:
        cur.close()
        conn.close()
    return redirect(request.referrer)

@app.route('/report/<int:emp_id>/<int:year>/<int:month>')
def report(emp_id, year, month):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    cur.callproc('monthly_report', (emp_id, year, month))
    # Stored procedure returns result sets; fetch from cursor._next_result?
    # MySQL Connector returns results in cursor.stored_results()
    results = []
    for res in cur.stored_results():
        results = res.fetchall()
    cur.close()
    conn.close()
    return render_template('report.html', report=results, year=year, month=month)

if __name__ == '__main__':
    app.run(debug=True, port=5001)
