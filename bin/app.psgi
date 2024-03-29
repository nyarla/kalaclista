#!/usr/bin/env perl

use strict;
use warnings;

use Plack::App::File;
use Plack::Builder;
use Plack::Middleware::DirIndex;
 
my $app = Plack::App::File->new(
  root => 'public/development',
);

builder {
  enable 'Plack::Middleware::DirIndex', root => 'public/development', dir_index => 'index.html';

  $app;
};
