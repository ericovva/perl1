package Web::App;
use Dancer2;
use Dancer2::Plugin::Database;
use Data::Printer;
use Dancer2::Session::Memcached;
use Data::Validate::Domain;
use Dancer2::Plugin::Auth::HTTP::Basic::DWIW;
use Digest::MD5 qw(md5 md5_hex md5_base64);
use Dancer::Plugin::EscapeHTML;

our $VERSION = '0.1';
my $auth = 0;
get '/' => sub {
 	#my @aa = database->quick_select('auth_user', {});
 	#p @aa;
 	my $name = 'who are you?';
 	$auth = 0;
 	if (session('user')) {
 		$name = 'I was missed you ' . session('user');
 		$auth = 1;
 	}
    template 'index', { name => $name,auth => $auth };
};
get '/auth' => sub {
    template 'auth', { error => '' };
};
get '/reg' => sub {
    template 'reg' , { error => '' };
};
get '/profile' => sub {
	if (! session('user')) {
		redirect '/auth';
	}
    template 'profile', { username => session('user'), auth => $auth, message => '' };
};
get '/token' => sub {
	auth_check();
	my $user = database->quick_select('users',{username => session('user') });
	my $token = $user->{token};
    template 'token', { auth => $auth, token => $token};
};
http_basic_auth_set_check_handler sub {
        my ( $user, $pass ) = @_;
        my $db_user = database->quick_select('users',{username => session('user') });
        # you probably want to check the user in a better way
        if ( !$db_user->{token} ){
        	return 0;
        }
        return $user eq $db_user->{username} && $pass eq $db_user->{token};
};

