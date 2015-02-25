use strict;
use HTTP::Cookies;
use LWP::UserAgent;
use HTML::Entities;
use URI::Escape;
use Encode qw(encode);
my $ua = LWP::UserAgent->new(show_progress=>1);
$ua->agent("Mozilla/5.0 (Windows NT 6.1; WOW64; rv:35.0) Gecko/20100101 Firefox/35.0");
$ua->timeout(30);
my $cookie_file = "appext20_cookie.txt";
unlink($cookie_file);
my $cookie = HTTP::Cookies->new(file=>$cookie_file,autosave=>1);
$ua->cookie_jar($cookie);
my $count = 0;
my $content = &lwp_get("http://www.dos.ny.gov/corps/bus_entity_search.html");
open LL,"input.txt";
while(<LL>)
{
	chomp;
	my $key = $_;
	my @array = ('BEGINS', 'CONTAINS','PARTIAL');
	my $i = 0;
	my $flag = 0;
	NextSearchOption:
	my $content = &lwp_get("http://appext20.dos.ny.gov/corp_public/CORPSEARCH.SELECT_ENTITY?p_entity_name=$key&p_name_type=%25&p_search_type=$array[$i]");
	NextPage:
	open SS,">test.html";
	print SS $content;
	close SS;
	while($content =~ m/<a\s*title\=\"Link\s*to\s*entity\s*information\.\" \s*[^>]*?href\=\"([^>]*?)\"/igs)
	{
		my $purl = &clean("http://appext20.dos.ny.gov/corp_public/".$1);
		my $pcontent = &lwp_get($purl);
		open SS,">test2.html";
		print SS $pcontent;
		close SS;
		# exit;
		my $entityname = &clean($1) if($pcontent =~ m/>\s*Current\s*Entity\s*Name\:\s*<\/th>\s*<td>\s*([^>]*?)\s*<\/td>/is);
		my $dosid = &clean($1) if($pcontent =~ m/>\s*DOS\s*ID\s*\#\:\s*<\/th>\s*<td>\s*([^>]*?)\s*<\/td>/is);
		my $filldate = &clean($1) if($pcontent =~ m/>\s*Initial\s*DOS\s*Filing\s*Date\:\s*<\/th>\s*<td>\s*([^>]*?)\s*<\/td>/is);
		my $county = &clean($1) if($pcontent =~ m/>\s*County\:\s*<\/th>\s*<td>\s*([^>]*?)\s*<\/td>/is);
		my $diction = &clean($1) if($pcontent =~ m/>\s*Jurisdiction\:\s*<\/th>\s*<td>\s*([^>]*?)\s*<\/td>/is);
		my $entitytype = &clean($1) if($pcontent =~ m/>\s*Entity\s*Type\:\s*<\/th>\s*<td>\s*([^>]*?)\s*<\/td>/is);
		my $entitystatus = &clean($1) if($pcontent =~ m/>\s*Current\s*Entity\s*Status\:\s*<\/th>\s*<td>\s*([^>]*?)\s*<\/td>/is);
		my ($daddress, $dosname, $daddress2, $dcity, $dstate, $dzip);
		if($pcontent =~ m/>\s*DOS\s*Process([\w\W]*?)<\/td>/is)
		{
			my $block = $1;
			if($block =~ m/headers=\"c1\">\s*([^>]*?)\s*<br>\s*([^>]*?)\s*<br>\s*(?:([^>]*?)\s*<br>)?\s*([^>]*?)\s*\,\s*([^>]*?)\s*\,\s*([^>]*?)\s*$/is)
			{
				$dosname = &clean($1);
				$daddress = &clean($2);
				$daddress2 = &clean($3);
				$dcity = &clean($4);
				$dstate = &clean($5);
				$dzip = &clean($6);
			}
		}
		my ($raddress, $rosname, $raddress2, $rcity, $rstate, $rzip);
		if($pcontent =~ m/>\s*Registered\s*Agent\s*<\/th>([\w\W]*?)<\/td>/is)
		{
			my $block = $1;
			if($block =~ m/headers=\"c1\">\s*([^>]*?)\s*<br>\s*([^>]*?)\s*<br>\s*(?:([^>]*?)\s*<br>)?\s*([^>]*?)\s*\,\s*([^>]*?)\s*\,\s*([^>]*?)\s*$/is)
			{
				$rosname = &clean($1);
				$raddress = &clean($2);
				$raddress2 = &clean($3);
				$rcity = &clean($4);
				$rstate = &clean($5);
				$rzip = &clean($6);
			}
		}
		$count++;
		print "$count -> $key ->  $dosid\n";
		open ff,">>output.xls";
		print ff "$count\t$entityname\t$dosid\t$filldate\t$county\t$diction\t$entitytype\t$entitystatus\t$dosname\t$daddress\t$daddress2\t$dcity\t$dstate\t$dzip\t$rosname\t$raddress\t$dosid\t$raddress2\t$rcity\t$rstate\t$rzip\t$purl\t$array[$i]\t$key\n";
		close ff;
		$flag=1;
	}
	if(($flag == 0) && ($i<3))
	{
		$i++;
		goto NextSearchOption;
	}
	elsif($flag == 0)
	{
		$count++;
		open ff,">>output.xls";
		print ff "$count\t$key\n";
		close ff;
	}
	if($content =~ m/href\=\"([^>]*?)\">\s*Next\s*Page\s*<\/a>/is)
	{
		my $nextpage = &clean("http://appext20.dos.ny.gov/corp_public/".$1);
		$content = &lwp_get($nextpage);
		goto NextPage;
	}
}
sub clean()
{
	my $var=shift;
	$var=~s/<[^>]*?>/ /igs;
	$var=~s/amp\;//igs;
	$var=~s/\&nbsp\;/ /igs;
	$var=decode_entities($var);
	$var=~s/\s+/ /igs;
	$var=~s/\'/\'\'/igs;
	return ($var);
}
sub lwp_get() 
{ 
    my $urls = shift;
	$urls =~ s/amp\;//igs;
    REPEAT: 
	my $req = HTTP::Request->new(GET=>$urls); 
    $req->header("Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"); 
    $req->header("Content-Type"=>"application/x-www-form-urlencoded"); 
    my $res = $ua->request($req); 
    $cookie->extract_cookies($res); 
    $cookie->save; 
    $cookie->add_cookie_header($req); 
    my $code = $res->code(); 
    print $code,"\n"; 
    if($code =~ m/50/is) 
    { 
        sleep 1; 
        goto REPEAT; 
    } 
    return($res->content()); 
}