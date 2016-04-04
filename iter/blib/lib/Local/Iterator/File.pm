package Local::Iterator::File;
use Mouse;
use strict;
use warnings;
use Data::Printer;
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
sub all{
	my ($self) = @_;
	my $fh = $self->fh;
	my @res;
	while(<$fh>){
		chomp;
		push (@res,$_);
	}
	return \@res;
}
1;
