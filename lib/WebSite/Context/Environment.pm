package WebSite::Context::Environment;

use v5.38;
use utf8;

use feature qw(state isa);

use Exporter::Lite;

use Kalaclista::Context::Environment;

our @EXPORT    = qw(env);
our @EXPORT_OK = ( @EXPORT, qw(detect) );

sub detect {
  my $stage = $ENV{'KALACLISTA_ENV'};
  my $on;

  if ( !exists $ENV{'KALACLISTA_ENV'} ) {
    warn 'KALACLISTA_ENV is not defined; fallback to `development`';
    $stage = 'development';
  }
  elsif ( $ENV{'KALACLISTA_ENV'} !~ m{^(?:test|staging|production|development)$} ) {
    warn "unsupported KALACLISTA_ENV: " . $ENV{'KALACLISTA_ENV'} . "; fallback to `development`";
    $stage = 'development';
  }

  if ( exists $ENV{'CI'} ) {
    $on = 'ci';
  }
  elsif ( exists $ENV{'IN_PERL_SHELL'} ) {
    $on = 'local';
  }
  else {
    $on = 'runtime';
  }

  Kalaclista::Context::Environment->new( stage => $stage, on => $on );
}

sub env {
  state $env ||= detect;

  if ( @_ > 0 && $_[0] isa 'Kalaclista::Context::Environment' ) {
    $env = shift;
  }

  return $env;
}

1;
