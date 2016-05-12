package Local::App::ProcessCalc;

use strict;
use warnings;
use JSON::XS;
use Data::Printer;
use Fcntl ':flock';
use POSIX;
$|=1;
our $VERSION = '1.0';

our $status_file = './calc_status.txt';
our $tmp_path = './xfiles/';
use IO::Socket;


sub multi_calc {
    # На вход получаем 3 параметра
    my $fork_cnt = shift;  # кол-во паралельных потоков в котором мы будем обрабатывать задания
    my $jobs = shift;      # пул заданий
    my $calc_port = shift; # порт на котором доступен сетевой калькулятор
    my $forks = $fork_cnt;
    my $N = int(($#$jobs+1) / $forks);
    my $remains = ($#$jobs+1) % $forks;
    my $pointer = 0;
    my %pids_hash;
    my @pids_arr;
    
    mkdir 'xfiles',   0777;
    while ($forks){
        my ($r, $w);
        pipe($r, $w);
        if (my $child = fork()){   
            push (@pids_arr,$child);
            my $count = $remains > 0 ? $N+1 : $N;  
            $pids_hash{$child} = "$count,$pointer";
            #print "$child do " . "$count,$pointer\n"; 
            close($r);
            print $w "$count,$pointer";
            close($w);
            $pointer+=$count;
            $remains--;
            $forks--;
        }
        else { setpgrp(0,0);
            #print "I am a child\n";
            my $socket_calc = IO::Socket::INET->new(
                PeerAddr => '127.0.0.1',
                PeerPort => $calc_port,
                Proto    => "tcp",
                Type     => SOCK_STREAM)
            or die "Couldn't connect to Сalc $@\n";
            my $count; my $pointer;
            close($w);
            while(<$r>){ 
                if (/(\d+),(\d+)/){
                    $count = $1; $pointer = $2;
                }  
            }
            close($r);
            #print "$count $pointer\n";
            change_status($$,'READY',0);
            open(my $file, '>>', $tmp_path ."$$" ) or die "error in opening xfiles write\n";
            my $msg_len;
            my $jobs_count = 0;
            for (1..$count){
                syswrite($socket_calc, pack('L', length($$jobs[$pointer]) + 1), 4);
                syswrite($socket_calc, pack('w/a*', $$jobs[$pointer++]));
                if (sysread($socket_calc, $msg_len, 8) == 8){
                    my $result = unpack 'd', $msg_len;
                    print $file "$result\n";
                    $jobs_count++;
                    change_status($$,'PROCESS',$jobs_count);
                }
                else {
                    exit 10;
                }
            }
            close($file);
            change_status($$,'DONE',$jobs_count);
            print "bye\n";
            exit;

        }
                
    }
    my @res;
    for my $pid(@pids_arr){ 
        if (waitpid($pid,0)){ my $status = $?;
            print "STATUS:"; print WEXITSTATUS($status);print "\n";
                if (WEXITSTATUS($status)){
                    for my $id(@pids_arr){
                        print "$id\n";
                        kill 9,-$id;
                        
                    }
                    print "ERROR WORKER HAS A PROBLEM\n";
                    my $deletedir = 'xfiles';
                    system("rm -rf $deletedir");
                    unlink $status_file;
                    return "error in jobs syntax\n";
                }
        }
        open(my $file, '<',$tmp_path . "$pid") or die "error in opening xfiles read\n";
        seek($file,0,0);
        while(<$file>){
            # print ("HERE IS: $_");
            push (@res,$_);
        }
        close($file);
        unlink($tmp_path . "$pid");
    }
    my $deletedir = 'xfiles';
    system("rm -rf $deletedir");
    unlink $status_file;
    # Возвращаем массив всех обработанных заданий
    p @res;
    return \@res;
}
sub change_status{
    my $pid = shift;
    my $status = shift;
    my $count = shift; my $file;
    sysopen($file,$status_file, O_RDWR | O_CREAT) or die "error in fileopening";
    flock($file,LOCK_EX) or die "can't flock $!";
    ##Первый json если файл нулевой длины - т е  пустой?
    if ( -z $status_file) {
        print "$pid in if :";
         while(<$file>){
           print $_;
        }print "\n";
        my $hash = {$pid => {'status' => $status, 'cnt' => "$count"}};
        print $file JSON::XS::encode_json($hash);
        #{PID => {status => 'READY|PROCESS|DONE', cnt => $cnt}}
    } 
    ##Добавляю к уже существующему json новый ключи и перезаписываю файл
    else {
        print "in else: ";
        seek($file,0,0);
        my $json;
        while(<$file>){
           $json = $_;
           print $_;
        } print "\n";
#        sysopen(my $file_change,$status_file, O_TRUNC | O_RDWR | O_CREAT) or die "error in fileopening";
        seek($file,0,0);
        truncate($file, tell($file)) or print "CAN'T TRUNCATE FILE\n";
        my $hash = JSON::XS::decode_json($json);
        $$hash{$pid} = {'status' => $status, 'cnt' => "$count"};
        #seek($file,0,0); 
        print $file JSON::XS::encode_json($hash);
    }
    flock($file, LOCK_UN) or die "Cannot unlock mailbox - $!\n";
    close($file);

}


sub get_from_server {
    my $port = shift;
    my $limit = shift;
    my $socket = IO::Socket::INET->new(
            PeerAddr => '127.0.0.1',
            PeerPort => $port,
            Proto    => "tcp",
            Type     => SOCK_STREAM)
        or die "Couldn't connect to GenCalc $@\n";
        syswrite($socket, pack('S', $limit), 2);
        my $msg_len;
            my @calcs;
            while (sysread($socket, $msg_len, 4) == 4){
                my $count = unpack 'L', $msg_len;
                #print "client count: $count ";
                my $st;
                if (sysread($socket, $msg_len, $count) == $count){
                    my $st = unpack 'w/a*', $msg_len;
                    push (@calcs, $st);
                    #print "client ex: $st\n";
                }
            }
            close($socket);
    # Возвращаем ссылку на массив заданий
    return \@calcs;
}

1;
