#!/usr/bin/perl
use strict;
use warnings;
use v5.10;
 
use DBI;

my $dsn = "DBI:mysql:my_db";
my $username = "root";
my $password = 'qwerty7gas';

# connect to MySQL database
my %attr = (PrintError=>0, RaiseError=>1);
 
my $dbh = DBI->connect($dsn,$username,$password, \%attr);

# create table statements
my @ddl =     (
 # create tags table
 "CREATE TABLE users (
  id int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  username  varchar(12) NOT NULL,
  project_ref  varchar(255) NOT NULL,
  password varchar(40) NOT NULL
         ) ENGINE=InnoDB",
  "CREATE TABLE session (
  id char(40) NOT NULL,
  session_data text,
  last_active timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
		 ) ENGINE=InnoDB DEFAULT CHARSET=utf8",
	);

# execute all create table statements	       
for my $sql(@ddl){
  $dbh->do($sql);
}  

# disconnect from the MySQL database
$dbh->disconnect();


