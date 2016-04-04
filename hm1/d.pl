#!/usr/bin/perl -naF':'
BEGIN{ 
	use Data::Dumper;
	use Data::Printer;
	$k=0; @ar = (); 
	$ans="";
}   
	$j=0; 
	@ar2=();  
	foreach (@F) { 
		push (@ar2,$_);  
		if ("$_" =~ /^[+-]?\d+$/ && $_ > 10) { 
			$ans=$ans . "i: $k j: $j --- $_\n" 
		} 
			$j++; 
	} 
		$k++; 
		push (@ar,[@ar2]);  
END {
	print 
	$ans;
	print Dumper(@ar); 
	p @ar;
}

