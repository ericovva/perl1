package Local::Commentors;

use strict;
use warnings;
use 5.010;
use Data::Printer;
use Mouse;
use Local::HabrWeb;
use Local::Models;
use Habr::Schema;
use Local::User;
extends 'Local::HabrWeb';
my $schema = Habr::Schema->connect("dbi:mysql:dbname=habr", "root", "qwerty7gas");
has info2 => (
	is => 'rw',
	isa => 'Str'
);
sub detect_link{
	my ($self) = @_;
	$self->link_ref ('https://habrahabr.ru/post/' . $self->info);
}

sub run {
	my ($self,$get) = @_;
	my $users = $self->get_from_db();
	my $post;
	if (!$users || $self->refresh){
		$users = $self->get_post_info_from_site;
		$post = Local::Post->new(
			info => $self->info,
			format => $self->format,
			refresh => $self->refresh,
		);
		$post->get;
		$self->info($post->result->{id});
	}
	my $user = Local::User->new(
			info => '',
			format => $self->format,
			refresh => $self->refresh,
	);
	for my $tmp(keys $users){
		$user->change_user($tmp);
		if ($get){ $user->get;}
		else { $user->run;} 	
		if ($self->refresh || $post){
			$self->result({ 
				author => $user->result->{id},
				post => $post->result->{id}
			});
			if ($user->result->{id}){
				$self->info2($user->result->{id});
			}
			else {
				$self->info2(0);
			} 
			$self->add_to_db('Comment','post','author');

		}
	}

}

sub get_post_info_from_site{
	my ($self) = @_;
	my %info;
	my $dom = $self->site_get();
 	my @ar = $$dom->find('.comment_body')->each;
 	my $i = 0;
 	my %users;
 	for my $div(@ar){
 	  	$_ = $div->find('.comment-item__username')->map('text')->join("\n");
 		if (!$users{"$_"}){
 			$users{"$_"} = defined;
 			#$user->change_user("$_");
 			#$user->run;
 		}
 	}
 	return \%users;
}
sub get_from_db{
	my ($self) = @_;
	my $search = $schema->resultset('Post')->search(
	    { post_id => $self->info }
	);
	my $post;
	my %users;
	if ($post = $search->next){
		$search = $schema->resultset('Comment')->search(
	    	{ post => $post->id }
		);
		my $comment;
		while ($comment = $search->next){
			$users{$comment->author->username} = undef;
		}
	} 
	if (%users){
		return \%users;
	}
	return 0;
	
}

1;
