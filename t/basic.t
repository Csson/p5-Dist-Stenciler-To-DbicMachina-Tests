use strict;
use Test::More;
use Dist::Stenciler;
#use Dist::Stenciler::To::DbicMachinaTest;

my $parser = Dist::Stenciler->new(path => 'corpus/test-1.mach', to => ['DbicMachinaTest']);

is(expected(), $parser->to_dbic_machina_test, 'Creates correct tests');

done_testing;

sub expected {
    return q{};
}
