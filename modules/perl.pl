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