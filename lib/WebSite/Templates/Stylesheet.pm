package WebSite::Templates::Stylesheet;

use strict;
use warnings;

use feature qw(state);

use Exporter::Lite;

our @EXPORT = qw(stylesheet);

use Kalaclista::HyperStyle qw(css);

my $maxWidth = '40em';

sub color {
  state $table ||= {
    white   => [ 0xFF, 0xFF, 0xFF ],
    blue    => [ 0x00, 0xCC, 0xFF ],
    cyan    => [ 0x00, 0xCC, 0xCC ],
    green   => [ 0xCC, 0xFF, 0x00 ],
    magenta => [ 0xCC, 0x99, 0xCC ],
    red     => [ 0xFF, 0x66, 0x33 ],
    yellow  => [ 0xFF, 0xCC, 0x33 ],
  };

  my ( $prop, $level ) = split qr{-}, shift;

  my $r = $table->{$prop}->[0];
  my $g = $table->{$prop}->[1];
  my $b = $table->{$prop}->[2];

  if ( defined $level && $level <= 16 ) {
    $r = $r - ( ( $r / 16 ) * ( 16 - $level ) );
    $g = $g - ( ( $g / 16 ) * ( 16 - $level ) );
    $b = $b - ( ( $b / 16 ) * ( 16 - $level ) );
  }

  my $red   = sprintf '%02x', $r;
  my $green = sprintf '%02x', $g;
  my $blue  = sprintf '%02x', $b;

  $_ =~ s{0x}{} for ( $red, $green, $blue );

  return '#' . join q{}, $red, $green, $blue;
}

sub background {
  return ( backgroundColor => color(shift) );
}

sub foreground {
  return ( color => color(shift) );
}

sub height {
  my %data = @_;
  my @css;

  for my $prop (qw/ min max value /) {
    if ( exists $data{$prop} ) {
      my $val = delete $data{$prop};
      my $key = $prop eq q{value} ? 'height' : "${prop}Height";

      push @css, $key => $val;
    }
  }

  return @css;
}

sub width {
  my %data = @_;
  my @css;

  for my $prop (qw/ min max value /) {
    if ( exists $data{$prop} ) {
      my $val = delete $data{$prop};
      my $key = $prop eq q{value} ? 'width' : "${prop}Width";

      push @css, $key => $val;
    }
  }

  return @css;
}

sub box {
  my %data = @_;
  my @css;

  if ( exists $data{'side'} && defined( my $val = delete $data{'side'} ) ) {
    push @css, marginLeft => $val, marginRight => $val;
  }

  if ( exists $data{'inner'} && defined( my $val = delete $data{'inner'} ) ) {
    push @css, (
      paddingTop    => $val->[0],
      paddingBottom => $val->[0],
      paddingLeft   => $val->[1],
      paddingRight  => $val->[1],
    );
  }

  return @css;
}

sub round {
  my %data = @_;

  my $color  = delete $data{'color'}  // color('white-0');
  my $width  = delete $data{'width'}  // "1px";
  my $radius = delete $data{'radius'} // "0";

  return (
    border       => "${width} solid ${color}",
    borderRadius => "${radius} ${radius} ${radius} ${radius}",
  );
}

sub textCenter {
  return ( textAlign => 'center' );
}

sub clearfix {
  return ( clear => 'both' );
}

sub global {
  return (
    [qw/ html body /] => [
      background('white-16'),
      foreground('white-1'),

      lineHeight => '1.727em',
    ],

    a => [
      color => color('blue-8'),
      (
        map {
          (
            "&:${_}"        => [ textDecoration => 'underline solid 1px' ],
            "&:${_}:hover"  => [ textDecoration => 'underline solid 2px' ],
            "&:${_}:active" => [ textDecoration => 'underline solid 2px' ],
          )
        } qw(link visited)
      ),
    ],
  );
}

