package Local::User;

use strict;
use warnings;
use 5.010;
use Data::Printer;
use Mouse;
use lib './lib';
use Local::HabrWeb;
use Local::Models;
use Habr::Schema;
extends 'Local::HabrWeb';

my $schema = Habr::Schema->connect("dbi:mysql:dbname=habr", "root", "qwerty7gas");


sub detect_link{
	my ($self) = @_;
	$self->link_ref ('https://habrahabr.ru/users/' . $self->info);
}
sub get{
	my ($self,$option) = @_;
	my $search = $schema->resultset('User')->search(
	    { username => $self->info }
	);my $user = $search->next;
	## memcach, or db, or site	
	if (!$user || $self->refresh){
		$self->result($self->get_user_info_from_site());
		if ($self->result->{username}){
			$self->add_to_db('User','username');
		}
		else {
			$self->result({user => 'No such user'});
		}
	}
	else {
		$self->result({
			id => $user->id,
			user => $user->username,
			rating => $user->rating,
			karma => $user->karma
		});
	}
	return $self->result;
}
sub run{
	my ($self) = @_;
	$self->get;
	$self->printer;
}

sub change_user{
	my ($self,$username) = @_;
	$self->info($username);
	$self->detect_link;
}

sub get_user_info_from_site{
	no warnings;
	my ($self) = @_;
	my %info;
	my $dom = $self->site_get();
	$_ = $$dom->find('title')->map('text')->join("\n");
 	$info{'username'} = (split)[2];
 	$_ = $$dom->find('.voting-wjt__counter-score')->map('text')->join("\n");
 	$info{'karma'} = "$_" + 0.0;
 	$_ = $$dom->find('.statistic__value_magenta')->map('text')->join("\n");
 	$info{'rating'} = "$_" + 0.0;
 	return \%info;
}

1;
