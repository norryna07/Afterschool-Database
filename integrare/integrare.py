from flask import Flask, render_template, request, redirect, url_for 
import cx_Oracle
from datetime import datetime

app = Flask(__name__)

dsn = cx_Oracle.makedsn("localhost", 1521, service_name="xe")
connection = cx_Oracle.connect("centru_meditatii", "med123", dsn)

#Determinarea tabelelor permise
def get_allowed_tables():
    cursor = connection.cursor()

    query = "SELECT table_name FROM user_tables"

    cursor.execute(query)
    tables = [row[0] for row in cursor.fetchall()]

    cursor.close()

    return tables

def get_allowed_columns(table_name):
    cursor = connection.cursor()

    query = f"SELECT column_name FROM all_tab_columns WHERE table_name = '{table_name}'"

    cursor.execute(query)
    columns = [row[0] for row in cursor.fetchall()]

    cursor.close()

    return columns

def get_allowed_views():
    cursor = connection.cursor()

    query = "SELECT view_name FROM user_views"
    
    cursor.execute(query)
    views = [row[0] for row in cursor.fetchall()]
    cursor.close()

    return views

def data_type(column):
    cursor = connection.cursor()

    query = f"SELECT data_type FROM all_tab_columns WHERE column_name = '{column}'"

    cursor.execute(query)
    record = cursor.fetchone()
    cursor.close()

    return record[0]


@app.route('/', methods = ['POST', 'GET'])
def index():
    #preluare cerinta
    task_name = request.args.get('task_name', 'a')
    if task_name < 'a' and task_name > 'f':
        task_name = 'a'
    
    if task_name == 'c':
        return redirect(url_for('cerinta_c'))
    if task_name == 'd':
        return redirect(url_for('cerinta_d'))
    if task_name == 'f':
        return redirect(url_for('cerinta_f'))

    #Preluare nume tabel
    table_name = request.args.get('table_name', 'ANGAJATI') 
    column_name = request.args.get('column_name', 'null')
    sort_order = request.args.get('sort_order', 'asc')

    allowed_tables = get_allowed_tables()
    if table_name not in allowed_tables:
        table_name = 'ANGAJATI'


    allowed_columns = get_allowed_columns(table_name)
    if column_name not in allowed_columns:
        column_name = 'null'

    if sort_order != 'asc':
        sort_order = 'desc'
    
    if column_name == 'null':
        query = f"SELECT * FROM {table_name}"
    else:
        query = f"SELECT * FROM {table_name} ORDER BY {column_name} {sort_order}"


    cursor = connection.cursor()
    cursor.execute(query)
    records = cursor.fetchall()
    cursor.close()

    return render_template('index.html', task_name = task_name, table_name=table_name, records=records, allowed_tables = allowed_tables, allowed_columns=allowed_columns)

@app.route('/add', methods=['GET', 'POST'])
def add():
    if request.method == 'GET':
        table_name = request.args.get('table_name', 'ANGAJATI')

        allowes_tables = get_allowed_tables()
        if table_name not in allowes_tables:
            table_name = 'ANGAJATI'

        allowed_columns = get_allowed_columns(table_name)
        return render_template('add_form.html', table_name = table_name, allowed_columns = allowed_columns)
    #primirea datelor prin form

    table_name = request.args.get('table_name', 'ANGAJATI')

    allowes_tables = get_allowed_tables()
    if table_name not in allowes_tables:
        table_name = 'ANGAJATI'
    
    form_data = {column: request.form[column] for column in request.form}

    allowed_columns = get_allowed_columns(table_name)
    
    for column in allowed_columns:
        if data_type(column) == 'DATE':
            form_data[column] = datetime.strptime(form_data[column], '%Y-%m-%d %H:%M:%S')

    cursor = connection.cursor()
    columns = ', '.join(form_data.keys())
    values = ', '.join(f':{key}' for key in form_data.keys())
    query = f'INSERT INTO {table_name} ({columns}) VALUES ({values})'
    cursor.execute(query, form_data)
    connection.commit()
    cursor.close()

    return redirect(url_for('index', table_name = table_name))
    
