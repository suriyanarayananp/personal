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
open OO,">output_streeteasyv1.xls";
print OO "SI.NO\tSOURCE URL\tBUILD\tOWNED BY\tARCHITECH\tDEVELOPER\tMANAGER\tLAND AND MARKETING\tLAND OFFICE TEL\tSALE ADDRESS\tSALE MARKETING\tSALE OFFICE TEL\tINTERIOR\tWEBSITE\tADDRESS\tCITY\tSTATE\tZIPCODE\n";
close OO;
open NN,"input.txt";
while(<NN>)
{
	chomp;
	my $url = $_;
	my $pcontent = &lwp_get($url);
	my $build = &clean($1) if($pcontent =~ m/>\s*Building\s*\:\s*([^>]*?)\s*</is);
	my $owned = &clean($1) if($pcontent =~ m/>\s*Owned\s*by\s*\:\s*<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>/is);
	my $arch = &clean($1) if($pcontent =~ m/>\s*Architect\s*\:\s*<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>/is);
	my $dev = &clean($1) if($pcontent =~ m/>\s*Developer\s*\:\s*<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>/is);
	my $mgr = &clean($1) if($pcontent =~ m/>\s*Manager\s*\:\s*<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>/is);
	my $landm = &clean($1) if($pcontent =~ m/>\s*Leasing\s*and\s*marketing\s*\:\s*<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>/is);
	my $lot = &clean($1) if($pcontent =~ m/>\s*Leasing\s*office\s*tel\s*\:\s*<\/td>\s*<td[^>]*?>\s*([\w\W]*?)\s*<\/td>/is);
	my $saleadd = &clean($1) if($pcontent =~ m/>\s*Sales\s*office\s*addr\s*\:\s*<\/td>\s*<td[^>]*?>\s*([\w\W]*?)\s*<\/td>/is);
	my $salemkr = &clean($1) if($pcontent =~ m/>\s*Sales\s*and\s*marketing\s*\:\s*<\/td>\s*<td[^>]*?>\s*([\w\W]*?)\s*<\/td>/is);
	my $salemtel = &clean($1) if($pcontent =~ m/>\s*Sales\s*office\s*tel\s*\:\s*<\/td>\s*<td[^>]*?>\s*([\w\W]*?)\s*<\/td>/is);
	my $interior = &clean($1) if($pcontent =~ m/>\s*Interiors\s*\:\s*<\/td>\s*<td[^>]*?>\s*([\w\W]*?)\s*<\/td>/is);
	my $web;
	if($pcontent =~ m/>\s*Website\s*\:\s*<\/td>\s*<td[^>]*?>\s*<a\s*href\=\"([^>]*?)\"[^>]*?>\s*([^>]*?)\s*<\/a>/is)
	{
		my $link1 = $1;
		my $link2 = $2;
		if($link2 =~ m/\.com|http\:/is)
		{
			$web = $link2;
		}
		else
		{
			$web = "http://streeteasy.com".$link1 unless($link1 =~ m/^http/is);
		}
	}
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
	open KK,">>output_streeteasyv1.xls";
	print KK "$count\t$url\t$build\t$owned\t$arch\t$dev\t$mgr\t$landm\t$lot\t$saleadd\t$salemkr\t$salemtel\t$interior\t$web\t$address\t$city\t$state\t$zipcode\n";
	close KK;
}
close NN;
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