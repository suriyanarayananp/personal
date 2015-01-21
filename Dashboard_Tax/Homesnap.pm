package Homesnap;
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
$ua->agent("Mozilla/5.0 (Windows NT 6.2; WOW64; rv:33.0) Gecko/20100101 Firefox/33.0");
$ua->timeout(30);
$ua->cookie_jar({});
my $date = DateTime->now->ymd;
$date =~ s/\-//igs;
my $filename ="Homesnap";
my $cookie_file = $filename."_cookie.txt";
unlink($cookie_file);
my $cookie = HTTP::Cookies->new(file=>$cookie_file,autosave=>1);
$ua->cookie_jar($cookie);
# open jj, ">Homesnap_output.xls";
# print jj "count\tkeys\tEstimate\tRent\thomescore\tinvestorscore\tLastSaleDate\tLastSalePrice\tbeds\tBathsFull\tsqft\tlotsize\tconstruction\tstyle\tYearBuilt\tBasement\tParking\tparkingspaces\n";
# close jj;
sub scrape()
{
	my $keys = shift;
	my $arrayref = shift;
	my @array = @$arrayref;
	my $file_xls_name = "output_".$filename.".xls";
	my $tkeys = $1 if($keys =~ m/([^>]*?\,[^>]*?)\,/is);
	$tkeys =~ s/\s+/\+/igs;
	my $url = "http://www.homesnap.com/search?q=$tkeys&pt=0";
	my $content = &lwp_get($url);
	# open sk,">test.html";
	# print sk $content;
	# close sk;
	# exit;
	my $Estimate = &clean($1) if($content =~ m/>\s*Value\s*Estimate\s*<\/div>\s*<div\s*class\=\"pfValue\s*value\">\s*([^>]*?)\s*</is);
	my $Rent = &clean($1) if($content =~ m/>\s*Rent\s*Estimate\s*<\/div>\s*<div\s*class\=\"pfValue\s*Rent\">\s*([^>]*?)\s*</is);
	my $homescore = &clean($1) if($content =~ m/class\=\"pfValue\s*homescore\">\s*([^>]*?)\s*</is);
	my $investorscore = &clean($1) if($content =~ m/class\=\"pfValue\s*investorscore\">\s*([^>]*?)\s*</is);
	my $LastSaleDate = &clean($1) if($content =~ m/class\=\"pfValue\s*LastSaleDate\">\s*([^>]*?)\s*</is);
	my $LastSalePrice = &clean($1) if($content =~ m/class\=\"pfValue\s*LastSalePrice\">\s*([^>]*?)\s*</is);
	my $beds = &clean($1) if($content =~ m/class\=\"pfValue\s*beds\">\s*([^>]*?)\s*</is);
	my $BathsFull = &clean($1) if($content =~ m/class\=\"pfValue\s*BathsFull\">\s*([^>]*?)\s*</is);
	my $sqft = &clean($1) if($content =~ m/class\=\"pfValue\s*sqft\">\s*([^>]*?)\s*</is);
	my $lotsize = &clean($1) if($content =~ m/class\=\"pfValue\s*lotsize\">\s*([^>]*?)\s*</is);
	my $construction = &clean($1) if($content =~ m/class\=\"pfValue\s*construction\">\s*([^>]*?)\s*</is);
	my $style = &clean($1) if($content =~ m/class\=\"pfValue\s*style\">\s*([^>]*?)\s*</is);
	my $YearBuilt = &clean($1) if($content =~ m/class\=\"pfValue\s*YearBuilt\">\s*([^>]*?)\s*</is);
	my $Basement = &clean($1) if($content =~ m/class\=\"pfValue\s*Basement\">\s*([^>]*?)\s*</is);
	my $Parking = &clean($1) if($content =~ m/class\=\"pfValue\s*Parking\">\s*([^>]*?)\s*</is);
	my $parkingspaces = &clean($1) if($content =~ m/class\=\"pfValue\s*parkingspaces\">\s*([^>]*?)\s*</is);
	print "$keys->$Estimate\n";
	open jj, ">>$file_xls_name";
	print jj "$array[0]\t$array[1]\t$array[2]\t$array[3]\t$array[4]\t$array[5]\t$array[6]\t$array[7]\t$array[8]\t$array[9]\t$array[10]\t$array[11]\t$array[12]\t$keys\t$Estimate\t$Rent\t$homescore\t$investorscore\t$LastSaleDate\t$LastSalePrice\t$beds\t$BathsFull\t$sqft\t$lotsize\t$construction\t$style\t$YearBuilt\t$Basement\t$Parking\t$parkingspaces\n";
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