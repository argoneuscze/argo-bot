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

use Safe;

sub perl
{
	my ($code, $sender) = @_;
	my $printBuffer;
	my $timedOut = 0;
	open (my $buffer, '>', \$printBuffer);
	my $stdout = select($buffer);
	my $cpmt = new Safe;
	$cpmt->permit_only(qw(:default :base_io));
	eval
	{
		local $SIG{ALRM} = sub { $timedOut = 1; die "alarm\n" };
		alarm 5;
		$cpmt->reval($code);
		alarm 0;
	};
	select($stdout);
	my $result;
	($timedOut) ? ($result = "Expression timed out.") : ($result = $printBuffer);
	return ("$sender: $result") if defined $result;
}

1;