sub banner {
  return (
    '#global p' => [
      textCenter,
      padding => '2em 0 1em 0',

      a => [
        img => [
          background('white-16'),
          round( width => '6px', radius => '18px', color => color('white-15') )
        ],

        br => [ display => 'block', marginTop => '0.25em' ],
      ]
    ],
  );
}

sub main {
  return (
    main => [
      background('white-16'),
      foreground('white-1'),

      width( max => $maxWidth ),
      box( side => 'auto', inner => [ "1em", "1em" ] ),
      round( width => '6px', radius => '18px', color => color('white-15') ),

      '#section' => [
        float        => 'right',
        margin       => '-1em -1em 1em 1em',
        paddingRight => '.5em',

        borderColor  => color('white-15'),
        borderStyle  => 'solid',
        borderWidth  => '0 0 6px 6px',
        borderRadius => '0 0 0 18px',

        a => [ paddingLeft => '.5em' ],
      ],
    ],

    '.entry' => [
      'header > *:first-child'         => [ marginTop    => 0 ],
      '.entry__content > *:last-child' => [ marginBottom => 0 ],

      h1 => [
        foreground('white-0'),
        fontSize => '1.7em',

        a => [
          foreground('white-0'),
        ]
      ],
    ],

    '.entry__permalink' => [
      'header h1' => [clearfix],
      'header p'  => [
        display  => 'flex',
        fontSize => '.85em',
        margin   => '0',

        [qw/ span time /] => [ display => 'block', width => '50%' ],

        time => [ textAlign => 'left' ],
        span => [ textAlign => 'right' ],
      ],
    ],
  );
}

sub content {
  return (
    '.entry__content' => [

      h2 => [ fontSize => '1.5em' ],
      h3 => [ fontSize => '1.4em' ],
      h4 => [ fontSize => '1.3em' ],
      h5 => [ fontSize => '1.2em' ],
      h6 => [ fontSize => '1.1em' ],

      p => [
        textAlign => 'match-parent',
      ],

      hr => [
        background('white-15'),
        border       => 'none',
        height       => '6px',
        borderRadius => '6px',
      ],

      [ '& > ul', 'li > ul', '& > ol', 'li > ol' ] => [
        paddingLeft => '1.5em',
      ],

      'pre, *:not(pre) > code' => [
        fontFamily => q(monospace),
      ],

      pre => [
        background('white-0'),
        foreground('white-15'),

        padding      => '0.707em 1em',
        borderRadius => '18px',
        whiteSpace   => 'pre',
        lineHeight   => '1.207em',
      ],

      'pre > code' => [
        width      => '100%',
        height     => '100%',
        display    => 'block',
        overflowX  => 'scroll',
        overflowY  => 'hidden',
        whiteSpace => 'pre',
      ],

      '*:not(pre) > code' => [
        background('white-15'),
        padding      => '0 0.25em',
        borderRadius => '4px',
      ],

      blockquote => [
        position => 'relative',
        margin   => '0',
        padding  => '0.25em 1em',

        '& > *:first-child' => [ marginTop    => '0' ],
        '& > *:last-child'  => [ marginBottom => '0' ],

        '&::before' => [
          display      => 'block',
          content      => q(""),
          position     => 'absolute',
          borderRadius => '6px',

          top    => '0',
          bottom => '0',
          left   => '0',
          width  => '6px',

          background('magenta-16')
        ],
      ],

      # structure specifical
      '.archives' => [
        li => [
          marginBottom => '.75em',

          time => [
            display    => 'block',
            fontSize   => '.8em',
            lineHeight => '1em',
          ],
        ],
      ],

      '.logs' => [
        [qw/ strong a /] => [ margin => '0 .25em' ],
      ],

      '.ads' => [
        margin => '1em 0',

        '&.top' => [ height => '140px', maxHeight => '140px', ],
      ],

      '#profile__information' => [textCenter],

      # cards
      '.content__card--thumbnail' => [
        textDecoration => 'none',

        img => [
          width        => '100%',
          height       => '100%',
          borderRadius => '6px',
        ]
      ],

      '.content__card--affiliate' => [
        position => 'relative',
        padding  => '0 0 0 1em',
        height   => '10em',

        h2 => [
          fontSize => '1em',
          display  => 'inline',

          a => [ color => color('white-2') ]
        ],

        ul => [
          paddingLeft => '2em',
        ],

        p => [
          display    => 'flex',
          alignItems => 'center',
          float      => 'right',
          margin     => '0 0 1em 2em',
          height     => '160px',
          width      => '160px',
        ],

        '&::before' => [
          display      => 'block',
          content      => q(""),
          position     => 'absolute',
          borderRadius => '6px',

          top    => '0',
          bottom => '0',
          left   => '0',
          width  => '6px',

          background('green-15')
        ],

        '&::after' => [
          display => 'block',
          content => q(""),
          clearfix,
        ],
        ,
      ],

      '.content__card--website' => [
        position => 'relative',
        margin   => '0',
        padding  => '0.25em 1em',

        '& > *:first-child' => [ marginTop    => '0' ],
        '& > *:last-child'  => [ marginBottom => '0' ],

        '& > a' => [
          textDecoration => 'none',

          '& > h2' => [ margin => '0', fontSize => '1em', foreground('white-2') ],
          '& > p'  => [
            margin => '0 0 0.5em 0',
            cite   => [
              foreground('green-8'),
              fontSize  => '.8em',
              fontStyle => 'normal',
            ],
          ],
          '& > blockquote' => [ foreground('white-2') ],

          [qw/ &:link &:visited /] => [
            [qw/ &>h2 &>p>cite /] => [
              textDecoration => 'underline solid 1px',
            ]
          ],
          [qw/ &:link:hover &:link:active &:visited:hover &:visited:active /] => [
            [qw/ &>h2 &>p>cite /] => [
              textDecoration => 'underline solid 2px',
            ]
          ],
        ],

        '&::before' => [
          display      => 'block',
          content      => q(""),
          position     => 'absolute',
          borderRadius => '6px',

          top    => '0',
          bottom => '0',
          left   => '0',
          width  => '6px',

          background('blue-15')
        ],
      ],
    ],
  );
}

