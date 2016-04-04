package Sort_and_filter;
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
	if ($sort_key){
		given ($sort_key) {
			when($sort_key eq 'year'){
				if (@$arr_ref){
					 @$arr_ref = sort {$a->{$sort_key} <=> $b->{$sort_key}} @$arr_ref;
				}
			   
			}
			default {
				if (@$arr_ref){
					@$arr_ref = sort {$a->{$sort_key} cmp $b->{$sort_key}} @$arr_ref ;
				}
			}
		}

	}
	
}
sub search{
	my ($arr_ref,$i,$column,$column_value) = @_;
	${$arr_ref}[$i] ->{$column} =~ s/^\s+//;
	${$arr_ref}[$i] ->{$column} =~ s/\s+$//;
	if ($column_value ne '') {  
		if ($column eq 'year'){
			if (${$arr_ref}[$i] ->{$column} + 0 != $column_value){
				return 0;
			}
		}
		elsif ( ${$arr_ref}[$i] ->{$column} ne $column_value ){ 
			return 0;
		} 
	}
	return 1;
}

sub filter{
	my ($arr_ref,$band,$year,$album,$track,$format) = @_;
	my %length_hash;
	for my $i (0..$#{$arr_ref}) {
		if (search($arr_ref,$i,'band',$band) && search($arr_ref,$i,'year',$year) &&
		search($arr_ref,$i,'album',$album) && search($arr_ref,$i,'track',$track) &&
		search($arr_ref,$i,'format',$format) ){
			if (%length_hash){
				for my $key(keys %length_hash){
					if ($length_hash{$key} < length ${$arr_ref}[$i] ->{$key}){ 
						$length_hash{$key} =  length ${$arr_ref}[$i] ->{$key};
					}
				}

			}
			else {
				@length_hash{qw(band year album track format)} = (
					do{length ${$arr_ref}[$i] ->{'band'}},
					do{length ${$arr_ref}[$i] ->{'year'}},
					do{length ${$arr_ref}[$i] ->{'album'}},
					do{length ${$arr_ref}[$i] ->{'track'}},
					do{length ${$arr_ref}[$i] ->{'format'}}
					)
			}			
			next;
		}
		else {
			delete ${$arr_ref}[$i];
		}
	}
	return \%length_hash;
}	

1;
