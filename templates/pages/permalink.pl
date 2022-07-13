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
    )
  );
};

my $template = sub {
  my ( $vars, $baseURI ) = @_;
  my ( $section, $data, $content, $meta ) =
    @{$vars}{qw( section data content meta )};

  my %info;
  @info{
    qw( title website
      description
      section kind home permalink )
    }
    = (
    $meta->title, $data->{'title'},
    $content->dom->at('*:first-child')->textContent,
    $meta->type, 'permalink', !!0, $meta->href->as_string,
    );

  my @tree = ();
  push @tree,
    +{
    name => 'カラクリスタ',
    href => href( '/', $baseURI ),
    };

  push @tree,
    +{
    name => $info{'website'},
    href => href( "/@{[ $info{'section'} ]}/", $baseURI ),
    };

  push @tree,
    +{
    name => $info{'title'},
    href => $info{'permalink'},
    };

  $info{'tree'} = \@tree;

  my %data;

  return document(
    expand( 'meta/head.pl', \%info, $baseURI ),
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
