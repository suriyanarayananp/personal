use strict;
use HTTP::Cookies;
use LWP::UserAgent;
use HTML::Entities;
use URI::Escape;
use LWP::Simple;
use Encode qw(encode);
use DateTime;
my $ua = LWP::UserAgent->new(show_progress=>1);
$ua->agent("Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3 (.NET CLR 3.5.30729)");
$ua->timeout(30);
$ua->cookie_jar({});
my $date = DateTime->now->ymd;
$date =~ s/\-//igs;
my $filename ="isba_".$date;
my $cookie_file = $filename."_cookie.txt";
unlink($cookie_file);
my $cookie = HTTP::Cookies->new(file=>$cookie_file,autosave=>1);
$ua->cookie_jar($cookie);
open kk,">output.xls";
print kk "count\tplanid\toccupied\tname\teviction\taddress\tcity\tstate\tzip\tiprice\tcprice\tcounty\tsubdate\tloccode\twithdrawndate\ttype\tRejdate\tconst\tRevdate\tunits\tAcceptdate\trattroney\tAbandate\taction\teffdate\tcertified\tamendmentno\tamesubdate\trevattorney\tamerevdate\treveng\tameaction\tamecont\n";
close kk;
my $count=0;
my $url = "http://offeringplan.datasearch.ag.ny.gov/REF/search.do?plan_search_id=&search_one=++++Search++++&search_type=search_b";
my $content = &lwp_get($url);
open ff,">first.html";
print ff $content;
close ff;
NextPage:
while($content =~ m/href\=[^>]*?\?id\=([^>]*?)\s*>\s*([^>]*?)\s*<\/a>/igs)
{
	my $pid = &clean($2);
	my $purl = &clean("http://offeringplan.datasearch.ag.ny.gov/REF/planformservlet?id=$pid");
	my $pcontent = &lwp_get($purl);
	open ss,">second.html";
	print ss $pcontent;
	close ss;
	my ($planid,$occupied,$name,$eviction,$address,$city,$state,$zip,$iprice,$cprice,$county,$subdate,$loccode,$withdrawndate,$type,$Rejdate,$const,$Revdate,$units,$Acceptdate,$rattroney,$Abandate,$action,$effdate,$certified,$amendmentno, $amesubdate,$revattorney, $amerevdate,$ameaction,$reveng,$amecont);
	if($pcontent =~ m/<table\s*width\=\"100\%\"\s*border\=\"0\"\s*cellspacing\=\"4\"\s*cellpadding\=\"4\">([\w\W]*?)<\/table>/is)
	{
		my $planblock = $1;
		if($planblock =~ m/<b>\s*Plan\s*ID\:\s*<\/b>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>\s*(?:<[^>]*?>\s*)*Occupied\:\s*<\/b>\s*<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>/is)
		{
			$planid = &clean($1);
			$occupied = &clean($2);
		}
		if($planblock =~ m/<b>\s*Name\:\s*<\/b>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>\s*(?:<[^>]*?>\s*)*Eviction\:\s*<\/b>\s*<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>/is)
		{
			$name = &clean($1);
			$eviction = &clean($2);
		}
		if($planblock =~ m/<b>\s*Address\:\s*<\/b><\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>\s*(?:<[^>]*?>\s*)*Initial\s*Price\:\s*<\/b>\s*<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>/is)
		{
			$address = &clean($1);
			$iprice = &clean($2);
		}
		if($planblock =~ m/<td\s*align\=\"left\">\s*([^>]*?)\,\s*([A-Z]{2})\s+([^>]*?)\s*<\/td>\s*(?:<[^>]*?>\s*)*Current\s*Price\:\s*<\/b>\s*<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>/is)
		{
			$city = &clean($1);
			$state = &clean($2);
			$zip = &clean($3);
			$cprice = &clean($4);
		}
		if($planblock =~ m/<b>\s*Boro\/County\:\s*<\/b><\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>\s*(?:<[^>]*?>\s*)*Submitted\s*Date\:\s*<\/b>\s*<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>/is)
		{
			$county = &clean($1);
			$subdate = &clean($2);
		}
		if($planblock =~ m/<b>\s*Location\s*Code\:\s*<\/b><\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>\s*(?:<[^>]*?>\s*)*Withdrawn\s*Date\:\s*<\/b>\s*<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>/is)
		{
			$loccode = &clean($1);
			$withdrawndate = &clean($2);
		}
		if($planblock =~ m/<b>\s*Type\:\s*<\/b><\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>\s*(?:<[^>]*?>\s*)*Rejected\s*Date\:\s*<\/b>\s*<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>/is)
		{
			$type = &clean($1);
			$Rejdate = &clean($2);
		}
		if($planblock =~ m/<b>\s*Construction\:\s*<\/b><\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>\s*(?:<[^>]*?>\s*)*Reviewed\s*Date\:\s*<\/b>\s*<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>/is)
		{
			$const = &clean($1);
			$Revdate = &clean($2);
		}
		if($planblock =~ m/<b>\s*Units\:\s*<\/b><\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>\s*(?:<[^>]*?>\s*)*Accepted\s*Date\:\s*<\/b>\s*<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>/is)
		{
			$units = &clean($1);
			$Acceptdate = &clean($2);
		}
		if($planblock =~ m/<b>\s*Review\s*Attorney\:\s*<\/b><\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>\s*(?:<[^>]*?>\s*)*Abandoned\s*Date\:\s*<\/b>\s*<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>/is)
		{
			$rattroney = &clean($1);
			$Abandate = &clean($2);
		}
		if($planblock =~ m/<b>\s*Action\:\s*<\/b><\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>\s*(?:<[^>]*?>\s*)*Effective\s*Date\:\s*<\/b>\s*<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>/is)
		{
			$action = &clean($1);
			$effdate = &clean($2);
		}
		if($planblock =~ m/<td\s*colspan\=\"2\">\s*([^>]*?)\s*<\/td>\s*(?:<[^>]*?>\s*)*CPS\-10\s*Certification\s*Filed\:\s*<\/b>\s*<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>/is)
		{
			$certified = &clean($2);
		}
		if($planblock =~ m/<b>\s*Amendment\s*No\:\s*<\/b><\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>\s*(?:<[^>]*?>\s*)*Submitted\s*Date\:\s*<\/b>\s*<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>/is)
		{
			$amendmentno = &clean($1);
			$amesubdate = &clean($2);
		}
		if($planblock =~ m/<b>\s*Review\s*Attorney\:\s*<\/b><\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>\s*(?:<[^>]*?>\s*)*Reviewed\s*Date\:\s*<\/b>\s*<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>/is)
		{
			$revattorney = &clean($1);
			$amerevdate = &clean($2);
		}
		if($planblock =~ m/<b>\s*Review\s*Engineer\:\s*<\/b><\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>\s*(?:<[^>]*?>\s*)*Action\:\s*<\/b>\s*<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>/is)
		{
			$reveng = &clean($1);
			$ameaction = &clean($2);
		}
		$amecont = &clean($1) if($planblock =~ m/<b>\s*Contents\*\s*(?:<[^>]*?>\s*)*[^>]*?\s*<\/span>\s*(?:<[^>]*?>\s*)*\s*\:\s*(?:<[^>]*?>\s*)*([^>]*?)\s*<\/td>/is);
		$count++;
		print "$count -> $planid -> $name\n";
		open kk,">>output.xls";
		print kk "$count\t$planid\t$occupied\t$name\t$eviction\t$address\t$city\t$state\t$zip\t$iprice\t$cprice\t$county\t$subdate\t$loccode\t$withdrawndate\t$type\t$Rejdate\t$const\t$Revdate\t$units\t$Acceptdate\t$rattroney\t$Abandate\t$action\t$effdate\t$certified\t$amendmentno\t$amesubdate\t$revattorney\t$amerevdate\t$reveng\t$ameaction\t$amecont\n";
		close kk;
	}
}
if($content =~ m/href\=([^>]*?)>\s*<img\s*src\=\"images\/next\.gif/is)
{
	my $next = "http://offeringplan.datasearch.ag.ny.gov".$1;
	$content = &lwp_get($next);
	goto NextPage;
}
sub lwp_get() 
{ 
	my $curl = shift;
	$curl =~ s/amp\;//igs;
    REPEAT: 
    my $req = HTTP::Request->new(GET=>$curl); 
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
        sleep 10; 
        goto REPEAT; 
    } 
    return($res->content());
}
sub clean() 
{ 
    my $var=shift; 
    $var=~s/<[^>]*?>//igs; 
    $var=~s/&nbsp\;|amp\;/ /igs; 
    $var=decode_entities($var); 
    $var=~s/\s+/ /igs; 
    return ($var); 
} 