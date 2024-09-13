#!/usr/bin/env perl

use v5.28;
use utf8;

use Parallel::Fork::BossWorkerAsync;

use WebSite::Worker::Images        qw(worker queues);
use WebSite::Helper::MakeDirectory qw(mkpath);

sub main {
  my $parallel = shift;
  my @sizes    = @_;

  my @queues = queues( [@sizes] );
  mkpath( map { $_->{'dest'} } @queues );

  my $bw = Parallel::Fork::BossWorkerAsync->new(
    work_handler   => \&worker,
    global_timeout => 10,
    worker_count   => $parallel,
  );

  $bw->add_work(@queues);

  while ( $bw->pending ) {
    my $result = $bw->get_result;
    my $msg    = $result->{'msg'};
    if ( !exists $result->{'ERROR'} ) {
      print "Compiled: ${msg}\n";
    }
    else {
      print "Failed: ${msg}: " . $result->{'ERROR'} . "\n";
    }
  }

  $bw->shut_down;
}

main(@ARGV);
