#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;
use Getopt::Long qw(GetOptions);
use Data::Printer;
use Switch;
use lib './lib';
use Local::User;
use Local::Post;
use Local::Commentors;
use Local::Self_commentors;


my $command = $ARGV[0] or die "no command";
my %options;
GetOptions(
	'format=s' => \$options{'format'},
	'refresh:s' => \$options{'refresh'},
	'name=s' => \$options{'name'},
	'post=s' => \$options{'post'},
	'id=s' => \$options{'id'},
	'n=i' => \$options{'n'},

);
$options{'format'} = 'json' if !$options{'format'};
$options{'refresh'} = 1 if defined $options{'refresh'};
p %options;
my $obj;
if ($command eq 'user' && !$options{'post'}){
	$obj = Local::User->new(
		info => $options{'name'},
		format => $options{'format'},
		refresh => $options{'refresh'},

	);

} elsif ($command eq 'self_commentors' || 
			($command eq 'desert_posts' && $options{'n'})){
	$options{'n'} = 0 if (!$options{'n'});
	$obj = Local::Self_commentors->new(
		format => $options{'format'},
		command => $command,
		n => $options{'n'},
	);
} elsif ($command eq 'commenters' && $options{'post'}){
	$obj = Local::Commentors->new(
		info => $options{'post'},
		format => $options{'format'},
		refresh => $options{'refresh'},
		command => $command,
	);
}elsif ($command eq 'user' || $command eq 'post'){
	my $info;
	if ($command eq 'user'){
	  $info = $options{'post'};
	}
	else {$info = $options{'id'}};
	
	$obj = Local::Post->new(
		info => $info,
		format => $options{'format'},
		refresh => $options{'refresh'},
		command => $command,
	);
}
else {
	die 'error';
}

$obj->run();


