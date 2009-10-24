package Code::Image;

use GD;
use Syntax::Highlight::Engine::Kate::Perl;
use Moose;
use File::Spec;

=head1 NAME

Code::Image - generate image with syntaxhighlighted code

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';


=head1 SYNOPSIS

    use Code::Image;
    
    my $foo = Code::Image->new;
    
    $foo->colormap(
        Alert   => [0,0,0,1],   # black and bold
        BaseN   => [0,0,0,0],   # black and plain
        BString => [255,0,0,0], # red and bold
        Char    => [255,0,0,0], # red and bold
    );
    
    $foo->height( 200 );
    $foo->width( 400 );
    # or 
    $foo->geometry( '400x200' );
    
    $foo->image( $string );
    # or
    $foo->image(
        code   => $string,
        output => $outputdir,
        height => $height,
        width  => $width,
    );

=head1 ATTRIBUTES

=cut

has width => (
    is      => 'rw',
    isa     => 'Int',
    default => 500,
);

has height => (
    is      => 'rw',
    isa     => 'Int',
    default => 500,
);

has output => (
    is      => 'rw',
    isa     => 'Str',
    default => '.',
);

has file => (
    is      => 'rw',
    isa     => 'Str',
    default => 'code_image',
);

=head1 METHODS

=cut

=head2 image

=cut

sub image {
    my $self = shift;
    
    my %params = (
        output => $self->output,
        height => $self->height,
        width  => $self->width,
    );
    
    if( @_ == 2 ) {
        %params = @_;
    }
    else {
        $params{code} = shift;
    }
    
    my $gd = GD::Image->new( $params{width}, $params{height} );
    $gd->colorAllocate(255,255,255);
    
    $self->_highlightText( $gd, $params{code} );
    
    my $path = File::Spec->catfile( $self->output, $self->file . '.png' );
    
    if( open my $ofh, '>', $path ){
        binmode $ofh;
        print {$ofh} $gd->png;
        close $ofh;
        return $path;
    }
    
    return;
}

sub geometry {
    my ( $self, $geo ) = @_;
    my ($width,$height) = split 'x', $geo;
    
    $self->width( $width );
    $self->height( $height );
    
    return $self->width . 'x' . $self->height;
}

sub _color {
    my ( $self, $key, $values ) = @_;
    
    if( @_ == 3 ) {
        $self->{$key} = $values;
    }

    $self->{$key};
}

sub _get_color {
    my ($self, $image, $key) = @_;
    
    return unless $key;
    
    my $values = $self->_color( $key );
    my @rgb    = @{$values}[0..2];
    
    my $color  = $image->colorAllocate( @rgb );
    return [ $color, $values->[3] ];
}

sub _highlightText {
    my ( $self, $image, $text ) = @_;
    
    my @format_keys = qw(
        Alert BaseN BString Char Comment DataType DecVal Error Float Function Warning
        IString Keyword Normal Operator Others RegionMarker Reserved String Variable
    );
    
    $self->_init_colors;
    
    my %format_table = map{ $_, $self->_get_color( $image, $_ ) }@format_keys;
    
    my $hl = Syntax::Highlight::Engine::Kate::Perl->new(
        format_table => \%format_table,
    );
    
    my $res = '';
    my @hl = $hl->highlight($text);
    
    my $x = 20;
    my $y = 30;
    
    while (@hl) {
        my $f = shift @hl;
        my $t = shift @hl;
        unless (defined($t)) { $t = 'Normal' }
        my $s = $hl->substitutions;
        my $rr = '';
        
        while ($f ne '') {
            my $k = substr($f , 0, 1);
            $f = substr($f, 1, length($f) -1);
            if (exists $s->{$k}) {
                 $rr = $rr . $s->{$k}
            } else {
                $rr = $rr . $k;
            }
        }

        my $rt = $hl->formatTable;
        
        if (exists $rt->{$t}) {
            my $o = $rt->{$t};
            
            if( $rr =~ /\n/ ) {
                $y += 15;
                $x  = 20;
                $rr =~ s/\r?\n//g;
            }

            my $font  = $o->[1] ? gdMediumBoldFont : gdSmallFont;
            my $width = $o->[1] ? 7 : 6;
            $image->string($font, $x, $y, $rr, $o->[0]);
            $x += length( $rr ) * $width;
        } else {
            $res = $res . $rr;
        }
    }
    return $res;
}

sub _init_colors {
    my ($self) = @_;
    
    my %map = (
        Alert        => [0,0,0,1],
        BaseN        => [0,0,0,0],
        BString      => [255,0,0, 0],
        Char         => [255,0,0, 0],
        Comment      => [199,199,199, 0],
        DataType     => [255,0,0, 1],
        DecVal       => [255,119,0, 1],
        Error        => [255,0,0, 1],
        Float        => [255,119,0, 1],
        Function     => [100,100,100, 1],
        IString      => [255,0,0, 0],
        Keyword      => [0,0,255, 1],
        Normal       => [0,0,0, 0],
        Operator     => [0,0,255, 0],
        Others       => [0,0,0, 0],
        RegionMarker => [0,0,0, 0],
        Reserved     => [0,0,255, 0],
        String       => [255,0,0, 0],
        Variable     => [255,0,0, 1],
        Warning      => [255,119,0, 0],
    );
    
    $self->_color( $_, $map{$_} ) for keys %map;
}

=head1 PREDEFINED COLORS

This module predefines some colors you can use for syntaxhighlighting:

=over 4

=item * black

=item * grey

=item * lightgrey

=back

=head1 NOTES

Currently this module only support Perl highlighting.

=head1 AUTHOR

Renee Baecker, C<< <module at renee-baecker.de> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-code::image at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Code::Image>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Code::Image

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Code::Image>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Code-Image>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Code-Image>

=item * Search CPAN

L<http://search.cpan.org/dist/Code-Image/>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2009 Renee Baecker, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of Code::Image
