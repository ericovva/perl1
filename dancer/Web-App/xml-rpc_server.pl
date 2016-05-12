use Frontier::Daemon;
use FindBin;
require "$FindBin::Bin/Calc/evaluate.pl";
require "$FindBin::Bin/Calc/rpn.pl";

sub calc {
    my ($exp) = @_;
    my $rpn = rpn($exp);
	my $value = evaluate($rpn);
    if ($value){
        return {'answer' => $value};
    }
    else {
        return {'answer' => "NaN"};
    }
    
}

# Call me as http://localhost:8080/RPC2
$methods = {'sample.calc' => \&calc};
Frontier::Daemon->new(LocalPort => 8080, methods => $methods)
    or die "Couldn't start HTTP server: $!";
