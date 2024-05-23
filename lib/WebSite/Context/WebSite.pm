package WebSite::Context::WebSite;

use v5.38;
use utf8;

use Exporter::Lite;

our @EXPORT_OK = qw(website posts echos notes section);

use Kalaclista::Data::WebSite;

use WebSite::Context::URI qw(href);

sub website {
  state $website ||= Kalaclista::Data::WebSite->new(
    label   => 'カラクリスタ',
    title   => 'カラクリスタ',
    summary => '『輝かしい青春』なんて失かった人の Web サイトです',
    href    => href(''),
  );

  return $website;
}

sub posts {
  state $website ||= Kalaclista::Data::WebSite->new(
    label   => 'ブログ',
    title   => 'カラクリスタ・ブログ',
    summary => '『輝かしい青春』なんて失かった人のブログです',
    href    => href('/posts/'),
  );

  return $website;
}

sub echos {
  state $website ||= Kalaclista::Data::WebSite->new(
    label   => '日記',
    title   => 'カラクリスタ・エコーズ',
    summary => '『輝かしい青春』なんて失かった人の日記です',
    href    => href('/echos/'),
  );

  return $website;
}

sub notes {
  state $website ||= Kalaclista::Data::WebSite->new(
    label   => 'メモ帳',
    title   => 'カラクリスタ・ノート',
    summary => '『輝かしい青春』なんて失かった人のメモ帳です',
    href    => href('/notes/'),
  );

  return $website;
}

sub section {
  my $section = shift;

  if ( $section eq 'posts' ) {
    return posts;
  }

  if ( $section eq 'echos' ) {
    return echos;
  }

  if ( $section eq 'notes' ) {
    return notes;
  }

  return website;
}

1;
