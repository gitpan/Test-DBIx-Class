package Test::DBIx::Class::SchemaManager::Trait::Testmysqld; {
	
	use Moose::Role;
	use Test::mysqld;
	use Test::More ();

	has '+force_drop_table' => (default=>1);

	has mysqldobj => (
		is=>'ro',
		init_arg=>undef,
		lazy_build=>1,
	);

	has [qw/base_dir mysql_install_db mysqld/] => (is=>'ro', isa=>'Str');
	has my_cnf => (is=>'ro', isa=>'HashRef', auto_deref=>1);

	sub _build_mysqldobj {
		my ($self) = @_;
		if($self->keep_db) {
			$ENV{TEST_MYSQLD_PRESERVE} = 1;
		}

		my %config = (
			my_cnf=>{'skip-networking'=>''},
			$self->my_cnf,
		);

		$config{base_dir} = $self->base_dir if $self->base_dir;	
		$config{mysql_install_db} = $self->mysql_install_db if $self->mysql_install_db;	
		$config{mysqld} = $self->mysqld if $self->mysqld;	
	
		return  Test::mysqld->new(%config);
	}

	sub get_default_connect_info {
		my ($self) = @_;
		my $base_dir = $self->mysqldobj->base_dir;

		Test::More::diag(
			"Starting mysqld with: ".
			$self->mysqldobj->mysqld.
			" --defaults-file=".$self->mysqldobj->base_dir . '/etc/my.cnf'.
			" --user=root"
		);

		Test::More::diag("DBI->connect('DBI:mysql:test;mysql_socket=$base_dir/tmp/mysql.sock','root','')");
		return ["DBI:mysql:test;mysql_socket=$base_dir/tmp/mysql.sock",'root',''];
	}

} 1;

__END__

=head1 NAME

Test::DBIx::Class::SchemaManager::Trait::Testmysqld - deploy to a test mysql instance

=head1 DESCRIPTION

This trait uses L<Test::mysqld> to auto create a test instance of mysql in a
temporary area.  This way you can test against mysql without having to create
a test database, users, etc.  Mysql needs to be installed (but doesn't need to
be running) as well as L<DBD::mysql>.  You need to install these yourself.

Please review L<Test::mysqld> for help if you get stuck.


=head1 CONFIGURATION

This trait supports all the existing features but adds some additional options
you can put into your inlined of configuration files.  These following 
additional configuration options basically map to the options supported by 
L<Test::mysqld> and the docs are adapted shamelessly from that module.

For the most part, if you have mysql installed in a normal, findable manner
you should be able to leave all these options blank.

=head2 base_dir

Returns directory under which the mysqld instance is being created. If you leave
this unset we automatically create a place in the temporary directory and then
clean it up later.  Unless you plan to roundtrip to the same database a lot
you can just leave this blank.

=head2 my_cnf

A hashref containing the list of name=value pairs to be written into "my.cnf",
which is the primary configuration file for the mysql instance.  Again, unless
you have some specific needs you can leave this empty, since we set the few
things most needed to get a server running.

=head2 mysql_install_db or mysqld

If your mysqld is not in the $PATH you might need to specify the location to
one of there binaries.  If you have a normal mysql setup this should not be
a problem and you can leave this blank.

=head1 NOTES

The following are notes regarding the way this trait alters or extends the 
core functionality as described in the basic documentation.

=head2 force_drop_table

Since it is always safe to use the 'force_drop_table' option with mysql, we set
the default to true.  We recommend you leave it this way, particularly if you
want to 'roundtrip' the same test database. 

=head2 keep_db

If you use the 'keep_db' option, this will preserve the temporarily created
database files, however it will not prevent L<Test::mysqld> from stopping the
database when you are finished.  This is a safety measure, since if we didn't
stop a test generated database instance automatically, you could easily end up
with many databases running at once, and that could bring your server or testing
box to a halt.

If you use the 'keep_db' option and want to start and log into the test generated
database instance, you can start the database by noticing the diagnostic output
that should be generated at the top of your test.  It will look similar to:

	# Starting mysqld with: /usr/local/mysql/bin/mysqld --defaults-file=/tmp/KHKfJf0Yf6/etc/my.cnf --user=root

You can then start the database instance yourself with something like:

	/usr/local/mysql/bin/mysqld --defaults-file=/tmp/WT0P0VutAe/etc/my.cnf \
	--user=root &
	[1] 3447
	....
	090827 15:06:16  InnoDB: Started; log sequence number 0 78863
	090827 15:06:16 [Note] Event Scheduler: Loaded 0 events
	090827 15:06:16 [Note] /usr/local/mysql/bin/mysqld: ready for connections.
	Version: '5.1.37'  socket: '/tmp/WT0P0VutAe/tmp/mysql.sock'  port: 0  MySQL Community Server (GPL)

There will be some additional output to the term and then the server will go
into the background.  If you don't like the extra output, you can just redirect
it all to /dev/null or whatever is similar for your OS.

You can now log into the test generated database instance with:

	mysql --socket=/tmp/WT0P0VutAe/tmp/mysql.sock -u root test

You may need to specify the full path to 'mysql' if it's not in your search 
$PATH.

When you are finished you can then kill the process.  In this case our reported
process id is '3447'

	kill 3447

And then you might wish to 'tidy' up temp

	rm -rf /tmp/WT0P0VutAe

All the above assume you are on a unix or unixlike system.  Would welcome 
document patches for how to do all the above on windows.

=head1 AUTHOR

John Napiorkowski C<< <jjnapiork@cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009, John Napiorkowski C<< <jjnapiork@cpan.org> >>

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
