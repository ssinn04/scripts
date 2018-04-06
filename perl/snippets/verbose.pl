# Creates a verbose switch which will print out messages that might be 
# useful.

use Getopt::Long;

my $verbose;

GetOptions (
  'v|verbose'    => \$verbose
);

if ($verbose) { print $some_value };

__END__
