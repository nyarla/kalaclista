package WebSite::Widgets::Title;

use strict;
use warnings;
use utf8;

use feature qw(state);

use Exporter::Lite;

our @EXPORT = qw(banner);

use Text::HyperScript::HTML5 qw(header p);
use WebSite::Helper::Hyperlink qw(hyperlink href);

sub banner {
  my $baseURI = shift;

  state $result ||= header(
    { id => 'global' },
    p( hyperlink( 'カラクリスタ', href( '/', $baseURI ) ) )
  );

  return $result;
}

1;
