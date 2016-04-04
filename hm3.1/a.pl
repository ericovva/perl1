package Local::SomePackage;
use GetterSetter qw(x y);

set_x(50);
print our $x; # 50

our $y = 42;
print get_y(); # 42
set_y(11);
print get_y(); # 11


