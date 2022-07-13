my $content = sub {
  my ( $vars, $baseURI ) = @_;

  my ( $data, $entries, $year, $section ) =
    @{$vars}{qw( data entries year section )};

  my @contents;

  if ( $section eq 'notes' ) {
    my @archives;
    for my $meta ( sort { $b->lastmod cmp $a->lastmod } $entries->@* ) {
      my $date = date( $meta->date );
      push @archives,
        li(
        time_( { datetime => $date } ),
        "${date}：",
        a( { href => $meta->href->as_string, class => 'title' }, $meta->title )
        );
    }

    @contents = ul( { class => 'archives' }, @archives );
  }
  else {
    my @archives;
    for my $meta ( sort { $b->date cmp $a->date } $entries->@* ) {
      my $date = date( $meta->date );
      push @archives,
        li(
        time_( { datetime => $date }, "${date}：" ),
        a( { href => $meta->href->as_string, class => 'title' }, $meta->title )
        );
    }

    my @years;
    for my $yr ( sort { $b <=> $a }
      $data->{'begin'} .. ( (localtime)[5] + 1900 ) )
    {
      if ( $yr == $year ) {
        push @years, strong($year);
        next;
      }

      push @years, a( { href => href( "/${section}/${yr}/", $baseURI ) }, $yr );
    }

    @contents = (
      strong("${year}年："), ul( { class => 'archives' }, @archives ),
      hr(),                p( "過去ログ：", ( join q{ / }, @years ) )
    );
  }

  return main(
    article(
      {
        class => [qw(entry entry__archives)]
      },
      header(
        h1(
          a( { href => href( "/${section}/", $baseURI ) }, $data->{'title'} )
        )
      ),
      section(
        { className( 'entry', 'content' ) }, p( $data->{'summary'} ),
        hr(),                                @contents,
      ),
    )
  );
};

my $template = sub {
  my ( $vars, $baseURI ) = @_;

  # vars of pages and archive
  my $year = $vars->{'year'} // 0;

  # vars of metadata
  my $title;
  my $description;
  my $permalink;
  my @tree;

  my ( $data, $section, $kind, $home ) = @{$vars}{qw(data section kind home)};
  my $website = $data->{'title'};

  if ( $home || $section eq 'notes' ) {
    ( $title, $description ) = @{$data}{qw(title summary)};
    $permalink = href( "/${section}/", $baseURI );
  }
  else {
    $title       = sprintf "%04d年の記事一覧", $year;
    $description = "${website}の${title}です";
    $permalink   = href( "/${section}/${year}/", $baseURI );
  }

  push @tree,
    +{
    name => 'カラクリスタ',
    href => href( '/', $baseURI ),
    };

  push @tree,
    +{
    name => $website,
    href => href( "/${section}/", $baseURI ),
    };

  if ( !$home ) {
    push @tree,
      +{
      name => $title,
      href => $permalink,
      };
  }

  my %info = ();
  @info{qw( title website description section kind home permalink tree )} = (
    $title, $website, $description, $section, $kind, $home, $permalink, \@tree
  );

  return document(
    expand( 'meta/head.pl', \%info, $baseURI ),
    [
      expand( 'widgets/title.pl',   $baseURI ),
      expand( 'widgets/profile.pl', $baseURI ),
      expand( 'widgets/menu.pl',    $baseURI ),
      $content->( $vars, $baseURI ),
      expand( 'widgets/info.pl', $baseURI )
    ]
  );
};

$template;
