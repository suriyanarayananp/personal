use strict;
use HTTP::Cookies;
use LWP::UserAgent;
use HTML::Entities;
use MIME::Base64;
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
my $cookie = HTTP::Cookies->new(autosave=>1);
$ua->cookie_jar($cookie);
my $count=0;
my $url = "http://www.cuponation.in/jabong-coupons";
my $content = &lwp_get($url);
open OO,">test.html";
print OO $content;
close OO;
# exit;
NExtpage:
while($content =~ m/<article\s*class\=\"voucher\s*code\s*custom\-text\"([\w\W]*?)<\/article>/igs)
{
	my $block = $1;
	my $id = &clean($1) if($block =~ m/id\=\"([^>]*?)\"/is);
	my $vouchercode = decode_base64($1) if($block =~ m/data\-voucher\-cd\=\"([^>]*?)\"/is);
	my $header = &clean($1) if($block =~ m/class\=\"voucher\-action\-btn\"\s*target\=\"_blank\">\s*([^>]*?)\s*<\/a>\s*<\/h3>/is);
	
	$count++;
	print "$count -> $id\n";
	open KK,">>output_coupon.xls";
	print KK "$count\t$id\t$vouchercode\t$header\n";
	close KK;
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