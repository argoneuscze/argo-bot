# =======
# LICENSE
# =======

# Copyright 2012 Tomas Drbota

# This file is part of argo-bot.

# argo-bot is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# argo-bot is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with argo-bot.  If not, see <http://www.gnu.org/licenses/>.

sub config
{
	my ($config) = @_;
	open my $inputFile, "<", $config
		or die "Can't open '$config' - $!";
	
	my %configHash;		
	while (<$inputFile>)
	{
		next if /^#/;
		chomp;
		if (/^\s*([^=]*?)\s*=\s*([^=]*?)\s*$/) { $configHash{$1} = $2; }
	}	
	return %configHash;
}

1;
