=head1 DESCRIPTION

Эта функция должна принять на вход арифметическое выражение,
а на выходе дать ссылку на массив, содержащий обратную польскую нотацию
Один элемент массива - это число или арифметическая операция
В случае ошибки функция должна вызывать die с сообщением об ошибке
 - +      - унарные минус и минус,
            приоритет 4, правоассоциативный

 ^        - возведение в степень,
            приоритет 3, правоассоциативный

 * /      - умножение, деление,
            приоритет 2, левоассоциативный

 + -      - сложение, вычитание,
            приоритет 1, левоассоциативный

 ( )      - приоритет 0

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
use FindBin;
require "$FindBin::Bin/../lib/tokenize.pl";

sub rpn {
	my $expr = shift;
	my $source = tokenize($expr);
	my @rpn;
	my @stack;
	my $prev = "null";
	for my $c (@{$source}){ 
		  given ($c) {
	        when (/\d/) { print "$c\n";# элемент содержит цифру
	        	if (/[+-]?\d*\.{1}?\d+/){ 
	        		if (/[+-]?\d*\.{1}?\d+\.+/){
	        			die "error";
	        		}
	        	}
	            push (@rpn,0 + $c);
	        }
	       # when ( '.' ) {} # элемент равен "."
	        when (["U-","U+"]){
	        	push(@stack,$c);
	        	die "Error: rpn" if $c eq $prev;
	        }
	        when (['^']){
	        	if (defined($stack[$#stack])){
	        	# while (defined($stack[$#stack]) && $stack[$#stack] eq "U-" || $stack[$#stack] eq "U+"){
	        	# 	push(@rpn,$stack[$#stack]);
	        	# 	if (defined($stack[$#stack])){pop(@stack);}
	        	# }
	        	}
	        	push(@stack,$c);
	        	die "Error: rpn" if $c eq $prev;
	        }
	        when (['*','/']){
	        	if (defined($stack[$#stack])){
	        	while ($stack[$#stack] eq "U-" || $stack[$#stack] eq "U+" || $stack[$#stack] eq '^' || $stack[$#stack] eq '*' || $stack[$#stack] eq '/'){
	        		push(@rpn,$stack[$#stack]);
	        		if (defined($stack[$#stack])){pop(@stack);}
	        	}
	        	}
	        	push(@stack,$c);
	        	die "Error: rpn" if $c eq $prev;
	        }
	        when ([ '+','-' ]){ # элемент "+" или "-"
	        	if (defined($stack[$#stack])){
	            while ($stack[$#stack] eq "U-" || $stack[$#stack] eq "U+" || $stack[$#stack] eq '^' || $stack[$#stack] eq '*' || $stack[$#stack] eq '/' || $stack[$#stack] eq '+' || $stack[$#stack] eq '-'){
	        		push(@rpn,$stack[$#stack]);
	        		if (defined($stack[$#stack])) {pop(@stack);}
	        	}
	        	}
	        	push(@stack,$c);
	        	die "Error: rpn" if $c eq $prev;

	        }
	        when (['(']){
	        	push(@stack,$c);
	        }
	        when([')']){
	        	if (defined($stack[$#stack])){
	        	while ($stack[$#stack] ne '('){
	        		if (@stack == 0){
	        			die "Error: unbalanced brackets\n"
	        		}
	        		else {
	        			push(@rpn,$stack[$#stack]);
	        			if (defined($stack[$#stack])){pop(@stack);}
	        		}	
	        	}
	        	}
	        	pop(@stack);
	        }
	        default {
	            die "Bad: '$_'";
	        }

	    }
	    $prev = $c;
	    #print $c;
	    #p @stack;
	}
	while (@stack !=0 ) {
		push(@rpn,$stack[$#stack]);
		pop(@stack);
	}

	# ...
	#p @rpn;
	return \@rpn;
}

1;
