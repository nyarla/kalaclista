my $content = sub {
  my $vars    = shift;
  my $baseURI = shift;

  my $href =
    sub { my $link = $baseURI->clone; $link->path( $_[0] ); $link->as_string };

  my $data    = $vars->{'data'};
  my @entries = $vars->{'entries'}->@*;

  my @contents;
  if ( $vars->{'section'} eq 'notes' ) {
    my @archives;
    for my $meta ( sort { $b->lastmod cmp $a->lastmod } @entries ) {
      my $date = ( split qr{T}, $meta->date )[0];
      push @archives,
        li( time_( { datetime => $date }, "${date}：" ),
        a( { href => $meta->href, class => 'title' }, $meta->title ) );
    }

    @contents = ( ul( { class => 'archives' }, @archives ), );
  }
  else {
    my @archives;
    for my $meta ( sort { $b->date cmp $a->date } @entries ) {
      my $date = ( split qr{T}, $meta->date )[0];
      push @archives,
        li( time_( { datetime => $date }, "${date}：" ),
        a( { href => $meta->href, class => 'title' }, $meta->title ) );
    }

    my @years;
    for my $year ( sort { $b <=> $a }
      ( $data->{'begin'} .. ( (localtime)[5] + 1900 ) ) )
    {
      if ( $year == $vars->{'year'} ) {
        push @years, strong($year);
      }
      else {
        push @years,
          a( { href => $href->("/@{[ $vars->{'section'} ]}/${year}/") },
          sprintf "%04d", $year );
      }
    }

    @contents = (
      strong( $vars->{'year'} . "年：" ),
      ul( { class => 'archives' }, @archives ),
      hr(), p( "過去ログ： ", ( join q{ / }, @years ), )
    );
  }

  return main(
    article(
      { class => [qw(entry entry__archives)] },
      header(
        h1(
          a(
            { href => $href->("/@{[ $vars->{'section'} ]}/") },
            $data->{'title'}
          )
        )
      ),
      section(
        { class => 'entry__content' }, p( $data->{'summary'} ),

        hr(), @contents,
      )
    )
  );
};

my $template = sub {
  my $vars    = shift;
  my $baseURI = shift;
  my $dir     = shift;

  # internal functions
  my $href =
    sub { my $link = $baseURI->clone; $link->path( $_[0] ); $link->as_string };
  my $head =
    load( "Kalaclista::Head", $dir->child('../meta/head.pl')->stringify );

  # per page variable
  my @entries = $vars->{'entries'}->@*;
  my $year    = $vars->{'year'} // 0;

  # local variables
  my $title;
  my $website = $vars->{'data'}->{'title'};
  my $description;
  my $section = $vars->{'section'};
  my $kind    = $vars->{'kind'};
  my $home    = $vars->{'home'};
  my $permalink;
  my $tree = [];

  if ( $section eq 'notes' ) {
    $title       = $vars->{'data'}->{'title'};
    $permalink   = $href->("/${section}/");
    $description = $vars->{'data'}->{'summary'};
  }
  else {
    $title       = sprintf "%04d年の記事一覧", $year;
    $permalink   = $href->("/${section}/${year}/");
    $description = "${website}の${title}です";
  }

  if ( $vars->{'home'} ) {
    $title       = $vars->{'data'}->{'title'};
    $description = $vars->{'data'}->{'summary'};
    $permalink   = $href->("/${section}/");
  }

  push $tree->@*,
    +{
    name => 'カラクリスタ',
    href => $href->('/'),
    };

  push $tree->@*,
    +{
    name => $website,
    href => $href->("/${section}/"),
    };

  if ( $kind eq q{archive} ) {
    push $tree->@*,
      +{
      name => $title,
      href => $permalink,
      };
  }

  my $data = {
    title       => $title,
    website     => $website,
    description => $description,
    section     => $section,
    kind        => $kind,
    home        => $home,
    permalink   => $permalink,
    tree        => $tree,
  };

  return document(
    $head->( $vars, $baseURI, $data ),
    [
      (
        load( "Kalaclista::Title", $dir->child("../widgets/title.pl") )
          ->( $vars, $baseURI, $data )
      ),
      (
        load( "Kalaclista::Profile", $dir->child("../widgets/profile.pl") )
          ->( $vars, $baseURI, $data )
      ),
      (
        load( "Kalaclista::Menu", $dir->child("../widgets/menu.pl") )
          ->( $vars, $baseURI, $data )
      ),
      $content->( $vars, $baseURI ),
      (
        load( "Kalaclista::Info", $dir->child("../widgets/info.pl") )
          ->( $vars, $baseURI, $data )
      ),
    ]
  );
};

$template;
