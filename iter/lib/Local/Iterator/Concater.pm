package Local::Iterator::Concater;
use Mouse;
use Local::Iterator;

extends 'Local::Iterator';
has 'iterators' => (is => 'rw',isa => 'ArrayRef');
has 'current' => (is => 'rw',isa => 'Int',default => 0);
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

1;
