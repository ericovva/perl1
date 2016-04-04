package Local::Iterator::File;
use Mouse;
use Local::Iterator;

extends 'Local::Iterator';
has 'filename' => (is => 'ro',isa => 'Str');
has 'fh' =>(is => 'rw',isa => 'FileHandle',
			builder => 'open_file');
sub open_file{
	my ($self) = @_;
	if ($self->filename){
		open(my $fh,'<',$self->filename);
		return $fh;
	}
}
sub next{
	my ($self) = @_;
	my $fh=$self->fh;
	if (defined(my $st = <$fh>)) {
		chomp($st);
		return ($st,0);
	}
	return (undef,1);

}
1;
