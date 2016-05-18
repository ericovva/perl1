package Local::Self_commentors;

use strict;
use warnings;
use 5.010;
use Data::Printer;
use Mouse;

my $schema = Habr::Schema->connect("dbi:mysql:dbname=habr", "root", "qwerty7gas");
extends 'Local::Habr';
has n => (
	is => 'rw',
	isa => 'Int',
);
has format => (
	is => 'rw',
	isa => 'Str',
);

sub run{
	my ($self) = @_;
	if ($self->command eq 'self_commentors'){
		$self->run_self;
	}
	else {
		$self->run_desert;
	}
}

sub run_self{
	my ($self) = @_;
	my @posts = $schema->resultset('Post')->all;
	for my $post(@posts){ 
		my $s=$schema->resultset('Comment')->search({
			author => $post->author->id,
			post => $post->id,
		}); my $comment = $s->next;
		my %hash;
		if ($comment){
			$hash{username} = $comment->author->username;
			$hash{karma} = $comment->author->karma;
			$hash{rating} = $comment->author->rating;
			$self->result(\%hash);
			$self->printer;
		}
	}
}
sub run_desert{
	my ($self) = @_;
	my @posts = $schema->resultset('Post')->all;
	my %hash;
	$self->result(\%hash);
	for my $post(@posts){
		my $s = $schema->resultset('Comment')->search({
			post => $post->id,
		}); my $count = $s->count;
		if ($count < $self->n){
			$hash{author} = $post->author->username;
			$hash{theme} = $post->theme;
			$hash{rating} = $post->rating;
			$hash{stars} = $post->stars;
			$hash{views} = $post->shows;
			$self->printer;
		}
	}
}

1;
