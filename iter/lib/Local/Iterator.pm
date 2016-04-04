package Local::Iterator;
use Mouse;
sub all{
	my ($self) = @_;
	my ($next,$end) = $self->next();
	my @ar;
	while(!$end){
		push(@ar,$next);
		($next,$end) = $self->next();
	} 
	return \@ar;
}
1;