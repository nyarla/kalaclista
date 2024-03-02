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
        overflowWrap => 'anywhere',

        [qw/ strong a /] => [ margin => '0 .25em' ],
      ],

      '.ads' => [
        margin => '1em 0',

        '&.top' => [ minHeight => '140px', maxHeight => '140px', ],
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

        h2 => [
          fontSize => '1em',
          display  => 'inline',

          a => [ color => color('white-2') ]
        ],

        ul => [
          paddingLeft   => '2em',
          paddingBottom => '1em',
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

        [ '& > a', '& > div' ] => [
          textDecoration => 'none',

          [ '& > h2', '& p' ] => [
            textOverflow => q("…"),
            overflow     => 'hidden',
            whiteSpace   => 'nowrap',
          ],

          '& > h2' => [ margin => '0', fontSize => '1em' ],
          '& > p'  => [
            margin => '0 0 0.5em 0',
            cite   => [
              fontSize       => '.8em',
              fontStyle      => 'normal',
              textDecoration => 'underline solid 1px',
            ],
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

        '&:hover::before' => [
          background('green-12'),
          transition => 'background ease .1s',
        ],

        '& > a' => [
          '& > h2'     => [ foreground('white-2') ],
          '& > p cite' => [
            foreground('green-8'),
            textDecorationColor => color('green-8') . ' !important',
          ],
          '& > blockquote' => [ foreground('white-2') ],
        ],

        '& > div' => [
          '& > h2'     => [ foreground('white-6') ],
          '& > p cite' => [
            foreground('white-6'),
          ],
          '& > p cite + small'     => [ foreground('white-0') ],
          '& > blockquote'         => [ foreground('white-6') ],
          '& > blockquote::before' => [ background('white-12') ],
        ],

        [ '&.gone::before', '&.gone:hover::before' ] => [ background('white-12') ],
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
/*! main.css */
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

1;
