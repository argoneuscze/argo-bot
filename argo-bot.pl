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
# valid value is in format 'option = value'
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

