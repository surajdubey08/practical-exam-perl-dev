# Practical Exam

### Perl Script Workflow

The script uses the DBI module to connect to the MySQL database, reads the CSV file line by line, and inserts the employee and phone records into the database.

For each line in the CSV file, the script performs the following steps:

1.  Split the line into individual fields using the `split` function.
2.  Insert the employee record into the `employee` table using the `insertEmployeeDetails` subroutine.
3.  Get the ID of the newly inserted employee record.
4.  Insert the phone record into the `phone` table using the `insertPhoneDetails` subroutine.

The script generates a unique comment for each employee by **concatenating the first three characters of their first and last names**. It also uses the `localtime` function to get the current date/time for the `created_on` field.


### Usage

To use this script, follow these steps:

1.  Create a MySQL database with the `employee` and `phone` tables.
2.  Update the `$inputFile`, `$dsn`, `$username`, and `$password` variables in the script to match your setup.
3.  Run the script using the `perl` command: `perl script.pl`

### Subroutines

The script defines the following subroutines:

#### `MAIN`

The main subroutine that reads the input file, connects to the database, and inserts the records.

#### `connectToDB`

A subroutine that connects to the MySQL database using the DBI module and returns a database handle.

#### `insertEmployeeDetails`

A subroutine that inserts an employee record into the `employee` table and returns the ID of the newly inserted record.

#### `insertPhoneDetails`

A subroutine that inserts a phone record into the `phone` table.
