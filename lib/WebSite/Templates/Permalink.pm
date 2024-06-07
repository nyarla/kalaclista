package WebSite::Templates::Permalink;

use strict;
use warnings;
use utf8;

use feature qw(state);

use Kalaclista::HyperScript;
use WebSite::Context::Environment qw(env);

use WebSite::Widgets::Layout;

sub readtime {
  my $text = shift;
  $text =~ s{<pre[\s\S]+?/pre>}{}g;
  $text =~ s{<blockquote[\s\S]+?/blockquote>}{}g;
  $text =~ s{<aside.+?content__card[\s\S]+?</aside>}{}g;
  $text =~ s{</?.+?>}{}g;

  return int( length($text) / 500 );
}

sub date {
  return ( split qr{T}, shift )[0];
}

sub content {
  my $vars  = shift;
  my $entry = $vars->entries->[0];

  my $date     = date( $entry->date );
  my $readtime = readtime( $entry->dom->innerHTML );

  return article(
    classes(qw|entry entry__permalink h-entry hentry|),
    header(
      h1( a( classes(qw|p-name fn u-url|), { href => $entry->href->to_string }, $entry->title ) ),
      p(
        time_( classes(qw|dt-published published|), { datetime => $date }, "更新：${date}" ),
        span("読了まで：約${readtime}分"),
      ),
    ),
    section(
      classes(q|entry__content e-content entry-content|),
      hr( { class => 'sep' } ),
      raw( $entry->dom->innerHTML ),
    ),
  );
}

sub render {
  my $vars = shift;

  return layout( $vars => content($vars) );
}

1;
