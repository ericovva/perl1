package Local::HabrWeb;

use strict;
use warnings;
use 5.010;
use Data::Printer;
use Mouse;
use LWP::UserAgent;
use HTTP::Request;
use Mojo::DOM;
use Local::Habr;
use Habr::Schema;
my $schema = Habr::Schema->connect("dbi:mysql:dbname=habr", "root", "qwerty7gas");
extends 'Local::Habr';

has info => (
	is => 'rw',
	isa => 'Str'
);

has link_ref => (
	is => 'rw',
	isa => 'Str',
	builder => 'detect_link',
);
sub site_get{
	my ($self) = @_;
	say 'Sending request to '. $self->link_ref .' ...';
	my $request = HTTP::Request->new(GET => $self->link_ref);
	my $ua = LWP::UserAgent->new;
 	my $response = $ua->request($request);
 	my $dom = Mojo::DOM->new($response->content);
 	return \$dom;
}
sub add_to_db{
	my ($self,$table,$pk,$pk2) = @_;
	my $entity;
	if ($self->refresh){
		my $poles = { $pk => $self->info };
		$poles->{$pk2} = $self->info2 if ($pk2);
		my $search = $schema->resultset($table)->search($poles);
		$search->update($self->result);
		$entity = $search->next;
		say "Update entity $pk = " . $self->info . " in table $table";
	}
	if (!$entity){
		$entity = $schema->resultset($table)->create($self->result);
		say "Create entity $pk = " . $self->info . " in table $table";
	}
	$self->result->{id} = $entity->id;
}
1;
