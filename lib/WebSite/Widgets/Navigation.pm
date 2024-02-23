package WebSite::Widgets::Navigation;

use strict;
use warnings;
use utf8;

use feature qw(state);

use Exporter::Lite;

our @EXPORT = qw(navigation);

use Kalaclista::HyperScript qw(nav p div span a img);

use WebSite::Context;
use WebSite::Helper::TailwindCSS;

sub href {
  my $path = shift;
  my $href = WebSite::Context->instance->baseURI->clone;
  $href->path($path);

  return $href->to_string;
}

sub c { state $c ||= WebSite::Context->instance; $c }

sub label {
  my $label = shift;
  my $path  = href(shift);
  my $attrs = shift // {};

  $attrs->{'href'} = $path;

  return a( $attrs, $label );
}

sub title {
  state $icon ||= a(
    classes(q|block mx-auto mb-4|),
    { href => href('/'), aria => { hidden => 'true' } },
    img(
      classes(q|inline-block border-4 border-bright rounded-xl bg-brightest|),
      {
        src    => href('/assets/avatar.svg'),
        height => 48,
        width  => 48,
        alt    => ''
      }
    )
  );

  state $home ||= p(
    $icon,
    a( classes(qw(p-name u-url site-title)), { href => href('/'), aria => { current => 'page' } }, c->website->label ),
  );

  state $tree ||= p(
    $icon,
    a( classes(qw(p-name u-url site-title)), { href => href('/') }, c->website->label ),
  );

  my $current = shift // !!0;
  return $current ? $home : $tree;
}

sub breadcrumb {
  state $tree ||= div( classes(q|my-2 text-md|), { aria => { hidden => 'true' } }, '・' );
  state $sep  ||= span( classes(q|mx-2 text-xs |), { aria => { hidden => 'true' } }, '/' );

  my $section = shift;
  my $kind    = shift;
  my $href    = shift;

  my @breadcrumb = ( title( $section eq q{pages} && $kind eq q{home} ), $tree );
  if ( $section eq 'pages' && $kind eq 'permalink' ) {
    if ( $href eq 'nyarla' ) {
      push @breadcrumb, p( a( { href => href('/nyarla/'), aria => { current => 'page' } }, 'プロフィール' ) );
    }
    elsif ( $href eq 'policies' ) {
      push @breadcrumb, p( a( { href => href('/policies/'), aria => { current => 'page' } }, '運営ポリシー' ) );
    }
    elsif ( $href eq 'licenses' ) {
      push @breadcrumb, p( a( { href => href('/licenses/'), aria => { current => 'page' } }, 'ライセンスなど' ) );
    }

    return @breadcrumb;
  }

  if ( $kind eq '404' ) {
    push @breadcrumb, p('404 Not Found');
    return @breadcrumb;
  }

  for my $type (qw(posts echos notes)) {
    my @attrs = ( href => href("/${type}/") );
    if ( $type eq $section ) {
      push @attrs, ( aria  => { current => 'page' } );
      push @attrs, ( class => q|font-bold| );
    }

    push @breadcrumb, a( {@attrs}, c->sections->{$type}->label );
    push @breadcrumb, $sep if $type ne q{notes};
  }

  return @breadcrumb;
}

sub navigation {
  my $page = shift;
  return nav(
    classes(q|my-24 text-center|),
    breadcrumb( $page->section, $page->kind, ( defined $page->href ? $page->href->path : undef ) ),
  );
}

1;
