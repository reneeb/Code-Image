use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Code::Image',
    AUTHOR              => 'Renee Baecker <module@renee-baecker.de>',
    VERSION_FROM        => 'lib/Code/Image.pm',
    ABSTRACT_FROM       => 'lib/Code/Image.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'                            => 0,
        'GD'                                    => 1,
        'Syntax::Highlight::Engine::Kate::Perl' => 0.03,
        'File::Spec'                            => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Code::Image-*' },
);
