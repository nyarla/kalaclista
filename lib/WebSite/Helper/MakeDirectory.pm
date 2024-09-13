package WebSite::Helper::MakeDirectory;

use v5.38;
use utf8;

use Exporter::Lite;

our @EXPORT_OK = qw(depth mkpath);

=head1 NAME

WebSite::Helper::MakeDirectory - Make parent directories from file paths.

=head1 MODULE FUNCTIONS

=head2 depth C<$path>

  my $depth = depth('/path/to/foo/bar') # => 4

=cut

sub depth : prototype($) { scalar( $_[0] =~ s{(/)}{/}g ) }

=head2 mkpath

  my @files = (...);  # list of file paths

  # make parent directories from @files path.
  mkpath(@files);     

=cut

sub mkpath : prototype(@) {
  my %t;
  my @paths =
      sort { depth( $b->path ) <=> depth( $a->path ) }
      grep { !$t{ $_->path }++ }
      map  { Kalaclista::Path->new( path => $_ )->parent } @_;

  ( -d $_->path || $_->mkpath ) for @paths;
}

1;
