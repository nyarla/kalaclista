package WebSite::Worker::Markdown;

use v5.38;
use utf8;

use feature qw(state);

use Exporter::Lite;

our @EXPORT_OK = qw(compile worker should_update queues);

use Time::HiRes qw(stat);
use Markdown::Perl;

use Kalaclista::Loader::Files   qw(files);
use Kalaclista::Loader::Content qw(content);
use Kalaclista::Path;

use WebSite::Context::Path qw(srcdir);

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
  my ( $src, $dest ) = @{$job}{qw(src dest)};

  if ( !should_update( $src, $dest ) ) {
    $job->{'skip'}++;
    return $job;
  }

  my $markdown = content $src;
  my $html     = compile $markdown;

  my $emitter = Kalaclista::Path::new( path => $dest );
  $emitter->mkpath;
  $emitter->emit($html);

  $job->{'done'}++;

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

  my @jobs = map {
    my $src = $_;

    my $dest = $src;
    $dest =~ s<$srcdir><$destdir>;

    my $msg = $src;
    $msg =~ s<$srcdir><>;

    { src => $src, dest => $dest }
  } sort { $a cmp $b } files $srcdir;

  return @jobs;
}

=head2 AUTHOR

OKAMURA Naoki aka nyarla E<lt>nyarla@kalaclista.comE<gt>.

=cut

1;
