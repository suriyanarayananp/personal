use strict;
use HTTP::Cookies;
use LWP::UserAgent;
use HTML::Entities;
use URI::Escape;
use Encode qw(encode);
my $ua = LWP::UserAgent->new(show_progress=>1);
$ua->agent("Mozilla/5.0 (Windows NT 6.1; WOW64; rv:35.0) Gecko/20100101 Firefox/35.0");
$ua->timeout(30);
my $cookie_file = "appext20_cookie.txt";
unlink($cookie_file);
my $cookie = HTTP::Cookies->new(file=>$cookie_file,autosave=>1);
$ua->cookie_jar($cookie);
my $count = 0;
my $req = HTTP::Request->new(GET=>"http://www.dos.ny.gov/corps/bus_entity_search.html");
$req->header("Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8");
$req->header("Content-Type"=>"application/x-www-form-urlencoded");
my $res = $ua->request($req);
$cookie->extract_cookies($res);
$cookie->save;
$cookie->add_cookie_header($req);
open LL,"input.txt";
while(<LL>)
{
	chomp;
	# my ($zip, $lat, $long, $city) = (split /\t/,$_);
	# print "Input:: $zip-> $lat -> $long\n";
	$req = HTTP::Request->new(POST=>"http://appext20.dos.ny.gov/corp_public/CORPSEARCH.SELECT_ENTITY");
	$req->header("Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8");
	$req->header("Content-Type"=>"application/x-www-form-urlencoded");
	$req->header("Referer"=>"http://www.dos.ny.gov/corps/bus_entity_search.html");
	$req->content("p_entity_name=$_&p_name_type=%25&p_search_type=BEGINS");
	$res = $ua->request($req);
	$cookie->extract_cookies($res);
	$cookie->save;
	$cookie->add_cookie_header($req);
	my $code = $res->code();
	print $code,"\n";
	my $content = $res->content();
	open SS,">test.html";
	print SS $content;
	close SS;
	# exit;
	while($content =~ m/<a\s*title\=\"Link\s*to\s*entity\s*information\.\" \s*[^>]*?href\=\"([^>]*?)\"/igs)
	{
		my $purl = &clean("http://appext20.dos.ny.gov/corp_public/".$1);
		$req = HTTP::Request->new(GET=>$purl);
		$req->header("Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8");
		$req->header("Content-Type"=>"application/x-www-form-urlencoded");
		my $res = $ua->request($req);
		$cookie->extract_cookies($res);
		$cookie->save;
		$cookie->add_cookie_header($req);
		my $code = $res->code();
		print $code,"\n";
		my $pcontent = $res->content();
		open SS,">test2.html";
		print SS $pcontent;
		close SS;
		exit;
		my $entityname = &clean($1) if($pcontent =~ m/>\s*Current\s*Entity\s*Name\:\s*<\/th>\s*<td>\s*([^>]*?)\s*<\/td>/is);
		my $entityname = &clean($1) if($pcontent =~ m/>\s*DOS\s*ID\s*\#\:\s*<\/th>\s*<td>\s*([^>]*?)\s*<\/td>/is);
		my $entityname = &clean($1) if($pcontent =~ m/>\s*Initial\s*DOS\s*Filing\s*Date\:\s*<\/th>\s*<td>\s*([^>]*?)\s*<\/td>/is);
		my $entityname = &clean($1) if($pcontent =~ m/>\s*County\:\s*<\/th>\s*<td>\s*([^>]*?)\s*<\/td>/is);
		my $entityname = &clean($1) if($pcontent =~ m/>\s*Jurisdiction\:\s*<\/th>\s*<td>\s*([^>]*?)\s*<\/td>/is);
		my $entityname = &clean($1) if($pcontent =~ m/>\s*Entity\s*Type\:\s*<\/th>\s*<td>\s*([^>]*?)\s*<\/td>/is);
		my $entityname = &clean($1) if($pcontent =~ m/>\s*Current\s*Entity\s*Status\:\s*<\/th>\s*<td>\s*([^>]*?)\s*<\/td>/is);
		$count++;
		print "$count -> $id -> $title -> $email\n";
		open ff,">>output.xls";
		print ff "$count\t$id\t$title\t$address\t$address2\t$city\t$state\t$zipcode\t$phone\t$website\t$email\n";
		close ff;
	}
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