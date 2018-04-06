#!/usr/bin/perl
# 2013-05-30 - ssinn
# This script creates udev rules for ASM. start_udev will need to be run to
# enable these rules.

use strict;
use warnings;
use Data::Dumper;

use Getopt::Long

my $single;
my $input_file;
my $remove;


Getopt::Long::Configure ( 'auto_help', 'bundling' );
GetOptions (
  's|single=s'    => \$single,
  'i|input=s'     => \$input_file,
  'r|remove=s'    => \$remove,
  'v|verbose'     => \$verbose,
) or warn pod2usage(2);

    # Check for input file
    if ( $input_file ) {
      open (INPUT_FILE, $input_file) or die "Unable to open $input_file.\n";
      print "\n";
      main($input_file);
    } elsif ( $single ) {
      exit;
    } else {
      die ("Script requires file of new LUN WWNs, one WWN per line.\n");
    }
    
sub add_single {
  open (ASM_RULES, '+>>/etc/udev/rules.d/99-asm.rules')
    or die "Couldn't open file: $!";
  if ($count == 0) {
    print ASM_RULES qq[\n];
    print ASM_RULES qq[Entries added on: ],qx(/bin/date '+%F %T');
    print ASM_RULES qq[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n];
  }
  print ASM_RULES qq[ACTION=="add|change", ENV{DM_UUID}=="],$dm_uuid,qq[", SYMLINK+="asm/disks/$wwn", OWNER="oracle", GROUP="dba", MODE="0660"\n];

}   # End add_single

sub main {
    my $count = 0;
    # This is to see new LUNs
    if ($verbose) print "Running rescan-scsi-bus.sh to check/activate new LUNs\n\n";
    my $rescan = qx(/usr/bin/rescan-scsi-bus.sh);
    if ($verbose) print "$rescan\n";
   
    my $num; 
    my $wwn; 
    my @wwn_list;
    while(my $line = <INPUT_FILE>) {
        chomp $line;
        # only lines with a single WWN
        next unless ($line =~ m/^600\w+$/);
        
        # We'll use this later
        push @wwn_list, $line;
        
        $wwn = $line;
        my $node_name = query_multipath($wwn);
        
        # Skip wwn if it doesn't exist on box.
        if ( ! $node_name ) {
            next;
        }
        $num++;        
        
        my $hash = query_udev($node_name);
        my $dm_uuid = $hash->{DM_UUID};
        open (ASM_RULES, '+>>/etc/udev/rules.d/99-asm.rules');
        if ($count == 0) {
            print ASM_RULES qq[\n];
            print ASM_RULES qq[Entries added on: ],qx(/bin/date '+%F %T');
            print ASM_RULES qq[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n];
        }
        print ASM_RULES qq[ACTION=="add|change", ENV{DM_UUID}=="],$dm_uuid,qq[", SYMLINK+="asm/disks/$wwn", OWNER="oracle", GROUP="dba", MODE="0660"\n];
        #print qq[ACTION=="add|change", ENV{DM_UUID}=="],$dm_uuid,qq[", SYMLINK+="asm/disks/$wwn", OWNER="oracle", GROUP="dba", MODE="0660"\n];
        $count++;
    }
    close(ASM_RULES);
    close(INPUT_FILE);
    if ($num) { 
        if ($verbose) print "Running udevadm subsystems change command\n";
        my $subsys_trigger = qx(/sbin/udevadm trigger --type=subsystems --action=change);
        if ($verbose) print "$subsys_trigger\n";
        
        if ($verbose) print "Running udevadm devices change command\n";
        my $devices_trigger = qx(/sbin/udevadm trigger --type=devices --action=change);
        if ($verbose) print "$devices_trigger\n";

        sleep 10; 
        if ($verbose )print "The following entries were created in /dev/asm/disks:\n";
        foreach my $entry (@wwn_list) {
            my $wwn_listing = qx(/bin/ls -lL /dev/asm/disks/$entry);
            if ($verbose) print "$wwn_listing";
        }
    }
}

sub query_multipath {
    my ($wwn) = @_;
    my $output = `multipath -l | grep $wwn`;
    #print "Output for $wwn = $output";
    if (! $output) {
        warn ("WWN: $wwn not found. Please verify WWN.\n");
        return;
    }
    my ($node_name) = split(' ',$output);
    return $node_name;
}

sub query_udev {
    my ($node_name) = @_;
    my $output = `udevadm info --query=property --name=/dev/mapper/$node_name`;
    my %hash;
    for my $line (split(/\n/,$output)) {
        chomp $line;
        my ($key, $value) = split(/=/,$line,2);
        $hash{$key}=$value;
    }
    return \%hash;
}

main();

__END__

=pod

=head1
 This script creates udev rules for ASM. start_udev will need to be run to
 enable these rules.

=head2 AUTHOR

 2013-05-30 - ssinn

=over

=cut
=back

