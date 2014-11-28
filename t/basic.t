use strict;
use Test::More;
use Dist::Stenciler;
use Path::Tiny;

my $parser = Dist::Stenciler->new(path => 'corpus/test-1.mach', to => 'DbicMachina::Tests');
my $expected = path('corpus/test-1.expected')->slurp;

is($parser->to_dbic_machina_test, $expected, 'Creates correct tests');

done_testing;
