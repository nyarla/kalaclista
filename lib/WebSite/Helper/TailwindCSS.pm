package WebSite::Helper::TailwindCSS;

use strict;
use warnings;

use feature qw(state);

use Exporter::Lite;
use Carp qw(carp);

our @EXPORT = qw(apply classes custom);

sub preset {
  state $presets ||= {
    link => q|text-actionable underline|,
  };

  my $name = shift;
  return $presets->{$name} if exists $presets->{$name};

  carp "this preset name of ${name} is not defined.";
  return q{};
}

sub apply {
  my @presets = @_;
  my @apply;

  for my $name (@presets) {
    if ( defined( my $preset = preset($name) ) ) {
      push @apply, ( split qr{ +}, $preset );
    }
  }

  return do {
    my %t;
    join q{ }, grep { !$t{$_}++ } @apply;
  };
}

sub classes {
  return join q{ }, sort @_;
}

sub custom {
  return join q{ }, sort ( split q{ }, (shift) );
}

1;
