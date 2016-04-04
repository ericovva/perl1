package Local::App::GenCalc;

use strict;
use Data::Printer;
use Fcntl ':flock';

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

#Определение обрабатываемых сигналов
# $SIG{...} = \&...;

sub start_server {
    # На вход приходит номер порта который будет слушат сервер для обработки запросов на получение данных
    my $port = shift;
    # Создание сервера и обработка входящих соединений, форки не нужны 
    # Входящее сообщение это 2-х байтовый инт (кол-во сообщений которое надо отдать в ответ)
    # Исходящее сообщение: ROWS_CNT ROW; ROW := ROW [ROW]; ROW := LEN MESS; LEN - 4-х байтовый инт; MESS - сообщение указанной длины
}

sub get {
       # На вход получаем кол-во запрашиваемых сообщений
    my $limit = shift;
    open(my $file_path, '<', './calcs.txt') or die "error in opening calcs.txt from get \n";
    open(my $tmp ,'>','./tmp.txt') or die "error in creating tmp.txt\n";
    flock($file_path,LOCK_EX) or die "can't flock $!";
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
    print "read $i strings\n";
    #if ($i > 0){
    close($file_path); 
    close($tmp);
    unlink "./calcs.txt";
    rename "./tmp.txt" , "./calcs.txt";
    #}
     #flock($file_path, LOCK_UN) or die "Cannot unlock  $!\n";
  
    # Открытие файла, чтение N записей
    # Надо предусмотреть, что файла может не быть, а так же в файле может быть меньше сообщений чем запрошено
    my $ref = \@calc_tasks; # Возвращаем ссылку на массив строк
    #p @$ref;
    return $ref;
}

1;
