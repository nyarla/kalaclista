package WebSite::Widgets::Information;

use strict;
use warnings;
use utf8;

use feature qw(state);

use Exporter::Lite;

our @EXPORT = qw(copyright information);

use Kalaclista::HyperScript qw(nav ul li p a raw);

use WebSite::Context;
use WebSite::Helper::TailwindCSS;

sub c { state $c ||= WebSite::Context->instance; $c }

sub href {
  my $path = shift;
  my $href = WebSite::Context->instance->baseURI->clone;
  $href->path($path);

  return $href->to_string;
}

sub information {
  state $style ||= custom(q|block md:inline|);
  state $sep   ||= li( { class => custom(q|block mx-4 md:inline md:mx-2|), aria => { hidden => 'true' } }, '・' );

  state $nav ||= nav(
    { class => custom(q|text-center mb-6 md:mb-4|) },
    ul(
      li( { class => $style }, a( { href => href('/policies/') }, '運営ポリシー' ) ),
      $sep,
      li( { class => $style }, a( { href => href('/licenses/') }, 'ライセンスなど' ) ),
    )
  );

  return $nav;
}

sub copyright {
  state $style ||= custom(q|text-center pb-32|);
  state $range ||= "2006-@{[ (localtime)[5] + 1900]}";
  state $copyright ||=
      p( { class => $style }, '© ', $range, ' ', a( { href => href('/nyarla/') }, 'OKAMURA Naoki aka nyarla' ) );

  return $copyright;
}

1;
