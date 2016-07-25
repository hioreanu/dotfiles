#!/usr/bin/env perl
# $Id$
# Monitor gnome-screensaver status and control Mcabber status accordingly.

print "Started\n";

use IO::Handle;

my $cmd = "dbus-monitor --session \"type='signal',interface='org.cinnamon.ScreenSaver',member='ActiveChanged'\"";
my $fifo = "/tmp/mcabber.fifo";

local *IN, *OUT;
open(IN, "$cmd |") or die "$cmd: $!";
print "Started $cmd\n";
open(OUT, ">${fifo}") or die "open fifo ${fifo} for writing: $!";
OUT->autoflush(1);
die if not -p OUT;
print "Opened ${fifo}\n";

while (<IN>) {
  print;
  if (m/^\s+boolean true/) {
    print OUT "/status away\n" or die "Write to fifo ${fifo}: $!";
    print "/status away\n";
  } elsif (m/^\s+boolean false/) {
    print OUT "/status online\n" or die "Write to fifo ${fifo}: $!";
    print "/status online\n";
  }
}
