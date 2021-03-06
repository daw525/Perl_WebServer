#!/usr/bin/perl
use strict;
use warnings;
use IO::Socket;
my $PORT = 80;
my $server = IO::Socket::INET->new (	Proto 		=> 'tcp',
										LocalPort 	=> $PORT,
										Listen		=> SOMAXCONN,
										Reuse		=> 1);

die "Failed to create server" unless $server;

print "Server running...\n";

while (my $client = $server->accept()) {
	print "Client connected...\n";
	my $request="";
	$client->autoflush(1);
	while( <$client> ) {
		$request = $request.$_;
		last if (/^\r\n/);
	}
	if ($request=~/^GET/) {
		print "Processing HTTP GET...\n";
		my @p=$request=~(/GET (.*?) HTTP/);
		if ($p[0]=~/\/$/) {$p[0]=$p[0]."index.html";}
		$p[0]=".".$p[0];		
		print "Client requested page: ".$p[0]."\n";
		if (-e $p[0]) {
			# Page exists
			print "Serving requested page...\n";
			open (FILE1, $p[0]) || die "Can't open html file";
			my $page="";
			while (<FILE1>) {
				$page=$page.$_;
			}
			close FILE1;
			print $client "HTTP/1.0 200 OK\r\n";
			if ($p[0]=~(/css$/)) { 
				print $client "Content-Type: text/css; charset=utf-8\r\n";				
			} else {
				print $client "Content-Type: text/html; charset=utf-8\r\n";
			}
			printf $client "Content-Length: %d\r\n",length($page);
			print $client "\r\n";
			print $client $page;
		} else {
			# Page not found
			print "Serving 404 error..\n";
			print $client "HTTP/1.0 404 Not Found\r\n";	
			print $client "Content-Type: text/html; charset=utf-8\r\n";
			print $client "Content-Length: 3\r\n";
			print $client "\r\n";
			print $client "404";
		}
	} else {
		print "Request received was not HTTP GET...\n";
	}
	print "Client socket closed.\n";
	print "Waiting for next client...\n";
	close $client;	
}
