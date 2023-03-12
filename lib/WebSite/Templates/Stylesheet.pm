package WebSite::Templates::Stylesheet;

use strict;
use warnings;

use feature qw(state);

use Exporter::Lite;

our @EXPORT = qw(stylesheet);

use Kalaclista::HyperStyle qw(css);

sub color {
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
