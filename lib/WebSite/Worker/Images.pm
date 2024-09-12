package WebSite::Worker::Images;

use v5.38;
use utf8;

use Exporter::Lite;

our @EXPORT_OK = qw(copy size resize should_update worker queues);

use File::Basename qw(fileparse);
use YAML::XS       qw(Dump);

use Kalaclista::Loader::Files qw(files);
use WebSite::Context::Path    qw(srcdir distdir cachedir);

=head1 NAME

WebSite::Worker::Images - The convert images to webp, or copy gif files

=head1 MODULE FUNCTIONS

=head2 copy C<$src>, C<$dest>

  # Copy `$src` file to `$dist`

  copy $src, $dest;

=cut

sub copy : prototype($$) {
  my ( $src, $dest ) = @_;

  Kalaclista::Path->new( path => $dest )->parent->mkpath;

  return `cp "${src}" "${dest}"`;
}

=head2 size C<$src> 
  
  # Take a image size from `$src` file.
  #
  # This function uses `identify` command by internal,
  # and `identify` includes ImageMagick package.
  #
  # The support format is same as ImageMagick.

  my ( $width, $height ) = size $src;

=cut

sub size : prototype($) {
  my $path = shift;
  my $size = `identify '${path}' | head -n1 | cut -d' ' -f3`;
  chomp($size);

  my ( $width, $height ) = split qr/x/, $size;
  return ( int($width), int($height) );
}

=head2 resize C<$src>, C<$dest>, C<$size>
  
  # Resize `$src` image to `$size`, and file is emit to `$dest`.
  #
  # This function returns `$weight` and `$height` of resized image.
  my ( $width, $height ) = resize $src, $dest, $size; 

=cut

sub resize : prototype($$$) {
  my ( $src, $dest, $size ) = @_;

  my ( $width, undef ) = size($src);
  my @resize  = $width >= $size ? ( '-resize', $size, 0 ) : ();
  my @quality = qw(-q 100);
  my @cmd     = ( 'cwebp', @resize, @quality, $src, '-o', $dest );

  my $cmd = join q{ }, @cmd;

  my $height = `${cmd} 2>&1 | grep 'Dimension:' | cut -d' ' -f4`;
  chomp($height);

  return int($height);
}

=head2 should_update C<$src>, C<$dest>

  # Compare two file, and return boolean about `$dest` should update.
  my $bool = should_update($src, $dest)

=cut

sub should_update {
  my ( $src, $dest ) = @_;

  if ( !-e $dest ) {
    return 1;
  }

  return ( stat($src) )[9] > ( stat($dest) )[9];
}

=head2 worker \%job

  # job hash sturcture:
  my $job = {
    src   => '...', # The file path of src image.
    dest  => '...', # The path of file deployment.
    data  => '...', # The path of metadata about image.
    msg   => '...', # The string value for to making process message.

    # The sizes of image resize.
    sizes => [ $widthx1, $width2x, ... ],
  };

  # process $job by worker
  my $result = worker($job);

  # $result sturcture is same as $job
  $result = { ... };

=cut

sub worker {
  my $job = shift;

  my ( $src, $dest, $data, $sizes ) = @{$job}{qw( src dest data sizes )};
  my $meta = {};

  if ( $src =~ m|\.gif$| ) {
    for ( my $idx = 0 ; $idx < $sizes->@* ; $idx++ ) {
      copy( $src, $dest ) if should_update( $src, $dest, "@{[ $idx +1 ]}x" );
    }

    my ( $width, $height ) = size($src);

    $meta->{'1x'}  = { width => $width, height => $height };
    $meta->{'2x'}  = { width => $width, height => $height };
    $meta->{'gif'} = { width => $width, height => $height };
  }
  elsif ( $src =~ m<\.(?:jpg|png)$> ) {
    for ( my $idx = 0 ; $idx < $sizes->@* ; $idx++ ) {
      my $scale = $idx + 1;
      my $width = $sizes->[$idx];

      my $path = $dest;
      $path =~ s<\.[^.]+$><_${scale}x.webp>;
      Kalaclista::Path->new( path => $path )->parent->mkpath;

      my $height = 0;
      if ( should_update( $src, $path ) ) {
        $height = resize( $src, $path, $width );
      }
      else {
        ( undef, $height ) = size($path);
      }

      $meta->{"${scale}x"} = { width => $width, height => $height };
    }
  }

  my $file = Kalaclista::Path->new( path => $data );
  $file->parent->mkpath;
  $file->emit( Dump($meta) );

  return $job;
}

=head2 queues C<\@sizes>

  # make the list of $job
  my @jobs = queues([ $width1x, $width2x, ... ]);

  $job[0] = {
    src   => '...', # The file path of src image.
    dest  => '...', # The path of file deployment.
    data  => '...', # The path of metadata about image.
    msg   => '...', # The string value for to making process message.

    # The sizes of image resize.
    sizes => [ $widthx1, $width2x, ... ],
  };

=cut

sub queues {
  my $sizes = shift;

  my $srcdir  = srcdir->child('images')->path;
  my $destdir = distdir->child('images')->path;
  my $datadir = cachedir->child('images')->path;

  my @jobs = map {
    my $src = $_;

    my $dest = $src;
    $dest =~ s<$srcdir><$destdir>;

    my $data = $src;
    $data =~ s<$srcdir><$datadir>;
    $data =~ s<\.([^.]+)$><.yaml>;

    my $msg = $src;
    $msg =~ s<$srcdir><images>;

    return {
      src   => $src,
      dest  => $dest,
      data  => $data,
      msg   => $msg,
      sizes => $sizes,
    };
  } sort { $a cmp $b } files $srcdir;

  return @jobs;
}

=head1 AUTHOR

OKAMURA Naoki aka nyarla / kalaclista E<lt>nyarla@kalaclista.comE<gt>

=cut

1;
