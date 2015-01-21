package Totalview;
use strict;
use HTTP::Cookies;
use LWP::UserAgent;
use HTML::Entities;
use WWW::Mechanize;
use URI::Escape;
use LWP::Simple;
use Encode qw(encode);
use DateTime;
my $ua = LWP::UserAgent->new(show_progress=>1);
$ua->agent("Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 2.0.50727)");
$ua->timeout(30);
$ua->cookie_jar({});
my $date = DateTime->now->ymd;
$date =~ s/\-//igs;
my $filename ="totalviewrealestate";
my $cookie_file = $filename."_cookie.txt";
unlink($cookie_file);
my $cookie = HTTP::Cookies->new(file=>$cookie_file,autosave=>1);
$ua->cookie_jar($cookie);
sub scrape()
{
	my $keys = shift;
	my $arrayref = shift;
	my @array = @$arrayref;
	my $file_xls_name = "output_".$filename.".xls";
	my $tkeys = $keys;
	$tkeys =~ s/\s+/\+/igs;
	my $url = "http://totalviewrealestate.com/index.php?address=$tkeys&city=&state=+&zip=";
	my $content = &lwp_get($url);
	my $zestimate = &clean($1) if($content =~ m/<b>\s*Zestimate[^>]*?<a\s*[^>]*?>[^>]*?<\/a>\s*<\/b>\s*<br>\s*Value\s*Range\s*\:\s*([^>]*?)\s*</is);
	my $mid = &clean($1) if($content =~ m/<b>\s*Mid\s*Value[^>]*?<a\s*[^>]*?>[^>]*?<\/a>\s*<\/b>\s*<br>\s*Value\s*Range\s*\:\s*([^>]*?)\s*</is);
	my $total = &clean($1) if($content =~ m/>\s*Our\s*Estimate\:\s*<[^>]*?>\s*([^>]*?)\s*<\/font>/is);
	my $address = &clean($1) if($content =~ m/<p\s*class\=\"box\">\s*<b>([\w\W]*?)<\/b>/is);
	my $ptype = &clean($1) if($content =~ m/>\s*<td>\s*Property\s*Type\:\s*<\/td>\s*<td>\s*([^>]*?)\s*<\/td>\s*<\/tr>/is);
	my ($soldtotal, $soldsqft, $solddate);
	if($content =~ m/>\s*Last\s*Sold\s*For\:\s*([^>]*?)\s*<\/b>\s*\(([^>]*?)\)\s*<br>\s*<b>\s*Last\s*Sold\s*On\:\s*([^>]*?)\s*<\/b>\s*<\/p>/is)
	{
		$soldtotal = &clean($1);
		$soldsqft = &clean($2);
		$solddate = &clean($3);	
	}
	my $cdept = &clean($1) if($content =~ m/target\=\"extdata\">\s*([^>]*?)\s*<\/a>\s*<\/b>\s*<i>Car\-Dependent<\/i>/is);
	my $sqft = &clean($1) if($content =~ m/<td>\s*SqFt\:\s*<\/td>\s*<td>([^>]*?)<\/td>/is);
	my $lot = &clean($1) if($content =~ m/<td>\s*Lot\s*Size\:\s*<\/td>\s*<td>([^>]*?)<\/td>/is);
	my $ybuilt = &clean($1) if($content =~ m/<td>\s*Year\s*Built\:\s*<\/td>\s*<td>([^>]*?)<\/td>/is);
	my $taxass = &clean($1) if($content =~ m/<td>\s*Tax\s*Assessment\:\s*<\/td>\s*<td>([^>]*?)<\/td>/is);
	my $yassess = &clean($1) if($content =~ m/<td>\s*Year\s*Assessed\:\s*<\/td>\s*<td>([^>]*?)<\/td>/is);
	my $beds = &clean($1) if($content =~ m/<td>\s*Beds\:\s*<\/td>\s*<td>([^>]*?)<\/td>/is);
	my $baths = &clean($1) if($content =~ m/<td>\s*Baths\:\s*<\/td>\s*<td>([^>]*?)<\/td>/is);
	my $rooms = &clean($1) if($content =~ m/<td>\s*Rooms\:\s*<\/td>\s*<td>([^>]*?)<\/td>/is);
	my $garage = &clean($1) if($content =~ m/<td>\s*Garage\:\s*<\/td>\s*<td>([^>]*?)<\/td>/is);
	my $legal = &clean($1) if($content =~ m/<td>\s*Legal\:\s*<\/td>\s*<td>([^>]*?)<\/td>/is);
	my $apn = &clean($1) if($content =~ m/<td>\s*APN\:\s*<\/td>\s*<td>([^>]*?)<\/td>/is);
	my $gmaplink = &clean($1) if($content =~ m/href\=\"([^>]*?)\"[^>]*?>\s*Launch\s*Large\s*Google\s*Map\s*<\/a>/is);
	my $snaplink = &clean($1) if($content =~ m/href\=\"([^>]*?)\"[^>]*?>\s*[^>]*?<\/a>\s*\(Heat/is);
	my $avgbed = &clean($1) if($content =~ m/<b>\s*Averages\s*From\s*Active\s*Comps\:\s*([^>]*?)<\/b>/is);
	my ($listedtype, $listed, $mprice, $aprice);
	if($content =~ m/<td>\s*(All)\s*<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>\s*<td>\s*([^>]*?)\s*<\/td>\s*<td>\s*([^>]*?)\s*<\/td>/is)
	{
		$listedtype = &clean($1);
		$listed = &clean($2);
		$mprice = &clean($3);
		$aprice = &clean($4);
	}
	print "$keys->$zestimate->$mid\n";
	open jj, ">>$file_xls_name";
	print jj "$array[0]\t$array[1]\t$array[2]\t$array[3]\t$array[4]\t$array[5]\t$array[6]\t$array[7]\t$array[8]\t$array[9]\t$array[10]\t$array[11]\t$array[12]\t$keys\t$zestimate\t$mid\t$total\t$address\t$ptype\t$soldtotal\t$soldsqft\t$solddate\t$url\t$cdept\t$sqft\t$lot\t$ybuilt\t$taxass\t$yassess\t$beds\t$baths\t$rooms\t$garage\t$legal\t$apn\t$gmaplink\t$snaplink\t$avgbed\t$listedtype\t$listed\t$mprice\t$aprice\n";
	close jj;
}
sub lwp_get() 
{ 
    REPEAT: 
	my $urls = shift;
	$urls =~ s/amp\;//igs;
    sleep 10; 
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
        sleep 500; 
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
	$var=~s/\'/\'\'/igs;
	return ($var);
}
1;