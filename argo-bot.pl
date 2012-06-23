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
		}
);

# _start
# called to initialize and connect the bot
sub botStart
{
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
	$irc->yield(privmsg => $config{'channel'} => "Shut up $sender.");
}

# run bot until done
$poe_kernel->run();
exit 0;