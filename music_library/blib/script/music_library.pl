#!/usr/bin/env perl 
use 5.010; 
use strict;
use warnings;
use Getopt::Long;
use Data::Printer;
#BEGIN { push(@INC, '/lib/'); }
use lib::Local::Hashmaker;
use lib::Local::Sort_and_filter;
use lib::Local::DrawTable;
my $band = '';   
my $sort = '';
my $columns = 'default';
my $format ='';      
my $album = '';
my $year = '';
my $track = '';
GetOptions ('band=s' => \$band, 
			'sort=s' => \$sort, 
			'columns=s' => \$columns, 
			'format=s' => \$format,
			'album=s' => \$album,
			'year=i' => \$year,
			'track=s' => \$track
			);
#print "$band, $sort $columns\n";
my @music;
while (<>) {
	my %entity = make_hash($_);
	if (%entity){
		push (@music, \%entity);	
	}

}
	#p @music; 
{
	package Sort_and_filter;
	if (@music){
			my_sort(\@music,$sort);
			my $length_hash = filter(\@music,$band,$year,$album,$track,$format);
			#p %$length_hash;

			DrawTable::draw(\@music,\%$length_hash,$columns);
	}

}

	
