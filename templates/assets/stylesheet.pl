my $base00 = '#000000';
my $base01 = '#333333';
my $base02 = '#666666';
my $base03 = '#999999';
my $base04 = '#cccccc';
my $base05 = '#f9f9f9';
my $base06 = '#ffffff';
my $base07 = '#f9f9f9';
my $base08 = '#ff3300';
my $base09 = '#ff6633';
my $base0A = '#ff9933';
my $base0B = '#669900';
my $base0C = '#006666';
my $base0D = '#0099cc';
my $base0E = '#663366';
my $base0F = '#cc6633';

my $K00 = '#000000';
my $K01 = '#000000';
my $K02 = '#333333';
my $K03 = '#666666';
my $K04 = '#f9f9f9';
my $K05 = '#f9f9f9';
my $K06 = '#ffffff';
my $K07 = '#cccccc';
my $K08 = '#ccff00';
my $K09 = '#ffcc33';
my $K0A = '#00cccc';
my $K0B = '#ffcc33';
my $K0C = '#ffcc33';
my $K0D = '#00ccff';
my $K0E = '#00ccff';
my $K0F = '#ffffff';

my $colorAmazon     = '#febd69';
my $colorRakuten    = '#e61717';
my $colorAliexpress = '#ff4747';
my $colorBanggood   = '#ff6e26';
my $colorGearbest   = '#ffda00';

sub fontSans {
  return (
    fontFamily          => 'sans-serif',
    fontWeight          => 300,
    fontFeatureSettings => q("palt"),
  );
}

sub fontSansBold {
  return (
    fontFamily          => 'sans-serif',
    fontWeight          => 900,
    fontFeatureSettings => q("palt"),
  );
}

sub linkColor {
  my ( $from, $to ) = @_;

  return (
    '&' => [
      transition => 'color 0.125s',
    ],

    [qw( &:link &:visited )] => [
      color => $from
    ],

    [qw( &:link:hover &:visited:hover &:link:active &:visited:active )] => [
      color => $to
    ],
  );
}

my @global = (
  [qw(html body)] => [
    backgroundColor => $base06,
    color           => $base01,
    minHeight       => '101%',

    fontSans,
  ],

  body => [
    fontSize => '1.25em',
  ],

  a => [
    linkColor( $base00, $base03 ), textDecoration => 'underline solid',
  ],
);

my @container = (
  [ '#global', '#profile', '#menu', '#copyright', '.entry' ] => [
    margin   => '0 auto',
    padding  => '0 1.5em',
    maxWidth => '35em',
  ],
);

my @widgets = (
  '#global' => [
    p => [
      margin => '5em 0',

      a => [ linkColor( $base00, $base03 ) ],
    ],
  ],

  '#profile' => [
    marginTop    => '5em',
    marginBottom => '0',

    figure => [
      margin => '0',

      p          => [ float        => 'left', margin => '0 1em 1em 0' ],
      figcaption => [ marginBottom => '0.5em' ],
    ],

    '.entry__content' => [
      'p' => [ margin => '0', fontSize => '0.75em' ],
    ],
    'nav p' => [ fontSize => '0.75em', a => [ marginRight => '0.5em' ] ],
  ],
);

my @menu = (
  '#menu' => [
    marginBottom => '5em',

    hr => [ marginBottom => '0.5em' ],
    p  => [ fontSize     => '0.75em' ],

    'p.kind' => [
      float      => 'left',
      marginLeft => '4.5%',
      width      => '45%',
      textAlign  => 'left',
      a          => [ marginRight => '0.5em' ],
    ],

    'p.links' => [
      float       => 'right',
      marginRight => '4.5%',
      width       => '45%',
      textAlign   => 'right',
      a           => [ marginLeft => '0.5em' ],
    ],

    '&::after' => [ display => 'block', content => q(""), clear => 'both' ],
  ],
);

my @entry = (
  '.entry' => [
    header => [
      p => [
        display       => 'flex',
        flexDirection => 'row',
        fontSize      => '0.865em',

        [qw(time span)] => [
          display => 'block',
          width   => '50%',
        ],

        time => [ textAlign => 'left' ],
        span => [ textAlign => 'right', ],
      ],
      'h1 a' => [
        linkColor( $base00, $base0A ),
        textDecoration => 'none',
        lineHeight     => '1.414em',
      ],
    ],
  ],
);

my @cards = (

  # website
  '.entry__card--website' => [
    a => [
      display  => 'block',
      overflow => 'hidden',

      backgroundColor => $base06,
      padding         => '0.25em 01em',
      borderRadius    => '3pxi',

      transition     => 'border-color 0.125s',
      textDecoration => 'none',

      '&:link, &:visited' => [
        border => "1px solid ${base04}",
      ],

      '&:hover, &:active' => [
        border => "1px solid ${base0D}",
      ],
    ],

    ".content__card--title" => [
      fontSize     => "1.2em",
      marginBottom => 0,
      color        => $base00,
    ],

    ".content__card--title + p" => [
      margin => 0,
    ],

    cite => [
      fontStyle  => 'normal',
      fontWeight => 'bold',
      fontSize   => '0.8em',
      color      => $base0B,
    ],

    blockquote => [
      marginTop => '0.5em',
      fontSize  => '0.75em',
      color     => $base02,
    ],
  ],

  # affiliate
  '.content__card--affiliate' => [
    margin          => '1em 0',
    backgroundColor => $base06,
    padding         => '0.25em 1em',
    borderRadius    => '3px',
    border          => "1px solid ${base0B}",
    overflow        => 'hidden',

    h1 => [
      fontSize => "1.2em",
      float    => 'left',

      a => [
        linkColor( $base00, $base0A ), textDecoration => 'underline',
      ]
    ],

    p => [
      margin  => '0.8em 0',
      padding => 0,
      float   => 'right',
    ],

    ul => [
      clear => 'left',

      li => [
        '&::before' => [
          width        => '3px',
          height       => 'auto',
          top          => 0,
          bottom       => 0,
          left         => '-0.5em',
          borderRadius => '3px',
        ],

        '&.amazon::before'     => [ backgroundColor => $colorAmazon ],
        '&.rakuten::before'    => [ backgroundColor => $colorRakuten ],
        '&.aliexpress::before' => [ backgroundColor => $colorAliexpress ],
        '&.banggood::before'   => [ backgroundColor => $colorBanggood ],
        '&.gearbest::before'   => [ backgroundColor => $colorGearbest ],
      ],

      'li a' => [ linkColor( $base02, $base0A ), ],
    ],

    '&::after' => [
      display => 'block',
      content => q(""),
      clear   => 'both',
    ],
  ],
);

