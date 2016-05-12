package Local::App::Calc;
use strict;
use IO::Socket;
#Определение обрабатываемых сигналов
my $server;
$SIG{INT} = sub{
    print "kill all from Calc\n";
    close( $server );
    kill (9,-$$);
};
use FindBin;
require "$FindBin::Bin/../lib/evaluate.pl";
require "$FindBin::Bin/../lib/rpn.pl";

sub start_server {
    # На вход получаем порт который будет слушать сервер занимающийся расчетами примеров
    my $port = shift;
    $server = IO::Socket::INET->new(
        LocalPort => $port,
        Type      => SOCK_STREAM,
        ReuseAddr => 1,
        Listen    => 10) 
    or die "Can't create server on port $port : $@ $/";
    #print "======Server Calc was started=======\n";    
    while(my $client = $server->accept()){
    	if (my $pid = fork()){
    		close ($client); next;
    	}
    	else{
    		my $msg_len;
	        #print "________new connect to Calc server________\n";
	        while (sysread($client, $msg_len, 4) == 4){
	        	my $count = unpack 'L', $msg_len;
	                #print "client count: $count ";
	                my $st;
	                if (sysread($client, $msg_len, $count) == $count){
	                    my $st = unpack 'w/a*', $msg_len;
	                    #print "client ex: $st\n";
	                    syswrite($client, pack('d', calculate($st)), 8);
	                }
	        }   
	        #print("Bye client\n");
	        close( $client );
	        exit;
    	}
        
    }
    close( $server );
    
    # Создание сервера и обработка входящих соединений, форки не нужны 
    # Входящее и исходящее сообщение: int 4 byte + string
    # На каждое подключение отдельный процесс. В рамках одного соединения может быть передано несколько примеров
}

sub calculate {
    my $ex = shift;
    my $rpn = rpn($ex);
	my $value = evaluate($rpn);
    return $value;
    # На вход получаем пример, который надо обработать, на выход возвращаем результат
}

1;