sub profile {
  return (
    '#profile' => [
      background('white-16'),
      foreground('white-1'),

      width( max => '40em' ),
      box( side => 'auto', inner => [ '1em', '1em' ] ),
      round( width => '6px', radius => '18px', color => color('white-15') ),

      marginTop => '4em',

      figure => [
        margin  => '0',
        padding => '0',

        p => [
          float   => 'left',
          margin  => '0',
          padding => '.5em 1em 0 0',
        ]
      ],

      [ 'figure figcaption', '.entry__content p', 'nav p' ] => [
        fontSize => '.85em',
      ],

      '.entry__content' => [
        p                   => [ margin       => '0' ],
        '& > *:first-child' => [ marginTop    => '0' ],
        '& > *:last-child'  => [ marginBottom => '0' ],
      ],

      'nav p' => [
        margin => '0 0 1em 0',

        a => [ marginRight => '.5em' ],
      ],
    ],
  );
}

sub copyright {
  return (
    '#copyright' => [
      marginBottom => '1.5em',
      textAlign    => 'center',
    ],
  );
}

sub render {
  my $desktop = css(
    [
      global,
      banner,
      main,
      content,
      profile,
      copyright,
    ]
  );

  return <<"...";
${desktop}

\@media (max-width: 640px) {
  #profile {
    text-align: center ;
  }

  #profile figure p {
    float: none;
  }

  #profile nav p {
    overflow-wrap: break-word;
  }
}

