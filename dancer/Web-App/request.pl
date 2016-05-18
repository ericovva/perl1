use strict;
use warnings;
use MIME::Base64;
use LWP::UserAgent; use Data::Printer;
use HTTP::Request::Common;
my $ua = LWP::UserAgent->new;
$ua->timeout(10);
$ua->env_proxy;
 
my $content = qq(
Content-Type: text/xml
Content-Length: 169
<?xml version="1.0"?>
<methodCall>
   <methodName>sample.calc</methodName>
      <params>
         <param>
            <value>1+1+1</value>
         </param>
      </params>
</methodCall>);
my $auth = "Basic " . encode_base64('4J6OkqweRKzCKQxeBZKhMQ');
p $auth;
my $header = 'qwerty7gas';

my $response = $ua->post('http://localhost:5000/xml','WWW-Authenticate' => $auth, Content => $content);

if ($response->is_success) {
    print $response->decoded_content;  # or whatever
}
else {
    die $response->status_line;
}
