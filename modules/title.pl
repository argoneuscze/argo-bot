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