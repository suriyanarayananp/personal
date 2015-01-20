use strict;
use HTTP::Cookies;
use LWP::UserAgent;
use HTML::Entities;
use URI::Escape;
use LWP::Simple;
use Encode qw(encode);
my $ua = LWP::UserAgent->new(show_progress=>1);
$ua->agent("Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 2.0.50727)");
$ua->timeout(30);
$ua->cookie_jar({});
my $filename ="streeteasy";
my $cookie_file = $filename."_cookie.txt";
unlink($cookie_file);
my $cookie = HTTP::Cookies->new(file=>$cookie_file,autosave=>1);
$ua->cookie_jar($cookie);
my $count=0;
my $url = "http://streeteasy.com/for-rent/nyc";
my $content = &lwp_get($url);
# open ss,">first.html";
# print ss $content;
# close ss;
NExtpage:
while($content =~ m/class\=\"details\-title\">\s*<a\s*href\=\"([^>]*?)\"/igs)
{
	my $formurl = $1;
	if($formurl =~ m/\/([^>]*?)\/([^>]*?)(?:\/|\?|$)/is)
	{
		my $listurl = "http://streeteasy.com/building/$2";
		my $pcontent = &lwp_get($listurl);
		# open ss,">second.html";
		# print ss $pcontent;
		# close ss;
		# exit;
		my $build = &clean($1) if($pcontent =~ m/>\s*Building\s*\:\s*([^>]*?)\s*</is);
		my $owned = &clean($1) if($pcontent =~ m/>\s*Owned\s*by\s*\:\s*<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>/is);
		my $arch = &clean($1) if($pcontent =~ m/>\s*Architect\s*\:\s*<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>/is);
		my $dev = &clean($1) if($pcontent =~ m/>\s*Developer\s*\:\s*<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>/is);
		my $mgr = &clean($1) if($pcontent =~ m/>\s*Manager\s*\:\s*<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>/is);
		my $landm = &clean($1) if($pcontent =~ m/>\s*Leasing\s*and\s*marketing\s*\:\s*<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>/is);
		my $lot = &clean($1) if($pcontent =~ m/>\s*Leasing\s*office\s*tel\s*\:\s*<\/td>\s*<td[^>]*?>\s*([\w\W]*?)\s*<\/td>/is);
		my $web = &clean($1) if($pcontent =~ m/>\s*Website\s*\:\s*<\/td>\s*<td[^>]*?>\s*<[^>]*?>\s*([^>]*?)\s*</is);
		my ($address, $city, $state, $zipcode);
		if($pcontent =~ m/class\=\'subtitle\'>\s*([^>]*?)\s*\,\s*([^>]*?)\s*\,\s*([^>]*?)\s*\,s*([^>]*?)\s*<\/div>/is)
		{
			$address = &clean($1);
			$city = &clean($2);
			$state = &clean($3);
			$zipcode = &clean($4);
		}
		$count++;
		print "$count -> $build\n";
		open KK,">>output_streeteasy.xls";
		print KK "$count\t$listurl\t$build\t$owned\t$arch\t$dev\t$mgr\t$landm\t$lot\t$web\t$address\t$city\t$state\t$zipcode\n";
		close KK;
	}
}
if($content =~ m/href\=\"([^>]*?)\"\s*class\=\"next_page\"/is)
{
	my $next = $1;
	$next = "http://streeteasy.com".$next unless($next =~ m/^http/is);
	$content = &lwp_get($next);
	goto NExtpage;
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
sub lwp_get() 
{ 
    my $urls = shift;
	$urls =~ s/amp\;//igs;
	my $pincount=0;
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
		if($pincount <=3)
		{
			sleep 500; 
			$pincount++;
			goto REPEAT; 			
		}
    } 
    return($res->content()); 
}