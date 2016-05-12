=head1 DESCRIPTION

Эта функция должна принять на вход арифметическое выражение,
а на выходе дать ссылку на массив, состоящий из отдельных токенов.
Токен - это отдельная логическая часть выражения: число, скобка или арифметическая операция
В случае ошибки в выражении функция должна вызывать die с сообщением об ошибке

Знаки '-' и '+' в первой позиции, или после другой арифметической операции стоит воспринимать
как унарные и можно записывать как "U-" и "U+"

Стоит заметить, что после унарного оператора нельзя использовать бинарные операторы
Например последовательность 1 + - / 2 невалидна. Бинарный оператор / идёт после использования унарного "-"
perl -MData::Printer -nle 'my @chunks = split m{([-+*/^() ])}, $_; $i =0; foreach(@chunks){if ($_ eq "" || $_ eq " " ){ delete $chunks[$i];} $i++;} p @chunks'
=cut

use 5.010;
# use strict;
# use warnings;
# use diagnostics;
use Data::Printer;
BEGIN{
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
}
no warnings 'experimental';

sub tokenize {
	chomp(my $expr = shift);
	my @chunks = split m{([-+*/^()e ])}, $expr; 
	my @res;
	my $prev = "null";
	my $prev_for_real = "null";
	foreach my $var (@chunks){
		if (!($var eq "" || $var eq " ") ){  #p @res;
			given ($var) {
				when (['*','/','^']){
					$prev = "binary";
					if ($prev_for_real eq "digit"){
						$prev_for_real = "null";
					}
				}
				when (/\d/) {
					$prev = "digit";
					if ($prev_for_real ne "null"){
						if ($prev_for_real eq '+' || $prev_for_real eq 'e'){
							$res[$#res] = $res[$#res] . $var;
							$prev_for_real = "digit";
							next;
						}
					}
				}
				when ([ '+','-' ]){
					if ($prev_for_real ne "null"){
						if ($prev_for_real eq 'e'){
							$res[$#res] = $res[$#res] . $var;
							$prev_for_real = '+';
							next;
						}
						elsif ($prev_for_real eq "digit"){
							$prev_for_real = "null";
						}
						else {
							die 'Error: syntax error1';
						}
						
					}
					if ($prev eq "binary" || $prev eq "null" || $prev eq "unary") {
						$var = "U" . $var;
						$prev = "unary";
					}
					else{
						$prev = "binary";
					}
				}
				default {
					if ($var ne ')' && $var ne '('){
						if ($var eq 'e' && $prev eq "digit" && $prev_for_real eq "null"){
							$res[$#res] = $res[$#res] . $var;
							$prev_for_real = 'e';
							next;
						}
						else{
							die 'Error: syntax error2 ';
						}

					}
					

				}
			}
			push (@res,$var);

		} 
	} 
	#p @res;
	return \@res;
}

1;
