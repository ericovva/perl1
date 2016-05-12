=head1 DESCRIPTION

Эта функция должна принять на вход ссылку на массив, который представляет из себя обратную польскую нотацию,
а на выходе вернуть вычисленное выражение

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

sub evaluate {
	my $rpn = shift;
	my @stack;

	for my $c (@{$rpn}){
		given ($c){
			when (['+']){
				if ($#stack > 0){ 
					$stack[$#stack-1] += pop(@stack);
				}
				else {
					die "Error: error 3"
				}
			}
			when (['-']){
				if ($#stack > 0){
					$stack[$#stack-1] -= pop(@stack);
				}
				else {
					die "Error: error 4"
				}
			}
			when (['*']){
				if ($#stack > 0){
					$stack[$#stack-1] *= pop(@stack);
				}
				else {
					die "Error: error 5"
				}
			}
			when (['/']){
				if ($#stack >= 0){
					$stack[$#stack-1] /= pop(@stack);
				}
				else {
					die "Error: error 6"
				}
			}
			when (['^']){
				if ($#stack >= 0){
					my $var = $stack[$#stack-1]**pop(@stack);
					$stack[$#stack] = $var;
				}
				else {
					die "Error: error 7"
				}
			}
			when (["U-"]){
				if ($#stack >= 0){
					$stack[$#stack] *= (-1); 
				}
				else {
					die "Error: error 8"
				}

			}
			when (/\d/){
				push (@stack,$c);
			}
		}
		#p @stack;
	}
	
	return $stack[$#stack];
}

1;
