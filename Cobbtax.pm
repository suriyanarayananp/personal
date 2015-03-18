package Cobbtax;
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
my $filename ="cobbtax";
my $cookie_file = $filename."_cookie.txt";
unlink($cookie_file);
my $cookie = HTTP::Cookies->new(file=>$cookie_file,autosave=>1);
$ua->cookie_jar($cookie);
#my $pcont = "__EVENTTARGET=&__EVENTARGUMENT=&__VIEWSTATE=%2FwEPDwUENTM4MQ9kFgJmD2QWAgIEDxYCHgZhY3Rpb24FEy90YXhlcy9kZWZhdWx0LmFzcHgWCgIBD2QWDAINDxBkZBYAZAIPD2QWAgIBDxBkZBYAZAIfD2QWAgIBD2QWAgIBDxBkZBYAZAIhD2QWAgIBD2QWAgIBDxBkZBYAZAIrDzwrABECARAWABYAFgAMFCsAAGQCNw88KwARAgEQFgAWABYADBQrAABkAgMPDxYCHgdWaXNpYmxlaGQWCGYPDxYCHwFoZBYEAgcPEGRkFgFmZAIJDw9kFgIeB29uY2xpY2sFP3JldHVybiBjb25maXJtKCdBcmUgeW91IHN1cmUgeW91IHdhbnQgdG8gZGVsZXRlIHRoaXMgbW9kdWxlPycpO2QCBQ8PFgIfAWhkFgICAQ8WAh4LXyFJdGVtQ291bnRmZAIHDw8WAh8BaGQWAgIBDxYCHwNmZAIJDw8WAh8BaGQWAgIBDxYCHwNmZAIEDw8WAh4EVGV4dAUYVEFYIFNFQVJDSCwgVklFVyBBTkQgUEFZZGQCBQ8PFgIfBAVUPGEgaHJlZj0nLyc%2BSG9tZTwvYT4mbmJzcDsmcmFxdW87Jm5ic3A7PGEgaHJlZj0nL3RheGVzJz5UYXggU2VhcmNoLCBWaWV3IGFuZCBQYXk8L2E%2BZGQCBg9kFgQCAQ9kFgZmD2QWBAIHDxBkZBYBZmQCCQ8PZBYCHwIFP3JldHVybiBjb25maXJtKCdBcmUgeW91IHN1cmUgeW91IHdhbnQgdG8gZGVsZXRlIHRoaXMgbW9kdWxlPycpO2QCBA8WAh8EZWQCBg8PFgIfAWhkZAICDw8WAh4EY2FydDLEDQABAAAA%2F%2F%2F%2F%2FwEAAAAAAAAADAIAAABOU3lzdGVtLkRhdGEsIFZlcnNpb249NC4wLjAuMCwgQ3VsdHVyZT1uZXV0cmFsLCBQdWJsaWNLZXlUb2tlbj1iNzdhNWM1NjE5MzRlMDg5BQEAAAAVU3lzdGVtLkRhdGEuRGF0YVRhYmxlAwAAABlEYXRhVGFibGUuUmVtb3RpbmdWZXJzaW9uCVhtbFNjaGVtYQtYbWxEaWZmR3JhbQMBAQ5TeXN0ZW0uVmVyc2lvbgIAAAAJAwAAAAYEAAAAlwo8P3htbCB2ZXJzaW9uPSIxLjAiIGVuY29kaW5nPSJ1dGYtMTYiPz4NCjx4czpzY2hlbWEgeG1sbnM9IiIgeG1sbnM6eHM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDEvWE1MU2NoZW1hIiB4bWxuczptc2RhdGE9InVybjpzY2hlbWFzLW1pY3Jvc29mdC1jb206eG1sLW1zZGF0YSI%2BDQogIDx4czplbGVtZW50IG5hbWU9IlRhYmxlMSI%2BDQogICAgPHhzOmNvbXBsZXhUeXBlPg0KICAgICAgPHhzOnNlcXVlbmNlPg0KICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJuYW1lIiB0eXBlPSJ4czpzdHJpbmciIG1zZGF0YTp0YXJnZXROYW1lc3BhY2U9IiIgbWluT2NjdXJzPSIwIiAvPg0KICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJ0YXhZZWFyIiB0eXBlPSJ4czpzdHJpbmciIG1zZGF0YTp0YXJnZXROYW1lc3BhY2U9IiIgLz4NCiAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0icm9sbFR5cGUiIHR5cGU9InhzOnN0cmluZyIgbXNkYXRhOnRhcmdldE5hbWVzcGFjZT0iIiAvPg0KICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJwYXJjZWxJRCIgdHlwZT0ieHM6c3RyaW5nIiBtc2RhdGE6dGFyZ2V0TmFtZXNwYWNlPSIiIC8%2BDQogICAgICAgIDx4czplbGVtZW50IG5hbWU9ImFtb3VudCIgdHlwZT0ieHM6ZG91YmxlIiBtc2RhdGE6dGFyZ2V0TmFtZXNwYWNlPSIiIG1pbk9jY3Vycz0iMCIgLz4NCiAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0icHJldlllYXIiIHR5cGU9InhzOmJvb2xlYW4iIG1zZGF0YTp0YXJnZXROYW1lc3BhY2U9IiIgbWluT2NjdXJzPSIwIiAvPg0KICAgICAgPC94czpzZXF1ZW5jZT4NCiAgICA8L3hzOmNvbXBsZXhUeXBlPg0KICA8L3hzOmVsZW1lbnQ%2BDQogIDx4czplbGVtZW50IG5hbWU9InRtcERhdGFTZXQiIG1zZGF0YTpJc0RhdGFTZXQ9InRydWUiIG1zZGF0YTpNYWluRGF0YVRhYmxlPSJUYWJsZTEiIG1zZGF0YTpVc2VDdXJyZW50TG9jYWxlPSJ0cnVlIj4NCiAgICA8eHM6Y29tcGxleFR5cGU%2BDQogICAgICA8eHM6Y2hvaWNlIG1pbk9jY3Vycz0iMCIgbWF4T2NjdXJzPSJ1bmJvdW5kZWQiIC8%2BDQogICAgPC94czpjb21wbGV4VHlwZT4NCiAgICA8eHM6dW5pcXVlIG5hbWU9InVuaXF1ZSIgbXNkYXRhOlByaW1hcnlLZXk9InRydWUiPg0KICAgICAgPHhzOnNlbGVjdG9yIHhwYXRoPSIuLy9UYWJsZTEiIC8%2BDQogICAgICA8eHM6ZmllbGQgeHBhdGg9InRheFllYXIiIC8%2BDQogICAgICA8eHM6ZmllbGQgeHBhdGg9InJvbGxUeXBlIiAvPg0KICAgICAgPHhzOmZpZWxkIHhwYXRoPSJwYXJjZWxJRCIgLz4NCiAgICA8L3hzOnVuaXF1ZT4NCiAgPC94czplbGVtZW50Pg0KPC94czpzY2hlbWE%2BBgUAAACAATxkaWZmZ3I6ZGlmZmdyYW0geG1sbnM6bXNkYXRhPSJ1cm46c2NoZW1hcy1taWNyb3NvZnQtY29tOnhtbC1tc2RhdGEiIHhtbG5zOmRpZmZncj0idXJuOnNjaGVtYXMtbWljcm9zb2Z0LWNvbTp4bWwtZGlmZmdyYW0tdjEiIC8%2BBAMAAAAOU3lzdGVtLlZlcnNpb24EAAAABl9NYWpvcgZfTWlub3IGX0J1aWxkCV9SZXZpc2lvbgAAAAAICAgIAgAAAAAAAAD%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwtkFghmD2QWBAIHDxAPFgIeC18hRGF0YUJvdW5kZ2RkFgFmZAIJDw9kFgIfAgU%2FcmV0dXJuIGNvbmZpcm0oJ0FyZSB5b3Ugc3VyZSB5b3Ugd2FudCB0byBkZWxldGUgdGhpcyBtb2R1bGU%2FJyk7ZAIHD2QWAmYPFQILQ29iYiBDb3VudHkLQ29iYiBDb3VudHlkAgkPZBYIAgEPEA8WAh8GZ2QQFRYJQWxsIFllYXJzBDIwMTUEMjAxNAQyMDEzBDIwMTIEMjAxMQQyMDEwBDIwMDkEMjAwOAQyMDA3BDIwMDYEMjAwNQQyMDA0BDIwMDMEMjAwMgQyMDAxBDIwMDAEMTk5OQQxOTk4BDE5OTcEMTk5NgQxOTk1FRYJQWxsIFllYXJzBDIwMTUEMjAxNAQyMDEzBDIwMTIEMjAxMQQyMDEwBDIwMDkEMjAwOAQyMDA3BDIwMDYEMjAwNQQyMDA0BDIwMDMEMjAwMgQyMDAxBDIwMDAEMTk5OQQxOTk4BDE5OTcEMTk5NgQxOTk1FCsDFmdnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2cWAQIBZAIDDxAPFgIfBmdkZBYBZmQCBQ8QDxYCHwZnZGQWAWZkAg8PPCsAEQMADxYEHwZnHwNmZAEQFgAWABYADBQrAABkAgsPZBYIAgEPZBYEZg9kFgJmD2QWAgIBD2QWAmYPZBYGAhkPFgIeBXZhbHVlBRZWaWV3IENhcnQvQ2hlY2tvdXQgKDApZAIfD2QWAgIDDxYCHwMC%2F%2F%2F%2F%2Fw9kAkEPPCsAEQMADxYEHwZnHwNmZAEQFgAWABYADBQrAABkAgQPZBYCZg9kFgICAQ9kFgJmD2QWBGYPFQELQ29iYiBDb3VudHlkAhkPEA8WAh8GZ2QQFTsCQUwCQUsCQVMCQVoCQVICQ0ECQ08CQ1QCREUCREMCRk0CRkwCR0ECR1UCSEkCSUQCSUwCSU4CSUECS1MCS1kCTEECTUUCTUgCTUQCTUECTUkCTU4CTVMCTU8CTVQCTkUCTlYCTkgCTkoCTk0CTlkCTkMCTkQCTVACT0gCT0sCT1ICUFcCUEECUFICUkkCU0MCU0QCVE4CVFgCVVQCVlQCVkkCVkECV0ECV1YCV0kCV1kVOwJBTAJBSwJBUwJBWgJBUgJDQQJDTwJDVAJERQJEQwJGTQJGTAJHQQJHVQJISQJJRAJJTAJJTgJJQQJLUwJLWQJMQQJNRQJNSAJNRAJNQQJNSQJNTgJNUwJNTwJNVAJORQJOVgJOSAJOSgJOTQJOWQJOQwJORAJNUAJPSAJPSwJPUgJQVwJQQQJQUgJSSQJTQwJTRAJUTgJUWAJVVAJWVAJWSQJWQQJXQQJXVgJXSQJXWRQrAztnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZxYBZmQCBQ88KwARAwAPFgQfBmcfA2ZkARAWABYAFgAMFCsAAGQCBw8PFgIfAWhkZAIRDzwrABEDAA8WBB8GZx8DZmQBEBYAFgAWAAwUKwAAZBgHBS1jdGwwMCRjcGhNYWluQ29udGVudCRTa2VsZXRvbkN0cmxfMjckdGJjVGF4ZXMPD2RmZAUbY3RsMDAkQ29udHJvbFBhbmVsMSRndkxpbmtzD2dkBRpjdGwwMCRDb250cm9sUGFuZWwxJGd2RG9jcw9nZAUuY3RsMDAkY3BoTWFpbkNvbnRlbnQkU2tlbGV0b25DdHJsXzI3JGd2UmVjb3Jkcw88KwAMAgYVBQxqdXJpc2RpY3Rpb24HdGF4WWVhcghyb2xsVHlwZQhwYXJjZWxJRApyZWNvcmRUeXBlCGZkBTBjdGwwMCRjcGhNYWluQ29udGVudCRTa2VsZXRvbkN0cmxfMjckZ3ZDYXJ0SXRlbXMPPCsADAEIZmQFSGN0bDAwJGNwaE1haW5Db250ZW50JFNrZWxldG9uQ3RybF8yNyR0YmNUYXhlcyR0Yk92ZXJ2aWV3JGd2SnVyaXNkaWN0aW9ucw88KwAMAQhmZAUtY3RsMDAkY3BoTWFpbkNvbnRlbnQkU2tlbGV0b25DdHJsXzI3JGd2VW5QYWlkDzwrAAwCBhUBBEFSRUMIZmQ0E4wrNPu%2BRmszsYgdsiDF5CbgnJifrowRw3dJv%2Fat6w%3D%3D&ctl00%24cphMainContent%24SkeletonCtrl_27%24btnAccept=Yes%2C+I+accept&__ncforminfo=OKfVWWp3dfesiUTjWH5pzVxKOGFPDbKPtETPLSegEcDUdRK1ETst7D2jWW1Npuh9ZxGLB4QmUdY-Qaw6C3vdsJ-whlScjIySle6rOUFEA73sh_r3rG7eNA%3D%3D";
# my $maincont =&post_content("http://www.cobbtax.org/taxes/default.aspx",$pcont);
# open ll,">cobb.html";
# print ll $maincont;
# close ll;
# my $view = uri_escape($1) if($maincont =~ m/id\=\"__VIEWSTATE\"\s*value\=\"([^>]*?)\"/is);
sub scrape()
{
	my $keys = shift;
	my $county = shift;
	my $arrayref = shift;
	my $NameFlag = shift;
	my @array = @$arrayref;
	print "From Cobbtax :: $keys->$county\n\n";
	my $file_xls_name = "output_".$county.".xls";
	my $url='http://www.cobbtax.org/taxes/default.aspx';
	my $cont1="__EVENTTARGET=&__EVENTARGUMENT=&__VIEWSTATE=";
	my $cont2="%2FwEPDwUENTM4MQ9kFgJmD2QWAgIEDxYCHgZhY3Rpb24FEy90YXhlcy9kZWZhdWx0LmFzcHgWCgIBD2QWDAINDxBkZBYAZAIPD2QWAgIBDxBkZBYAZAIfD2QWAgIBD2QWAgIBDxBkZBYAZAIhD2QWAgIBD2QWAgIBDxBkZBYAZAIrDzwrABECARAWABYAFgAMFCsAAGQCNw88KwARAgEQFgAWABYADBQrAABkAgMPDxYEHghlZGl0TW9kZQspXUJhc2VDb250cm9sK0VkaXRNb2RlLCBBcHBfV2ViX2h1ZW5jYXFiLCBWZXJzaW9uPTAuMC4wLjAsIEN1bHR1cmU9bmV1dHJhbCwgUHVibGljS2V5VG9rZW49bnVsbAAeB1Zpc2libGVoZBYIZg8PFgIfAmhkFgYCAQ8WAh4Dc3JjBSAvaW1hZ2VzL3NrZWxldG9uL2FjdGlvbnNNZW51LmdpZmQCBw8QZGQWAWZkAgkPD2QWAh4Hb25jbGljawU%2FcmV0dXJuIGNvbmZpcm0oJ0FyZSB5b3Ugc3VyZSB5b3Ugd2FudCB0byBkZWxldGUgdGhpcyBtb2R1bGU%2FJyk7ZAIFDw8WAh8CaGQWAgIBDxYCHgtfIUl0ZW1Db3VudGZkAgcPDxYCHwJoZBYCAgEPFgIfBWZkAgkPDxYCHwJoZBYCAgEPFgIfBWZkAgQPDxYCHgRUZXh0BRhUQVggU0VBUkNILCBWSUVXIEFORCBQQVlkZAIFDw8WAh8GBVQ8YSBocmVmPScvJz5Ib21lPC9hPiZuYnNwOyZyYXF1bzsmbmJzcDs8YSBocmVmPScvdGF4ZXMnPlRheCBTZWFyY2gsIFZpZXcgYW5kIFBheTwvYT5kZAIGD2QWBAIBD2QWBmYPZBYEAgcPEGRkFgFmZAIJDw9kFgIfBAU%2FcmV0dXJuIGNvbmZpcm0oJ0FyZSB5b3Ugc3VyZSB5b3Ugd2FudCB0byBkZWxldGUgdGhpcyBtb2R1bGU%2FJyk7ZAIEDxYCHwZlZAIGDw8WAh8CaGRkAgIPDxYEHwELKwQAHgRjYXJ0MsQNAAEAAAD%2F%2F%2F%2F%2FAQAAAAAAAAAMAgAAAE5TeXN0ZW0uRGF0YSwgVmVyc2lvbj00LjAuMC4wLCBDdWx0dXJlPW5ldXRyYWwsIFB1YmxpY0tleVRva2VuPWI3N2E1YzU2MTkzNGUwODkFAQAAABVTeXN0ZW0uRGF0YS5EYXRhVGFibGUDAAAAGURhdGFUYWJsZS5SZW1vdGluZ1ZlcnNpb24JWG1sU2NoZW1hC1htbERpZmZHcmFtAwEBDlN5c3RlbS5WZXJzaW9uAgAAAAkDAAAABgQAAACXCjw%2FeG1sIHZlcnNpb249IjEuMCIgZW5jb2Rpbmc9InV0Zi0xNiI%2FPg0KPHhzOnNjaGVtYSB4bWxucz0iIiB4bWxuczp4cz0iaHR0cDovL3d3dy53My5vcmcvMjAwMS9YTUxTY2hlbWEiIHhtbG5zOm1zZGF0YT0idXJuOnNjaGVtYXMtbWljcm9zb2Z0LWNvbTp4bWwtbXNkYXRhIj4NCiAgPHhzOmVsZW1lbnQgbmFtZT0iVGFibGUxIj4NCiAgICA8eHM6Y29tcGxleFR5cGU%2BDQogICAgICA8eHM6c2VxdWVuY2U%2BDQogICAgICAgIDx4czplbGVtZW50IG5hbWU9Im5hbWUiIHR5cGU9InhzOnN0cmluZyIgbXNkYXRhOnRhcmdldE5hbWVzcGFjZT0iIiBtaW5PY2N1cnM9IjAiIC8%2BDQogICAgICAgIDx4czplbGVtZW50IG5hbWU9InRheFllYXIiIHR5cGU9InhzOnN0cmluZyIgbXNkYXRhOnRhcmdldE5hbWVzcGFjZT0iIiAvPg0KICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJyb2xsVHlwZSIgdHlwZT0ieHM6c3RyaW5nIiBtc2RhdGE6dGFyZ2V0TmFtZXNwYWNlPSIiIC8%2BDQogICAgICAgIDx4czplbGVtZW50IG5hbWU9InBhcmNlbElEIiB0eXBlPSJ4czpzdHJpbmciIG1zZGF0YTp0YXJnZXROYW1lc3BhY2U9IiIgLz4NCiAgICAgICAgPHhzOmVsZW1lbnQgbmFtZT0iYW1vdW50IiB0eXBlPSJ4czpkb3VibGUiIG1zZGF0YTp0YXJnZXROYW1lc3BhY2U9IiIgbWluT2NjdXJzPSIwIiAvPg0KICAgICAgICA8eHM6ZWxlbWVudCBuYW1lPSJwcmV2WWVhciIgdHlwZT0ieHM6Ym9vbGVhbiIgbXNkYXRhOnRhcmdldE5hbWVzcGFjZT0iIiBtaW5PY2N1cnM9IjAiIC8%2BDQogICAgICA8L3hzOnNlcXVlbmNlPg0KICAgIDwveHM6Y29tcGxleFR5cGU%2BDQogIDwveHM6ZWxlbWVudD4NCiAgPHhzOmVsZW1lbnQgbmFtZT0idG1wRGF0YVNldCIgbXNkYXRhOklzRGF0YVNldD0idHJ1ZSIgbXNkYXRhOk1haW5EYXRhVGFibGU9IlRhYmxlMSIgbXNkYXRhOlVzZUN1cnJlbnRMb2NhbGU9InRydWUiPg0KICAgIDx4czpjb21wbGV4VHlwZT4NCiAgICAgIDx4czpjaG9pY2UgbWluT2NjdXJzPSIwIiBtYXhPY2N1cnM9InVuYm91bmRlZCIgLz4NCiAgICA8L3hzOmNvbXBsZXhUeXBlPg0KICAgIDx4czp1bmlxdWUgbmFtZT0idW5pcXVlIiBtc2RhdGE6UHJpbWFyeUtleT0idHJ1ZSI%2BDQogICAgICA8eHM6c2VsZWN0b3IgeHBhdGg9Ii4vL1RhYmxlMSIgLz4NCiAgICAgIDx4czpmaWVsZCB4cGF0aD0idGF4WWVhciIgLz4NCiAgICAgIDx4czpmaWVsZCB4cGF0aD0icm9sbFR5cGUiIC8%2BDQogICAgICA8eHM6ZmllbGQgeHBhdGg9InBhcmNlbElEIiAvPg0KICAgIDwveHM6dW5pcXVlPg0KICA8L3hzOmVsZW1lbnQ%2BDQo8L3hzOnNjaGVtYT4GBQAAAIABPGRpZmZncjpkaWZmZ3JhbSB4bWxuczptc2RhdGE9InVybjpzY2hlbWFzLW1pY3Jvc29mdC1jb206eG1sLW1zZGF0YSIgeG1sbnM6ZGlmZmdyPSJ1cm46c2NoZW1hcy1taWNyb3NvZnQtY29tOnhtbC1kaWZmZ3JhbS12MSIgLz4EAwAAAA5TeXN0ZW0uVmVyc2lvbgQAAAAGX01ham9yBl9NaW5vcgZfQnVpbGQJX1JldmlzaW9uAAAAAAgICAgCAAAAAAAAAP%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FC2QWCGYPZBYGAgEPFgIfAwUgL2ltYWdlcy9za2VsZXRvbi9hY3Rpb25zTWVudS5naWZkAgcPEA8WAh4LXyFEYXRhQm91bmRnZGQWAWZkAgkPD2QWAh8EBT9yZXR1cm4gY29uZmlybSgnQXJlIHlvdSBzdXJlIHlvdSB3YW50IHRvIGRlbGV0ZSB0aGlzIG1vZHVsZT8nKTtkAgcPDxYCHwJoZBYCZg8VAgtDb2JiIENvdW50eQtDb2JiIENvdW50eWQCCQ8PFgIfAmdkFgoCAQ8QDxYCHwhnZBAVFglBbGwgWWVhcnMEMjAxNQQyMDE0BDIwMTMEMjAxMgQyMDExBDIwMTAEMjAwOQQyMDA4BDIwMDcEMjAwNgQyMDA1BDIwMDQEMjAwMwQyMDAyBDIwMDEEMjAwMAQxOTk5BDE5OTgEMTk5NwQxOTk2BDE5OTUVFglBbGwgWWVhcnMEMjAxNQQyMDE0BDIwMTMEMjAxMgQyMDExBDIwMTAEMjAwOQQyMDA4BDIwMDcEMjAwNgQyMDA1BDIwMDQEMjAwMwQyMDAyBDIwMDEEMjAwMAQxOTk5BDE5OTgEMTk5NwQxOTk2BDE5OTUUKwMWZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2RkAgMPEA8WAh8IZ2RkZGQCBQ8QDxYCHwhnZGRkZAINDw8WAh8GBRBObyBSZWNvcmRzIEZvdW5kZGQCDw88KwARAwAPFgQfCGcfBWZkARAWABYAFgAMFCsAAGQCCw9kFggCAQ9kFgRmD2QWAmYPZBYCAgEPZBYCZg9kFgYCGQ8WAh4FdmFsdWUFFlZpZXcgQ2FydC9DaGVja291dCAoMClkAh8PZBYCAgMPFgIfBQL%2F%2F%2F%2F%2FD2QCQQ88KwARAwAPFgQfCGcfBWZkARAWABYAFgAMFCsAAGQCBA9kFgJmD2QWAgIBD2QWAmYPZBYEZg8VAQtDb2JiIENvdW50eWQCGQ8QDxYCHwhnZBAVOwJBTAJBSwJBUwJBWgJBUgJDQQJDTwJDVAJERQJEQwJGTQJGTAJHQQJHVQJISQJJRAJJTAJJTgJJQQJLUwJLWQJMQQJNRQJNSAJNRAJNQQJNSQJNTgJNUwJNTwJNVAJORQJOVgJOSAJOSgJOTQJOWQJOQwJORAJNUAJPSAJPSwJPUgJQVwJQQQJQUgJSSQJTQwJTRAJUTgJUWAJVVAJWVAJWSQJWQQJXQQJXVgJXSQJXWRU7AkFMAkFLAkFTAkFaAkFSAkNBAkNPAkNUAkRFAkRDAkZNAkZMAkdBAkdVAkhJAklEAklMAklOAklBAktTAktZAkxBAk1FAk1IAk1EAk1BAk1JAk1OAk1TAk1PAk1UAk5FAk5WAk5IAk5KAk5NAk5ZAk5DAk5EAk1QAk9IAk9LAk9SAlBXAlBBAlBSAlJJAlNDAlNEAlROAlRYAlVUAlZUAlZJAlZBAldBAldWAldJAldZFCsDO2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnFgFmZAIFDzwrABEDAA8WBB8IZx8FZmQBEBYAFgAWAAwUKwAAZAIHDw8WAh8CaGRkAhEPPCsAEQMADxYEHwhnHwVmZAEQFgAWABYADBQrAABkGAcFLWN0bDAwJGNwaE1haW5Db250ZW50JFNrZWxldG9uQ3RybF8yNyR0YmNUYXhlcw8PZGZkBRtjdGwwMCRDb250cm9sUGFuZWwxJGd2TGlua3MPZ2QFGmN0bDAwJENvbnRyb2xQYW5lbDEkZ3ZEb2NzD2dkBTBjdGwwMCRjcGhNYWluQ29udGVudCRTa2VsZXRvbkN0cmxfMjckZ3ZDYXJ0SXRlbXMPPCsADAEIZmQFSGN0bDAwJGNwaE1haW5Db250ZW50JFNrZWxldG9uQ3RybF8yNyR0YmNUYXhlcyR0Yk92ZXJ2aWV3JGd2SnVyaXNkaWN0aW9ucw88KwAMAQhmZAUuY3RsMDAkY3BoTWFpbkNvbnRlbnQkU2tlbGV0b25DdHJsXzI3JGd2UmVjb3Jkcw88KwAMAgYVBQxqdXJpc2RpY3Rpb24HdGF4WWVhcghyb2xsVHlwZQhwYXJjZWxJRApyZWNvcmRUeXBlCGZkBS1jdGwwMCRjcGhNYWluQ29udGVudCRTa2VsZXRvbkN0cmxfMjckZ3ZVblBhaWQPPCsADAIGFQEEQVJFQwhmZJFOHJ61aAcJL3vnt61yvpuxPPxIpZ2CxQIMtum7m9ji";
	my $cont3;
	if($NameFlag == 'Y')
	{
		$cont3="&&ctl00%24cphMainContent%24SkeletonCtrl_27%24drpTaxYear=2014&ctl00%24cphMainContent%24SkeletonCtrl_27%24drpStatus=All&ctl00%24cphMainContent%24SkeletonCtrl_27%24drpSearchParam=Owner+Name&ctl00%24cphMainContent%24SkeletonCtrl_27%24txtSearchParam=";
	}
	else
	{
		$cont3="&&ctl00%24cphMainContent%24SkeletonCtrl_27%24drpTaxYear=2014&ctl00%24cphMainContent%24SkeletonCtrl_27%24drpStatus=All&ctl00%24cphMainContent%24SkeletonCtrl_27%24drpSearchParam=Property+Address&ctl00%24cphMainContent%24SkeletonCtrl_27%24txtSearchParam=";
	}
	my $view="ctl00%24cphMainContent%24SkeletonCtrl_27%24btnSearch=Search";
	my $cont4=$cont1.$cont2.$cont3.$keys."&".$view;
	my $content1=&post_content($url,$cont4);
	open ff,">first.html";
	print ff $content1;
	close ff;
	exit;
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
	my $cont5=$cont1.$cont2.$cont3.$keys."&".$view."=View";
	my $content= &post_content($url,$cont5);
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
	print "$keys -> $parcelno\n";
	open ff,">>$file_xls_name";
	print ff "$array[0]\t$array[1]\t$array[2]\t$array[3]\t$array[4]\t$array[5]\t$array[6]\t$array[7]\t$array[8]\t$array[9]\t$array[10]\t$array[11]\t$array[12]\t$owner\t$address\t$city\t$state\t$zipcode\t$taxyear\t$duedate\t$paystatus\t$paidamt\t$datepaid\t$totaldue\t$parcelno\t$fairvalue\n";
	close ff;
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
sub post_content()
{
	my $url = shift;
	my $cont= shift;
	my $rerun_count=0;
	$url =~ s/^\s+|\s+$|amp\;//g;
	Home:
	my $req = HTTP::Request->new(POST=>$url); 
	$req->header("Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"); 
	$req->header("Content-Type"=>"application/x-www-form-urlencoded");
	$req->header("DNT"=>"1"); 
	$req->header("HOST"=>"www.cobbtax.org"); 
	$req->header("Cookie"=>"__utma=172939825.1677480068.1426649199.1426649199.1426649199.1; __utmb=172939825.2.10.1426649199; __utmc=172939825; __utmz=172939825.1426649199.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); __utmt=1; BNES___utmt=aH3r+s7JW5nF7ADgo+HC5qFqBzqrFUqN5dnzR0ZrOhEDDlJAwyClkA==; ASP.NET_SessionId=vqkamvhpi2l1nfhxbdnbjwjb; BNES_ASP.NET_SessionId=Ya/UxA0YmN9QFZaU8KU1aeuzBY51UAEs5JK7YVidI3shYYHG64AG2BT4gqf4+R4ZFek0o/33t5Fh+YTskN7HvsZb4eBKJMec");
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
1;