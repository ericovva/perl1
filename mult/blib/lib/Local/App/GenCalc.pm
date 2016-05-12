package Local::App::GenCalc;

use strict;
use IO::Socket;
use Fcntl ':flock';
use Data::Printer;
#my $file_path = './calcs.txt';

sub new_one {
    # Функция вызывается по таймеру каждые 100
    my $new_row = join $/, int(rand(5)).' + '.int(rand(5)), 
                  int(rand(2)).' + '.int(rand(5)).' * '.int(int(rand(10))), 
                  '('.int(rand(10)).' + '.int(rand(8)).') * '.int(rand(7)), 
                  int(rand(5)).' + '.int(rand(6)).' * '.int(rand(8)).' ^ '.int(rand(12)), 
                  int(rand(20)).' + '.int(rand(40)).' * '.int(rand(45)).' ^ '.int(rand(12)), 
                  (int(rand(12))/(int(rand(17))+1)).' * ('.(int(rand(14))/(int(rand(30))+1)).' - '.int(rand(10)).') / '.rand(10).'.0 ^ 0.'.int(rand(6)),  
                  int(rand(8)).' + 0.'.int(rand(10)), 
                  int(rand(10)).' + .5',
                  int(rand(10)).' + .5e0',
                  int(rand(10)).' + .5e1',
                  int(rand(10)).' + .5e+1', 
                  int(rand(10)).' + .5e-1', 
                  int(rand(10)).' + .5e+1 * 2';
    # Далее происходить запись в файл очередь
    open(my $file_path, '>>', './calcs.txt') or die "error in opening calcs.txt \n";
    flock($file_path,LOCK_EX) or die "can't flock $!";
    print $file_path $new_row;
    return;
}
my $server;
#Определение обрабатываемых сигналов
$SIG{INT} = sub{
    print "kill all from GenCalc\n";
    close( $server );
    if (-e './tmp.txt') {unlink ('./tmp.txt');}
    if (-e './calcs.txt') {unlink ('./calcs.txt');}
    kill (9,-$$);
};
$SIG{ALRM} = sub {
    print "new_one\n";
    new_one();
};

sub start_server {
    # На вход приходит номер порта который будет слушат сервер для обработки запросов на получение данных
    my $port = shift;
    $server = IO::Socket::INET->new(
        LocalPort => $port,
        Type      => SOCK_STREAM,
        ReuseAddr => 1,
        Listen    => 10) 
    or die "Can't create server on port $port : $@ $/";
    #print "======Server GenCalc was started======\n";    
    alarm(100);
    while(my $client = $server->accept()){
        alarm(0);
        my $msg_len;
        #print "__new connect to GenCalc server \n";
        if (sysread($client, $msg_len, 2) == 2){
            my $limit = unpack 'S', $msg_len;
            my $ex = Local::App::GenCalc::get($limit);
            #print "I must read $limit strings\n";
            p @$ex;
            for my $val(@$ex){
              my $count = 1 + length $val;
              syswrite($client, pack('L', $count), 4);
              syswrite($client, pack('w/a*', $val));
            }
        }
        #print("Bye client\n");
        close( $client );
        alarm(100);
    }
    close( $server );

}

sub get {
    # На вход получаем кол-во запрашиваемых сообщений
    my $limit = shift;
    open(my $file_path, '<', './calcs.txt') or die "error in opening calcs.txt from get \n";
    flock($file_path,LOCK_EX) or die "can't flock $!";
    open(my $tmp ,'>','./tmp.txt') or die "error in creating tmp.txt\n";
    seek($file_path,0,0);
    #print tell($file_path);
    my $i = 0;
    my @calc_tasks;
    while (<$file_path>) {
      if ($i < $limit){
        push(@calc_tasks,$_);
        $i++;
      }
      else {
        print $tmp $_;
      }
    }
    #print "read $i strings\n";
    #if ($i > 0){
    close($file_path); 
    close($tmp);
    unlink "./calcs.txt";
    rename "./tmp.txt" , "./calcs.txt";
  
    # Открытие файла, чтение N записей
    # Надо предусмотреть, что файла может не быть, а так же в файле может быть меньше сообщений чем запрошено
    my $ref = \@calc_tasks; # Возвращаем ссылку на массив строк

    return $ref;
}

1;
