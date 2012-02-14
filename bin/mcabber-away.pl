#!/usr/bin/env perl
# $Id$
# Monitor gnome-screensaver status and control Mcabber status accordingly.

my $cmd = "dbus-monitor --session \"type='signal',interface='org.gnome.ScreenSaver',member='ActiveChanged'\"";

local *IN, *OUT;
open(IN, "$cmd |");
# open(OUT, ">>${HOME}/mcabber.fifo");

while (<IN>) {
  if (m/^\s+boolean true/) {
    system "echo /status away > ${HOME}/mcabber.fifo";
    print "/status away\n";
  } elsif (m/^\s+boolean false/) {
    system "echo /status online > ${HOME}/mcabber.fifo";
    print "/status online\n";
  }
}
