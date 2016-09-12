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
		# As explained below, really not supposed to do this with
		# immutable objects, but necessary for demonstrating
		# the difference between the two roles.
		is => 'rw',
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

plan tests => 2;

subtest 'Plain CloneSet' => sub {
	plan tests => 3;

	my $first = Something->new(name => 'giant panda', color => 'black & white');
	test_something 'The original panda',
	    $first, 'giant panda', 'black & white';

	# We are really not supposed to do this with immutable objects,
	# but it's necessary for demonstrating the difference between
	# the two CloneSet roles.
	
	$first->name('another giant panda');
	test_something 'Another panda',
	    $first, 'another giant panda', 'black & white';

	my $second = $first->cset(color => 'see for yourself');
	test_something 'Yet another panda',
	    $second, 'another giant panda', 'see for yourself';
};

subtest 'CloneSet::BuildArgs' => sub {
	my $have_buildargs;
	eval {
		require MooX::BuildArgs;
		$have_buildargs = 1;
	};
	plan skip_all => 'MooX::BuildArgs not installed' unless $have_buildargs;

	plan tests => 3;

	package Something::Else {
		use v5.14;
		use strict;
		use warnings;

		use Moo;
		use namespace::clean;

		extends 'Something';
		with 'MooX::Role::CloneSet::BuildArgs';
	};

	my $first = Something::Else->new(name => 'giant panda', color => 'black & white');
	test_something 'The original panda',
	    $first, 'giant panda', 'black & white';

	# We are really not supposed to do this with immutable objects,
	# but it's necessary for demonstrating the difference between
	# the two CloneSet roles.
	
	$first->name('another giant panda');
	test_something 'Another panda',
	    $first, 'another giant panda', 'black & white';

	my $second = $first->cset(color => 'see for yourself');
	test_something 'Yet another panda',
	    $second, 'giant panda', 'see for yourself';
};
