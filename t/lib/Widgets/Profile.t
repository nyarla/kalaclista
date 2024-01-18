#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Test2::V0;

use HTML5::DOM;

use WebSite::Context;
use WebSite::Widgets::Profile;

my $parser = HTML5::DOM->new;
my $c      = WebSite::Context->init(qr{^t$});

my $profile = profile;
utf8::decode($profile);
my $dom = $parser->parse($profile);

sub href {
  my $path = shift;
  my $href = $c->baseURI->clone;
  $href->path($path);

  return $href->to_string;
}

subtest avatar => sub {
  is $dom->at('address > p:first-child > a')->getAttribute('href'),         href('/nyarla/');
  is $dom->at('address > p:first-child > a > img')->getAttribute('src'),    href('/assets/avatar.svg');
  is $dom->at('address > p:first-child > a > img')->getAttribute('height'), 96;
  is $dom->at('address > p:first-child > a > img')->getAttribute('width'),  96;
  is $dom->at('address > p:first-child > a > span')->textContent,           'にゃるら（カラクリスタ）';
};

subtest contacts => sub {
  is $dom->at('address > nav > ul:nth-child(3) > li:nth-child(1) > a')->textContent,          'Email';
  is $dom->at('address > nav > ul:nth-child(3) > li:nth-child(1) > a')->getAttribute('href'), 'mailto:nyarla@kalaclista.com';

  is $dom->at('address > nav > ul:nth-child(3) > li:nth-child(2) > a')->textContent,          'GoToSocial';
  is $dom->at('address > nav > ul:nth-child(3) > li:nth-child(2) > a')->getAttribute('href'), 'https://kalaclista.com/@nyarla';

  is $dom->at('address > nav > ul:nth-child(3) > li:nth-child(3) > a')->textContent,          'Misskey.io';
  is $dom->at('address > nav > ul:nth-child(3) > li:nth-child(3) > a')->getAttribute('href'), 'https://misskey.io/@nyarla';
};

subtest website => sub {
  is $dom->at('address > nav > ul:nth-child(4) > li:nth-child(1) > a')->textContent,          'GitHub';
  is $dom->at('address > nav > ul:nth-child(4) > li:nth-child(1) > a')->getAttribute('href'), 'https://github.com/nyarla/';

  is $dom->at('address > nav > ul:nth-child(4) > li:nth-child(2) > a')->textContent,          'Zenn';
  is $dom->at('address > nav > ul:nth-child(4) > li:nth-child(2) > a')->getAttribute('href'), 'https://zenn.dev/nyarla/';

  is $dom->at('address > nav > ul:nth-child(4) > li:nth-child(3) > a')->textContent,          'しずかなインターネット';
  is $dom->at('address > nav > ul:nth-child(4) > li:nth-child(3) > a')->getAttribute('href'), 'https://sizu.me/nyarla/';

  is $dom->at('address > nav > ul:nth-child(4) > li:nth-child(4) > a')->textContent,          'note';
  is $dom->at('address > nav > ul:nth-child(4) > li:nth-child(4) > a')->getAttribute('href'), 'https://note.com/kalaclista/';
};

done_testing;
