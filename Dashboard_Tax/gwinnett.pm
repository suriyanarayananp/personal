package gwinnett;
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
$ua->agent("Mozilla/5.0 (Windows NT 6.1; WOW64; rv:33.0) Gecko/20100101 Firefox/33.0");
$ua->timeout(30);
$ua->cookie_jar({});
my $date = DateTime->now->ymd;
$date =~ s/\-//igs;
my $filename ="gwinnett";
my $cookie_file = $filename."_cookie.txt";
unlink($cookie_file);
my $cookie = HTTP::Cookies->new(file=>$cookie_file,autosave=>1);
$ua->cookie_jar($cookie);

sub scrape()
{
	my $keys = shift;
	my $county = shift;
	my $arrayref = shift;
	my $NameFlag = shift;
	my @array = @$arrayref;
	print "From Gwin :: $keys->$county\n\n";
	my $file_xls_name = "output_".$county.".xls";
	# open ff,">$file_xls_name";
	# print ff "Source_File_Date\tSource_Sale_Date\tSource_Case_Nbr\tSource_Owner_Name\tSpacer\tSource_SITUS_Full_Address_FORMULA\tSource_Situs_Abbreviated_Address\tSource_Situs_Address\tSource_Situs_City\tSource_Situs_Zip\tSource_Situs_County\tSource_Situs_Status\tSource_From_Origin\tOWNER NAME\tADDRESS\tSITUS ADDRESS\tPARCEL ID\tLEGAL DESCRIPTION\tTOTAL MARKET VALUE\tURL\n";
	# close ff;
	sleep 10;
	# print "$keys\n\n";
	my $postcont;
	if($NameFlag eq 'Y')
	{
		$postcont = "-----------------------------265962991127782
Content-Disposition: form-data; name=\"__EVENTTARGET\"


-----------------------------265962991127782
Content-Disposition: form-data; name=\"__EVENTARGUMENT\"


-----------------------------265962991127782
Content-Disposition: form-data; name=\"__VIEWSTATE\"

/wEPDwUKMTA1MjU0NzA5MA9kFgZmDxYCHgRUZXh0BXk8IURPQ1RZUEUgaHRtbCBQVUJMSUMgIi0vL1czQy8vRFREIFhIVE1MIDEuMCBUcmFuc2l0aW9uYWwvL0VOIiAiaHR0cDovL3d3dy53My5vcmcvVFIveGh0bWwxL0RURC94aHRtbDEtdHJhbnNpdGlvbmFsLmR0ZCI+ZAIBD2QWDAIBDxYCHgdWaXNpYmxlaGQCAg8WAh4HY29udGVudAVwUmljaGFyZCBTdGVlbGUsIFRheCBDb21taXNzaW9uZXI7IDc1IExhbmdsZXkgRHJpdmUsIExhd3JlbmNldmlsbGUsIEdBIDMwMDQ2OyB0YXhjb21taXNzaW9uZXJAZ3dpbm5ldHRjb3VudHkuY29tIGQCAw8WAh8CBS9SaWNoYXJkIFN0ZWVsZSBHd2lubmV0dCBDb3VudHkgVGF4IENvbW1pc3Npb25lcmQCBA8WAh8CBR5Db3B5cmlnaHQgMjAxNCBUaG9tc29uIFJldXRlcnNkAgUPFgQfAmQfAWhkAgYPFgIfAgUvUmljaGFyZCBTdGVlbGUgR3dpbm5ldHQgQ291bnR5IFRheCBDb21taXNzaW9uZXJkAgIPZBYCAgEPZBYCAgQPZBYCZg9kFhBmD2QWAmYPDxYEHgdUb29sVGlwBS9SaWNoYXJkIFN0ZWVsZSBHd2lubmV0dCBDb3VudHkgVGF4IENvbW1pc3Npb25lch4LTmF2aWdhdGVVcmwFOGh0dHA6Ly9nd2lubmV0dHRheGNvbW1pc3Npb25lci5tYW5hdHJvbi5jb20vRGVmYXVsdC5hc3B4ZGQCAw8WAh8BZxYCAgEPZBYCZg9kFgICAQ9kFgICAQ9kFgICAg8WAh8BaGQCBA8WAh8BZxYIAgEPZBYEZg9kFgYCAQ8QDxYKHghDc3NDbGFzcwUGc2VhcmNoHwAFA1dlYh8DBRFHb29nbGUgV2ViIFNlYXJjaB4EXyFTQgICHwFoZGRkZAIDDxAPFgofBQUGc2VhcmNoHwAFBFNpdGUfAwULU2l0ZSBTZWFyY2gfBgICHwFoZGRkZAIHDw8WBh8FBQZzZWFyY2gfAAUhPHNwYW4gY2xhc3M9J3NlYXJjaENtZCc+wqA8L3NwYW4+HwYCAmRkAgIPZBYEZg8PFgIeDUFsdGVybmF0ZVRl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
-----------------------------265962991127782
Content-Disposition: form-data; name=\"__VIEWSTATEGENERATOR\"

CA0B0334
-----------------------------265962991127782
Content-Disposition: form-data; name=\"dnn\$dnnSEARCH\$txtSearch\"


-----------------------------265962991127782
Content-Disposition: form-data; name=\"selSearchBy\"

Column2%
-----------------------------265962991127782
Content-Disposition: form-data; name=\"fldInput\"

$keys
-----------------------------265962991127782
Content-Disposition: form-data; name=\"btnsearch\"

search
-----------------------------265962991127782
Content-Disposition: form-data; name=\"ScrollTop\"


-----------------------------265962991127782
Content-Disposition: form-data; name=\"__dnnVariable\"


-----------------------------265962991127782--";
	}
	else
	{
	$postcont = "-----------------------------265962991127782
Content-Disposition: form-data; name=\"__EVENTTARGET\"


-----------------------------265962991127782
Content-Disposition: form-data; name=\"__EVENTARGUMENT\"


-----------------------------265962991127782
Content-Disposition: form-data; name=\"__VIEWSTATE\"

/wEPDwUKMTA1MjU0NzA5MA9kFgZmDxYCHgRUZXh0BXk8IURPQ1RZUEUgaHRtbCBQVUJMSUMgIi0vL1czQy8vRFREIFhIVE1MIDEuMCBUcmFuc2l0aW9uYWwvL0VOIiAiaHR0cDovL3d3dy53My5vcmcvVFIveGh0bWwxL0RURC94aHRtbDEtdHJhbnNpdGlvbmFsLmR0ZCI+ZAIBD2QWDAIBDxYCHgdWaXNpYmxlaGQCAg8WAh4HY29udGVudAVwUmljaGFyZCBTdGVlbGUsIFRheCBDb21taXNzaW9uZXI7IDc1IExhbmdsZXkgRHJpdmUsIExhd3JlbmNldmlsbGUsIEdBIDMwMDQ2OyB0YXhjb21taXNzaW9uZXJAZ3dpbm5ldHRjb3VudHkuY29tIGQCAw8WAh8CBS9SaWNoYXJkIFN0ZWVsZSBHd2lubmV0dCBDb3VudHkgVGF4IENvbW1pc3Npb25lcmQCBA8WAh8CBR5Db3B5cmlnaHQgMjAxNCBUaG9tc29uIFJldXRlcnNkAgUPFgQfAmQfAWhkAgYPFgIfAgUvUmljaGFyZCBTdGVlbGUgR3dpbm5ldHQgQ291bnR5IFRheCBDb21taXNzaW9uZXJkAgIPZBYCAgEPZBYCAgQPZBYCZg9kFhBmD2QWAmYPDxYEHgdUb29sVGlwBS9SaWNoYXJkIFN0ZWVsZSBHd2lubmV0dCBDb3VudHkgVGF4IENvbW1pc3Npb25lch4LTmF2aWdhdGVVcmwFOGh0dHA6Ly9nd2lubmV0dHRheGNvbW1pc3Npb25lci5tYW5hdHJvbi5jb20vRGVmYXVsdC5hc3B4ZGQCAw8WAh8BZxYCAgEPZBYCZg9kFgICAQ9kFgICAQ9kFgICAg8WAh8BaGQCBA8WAh8BZxYIAgEPZBYEZg9kFgYCAQ8QDxYKHghDc3NDbGFzcwUGc2VhcmNoHwAFA1dlYh8DBRFHb29nbGUgV2ViIFNlYXJjaB4EXyFTQgICHwFoZGRkZAIDDxAPFgofBQUGc2VhcmNoHwAFBFNpdGUfAwULU2l0ZSBTZWFyY2gfBgICHwFoZGRkZAIHDw8WBh8FBQZzZWFyY2gfAAUhPHNwYW4gY2xhc3M9J3NlYXJjaENtZCc+wqA8L3NwYW4+HwYCAmRkAgIPZBYEZg8PFgIeDUFsdGVybmF0ZVRl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
-----------------------------265962991127782
Content-Disposition: form-data; name=\"__VIEWSTATEGENERATOR\"

CA0B0334
-----------------------------265962991127782
Content-Disposition: form-data; name=\"dnn\$dnnSEARCH\$txtSearch\"


-----------------------------265962991127782
Content-Disposition: form-data; name=\"selSearchBy\"

Column4*
-----------------------------265962991127782
Content-Disposition: form-data; name=\"fldInput\"

$keys
-----------------------------265962991127782
Content-Disposition: form-data; name=\"btnsearch\"

search
-----------------------------265962991127782
Content-Disposition: form-data; name=\"ScrollTop\"


-----------------------------265962991127782
Content-Disposition: form-data; name=\"__dnnVariable\"


-----------------------------265962991127782--";
}
	my $url = "http://gwinnetttaxcommissioner.manatron.com/Tabs/ViewPayYourTaxes.aspx";
	Repeat2:
	my $req = HTTP::Request->new(POST=>$url); 
	$req->header("Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"); 
	$req->header("Content-Type"=>"multipart/form-data; boundary=---------------------------265962991127782");
	$req->content("$postcont");
	my $res = $ua->request($req); 
	$cookie->extract_cookies($res); 
	$cookie->save; 
	$cookie->add_cookie_header($req); 
	my $code = $res->code();
	if($code =~ m/50/is)
	{
		sleep 100;
		goto Repeat2;
	}
	my $content = $res->content();
	# open ll,">gwin.html";
	# print ll $content;
	# close ll;
	# exit;
	if($content =~ m/<tr\s*p\=\"([^>]*?)\"\s*a\=\"([^>]*?)\">\s*<td\s*class\=[^>]*?>\s*([^>]*?)\s*<\/td>\s*<td\s*class[^>]*?>([\w\W]*?)<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>/is)
	{
		# while($content =~ m/<tr\s*p\=\"([^>]*?)\"\s*a\=\"([^>]*?)\">\s*<td\s*class\=[^>]*?>\s*([^>]*?)\s*<\/td>\s*<td\s*class[^>]*?>([\w\W]*?)<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td>/igs)
		# {
			my $p= &clean($1);
			my $a= &clean($2);
			my $name = &clean($3);
			my $address = &clean($4);
			my $situsaddress = &clean($5);
			my $parcelid= &clean($6);
			my $purl = "http://gwinnetttaxcommissioner.manatron.com/Tabs/ViewPayYourTaxes/AccountDetail.aspx?p=$p&a=$a";
			my $burl = "http://gwinnetttaxcommissioner.manatron.com/Tabs/ViewPayYourTaxes/AccountDetail/BillDetail.aspx?p=$p&a=$a";
			Repeat3:
			$req = HTTP::Request->new(GET=>$burl ); 
			$req->header("Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"); 
			$res = $ua->request($req); 
			$cookie->extract_cookies($res); 
			$cookie->save; 
			$cookie->add_cookie_header($req); 
			my $code = $res->code();
			print "Code:: $code\n";
			if($code =~ m/50/is)
			{
				sleep 100;
				goto Repeat3;
			}
			my $tcontent = $res->content();
			# open ss,">test2.html";
			# print ss $tcontent;
			# close ss;
			print "$. -> $keys -> $p\n";
			my $legaldesc = &clean($1) if($tcontent =~ m/>\s*Legal\s*Description<\/th>\s*<\/tr>\s*<tr>\s*<[^>]*?>\s*([^>]*?)\s*<\/td>/is);
			my $totalmkvalue = &clean($1) if($tcontent =~ m/>\s*Total\s*<\/td>\s*<td[^>]*?>\s*([^>]*?)\s*<\/td> /is);
			open ff,">>$file_xls_name";
			print ff "$array[0]\t$array[1]\t$array[2]\t$array[3]\t$array[4]\t$array[5]\t$array[6]\t$array[7]\t$array[8]\t$array[9]\t$array[10]\t$array[11]\t$array[12]\t$name\t$address\t$situsaddress\t$parcelid\t$legaldesc\t$totalmkvalue\t$purl\n";
			close ff;
		# }
	}
	else
	{
		print "No Record Found\n";
		open ff,">>$file_xls_name";
		print ff "$keys\n";
		close ff;
		next;
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
1;