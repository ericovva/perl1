package Local::Habr;

use strict;
use warnings;
use 5.010;
use Data::Printer;
use Mouse;
use JSON::XS;

has command => (
	is => 'rw',
	isa => 'Str',
);
has format => (
	is => 'rw',
	isa => 'Str',
);
has refresh => (
	is => 'rw',
	isa => 'Bool',
);
has result => (
	is => 'rw',
	isa => 'HashRef'
);

sub printer{
	my ($self) = @_;
	#p $self->result;
	my $jsonl = encode_json $self->result;
	if ($self->format eq 'json'){
		my $json = decode_json $jsonl;
		p $json;
	}
	else {
		say $jsonl;
	}

}

1;
