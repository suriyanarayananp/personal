use strict;
use gwinnett;
use Totalview;
use forsyth;
use Homesnap;
use Win32::OLE qw(in with in);
use Win32::OLE::Const;
use Win32::OLE::Variant;
use Win32::OLE::NLS qw(:LOCALE :DATE);
$Win32::OLE::Warn = 3; 

$SIG{__DIE__} = \&die_handler;

my $dir = `cd`;
$dir =~ s/\s*$//igs;

my $inputfile = $ARGV[0];

my $Excel = Win32::OLE->GetActiveObject('Excel.Application')
    || Win32::OLE->new('Excel.Application', 'Quit');  

$Excel->{'Visible'} = 0;
$Excel->{DisplayAlerts} = 0;
my $ABook = $Excel->Workbooks->Open("$dir\\$inputfile"); 

my @sheets = in $Excel->Worksheets;
my $sheets = $ABook->Worksheets->Count;
my %hashkey;
my $row =0;
my @input_array=();
foreach my $sheet (1)
{
	my $eSheet = $ABook->Worksheets($sheet);
	my $rowcount = $eSheet->UsedRange->Rows->{'Count'}; 
	print "rowcount :: $rowcount\n";
	my $colcount = $eSheet->UsedRange->Columns->{'Count'}; 
	print "colcount :: $colcount\n";
	foreach my $row (2 .. $rowcount)
	{
		my $line;
		foreach my $col (1 .. $colcount)
		{
			my $data_value = $eSheet->Cells($row,$col)->{'Value'};
			if($line eq '')
			{
				$line = $data_value;
			}
			else
			{
				$line = $line."\t".$data_value;
			}
		}
		push(@input_array,$line);
	}
}
print "
Enter 1. Address Lookup \n
Enter 2. Name Lookup \n
Enter 3. Estimated Value Sites:  1=TotalView, 2=HomeSnap \n
Enter 4. RUN ALL:   ADDRESS LOOKUP > NAME LOOKUP > ESTIMATED VALUE SITES\n\n";

print "Please Enter your option:-";
my $GetLookup = <STDIN>;
chomp($GetLookup);
my @arraycont;
if($GetLookup eq '1')
{
	print "
	Enter 1. GWINNETT
	Enter 2. Clarke
	Enter 3. CHEROKEE
	Enter 4. Hall
	Enter 5. Forsyth
	Enter 6. Fulton
	Enter 7. Dekalb
	Enter 8. All\n
	Enter Address Lookup Options:-";
	my $AddressOptions = <STDIN>;
	chomp ($AddressOptions);
	my %hashoptions =('1'=>'GWINNETT','2'=>'Clarke','3'=>'CHEROKEE','4'=>'Hall','5'=>'Forsyth','6'=>'Fulton','7'=>'Dekalb');
	my @options = split /\,/,$AddressOptions;
	foreach(@options)
	{
		my $opt = $_;
		foreach (@input_array)
		{
			my $line = $_;
			if($line =~ m/$hashoptions{$opt}/is)
			{
				push @arraycont, $line;
			}
		}
	}
	foreach(@arraycont)
	{
		my @array = split /\t/, $_;
		my $key = $array[6];
		my $county = $array[10];
		$county = &clean($county);
		sleep 10;
		if($county =~ m/GWINNET/is)
		{
			print "$key -> $county\n\n";
			&gwinnett::scrape($key,$county,\@array);
		}
		elsif($county =~ m/clarke|CHEROKEE|Hall|Forsyth|FULTON|dekalb/is)
		{
			print "$key -> $county\n\n";
			&forsyth::scrape($key,$county,\@array);
		}
	}
}
elsif($GetLookup eq '2')
{
	print "
	Enter 1. GWINNETT
	Enter 2. Clarke
	Enter 3. CHEROKEE
	Enter 4. Hall
	Enter 5. Forsyth
	Enter 6. Fulton
	Enter 7. Dekalb
	Enter 8. All\n
	Enter Address Lookup Options:-";
	my $AddressOptions = <STDIN>;
	chomp ($AddressOptions);
	my %hashoptions =('1'=>'GWINNETT','2'=>'Clarke','3'=>'CHEROKEE','4'=>'Hall','5'=>'Forsyth','6'=>'Fulton','7'=>'Dekalb');
	my @options = split /\,/,$AddressOptions;
	foreach(@options)
	{
		my $opt = $_;
		foreach (@input_array)
		{
			my $line = $_;
			if($line =~ m/$hashoptions{$opt}/is)
			{
				push @arraycont, $line;
			}
		}
	}
	foreach(@arraycont)
	{
		my @array = split /\t/, $_;
		my $key = $array[3];
		my $county = $array[10];
		$county = &clean($county);
		sleep 10;
		if($county =~ m/GWINNET/is)
		{
			print "$key -> $county\n\n";
			&gwinnett::scrape($key,$county,\@array,'Y');
		}
		elsif($county =~ m/clarke|CHEROKEE|Hall|Forsyth|FULTON|dekalb/is)
		{
			print "$key -> $county\n\n";
			&forsyth::scrape($key,$county,\@array,'Y');
		}
	}
}
elsif($GetLookup eq '3')
{
	print "
	Enter 1. Totalview
	Enter 2. Homesnap
	Enter 3. All\n
	Enter Address Lookup Options for Estimated Sites:-";
	my $AddressOptions = <STDIN>;
	chomp ($AddressOptions);
	my %hashoptions =('1'=>'Totalview','2'=>'Homesnap');
	my @options = split /\,/,$AddressOptions;
	foreach(@options)
	{
		my $opt = $_;
		foreach(@input_array)
		{
			my @array = split /\t/, $_;
			my $key = $array[5];
			sleep 10;
			if($hashoptions{$opt} eq 'Totalview')
			{
				&Totalview::scrape($key,\@array);
			}
			elsif($hashoptions{$opt} eq 'Homesnap')
			{
				&Homesnap::scrape($key,\@array);
			}
			else
			{
				&Totalview::scrape($key,\@array);
				&Homesnap::scrape($key,\@array);
			}
		}
	}
}
else
{
	foreach(@input_array)
	{
		my @array = split /\t/, $_;
		my $ekey = $array[5];
		&Totalview::scrape($ekey,\@array);
		&Homesnap::scrape($ekey,\@array);
		my $key1 = $array[3];
		my $county1 = $array[10];
		$county1 = &clean($county1);
		if($county1 =~ m/GWINNET/is)
		{
			&gwinnett::scrape($key1,$county1,\@array,'Y');
		}
		elsif($county1 =~ m/clarke|CHEROKEE|Hall|Forsyth|FULTON|dekalb/is)
		{
			&forsyth::scrape($key1,$county1,\@array,'Y');
		}
		my $key = $array[6];
		my $county = $array[10];
		$county = &clean($county);
		if($county =~ m/GWINNET/is)
		{
			&gwinnett::scrape($key,$county,\@array);
		}
		elsif($county =~ m/clarke|CHEROKEE|Hall|Forsyth|FULTON|dekalb/is)
		{
			&forsyth::scrape($key,$county,\@array);
		}
	}
}
sub clean()
{
	my $var=shift;
	$var=~s/\s+/ /igs;
	$var=~s/^\s+|\s+$//igs;
	return ($var);
}