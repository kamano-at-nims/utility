#!/usr/bin/perl

while(<>){
	chomp;
	if($_ =~ /\(RCB[0-9]+\)/){
		#print "$_\n";
		$_ =~ s/(\(RCB[0-9]+\))/ $1 /g;
		$_ =~ s/ \(/\n/g;
		$_ =~ s/\) /\n/g;
		print "$_\n";
	}else{
		print "$_\n";
	}
}
