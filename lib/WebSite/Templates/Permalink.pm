package WebSite::Templates::Permalink;

use strict;
use warnings;
use utf8;

use feature qw(state);

use Kalaclista::HyperScript;
use WebSite::Context::Environment qw(env);

use WebSite::Widgets::Layout;

sub ads {
  return raw(<<'...');
<script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-1273544194033160"
     crossorigin="anonymous"></script>
<ins class="adsbygoogle"
     style="display:block"
     data-ad-format="fluid"
     data-ad-layout-key="-gc-d+1s-3c+3o"
     data-ad-client="ca-pub-1273544194033160"
     data-ad-slot="5004342069"></ins>
<script>
     (adsbygoogle = window.adsbygoogle || []).push({});
</script>
...
}

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
    { class => 'entry entry__permalink' },
    header(
      h1( a( { href => $entry->href->to_string }, $entry->title ) ),
      p(
        time_( { datetime => $date }, "更新：${date}" ),
        span("読了まで：約${readtime}分"),
      ),
    ),
    section(
      { class => 'entry__content' },
      hr( { class => 'sep' } ),
      raw( $entry->dom->innerHTML ),
    ),
    ( env->production ? aside(ads) : () ),
  );
}

sub render {
  my $vars = shift;

  return layout( $vars => content($vars) );
}

1;
