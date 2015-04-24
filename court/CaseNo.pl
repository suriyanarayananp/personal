use strict;
use HTTP::Cookies;
use LWP::UserAgent;
use LWP::Simple;
use HTML::Entities;
use URI::Escape;
use Encode qw(encode);
my $ua = LWP::UserAgent->new(show_progress=>1);
$ua->agent("Mozilla/5.0 (Windows NT 6.2; WOW64; rv:37.0) Gecko/20100101 Firefox/37.0");
$ua->timeout(30);
$ua->cookie_jar({});
my $filename ="case";
my $cookie_file = $filename."_cookie.txt";
unlink($cookie_file);
my $cookie = HTTP::Cookies->new(autosave=>1);
$ua->cookie_jar($cookie);
my $count = 0;
open ss,"input.txt";
while(<ss>)
{
	chomp;
	my $caseno = $_;
	my $norecord = 0;
	my $url = "http://web.jp.hctx.net/CaseInfo/GetCaseInfo?case=$caseno";
	my $content = &lwp_get($url);
	open ll,">first.html";
	print ll $content;
	close ll;
	# exit;
	while($content =~ m/>\s*Filing\s*Description\:\s*<\/span>\s*<span[^>]*?>\s*([^>]*?)\s*<\/span>\s*<br\s*\/>\s*<span[^>]*?>\s*Date\s*Added\s*\:\s*<\/span>\s*<span[^>]*?>\s*([^>]*?)\s*<\/span>/igs)
	{
		print "Here \n";
		my $val = $1;
		my $val2 = $2;
		if($val =~ m/Abstract/is)
		{
			open ff,">>output.xls";
			print ff "$caseno\ty\ty\t$val2\n";
			close ff;
			print "Mattched \n";
			$norecord = 1;
		}
	}
	if($norecord == 0)
	{
		open ff,">>output.xls";
		print ff "$caseno\tn\t\t\n";
		close ff;
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