get '/logout' => sub {
	$auth = 0;
	my $name = 'who are you?';
	app->destroy_session;
	template 'index' , { name => $name,auth => $auth };
};
post '/reg' => sub {
	my $username = param 'username';
	$username = escape_html($username);
	my $password1 = param 'password1';
	my $password2 = param 'password2';
	my $link = param 'link';
	$link = escape_html($link);
	my $real_link = $link;
	$link =~ s{https://}{}; 
	$link =~ s{http://}{}; 
	$link =~ s{www.}{};
	my $error = q(Mistake in the form!);
	if (! ($link =~ m{(//)+} || $link =~ m{(\.\.)+})){
			$link =~ s{/[\w\.\D]+}{};
			print "LINK TO COMPARE $link\n";
	}
	if (database->quick_count('users', {username => $username}) <= 0){

		if ($username =~ m/[A-z]+/ && ($password1 eq $password2) 
			&& $password1 ne '' && ( ($link eq "") || is_domain($link) ) 
		   )
		{
			my $hash = { 
				username => $username,  
				password => md5_base64($password1),
				project_ref => $real_link,
				rate_limits => 10
			};
			p $hash;	
			database->quick_insert('users', $hash);
			redirect '/auth';
		}

	}
	else {
		$error = q(Alreadey exists!);
	}
	print "\n$username $password1 $password2 $link\n"; 
	template 'reg' , { error => $error };
};
post '/auth' => sub {
	p request->header('X-CSRF-Token');
	my $username = param 'username';
	my $password = param 'password';
	my $user = database->quick_select('users',{username => $username });
	p $user;
	if ($user && $user->{password} eq md5_base64($password)){
		session user => $username;
		session link => $user->{project_ref};
		redirect '/';
	}
	print "\n$username $password\n";
	template 'auth', {error => q(Password || Username is incorrect)};
};
post '/change_username' => sub {
	my $username = param 'username';
	my $error = q(Username was updated successfully!);
	$username = escape_html($username);
	if (database->quick_count('users', {username => $username}) <= 0){
		my $var = database->quick_update('users', 
								{ username => session('user')}, 
								{ username => $username }
		);
		if ($var){
			session user => $username;
		}
		else {
			$error = 'incorrect username';
		}
		
	}
	else {
		$error = q('Username already exists');
	}
	template 'profile', { username => session('user'), auth => $auth, message => $error};
};
post '/change_link' => sub {
	my $link = param 'link';
	$link = escape_html($link);
	my $real_link = $link;
	$link =~ s{https://}{}; 
	$link =~ s{http://}{}; 
	$link =~ s{www.}{};
	my $error = q(Link was updated successfully!);
	if (! ($link =~ m{(//)+} || $link =~ m{(\.\.)+})){
			$link =~ s{/[\w\.\D]+}{};
			print "LINK TO COMPARE $link\n";
	}
	if (is_domain($link) ){
		my $var = database->quick_update('users', 
							{ username => session('user')}, 
							{ project_ref => $real_link }
		);
		if ($var){
			$error = q(Link was changed);
			session link => $real_link;
		}
	}
	else {
		$error = q('Link is incorrect');
	}

	template 'profile', { username => session('user'), auth => $auth, message => $error }
};
post '/change_password' => sub {
	my $old_pass = param 'password0';
	my $pass1 = param 'password1';
	my $pass2 = param 'password2';
	my $message = "Password was updated successfully";
	my $user = database->quick_select('users',{username => session('user') });
	if ( $pass1 ne '' && $pass1 eq $pass2 && md5_base64($old_pass) eq $user->{password}){
		database->quick_update('users', 
							{ username => session('user')}, 
							{ password => md5_base64($pass1) }
		);
	}
	else {
		$message = "Error, please enter correct data";
	}
	template 'profile', { username => session('user'), auth => $auth, message => $message }
};
#______XML-RPC______

post '/token' => sub {
	auth_check();
	my $token = md5_base64(rand(0xffffffff));
	my $l = length session('user');
	p $l;
	substr $token , 5, $l, session('user');
	my $now = DateTime->now;
	my $time = $now->ymd . ' ' . $now->hms;
	database->quick_update('users', 
		{ username => session('user')}, 
		{ token => $token, token_time => $time }
	);
	my $user = database->quick_select('users',{username => session('user') });
	template 'token', { auth => $auth, token => $token};
};
use Frontier::Client;
get '/xml-rpc' => http_basic_auth required => sub {
	 my ( $user, $pass ) = http_basic_auth_login;
	 my $user_db = database->quick_select('users',{username => session('user') });
	 template 'xml-rpc', { auth => $auth, rate_limits => $user_db->{rate_limits} };
};
post '/exec' => sub {
	my $expression = param 'expression';
	auth_check();
	# Make an object to represent the XML-RPC server.
	my $server_url = 'http://localhost:8080/RPC2';
	my $server = Frontier::Client->new(url => $server_url);
	my $user = database->quick_select('users',{username => session('user') });
	my $limits = $user->{rate_limits};
	my $answer;
	if ($limits > 0) {
		$limits-=1;
		database->quick_update('users',{username => session('user') },{rate_limits => $limits});
		# Call the remote server and get our result.
		my $result = $server->call('sample.calc', $expression);
		$answer = $result->{'answer'};
	}
	else {
		$answer = "No rate-limits";
	}
	template 'xml-rpc', { auth => $auth, answer => $answer, rate_limits => $limits };

};
#___XML_RPC from request___
use MIME::Base64;
use XML::RPC;
use CGI;
use DateTime;
use 5.010;
post '/xml' => sub {
	$_ = request->header('WWW-Authenticate');
	my $body = request->body;
	my $token = (split)[1] . "\n"; p $token;
	my @users = database->quick_select('users',{});
	my $access = 0;
	for my $user(@users){
		p encode_base64($user->{token});
		if (encode_base64($user->{token}) eq $token){
			my $limits = $user->{rate_limits};
			my $now = DateTime->now;
			my $time = $now->ymd . ' ' . $now->hms; #YYYY-MM-DD HH:MM:SS <-My sql
			#my $last_time =  
			database->quick_update('users',{token => $user->{token} },{rate_limits => $limits});
			if ($limits > 0) {
				$limits-=1;
				database->quick_update('users',{token => $user->{token} },{rate_limits => $limits,token_time => $time});
				my $q  = new CGI;
			    my $xmlrpc = XML::RPC->new(); p $body;
			    my $xml = $body;
			    return $xmlrpc->receive( $xml, \&handler );
			}
			else {
				return "No rate-limits\n";
			}
			last;
		}
	}	
};
sub handler {
        my ( $methodname, @params ) = @_;
        p $methodname; p @params;
        my $answer;
        my $server_url = 'http://localhost:8080/RPC2';
		my $server = Frontier::Client->new(url => $server_url);
		my $result = $server->call($methodname, $params[0]);
		$answer = $result->{'answer'};
		#p $answer;
		return {answer => $answer};
        #return { you_called => $methodname, with_params => \@params };
}
#____________________
sub auth_check{
	my ($check) = @_;
	$auth = 0;
	if (session('user')) {
 		$auth = 1;
 		return;
 	}
 	redirect '/auth';
}

true;
