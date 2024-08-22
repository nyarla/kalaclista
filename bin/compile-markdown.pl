#!/usr/bin/env perl

use v5.38;
use utf8;

use Parallel::Fork::BossWorkerAsync;

use WebSite::Worker::Markdown qw(worker queues);

sub main {
  my $parallel = shift;

  my $bw = Parallel::Fork::BossWorkerAsync->new(
    work_handler   => \&worker,
    global_timeout => 5,
    worker_count   => $parallel,
  );

  $bw->add_work( queues() );
  while ( $bw->pending() ) {
    my $result = $bw->get_result;
    if ( exists $result->{'done'} && $result->{'done'} > 0 ) {
      print "Compiled: " . $result->{'msg'} . ' -> ' . $result->{'dest'} . "\n";
    }
  }

  $bw->shut_down();
}

main(@ARGV);
