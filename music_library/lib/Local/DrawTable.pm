package DrawTable;
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
#no strict; no warnings;
sub make_space{
	my ($str,$max_len) = @_;
	if (length $str < $max_len){
		while (length $str != $max_len) {
			$str = ' ' . $str;
		}
	}
	print ' ' . "$str" . ' ';
}

sub draw{
	my ($arr_ref,$hash_length,$columns) = @_;
	if ($columns eq 'default') {
		$columns= 'band,year,album,track,format';
	} elsif ($columns eq ''){ return; }
	my @cols = split m{[,]}, $columns;
	my $width = 0;
	my $mid = '|';
	for my $c(@cols){
		next if $c =~ /^\s*$/;
		$c =~ s/^\s+//;
		$c =~ s/\s+$//;
		if (${$hash_length}{$c}){
			my $tmp = "-" x (${$hash_length}{$c} + 2);
			$width +=  (${$hash_length}{$c}) + 3;
			$mid = "$mid" . "$tmp" . '+';
		}
		else {return;}
	}
	$width += 1;
  	my $start = '/' . ('-' x ($width - 2)) . "\\\n";
  	my $finish = "\\" . ('-' x ($width - 2)) . "/\n";
	chop $mid; 
	$mid = $mid . "|\n";
	my $first = 1;
	for my $i (0..$#{$arr_ref}) {
		if (${$arr_ref}[$i]){
			if ($first){ print $start; $first=0;}
			print '|';
			for my $c(@cols){
				next if $c =~ /^\s*$/;
				$c =~ s/^\s+//;
				$c =~ s/\s+$//;
				make_space(${$arr_ref}[$i]-> {$c},${$hash_length}{$c});
				print '|';
			}
			print "\n";
			if ($i!=$#{$arr_ref} ){
				print $mid;
			}
			else{
				print $finish;
			}

		}
	}
}
1;