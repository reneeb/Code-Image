#!perl -T

use Test::More tests => 1;
use Code::Image;

my @methods = qw(height width image colormap output geometry file);

can_ok( 'Code::Image', @methods );
