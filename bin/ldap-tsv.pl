#!/usr/bin/env perl
# $Id$

use strict;
BEGIN { $^W = 1 }

$main::LDAPSERVER = $ENV{LDAPSERVER};

use Net::LDAP::LDIF;

my @attrs = @ARGV;
local *LDAPSEARCH;
open(LDAPSEARCH,
	"ldapsearch -x -W -ZZ -h $main::LDAPSERVER -f - '(uid=%s)' " . 
	join(' ', @attrs) .
	" |") or die("exec ldapsearch: $!");

my $ldif = Net::LDAP::LDIF->new(\*LDAPSEARCH, 'r', onerror => undef);

while (! ($ldif->eof())) {
	my $entry = $ldif->read_entry() or next;
	my $out = [];
	for my $attr (@attrs) {
		push(@$out, join(';', sort($entry->get_value($attr))));
	}
	print join("\t", @$out), "\n";
}

