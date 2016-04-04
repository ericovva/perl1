#!/usr/bin/perl

use strict;
use lib::Local::App::GenCalc;
use lib::Local::App::ProcessCalc;
use IO::Socket;
use Time::HiRes qw/alarm/;
use Data::Printer;
$SIG{ALRM} = sub {
    print("new one\n");
    Local::App::GenCalc::new_one();
};


if(my $pid = fork()){   
    my $port = 9899;
    my $server = IO::Socket::INET->new(
        LocalPort => $port,
        Type      => SOCK_STREAM,
        ReuseAddr => 1,
        Listen    => 10) 
    or die "Can't create server on port $port : $@ $/";
    Local::App::GenCalc::new_one();
    Local::App::GenCalc::new_one();
    Local::App::GenCalc::new_one();
    Local::App::GenCalc::new_one();
    Local::App::GenCalc::new_one();
    alarm(100);
    while(my $client = $server->accept()){
        alarm(0);
        my $msg_len;
        if (sysread($client, $msg_len, 2) == 2){
            print("new connect\n");
            my $limit = unpack 'S', $msg_len;
            print ("I must get $limit excercises\n");
            my $ex = Local::App::GenCalc::get($limit);
            syswrite($client, pack('L', scalar($ex)), 4);
            for my $val(@$ex){
                print "$val\n";
                #syswrite($client, pack('w/a*', $val));
                #syswrite($client, pack('L', scalar($ex)), 4);
            }
        }
        close( $client );
        alarm(100);
    }
    close( $server );
}
else {
    Local::App::ProcessCalc::multi_calc(1,10,9899);
    print("exit ProcessCalc\n");
    exit;
}