@app.route('/edit/<int:record_id>', methods=['GET', 'POST'])
def edit(record_id):
    table_name = request.args.get('table_name', 'ANGAJATI')
    record_col = request.args.get('record_col', 'null')

    allowed_table = get_allowed_tables()
    if table_name not in allowed_table:
        table_name = 'ANGAJATI'
    
    allowed_columns = get_allowed_columns(table_name)

    cursor = connection.cursor()

    if request.method == 'GET':
        query = f"SELECT * FROM {table_name} WHERE {record_col} = :record_id"
        cursor.execute(query, {'record_id' : record_id})
        record = cursor.fetchone()

        return render_template('edit_form.html', table_name = table_name, record=record, allowed_columns=allowed_columns, record_id = record_id, record_col = record_col)

    form_data = {column: request.form[column] for column in allowed_columns}

    for column in allowed_columns:
        if data_type(column) == 'DATE':
            form_data[column] = datetime.strptime(form_data[column], '%Y-%m-%d %H:%M:%S')

    set_clause = ', '.join(f'{col} = :{col}' for col in allowed_columns)
    query = f"UPDATE {table_name} SET {set_clause} where {record_col} = :record_id"
    print(query)
    form_data['record_id'] = record_id
    cursor.execute(query, form_data)
    connection.commit()
    cursor.close()

    return redirect(url_for('index', table_name = table_name))

@app.route('/delete/<int:record_id>', methods = ['GET'])
def delete(record_id):
    table_name = request.args.get('table_name', 'null')
    record_col = request.args.get('record_col', 'null')

    allowed_tables = get_allowed_tables()
    if table_name not in allowed_tables:
        return redirect(url_for('index'))
    if table_name == 'null':
        return redirect(url_for('index'))
    
    allowed_columns = get_allowed_columns(table_name)
    if record_col not in allowed_columns:
        return redirect(url_for('index', table_name = table_name))
    if record_col == 'null':
        return redirect(url_for('index', table_name = table_name))
    
    query = f"DELETE FROM {table_name} WHERE {record_col} = :record_id"

    cursor = connection.cursor()
    cursor.execute(query, {'record_id' : record_id})
    connection.commit()
    cursor.close()

    return redirect(url_for('index', table_name = table_name))

@app.route('/cerinta_c', methods = ['GET', 'POST'])
def cerinta_c():
    cursor = connection.cursor()

    query = "select sedinta_id, nume_angajat || ' ' || prenume_angajat as Profesor, 'Str. ' || strada || ', nr. ' || numar_locatie || ', et. ' || etaj || ', nr_sala. ' || numar_sala as Sala from sedinte join sali using (sala_id) join locatii using (locatie_id) join orase using (oras_id) join angajati on (CNP = profesor) where upper(denumire_oras) = 'BUCURESTI' and to_char(data_ora, 'yyyy') = '2023'"

    cursor.execute(query)
    records = cursor.fetchall()
    cursor.close()

    return render_template('cerinta_c.html', records = records)

@app.route('/cerinta_d', methods = ['GET', 'POST'])
def cerinta_d():
    cursor = connection.cursor()

    query = "select nume_elev, prenume_elev, sum(pret) as Suma from elevi join facturi on (elev = CNP) join sedinte using (sedinta_id) group by nume_elev, prenume_elev having sum(pret) > 200"

    cursor.execute(query)
    records = cursor.fetchall()
    cursor.close()

    return render_template('cerinta_d.html', records = records)


@app.route('/cerinta_f', methods = ['GET', 'POST'])
def cerinta_f():
    view_name = request.args.get('view_name', 'PROFESORI')

    allowed_views = get_allowed_views()
    if view_name not in allowed_views:
        view_name = 'PROFESORI'
    
    allowed_columns = get_allowed_columns(view_name)

    query = f"SELECT * FROM {view_name}"

    cursor = connection.cursor()
    cursor.execute(query)
    records = cursor.fetchall()
    cursor.close()

    return render_template('cerinta_f.html', view_name = view_name, records = records, allowed_views = allowed_views, allowed_columns = allowed_columns)



if __name__ == '__main__':
    app.run(debug=True)
