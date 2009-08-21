use Test::More; {

	use strict;
	use warnings;

	require_ok 'Test::DBIx::Class';
	use_ok 'Test::DBIx::Class::Types';
	use_ok 'Test::DBIx::Class::Schema';
	use_ok 'Test::DBIx::Class::Example::Schema';
	use_ok 'Test::DBIx::Class::Example::Schema::Result';
	use_ok 'Test::DBIx::Class::Example::Schema::ResultSet';
	use_ok 'Test::DBIx::Class::Example::Schema::DefaultRS';
	use_ok 'Test::DBIx::Class::FixtureCommand::Populate';
	use_ok 'Test::DBIx::Class::FixtureCommand::PopulateMore';
	

	done_testing();
}
