# =========
# COPYRIGHT
# =========

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Copyright 2012 Tomas Drbota, contact at argoneuscze@gmail.com
# For more information see README

# ========
# INCLUDES
# ========

#! /usr/bin/perl

use warnings;
use strict;

use POE;
use POE::Component::IRC;

use URI::Escape;

use LWP::UserAgent;

# ===================
# HELPING SUBROUTINES
# ===================

# load config file and store valid values in a hash
# valid value is in format 'option=value' (with lots of tolerance)
sub loadConfig
{
	my ($config) = $_[0];
	open my $inputFile, "<", $config
		or die "Can't open '$config' - $!";
	
	my %configHash;
		
	while (<$inputFile>)
	{
		next if /^#/;
		chomp;
		if (/^\s*([^=]*?)\s*=\s*([^=]*?)\s*$/)
		{
			$configHash{$1} = $2;
		}
	}
	
	return %configHash;
}

# ==============
# CONFIG LOADING
# ==============

# set default config file
my $config_file = "argo-bot.cfg";

# let user set alternative config file
if (@ARGV == 2)
{
	if($ARGV[0] eq "-config" && @ARGV == 2) { $config_file = $ARGV[1]; }
}

# load the config
my %config = loadConfig($config_file);

# ========
# BOT CODE
# ========

# spawn IRC component
my $irc = POE::Component::IRC->spawn();

# create a new POE session
POE::Session->create
(
	inline_states => 
		{
			_start     => \&botStart,
			irc_001    => \&onConnect,
			irc_public => \&onMessage,
			bot_timer  => \&botTimer,
		}
);

# _start
# called to initialize and connect the bot
sub botStart
{
	$_[KERNEL]->delay(bot_timer => 1);
	
	$irc->yield(register => "all");
	$irc->yield
	(
		connect =>
			{
				Server   => $config{'server'},
				Port     => $config{'port'},
				Nick     => $config{'nickname'},
				Username => $config{'nickname'},
				Ircname  => $config{'realname'},
			}
	);
	print "Connecting to $config{'server'}:$config{'port'}...\n";
}

# _onConnect
# called after bot connects
sub onConnect
{
	print "Connected. Joining channel $config{'channel'}...\n";
	$irc->yield(join => $config{'channel'});
	$irc->yield(privmsg => $config{'channel'} => "Hello, everyone! Now that I am here, the fun may begin!");
}

# _onMessage
# called everytime a user sends a message into the channel
sub onMessage
{
	my ($sender, $channel, $message, $registered) = @_[ARG0,ARG1,ARG2,ARG3];
	$sender =~ s/!.*//;
	
	my @msg;
	
	if ($message =~ m/^$config{'delimiter'}.*/)
	{
		foreach ($message)
		{
			# google command
			if (/^.google\s(\S.*)$/)
			{
				push @msg, "http://google.com/search?q=" . uri_escape($1);
			}
			
			# version command
			elsif (/^.version$/)
			{
				my $version = "argo-bot [in development], https://github.com/argoneuscze/argo-bot";
				push @msg, $version;
			}
		}
	}
	
	# check for URLs
	if ($message =~ m!https?://\S+!)
	{
		my @strlist = split(/\s+/, $message);		
		foreach (@strlist)
		{
			if (m!^https?://\S+!)
			{
				my $ua = LWP::UserAgent->new();
				$ua->timeout(5);
				$ua->env_proxy;
				$ua->agent('Mozilla/5.0');
				push @msg, $ua->get($_)->title if $ua->get($_)->is_success;
			}
		}
	}
	
	if (@msg > 0)
	{
			push @{$_[HEAP]->{'msg_queue'}}, @msg;
	} 
}

# bot_timer subroutine
# prints the first 6 messsages in the queue with a 1 second delay
sub botTimer
{
	if (defined $_[HEAP]->{'msg_queue'})
	{
		splice (@{$_[HEAP]->{'msg_queue'}}, 6) if @{$_[HEAP]->{'msg_queue'}} > 6;
		$irc->yield(privmsg => $config{'channel'} => shift $_[HEAP]->{'msg_queue'})
			unless @{$_[HEAP]->{'msg_queue'}} == 0;
	}
	$_[KERNEL]->delay(bot_timer => 1);
}

# run bot until done
$poe_kernel->run();

exit 0;