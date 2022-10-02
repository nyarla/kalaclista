package WebSite::Widgets::Title;

use strict;
use warnings;
use utf8;

use Text::HyperScript::HTML5 qw(header p);
use Exporter::Lite;

use WebSite::Helper::Hyperlink qw(hyperlink href);

our @EXPORT = qw(banner);

sub banner {
  my $baseURI = shift;

  return header(
    { id => 'global' },
    p( hyperlink( 'カラクリスタ', href( '/', $baseURI ) ) )
  );
}
