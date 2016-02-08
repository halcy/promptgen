#!/usr/bin/perl

use warnings;
use strict;

use CGI;
my $password = "";

if($password eq "") {
	die("Change password in edit.pl and retry");
}

print "Content-type: text/html\n\n";
print "<html><head><title>Edit prompts</title></head><body>";

my $prompts_file = "prompts.txt";
open my $handle, '<', $prompts_file;
chomp(my @prompts = <$handle>);
map {$_ =~ s/^\s+|\s+$//g} @prompts;
close $handle;

my $query = new CGI;
if(defined $query->param('password') && defined $query->param('prompts')) {
	@prompts = split("\n", $query->param('prompts'));
	if($query->param('password') eq $password) {
		open my $outhandle, '>>', $prompts_file . ".tmp";
		for my $prompt(@prompts) {
			print $outhandle "$prompt\n";
		}
		close $outhandle;
		my $mvcmd = 'mv ' . $prompts_file . '.tmp ' . $prompts_file;
		my $permscmd = 'chmod a+rw ' . $prompts_file;
		my $gitcmd = 'git add $prompts_file; git commit -m "Prompts edited by IP ' . $query->remote_host() . '" 2>&1';
		print "<h1>Changes saved!</h1><hr>";
		`$mvcmd`;
		`$permscmd`;
		my $output = `$gitcmd`;
		print '<pre>' . $gitcmd . "\n" . $output . '</pre><hr>';
	}
	else {
		print "<h1>Wrong password! Please try again</h1><hr>";
	}
}

print "<h1>Edit prompts</h1>\n";
print "<form action=\"edit.pl\" method=\"post\">";
print "<p>";
print "<textarea name=\"prompts\" rows=\"30\" cols=\"100\">";

print join("\n", @prompts);

print "</textarea>";
print "</p><p>";
print "Password: <input type=\"text\" name=\"password\"></input>";
print "<input type=\"submit\" value=\"Save\"></input>";
print "</p>";
print "</form>";
print "</body></html>";
