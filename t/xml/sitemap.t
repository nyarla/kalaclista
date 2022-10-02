use strict;
use warnings;

use Test2::V0;
use XML::LibXML;
use URI;

use Kalaclista::Directory;

my $dist = Kalaclista::Directory->new->rootdir->child("dist");

sub main {
  my $xml = XML::LibXML->load_xml( string => $dist->child('sitemap.xml')->slurp );

  my $xc = XML::LibXML::XPathContext->new($xml);
  $xc->registerNs( 's', 'http://www.sitemaps.org/schemas/sitemap/0.9' );

  for my $node ( $xc->findnodes('//s:url')->get_nodelist ) {
    my $loc     = URI->new( $xc->findnodes( 's:loc', $node )->pop->textContent );
    my $lastmod = $xc->findnodes( 's:lastmod', $node )->pop->textContent;

    # DateTime test
    like(
      $lastmod,
      qr<^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:[-+]\d{2}:\d{2}|Z)$>
    );

    # URL tests
    is( $loc->scheme, 'https' );
    is( $loc->host,   'the.kalaclista.com' );

    my @paths = split qr{/}, $loc->path;

    if ( $paths[1] eq 'nyarla'
      || $paths[1] eq 'licenses'
      || $paths[1] eq 'policies' ) {
      like( $paths[1], qr{nyarla|licenses|policies} );
      is( scalar(@paths), 2 );
      next;
    }

    if ( $paths[1] eq 'posts' || $paths[1] eq 'echos' ) {
      if ( @paths == 3 ) {
        like( $paths[2], qr<\d{4}> );
        next;
      }

      like( $paths[2], qr<\d{4}> );
      like( $paths[3], qr<\d{2}> );
      like( $paths[4], qr<\d{2}> );
      like( $paths[5], qr<\d{6}> );

      is( scalar(@paths), 6 );
      next;
    }

    if ( $paths[1] eq 'notes' ) {
      is( scalar(@paths), 3 );
      next;
    }

    ok( 0, "unknown url: " . join( q{/}, @paths ) . '/' );
  }

  done_testing;
}

main;
