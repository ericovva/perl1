package Local::Iterator::Aggregator;
use Mouse;
use lib::Local::Iterator::Iterator;

extends 'Local::Iterator::Iterator';
has 'iterator' => (is => 'ro', isa => 'Object');
has 'chunk_length' => (is => 'ro', isa => 'Int');
sub next{
	my ($self) = @_;
	my @result;
	my ($next,$end);
	for (1..$self->chunk_length){
		($next,$end) = $self->iterator->next();
		if ($end){
			last;
		}
		push(@result,$next);
		
	}
	@result? return (\@result,0) : return (undef,1);
}

1;
