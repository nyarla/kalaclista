package WebSite::Helper::NeoVimColor;

use v5.38;
use utf8;

use File::Basename qw(fileparse);
use Exporter::Lite;
use HTML5::DOM;

our @EXPORT_OK = qw(ftdetect detect parse render);

use Kalaclista::Path;

my sub dom : prototype($) { state $p = HTML5::DOM->new; $p->parse(shift) }

=head1 NAME

WebSite::Helper::NeoVimColor - The code block highligher by NeoVim

=head1 FUNCTIONS

=head2 ftdetect C<$lang>, C<$filename>

  # => perl
  my $lang = ftdetect 'perl';
  
  # => perl
  my $lang = ftdetect '', 'script.pl';

  # => javascriptreact
  my $lang = ftdetect '', 'filename.jsx';

=cut

sub ftdetect : prototype($;$) {
  state $language ||= {
    'bash'            => qr{^bash|shell|pkgbuild|xinitrc$}i,
    'csh'             => qr{^csh$}i,
    'css'             => qr{^css$}i,
    'diff'            => qr{^(?:diff|patch)$}i,
    'dockerfile'      => qr{^dockerfile$}i,
    'dosbatch'        => qr{^(?:bat|cmd|prompt)$}i,
    'dosini'          => qr{^ini$}i,
    'go'              => qr{^go$}i,
    'html'            => qr{^(?:html|xhtml)$}i,
    'javascript'      => qr{^(?:javascript|js)$}i,
    'javascriptreact' => qr{^jsx$}i,
    'json'            => qr{^json$}i,
    'lua'             => qr{^lua$},
    'make'            => qr{^(?:make|makefile)$}i,
    'nix'             => qr{^nix$}i,
    'perl'            => qr{^perl$}i,
    'ps1'             => qr{^(?:powershell|ps1)$}i,
    'registry'        => qr{^(?:reg|registry)$}i,
    'ruby'            => qr{^ruby$}i,
    'scss'            => qr{^scss$},
    'sh'              => qr{^(?:apkbuild|sh)$}i,
    'swift'           => qr{^swift$}i,
    'toml'            => qr{^toml$}i,
    'typescript'      => qr{^ts$}i,
    'typescriptreact' => qr{^tsx$}i,
    'vim'             => qr{^(?:nvim|vim)$}i,
    'xdefaults'       => qr{^xresources$}i,
    'xf86config'      => qr{^xorg$}i,
    'xml'             => qr{^xml$}i,
    'yaml'            => qr{^(?:yaml)$}i,
    'zsh'             => qr{^zsh$}i,
  };

  state $filepath ||= {
    'bash'            => qr{\.sh$|^pkgbuild$|^.xinitrc$}i,
    'csh'             => qr{\.csh$}i,
    'css'             => qr{\.css$}i,
    'diff'            => qr{\.(?:diff|patch)$}i,
    'dockerfile'      => qr{^dockerfile}i,
    'dosbatch'        => qr{\.(?:bat|cmd)$}i,
    'dosini'          => qr{\.ini$},
    'go'              => qr{\.go$}i,
    'html'            => qr{\.x?html?$}i,
    'javascript'      => qr{\.js$}i,
    'javascriptreact' => qr{\.jsx$}i,
    'json'            => qr{\.json$}i,
    'make'            => qr{^makefile$|\.mk$}i,
    'nix'             => qr{\.nix$}i,
    'perl'            => qr{\.(?:pl|pm|t)$}i,
    'ps1'             => qr{\.ps1$}i,
    'registry'        => qr{\.reg$}i,
    'scss'            => qr{\.scss$}i,
    'sh'              => qr{\.sh$|^apkbuild$}i,
    'swift'           => qr{\.swift$}i,
    'toml'            => qr{\.toml$}i,
    'typescript'      => qr{\.ts$}i,
    'typescriptreact' => qr{\.tsx$}i,
    'vim'             => qr{\.n?vim}i,
    'xdefaults'       => qr{^\.Xresources$}i,
    'xml'             => qr{\.(?:atom|opml|rss|xml)$}i,
    'yaml'            => qr{\.(?:yaml|yml)$}i,
    'zsh'             => qr{\.zsh$}i,
  };

  my ( $lang, $path ) = @_;
  for my $ft ( keys $language->%* ) {
    return $ft if $lang =~ $language->{$ft};
  }

  if ( defined $path && $path ne q{} ) {
    for my $ft ( keys $filepath->%* ) {
      return $ft if $path =~ $filepath->{$ft};
    }
  }

  return q{};
}

=head2 detect C<$line>

  # $lang => 'perl', $filename => 'script.pl'
  my ($lang, $filename) = detect 'language-perl:script.pl';

  # the case of broken source
  # $lang => 'perl'
  my ($lang,undef) = detect 'language-(perl)';

  # the missing language case
  # $filename => 'script.pl'
  my (undef, $filename) = detect 'script.pl';

=cut

sub detect : prototype($) {
  my $line = shift;

  $line =~ s{^language-[\-_]*}{};
  $line =~ s{[()]}{}g;

  if ( $line =~ m{:} ) {
    my ( $ft, $fn ) = $line =~ m{^([^:]+):(.+)$};
    return ( $ft, ( fileparse($fn) )[0] );
  }

  if ( $line =~ m{[/\.]} ) {
    return ( q{}, ( fileparse($line) )[0] );
  }

  return ( $line, q{} );
}

=head2 render C<$code, $line>

  my $code = '...'                      # a source code in articles
  my $lang = 'language-perl:script.pl'  # the language information about source code

  # render html with code highlight
  my $html = render $code, $lang;

=cut

sub render : prototype($$) {
  state $nvimrc ||= $ENV{'HOME'} . '/.config/nvim/highlight.lua';
  state $rccmd  ||= -e $nvimrc ? qq<-u ${nvimrc}> : q<>;

  my ( $code, $line ) = @_;

  my $filetype = ftdetect( detect($line) );
  my $ftcmd    = $filetype ne q{} ? qq<set ft=${filetype}> : "filetype detect";

  my $dump = Kalaclista::Path->tempfile;
  my $load = Kalaclista::Path->tempfile;

  utf8::encode($code) if utf8::is_utf8($code);
  $dump->emit($code);

  my $cmds   = qq#-c "e @{[ $dump->path ]} | ${ftcmd} | TOhtml | w! @{[ $load->path ]} | qa!"#;
  my $launch = qq<nvim -n ${rccmd} ${cmds}>;

  `${launch} 1>/dev/null 2>&1`;

  my $html = $load->load;
  utf8::decode($html);

  return $html;
}

=head2 parse C<$html>

  my $html = '...' # highlighted html code by NeoVim
  
  my ($code, $style) = parse $html;

  print $code;  # html block for code highlight
  print $style; # stylesheet for highlighted html

=cut

sub parse : prototype($) {
  my $html  = shift;
  my $dom   = dom $html;
  my $style = $dom->at('head > style')->innerHTML;
  my $code  = $dom->at('body > pre')->innerHTML;

  $code  =~ s{\n+$}{};
  $style =~ s{(?:body|\*)[^\n]+\n}{}g;

  return ( $code, $style );
}

1;
