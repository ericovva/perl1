package Local::Post;

use strict;
use warnings;
use 5.010;
use Data::Printer;
use Mouse;
use Local::HabrWeb;
use Local::Models;
use Habr::Schema;
use Local::User;
use Local::Commentors;
extends 'Local::HabrWeb';
my $schema = Habr::Schema->connect("dbi:mysql:dbname=habr", "root", "qwerty7gas");
my $user;
sub detect_link{
	my ($self) = @_;
	$self->link_ref ('https://habrahabr.ru/post/' . $self->info);
}

sub get{
	my ($self) = @_;	

	my $search = $schema->resultset('Post')->search(
	    { post_id => $self->info }
	);my $post = $search->next;

	if (!$post || $self->refresh){
		$self->get_post_info_from_site();
		if ($self->result->{author}){
			$self->result->{author} = $self->get_user->{id};
			$self->add_to_db('Post','post_id');
		}
		else {
			$self->result({post => 'No such post'});
		}
	}
	else {
		$self->get_post_from_dbi($post);
	}
}
sub run{
	my ($self) = @_;
	$self->get;
	if ($self->command eq 'user' && $self->result->{author}){
		if (!$user){
			$self->get_user;
		}
		$self->result($user);
	}
	else {
		$self->get_comments;
	}
	$self->printer();
}
sub get_comments{
	my ($self) = @_;
	my $obj = Local::Commentors->new(
		info => $self->info,
		format => $self->format,
		refresh => $self->refresh,
		command => 'commenters',
	);
	$obj->run(1);
}
sub get_user{
	my ($self,$option) = @_;
	my $obj = Local::User->new(
			info => $self->result->{author},
			format => $self->format,
			refresh => $self->refresh,

		);
	$user = $obj->get;
}
sub get_post_from_dbi{
	my ($self,$post) = @_;
	$self->result({
			id => $post->id,
			theme => $post->theme,
			shows => $post->shows,
			stars => $post->stars,
			rating => $post->rating,
			post_id => $post->post_id,
			author => $post->author->username,
		});
}
sub get_post_info_from_site{
	my ($self) = @_;
	my %info;
	my $dom = $self->site_get();
 	$_ = $$dom->find('.post-type__value_author')->map('text')->join("\n");
 	if ($_ eq ''){
 		$_ = $$dom->find('.author-info__nickname')->map('text')->last;
 	}
 	if ($_){
 		$info{'author'} = substr $_,1;
 	}
 	else {
 		$info{'author'} = undef;
 	}
 	$_ = $$dom->find('.post_title')->map('text')->join("\n");
 	$info{'theme'} = "$_";
 	$_ = $$dom->find('.views-count_post')->map('text')->join("\n");
 	no warnings;
 	$info{'shows'} = "$_" + 0;
 	$_ = $$dom->find('.favorite-wjt__counter')->map('text')->join("\n");
 	$info{'stars'} = "$_" + 0.0;
 	$_ = $$dom->find('.voting-wjt__counter-score')->map('text')->join("\n");
 	$info{'rating'} = "$_" + 0.0;
 	$info{'post_id'} = $self->info;
 	$self->result(\%info);
 	p $self->result;
 	return;
}


1;
