use strict;
use HTTP::Cookies;
use LWP::UserAgent;
use LWP::Simple;
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
my $count = 0;
open ff,"input.txt";
while(<ff>)
{
	chomp;
	my $upc = $_;
	# my $upc = "027616216927";
	my $upcURL = "http://upctoasin.com/$upc";
	my $upcContent = &lwp_get($upcURL);
	open ss,">first.html";
	print ss $upcContent;
	close ss;
	# exit;
	if($upcContent =~ m/UPCNOTFOUND/is)
	{
		print "$upc -> No Asin\n";
		open ll,">>AmazonOutput.xls";
		print ll "$count\t$upc\n";
		close ll;
	}
	elsif($upcContent =~ m/^([^>]*?)$/is)
	{
		my $asin = $1;
		print "$upc -> $asin\n";
		my $amazonURL = "http://www.amazon.com/dp/".$asin;
		my $content = &lwp_get($amazonURL);
		open ss,">second.html";
		print ss $content;
		close ss;
		my $title = &clean($1) if($content =~ m/id\=\"productTitle\"[^>]*?>([\w\W]*?)<\/h1>/is);
		my $imageurl = &clean($1) if($content =~ m/data\-old\-hires\=\"([^>]*?)\"/is);
		getstore($imageurl,"./Images/$asin.jpg");
		open ll,">>AmazonOutput.xls";
		print ll "$count\t$upc\t$asin\t$title\t$imageurl\n";
		close ll;
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
	$var=~s/amp\;//igs;
	$var=~s/\&nbsp\;/ /igs;
	$var=decode_entities($var);
	$var=~s/\s+/ /igs;
	$var=~s/\'/\'\'/igs;
	return ($var);
}