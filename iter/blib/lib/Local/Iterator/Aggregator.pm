package Local::Iterator::Aggregator;
use Mouse;
use strict;
use warnings;
use Data::Printer;
use Mouse;
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
	@result? return (\@result,$end) : return (undef,1);
}
sub all{
	my ($self) = @_;
	my @result;
	my ($next,$end);
	while(!$end){
		($next,$end) = $self->next();
		push (@result,$next);
	}
	return \@result;

}

1;
