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

use URI::Escape;
use LWP::UserAgent;

sub title
{
	if (m!^https?://\S+!)
	{
		my $ua = LWP::UserAgent->new();
		$ua->timeout(5);
		$ua->env_proxy;
		$ua->agent('Mozilla/5.0');
		return $ua->get($_)->title if $ua->get($_)->is_success;
	}
}

1;
