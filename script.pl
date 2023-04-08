#!/usr/bin/perl

use strict;
use warnings;
use DBI;

MAIN: {
    my $inputFile = "../inputData/inputData.csv";
    # my $inputFile = "D:/practical-exam-perl-dev/inputData/inputData.csv";
    open my $fileHandler, "<", $inputFile or die "Could not open the inputData.csv file. Reason: $!";

    my $databaseHandler = connectToDB();
    while (my $currentInputLine = <$fileHandler>) {
        chomp $currentInputLine;
        next if $. == 1; # skip the header line
        my @columnFields = split /,/, $currentInputLine;
        my $employeeID = insertEmployeeDetails($databaseHandler, @columnFields);
        insertPhoneDetails($databaseHandler, $employeeID, $columnFields[3]);
    }

    $databaseHandler->disconnect;
    close $fileHandler;
}

sub connectToDB {
    my $dsn = "DBI:mysql:database=practicalDB;host=localhost";
    my $username = "admin";
    my $password = "practicalExam@@0804";
    my $databaseHandler = DBI->connect($dsn, $username, $password) or die "Could not connect with the database. Reason: $DBI::errstr";
    return $databaseHandler;
}

sub insertEmployeeDetails {
    my ($databaseHandler, $employeeFirstName, $employeeLastName, $age) = @_;
    my $uniqueComment = substr($employeeFirstName, 0, 3) . substr($employeeLastName, 0, 3); # generate unique comment for each record
    my $createdOn = localtime(); # current datetime to insert

    #| Column Name | Data Type | Description |
    #|--|--|--|
    #| id | INT | Unique identifier for the employee |
    #| firstname | VARCHAR | First name of the employee |
    #| lastname | VARCHAR | Last name of the employee |
    #| age | INT | Age of the employee|
    #| created_on | DATETIME | Datetime the employee record was created |
    #| comments | VARCHAR | Unique comment for the employee |

    # insert employee record
    my $command = $databaseHandler->prepare("INSERT INTO employee (firstname, lastname, age, created_on, comments) VALUES (?, ?, ?, ?, ?)");
    $command->execute($employeeFirstName, $employeeLastName, $age, $createdOn, $uniqueComment);
    return $databaseHandler->last_insert_id(undef, undef, 'employee', 'id'); # get last inserted ID
}

sub insertPhoneDetails {
    my ($databaseHandler, $employeeID, $phoneNumber) = @_;

    # | Column Name | Data Type | Description |
    # |--|--|--|
    # | id  | INT | Unique identifier for the employee |
    # | person_id | INT | ID of the employee associated with the phone number |
    # | phone_number | INT | Phone number of the employee |

    # insert phone record
    my $command = $databaseHandler->prepare("INSERT INTO phone (person_id, phone_number) VALUES (?, ?)");
    $command->execute($employeeID, $phoneNumber);
}
