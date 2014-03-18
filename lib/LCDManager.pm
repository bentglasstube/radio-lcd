package LCDManager;

use 5.010;

use strict;
use warnings;
use threads;
use threads::shared;

use LCD;
use Time::HiRes qw'sleep time';

sub new {
  my ($class, $path) = @_;

  my $display = shared_clone {
    offset  => 0,
    message => '',
    status  => '',
 };

  my $self = bless {
    lcd     => LCD->new($path),
    display => $display,
  }, $class;

  return $self;
}

sub init {
  my ($self) = @_;

  $self->{lcd}->clear();
  $self->{lcd}->contrast(200);
  $self->{lcd}->brightness(100);
  $self->{lcd}->color(255, 255, 255);
  $self->{lcd}->auto_scroll(undef);
}

sub exit {
  my ($self) = @_;

  $self->{lcd}->clear();
  $self->{lcd}->contrast(200);
  $self->{lcd}->brightness(0);

  if ($self->{thread}) {
    $self->{thread}->detach;
  }
}

sub set_line {
  my ($self, $string) = @_;

  $self->{display}{offset} = 0;
  $self->{display}{message} = $string;
}

sub set_status {
  my ($self, $status) = @_;

  $self->{display}{status} = $status;
}

my %_colors = (
  red     => [ 255, 0,   0 ],
  green   => [ 0,   255, 0 ],
  blue    => [ 0,   0,   255 ],
  yellow  => [ 255, 255, 0 ],
  magenta => [ 255, 0,   255 ],
  cyan    => [ 0,   255, 255 ],
  grey    => [ 127, 127, 127 ],
  white   => [ 255, 255, 255 ],
);

sub set_color {
  my ($self, $color) = @_;
  $self->{lcd}->color(@{$_colors{$color}}) if $_colors{$color};
}

sub draw {
  my ($self) = @_;

  $self->{lcd}->home;
  $self->{lcd}->printf('%-16s', substr($self->{display}{status}, 0, 16));

  my $string = $self->{display}{message};
  $string .= '  |  ' . $self->{display}{message} if length $string > 16;

  $self->{lcd}->set_cursor(1, 2);
  $self->{lcd}->printf('%-16s', substr($string, $self->{display}{offset}, 16));
}

sub update {
  my ($self, $elapsed) = @_;

  return unless length $self->{display}{message} > 16;

  my $delay = 0.5;

  $self->{elapsed} += $elapsed;
  if ($self->{elapsed} > $delay) {
    $self->{display}{offset}++;
    $self->{display}{offset} %= 5 + length $self->{display}{message};
    $self->{elapsed} -= $delay;
  }
}

sub run {
  my ($self) = @_;

  $self->init();

  $self->{thread} = threads->create(sub {
    my $last = time;
    while (1) {
      my $elapsed = time - $last;
      $last = time;

      $self->update($elapsed);
      $self->draw();
      threads->yield();

      my $delay = 1/60 - $elapsed;
      sleep $delay if $delay > 0;

    }
  });
}

1;
