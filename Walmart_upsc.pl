# PERL MODULES WE WILL BE USING
use strict;
use HTTP::Cookies;
use LWP::UserAgent;
use HTML::Entities;
use URI::Escape;
use Encode qw(encode);
use DateTime;
my $ua = LWP::UserAgent->new(show_progress=>1);
$ua->agent("Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 2.0.50727)");
$ua->timeout(30);
$ua->cookie_jar({});
my $date = DateTime->now->ymd;
$date =~ s/\-//igs;
my $filename ="walmart".$date;
my $cookie_file = $filename."_cookie.txt";
unlink($cookie_file);
my $cookie = HTTP::Cookies->new(file=>$cookie_file,autosave=>1);
$ua->cookie_jar($cookie);
my @regexarray = ('allergen_free|allergen\s+free|free\s+allergen','casein_free|casein\s+free|free\s+casein','corn_free|corn\s+free|free\s+corn','dairy_free|dairy\s+free|free\s+dairy','egg_free|egg\s+free|free\s+egg','hypoallergenic','lactose_free|lactose\s+free|free\s+lactose','latex_free|latex\s+free|free\s+latex','peanut_free|peanut\s+free|free\s+peanut','shellfish_free|shellfish\s+free|free\s+shellfish','silicone_free|silicone\s+free|free\s+silicone','soy_free|soy\s+free|free\s+soy','tree_nut_free|tree\s+nut\s+free|free\s+tree\s+nut','wheat_free|wheat\s+free|free\s+wheat','yeast_free|yeast\s+free|free\s+yeast','fat_free|fat\s+free|free\s+fat','gluten_free|gluten\s+free|free\s+gluten','kosher','low_carb','low_sodium','organic','sugar_free|sugar\s+free|free\s+sugar','vegan','vegetarian','alcohol_free|alcohol\s+free|free\s+alcohol','ammonium_lauryl_sulfate_free|ammonium\s+lauryl\s+sulfate\s+free|free\s+ammonium\s+lauryl\s+sulfate','bpa_free|free\s+free|bpa\s+free','chemical_free|chemical\s+free|free\s+chemical','chlorine_free|chlorine\s+free|free\s+chlorine','deet_free|deet_free|free\s+deet','fragrance_free|fragrance_free|free\s+fragrance','hexane_free|hexane\s+free|free\s+hexane','mineral_oil_free|mineral\s+oil\s+free|free\s+mineral\s+oil','msg_free|msg\s+free|free\s+msg','non_gmo','paraben_free|paraben\s+free|free\s+paraben','petroleum_free|petroleum\s+free|free\s+petroleum','preservative_free|preservative\s+free|free\s+preservative','sodium_laureth_sulfate_free|sodium\s+laureth\s+sulfate\s+free|free\s+sodium\s+laureth\s+sulfate','talc_free|talc\s+free|free\s+talc','children','clearance','cruelty_free|cruelty\s+free|free\s+cruelty','fsa_eligible');
my @upscarr=('610708883920', '610373772697', '899133002124', '837654129210', '837654125625', '013964521726', '013964521788', '837654315170', '013964521719', '837654315125', '837654315149', '837654315187', '837654315132', '837654315163', '013964521702', '074250784058', '724675880308', '853778000426', '898960185512', '898960182122', '898960184751', '898960184744', '898960184102', '898960181569', '898630183107', '898960181491', '898960184423', '898960184041', '898960181439', '898960184515', '071409745014', '071409745052', '729609016037', '729609016013', '729609016648', '870434001115', '798412444511', '798412444412', '798412444405', '019373301010', '019373952557', '859220000853', '859220000815', '857249001042', '724742004019', '724742004026', '724742003838', '724742004002', '810053000076', '810053000120', '608503050043', '608503030717', '760860091517', '760860091524', '760860091166', '760860091111', '760860091234', '760860092118', '760860217412', '760860201039', '760860251041', '760860251072', '760860211021', '760860211014', '760860211045', '760860211076', '760860211038', '760860211052', '760860211069', '760860282052', '760860722107', '760860020364', '760860020371', '760860011515', '760860011553', '760860011140', '760860011164', '760860011201', '760860011362', '760860011119', '760860011232', '760860012512', '760860012352', '760860012116', '760860215173', '760860215111', '760860215067', '760860215081', '760860281086', '076920000185', '027434040747', '027434039932', '027434038072', '678226009307', '678226014301', '076630110044', '076630110532', '076630043908', '076630025423');

