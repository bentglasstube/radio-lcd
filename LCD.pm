package LCD;

use strict;
use warnings;

use IO::File;

sub new {
  my ($class, $path) = @_;

  my $fh = IO::File->new($path, 'w') or die "Could not open $path: $!";
  $fh->autoflush(1);

  return bless { fh => $fh }, $class;
}

sub _command {
  my ($self, $command, @args) = @_;
  $self->print(map chr($_), 0xfe, $command, @args, );
}

sub backlight {
  my ($self, $on) = @_;
  $self->_command($on ? (0x42, 0) : 0x46);
}

sub brightness {
  my ($self, $level) = @_;
  $self->_command(0x99, $level);
}

sub contrast {
  my ($self, $level) = @_;
  $self->_command(0x50, $level);
}

sub auto_scroll {
  my ($self, $on) = @_;
  $self->_command($on ? 0x51 : 0x52);
}

sub clear {
  my ($self) = @_;
  $self->_command(0x58);
}

sub set_splash {
  my ($self, $splash) = @_;
  $self->_command(0x40);
  $self->print($splash);
}

sub set_cursor {
  my ($self, $x, $y) = @_;
  $self->_command(0x47, $x, $y);
}

sub home {
  my ($self) = @_;
  $self->_command(0x48);
}

sub back {
  my ($self) = @_;
  $self->_command(0x4c);
}

sub forward {
  my ($self) = @_;
  $self->_command(0x4d);
}

sub underline {
  my ($self, $on) = @_;
  $self->_command($on ? 0x4a : 0x4b);
}

sub block {
  my ($self, $on) = @_;
  $self->_command($on ? 0x53 : 0x54);
}

sub color {
  my ($self, $r, $g, $b) = @_;
  $self->_command(0xd0, $r, $g, $b);
}

sub size {
  my ($self, $cols, $rows) = @_;
  $self->_command(0xd1, $cols, $rows);
}

sub create_char {
  my ($self, $pos, @data) = @_;
  $self->_command(0x4e, $pos, @data);
}

sub save_char {
  my ($self, $bank, $pos, @data) = @_;
  $self->_command(0xc1, $bank, $pos, @data);
}

sub load_chars {
  my ($self, $bank) = @_;
  $self->_command(0xc0, $bank);
}

sub gpo_set {
  my ($self, $pin, $state) = @_;
  $self->_command($state ? 0x57 : 0x56, $pin);
}

sub print {
  my ($self, @stuff) = @_;
  $self->{fh}->print(@stuff);
}

sub printf {
  my ($self, $format, @args) = @_;
  $self->print(sprintf($format, @args));
}

sub say {
  my ($self, @stuff) = @_;
  $self->print(@stuff, "\r");
}

1;
