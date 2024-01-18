package WebSite::Widgets::Navigation;

use strict;
use warnings;
use utf8;

use feature qw(state);

use Exporter::Lite;

our @EXPORT = qw(navigation);

use Kalaclista::HyperScript qw(nav p div span a);

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
  state $home ||= p( label( c->website->label => '/', { class => classes(qw(p-name u-url site-title)), aria => { current => 'page' } }, ) );
  state $tree ||= p( label( c->website->label => '/' ) );

  my $current = shift // !!0;
  return $current ? $home : $tree;
}

sub breadcrumb {
  state $tree ||= div( { class => custom(q|my-2 text-md |), aria => { hidden => 'true' } }, '・' );
  state $sep  ||= span( { class => custom(q|mx-2 text-xs |), aria => { hidden => 'true' } }, '/' );

  my $section = shift;
  my $kind    = shift;
  my $href    = shift;

  my @breadcrumb = ( title( $section eq q{pages} && $kind eq q{home} ), $tree );
  if ( $section eq 'pages' ) {
    if ( $kind eq 'home' ) {
      push @breadcrumb, p(
        label( c->sections->{posts}->label => '/posts/' ),
        $sep,
        label( c->sections->{echos}->label => '/echos/' ),
        $sep,
        label( c->sections->{notes}->label => '/notes/' ),
      );
    }
    elsif ( $kind eq 'permalink' ) {
      if ( $href eq 'nyarla' ) {
        push @breadcrumb, p( label( 'プロフィール' => '/nyarla/', { aria => { current => 'page' } } ) );
      }
      elsif ( $href eq 'policies' ) {
        push @breadcrumb, p( label( '運営ポリシー' => '/policies/', { aria => { current => 'page' } } ) );
      }
      elsif ( $href eq 'licenses' ) {
        push @breadcrumb, p( label( 'ライセンスなど' => '/licenses/', { aria => { current => 'page' } } ) );
      }
    }
  }
  else {
    if ( $section eq 'posts' ) {
      push @breadcrumb,
          p(
            label(
              c->sections->{posts}->label => '/posts/',
              { class => classes(qw(p-name u-url site-title)), aria => { current => 'page' } }
            )
          );
    }
    elsif ( $section eq 'echos' ) {
      push @breadcrumb,
          p(
            label(
              c->sections->{echos}->label => '/echos/',
              { class => classes(qw(p-name u-url site-title)), aria => { current => 'page' } }
            )
          );
    }
    elsif ( $section eq 'notes' ) {
      push @breadcrumb,
          p(
            label(
              c->sections->{notes}->label => '/notes/',
              { class => classes(qw(p-name u-url site-title)), aria => { current => 'page' } }
            )
          );
    }
  }

  return @breadcrumb;
}

sub navigation {
  my $page = shift;
  return nav(
    { class => custom(q|my-24 text-center|) },
    breadcrumb( $page->section, $page->kind, ( defined $page->href ? $page->href->path : undef ) ),
  );
}

1;
