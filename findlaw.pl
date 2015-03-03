use strict;
use HTTP::Cookies;
use LWP::UserAgent;
use HTML::Entities;
use URI::Escape;
use Encode qw(encode);
my $ua = LWP::UserAgent->new(show_progress=>1);
$ua->agent("Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 2.0.50727)");
$ua->timeout(30);
$ua->cookie_jar({});
my $filename ="findlaw";
my $cookie_file = $filename."_cookie.txt";
unlink($cookie_file);
my $cookie = HTTP::Cookies->new(file=>$cookie_file,autosave=>1);
$ua->cookie_jar($cookie);
open ff,">output.xls";
print ff "count\tpurl\tname\tcity\tstate\tcategory\tpname\tfname\tjtitle\tpaddress\tpaddress2\tpcity\tpstate\tpzipcode\tphone1\tphone2\tfax\twebsite\n";
close ff;
my @alpha = ('a'..'z');
my $count = 0;
foreach (@alpha)
{
	my $url = "http://pview.findlaw.com/profiles/lawyer/$_/1.html";
	my $content = &lwp_get($url);
	open ff,">findlaw.html";
	print ff $content;
	close ff;
	Nextpage:
	while($content =~ m/class\=\"bp_listings_result\"[^>]*?href\=\"([^>]*?)\">\s*<div[^>]*?itemprop\=\"name\">\s*([^>]*?)\s*<\/div>\s*<div[^>]*?itemprop\=\"address\"[^>]*?>\s*<span\s*itemprop\=\"addressLocality\">\s*([^>]*?)\s*<\/span>\s*\,\s*<span\s*itemprop\=\"addressRegion\">\s*([^>]*?)\s*<\/span>\s*<\/span>\s*<\/div>\s*(?:<div[^>]*?itemprop\=\"jobTitle\">\s*([^>]*?)\s*<)?/igs)
	{
		my $purl = &clean($1);
		my $name = &clean($2);
		my $city = &clean($3);
		my $state = &clean($4);
		my $category = &clean($5);
		my $pcontent = &lwp_get($purl);
		my $pname = &clean($1) if($pcontent =~ m/class\=\"pp_card_name main_header\"[^>]*?>([^>]*?)</is);
		my $fname = &clean($1) if($pcontent =~ m/class\=\"pp_card_focus_name\">\s*([^>]*?)\s*<\/div>/is);
		my $jtitle = &clean($1) if($pcontent =~ m/class\=\"pp_card_focus_name\">\s*<a\s*class\=\"org\"[^>]*?>\s*<span\s*itemprop\=\"name\">([^>]*?)</is);
		my ($paddress, $paddress2, $pcity, $pstate, $pzipcode);
		if($pcontent =~ m/class\=\"block_content_header\">Address<\/div>([\w\W]*?)<\/div>/is)
		{
			my $block = $1;
			while($block =~ m/itemprop\=\"streetAddress\">\s*([^>]*?)\s*</igs)
			{
				if($paddress eq '')
				{
					$paddress  = &clean($1);
				}
				else
				{
					$paddress2  = &clean($1);
				}
			}
			$pcity = &clean($1) if($block =~ m/itemprop\=\"addressLocality\">\s*([^>]*?)\s*</is);
			$pstate = &clean($1) if($block =~ m/itemprop\=\"addressRegion\">\s*([^>]*?)\s*</is);
			$pzipcode = &clean($1) if($block =~ m/itemprop\=\"postalCode\">\s*([^>]*?)\s*</is);
		}
		my ($phone1, $phone2);
		if($pcontent =~ m/class\=\"block_content_header\">Phone<\/div>([\w\W]*?)<\/div>/is)
		{
			my $block = $1;
			while($block =~ m/itemprop\=\"telephone\">\s*([^>]*?)\s*</igs)
			{
				if($phone1 eq '')
				{
					$phone1  = &clean($1);
				}
				else
				{
					$phone2  = &clean($1);
				}
			}
		}
		my $fax = &clean($1) if($pcontent =~ m/itemprop\=\"faxNumber\">\s*([^>]*?)\s*</is);
		my $website = $1 if($pcontent =~ m/class\=\"block_content_header\">Websites<\/div>([\w\W]*?)<\/div>/is);
		$website =~ s/<\/a>/|/igs;
		$website = &clean($website);
		$count++;
		print "$count -> $pname -> $pzipcode\n";
		open ff,">>output.xls";
		print ff "$count\t$purl\t$name\t$city\t$state\t$category\t$pname\t$fname\t$jtitle\t$paddress\t$paddress2\t$pcity\t$pstate\t$pzipcode\t$phone1\t$phone2\t$fax\t$website\n";
		close ff;		
	}
	if($content =~ m/rel\=\"next\"\s*href=\"([^>]*?)\"/is)
	{
		my $nextpage = $1;
		$content = &lwp_get($nextpage);
		goto Nextpage;
	}
}
sub lwp_get() 
{ 
	my $urls = shift;
	$urls =~ s/amp\;//igs;
    # sleep 15; 
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
    # if($code =~ m/50/is) 
    # { 
        # sleep 500; 
        # goto REPEAT; 
    # } 
    return($res->content()); 
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