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
my $filename ="Amazon";
my $cookie_file = $filename."_cookie.txt";
unlink($cookie_file);
my $cookie = HTTP::Cookies->new(file=>$cookie_file,autosave=>1);
$ua->cookie_jar($cookie);
my $count = 0;
print "Please Enter to run the script
	1. Choose Category Wise Search\n
	2. Choose Merchant Wise Search\n";
my $searchval = <STDIN>;
if($searchval == 1)
{
	my $baseurl = "http://www.amazon.com";
	my $content = &lwp_get($baseurl);
	open ff,">first.html";
	print ff $content;
	close ff;
	while($content =~ m/<option\s*value\=\"([^>]*?)\">\s*([^>]*?)\s*<\/option>/igs)
	{
		print "$1 -> $2\n";
	}
	
}
elsif($searchval == 2)
{
	open ff,"merchantinfo.txt";
	my (%merchanthash, %idhash, $mecount);
	# Load Input into Hash
	while(<ff>)
	{
		chomp;
		my ($id, $val) = (split/\t/,$_);
		$mecount++;
		$merchanthash{$mecount} = $id;
		$idhash{$id} = $val;
	}
	close ff;
	# print all Input
	print "ID  => Merchant ID -> Merchant Name\n";
	foreach (keys %merchanthash)
	{
		print "$_   => $merchanthash{$_} -> $idhash{$merchanthash{$_}}\n";
	}
	print "Please enter your merchant id :  ";
	my $input = <STDIN>;
	chomp($input);
	my $merchanturl = "http://www.amazon.com/gp/aag/main?ie=UTF8&seller=$merchanthash{$input}";
	my $content = &lwp_get($merchanturl);
	open ff,">second.html";
	print ff $content;
	close ff;
	while($content =~ m/<option\s*value\=\"([^>]*?)\">\s*([^>]*?)\s*<\/option>/igs)
	{
		print "$1 -> $2\n";
	}
	
}

sub clean()
{
	my $string=shift;
	$string=~s/<[^>]*?>/ /igs;
	$string=~s/amp\;//igs;
	$string=~s/\&nbsp\;/ /igs;
	$string=~s/\s+/ /igs;
	$string=decode_entities($string);;
	$string=~s/^\s+|\s+$//igs;
	return($string);
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
        sleep 1; 
        goto REPEAT; 
    } 
    return($res->content()); 
}