\@media (max-width: 460px) {
  .entry__content .content__card--affiliate {
    height: 100%;
  }

  .entry__content .content__card--affiliate p {
    display: block;
    float: none;
    margin: 1em 0;
    text-align: center;
    width: 100%;
  }

  .entry__content .content__card--affiliate ul {
    text-align: center;
    padding: 0;
  }

  .entry__content .content__card--affiliate ul li {
    list-style: none;
  }
}

\@media (max-width: 360px) {
  main #section {
    border-radius: 0 0 0 0;
    border-width: 0 0 6px 0;
    float: none;
    margin: -1em -1em 1em -1em ;
    padding: 0 ;
    text-align: center ;
  }
}
...
}

=pod

sub _color {
  state $table ||= {
    background          => '#fff',
    backgroundCode      => '#ccc',
    backgroundCodeBlock => '#000',
    foreground          => '#333',
    foregroundURL       => '#690',

    foregroundAffiliate          => '#666',
    foregroundAffiliateActivated => '#f93',

    linkText      => '#000',
    linkActivated => '#999',
    linkDisabled  => '#999',

    entryTitle          => '#000',
    entryTitleActivated => '#f93',

    borderColorHr               => '#ccc',
    borderColorImage            => '#000',
    borderColorList             => '#690',
    borderColorQuote            => '#636',
    borderColorWebsite          => '#ccc',
    borderColorWebsiteActivated => '#09c',
    borderColorAffiliate        => '#690',

    brandColorAmazon     => '#febd69',
    brandColorRakuten    => '#e61717',
    brandColorAliexpress => '#ff4747',
    brandColorBanggood   => '#ff6e26',
    brandColorGearbest   => '#ffda00',
  };
  my $prop = shift;

  return $table->{$prop};
}

sub global {
  return (
    [qw(html body)] => [
      backgroundColor => color('background'),
      color           => color('foreground'),
      minHeight       => 'calc(100% + 1px)',

      fontFamily          => 'sans-serif',
      fontWeight          => '300',
      fontFeatureSettings => q("palt"),
    ],

    a => [
      textDecoration => 'underline solid',
      transition     => 'color 0.125s',

      (
        map {
          (
            "&:${_}"        => [ color => color('linkText') ],
            "&:${_}:hover"  => [ color => color('linkActivated') ],
            "&:${_}:active" => [ color => color('linkActivated') ],
          )
        } qw(link visited)
      ),
    ],
  );
}

sub container {
  return (
    [ '#global', '#profile', '#menu', '#copyright', '.ads', '.entry' ] => [
      margin   => '0 auto',
      padding  => '0 1em',
      maxWidth => '40em',
    ],

    'aside.ads:nth-child(1) > ins.adsbygoogle' => [
      height => '140px !important',
    ],
  );
}

sub widgets {
  return (
    '#global' => [
      p => [
        marginBottom => '.5em',
        img          => [
          verticalAlign => 'middle',
          marginRight   => '.75em'
        ],
        span => [
          margin     => '0 0.5em',
          fontWeight => 'bold',
        ],
      ],
      hr => [
        backgroundColor => color('borderColorHr'),
        borderRadius    => '3px',
        border          => 'none',
        height          => '3px',
      ],
    ],

    '#menu' => [
      display => 'flex',

      p => [
        width => '50%',

        '&.section' => [
          textAlign => 'left',
          a         => [
            marginRight => '0.75em',
          ],
        ],

        '&.help' => [
          textAlign => 'right',
          a         => [
            marginLeft => '0.75em',
          ]
        ],
      ],
    ],

    'main::before, #profile::before' => [
      display    => 'block',
      content    => q{"↓"},
      textAlign  => 'center',
      fontWeight => 'bold',
      margin     => '2em 0',
    ],

    '#profile' => [
      paddingTop   => '0.5em',
      marginBottom => '0',

      figure => [
        margin => 0,

        p => [
          float  => 'left',
          margin => '0 1em 1em 0',
        ],

        figcaption => [
          marginBottom => '0.5em',
        ],
      ],

      '.entry__content' => [
        p => [
          margin   => 0,
          fontSize => '0.75em',
        ],
      ],

      'nav p' => [
        fontSize => '0.825em',
        a        => [
          marginRight => '0.625em',
        ],
      ],
    ],
  );
}

