package Web::Admin;
use Dancer2;
use Dancer2::Plugin::Database;
use Data::Printer;
use Dancer2::Session::Memcached;
use Data::Validate::Domain;
use Dancer2::Plugin::Auth::HTTP::Basic::DWIW;
use Digest::MD5 qw(md5 md5_hex md5_base64);

our $VERSION = '0.1';

set layout => 'main2';
my $auth = 0;
hook before => sub {
	if (! (session('user') && session('access')) && request->dispatch_path !~ m{^/auth} ){
		redirect '/auth';
	}
};
get '/' => sub {
	my @users = database->quick_select('users',{});
    template "admin/index", {auth => $auth, users => \@users};
};
get '/rate-limits' => sub {
	my @users = database->quick_select('users',{});
	template 'admin/rate-limits', {auth => $auth, users => \@users};
};
get '/users' => sub {
	my @users = database->quick_select('users',{});
	template 'admin/users',  {auth => $auth, users => \@users};
};
get '/auth' => sub {
	template 'admin/auth';
};
post '/change_rate' => sub {
	my $username = param 'username';
	my $limit = param "rate_limit_count_$username"; $limit += 0; 
	p $limit;
	my $error;
	database->quick_update('users', { username => $username },{ rate_limits => $limit });
	$error = "success, rate limits of $username was changed";
	my @users = database->quick_select('users',{});
	template 'admin/rate-limits',  {auth => $auth, users => \@users, error => $error};
};
post '/delete' => sub {
	my $username = param 'username';
	my $error;
	if ($username eq session('user')){
		$error = "YOU CAN'T DELETE YOURSELF, BECAUSE YOU'RE BIG ADMIN";
	}
	else {
		database->quick_delete('users', { username => $username });
		$error = "success, $username was deleted";
	}
	my @users = database->quick_select('users',{});
	template 'admin/users',  {auth => $auth, users => \@users, error => $error};
};

post '/auth' => sub {
	my $username = param 'username';
	my $password = param 'password';
	my $user = database->quick_select('users',{username => $username });
	p $user;
	if ($user && $user->{password} eq md5_base64($password) && $user->{access}){
		session user => $username;
		session access => 1;
		$auth = 1;
		redirect '/';
	}
	template 'admin/auth', {error => q(Password || Username is incorrect)};
};
true;
