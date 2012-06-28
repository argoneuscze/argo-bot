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