sub entry {
  return (
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
          span => [ textAlign => 'right' ],
        ],

        h1 => [ fontSize => '1.5em' ],

        'h1 a' => [
          textDecoration => 'none',
          lineHeight     => '1.414em',

          (
            map {
              (
                "&:${_}"        => [ color => color('entryTitle') ],
                "&:${_}:hover"  => [ color => color('entryTitleActivated') ],
                "&:${_}:active" => [ color => color('entryTitleActivated') ],
              )
            } qw(link visited)
          ),
        ],
      ],
    ],
  );
}

sub card {
  return (
    # thumbnail
    '.content__card--thumbnail' => [
      display => 'block',
      width   => '100%',

      '& img' => [
        display      => 'block',
        borderRadius => '3px',
        height       => 'auto',
        width        => '100%',

        border     => '1px solid',
        transition => 'border-color 0.125s',
        "&"        => [ borderColor => color('background') ],
        "&:hover"  => [ borderColor => color('borderColorImage') ],
        "&:active" => [ borderColor => color('borderColorImage') ],
      ],
    ],

    # website
    '.content__card--website' => [
      a => [
        backgroundColor => color('background'),
        (
          map {
            (
              "&:${_}"        => [ borderColor => color('borderColorWebsite') ],
              "&:${_}:hover"  => [ borderColor => color('borderColorWebsiteActivated') ],
              "&:${_}:active" => [ borderColor => color('borderColorWebsiteActivated') ],
            )
          } qw(link visited)
        ),

        h2 => [
          color => color('foreground'),
        ],

        cite => [
          color => color('foregroundURL'),
        ],

        blockquote => [
          color => color('borderColorQuote'),
        ],
      ],

      div => [
        backgroundColor => color('background'),
        h2              => [
          color => color('linkDisabled'),
        ],

        cite => [
          color => color('linkDisabled'),
        ],

        blockquote => [
          color => color('linkDisabled'),

          '&::before' => [
            backgroundColor => color('linkDisabled'),
          ],
        ],
      ],

      [qw(a div)] => [
        display  => 'block',
        overflow => 'hidden',

        padding      => '0.25em 01em',
        borderRadius => '3px',

        transition     => 'border-color 0.125s',
        textDecoration => 'none',

        border => '1px solid',
      ],

      "h3" => [
        fontSize     => "1.2em",
        marginBottom => 0,
      ],

      "h3 + p" => [
        margin => 0,
      ],

      cite => [
        fontStyle  => 'normal',
        fontWeight => 'bold',
        fontSize   => '0.8em',
      ],

      "cite + small" => [
        color      => color('linkDisabled'),
        fontStyle  => 'normal',
        fontWeight => 'bold',
        fontSize   => '0.7em',
        marginLeft => '0.5em',
      ],

      blockquote => [
        marginTop => '0.5em',
        fontSize  => '0.75em',
      ],
    ],

    # affiliate
    '.content__card--affiliate' => [
      margin          => '1em 0',
      backgroundColor => color('background'),
      padding         => '0.25em 1em',
      borderRadius    => '3px',
      border          => "1px solid @{[ color('borderColorAffiliate') ]}",
      overflow        => 'hidden',

      h2 => [
        fontSize => "1.2em",
        float    => 'left',

        a => [
          textDecoration => 'underline',
          (
            map {
              (
                "&:${_}"        => [ color => color('entryTitle') ],
                "&:${_}:hover"  => [ color => color('entryTitleActivated') ],
                "&:${_}:active" => [ color => color('entryTitleActivated') ],
              )
            } qw(link visited)
          )
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

          '&.amazon::before'     => [ backgroundColor => color('brandColorAmazon') ],
          '&.rakuten::before'    => [ backgroundColor => color('brandColorRakuten') ],
          '&.aliexpress::before' => [ backgroundColor => color('brandColorAliexpress') ],
          '&.banggood::before'   => [ backgroundColor => color('brandColorBanggood') ],
          '&.gearbest::before'   => [ backgroundColor => color('brandColorGearbest') ],
        ],

        'li a' => [
          (
            map {
              (
                "&:${_}"        => [ color => color('foregroundAffiliate') ],
                "&:${_}:hover"  => [ color => color('foregroundAffiliateActivated') ],
                "&:${_}:active" => [ color => color('foregroundAffiliateActivated') ],
              )
            } qw(link visited)
          )
        ],
      ],

      '&::after' => [
        display => 'block',
        content => q(""),
        clear   => 'both',
      ],
    ],

  );
}