my @content = (
  '.entry__content' => [

    # profile page only
    '#profile__information' => [
      textAlign => 'center',

      img => [
        margin => '0 auto',
        width  => '256px',
        height => '256px',
        border => 'none',
      ]
    ],

    [qw( h1 h2 h3 h4 h5 h6 )] => [ margin => '1em 0' ],

    h1 => [ fontSize   => '1.5em' ],
    h2 => [ fontSize   => '1.375em' ],
    h3 => [ fontSize   => '1.25em' ],
    h4 => [ fontSize   => '1.125em' ],
    h5 => [ fontSize   => '1em' ],
    h6 => [ fontWeight => 'normal', textDecoration => 'underline' ],

    p => [ lineHeight => '1.727em' ],

    hr => [
      margin          => '2em auto',
      width           => '91%',
      backgroundColor => $base04,
      borderRadius    => '3px',
      border          => 'none',
      height          => '3px',
    ],

    blockquote => [
      position => 'relative',
      margin   => '1em',

      '& *:first-child' => [ marginTop    => 0 ],
      '& *:last-child'  => [ marginBottom => 0 ],

      '&::before' => [
        position        => 'absolute',
        left            => '-0.75em',
        bottom          => 0,
        top             => 0,
        display         => 'block',
        content         => q(""),
        width           => '3px',
        backgroundColor => $base0E,
        borderRadius    => '6px',
      ],
    ],

    [qw(ul ol)] => [
      paddingLeft => '1em',

      li => [
        margin => '0.125em 0 0.125em 0.5em',

        'wbr:last-child' => [
          display => 'none',
        ],
      ],
    ],

    'ul' => [
      listStyle => 'none',

      li => [
        position   => 'relative',
        lineHeight => '1.414em',

        '&::before' => [
          display         => 'block',
          position        => 'absolute',
          content         => q(""),
          width           => '0.5em',
          height          => '2px',
          borderRadius    => '100%',
          backgroundColor => $base0B,
          top             => '0.75em',
          left            => '-0.875em',
        ],
      ],
    ],

    dl => [
      dt        => [ marginBottom => '0.25em' ],
      dd        => [ marginLeft   => '1em' ],
      'dd + dt' => [ marginTop    => '0.25em' ],
    ],

    'pre, *:not(pre) > code' => [
      fontFamily => q("Inconsolata", monospace),
    ],

    pre => [
      backgroundColor => $K01,
      color           => $K06,
      padding         => '0.25em 0.5em',
      borderRadius    => '3px',
      overflowX       => 'scroll',
    ],

    '*:not(pre) > code' => [
      backgroundColor => $base04,
      borderRadius    => '3px',
      fontSize        => '0.9em',
      padding         => '0.1em 0.25em',
    ],

    'p.img > a > img' => [
      borderRadius => '3px',
      border       => "1px solid ${base06}",
      hight        => 'auto',
      maxHeight    => '100%'
    ],

    strong => [
      fontWeight => 600,
    ],

    @cards,
  ],
);

my @archives = (
  [qw( .entry__home .entry__archives .entry__related )] => [
    '.entry__content .archives' => [
      li => [
        marginBottom => '1em',
        fontSize     => '0.75em',

        'a.title' => [
          display    => 'block',
          fontSize   => '1.25em',
          lineHeight => '1.727em',
        ],
      ],
    ],
  ],
);

my @copyright = (
  '#copyright' => [
    marginTop    => '5em',
    marginBottom => '5em',
    textAlign    => 'center',
    fontSize     => '0.75em',
  ],
);

my $main = css(
  [
    @global, @container, @widgets,  @menu,
    @entry,  @content,   @archives, @copyright
  ]
);

my $middle = css(
  [
    '#profile' => [
      figure => [
        p => [
          textAlign => 'center',
          float     => 'none'
        ],
      ],

      '.entry__content' => [
        p => [
          display => 'inline',
        ]
      ],
    ],
    '#menu' => [
      [qw(p.kind p.links)] => [
        float     => 'none',
        width     => 'auto',
        textAlign => 'left',
        margin    => '1em 0',

        a => [
          margin => '0 0.5em 0 0',
        ],
      ]
    ],
  ]
);

my $small = css( [ body => [ fontSize => '1em' ] ] );

my $css = qq|
${main}
\@media screen and (max-width: 37.5em) {${middle}}
\@media screen and (max-width: 20em) {${small}}
|;

my $assets = sub { return $css };

$assets;
