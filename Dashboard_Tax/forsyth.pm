use strict;
use HTTP::Cookies;
use LWP::UserAgent;
use HTML::Entities;
use WWW::Mechanize;
use URI::Escape;
use LWP::Simple;
use Encode qw(encode);
use DateTime;
package forsyth;
my $ua = LWP::UserAgent->new(show_progress=>1);
$ua->agent("Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 2.0.50727)");
$ua->timeout(30);
$ua->cookie_jar({});
my $date = DateTime->now->ymd;
$date =~ s/\-//igs;
my $filename ="forsyth";
my $cookie_file = $filename."_cookie.txt";
unlink($cookie_file);
my $cookie = HTTP::Cookies->new(file=>$cookie_file,autosave=>1);
$ua->cookie_jar($cookie);
my $count;
sub scrape()
{
	my $key = shift;
	my $county = shift;
	my $arrayref = shift;
	my $NameFlag = shift;
	my @array = @$arrayref;
	my $file_xls_name = "output_".$county.".xls";
	$county = lc($county);
	my $post;
	my ($street, $streetname);
	$county =~ s/^\s+|\s+$//igs;
	if($NameFlag eq 'Y')
	{
		my $tkey = $key;
		$tkey =~ s/\,//igs;
		$tkey =~ s/\s+/+/igs;
		$post = "BEGIN=0&INPUT=$tkey&searchType=owner_name&county=ga_".$county."&Owner_Search=Search+By+Owner+Name";
	}
	else
	{
		($street, $streetname) = $key =~ m/^([^>]*?)\s+([^>]*?)$/is;
		$streetname =~ s/^\s+|\s+$//igs;	$street =~ s/^\s+|\s+$//igs;	
		$post="BEGIN=0&streetNumber=$street&streetName=$streetname&streetType=&streetDirection=&streetUnit=&searchType=address_search&county=ga_".$county."&Address+Search=Address+Search";
	}
	
	print "Key->$key->>$county\n\n";
	my $url;
	if($county =~ m/clarke/is)
	{
		$url = "http://qpublic7.qpublic.net/ga_alsearch.php";
	}
	elsif($county =~ m/CHEROKEE/is)
	{
		$url = "http://qpublic7.qpublic.net/ga_alsearch_dw.php";
	}
	elsif($county =~ m/Hall/is)
	{
		$url = "http://qpublic7.qpublic.net/ga_alsearch.php";
	}
	else
	{
		$url = "http://qpublic9.qpublic.net/ga_alsearch_dw.php";
	}
	my $req = HTTP::Request->new(POST=>$url); 
	$req->header("Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"); 
	$req->header("Content-Type"=>"application/x-www-form-urlencoded");
	$req->content($post);
	my $res = $ua->request($req); 
	$cookie->extract_cookies($res); 
	$cookie->save; 
	$cookie->add_cookie_header($req); 
	my $code = $res->code();
	my $content = $res->content();
	open ss,">forsyth.html";
	print ss $content;
	close ss;
	if($content =~ m/class\=\"search_value\">\s*\&nbsp\;\s*<a\s*href\=\"([^>]*?)\">\s*([^>]*?)\s*<\/a>/is)
	{
		my $purl = $1;
		my $pcont = &lwp_get($purl);
		open ss,">forsyth2.html";
		print ss $pcont;
		close ss;
		$count++;
		my $name  = &clean($1.$2) if($pcont =~ m/>\s*Owner\s*Name\s*<\/font>\s*<\/td>\s*<td\s*class\=\"cell_value\">\s*([\w\W]*?)\s*<\/td>|>\s*Owner\s*Name\s*<\/(?:A|font)>\s*<\/td>\s*<td\s*class\=\"owner_value">\s*([\w\W]*?)\s*<\/td>/is);
		my $mailaddress  = &clean($1.$2) if($pcont =~ m/>\s*Mailing\s*Address\s*<\/font>[^>]*?<\/td>\s*<td\s*class\=\"cell_value\">\s*([\w\W]*?)\s*<\/td>|>\s*Mailing\s*Address\s*<\/(?:A|font)>[^>]*?<\/td>\s*<td\s*class\=\"owner_value">\s*([\w\W]*?)\s*<\/td>/is);
		$mailaddress  = &clean( $mailaddress.' '.$1.$2) if($pcont =~ m/<td\s*class\=\"cell_header\">\&nbsp\;<\/td>\s*<td\s*class\=\"cell_value\">\s*([\w\W]*?)\s*<\/td>\s*<td\s*class\=\"cell_header\">\s*<font[^>]*?>\s*Tax\s*District\s*<\/font>|<td\s*class\=\"owner_header\">\s*\&nbsp\;\s*<\/td>\s*<td\s*class\=\"owner_value\">\s*([\w\W]*?)\s*<\/td>\s*<td\s*class\=\"owner_header\">\s*<[^>]*?>\s*Tax\s*District\s*<\/(?:A|font)>/is);
		
		my $locaddress  = &clean($1.$2) if($pcont =~ m/>\s*Location\s*Address\s*<\/font>[^>]*?<\/td>\s*<td\s*class\=\"cell_value\">\s*([\w\W]*?)\s*<\/td>|>\s*Location\s*Address\s*<\/(?:A|font)>[^>]*?<\/td>\s*<td\s*class\=\"owner_value">\s*([\w\W]*?)\s*<\/td>/is);
		my $pno  = &clean($1.$2) if($pcont =~ m/>\s*Parcel\s*Number\s*<\/font>[^>]*?<\/td>\s*<td\s*class\=\"cell_value\">\s*([\w\W]*?)\s*<\/td>|>\s*Parcel\s*Number\s*<\/(?:A|font)>[^>]*?<\/td>\s*<td\s*class\=\"owner_value">\s*([\w\W]*?)\s*<\/td>/is);
		my $ldesc  = &clean($1.$2) if($pcont =~ m/>\s*Legal\s*Description\s*<\/font>[^>]*?<\/td>\s*<td\s*class\=\"cell_value\"[^>]*?>\s*([\w\W]*?)\s*<\/td>|>\s*Legal\s*Description\s*<\/(?:A|font)>[^>]*?<\/td>\s*<td\s*class\=\"owner_value">\s*([\w\W]*?)\s*<\/td>/is);
		my ($tvalue, $c);
		while($pcont =~ m/class\=\"sales_value\"\s*align\=\"center\">\s*([\w\W]*?)\s*<\/td>/igs)
		{
			$c++;
			if($c == 6)
			{
				$tvalue = &clean($1);
			}
		}
		while($pcont =~ m/class\=\"tax_value\">([\w\W]*?)<\/td>/igs)
		{
			$c++;
			if($c == 4)
			{
				$tvalue = &clean($1);
			}
		}
		print "$count\t$name\n";
		open ss,">>$file_xls_name";
		print ss "$array[0]\t$array[1]\t$array[2]\t$array[3]\t$array[4]\t$array[5]\t$array[6]\t$array[7]\t$array[8]\t$array[9]\t$array[10]\t$array[11]\t$array[12]\t$name\t$mailaddress\t$locaddress\t$pno\t$ldesc\t$tvalue\t$purl\t$county\n";
		close ss;
	}
	else
	{
		print "$count\t$key\n";
		open ss,">>$file_xls_name";
		print ss "$array[0]\t$array[1]\t$array[2]\t$array[3]\t$array[4]\t$array[5]\t$array[6]\t$array[7]\t$array[8]\t$array[9]\t$array[10]\t$array[11]\t$array[12]\n";
		close ss;
	}

	
}
sub lwp_get() 
{ 
    my $urls = shift;
	$urls =~ s/amp\;//igs;
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
	$var=HTML::Entities::decode_entities($var);
	$var=~s/\s+/ /igs;
	$var=~s/^\s+|\s+$//igs;
	return ($var);
}
1;