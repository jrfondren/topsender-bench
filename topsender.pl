#! /usr/bin/env perl
use strict;
use warnings;

my %senders;
keys(%senders) = 200_000;

sub populate_senders {
	open my $f, '<', 'exim_mainlog' or die "Unable to open exim_mainlog for reading : $!";
	while (defined(my $line = <$f>)) {
		$senders{$1}++ if $line =~ /^(?:\S+ ){3,4}<= ([^@]+\@(\S+))/;
	}
	close $f;
}

populate_senders();

my @topfive = (sort { $senders{$b} <=> $senders{$a} } keys %senders)[0..4];

printf "%9d %s\n", $senders{$_}, $_ for @topfive;
