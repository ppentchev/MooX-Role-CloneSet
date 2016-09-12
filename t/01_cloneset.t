use v5.12;
use strict;
use warnings;

use Scalar::Util qw(blessed);

use Test::More 0.98;

package Something
{
	use v5.14;
	use strict;
	use warnings;

	use Moo;
	use namespace::clean;

	with 'MooX::Role::CloneSet';

	has name => (
		is => 'ro',
	);

	has color => (
		is => 'ro',
	);
}

sub test_something($ $ $ $)
{
	my ($test, $thing, $name, $color) = @_;

	subtest "$test" => sub {
		plan tests => 3;

		my $fine = defined($thing) &&
		    defined blessed($thing) &&
		    $thing->isa('Something');

		ok $fine, "we have something";
		SKIP:
		{
			skip 'cannot test the attributes of nothing', 2 unless $fine;

			is $thing->name, $name, "the right name";
			is $thing->color, $color, "the right color";
		}
	}
}

plan tests => 4;

my $first = Something->new(name => 'giant panda', color => 'black & white');
test_something 'The original panda',
    $first, 'giant panda', 'black & white';

my $intermediate = $first->cset(color => 'reddish-brown');
test_something 'A weird animal with an identity crisis',
    $intermediate, 'giant panda', 'reddish-brown';

my $final = $intermediate->cset(name => 'red panda');
test_something 'The cute and cuddly fox-like thing',
    $final, 'red panda', 'reddish-brown';

my $else = $intermediate->cset(name => 'mimic octopus', color => 'whatever you like');
test_something 'And now for something completely different',
    $else, 'mimic octopus', 'whatever you like';
