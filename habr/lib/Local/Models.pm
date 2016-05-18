package Local::UserModel;
use 5.010;
use Mouse;
has username => (
	is => 'rw',
	isa => 'Str'
);
has karma => (
	is => 'rw',
	isa => 'Num'
);
has rating => (
	is => 'rw',
	isa => 'Num'
);

sub save_to_db{
	my ($self) = @_;
	say "save to db";
}

1;
