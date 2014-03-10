#!/usr/bin/perl

use 5.010;
use strict;
use warnings;

use LCD;
use Time::HiRes 'sleep';

my $lcd = LCD->new('/dev/ttyACM0');

$lcd->clear();
$lcd->contrast(200);
$lcd->brightness(100);
$lcd->color(255, 255, 255);

$lcd->say(chr(0), chr(1), ' eatabrick');
$lcd->say(chr(2), chr(3), ' radio');

$SIG{INT} = sub {
  $lcd->clear();
  exit;
};

while (1) {
  sleep 3;
}
