my $ads = sub {
  my ( $position, $uri ) = @_;

  if ( $uri =~ m{/(?:nyarla|policies|licenses)/} ) {
    return q{};
  }

  if ( $position eq q{top} ) {
    return aside(
      { class => 'ads', style => 'height: 140px' },
      ins(
        {
          class => 'adsbygoogle',
          style => 'display:block',
          data  => {
            'ad-format'     => 'fluid',
            'ad-format-key' => '-gr-d+2d-6d+7k',
            'ad-client'     => 'ca-pub-1273544194033160',
            'ad-slot'       => '5004342069'
          }
        },
        ""
      ),
      script( raw("(adsbygoogle = window.adsbygoogle || []).push({})") ),
    );
  }

  if ( $position eq q{bottom} ) {
    return aside(
      { class => 'ads', style => 'height:360px' },
      ins(
        {
          class => 'adsbygoogle',
          style => 'display:block',
          data  => {
            'ad-format' => 'autorelaxed',
            'ad-client' => 'ca-pub-1273544194033160',
            'ad-slot'   => '2107661428'
          },
        },
        ""
      ),
      script( raw("(adsbygoogle = window.adsbygoogle || []).push({})") ),
    );
  }
};

my $main = sub {
  my ( $content, $meta, $baseURI ) = @_;

  my $date = date( $meta->date );
  my $text = $content->dom->innerHTML;

  $text =~ s{<pre[\s\S]+?/pre>}{}g;
  $text =~ s{<blockquote[\s\S]+?/blockquote>}{}g;
  $text =~ s{<aside.+?content__card[\s\S]+?</aside>}{}g;
  $text =~ s{</?.+?>}{}g;

  my $readtime = int( length($text) / 500 );

  return main(
    $ads->( 'top', $meta->href->as_string ),
    article(
      { class => 'entry' },
      header(
        p(
          time_( { datetime => $date }, "${date}：" ),
          span("読了まで：約${readtime}分")
        ),
        h1( a( { href => $meta->href->as_string }, $meta->title ) ),
      ),
      section(
        { className( 'entry', 'content' ) },
        raw( $content->dom->innerHTML ),
      ),
    ),
    $ads->( 'bottom', $meta->href->as_string ),
  );
};

my $template = sub {
  my ( $vars, $baseURI ) = @_;

  my $content = $vars->entries->[0]->[1];
  my $meta    = $vars->entries->[0]->[0];

  return document(
    expand( 'meta/head.pl', $vars, $baseURI ),
    [
      expand( 'widgets/title.pl',   $baseURI ),
      expand( 'widgets/profile.pl', $baseURI ),
      expand( 'widgets/menu.pl',    $baseURI ),
      $main->( $content, $meta, $baseURI ),
      expand( 'widgets/info.pl', $baseURI )
    ]
  );
};

$template;
