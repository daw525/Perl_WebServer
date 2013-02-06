#!/usr/bin/perl

use strict;
use warnings;
use IO::Socket;

my $page = "";
my $PORT = 80;

my $server = IO::Socket::INET->new (	Proto 		=> 'tcp',
										LocalPort 	=> $PORT,
										Listen		=> SOMAXCONN,
										Reuse		=> 1);
die "Failed to create server" unless $server;

while (my $client = $server->accept()) {
	my $string="";
	$client->autoflush(1);
	while( <$client> ) {
		$string = $string.$_;
		last if (/^\r\n/);
	}
	if ($string=~/^GET/) {
		my @p=$string=~(/GET \/(.*?) HTTP/);
		if ($p[0] eq "") {$p[0]="index.html";}
		if (-e $p[0]) {
			open (FILE1, $p[0]) || die "Can't open html";
			$page="";
			while (<FILE1>) {
				$page=$page.$_;
			}
			close FILE1;
			print $client "HTTP/1.0 200 OK\r\n";
			print $client "Content-Type: text/html; charset=utf-8\r\n";
			printf $client "Content-Length: %d\r\n",length($page);
			print $client "\r\n";
			print $client $page;
		} else {
			print $client "HTTP/1.0 404 Not Found\r\n";	
			print $client "Content-Type: text/html; charset=utf-8\r\n";
			print $client "Content-Length: 3\r\n";
			print $client "\r\n";
			print $client "404";
		}
	} else {
	}
	close $client;
}