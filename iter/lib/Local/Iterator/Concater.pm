package Local::Iterator::Concater;

use strict;
use warnings;
use Data::Printer;
use Mouse;
has 'iterators' => (is => 'rw',isa => 'ArrayRef');
has 'current' => (is => 'rw',isa => 'Int',default => sub {return 0});
sub next{
	my ($self) = @_;
	my ($next,$end);
	$self->current <= $#{$self->iterators}?($next,$end) = ${$self->iterators}[$self->current]->next() : return (undef,1);
	if ($end){
		$self->current($self->current + 1);
		if ($self->current > $#{$self->iterators}){
			return (undef,1);
		}
		($next,$end) = ${$self->iterators}[$self->current]->next();
	}
	return ($next,$end);
}
sub all{
	my ($self) = @_;
	my @result;
	my ($next,$end) = $self->next();
	while(!$end){
		push (@result,$next);
		($next,$end) = $self->next();
	}
	return \@result;
}

1;
