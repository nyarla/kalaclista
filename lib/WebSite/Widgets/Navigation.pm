package WebSite::Widgets::Navigation;

use strict;
use warnings;
use utf8;

use feature qw(state);

use Exporter::Lite;

our @EXPORT = qw(navigation);

use Kalaclista::HyperScript qw(nav p a img hr span br);

use WebSite::Context;

sub href {
  my $path = shift;
  my $href = WebSite::Context->instance->baseURI->clone;
  $href->path($path);

  return $href->to_string;
}

sub c { state $c ||= WebSite::Context->instance; $c }

sub title {
  state $title ||= a(
    {
      href  => href('/'),
      class => q|block text-3xl align-middle mx-auto text-center my-8 pb-4|,
    },
    span( { class => q|block align-middle font-serif font-bold scale-x-50| }, "カラクリスタ" ),
  );

  return $title;
}

sub section {
  state $common    ||= q|inline-block |;
  state $underline ||= q| |;

  state $home  ||= a( { class => $common . $underline . q|pr-1|, href => href('/'), },       'ホーム' );
  state $posts ||= a( { class => $common . $underline . q|px-1|, href => href('/posts/'), }, c->sections->{posts}->label );
  state $echos ||= a( { class => $common . $underline . q|px-1|, href => href('/echos/'), }, c->sections->{echos}->label );
  state $notes ||= a( { class => $common . $underline . q|pl-1|, href => href('/notes/'), }, c->sections->{notes}->label );

  state $profile  ||= a( { class => $common . $underline . q|px-1|, href => href('/nyarla/'), },   'プロフィール' );
  state $policy   ||= a( { class => $common . $underline . q|px-1|, href => href('/policies/'), }, '運営ポリシー' );
  state $licenses ||= a( { class => $common . $underline . q|px-1|, href => href('/licenses/'), }, 'ライセンスなど' );

  my $section = shift;
  my $kind    = shift;
  my $href    = shift;

  my @breadcrumb;
  if ( $section eq 'pages' ) {
    if ( $kind eq 'home' ) {
      @breadcrumb = ( '→', $posts, '/', $echos, '/', $notes );
    }
    elsif ( $kind eq 'permalink' ) {
      if ( $href eq 'nyarla' ) {
        @breadcrumb = ( '→', $profile );
      }
      elsif ( $href eq 'policies' ) {
        @breadcrumb = ( '→', $policy );
      }
      elsif ( $href eq 'licenses' ) {
        @breadcrumb = ( '→', $licenses );
      }
    }
  }
  else {
    if ( $section eq 'posts' ) {
      @breadcrumb = ( '→', $posts );
    }
    elsif ( $section eq 'echos' ) {
      @breadcrumb = ( '→', $echos );
    }
    elsif ( $section eq 'notes' ) {
      @breadcrumb = ( '→', $notes );
    }
  }

  return p(
    {
      class => q|pb-4|,
    },
    $home,
    @breadcrumb,
  );
}

sub navigation {
  my $page = shift;

  return nav(
    title,
    section( $page->section, $page->kind, ( defined $page->href ? $page->href->path : undef ) ),
  );
}

1;
