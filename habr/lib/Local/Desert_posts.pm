package Local::Habr;

use strict;
use warnings;
use 5.010;
use Data::Printer;
use Mouse;

has link => (
	is => 'rw',
	isa => 'Str',
);
has format => (
	is => 'rw',
	isa => 'Str',
);
has refresh => (
	is => 'rw',
	isa => 'Str',
);

sub site_get{
	say "go_to_site";
}

1;
