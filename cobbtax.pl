use strict;
use HTTP::Cookies;
use LWP::UserAgent;
use HTML::Entities;
use URI::Escape;
use LWP::Simple;
use Encode qw(encode);
my $ua = LWP::UserAgent->new(show_progress=>1);
$ua->agent("Mozilla/5.0 (Windows NT 6.2; WOW64; rv:35.0) Gecko/20100101 Firefox/35.0");
$ua->timeout(30);
$ua->cookie_jar({});
my $filename ="cobbtax";
my $cookie_file = $filename."_cookie.txt";
unlink($cookie_file);
my $cookie = HTTP::Cookies->new(file=>$cookie_file,autosave=>1);
$ua->cookie_jar($cookie);
my $url='http://www.cobbtax.org/taxes/default.aspx';
my @arry;
@arry=("1827+Brackendale","2000+MULKEY","2400+CATAMARAN","2504+SUTTER");
my $cont1="__EVENTTARGET=&__EVENTARGUMENT=&__VIEWSTATE=";
my $cont2="%2FwEPDwUENTM4MQ9kFgJmD2QWAgIEDxYCHgZhY3Rpb24FEy90YXhlcy9kZWZhdWx0LmFzcHgWCgIBD2QWDAINDxBkZBYAZAIPD2QWAgIBDxBkZBYAZAIfD2QWAgIBD2QWAgIBDxBkZBYAZAIhD2QWAgIBD2QWAgIBDxBkZBYAZAIrDzwrABECARAWABYAFgAMFCsAAGQCNw88KwARAgEQFgAWABYADBQrAABkAgMPDxYEHghlZGl0TW9kZQspXUJhc2VDb250cm9sK0VkaXRNb2RlLCBBcHBfV2ViX2dpazJ0dDR3LCBWZXJzaW9uPTAuMC4wLjAsIEN1bHR1cmU9bmV1dHJhbCwgUHVibGljS2V5VG9rZW49bnVsbAAeB1Zpc2libGVoZBYIZg8PFgIfAmhkFgYCAQ8WAh4Dc3JjBSAvaW1hZ2VzL3NrZWxldG9uL2FjdGlvbnNNZW51LmdpZmQCBw8QZGQWAWZkAgkPD2QWAh4Hb25jbGljawU%2FcmV0dXJuIGNvbmZpcm0oJ0FyZSB5b3Ugc3VyZSB5b3Ugd2FudCB0byBkZWxldGUgdGhpcyBtb2R1bGU%2FJyk7ZAIFDw8WAh8CaGQWAgIBDxYCHgtfIUl0ZW1Db3VudGZkAgcPDxYCHwJoZBYCAgEPFgIfBWZkAgkPDxYCHwJoZBYCAgEPFgIfBWZkAgQPDxYCHgRUZXh0BRhUQVggU0VBUkNILCBWSUVXIEFORCBQQVlkZAIFDw8WAh8GBVQ8YSBocmVmPScvJz5Ib21lPC9hPiZuYnNwOyZyYXF1bzsmbmJzcDs8YSBocmVmPScvdGF4ZXMnPlRheCBTZWFyY2gsIFZpZXcgYW5kIFBheTwvYT5kZAIGD2QWBAIBD2QWBmYPZBYEAgcPEGRkFgFmZAIJDw9kFgIfBAU%2FcmV0dXJuIGNvbmZpcm0oJ0FyZSB5b3Ugc3VyZSB5b3Ugd2FudCB0byBkZWxldGUgdGhpcyBtb2R1bGU%2FJyk7ZAIEDxYCHwZlZAIGDw8WAh8CaGRkAgIPDxYEHwELKwQAHgRjYXJ0MsQNAAEAAAD%2F%2F%2F%2F%2FAQAAAAAAAAAMAgAAAE5TeXN0ZW0uRGF0YSwgVmVyc2lvbj00LjAuMC4wLCBDdWx0dXJlPW5ldXRyYWwsIFB1YmxpY0tleVRva2VuPWI3N2E1YzU2MTkzNGUwODkFAQAAABVTeXN0ZW0uRGF0YS5EYXRhVGFibGUDAAAAGURhdGFUYWJsZS5SZW1vdGluZ1ZlcnNpb24JWG1sU2NoZW1hC1htbERpZmZHcmFtAwEBDlN5c3RlbS5WZXJzaW9uAgAAAAkDAAAABgQAAACXCjw%2FeG1sIHZlcnNpb249IjEuMCIgZW5jb2Rpbmc9InV0Zi0xNiI%2FPg0KPHhzOnNjaGVtYSB4bWxucz0iIiB4bWxuczp4cz0iaHR0cDovL3d3dy53My5vcmcvMjAwMS9YTUxTY2hlbWEiIHhtbG5zOm1zZGF0YT0idXJuOnNjaGVtYXMtbWljcm9zb2Z0LWNvbTp4bWwtbXNkYXRhIj4NCiAgPHhzOmVsZW1lbnQgbmFtZT0iVGFibGUxIj4NCiAgICA8eHM6Y29tcGxleFR5cGU%2BDQogICAgICA8eHM6c2VxdWVuY2U%2BDQogICAgICAgIDx4czplbGVtZW50IG5hbWU9Im5hbWUiIHR5cGU9InhzOnN0cmluZyIgbXNkYXRhOnRhcmdldE5hbWVzcGFjZT0iIiBtaW5PY2N1cnM9IjAiIC8%2BDQogICAgICAgIDx4czplbGVtZW50IG5hbWU9InRheFllYXIiIHR5cGU9InhzOnN0cmluZyIgbXNkYXRhOnRhcmdldE5hbWVzcGFjZT0iIiAvPg0KICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJyb2xsVHlwZSIgdHlwZT0ieHM6c3RyaW5nIiBtc2RhdGE6dGFyZ2V0TmFtZXNwYWNlPSIiIC8%2BDQogICAgICAgIDx4czplbGVtZW50IG5hbWU9InBhcmNlbElEIiB0eXBlPSJ4czpzdHJpbmciIG1zZGF0YTp0YXJnZXROYW1lc3BhY2U9IiIgLz4NCiAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iYW1vdW50IiB0eXBlPSJ4czpkb3VibGUiIG1zZGF0YTp0YXJnZXROYW1lc3BhY2U9IiIgbWluT2NjdXJzPSIwIiAvPg0KICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJwcmV2WWVhciIgdHlwZT0ieHM6Ym9vbGVhbiIgbXNkYXRhOnRhcmdldE5hbWVzcGFjZT0iIiBtaW5PY2N1cnM9IjAiIC8%2BDQogICAgICA8L3hzOnNlcXVlbmNlPg0KICAgIDwveHM6Y29tcGxleFR5cGU%2BDQogIDwveHM6ZWxlbWVudD4NCiAgPHhzOmVsZW1lbnQgbmFtZT0idG1wRGF0YVNldCIgbXNkYXRhOklzRGF0YVNldD0idHJ1ZSIgbXNkYXRhOk1haW5EYXRhVGFibGU9IlRhYmxlMSIgbXNkYXRhOlVzZUN1cnJlbnRMb2NhbGU9InRydWUiPg0KICAgIDx4czpjb21wbGV4VHlwZT4NCiAgICAgIDx4czpjaG9pY2UgbWluT2NjdXJzPSIwIiBtYXhPY2N1cnM9InVuYm91bmRlZCIgLz4NCiAgICA8L3hzOmNvbXBsZXhUeXBlPg0KICAgIDx4czp1bmlxdWUgbmFtZT0idW5pcXVlIiBtc2RhdGE6UHJpbWFyeUtleT0idHJ1ZSI%2BDQogICAgICA8eHM6c2VsZWN0b3IgeHBhdGg9Ii4vL1RhYmxlMSIgLz4NCiAgICAgIDx4czpmaWVsZCB4cGF0aD0idGF4WWVhciIgLz4NCiAgICAgIDx4czpmaWVsZCB4cGF0aD0icm9sbFR5cGUiIC8%2BDQogICAgICA8eHM6ZmllbGQgeHBhdGg9InBhcmNlbElEIiAvPg0KICAgIDwveHM6dW5pcXVlPg0KICA8L3hzOmVsZW1lbnQ%2BDQo8L3hzOnNjaGVtYT4GBQAAAIABPGRpZmZncjpkaWZmZ3JhbSB4bWxuczptc2RhdGE9InVybjpzY2hlbWFzLW1pY3Jvc29mdC1jb206eG1sLW1zZGF0YSIgeG1sbnM6ZGlmZmdyPSJ1cm46c2NoZW1hcy1taWNyb3NvZnQtY29tOnhtbC1kaWZmZ3JhbS12MSIgLz4EAwAAAA5TeXN0ZW0uVmVyc2lvbgQAAAAGX01ham9yBl9NaW5vcgZfQnVpbGQJX1JldmlzaW9uAAAAAAgICAgCAAAAAAAAAP%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FC2QWCGYPZBYGAgEPFgIfAwUgL2ltYWdlcy9za2VsZXRvbi9hY3Rpb25zTWVudS5naWZkAgcPEA8WAh4LXyFEYXRhQm91bmRnZGQWAWZkAgkPD2QWAh8EBT9yZXR1cm4gY29uZmlybSgnQXJlIHlvdSBzdXJlIHlvdSB3YW50IHRvIGRlbGV0ZSB0aGlzIG1vZHVsZT8nKTtkAgcPDxYCHwJoZBYCZg8VAgtDb2JiIENvdW50eQtDb2JiIENvdW50eWQCCQ8PFgIfAmdkFggCAQ8QDxYCHwhnZBAVFglBbGwgWWVhcnMEMjAxNQQyMDE0BDIwMTMEMjAxMgQyMDExBDIwMTAEMjAwOQQyMDA4BDIwMDcEMjAwNgQyMDA1BDIwMDQEMjAwMwQyMDAyBDIwMDEEMjAwMAQxOTk5BDE5OTgEMTk5NwQxOTk2BDE5OTUVFglBbGwgWWVhcnMEMjAxNQQyMDE0BDIwMTMEMjAxMgQyMDExBDIwMTAEMjAwOQQyMDA4BDIwMDcEMjAwNgQyMDA1BDIwMDQEMjAwMwQyMDAyBDIwMDEEMjAwMAQxOTk5BDE5OTgEMTk5NwQxOTk2BDE5OTUUKwMWZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2RkAgMPEA8WAh8IZ2RkZGQCBQ8QDxYCHwhnZGRkZAIPDzwrABEDAA8WBB8IZx8FZmQBEBYAFgAWAAwUKwAAZAILD2QWCAIBD2QWBGYPZBYCZg9kFgICAQ9kFgJmD2QWBgIZDxYCHgV2YWx1ZQUWVmlldyBDYXJ0L0NoZWNrb3V0ICgwKWQCHw9kFgICAw8WAh8FAv%2F%2F%2F%2F8PZAJBDzwrABEDAA8WBB8IZx8FZmQBEBYAFgAWAAwUKwAAZAIED2QWAmYPZBYCAgEPZBYCZg9kFgRmDxUBC0NvYmIgQ291bnR5ZAIZDxAPFgIfCGdkEBU7AkFMAkFLAkFTAkFaAkFSAkNBAkNPAkNUAkRFAkRDAkZNAkZMAkdBAkdVAkhJAklEAklMAklOAklBAktTAktZAkxBAk1FAk1IAk1EAk1BAk1JAk1OAk1TAk1PAk1UAk5FAk5WAk5IAk5KAk5NAk5ZAk5DAk5EAk1QAk9IAk9LAk9SAlBXAlBBAlBSAlJJAlNDAlNEAlROAlRYAlVUAlZUAlZJAlZBAldBAldWAldJAldZFTsCQUwCQUsCQVMCQVoCQVICQ0ECQ08CQ1QCREUCREMCRk0CRkwCR0ECR1UCSEkCSUQCSUwCSU4CSUECS1MCS1kCTEECTUUCTUgCTUQCTUECTUkCTU4CTVMCTU8CTVQCTkUCTlYCTkgCTkoCTk0CTlkCTkMCTkQCTVACT0gCT0sCT1ICUFcCUEECUFICUkkCU0MCU0QCVE4CVFgCVVQCVlQCVkkCVkECV0ECV1YCV0kCV1kUKwM7Z2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2cWAWZkAgUPPCsAEQMADxYEHwhnHwVmZAEQFgAWABYADBQrAABkAgcPDxYCHwJoZGQCEQ88KwARAwAPFgQfCGcfBWZkARAWABYAFgAMFCsAAGQYBwUtY3RsMDAkY3BoTWFpbkNvbnRlbnQkU2tlbGV0b25DdHJsXzI3JHRiY1RheGVzDw9kZmQFG2N0bDAwJENvbnRyb2xQYW5lbDEkZ3ZMaW5rcw9nZAUaY3RsMDAkQ29udHJvbFBhbmVsMSRndkRvY3MPZ2QFMGN0bDAwJGNwaE1haW5Db250ZW50JFNrZWxldG9uQ3RybF8yNyRndkNhcnRJdGVtcw88KwAMAQhmZAVIY3RsMDAkY3BoTWFpbkNvbnRlbnQkU2tlbGV0b25DdHJsXzI3JHRiY1RheGVzJHRiT3ZlcnZpZXckZ3ZKdXJpc2RpY3Rpb25zDzwrAAwBCGZkBS5jdGwwMCRjcGhNYWluQ29udGVudCRTa2VsZXRvbkN0cmxfMjckZ3ZSZWNvcmRzDzwrAAwCBhUFDGp1cmlzZGljdGlvbgd0YXhZZWFyCHJvbGxUeXBlCHBhcmNlbElECnJlY29yZFR5cGUIZmQFLWN0bDAwJGNwaE1haW5Db250ZW50JFNrZWxldG9uQ3RybF8yNyRndlVuUGFpZA88KwAMAgYVAQRBUkVDCGZkAyBdGjazDIOfhePuPidmiC8YyFH88KC9hzjnw1ubYZI%3D";
# my $cont3="&&ctl00%24cphMainContent%24SkeletonCtrl_27%24drpTaxYear=All+Years&ctl00%24cphMainContent%24SkeletonCtrl_27%24drpStatus=All&ctl00%24cphMainContent%24SkeletonCtrl_27%24drpSearchParam=Property+Address&ctl00%24cphMainContent%24SkeletonCtrl_27%24txtSearchParam="; 
my $cont3="&&ctl00%24cphMainContent%24SkeletonCtrl_27%24drpTaxYear=2014&ctl00%24cphMainContent%24SkeletonCtrl_27%24drpStatus=All&ctl00%24cphMainContent%24SkeletonCtrl_27%24drpSearchParam=Property+Address&ctl00%24cphMainContent%24SkeletonCtrl_27%24txtSearchParam="; 
foreach(@arry)
{
	my $value=$_;
	my $view="ctl00%24cphMainContent%24SkeletonCtrl_27%24btnSearch=Search";
	my $cont4=$cont1.$cont2.$cont3.$value."&".$view;
	print"value::$value\n";
	my $content1=&post_content($url,$cont4);
	my ($year,$view);
	while($content1=~m/width[^>]*?>([\d+]*?)<\/td>[^^]*?name\=\"([^>]*?)\"/igs)
	{
		$year=$1;
		$view=$2;
	}
	print"year::$year\n";
	$view=uri_escape($view);
	print"view::$view\n";
	$cont2=uri_escape($1) if($content1=~m/VIEWSTATE\"\s*value\=\"([^>]*?)\"/is);
	my $cont5=$cont1.$cont2.$cont3.$value."&".$view."=View";
	my $content= &post_content($url,$cont5);
	while($content=~m/<div\s*class\=\"section\s*mobileSection\">([\w\W]*?)<\/div>/igs)
	{
		my $owner = &clean($1) if($content =~ m/_lblOwnerName\">\s*([^>]*?)\s*</is);
		my($address, $city, $state, $zipcode);
		if($content =~ m/_lblOwnerAddr\">\s*([^>]*?)\s*<br>\s*([^>]*?)\s*\,\s+([A-Z]{2})\s+([^>]*?)\s*</is)
		{
			$address = &clean($1);
			$city = &clean($2);
			$state = &clean($3);
			$zipcode = &clean($4);
		}
		my $taxyear = &clean($1) if($content =~ m/_lblTaxYear\">\s*([^>]*?)\s*</is);
		my $duedate = &clean($1) if($content =~ m/_lblDueDate\">\s*([^>]*?)\s*</is);
		my $paystatus = &clean($1) if($content =~ m/_lblPaymentStatus\"[^>]*?>\s*([^>]*?)\s*</is);
		my $paidamt = &clean($1) if($content =~ m/_lblPaidAmount\"[^>]*?>\s*([^>]*?)\s*</is);
		my $datepaid = &clean($1) if($content =~ m/_lblDatePaid\"[^>]*?>\s*([^>]*?)\s*</is);
		my $totaldue = &clean($1) if($content =~ m/_lblTotalDue\"[^>]*?>\s*([^>]*?)\s*</is);
		my $parcelno = &clean($1) if($content =~ m/\bpin\=([^>]*?)\"/is);
		my $fairvalue = &clean($1) if($content =~ m/_lblFairMarketValue\"[^>]*?>\s*([^>]*?)\s*</is);
		
	}	
}
sub get_content()
{
 my $url = shift;
 my $rerun_count=0;
 $url =~ s/^\s+|\s+$//g;
 Home:
 my $req = HTTP::Request->new(GET=>$url);
 $req->header("Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8");
 $req->header("Content-Type"=> "text/plain");
 $req->header("DNT"=>"1"); 
$req->header("HOST"=>"www.cobbtax.org"); 
$req->header("Cookie"=>"172939825.139902089.1421786675.1421786675.1421786675.1; __utmb=172939825.16.10.1421786675; __utmz=172939825.1421786675.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); BNES___utmt=yBk1iI2DKxwu+knSHYSj+TDxHe6/Thh10gasvgu9iMzpzE/GDkYWRw=="); 
 my $res = $ua->request($req);
 $cookie->extract_cookies($res);
 $cookie->save;
 $cookie->add_cookie_header($req);
 my $code=$res->code;
 
 my $content;
 if($code =~m/20/is)
 {
  $content = $res->content;
 }
 else
 {
  if ( $rerun_count <= 3 )
  {
   $rerun_count++;
   sleep rand 5;
   goto Home;
  }
 }
 return $content;
}
sub post_content()
{
 my $url = shift;
 my $cont= shift;
 my $rerun_count=0;
 $url =~ s/^\s+|\s+$//g;
 Home:
 my $req = HTTP::Request->new(POST=>$url); 
 $req->header("Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"); 
 $req->header("Content-Type"=>"application/x-www-form-urlencoded");
 $req->header("DNT"=>"1"); 
 $req->header("HOST"=>"www.cobbtax.org"); 
 $req->header("Cookie"=>"__utma=172939825.139902089.1421786675.1421786675.1421786675.1; __utmb=172939825.14.10.1421786675; __utmc=172939825; __utmz=172939825.1421786675.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none)");
 $req->content($cont);
 my $res = $ua->request($req);
 $cookie->extract_cookies($res);
 $cookie->save;
 $cookie->add_cookie_header($req);
 my $code=$res->code;
 
 my $content;
 if($code =~m/20/is)
 {
  $content = $res->content;
 }
 else
 {
  if ( $rerun_count <= 3 )
  {
   $rerun_count++;
   sleep rand 5;
   goto Home;
  }
 }
 return $content;
}
sub trim($) {
  my $string = shift;
  $string =~ s/<[^>]*?>/ /igs;
  $string =~ s/\"/''/igs;
  $string =~ s/\&nbsp\;/ /g;
  $string =~ s/\|//igs;
  $string =~ s/\s+/ /igs;
  $string =~ s/^\s+//g;
  $string =~ s/^\s+//g;
  $string =~ s/\s+$//g;
  $string =~ s/^\s*n\/a\s*$//g;
  $string =~ s/\&\#039\;/'/g;
  $string =~ s/\&\#43\;/+/g;
  $string =~ s/amp;//g;
  
  $string =~ s/mydelimiter/|/g;
  $string =decode_entities($string);
  return $string;
}