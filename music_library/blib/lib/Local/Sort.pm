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

sub my_sort{
	my ($arr_ref,$sort_key) = @_;
	given ($sort_key) {
		when($sort_key eq "year"){
		    @$arr_ref = sort {$a->{"year"} <=> $b->{"year"}} @$arr_ref;
		    p @$arr_ref;
		}
		default {
			@$arr_ref = sort {$a->{$sort_key} cmp $b->{$sort_key}} @$arr_ref;
		    p @$arr_ref;
		}
	}
}

sub filter{
	my ($arr_ref,@filter_params) = @_;
	for my $hash(@$arr_ref){
		print $hash ->{$filter_params[0]};
	}
}	

1;
