package WebSite::Loader::Entry;

use v5.38;
use utf8;

use feature 'state';

use Exporter::Lite;
use HTML5::DOM;

use Kalaclista::Data::Entry;

use Kalaclista::Loader::Files   qw(files);
use Kalaclista::Loader::Content qw(header);

use WebSite::Context::Path qw(srcdir);
use WebSite::Context::URI  qw(href);

use WebSite::Extensions::AdjustHeading;
use WebSite::Extensions::CodeHighlight;
use WebSite::Extensions::Furigana;
use WebSite::Extensions::Picture;
use WebSite::Extensions::Products;
use WebSite::Extensions::WebSite;

our @EXPORT    = qw(prop entry entries);
our @EXPORT_OK = ( @EXPORT, qw(fixup) );

my @transformers = qw(
  WebSite::Extensions::AdjustHeading
  WebSite::Extensions::CodeHighlight
  WebSite::Extensions::Picture
  WebSite::Extensions::Furigana
  WebSite::Extensions::WebSite
  WebSite::Extensions::Products
);

my sub dom : prototype($) { state $p ||= HTML5::DOM->new; $p->parse(shift)->body }

my sub src         { state $d ||= srcdir->child('entries/src');         $d }
my sub precompiled { state $d ||= srcdir->child('entries/precompiled'); $d }

sub fixup : prototype($$) {
  my ( $src, $header ) = @_;
  my $root = srcdir->to_string;
  my $path = $src->to_string;

  my $section;
  my $href;

  $path =~ s{^$root/}{};

  if ( $path =~ m{(posts|echos)/(\d{4})/(\d{2})/(\d{2})/(\d{6})\.md$} ) {
    my ( $type, $year, $month, $day, $time ) = ( $1, $2, $3, $4, $5 );
    $href    = href "/${type}/${year}/${month}/${day}/${time}/";
    $section = $type;
  }
  elsif ( $path =~ m{notes/([^/]+)\.md$} ) {
    my $page = $1;
    $section = q{notes};
    if ( exists $header->{'slug'} ) {
      my $slug = $header->{'slug'};
      $slug =~ s{ }{-}g;

      $page = $slug;
    }

    $href = href "/notes/${page}/";
  }
  elsif ( $path =~ m{([^/]+)\.md$} ) {
    $href    = href "/${1}/";
    $section = q{pages};
  }

  my $data = {
    title   => delete $header->{'title'},
    summary => delete $header->{'summary'} // q{},
    section => $section,
    draft   => delete $header->{'draft'} // !!0,
    date    => delete $header->{'date'},
    href    => $href,
    src     => q{},
    dom     => undef,
  };

  $data->{'lastmod'}        = delete $header->{'lastmod'} // $data->{'date'};
  $data->{'meta'}           = $header;
  $data->{'meta'}->{'path'} = $path;

  return Kalaclista::Data::Entry->new( $data->%* );
}

sub prop : prototype($) {
  my $file   = shift;
  my $src    = src->child($file);
  my $header = header $src->path;

  return fixup $src => $header;
}

sub entry : prototype($) {
  my $file  = shift;
  my $entry = prop $file;

  my $content = precompiled->child($file)->load;
  utf8::decode($content);

  my $dom = dom $content;

  $entry = $entry->clone( src => $content, dom => $dom );

  for my $transformer (@transformers) {
    $entry = $transformer->transform($entry);
  }

  return $entry;
}

sub entries : prototype(&) {
  my $filter = shift;
  my $src    = src->path;
  return $filter->( map { s|$src/||; $_ } files $src );
}
1;
