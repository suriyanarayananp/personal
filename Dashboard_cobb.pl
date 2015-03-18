use strict;
use Cobbtax;
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
# Address Lookup for CobbTax
my @arraycont;
print "
Enter 1. Cobb
Enter Address Lookup Options:-";
my $AddressOptions = <STDIN>;
chomp ($AddressOptions);
my %hashoptions =('1'=>'COBB');
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
	if($county =~ m/cobb/is)
	{
		print "$key -> $county\n\n";
		&Cobbtax::scrape($key,$county,\@array);
	}
}
sub clean()
{
	my $var=shift;
	$var=~s/\s+/ /igs;
	$var=~s/^\s+|\s+$//igs;
	return ($var);
}