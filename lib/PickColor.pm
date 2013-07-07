package PickColor;

use Dancer qw(:syntax);
use Dancer::FileUtils qw(dirname path);
use Image::Magick;

our $VERSION = '0.1';

sub to_thumb {
    my ( $file, $path, $width_new ) = @_;

    my $image  = Image::Magick->new;
    my $retval = $image->Read($file);

    my $height_new;
    if ( !$retval ) {
        my ( $width_old, $height_old ) = $image->Get( 'width', 'height' );
        $height_new = int( $width_new / ( $width_old / $height_old ) );
    }

    $retval = $image->Resize( width => $width_new, height => $height_new );
    $retval = $image->Write($path);

    return $height_new;
}

sub get_pixel {
    my ( $file, $x, $y ) = @_;

    my $image = Image::Magick->new;
    $image->Read($file);
    my @pixel = $image->GetPixel( x => $x, y => $y );

    return @pixel;
}

any [qw(get post)] => '/' => sub {
    my ( $width, $height );

    my $filename;
    if ( request->method eq 'POST' ) {
        my $upload = request->upload('image');

        if ($upload) {
            my $image     = $upload->filename();
            my $base_path = path( dirname(__FILE__), '../public/img' );
            my $full_path = path( $base_path, $image );
            $upload->copy_to($full_path);

            my ( $basename, $ext ) = $image =~ /^(.*)\.(.*)$/;
            $filename = $basename . '.thumb.' . $ext;
            my $thumb_path = path( $base_path, $filename );
            $width = 400;
            $height = to_thumb( $full_path, $thumb_path, $width );

            session file => $filename;
        }
    }

    template 'index',
        {
        image  => $filename,
        width  => $width,
        height => $height,
        };
};

any [qw(get post)] => '/preview' => sub {
    my ( %pixel, $color, $x, $y );

    my $filename;
    if ( request->method eq 'POST' ) {
        my $cursor = params->{'cursor'};
        ( $x, $y ) = $cursor =~ /(\d+), (\d+)/;
        my $base_path = path( dirname(__FILE__), '../public/img' );
        $filename = session('file');
        my $file = path( $base_path, $filename );
        my @pixel = get_pixel( $file, $x, $y );
        # FIXME
        $color = sprintf "#%02lx%02lx%02lx", @pixel;
        my @rgb = qw(红 绿 蓝);
        for my $index ( 1 .. 3 ) {
            $pixel{ $rgb[ $index - 1 ] } = $pixel[ $index - 1 ];
        }
    }

    template 'preview',
        {
        image => $filename,
        x     => $x,
        y     => $y,
        rgb   => \%pixel,
        color => $color,
        };
};

true;
