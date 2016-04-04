package Local::Iterator::Array;
use Mouse;
use Iterator;

extends 'Iterator';
has 'array' => (is => 'ro', isa => 'ArrayRef');
has 'current' => (is => 'rw', isa => 'Int', 
				  default => sub {return 0});
sub next{
	my ($self) = @_;
	my $i = $self->current;
	$self->current($i  + 1);
	$i <= $#{$self->array} ? return ((${$self->array}[$i]),0):return (undef,1);
}
1;
