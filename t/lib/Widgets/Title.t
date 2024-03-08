#!/usr/bin/env perl

use v5.38;
use utf8;

use Test2::V0;
use HTML5::DOM;

use Kalaclista::Data::Page;

use WebSite::Context;
use WebSite::Context::URI   qw(href);
use WebSite::Widgets::Title qw(banner);

my sub dom : prototype($) { state $dom ||= HTML5::DOM->new; $dom->parse(shift)->body }

subtest title => sub {
  my $c = WebSite::Context->init(qr{^t$});

  for my $section (qw(posts echos notes home)) {
    my $page = Kalaclista::Data::Page->new( section => $section );
    my $html = banner($page);
    utf8::decode($html);
    my $dom  = dom $html;
    my $path = $section ne q{home} ? "${section}/" : "";

    is $dom->at('nav')->attr('id'), 'global';

    is $dom->at('#global > p > a')->attr('href'),         href('/')->to_string;
    is $dom->at('#global > p > a > img')->attr('src'),    href('/assets/avatar.svg')->to_string;
    is $dom->at('#global > p > a > img')->attr('width'),  50;
    is $dom->at('#global > p > a > img')->attr('height'), 50;

    if ( $section ne q{home} ) {
      is $dom->at('#global > p > span')->textContent,          '→';
      is $dom->at('#global > p > a:last-child')->attr('href'), href("/${path}")->to_string;
      is $dom->at('#global > p > a:last-child')->textContent,  $c->sections->{$section}->label;
    }
    else {
      is scalar( $dom->find('#global > p a')->@* ), 1;
    }
  }
};

done_testing;