sub content {
  return (
    '.entry__content' => [
      '#profile__information' => [
        textAlign => 'center',

        img => [
          margin => '0 auto',
          width  => '256px',
          height => '256px',
          border => 'none',
        ],
      ],

      [qw( h2 h3 h4 h5 h6 )] => [
        margin => '1em 0',
      ],

      h2 => [ fontSize   => '1.375em' ],
      h3 => [ fontSize   => '1.25em' ],
      h4 => [ fontSize   => '1.125em' ],
      h5 => [ fontSize   => '1em' ],
      h6 => [ fontWeight => 'bold' ],

      p => [ lineHeight => '1.727em' ],

      hr => [
        margin          => '2em auto',
        width           => '100%',
        backgroundColor => color('borderColorHr'),
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
          backgroundColor => color('borderColorQuote'),
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

      ul => [
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
            backgroundColor => color('borderColorList'),
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
        fontFamily => q(monospace),
      ],

      pre => [
        backgroundColor => color('backgroundCodeBlock'),
        color           => color('background'),
        padding         => '0.25em 0.5em',
        borderRadius    => '3px',
        whiteSpace      => 'pre',
      ],

      'pre > code' => [
        width      => '100%',
        height     => '100%',
        display    => 'block',
        overflowX  => 'scroll',
        overflowY  => 'hidden',
        whiteSpace => 'pre',
      ],

      '*:not(pre) > code' => [
        backgroundColor => color('backgroundCode'),
        borderRadius    => '3px',
        fontSize        => '0.9em',
        padding         => '0.1em 0.25em',
      ],

      'p.img > a > img' => [
        borderRadius => '3px',
        border       => "1px solid @{[ color('background') ]}",
        height       => 'auto',
        maxHeight    => '100%'
      ],

      strong => [
        fontWeight => 600,
      ],

      card,
    ],
  );
}

sub archive {
  return (
    [qw( .entry__home .entry__archives .entry__related )] => [
      '.entry__content .archives' => [
        li => [
          marginBottom => '2em',

          'a.title' => [
            display    => 'block',
            lineHeight => '1.727em',
          ],
        ],

      ],
      '.entry__content .logs' => [
        '& > *' => [ margin => '0 0.5em' ],
      ],
    ],
  );
}

sub copyright {
  return (
    '#copyright' => [
      marginTop    => '2.5em',
      marginBottom => '2.5em',
      textAlign    => 'center',
    ],
  );
}

sub render {
  my $main = css(
    [
      global,
      container,

      widgets,
      entry,
      content,
      archive,

      copyright,
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
    ]
  );

  my $small = css(
    [
      '.entry__content .content__card--affiliate p' => [
        float     => 'none',
        margin    => '1em auto',
        textAlign => 'center',
      ],
    ]
  );

  my $out = <<"...";
\@import "./normalize.css";

${main}
\@media screen and (max-width: 37.5em) {${middle}}
\@media screen and (max-width: 25em) {${small}}
...

  return $out;
}

=cut
