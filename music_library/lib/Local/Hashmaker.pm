use 5.010;  # for say, given/when
use strict;
use warnings;
use Data::Printer;
BEGIN{
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
}
no warnings 'experimental';
use Data::Printer;
sub make_hash{ 
	my ($str) = @_; 
	my ($band,$year_album,$track_format) = split m{[/]}, (substr $str,2);
	my %entity; 
	@entity{qw(band year album track format)} = (
		$band,
		do{split m{[-]},$year_album},
		do{split m{[.]},$track_format}
		);
	return %entity;
}

1;