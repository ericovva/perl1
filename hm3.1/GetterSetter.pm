package GetterSetter;
use strict;
sub import {
  my ($dest_pac) = caller();
  my ($package,@names) = @_;
  no strict;
  for (my $var = 0; $var <= $#names; $var++) {
      my $s = $dest_pac . '::' . 'set_' . $names[$var];
      my $g = $dest_pac . '::' . 'get_' . $names[$var];
      my $v = $dest_pac . '::' . $names[$var];
      *{$s} = sub {
        my ($tmp) = @_; ${$v} = $tmp;
      };
      *{$g} = sub {
        return ${$v};
      }; 
  }
  
}


1;
