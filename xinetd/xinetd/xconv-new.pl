#!/usr/bin/perl -w

# $RCSid = "$Id: xconv-new.pl,v 1.1.1.3 2003/05/22 01:16:36 rbraun Exp $";

use strict;

print <DATA>;

while (<>) {
    next if /^#/ || /^$/;
    s/\s+$//;
    my ($service, $socket_type, $protocol, $wait, $user, $server,
	@server_args) = split;

    my ($cps, $id, $instances, $rpc_version, $type);

    $service =~ s#^tcpmux/\+?##;

    $protocol =~ s#^(tcp.*)/.*#$1#;
    if ($protocol =~ s#^rpc/##) {
	print STDERR "Warning: Service $service not added because\n";
	print STDERR "xinetd does not handle rpc services well\n";
	next;
	$type = "RPC";
	$rpc_version = $1 if $service =~ s#/(.*)##;
    }

    if ($wait =~ /\.(\d+)/) {			# [no]wait[.maxcpm]
	$cps = sprintf("%.f", $1/60);
    } elsif ($wait =~ m#/(\d+)(/(\d+))?#) {	# [no]wait[/maxchild[/maxcpm]]
	$instances = $1;
	$cps = sprintf("%.f", $3/60) if $3;
    }
    $wait =~ s/^wait.*/yes/;
    $wait =~ s/^nowait.*/no/;

    $user =~ s#/.*##;				# Strip /login-class
    my $group = $1 if $user =~ s/[.:](.*)//;	# user.group or user:group

    my $flags = "";
    if ($server =~ m#/tcpd$#) {
	$flags .= " NAMEINARGS NOLIBWRAP";
    } else {
	shift @server_args;
	if ($server eq "internal") {
	    $type   = "INTERNAL";
	    $id     = "$service-$socket_type";
	    $server = undef;
	}
    }

    print "service $service\n";
    print "{\n";
    print "\tflags       = $flags\n";
    print "\trpc_version = $rpc_version\n"	if $rpc_version;
    print "\tsocket_type = $socket_type\n";
    print "\tprotocol    = $protocol\n";
    print "\twait        = $wait\n";
    print "\tinstances   = $instances\n"	if $instances;
    print "\tcps         = $cps\n"		if $cps;
    print "\tuser        = $user\n";
    print "\tgroup       = $group\n"		if defined $group;
    print "\ttype        = $type\n"		if $type;
    print "\tid          = $id\n"		if $id;
    print "\tserver      = $server\n"		if $server;
    print "\tserver_args = @server_args\n"	if @server_args;
    print "}\n\n";
}

__DATA__
# This file generated by xconv.pl, included with the xinetd
# package.  xconv.pl was written by Rob Braun (bbraun@synack.net)
#
# The file is merely a translation of your inetd.conf file into
# the equivalent in xinetd.conf syntax.  xinetd has many
# features that may not be taken advantage of with this translation.
# Please refer to the xinetd.conf man page for more information
# on how to properly configure xinetd.


# The defaults section sets some information for all services
defaults
{
	#The maximum number of requests a particular service may handle
	# at once.
	instances   = 25

	# The type of logging.  This logs to a file that is specified.
	# Another option is: SYSLOG syslog_facility [syslog_level]
	log_type    = FILE /var/log/servicelog

	# What to log when the connection succeeds.
	# PID logs the pid of the server processing the request.
	# HOST logs the remote host's ip address.
	# USERID logs the remote user (using RFC 1413)
	# EXIT logs the exit status of the server.
	# DURATION logs the duration of the session.
	log_on_success = HOST PID

	# What to log when the connection fails.  Same options as above
	log_on_failure = HOST 

	# The maximum number of connections a specific IP address can
	# have to a specific service.
	per_source  = 5
}
