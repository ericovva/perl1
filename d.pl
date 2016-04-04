#!/usr/bin/perl -naF':'
BEGIN{ 
	use Data::Dumper;
	use Data::Printer;
	@ar = (); 
	$ans="";
}   
	$j=0; 
	@ar2=();  
	foreach (@F) { 
		push (@ar2,$_);  
		if ($_ =~ /^[+-]?\d+$/ && $_ > 10) { 
			$k = $. - 1;
			$ans=$ans . "i: $k  j: $j --- $_\n" 
		} 
			$j++; 
	} 
		push (@ar,[@ar2]);  
END {
	print 
	$ans;
	print Dumper(@ar); 
	p @ar;
}