open(fh,">output.txt");
print fh "UPSC\tProduct_name\tPrice_text\tPrice\tBrand\tDescription\tProd_detail\tBreadcrumb\tWas_price\tOrgin\tShipping_weight\tShort_desc\tSize\tProduct URL\tSuggested Use\tSupplement Facts\tWarnings\tOther Ingredients\tIngredients\tallergen_free\tcasein_free\tcorn_free\tdairy_free\tegg_free\thypoallergenic\tlactose_free\tlatex_free\tpeanut_free\tshellfish_free\tsilicone_free\tsoy_free\ttree_nut_free\twheat_free\tyeast_free\tfat_free\tgluten_free\tkosher\tlow_carb\tlow_sodium\torganic\tsugar_free\tvegan\tvegetarian\talcohol_free\tammonium_lauryl_sulfate_free\tbpa_free\tchemical_free\tchlorine_free\tdeet_free\tfragrance_free\thexane_free\tmineral_oil_free\tmsg_free\tnon_gmo\tparaben_free\tpetroleum_free\tpreservative_free\tsodium_laureth_sulfate_free\ttalc_free\tchildren\tclearance\tcruelty_free\tfsa_eligible\tmen\tsenior\tteen\twomen\n";
close fh;
my $pcount = 0;
foreach my $upsc (@upscarr)
{
	##$upsc='899133002124';
	my $url='http://www.walmart.com/search/?query='.$upsc;
	my $content=lwp_get($url);
	if($content=~m/<h4\s*class\=tile\-heading>\s*<a\s*class\=js\-product\-title\s*href\=\"([^>]*?)\">/is)
	{
		my $product_url='http://www.walmart.com'.$1;
		
		# $product_url='http://www.walmart.com/ip/Nature-Valley-Peanut-Butter-Dark-Chocolate-Protein-Chewy-Bars-1.42-oz-5-count/20470594'; ## Testing
		
		# $product_url='http://www.walmart.com/ip/Liquid-Coconut-Premium-Oil-Nature-s-Way-10-oz-Liquid/29848018?action=product_interest&action_type=title&placement_id=irs_top&strategy=PWVUB&visitor_id=Dx7fIAjX2_oU-a9cVyiTi4&category=&client_guid=cafa13f0-d916-40ee-81b7-5873194e3c41&customer_id_enc=&config_id=2&parent_item_id=29671378&guid=6d13297f-0225-4311-b6e8-2bf762bbff95&bucket_id=irsbucketdefault&beacon_version=1.0.0&findingMethod=p13n'; ## Testing
		
		print "Product URl:: $product_url\n";
		my $product_content=lwp_get($product_url);

		
		my ($product_name, $price_text, $price, $brand, $description, $prod_detail, $breadcrumb, $was_price, $orgin, $shipping_weight, $short_desc, $size);
		
		if($product_content=~m/itemprop\=breadcrumb>([\w\W]*?)<\/ol>\s*<\/div>\s*<\/div>/is)
		{
			my $breadcrumb_block=$1;
			$breadcrumb_block=~s/<li\s*class\=breadcrumb>/ > /igs;
			$breadcrumb=clean($breadcrumb_block);
			$breadcrumb=~s/^\s*\>\s*//is;
			$breadcrumb=~s/\>/ > /igs;		
		}	
		
		print "Breadcrumb:: $breadcrumb\n";
		
		# Product_name
		if($product_content =~ m/<h1[^>]*?>\s*([^>]*?)\s*<\/h1>/is )
		{
			$product_name = clean($1);		
		}
		elsif ( $product_content =~ m/productName\"\:\"([\w\W]*?)\"\,\"/is )
		{
			$product_name = clean($1);		
		}
		elsif($product_content =~ m/name\=\"title\"\s*content\=\"([^>]*?)\"\/>/is)
		{
			$product_name = clean($1);
		}
		
		# print "Product Name:: $product_name\n";
			
		
		#Collecting the price text
		if($product_content =~ m/class\=js-product-offer-summary>([\w\W]*?)<\/div>\s*(?:<div\s*class\=price\-fulfillment>|<\/div>)/is)
		{
			$price_text = clean($1);
		}
		elsif($product_content=~m/<div\s*class\=\"js\-price\-display\s*price\s*price\-display\">([\w\W]*?)<\/div>/is) 
		{
			$price_text = clean($1);
		}
		elsif($product_content =~ m/<span\s*class\=\"bigPriceText1\">([^<]*?)<\/span>\s*<span\s*class\=\"smallPriceText1\">([^<]*?)</is)
		{
			$price_text = clean($1.$2);
		}

		if($price_text eq '')
		{
			if($product_content =~ m/itemprop\=price[^>]*?content\=\"([^>]*?)\"/is)
			{
				$price_text = clean($1);
			}
		}
		
		#Was price	
		if($product_content =~ m/Was\:\s*<s>\s*([^>]*?)\s*<\/s>/is)
		{
			$was_price=$1;
		}
		
		# print "Was price:: $was_price\n";
		
		# collecting the price
		if($product_content =~ m/itemprop\=price[^>]*?content\=\"([^>]*?)\"/is)
		{
			$price = clean($1);
		}
		
		# print "Price:: $price\n";
		
		# print "Price text:: $price_text\n";
		
		# collecting brand name
		if ( $product_content =~ m/itemprop\=brand[^>]*?content\=\s*(?:\")?([^>]*?)\s*(?:\")?\s*\//is )
		{
			$brand = clean($1);
				
			if ( $brand !~ /^\s*$/g ) 
			{ 
				# print "Brand: $brand\n"; 
			} 
		}
		
		# Collecting product description
		my $dumpdesc = $1 if($product_content =~ m/class\=\"product\-about\s*js\-about\-[^>]*?\">([\w\W]*?)<\/div>\s*<\/div>\s*<\/div>/is);
		if ( $product_content =~ m/About\s*this\s*item<\/h2>[\w\W]*?<p>([\w\W]*?)<\/div>/is )
		{
			$description = clean($1);
		}
		elsif($product_content =~ m/itemprop\=\"description\">\s*<div>([\w\W]*?)<\/div>\s*<\/div>/is)
		{
			$description = clean($1);
		}
		elsif($product_content =~ m/class\=\"product\-about\s*js\-about\-bundle\">([\w\W]*?)<\/div>/is)
		{
			$description = clean($1);
		}
		
		# Short desc
		if($product_content =~ m/<div\s*class\=\"product\-short\-description\s*module\">\s*([^>]*?)\s*<\/div>/is)
		{
			$short_desc=$1;
		}
		
		# print "Short desc:: $short_desc\n";
		
		# Detail
		if($product_content =~ m/product\-specs\">\s*<div\s*class\=specs\-table>([\w\W]*?)<\/div>/is)
		{
			$prod_detail = clean($1);
		}
		
		# print "Product Desc:: $description\n";
		
		# print "Product Detail:: $prod_detail\n";
		
		if($product_content =~ m/Origin\s*of\s*Components\:<\/td>\s*<td>\s*([^>]*?)\s*<\/td>/is)
		{
			$orgin=clean($1);
		}
		
		# print "orgin:: $orgin\n";
		
		if($product_content =~ m/Shipping\s*Weight\s*\(in\s*pounds\)\:([\w\W]*?)<\/tr>/is)
		{
			$shipping_weight=clean($1);		
		}
		# print "Shipping Weight:: $shipping_weight\n";
		if($product_content =~ m/(Product\s*in\s*Inches|Size)[^>]*?\:<\/td>([\w\W]*?)<\/tr>/is)
		{
			$size=clean($2);
		}
		# print "Size:: $size\n";
		my ($suse,$sfacts,$warn,$oingred,$ingred);
		if($dumpdesc =~ m/<b>\s*Suggested\s*Use\s*<\/b>([\w\W]*?)<\/p>/is)
		{
			$suse = &clean($1);
			$dumpdesc =~ s/<b>\s*Suggested\s*Use\s*<\/b>([\w\W]*?)<\/p>//igs;
		}
		if($dumpdesc =~ m/<b>\s*Supplement\s*Facts\s*<\/b>([\w\W]*?)<\/p>/is)
		{
			$sfacts = &clean($1);
			$dumpdesc =~ s/<b>\s*Supplement\s*Facts\s*<\/b>([\w\W]*?)<\/p>//igs;
		}
		if($dumpdesc =~ m/<b>\s*Warnings\s*\:\s*<\/b>([\w\W]*?)<\/p>/is)
		{
			$warn = &clean($1);
			$dumpdesc =~ s/<b>\s*Warnings\s*\:\s*<\/b>([\w\W]*?)<\/p>//igs;
		}
		if($dumpdesc =~ m/<b>\s*Other\s*Ingredients\s*\:\s*<\/b>([\w\W]*?)<\/p>/is)
		{
			$oingred = &clean($1);
			$dumpdesc =~ s/<b>\s*Other\s*Ingredients\s*\:\s*<\/b>([\w\W]*?)<\/p>//igs;
		}
		if($dumpdesc =~ m/>\s*Ingredients\s*\:\s*([\w\W]*?)<\/p>\s*<\/section>/is)
		{
			$ingred = &clean($1);
			$dumpdesc =~ s/>\s*Ingredients\s*\:\s*([\w\W]*?)<\/p>\s*<\/section>//igs;
		}
		my $str;
		for(my $i=0; $i<@regexarray;$i++)
		{
			my $key;
			if($dumpdesc =~ m/$regexarray[$i]/is)
			{
				$key='Yes';
			}
			else
			{
				$key='No';
			}
			if($str eq '')
			{
				$str = $key;
			}
			else
			{
				$str = $str."\t".$key;
			}
		}
		$str = $str."\tYes\tYes\tYes\tYes";
		print "$pcount -> $product_name\n";
		open(fh,">>output.txt");
		print fh "$upsc\t$product_name\t$price_text\t$price\t$brand\t$description\t$prod_detail\t$breadcrumb\t$was_price\t$orgin\t$shipping_weight\t$short_desc\t$size\t$product_url\t$suse\t$sfacts\t$warn\t$oingred\t$ingred\t$str\n";
		close fh;

		
	}
}

sub lwp_get() 
{ 
    REPEAT: 
	my $urls = shift;
	$urls =~ s/amp\;//igs;
    # sleep 15; 
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