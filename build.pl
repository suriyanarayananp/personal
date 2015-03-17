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
my $cookie = HTTP::Cookies->new(autosave=>1);
$ua->cookie_jar($cookie);
my $count=0;
# my $url = "http://streeteasy.com/for-rent/nyc";
my $url = "http://www.buildzoom.com/property-info/101-01st-st-san-francisco-ca-94105";
my $content = &lwp_get($url);
while($content =~ m/class\=\"permit\-details\">([\w\W]*?)<\/table>\s*<\/div>\s*<\/div>/igs)
{
	my $block = $1;
	my $pdesc = &clean($1) if($block =~ m/class\=\"permit\-description\">\s*([^>]*?)\s*</is);
	my $ptype = &clean($1) if($block =~ m/>\s*Permit\s*Type\s*<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*</is);
	my $pstatus = &clean($1) if($block =~ m/>\s*Status\s*<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*</is);
	my $permitid = &clean($1) if($block =~ m/>\s*Permit\s*\#\s*<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*</is);
	my $pvalue = &clean($1) if($block =~ m/>\s*Valuation\s*<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*</is);
	my $btype = &clean($1) if($block =~ m/>\s*Building\s*Type\s*<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*</is);
	my $bowner = &clean($1) if($block =~ m/>\s*Business\s*owner\s*<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*</is);
	my $ctelp = &clean($1) if($block =~ m/>\s*Contractor\s*Telephone\s*<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*</is);
	my $licno = &clean($1) if($block =~ m/>\s*License\s*number\s*[^>]*?<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*</is);
	my $pvalue = &clean($1) if($block =~ m/>\s*Permit\s*Value\s*<\/label>\s*<div[^>]*?>\s*([^>]*?)\s*</is);
	my $pdate = &clean($1) if($block =~ m/>\s*Permit\s*date\s*<\/label>\s*<div[^>]*?>\s*([^>]*?)\s*</is);
	$count++;
	print "$count -> $permitid\n";
	open ff,">>output.xls";
	print ff "$count\t$pdesc\t$ptype\t$permitid\t$pvalue\t$btype\t$bowner\t$ctelp\t$licno\t$pvalue\t$pdate\n";
	close ff;	
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