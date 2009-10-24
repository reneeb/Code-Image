#!perl -T

use Test::More tests => 1;
use Code::Image;
use File::Basename;

my $code_image = Code::Image->new();
my $code       = do{ local (@ARGV, $/) = __FILE__; <> };
my $dir        = dirname( __FILE__ );

my $file       = $code_image->image( $code );
diag $file;

ok( -e $file );