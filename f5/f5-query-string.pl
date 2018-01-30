#!/usr/bin/perl
#----------------------------------------------------------------------------
# The contents of this file are subject to the iControl Public License
# Version 4.5 (the "License"); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
# http://www.f5.com/.
#
# Software distributed under the License is distributed on an "AS IS"
# basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
# the License for the specific language governing rights and limitations
# under the License.
#
# The Original Code is iControl Code and related documentation
# distributed by F5.
#
# The Initial Developer of the Original Code is F5 Networks,
# Inc. Seattle, WA, USA. Portions created by F5 are Copyright (C) 1996-2003 F5 Networks,
# Inc. All Rights Reserved.  iControl (TM) is a registered trademark of F5 Networks, Inc.
#
# Alternatively, the contents of this file may be used under the terms
# of the GNU General Public License (the "GPL"), in which case the
# provisions of GPL are applicable instead of those above.  If you wish
# to allow use of your version of this file only under the terms of the
# GPL and not to allow others to use your version of this file under the
# License, indicate your decision by deleting the provisions above and
# replace them with the notice and other provisions required by the GPL.
# If you do not delete the provisions above, a recipient may use your
# version of this file under either the License or the GPL.
#----------------------------------------------------------------------------

#use SOAP::Lite + trace => qw(method debug);
use SOAP::Lite;

#----------------------------------------------------------------------------
# Validate Arguments
#----------------------------------------------------------------------------
my $sHost = $ARGV[0];
my $sPort = $ARGV[1];
my $sUID = $ARGV[2];
my $sPWD = $ARGV[3];
my $sClass = $ARGV[4];
my $sString = $ARGV[5];
my $sProtocol = "https";

sub usage()
{
  die ("Usage: stringClass.pl host port uid pwd [classname] [string] \n");
}

if ( ($sHost eq "") or ($sPort eq "") or ($sUID eq "") or ($sPWD eq "") )
{
  usage();
}

if ( ("80" eq $sPort) or ("8080" eq $sPort) )
{
  $sProtocol = "http";
}

#----------------------------------------------------------------------------
# Transport Information
#----------------------------------------------------------------------------
sub SOAP::Transport::HTTP::Client::get_basic_credentials-->
{
  return "$sUID" => "$sPWD";
}

#----------------------------------------------------------------------------
# support for custom enum types
#----------------------------------------------------------------------------
sub SOAP::Deserializer::typecast-->
{
  my ($self, $value, $name, $attrs, $children, $type) = @_;
  my $retval = undef;
  if ( "{urn:iControl}Class.ClassType" == $type )
  {
    $retval = $value;
  }
  return $retval;
}


$Class = SOAP::Lite
  -> uri('urn<!--:iControl:LocalLB/Class')-->
  -> readable(1)
  -> proxy("$sProtocol://$sHost:$sPort/iControl/iControlPortal.cgi");

#----------------------------------------------------------------------------
# Main program logic
#----------------------------------------------------------------------------
if ( "" eq $sClass )
{
  &listClasses();
}
elsif ( "" eq $sString )
{
  &listStrings($sClass);
}
else
{
  &modifyClass($sClass, $sString);
}

#----------------------------------------------------------------------------
# sub listClasses
#----------------------------------------------------------------------------
sub listClasses()
{
  $soapResponse = $Class->get_string_class_list();
  &checkResponse($soapResponse);
  @ClassList = @{$soapResponse->result};
  foreach $ClassName (@ClassList)
  {
    print "Class Name: $ClassName\n";
  }
}

#----------------------------------------------------------------------------
# sub listStrings
#----------------------------------------------------------------------------
sub listStrings()
{
  ($class) = (@_);
  $soapResponse = $Class->get_string_class
  (
    SOAP::Data->name(class_names => [$class])
  );
  &checkResponse($soapResponse);
  @StringClassList = @{$soapResponse->result};
  foreach $StringClass (@StringClassList)
  {
    $name = $StringClass->{"name"};
    print "Name : $name\n";
    @members = @{$StringClass->{"members"}};
    foreach $member (@members)
    {
      print "     : $member\n";
    }
  }
}

#----------------------------------------------------------------------------
# sub modifyClass
#----------------------------------------------------------------------------
sub modifyClass()
{
  my ($class, $string) = (@_);
  @values = split(/,/, $string);

  $StringClass =
  {
    name => $class, 
    members => [@values]
  };
  
  $soapResponse = $Class->modify_string_class
  (
    SOAP::Data->name(classes => [$StringClass])
  );
  &checkResponse($soapResponse);
}

#----------------------------------------------------------------------------
# checkResponse makes sure the error isn't a SOAP error
#----------------------------------------------------------------------------
sub checkResponse()
{
  my ($soapResponse) = (@_);
  if ( $soapResponse->fault )
  {
    print $soapResponse->faultcode, " ", $soapResponse->faultstring, "\n";
    exit();
  }
}
