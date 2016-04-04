use lib::Local::Iterator::File;
use lib::Local::Iterator::Array;
use lib::Local::Iterator::Aggregator;
use lib::Local::Iterator::Concater;
use v5.18;
use Data::Printer;
my $iterator = Local::Iterator::Array->new(array => []);
# p $iterator->all();
# say $iterator->next();
# p $iterator->all();
# say $iterator->next();
# p $iterator->all();
# say $iterator->next();
# p $iterator->all();
# my @aa = $iterator->next;
# p @aa;
my $fn = 'testfile';
# open(my $fh,'<',$fn) or die "f error";
# #p $fh;
# my $iterator2 = Local::Iterator::File->new(filename => $fn);
# my ($next, $end);
# say $iterator2->next();
# say $iterator2->next();
# p @{$iterator2->all()};
# ($next, $end) = $iterator2->next();
# say "$next $end";
# say $iterator2->next();
# p @{$iterator2->all()};
# say $iterator2->next();
# say $iterator2->next();
# my $iterator3 = Local::Iterator::File->new(filename => $fn);
# say $iterator3->next();
#p @{[qw(C D E)]};
#aggregator
#  my $iterator = Local::Iterator::Aggregator->new(
#     iterator => Local::Iterator::File->new(filename => $fn),
#     chunk_length => 2,
# );

# my ($next,$end) = $iterator->next();
# p $next;
# p $iterator->all();
# ($next,$end) = $iterator->next();
# p $next;
# ($next,$end) = $iterator->next();
# p $next;
# ($next,$end) = $iterator->next();
# p $next;
# ($next,$end) = $iterator->next();
# p $next;
my $iterator = Local::Iterator::Concater->new(
    iterators => [
        Local::Iterator::Array->new(array => [1, 2]),
        Local::Iterator::Array->new(array => [3, 4]),
        Local::Iterator::Array->new(array => [5, 6]),
    ],
);
my ($next, $end);

($next, $end) = $iterator->next();
say $next;
p $iterator->all();
($next, $end) = $iterator->next();
p $next;







