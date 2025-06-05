import sqlite3
import pandas as pd

# Connect to your SQLite database
conn = sqlite3.connect("studybuddy.db")
cursor = conn.cursor()

# Get all table names
cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
tables = cursor.fetchall()

# Loop through all tables and write each to its own Excel file
for table in tables:
    table_name = table[0]
    print(f"Exporting table: {table_name}")
    
    # Read the table into a DataFrame
    df = pd.read_sql_query(f"SELECT * FROM {table_name}", conn)
    
    # Save to Excel file
    filename = f"{table_name}.xlsx"
    df.to_excel(filename, index=False)
    print(f"Saved to: {filename}")

# Close the database connection
conn.close()
