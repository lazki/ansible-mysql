#!/usr/bin/perl

#
# This script generates ansible test config for Vagrant
#

use strict;
use warnings;
use Socket;

my @a = (
    "jessie-default-mysql-master",
    "jessie-default-mysql-slave",
    "jessie-upstream-mariadb-master",
    "jessie-upstream-mariadb-slave",
    "jessie-upstream-percona-master",
    "jessie-upstream-percona-slave",
    "jessie-default-mariadb-master",
    "jessie-default-mariadb-slave",
    "jessie-upstream-mariadbgalera-1",
    "jessie-upstream-mariadbgalera-2",
    "jessie-upstream-mariadbgalera-3"
);

my $start_ip = '192.168.200.10';
my $iip = ip2long($start_ip);

my @galera = ();

foreach my $n (@a)
{
	my @data = split(/-/, $n);
	printf(
		'["%s", "debian/%s64", "%s", [%s]],' . "\n",
		$n,
		$data[0],
		long2ip($iip),
		join(',', map { sprintf('"%s"', $_) } @data)
	);

	if($data[-1] eq 'slave')
	{
		open(FILE, '>', "host_vars/$n");
		printf FILE (qq/his_master: '%s'\n/, long2ip($iip));
		close(FILE);
	}

#	if($data[-1] =~ /^\d$/ && $data[-2] eq 'mariadbgalera')
#	{
#		open(FILE, '>', "host_vars/$n");
#		printf FILE (qq/galera_id: '%s'\n/, $data[-1]);
#		close(FILE);
#	}

	if($data[-2] eq 'mariadbgalera')
	{
		push(@galera, long2ip($iip));
		goto SKIP;
	}

	open(FILE, '>', "group_vars/" . $data[2]);
	printf FILE (qq/mysql_vendor: '%s'\n/, $data[2]);
	close(FILE);

	SKIP:
	$iip++;
}

open(FILE, '>', 'group_vars/mariadbgalera');
say FILE qq/mysql_vendor: 'mariadb_galera'/;
say FILE qq/mariadb_galera_members:/;
foreach(@galera)
{
	say FILE qq/  - '$_'/;
}
close(FILE);

sub ip2long {
	return unpack("l*", pack("l*", unpack("N*", inet_aton(shift))));
}

sub long2ip {
	return inet_ntoa(pack("N*", shift));
}
