#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Code::Image' );
}

diag( "Testing Code::Image $Code::Image::VERSION, Perl $], $^X" );
