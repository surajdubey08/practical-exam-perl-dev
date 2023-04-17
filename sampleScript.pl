#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use Text::CSV;

# MySQL database configuration
my $dsn = "DBI:mysql:database=DATABASE_NAME;host=HOST_NAME";
my $username = "USERNAME";
my $password = "PASSWORD";

# Connect to the database
my $dbh = DBI->connect($dsn, $username, $password) or die "Could not connect to database: $DBI::errstr";

# SQL queries
my $employee_table_query = q{
    CREATE TABLE employee (
        id INT AUTO_INCREMENT PRIMARY KEY,
        firstname VARCHAR(255) NOT NULL,
        lastname VARCHAR(255) NOT NULL,
        age INT NOT NULL,
        created_on DATETIME NOT NULL DEFAULT NOW(),
        comments VARCHAR(255)
    )
};
my $phone_table_query = q{
    CREATE TABLE phone (
        id INT AUTO_INCREMENT PRIMARY KEY,
        person_id INT NOT NULL,
        phone_number VARCHAR(255) NOT NULL,
        FOREIGN KEY (person_id) REFERENCES employee(id)
    )
};
my $employee_data_query = q{
    INSERT INTO employee (firstname, lastname, age, comments)
    VALUES (?, ?, ?, ?)
};
my $phone_data_query = q{
    INSERT INTO phone (person_id, phone_number)
    VALUES (?, ?)
};

# Prepare the data for insertion
my $csv = Text::CSV->new({ binary => 1 }) or die "Could not create CSV parser: $!";
open my $fh, "<", "input.csv" or die "Could not open input file: $!";
my @employees;
while (my $row = $csv->getline($fh)) {
    my $firstname = $row->[0];
    my $lastname = $row->[1];
    my $age = $row->[2];
    my $phone_number = $row->[3];
    my $comments = generate_comments();
    push @employees, [$firstname, $lastname, $age, $comments, $phone_number];
}
close $fh;

# Execute the queries
$dbh->do($employee_table_query) or die "Could not create employee table: $DBI::errstr";
$dbh->do($phone_table_query) or die "Could not create phone table: $DBI::errstr";
my $sth_employee = $dbh->prepare($employee_data_query) or die "Could not prepare employee data query: $DBI::errstr";
my $sth_phone = $dbh->prepare($phone_data_query) or die "Could not prepare phone data query: $DBI::errstr";
foreach my $employee (@employees) {
    $sth_employee->execute(@{$employee}[0..3]) or die "Could not insert employee data: $DBI::errstr";
    my $person_id = $dbh->last_insert_id(undef, undef, 'employee', 'id');
    $sth_phone->execute($person_id, $employee->[4]) or die "Could not insert phone data: $DBI::errstr";
}

# Disconnect from the database
$dbh->disconnect();

sub generate_comments {
    my @chars = ('a'..'z', 'A'..'Z', '0'..'9');
    my $comments = join '', map { $chars[rand @chars] } 1..8;
    return $comments;

  #or use my $uniqueComment = substr($employeeFirstName, 0, 3) . substr($employeeLastName, 0, 3); # generate unique comment for each record
}
