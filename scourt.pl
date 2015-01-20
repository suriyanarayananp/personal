use strict;
use HTTP::Cookies;
use LWP::UserAgent;
use HTML::Entities;
use URI::Escape;
use LWP::Simple;
use Encode qw(encode);
my $ua = LWP::UserAgent->new(show_progress=>1);
$ua->agent("Mozilla/5.0 (Windows NT 6.1; WOW64; rv:35.0) Gecko/20100101 Firefox/35.0");
$ua->timeout(30);
$ua->cookie_jar({});
my $filename ="supermecourt";
my $cookie_file = $filename."_cookie.txt";
unlink($cookie_file);
my $cookie = HTTP::Cookies->new(file=>$cookie_file,autosave=>1);
$ua->cookie_jar($cookie);
use Win32::OLE qw(in with in);
use Win32::OLE::Const;
use Win32::OLE::Variant;
use Win32::OLE::NLS qw(:LOCALE :DATE);
$Win32::OLE::Warn = 3; 
my $dir = `cd`;
$dir =~ s/\s*$//igs;

# my $inputfile = $ARGV[0];
my $inputfile = "Source_data.xls";

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
		print "Row Push: $row\n";
		push(@input_array,$line);
	}
}
my $count=0;
my $url = "https://iapps.courts.state.ny.us/webcivil/FCASSearch";
REPEAT:
my $req = HTTP::Request->new(GET=>$url); 
$req->header("Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"); 
$req->header("Content-Type"=>"application/x-www-form-urlencoded"); 
$req->header("DNT"=>"0"); 
$req->header("HOST"=>"iapps.courts.state.ny.us"); 
$req->header("Cookie"=>"webcivil=\"01/11/2015 09:36 AM\"; ucs_webcivil=2BXCyfDbAmijFphM64YOSeGACyjV%2FIfjyY3UR3JWlbA%3D; JSESSIONID=955A1167741F03FA0E7DB1CA15DD4932.server2074; TS01e3be5c=01d8b4db4bb82ee0c836faa9a0556e1e1274eb505c7d8e06ceb6ff02533de288ea775db155e4593dd35187872056aa67ed9cceb7b7; TS01e0f152=01d8b4db4b0ec458eb0624cc2f6a51a12b9199cef8ecdd6ff2a3647c2e885de001d2f29708; TS01e0f152_77=08b9a1dceaab2800bd2c3aaf60969755122f0b6214f71e560914630aafdf21976f63634a5e71857306994a2ac980bf09085fd3c6468238008500a945c95fef2d94fadba5f29240c01af5fae1fdf28d79ab49f5417a417edd8c64acc387e765a37d7eb279445a378f31d087b085700afe"); 
my $res = $ua->request($req); 
$cookie->extract_cookies($res); 
$cookie->save; 
$cookie->add_cookie_header($req); 
my $code = $res->code();
print $code,"\n"; 
if($code =~ m/50/is) 
{ 
	sleep 500; 
	goto REPEAT; 			
} 
my $content = $res->content(); 
open ss,">first.html";
print ss $content;
close ss;
# exit;
my $iflag = 0;
if($content =~ m/src\=\"([^>]*?)\"\s*alt\=\"jcaptcha\s*image\"/is)
{
	my $imgurl = "https://iapps.courts.state.ny.us/webcivil/".$1;
	print "Captcha URL:: $imgurl\n";
	$req = HTTP::Request->new(GET=>$imgurl); 
	$req->header("Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"); 
	$req->header("Content-Type"=>"application/x-www-form-urlencoded");
	$req->header("DNT"=>"0"); 
	$req->header("HOST"=>"iapps.courts.state.ny.us"); 
	$req->header("Cookie"=>"webcivil=\"01/11/2015 09:36 AM\"; ucs_webcivil=2BXCyfDbAmijFphM64YOSeGACyjV%2FIfjyY3UR3JWlbA%3D; JSESSIONID=955A1167741F03FA0E7DB1CA15DD4932.server2074; TS01e3be5c=01d8b4db4bb82ee0c836faa9a0556e1e1274eb505c7d8e06ceb6ff02533de288ea775db155e4593dd35187872056aa67ed9cceb7b7; TS01e0f152=01d8b4db4b0ec458eb0624cc2f6a51a12b9199cef8ecdd6ff2a3647c2e885de001d2f29708; TS01e0f152_77=08b9a1dceaab2800bd2c3aaf60969755122f0b6214f71e560914630aafdf21976f63634a5e71857306994a2ac980bf09085fd3c6468238008500a945c95fef2d94fadba5f29240c01af5fae1fdf28d79ab49f5417a417edd8c64acc387e765a37d7eb279445a378f31d087b085700afe"); 
	my $res = $ua->request($req); 
	$cookie->extract_cookies($res); 
	$cookie->save; 
	$cookie->add_cookie_header($req); 
	my $code = $res->code(); 
	print $code,"\n"; 
	my $imcontent = $res->content(); 
	open II,">captcha.jpg";
	binmode II;
	print II $imcontent;
	close II;
	print "Captcha Image Download Successfully -> Please Enter captcha \n";
	$iflag = 1;
}
if($iflag == 1)
{
	my $captcha = <STDIN>;
	chomp($captcha);
	my $req = HTTP::Request->new(POST=>$url); 
	$req->header("Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"); 
	$req->header("Content-Type"=>"application/x-www-form-urlencoded"); 
	$req->header("DNT"=>"0"); 
	$req->header("HOST"=>"iapps.courts.state.ny.us"); 
	$req->header("Referer"=>"https://iapps.courts.state.ny.us/webcivil/FCASSearch?param=I"); 
	$req->header("Cookie"=>"webcivil=\"01/11/2015 09:36 AM\"; ucs_webcivil=2BXCyfDbAmijFphM64YOSeGACyjV%2FIfjyY3UR3JWlbA%3D; JSESSIONID=955A1167741F03FA0E7DB1CA15DD4932.server2074; TS01e3be5c=01d8b4db4bb82ee0c836faa9a0556e1e1274eb505c7d8e06ceb6ff02533de288ea775db155e4593dd35187872056aa67ed9cceb7b7; TS01e0f152=01d8b4db4b62e7804071641f48771f45b87b54a16b2db96703dd346f590a87626b00b92b38; TS01e0f152_77=08b9a1dceaab2800605ebebdd7031f7eba1bcba46b644fc1fb0d0599055cdaa6a0aabaec8c6e286149dd78c5492ab1520851970065823800f183547b699d4f4a28b7c85e107d28cab0f7a7d65195c6309c873e243547db108031c203af13e7d9a428232e831de2f1e40c6ceeab2818b2");
	$req->content("chkSoundOnly=false&jcaptcha_answer=$captcha");
	my $res = $ua->request($req); 
	$cookie->extract_cookies($res); 
	$cookie->save; 
	$cookie->add_cookie_header($req); 
	my $code = $res->code(); 
	print $code,"\n"; 
	if($code =~ m/50/is) 
	{ 
		sleep 10; 
		goto REPEAT; 			
	} 
	# my $content = $res->content(); 
	# open ss,">second.html";
	# print ss $content;
	# close ss;
}
foreach(@input_array)
{
	my @array = split /\t/, $_;
	my ($val1, $val2) = split /\//, $array[1];
	print "Val1 $val1  -> Val2 $val2\n";
	sleep 25; 
	REPEAT2:
	my $req = HTTP::Request->new(POST=>$url); 
	$req->header("Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"); 
	$req->header("Content-Type"=>"application/x-www-form-urlencoded");
	$req->header("DNT"=>"0"); 
	$req->header("HOST"=>"iapps.courts.state.ny.us"); 
	$req->header("HOST"=>"iapps.courts.state.ny.us"); 
	$req->header("Cookie"=>"webcivil=\"01/11/2015 09:36 AM\"; ucs_webcivil=XAu1UwBp0Eyx_PLUS_RYEhVxjKh%2FJPBgEsuoeIv2G018yPIY%3D; JSESSIONID=955A1167741F03FA0E7DB1CA15DD4932.server2074; TS01e3be5c=01d8b4db4bb82ee0c836faa9a0556e1e1274eb505c7d8e06ceb6ff02533de288ea775db155e4593dd35187872056aa67ed9cceb7b7; TS01e0f152=01d8b4db4bc1e01359ed37bbdd3f522975773761e41f6a6b2536f637342eea5d8bbdb31eac0160970b3b21afa07a288ff4e52a0155; TS01e0f152_77=08b9a1dceaab2800605ebebdd7031f7eba1bcba46b644fc1fb0d0599055cdaa6a0aabaec8c6e286149dd78c5492ab1520851970065823800f183547b699d4f4a28b7c85e107d28cab0f7a7d65195c6309c873e243547db108031c203af13e7d9a428232e831de2f1e40c6ceeab2818b2");

	# $req->content("hWhichPage=I&hCourtType=Supreme&hPageNumber=1&hSearchKey=&txtIndex=$val1%2F$val2&txtPlaintiffLname=&txtAttorneyLname=&txtJudgeLname=&rdRepresents=Plaintiff&cboYearOfFiling=0&rbStatus=all&rbFutureCases=N&cboSort=index_number&rbOutputFormat=HTML&btnFindCase=Find+Case%28s%29");
	$req->content("hWhichPage=I&hCourtType=Supreme&hPageNumber=1&hSearchKey=&txtIndex=$val1%2F$val2&txtPlaintiffLname=&txtAttorneyLname=&txtJudgeLname=&rdRepresents=Plaintiff&cboCounty=23&cboYearOfFiling=0&rbStatus=all&rbFutureCases=N&cboSort=index_number&rbOutputFormat=HTML&btnFindCase=Find+Case%28s%29");
	my $res = $ua->request($req); 
	$cookie->extract_cookies($res); 
	$cookie->save; 
	$cookie->add_cookie_header($req); 
	my $code = $res->code(); 
	print $code,"\n"; 
	if($code =~ m/50/is) 
	{ 
		sleep 100; 
		goto REPEAT2; 			
	}
	elsif($code =~ m/302/is)
	{
		print "Captcha asking\n";
		exit;
	}

	my $pcontent = $res->content(); 
	# open ss,">third.html";
	# print ss $pcontent;
	# close ss;
	my $flag = 0;
	while($pcontent =~ m/class\=smallfont>\s*([^>]*?)\s*<\/span>\s*<\/td>\s*<td>\s*<[^>]*?class\=smallfont>\s*([^>]*?)\s*<\/span>\s*<\/td>\s*<td[^>]*?>\s*([\w\W]*?)<\/span>\s*<\/td>\s*<td>\s*<[^>]*?class\=smallfont>\s*([^>]*?)\s*<\/span>\s*<\/td>\s*<td>\s*<[^>]*?class\=smallfont>\s*([^>]*?)\s*<\/span>\s*<\/td>\s*<td>\s*<[^>]*?class\=smallfont>\s*([^>]*?)\s*<\/span>\s*<\/td>\s*<td>\s*<[^>]*?class\=smallfont>\s*([^>]*?)\s*<\/span>\s*<\/td>\s*<td>\s*<[^>]*?class\=smallfont>\s*([^>]*?)\s*<\/span>\s*<\/td>\s*<td[^>]*?>\s*([\w\W]*?)<\/span>\s*<\/td>[\w\W]*?<[^>]*?class\=smallfont>\s*([^>]*?)\s*<\/span>\s*<\/td>/igs)
	{
		my $id = &clean($1);
		my $country = &clean($2);
		my $indexno = &clean($3);
		my $casestatus = &clean($4);
		my $plain = &clean($5);
		my $firm = &clean($6);
		my $defedant = &clean($7);
		my $dfirm = &clean($8);
		my $appearncedate = &clean($9);
		my $justice = &clean($10);
		$count++;
		print "$count->$id->$country->$indexno  -> Found\n";
		open ss,">>output_ecourts.xls";
		print ss "$count\t$id\t$country\t$indexno\t$casestatus\t$plain\t$firm\t$defedant\t$dfirm\t$appearncedate\t$justice\n";
		close ss;
		$flag = 1;
	}
	if($flag == 0)
	{
		$count++;
		print "$count->Kings->$array[1] -> Not Found\n";
		open ss,">>output_ecourts.xls";
		print ss "$count\t0\tKings\t$array[1]\n";
		close ss;
	}
}
sub clean()
{
	my $var=shift;
	$var=~s/<[^>]*?>/ /igs;
	$var=~s/\&nbsp\;|amp\;/ /igs;
	$var=HTML::Entities::decode_entities($var);
	$var=~s/\s+/ /igs;
	$var=~s/^\s+|\s+$//igs;
	return ($var);
}