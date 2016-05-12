#!/usr/bin/perl

use strict;
use lib::Local::App::GenCalc;
use lib::Local::App::ProcessCalc;
use lib::Local::App::Calc;
use IO::Socket;
use Time::HiRes qw/alarm/;
package Main;
# $SIG{ALRM} = sub {
#     print "new_one\n";
#     Local::App::GenCalc::new_one();
#     alarm(1);
# };
our $pid;
our $pid2;
our $pid3;
$SIG{INT} = sub {
	print "kill all\n";
	kill (9,-$$);
};
if (!($pid3 = fork())){
    Local::App::Calc::start_server(9999);
    exit;
}

if($pid = fork()){
    print "welcome\n";
    while(1){
        sleep(1);
        print("gen\n");
        Local::App::GenCalc::new_one();
    }
}
else {
    if ($pid2 = fork()){
    	Local::App::GenCalc::start_server(9899);
    }
    else {
        #while (1) {
        sleep(1);
    	my $ref = Local::App::ProcessCalc::get_from_server(9899,10);
    	Local::App::ProcessCalc::multi_calc(3,$ref,9999);
            #}
    	exit;
    	
    }
    
}





