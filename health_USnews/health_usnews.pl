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
my $url = "http://health.usnews.com/doctors/specialists-index?int=a65d09";
my $content = &lwp_get($url);
open OO,">test.html";
print OO $content;
close OO;
# exit;
while($content =~ m/href\=\"([^>]*?)\">\s*([^>]*?)\s*\(/igs)
{
	my $link = "http://health.usnews.com/".$1;
	my $cat1 = &clean($2);
	my $lcontent = &lwp_get($link);
	while($lcontent =~ m/href\=\"([^>]*?)\">\s*([^>]*?)\s*\([^>]*?<\/a>\s*<\/h2>/igs)
	{
		my $link2 = "http://health.usnews.com/".$1;
		my $cat2 = &clean($2);
		my $lcontent2 = &lwp_get($link2);
		while($lcontent2 =~ m/href\=\"([^>]*?)\">\s*([^>]*?)\s*\(/igs)
		{
			my $link3 = "http://health.usnews.com/".$1;
			my $cat3 = &clean($2);
			my $lcontent3 = &lwp_get($link3);
			while($lcontent3 =~ m/class\=\"h\-flush\">\s*<a\s*href\=\"([^>]*?)\"/igs)
			{
				my $link4 = "http://health.usnews.com/".$1;
				my $cat4 = &clean($2);
				my $pcontent = &lwp_get($link4);
				my ($title, $first, $middle, $last);
				if($pcontent =~ m/class\=\"h\-bigger\s*h\-flush\">\s*([^>]*?)\s+([^>]*?)\s+([^>]*?)\s+([^>]*?)\s*</is)
				{	
					$title = &clean($1);
					$first = &clean($2);
					$middle = &clean($3);
					$last = &clean($4);
				}
				my ($address1, $address2, $city, $state, $zipcode);
				if($pcontent =~ m/class\=\"t\-slackest\">\s*([^>]*?)\s*<br\s*\/>\s*(?:([^>]*?)\s*<br\s*\/>)?\s*([^>]*?)\,\s*([A-Z]{2})\s+([0-9]{5})\s*</is)
				{
					$address1 = &clean($1);
					$address2 = &clean($2);
					$city = &clean($3);
					$state = &clean($4);
					$zipcode = &clean($5);
				}
				my $phone = &clean($1) if($pcontent =~ m/>\s*Phone\:\s*([^>]*?)\s*<br\s*\/>/is);
				my $fax = &clean($1) if($pcontent =~ m/>\s*Fax\:\s*([^>]*?)\s*<br\s*\/>/is);
				my $specialty = &clean($1) if($pcontent =~ m/>\s*Specialty\:\s*<\/span>\s*<a[^>]*?>\s*([^>]*?)\s*<\/a>/is);
				my $subspecialty = &clean($1) if($pcontent =~ m/>\s*Subspecialties\:\s*<\/span>\s*([^>]*?)\s*<\/p>/is);
				my $clinical = &clean($1) if($pcontent =~ m/>\s*Clinical\s*Interests\:\s*<\/span>\s*([^>]*?)\s*<\/p>/is);
				# $subspecialty =~ s/,/\t/igs;
				# $clinical =~ s/,/\t/igs;
				$count++;
				print "$count -> $first -> $city\n";
				open ff,">>doctor_output.xls";
				print ff "$count\t$cat1 -> $cat2 -> $cat3 -> $cat4\t$link4\t$title\t$first\t$middle\t$last\t$address1\t$address2\t$city\t$state\t$zipcode\t$phone\t$fax\t$specialty\t$subspecialty\t$clinical\n";
				close ff;
			}
			# exit;
		}
	}
	
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