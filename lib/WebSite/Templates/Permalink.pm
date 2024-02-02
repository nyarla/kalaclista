package WebSite::Templates::Permalink;

use strict;
use warnings;
use utf8;

use feature qw(state);

use URI::Fast;

use Kalaclista::HyperScript qw(h1 a article time_ p header span raw button div br);

use WebSite::Widgets::Layout;
use WebSite::Helper::TailwindCSS;

sub readtime {
  ## TODO: change webcard class name when the webcard container renamed
  my $text = shift;
  $text =~ s{<pre[\s\S]+?/pre>}{}g;
  $text =~ s{<blockquote[\s\S]+?/blockquote>}{}g;
  $text =~ s{<aside.+?content__card[\s\S]+?</aside>}{}g;
  $text =~ s{</?.+?>}{}g;

  my $time = int( length($text) / 500 );
  if ( $time <= 0 ) {
    $time = 1;
  }

  return $time;
}

sub date {
  my $datetime = shift;
  my $date     = ( split qr{T}, $datetime )[0];
  my ( $year, $month, $day ) = split qr{-}, $date;

  $year  = int($year);
  $month = int($month);
  $day   = int($day);

  return qq<${year}年${month}月${day}日>;
}

sub headers {
  my $entry = shift;

  my $title = h1(
    { class => join( q{ }, classes(qw(p-name)), custom(q|text-3xl font-bold my-4|) ) },
    a( { href => $entry->href->to_string, class => classes(qw(u-url)) }, $entry->title ),
  );

  my $published_at = $entry->date;
  my $updated_at   = $entry->lastmod // $published_at;

  my $date = p(
    { class => custom(q|text-left w-1/2|) },
    span(
      time_(
        {
          class    => classes(qw(dt-published)),
          datetime => $published_at,
          title    => qq<この記事は@{[ date($published_at) ]}に公開されました>,
        },
        date($published_at),
      ),
    ),
    (
      $updated_at ne $published_at
      ? (
        br( { class => custom(q|sm:hidden|) } ),
        span( { class => custom(q|mr-1 sm:ml-1|), aria => { hidden => 'true' } }, '→' ),
        span(
          time_(
            {
              class    => classes(qw(dt-updated)),
              datetime => $updated_at,
              title    => qq<また@{[ date($updated_at) ]}に更新されています>
            },
            date($updated_at),
          ),
        )
          )
      : ()
    ),
  );

  my $readtime = p(
    { class => custom(q|text-right w-1/2|) },
    qq|この記事は@{[ readtime($entry->dom->innerHTML) ]}分で読めそう|,
  );

  my $meta = div(
    { class => custom(q|text-xs flex|) },
    $date, $readtime,
  );

  ## TODO: change webcard class when the class of affiliate webcard renamed
  my @notice = ();
  if ( defined $entry->dom->at('.content__card--affiliate') ) {
    ## FIXME: add comment to about ads in this message.
    push @notice, p(
      { class => custom(q|card-notify text-sm|) },
      "この記事はアフィリエイト広告を含んでいます。"
    );
  }

  return header(
    $meta,
    $title,
    @notice,
  );
}

sub content {
  my $page  = shift;
  my $entry = $page->entries->[0];

  my $header  = headers($entry);
  my $article = article(
    { class => classes(qw(h-entry)) },
    $header,
  );

  return $article;
}

sub render {
  my $vars = shift;

  return layout( $vars => content($vars) );
}

1;
