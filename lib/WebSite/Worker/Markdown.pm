package WebSite::Worker::Markdown;

use v5.38;
use utf8;

use feature qw(state);

use Exporter::Lite;
use HTML5::DOM;
use YAML::XS qw(Dump);

our @EXPORT_OK = qw(compile worker should_update queues highlight);

use Time::HiRes qw(stat);
use Markdown::Perl;

use Kalaclista::Loader::Files   qw(files);
use Kalaclista::Loader::Content qw(content);
use Kalaclista::Path;

use WebSite::Context::Path       qw(srcdir);
use WebSite::Helper::NeoVimColor qw(render parse);

my sub dom : prototype($) { state $dom ||= HTML5::DOM->new; $dom->parse(shift) }

=head1 NAME

WebSite::Worker::Markdown - A worker modules for the compiling markdown files.

=head1 INTERFACES

=cut

=head2 compile C<$markdown>

  my $markdown  = '...';              # markdown text.
  my $html      = compile $markdown;  # compile markdown text to html.

=cut

sub compile : prototype($) {
  state $compiler ||= Markdown::Perl->new(
    mode                   => 'github',
    use_extended_autolinks => !!0,
  );

  return $compiler->convert(shift);
}

=head2 highlight C<$html>, C<$codedir>

  my $html    = '...' # compiled html from markdown
  my $codedir = '...' # path to store of highlight data

  # make the syntax highlight files
  highlight $html, $codedir

=cut

sub highlight : prototype($$) {
  my ( $html, $basedir ) = @_;

  $basedir = Kalaclista::Path->new( path => $basedir );

  my $dom = dom $html;
  my $idx = 0;

  for my $block ( $dom->find('pre > code[class]')->@* ) {
    $idx++;

    my $src  = $block->text;
    my $lang = $block->attr('class');

    my ( $highlight, $style ) = parse render $src, $lang;

    my $path = $basedir->child("${idx}.yml");
    $path->parent->mkpath;

    $path->emit( Dump( { highlight => $highlight, style => $style } ) );
  }

  return $idx;
}

=head2 should_update(C<$src>, C<$dest>)

  my $src   = '...'; # the fullpath of markdown file
  my $dest  = '...'; # the fullpath of precompile file

  # This functions returns true at these cases:
  # 
  # 1. update time of $src is newer than $dest
  # 2. $dest does not exists 
  my $bool  = should_update($src, $dest);

=cut

sub should_update {
  my ( $src, $dest ) = @_;

  if ( !-e $dest ) {
    return 1;
  }

  return ( stat($src) )[9] > ( stat($dest) )[9];
}

=head2 worker(C<$job>)

  # job hash structure:
  my $job = {
    src   => '...', # the fullpath of markdown file
    dest  => '...', # the fullpath of precompile file
  };
  
  # process $job by worker
  my $result = worker($job);
  
  # $result hash structure
  $result = {
    skip => $bool, # the boolean vlaue of this job is skipped.
    done => $bool, # the boolean value of this job is procced. 
    src  => '...', # same value of $job->{'src'}
    dest => '...', # same value of $job->{'dest'}
  }; 

=cut

sub worker {
  my $job = shift;
  my ( $src, $dest, $code ) = @{$job}{qw(src dest code)};

  if ( !should_update( $src, $dest ) ) {
    $job->{'skip'}++;
    return $job;
  }

  my $markdown = content $src;
  my $html     = compile $markdown;
  my $codes    = 0;

  if ( $html =~ m{<pre><code} ) {
    $codes = highlight $html, $code;
  }

  my $emitter = Kalaclista::Path->new( path => $dest );
  $emitter->parent->mkpath;
  $emitter->emit($html);

  $job->{'done'}++;
  $job->{'codes'} += $codes;

  return $job;
}

=head2 queue

  # make the list of $job
  my @jobs = queues;
  
  $job[0] = {
    src   => '...', # the fullpath of markdown file.
    dest  => '...', # the fullpath of precompile file.
  };

=cut

sub queues {
  my $srcdir  = srcdir->child('entries/src')->path;
  my $destdir = srcdir->child('entries/precompiled')->path;
  my $codedir = srcdir->child('entries/code')->path;

  my @jobs = map {
    my $src = $_;

    my $dest = $src;
    $dest =~ s<$srcdir><$destdir>;

    my $code = $src;
    $code =~ s<$srcdir><$codedir>;
    $code =~ s<\.md$><>;

    my $msg = $src;
    $msg =~ s<$srcdir><>;

    { src => $src, dest => $dest, code => $code, msg => $msg, codes => 0 }
  } sort { $a cmp $b } files $srcdir;

  return @jobs;
}

=head2 AUTHOR

OKAMURA Naoki aka nyarla E<lt>nyarla@kalaclista.comE<gt>.

=cut

1;
