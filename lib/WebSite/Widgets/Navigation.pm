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
      classes(q|inline-block border-4 border-unactionable rounded-xl bg-bright|),
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
  if ( $section eq 'pages' ) {
    if ( $kind eq 'home' ) {
      push @breadcrumb, p(
        a( { href => href('/posts/') }, c->sections->{posts}->label ),
        $sep,
        a( { href => href('/echos/') }, c->sections->{echos}->label ),
        $sep,
        a( { href => href('/notes/') }, c->sections->{notes}->label ),
      );
    }
    elsif ( $kind eq 'permalink' ) {
      if ( $href eq 'nyarla' ) {
        push @breadcrumb, p( a( { href => href('/nyarla/'), aria => { current => 'page' } }, 'プロフィール' ) );
      }
      elsif ( $href eq 'policies' ) {
        push @breadcrumb, p( a( { href => href('/policies/'), aria => { current => 'page' } }, '運営ポリシー' ) );
      }
      elsif ( $href eq 'licenses' ) {
        push @breadcrumb, p( a( { href => href('/licenses/'), aria => { current => 'page' } }, 'ライセンスなど' ) );
      }
    }
  }
  else {
    if ( $section eq 'posts' ) {
      push @breadcrumb,
          p(
            classes(q|p-name u-url site-title|),
            a( { href => href('/posts/'), aria => { current => 'page' } }, c->sections->{posts}->label )
          );
    }
    elsif ( $section eq 'echos' ) {
      push @breadcrumb,
          p(
            classes(q|p-name u-url site-title|),
            a( { href => href('/echos/'), aria => { current => 'page' } }, c->sections->{echos}->label )
          );
    }
    elsif ( $section eq 'notes' ) {
      push @breadcrumb,
          p(
            classes(q|p-name u-url site-title|),
            a( { href => href('/notes/'), aria => { current => 'page' } }, c->sections->{notes}->label )
          );
    }
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
