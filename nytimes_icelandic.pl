use strict;
use HTTP::Cookies;
use LWP::UserAgent;
use HTML::Entities;
use WWW::Mechanize;
use URI::Escape;
use LWP::Simple;
use Encode qw(encode);
use DateTime;
use Date::Calc qw(Add_Delta_Days);
use Date::Calc qw(Days_in_Month Today);
my $ua = LWP::UserAgent->new(show_progress=>1);
$ua->agent("Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 2.0.50727)");
$ua->timeout(30);
$ua->cookie_jar({});
my $date = DateTime->now->ymd;
$date =~ s/\-//igs;
my $filename ="nytimes".$date;
my $cookie_file = $filename."_cookie.txt";
unlink($cookie_file);
my $cookie = HTTP::Cookies->new(file=>$cookie_file,autosave=>1);
$ua->cookie_jar($cookie);
my $count = 0;
my $flag = 0;
my $styear = "1855";
my $stmonth = "01";
my $stdays = "01";
nextping:
my $i =0;
	
	# my $days = Days_in_Month($styear, $stmonth);
	cyearping:
	my $pyear = "$styear$stmonth$stdays";	
	my $cyear = $pyear;
	# my $url = "http://api.nytimes.com/svc/search/v2/articlesearch.json?fq=malta&begin_date=".$pyear."&end_date=".$cyear."&page=$i&sort=oldest&api-key=111bbf1e448542a6e8090fc39b3e079d:16:54940415";
	# my $url = "http://api.nytimes.com/svc/search/v2/articlesearch.json?fq=malta&begin_date=".$pyear."&end_date=".$cyear."&page=$i&sort=oldest&api-key=111bbf1e448542a6e8090fc39b3e079d:16:54940415";
	# my $url = "http://api.nytimes.com/svc/search/v2/articlesearch.json?q=new+york+times&page=0&begin_date=".$pyear."&end_date=".$cyear."&sort=oldest&api-key=111bbf1e448542a6e8090fc39b3e079d:16:54940415";
	my $url = "http://api.nytimes.com/svc/search/v2/articlesearch.json?fq=iceland&page=0&begin_date=".$pyear."&end_date=".$cyear."&sort=oldest&api-key=111bbf1e448542a6e8090fc39b3e079d:16:54940415";
	my $content = &lwp_get($url);
	my ($hits,$count_curr,$hits_add);
	$count_curr = 0;
	print "Start count_curr ::> $count_curr\n";
	if($content =~ m/\"hits\"\:([^<]*?),/is)
	{
		$hits = $1
	}
	# if($hits >= 990)
	# {
		# $days = 15;
		# goto cyearping;
	# }
	NEXTPAGE:
	$count_curr = $count_curr + 10;
	while($content =~ m/(\{\"web_url\"[\w\W]*?)word_count/igs)
	{
		$count++;
		my $block = $1;
		my $title = &clean($1) if($block =~ m/\"Main\"\:\"([^>]*?)\"/is);
		my $para = &clean($1) if($block =~ m/\"lead_paragraph\"\:\"([^>]*?)\"/is);
		my $sec = &clean($1) if($block =~ m/\"section_name\"\:\"([^>]*?)\"/is);
		my $date = &clean($1) if($block =~ m/\"pub_date\"\:\"([^>]*?)\"/is);
		my $source = &clean($1) if($block =~ m/\"source\"\:\"([^>]*?)\"/is);
		my $weburl = &clean($1) if($block =~ m/\"web_url\"\:\"([^>]*?)\"/is);
		$weburl =~ s/\\//igs;
		print  "$count \n";
		open ff,">>sample_iceland_1851.xls";
		print ff "$count\t$title\t$para\t$sec\t$date\t$source\tIceland\t$weburl\n";
		close ff;
		$flag = 1;
	}
	print "count_curr :: $hits >= $count_curr\n";
	if($hits >= $count_curr)
	{	$i++;
		# my $nextpage = "http://api.nytimes.com/svc/search/v2/articlesearch.json?fq=malta&begin_date=".$pyear."&end_date=".$cyear."&page=$i&sort=oldest&api-key=111bbf1e448542a6e8090fc39b3e079d:16:54940415";
		my $nextpage = "http://api.nytimes.com/svc/search/v2/articlesearch.json?fq=iceland&page=$i&begin_date=".$pyear."&end_date=".$cyear."&sort=oldest&api-key=111bbf1e448542a6e8090fc39b3e079d:16:54940415";
		$content = &lwp_get($nextpage);
		# $flag = 0;
		goto NEXTPAGE;
	}
	my $entered_date = $cyear;
	# $entered_date =~ s/(\d{4})(\d{2})(\d{2})/$1-$2-$3/igs;
	if($entered_date =~ m/(\d{4})(\d{2})(\d{2})/is)
	{
		$styear = $1;
		$stmonth = $2;
		$stdays = $3;
		# print "Near start day1 :: $stdays/$stmonth/$styear\n";#<STDIN>;
		$pyear= join "-", Add_Delta_Days($styear,$stmonth,$stdays,1);
		$pyear =~ s/\-(\d{1})\-/-0$1-/igs;
		$pyear =~ s/\-(\d{1})$/-0$1/igs;
		$pyear =~ s/\-//igs;
		if($pyear =~ m/(\d{4})(\d{2})(\d{2})/is)
		{
			$styear = $1;
			$stmonth = $2;
			$stdays = $3;
		}
		# ($styear,$stmonth,$stdays) = Add_Delta_Days($styear,$stmonth,$stdays,1);
		print "Near start day :: $pyear\n";
	}
	if($styear >=1865)
	{
		exit;
	}
	else
	{
		print "Near start day :: $stdays/$stmonth/$styear\n";#<STDIN>;
		goto nextping;
	}
	
sub lwp_get() 
{ 
    my $urls = shift;
	$urls =~ s/amp\;//igs;
	print "urls :: $urls\n";
    # sleep 10; 
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
        sleep 10; 
        goto REPEAT; 
    } 
    return($res->content()); 
} 
sub clean()
{
	my $var=shift;
	$var=~s/<[^>]*?>/ /igs;
	$var=~s/\&nbsp\;|amp\;/ /igs;
	$var=decode_entities($var);
	$var=~s/\s+/ /igs;
	$var=~s/^\s+|\s+$//igs;
	return ($var);
}