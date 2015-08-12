package CDH::MUTS;

use strict;
use Data::Dumper;

use CDH::Common;
use CDH::ExtractCommon;
use CDH::LookUpXRef;

our $global_str_muts_remarks_single_block_template = "_VALUE_PERSON_NAME		(Q - _VALUE_QUESTION_NUMBER ) Condition = _VALUE_CONDITION
_VALUE_PERSON_NAME		(Q - _VALUE_QUESTION_NUMBER ) Duration = _VALUE_DURATION
_VALUE_PERSON_NAME		(Q - _VALUE_QUESTION_NUMBER ) Deg of Rec = _VALUE_DEGREE_OF_RECOVERY
_VALUE_PERSON_NAME		(Q - _VALUE_QUESTION_NUMBER ) Physician = _VALUE_PHYSICIAN
_VALUE_PERSON_NAME		(Q - _VALUE_QUESTION_NUMBER ) Addr Line 1 = _VALUE_ADDRESS_LINE_ONE
";

my $remark_dataArray =
[['Question No.', 'Does Question Apply to Employee, Spouse/DP or Child
	', 'Condition', 'Date Occurred', 'Duration', 'Degree of Recovery', 'Names & Addresses of Physicians
	Hospitals/Clinics Consulted']
];

our $global_hash_muts_question_numbers = {
											"6" => "6",
											"7a" => "7A",
											"7b" => "7B",
											"7c" => "7C",
											"8" => "8"
										};
our $global_hash_muts_products_for_current_move = {};	

my $hash_additionalpages = {};
#EOI_Phase_2_1::Begin - Ponmani
#TP-13347	Unique coverage name for each ProductID
our $global_hash_muts_preferred_products = {
												"100~List" => "Group Critical Illness",
												"100~Self" => "Group Critical Illness",
												"104~List" => "Employer-Funded Life",
												"104~Self" => "Employer Paid Life",
												"105~List" => "Employer-Funded AD&D",
												"105~Self" => "Employer Paid AD&D",
												"106~List" => "Employer-Funded LTD ",
												"106~Self" => "Employer-Funded LTD ",
												"107~List" => "Employer-Funded STD",
												"107~Self" => "Employer-Funded STD",
												"110~List" => "Employer-Funded Dependent Life",
												"110~Self" => "Employer-Funded Dependent Life",
												"111~List" => "Employee-Paid AD&D",
												"111~Self" => "Employee-Paid AD&D",
												"112~List" => "Employee-Paid Life",
												"112~Self" => "Employee Paid Life",
												"113~List" => "Employee-Paid Dependent Life",
												"113~Self" => "Employee Paid Dependent Life",
												"124~List" => "Employee-Paid STD (Buyup)",
												"124~Self" => "Employee-Paid STD (Buyup)",
												"125~List" => "Employee-Paid LTD (Buyup)",
												"125~Self" => "Employee-Paid LTD (Buyup)",
												"126~List" => "Group Standalone AD&D",
												"126~Self" => "Group Standalone AD&D",
												"601~List" => "Employer-Funded Life",
												"601~Self" => "Employer-Funded Life",
												"602~List" => "Employer-Funded Spouse Life",
												"602~Self" => "Employer-Funded Spouse Life",
												"603~List" => "Employer-Funded Child Life",
												"603~Self" => "Employer-Funded Child Life",
												"604~List" => "Employer-Funded Spouse & Child Life",
												"604~Self" => "Employer-Funded Spouse & Child Life",
												"606~List" => "Employer-Funded LTD ",
												"606~Self" => "Employer-Funded LTD ",
												"607~List" => "Employer-Funded STD",
												"607~Self" => "Employer-Funded STD",
												"611~List" => "Employee-Paid Life",
												"611~Self" => "Employee-Paid Life",
												"612~List" => "Employee-Paid Spouse Life",
												"612~Self" => "Employee-Paid Spouse Life",
												"613~List" => "Employee-Paid Child Life",
												"613~Self" => "Employee-Paid Child Life",
												"614~List" => "Employee-Paid Spouse & Child Life",
												"614~Self" => "Employee-Paid Spouse & Child Life",
												"620~List" => "Employer-Funded AD&D",
												"620~Self" => "Employer-Funded AD&D",
												"621~List" => "Employer-Funded Spouse AD&D",
												"621~Self" => "Employer-Funded Spouse AD&D",
												"622~List" => "Employer-Funded Child AD&D",
												"622~Self" => "Employer-Funded Child AD&D",
												"631~List" => "Employee-Paid AD&D",
												"631~Self" => "Employee-Paid AD&D",
												"632~List" => "Employee-Paid Spouse AD&D",
												"632~Self" => "Employee-Paid Spouse AD&D",
												"633~List" => "Employee-Paid Child AD&D",
												"633~Self" => "Employee-Paid Child AD&D",
												"634~List" => "Employee-Paid Family AD&D",
												"634~Self" => "Employee-Paid Family AD&D"
											};
#EOI_Phase_2_1::End - Ponmani											
sub generate_muts_report
{
	my $hash_single_form = shift;
	my $reference_array_muts_reports = shift;
	my $str_process_type_key = shift;
	my $hash_eoi_current_application = shift;

	my $boolean_generate_muts_report = 0;
	foreach my $str_product_sequence( keys %{$hash_single_form->{products}} )
	{
		my $hash_single_product = $hash_single_form->{products}->{$str_product_sequence};

		my $hash_case_product = CDH::LookUpXRef::get_case_product( $hash_single_form->{CaseID}, $hash_single_product->{ProductID} );
		my $str_muts_flag = $hash_case_product->{MUTS_FLAG};

		if( is_enrollment( $hash_single_product->{TransactionType} ) && $str_muts_flag eq "Yes" )
		{
			$boolean_generate_muts_report = 1;
			$global_hash_muts_products_for_current_move->{$hash_case_product->{PRODUCT_ID}} = $CDH::LookUpXRef::hash_master_lookup->{PRODUCT_MASTER}->{$hash_case_product->{PRODUCT_ID}}->{ProductName};
			print "MUTS Flag -> Yes  => $CDH::LookUpXRef::hash_master_lookup->{PRODUCT_MASTER}->{$hash_case_product->{PRODUCT_ID}}->{ProductName}\n";
		}
	}
	if( !$boolean_generate_muts_report )
	{
		return;
	}
	my $hash_single_report = {};
	$hash_single_report->{REMARKS_PAGE_2_COUNTER} = 0;
	$hash_single_report->{REMARKS_PAGE_3} = "";
	$hash_single_report->{REMARKS_PAGE_3_COUNTER} = 0;
	$hash_single_report->{REMARKS_PAGE_4} = "";
	$hash_single_report->{QUESTION_NUMBERS} = {};
	my $str_stateid_formid = $hash_single_form->{IssueState}.'~'.$hash_single_form->{FormID};
	my $state_filed_form = $CDH::LookUpXRef::hash_master_lookup->{STATE_SPECIFIC_FORM}->{$str_stateid_formid}->{FormPDFName};
	if($state_filed_form eq '')
	{
		my $str_genericstatid_formid = 'Generic~'.$hash_single_form->{FormID};
		$hash_single_report->{STATE_FIELD_FORM} = $CDH::LookUpXRef::hash_master_lookup->{STATE_SPECIFIC_FORM}->{$str_genericstatid_formid}->{FormPDFName};
		$hash_single_report->{STATE_FIELD_FORMNAME} = $CDH::LookUpXRef::hash_master_lookup->{STATE_SPECIFIC_FORM}->{$str_genericstatid_formid}->{FormName};
		$hash_single_report->{STATE_FIELD_UWCOMPANYNAME} = $CDH::LookUpXRef::hash_master_lookup->{STATE_SPECIFIC_FORM}->{$str_genericstatid_formid}->{UnderwritingcompanyName};
		$hash_single_report->{STATE_FIELD_UWCOMPANYLOCATION} = $CDH::LookUpXRef::hash_master_lookup->{STATE_SPECIFIC_FORM}->{$str_genericstatid_formid}->{UnderwritingCompanyLocation};
		$hash_single_report->{STATE_FIELD_PLANAMINOFFICE} = $CDH::LookUpXRef::hash_master_lookup->{STATE_SPECIFIC_FORM}->{$str_genericstatid_formid}->{PlanAdministrativeOffice};
	}
	else
	{
		$hash_single_report->{STATE_FIELD_FORM} = $CDH::LookUpXRef::hash_master_lookup->{STATE_SPECIFIC_FORM}->{$str_stateid_formid}->{FormPDFName};
		$hash_single_report->{STATE_FIELD_FORMNAME} = $CDH::LookUpXRef::hash_master_lookup->{STATE_SPECIFIC_FORM}->{$str_stateid_formid}->{FormName};
		$hash_single_report->{STATE_FIELD_UWCOMPANYNAME} = $CDH::LookUpXRef::hash_master_lookup->{STATE_SPECIFIC_FORM}->{$str_stateid_formid}->{UnderwritingcompanyName};
		$hash_single_report->{STATE_FIELD_UWCOMPANYLOCATION} = $CDH::LookUpXRef::hash_master_lookup->{STATE_SPECIFIC_FORM}->{$str_stateid_formid}->{UnderwritingCompanyLocation};
		$hash_single_report->{STATE_FIELD_PLANAMINOFFICE} = $CDH::LookUpXRef::hash_master_lookup->{STATE_SPECIFIC_FORM}->{$str_stateid_formid}->{PlanAdministrativeOffice};
	}
	## TEMP SECTION START
	print "Form Name:: $state_filed_form\n";
	if($state_filed_form eq '')
	{
		$hash_single_report->{STATE_FIELD_FORM}='../Layouts/G-AppComb-40042.pdf';
		# $hash_single_report->{STATE_FIELD_FORM}='../Layouts/G-APP-40010-V.pdf';
	}
	$hash_single_report->{STATE_FIELD_FORM}='../Layouts/G-AppComb-40042.pdf';
	# $hash_single_report->{STATE_FIELD_FORM}='../Layouts/G-APP-40010-V.pdf';
	##TEMP SECTION DONE
	build_MUTS_cover_page1($hash_single_form, $hash_single_report,$str_process_type_key,$hash_eoi_current_application);
	build_muts_product_details_page1($hash_single_form, $hash_single_report);
	build_muts_demographic_page2( $hash_single_form, $hash_single_report );
	build_muts_questions_page3( $hash_single_form, $hash_single_report );
	build_muts_beneficiaries_page4( $hash_single_form, $hash_single_report );
	build_muts_agent_page( $hash_single_form, $hash_single_report );
	#EOI_Phase_2_1::End - Ponmani
	push @{$reference_array_muts_reports}, $hash_single_report;
}


sub notify_underwriters
{
	my $int_number_of_files = shift;
	my $str_muts_path = shift;
	my $str_case_id = shift;
	
	my $hash_output_configuration = {};
	my $str_single_product_line = '';
	my $str_contact_cdh = $CDH::Common::CONFIG->param("_EMAIL_RECIPIENTS_CDH_NOTIFICATIONS_IT");
	my $str_contact_business = $CDH::Common::CONFIG->param("_CONTACT_INFORMATION_BUSINESS");
	my $str_case_name = $CDH::LookUpXRef::hash_master_lookup->{ENROLLMENT_SYSTEMS}->{$str_case_id}->{CASE_NAME};
	my $str_eoi_case_flag = $CDH::LookUpXRef::hash_master_lookup->{ENROLLMENT_SYSTEMS}->{$str_case_id}->{EOI_LOOKUP};

	my $str_template_muts_email_message = "There are <b>_VALUE_NUMBER_OF_FILES</b> new application(s) from CDH, requiring medical underwriting in the following location: <br/><br/>";
	$str_template_muts_email_message.= "<h>_VALUE_MUTS_DESTINATION_PATH</h></br/>";
	$str_template_muts_email_message.= "<br/>Online EOI case:<b>_VALUE_EOI_YES_OR_NO</b><br/>";
	$str_template_muts_email_message.= "<br><font color='blue'><u>Products and their Destinations</u></font><br/><br/>";
	$str_template_muts_email_message.= "<table border=1 bordercolor='black' valign=middle cellspacing=0 ><tr align=center bgcolor='#D3D3D3'><th>Product Name</td><th>Destination</td><th>Administered Location</td></tr>";

	$str_template_muts_email_message.= "_VALUE_TABLE_ROWS</table><br/>";
	$str_template_muts_email_message.= "For HPS cases:<br/>When a case is HPS administered, CDH will generate a PDF for each app in the incoming data file. HPS will then send handoff sheets for the apps that need underwriting review. Medical UW picks out those apps from the full set of files, CDH put on the network drive.<br/><br/>";
	$str_template_muts_email_message.= "For Neptune administered cases:<br/>When a case is Neptune administered, CDH will generate a PDF for each app in the incoming data file. CDH isn’t aware of the Medical UW requirements, so medical underwriting needs to review all the applications to determine if underwriting review is required.<br/><br/>";
	$str_template_muts_email_message.= "For Online EOI cases:<br/>For Online EOI cases, CDH will generate PDFs only for applicants that require medical UW review.<br/><br/>";
	$str_template_muts_email_message.= "Contact:<br/>CustomerDataHub: <a>_VALUE_CONTACT_DETAILS_CDH</a><br/>Enrollment Technology: <h>_VALUE_CONTACT_DETAILS_BUSINESS</h><br/>";

	my $str_template_muts_email_table_single_row = "<tr align=center><td align=left>_VALUE_PRODUCT_NAME</td><td>_VALUE_DESTINATION</td><td>_VALUE_ADMIN_LOCATION</td></tr>";

	my $str_email_notification_message = $str_template_muts_email_message;

	$str_email_notification_message =~ s/_VALUE_NUMBER_OF_FILES/$int_number_of_files/g;
	$str_email_notification_message =~ s/_VALUE_MUTS_DESTINATION_PATH/$str_muts_path/g;
	
	if( $str_eoi_case_flag eq 'N' )
	{
		$str_eoi_case_flag = "No";
	}
	else
	{
		$str_eoi_case_flag = "Yes";
	}
	$str_email_notification_message =~ s/_VALUE_EOI_YES_OR_NO/$str_eoi_case_flag/g;

	my $str_table_all_rows = "";
	foreach my $str_product( sort keys %{$global_hash_muts_products_for_current_move} )
	{
		my $str_table_single_row = $str_template_muts_email_table_single_row;
		$str_table_single_row =~ s/_VALUE_PRODUCT_NAME/$global_hash_muts_products_for_current_move->{$str_product}/g;
		my @array_output_destination = ();
		my @array_admin_location = ();
		my $str_output_destination = "";
		my $hash_output_configuration = CDH::LookUpXRef::get_output_configuration( $str_case_id, $str_product);
		foreach my $str_output_format ( keys  %{$hash_output_configuration} )
		{
			if ($str_output_format eq 'eoiMax')
			{
				next;
			}
			foreach $str_output_destination( sort keys %{$hash_output_configuration->{$str_output_format}} )
			{
				my $str_admin_location = find_admin_location($str_output_destination);				
				push @array_output_destination, $str_output_destination;
				push @array_admin_location, $str_admin_location;
			}
		}
		my $str_tbl_output_destination = join(',', @array_output_destination);
		my $str_tbl_admin_location = join(',', @array_admin_location);
		$str_table_single_row =~ s/_VALUE_DESTINATION/$str_tbl_output_destination/g;
		$str_table_single_row =~ s/_VALUE_ADMIN_LOCATION/$str_tbl_admin_location/g;
		$str_table_all_rows.= $str_table_single_row;
	}
	$str_email_notification_message =~ s/_VALUE_TABLE_ROWS/$str_table_all_rows/g;

	$str_email_notification_message =~ s/_VALUE_CONTACT_DETAILS_CDH/$str_contact_cdh/g;
	$str_email_notification_message =~ s/_VALUE_CONTACT_DETAILS_BUSINESS/$str_contact_business/g;

	eval
	{
		send_mail( $str_email_notification_message, $CDH::Common::CONFIG->param('_REGION')."MUTS::Electronic Applications for UW - ".
									$str_case_name." - ".$str_case_id,
									$CDH::Common::CONFIG->param('_EMAIL_SENDER_CDH_NOTIFICATIONS'),
									$CDH::Common::CONFIG->param('_EMAIL_RECIPIENTS_MUTS_NOTIFICATIONS') );
		$main::log->info( "CDH::ExtractAdmin::underwriters::Email Sent:".$str_email_notification_message );
	};
	if( $@ )
	{
		$main::log->error("CDH::ExtractAdmin::notify_undwerwriters - Error sending email: $str_email_notification_message");
		$main::log->error($@);
	}
}

sub reset_variables
{
	$global_hash_muts_products_for_current_move = {};

}
####################################################################################################################################################
#Defect/User Story		Developer		Description
#13391 				    Muralikumar A	Waiting period calculation for 606,607
####################################################################################################################################################
#EOI_Phase_2_1::Begin - Ponmani
sub build_MUTS_cover_page1
{
	my $hash_current_form = shift;
	my $hash_current_report = shift;
	my $str_process_type_key = shift;
	my $hash_eoi_current_application = shift;

	my $str_case_id = $hash_current_form->{CaseID};
	my $str_product_MUTS = '';
	my @array_e3groupnumbers = ();
	my $boolean_GTL_exists_601_104 = 0;
	my $boolean_GTL_exists_611_110 = 0;
	my $boolean_GTL_exists_106_606 = 0;
	my $boolean_GTL_exists_107_607 = 0;
	my $str_eligibility_waiting_period_601_104 = "";
	my $str_eligibility_waiting_period_611_110 = "";
	my $str_eligibility_waiting_period_106_606 = "";
	my $str_eligibility_waiting_period_107_607 = "";
	my $str_unique_identifier = '';

	foreach my $str_product_sequence( sort keys %{$hash_current_form->{products}} )
	{
		my $hash_single_product = $hash_current_form->{products}->{$str_product_sequence};
		my $str_e3groupnumber = CDH::LookUpXRef::get_code_manager_group_number( $str_case_id,$hash_single_product->{ProductID} );
		if ( $str_e3groupnumber ne '')
		{
			push @array_e3groupnumbers, $str_e3groupnumber;
		}
	}
	$hash_current_report->{SUBMIT_DATE} = get_formatted_current_date( "MM/DD/YYYY" ); 
	$hash_current_report->{RECEIVED_DATE} = get_formatted_current_date( "MM/DD/YYYY" ); 
	$hash_current_report->{GROUP_NUMBERS} = join(',', @array_e3groupnumbers);
	my @array_eoi_product_ids = ();
	my $str_class_name = '';
	if ($str_process_type_key eq "EOI_Processing")
	{
		@array_eoi_product_ids = split("~",$hash_eoi_current_application->{ProductID});
	}
	foreach my $str_product_sequence( sort keys %{$hash_current_form->{products}} )
	{
		my $hash_single_product = $hash_current_form->{products}->{$str_product_sequence};
		if ($hash_single_product->{ProductID} eq $array_eoi_product_ids[0] )
		{
			$str_class_name = $hash_single_product->{iMaxClass};
		}
	}
	$hash_current_report->{CLASS} = $str_class_name;
	$hash_current_report->{GROUP_NAME} = $CDH::LookUpXRef::hash_master_lookup->{EOI_GE_CASE_LEVEL_DATA}->{$str_case_id}->{GROUPNAME};
	$hash_current_report->{GROUP_CONTACT_NAME} = $CDH::LookUpXRef::hash_master_lookup->{ENROLLMENT_SYSTEMS}->{$str_case_id}->{GROUP_CONTACT_NAME};
	$hash_current_report->{GROUP_CONTACT_PHONE_NUMBER} = $CDH::LookUpXRef::hash_master_lookup->{ENROLLMENT_SYSTEMS}->{$str_case_id}->{PHONE_NUMBER};
	$hash_current_report->{GROUP_CONTACT_ADDRESS} = $CDH::LookUpXRef::hash_master_lookup->{EOI_GE_CASE_LEVEL_DATA}->{$str_case_id}->{GROUPADDRESS};
	$hash_current_report->{GROUP_EFFECTIVE_DATE} =  get_formatted_date( $CDH::LookUpXRef::hash_master_lookup->{EOI_GROUP_EFFECTIVE_DATE}->{$str_case_id}->{GROUP_EFFECTIVE_DATE}, "YYYY-MM-DD", "MM/DD/YYYY" );
	$hash_current_report->{PERSON_TITLE_COMPANY} = $CDH::LookUpXRef::hash_master_lookup->{PERSON_TITLE_COMPANY}->{$str_case_id}->{PERSON_TITLE_COMPANY};

	my $hash_employee_person = $hash_current_form->{Persons}->{$hash_current_form->{EmployeeIdentifier}};
	if ($hash_current_form->{Key_ID_Field} eq '1')
	{
		$str_unique_identifier =  $hash_employee_person->{SSN};
	}
	elsif ($hash_current_form->{Key_ID_Field} eq '2')
	{
		$str_unique_identifier =  $hash_employee_person->{EmployeeNumber};
	}
	$hash_current_report->{APPLICANT_NAME} = $hash_employee_person->{FirstName}." ".$hash_employee_person->{LastName};
	my $int_coverage_counter = 0;
	my $database_handle_redi = CDH::Common::open_connection( $CDH::Common::CONFIG->param('_DATABASE_DSN_REDI'));
	my $str_jobclass = CDH::LookUpXRef::get_jobclass_from_redi( $database_handle_redi,$str_case_id,$hash_employee_person->{SSN} );
	if($CDH::LookUpXRef::hash_master_lookup->{ENROLLMENT_SYSTEMS}->{$str_case_id}->{BILLING_FLAG} eq "Self")
	{
		$hash_current_report->{BILLING_LOCATION}= "Self-Bill";
	}
	else
	{
		if($hash_current_form->{FormID} == 300)
		{
			$hash_current_report->{BILLING_LOCATION}= "Tampa";
		}
		elsif($hash_current_form->{FormID} == 900)
		{
			$hash_current_report->{BILLING_LOCATION}= "Amarillo";
		}
	}
	foreach my $str_product_sequence( sort keys %{$hash_current_form->{products}} )
	{
		my $int_coverage_index = $int_coverage_counter;
		my $hash_single_product = $hash_current_form->{products}->{$str_product_sequence};
		if($CDH::LookUpXRef::hash_master_lookup->{ENROLLMENT_SYSTEMS}->{$str_case_id}->{BILLING_FLAG} eq "Self")
		{
			$str_product_MUTS = $hash_single_product->{ProductID}."~Self";
		}
		else
		{
			$str_product_MUTS = $hash_single_product->{ProductID}."~List";
		}
		my $str_coverage = $global_hash_muts_preferred_products->{$str_product_MUTS};
		if( exists $hash_current_report->{COVERAGES}->{$str_coverage} )
		{
			$int_coverage_index = $hash_current_report->{COVERAGES}->{$str_coverage};
		}
		else
		{
			$int_coverage_index = ++$int_coverage_counter;
			$hash_current_report->{COVERAGES}->{$str_coverage} = $int_coverage_index;
		}
	
		$hash_current_report->{"COVERAGE_".$int_coverage_index} = $str_coverage;
		$hash_current_report->{"PRODUCT_EFFECTIVE_DATE_".$int_coverage_index} = $hash_single_product->{EffectiveDate};
		$hash_current_report->{"POLICY_".$int_coverage_index}= CDH::LookUpXRef::get_code_manager_group_number( $str_case_id,$hash_single_product->{ProductID} );
		
		if ($hash_single_product->{ProductID} eq '601' || $hash_single_product->{ProductID} eq '104')
		{
			$boolean_GTL_exists_601_104 = 1;
			$str_eligibility_waiting_period_601_104 = CDH::LookUpXRef::get_ge_waiting_period( $str_case_id, $hash_single_product->{ProductID},$str_jobclass );
		}
		elsif ($hash_single_product->{ProductID} eq '611' || $hash_single_product->{ProductID} eq '110')
		{
			$boolean_GTL_exists_611_110 = 1;
			$str_eligibility_waiting_period_611_110 = CDH::LookUpXRef::get_ge_waiting_period( $str_case_id, $hash_single_product->{ProductID},$str_jobclass );
		}
		elsif ($hash_single_product->{ProductID} eq '106' || $hash_single_product->{ProductID} eq '606')
		{
			$boolean_GTL_exists_106_606 = 1;
			$str_eligibility_waiting_period_106_606 = CDH::LookUpXRef::get_ge_waiting_period( $str_case_id, '106',$str_jobclass );
		}
		elsif ($hash_single_product->{ProductID} eq '107' || $hash_single_product->{ProductID} eq '607')
		{
			$boolean_GTL_exists_107_607 = 1;
			$str_eligibility_waiting_period_107_607 = CDH::LookUpXRef::get_ge_waiting_period( $str_case_id, '107',$str_jobclass );
		}

		populate_face_amounts( $hash_current_report, $hash_current_form, $hash_single_product, $int_coverage_index );

		if( $hash_current_report->{"REQUESTED_AMOUNT_EE_".$int_coverage_index} ne "" &&
			!exists $hash_current_report->{"GI_AMOUNT_".$int_coverage_index}
		)
		{
			$hash_current_report->{"GI_AMOUNT_".$int_coverage_index} = CDH::LookUpXRef::get_ge_gi_amount( $str_case_id, $hash_single_product->{ProductID},$str_jobclass, "1" );
		}

		if( $hash_current_report->{"REQUESTED_AMOUNT_SP_".$int_coverage_index} ne "" &&
			( !exists $hash_current_report->{"GI_AMOUNT_SP_".$int_coverage_index} ||
				$hash_current_report->{"GI_AMOUNT_SP_".$int_coverage_index} eq "" )
		)
		{
			$hash_current_report->{"GI_AMOUNT_SP_".$int_coverage_index} = CDH::LookUpXRef::get_ge_gi_amount( $str_case_id, $hash_single_product->{ProductID},$str_jobclass, "2" );
		}

		if( $hash_current_report->{"REQUESTED_AMOUNT_CH_".$int_coverage_index} ne "" &&
			( !exists $hash_current_report->{"GI_AMOUNT_CH_".$int_coverage_index} ||
				$hash_current_report->{"GI_AMOUNT_CH_".$int_coverage_index} eq "" )
		)
		{
			$hash_current_report->{"GI_AMOUNT_CH_".$int_coverage_index} = CDH::LookUpXRef::get_ge_gi_amount( $str_case_id, $hash_single_product->{ProductID},$str_jobclass, "3" );
		}

		if( $hash_current_report->{"REQUESTED_AMOUNT_EE_".$int_coverage_index} ne "" &&
			( !exists $hash_current_report->{"GRANDFATHERED_AMOUNT_EE_".$int_coverage_index} ||
				$hash_current_report->{"GRANDFATHERED_AMOUNT_EE_".$int_coverage_index} eq "" )
		)
		{
			$hash_current_report->{"GRANDFATHERED_AMOUNT_EE_".$int_coverage_index} = CDH::LookUpXRef::get_grandfathered_amount_employee( $str_case_id, $str_unique_identifier, $hash_single_product->{ProductID} );
		}
		if( $hash_current_report->{"REQUESTED_AMOUNT_SP_".$int_coverage_index} ne "" &&
			( !exists $hash_current_report->{"GRANDFATHERED_AMOUNT_SP_".$int_coverage_index} ||
				$hash_current_report->{"GRANDFATHERED_AMOUNT_SP_".$int_coverage_index} eq "" )
		)
		{
			$hash_current_report->{"GRANDFATHERED_AMOUNT_SP_".$int_coverage_index} = CDH::LookUpXRef::get_grandfathered_amount_spouse( $str_case_id, $str_unique_identifier, $hash_single_product->{ProductID} );
		}
		if( $hash_current_report->{"REQUESTED_AMOUNT_CH_".$int_coverage_index} ne "" &&
			( !exists $hash_current_report->{"GRANDFATHERED_AMOUNT_CH_".$int_coverage_index} ||
				$hash_current_report->{"GRANDFATHERED_AMOUNT_CH_".$int_coverage_index} )
		)
		{
			$hash_current_report->{"GRANDFATHERED_AMOUNT_CH_".$int_coverage_index} = CDH::LookUpXRef::get_grandfathered_amount_children( $str_case_id, $str_unique_identifier, $hash_single_product->{ProductID} );
		}
	}
	if ($boolean_GTL_exists_601_104 eq '1')
	{
		$hash_current_report->{ELIGIBILITY_WAITING_PERIOD} = $str_eligibility_waiting_period_601_104;
	}
	elsif ($boolean_GTL_exists_611_110 eq '1')
	{
		$hash_current_report->{ELIGIBILITY_WAITING_PERIOD} = $str_eligibility_waiting_period_611_110;
	}
	elsif ($boolean_GTL_exists_106_606 eq '1')
	{
		$hash_current_report->{ELIGIBILITY_WAITING_PERIOD} = $str_eligibility_waiting_period_106_606;
	}
	elsif ($boolean_GTL_exists_107_607 eq '1')
	{
		$hash_current_report->{ELIGIBILITY_WAITING_PERIOD} = $str_eligibility_waiting_period_107_607;
	}
}

sub populate_face_amounts
{
	my $hash_current_report = shift;
	my $hash_current_form = shift;
	my $hash_single_product = shift;
	my $int_coverage_index = shift;

	my $hash_person_type_amount_field_names = {
												1 =>
													{
														FIELD_NAME => "EmployeeFaceAmount",
														IDENTIFIER => "EE"
													},
												2 =>
													{
														FIELD_NAME => "SpouseFaceAmount",
														IDENTIFIER => "SP"
													},
												3 =>
													{
														FIELD_NAME => "DependentFaceAmount",
														IDENTIFIER => "CH"
													},
												};
	foreach my $str_person_type( sort keys %{$hash_person_type_amount_field_names} )
	{
		my $str_field_name = $hash_person_type_amount_field_names->{$str_person_type}->{FIELD_NAME};
		my $str_person_type_identifier = $hash_person_type_amount_field_names->{$str_person_type}->{IDENTIFIER};

		if( does_person_type_exist_in_hash( $hash_single_product, $hash_current_form->{Persons}, $str_person_type ) )
		{
			my $str_person_amount = $hash_single_product->{$str_field_name};
			if ( $hash_single_product->{FaceAmount} ne '')
			{
				$str_person_amount = $hash_single_product->{FaceAmount};
			}
			$hash_current_report->{"REQUESTED_AMOUNT_".$str_person_type_identifier."_".$int_coverage_index} = $str_person_amount;
		}
	}
}

sub build_muts_demographic_page2
{
	my $hash_current_form = shift;
	my $hash_current_report = shift;

	my $int_child_counter = 1;
	$hash_current_report->{CHECKBOX_NEW_COVERAGE} = 'Yes';
	$hash_current_report->{EMPLOYER_NAME} = $CDH::LookUpXRef::hash_master_lookup->{ENROLLMENT_SYSTEMS}->{$hash_current_form->{CaseID}}->{CASE_NAME};
	$hash_current_report->{FORM_NUMBER} = $CDH::LookUpXRef::hash_master_lookup->{FORM_NUMBERS}->{$hash_current_form->{FormID}}->{FILE_FORMAT_NUMBER};
	$hash_current_report->{FORM_ST} = $hash_current_form->{IssueState};
	$hash_current_report->{FORM_DT} = get_formatted_date( $hash_current_form->{TransactionDate}, "YYYY-MM-DD", "MM/DD/YYYY" );
	my $hash_employee_person = $hash_current_form->{Persons}->{$hash_current_form->{EmployeeIdentifier}};
	#Employee Information
	$hash_current_report->{FILE_NAME} = $hash_current_form->{EmployeeIdentifier}."_".upper( $hash_employee_person->{FirstName} )."_".upper( $hash_employee_person->{LastName} )."_".$hash_current_form->{FormSeq}.".pdf";
	$hash_current_report->{EE_FNAME} = $hash_employee_person->{FirstName};
	$hash_current_report->{EE_MI} = $hash_employee_person->{MiddleName};
	$hash_current_report->{EE_LNAME} = $hash_employee_person->{LastName};
	$hash_current_report->{EMPLOYEE_FULLNAME} = $hash_employee_person->{FirstName}.' '.$hash_employee_person->{MiddleName}.' '.$hash_employee_person->{LastName}.' '.$hash_employee_person->{Honorific};
	$hash_current_report->{EE_ADDRESS_1} = $hash_employee_person->{AddressLine1};
	$hash_current_report->{EE_CITY} = $hash_employee_person->{City};
	$hash_current_report->{EE_STATE} = $hash_employee_person->{State};
	$hash_current_report->{EE_ZIP} = $hash_employee_person->{Zip};
	$hash_current_report->{EE_HOME_PHONE} = $hash_employee_person->{HomePhone};
	$hash_current_report->{EE_HOME_ADDRESS} = $hash_employee_person->{AddressLine1}.' '.$hash_employee_person->{City}.' '.$hash_employee_person->{State}.' '.$hash_employee_person->{Zip}.' '.$hash_employee_person->{HomePhone};
	$hash_current_report->{EE_SALARY} = commify( $hash_employee_person->{Salary} );
	$hash_current_report->{EE_HIRE_DATE} = get_formatted_date( $hash_employee_person->{DateHire}, "YYYY-MM-DD", "MM/DD/YYYY" );
	$hash_current_report->{EE_JOB_TITLE} = $hash_employee_person->{JobTitle};
	$hash_current_report->{EE_NAME} = get_component_value( $hash_employee_person, "1000,1001,1002" );
	$hash_current_report->{EE_AGE} = $hash_employee_person->{PersonIssueAge};
	$hash_current_report->{EE_DOB} = get_formatted_date( $hash_employee_person->{DateBirth}, "YYYY-MM-DD", "MM/DD/YYYY" );
	$hash_current_report->{EE_SEX} = $hash_employee_person->{Sex};
	$hash_current_report->{EE_PLACEOFBIRTH} = CDH::ExtractCommon::get_place_of_birth( $hash_employee_person );
	$hash_current_report->{EE_HEIGHTFEET} = $hash_employee_person->{HeightFeet};
	$hash_current_report->{EE_HEIGHTINCHES} = $hash_employee_person->{HeightInches};
	$hash_current_report->{EE_WEIGHT} = $hash_employee_person->{WeightPounds};
	$hash_current_report->{EE_SSN} = get_formatted_ssn( $hash_employee_person->{SSN}, "AAAGGSSSS", "AAA-GG-SSSS" );
	$hash_current_report->{DIVISION} = $hash_employee_person->{Division};
	$hash_current_report->{EE_EMAIL_ADDRESS}=$hash_employee_person->{EmailAddress};
	if($hash_employee_person->{ActivelyWorkIndicator} eq 'Y')
	{
		$hash_current_report->{CHECKBOX_ACTIVELY_WORK_YES} = 'Yes';
	}
	else
	{
		$hash_current_report->{CHECKBOX_ACTIVELY_WORK_NO} = 'Yes';
	}
	#Spouse Information
	my $str_spouse_person_identifier = get_spouse_person_identifier( $hash_current_form->{Persons} );
	if( $str_spouse_person_identifier ne "" )
	{
		my $hash_spouse_person = $hash_current_form->{Persons}->{$str_spouse_person_identifier};
		$hash_current_report->{SPS_NAME} = get_component_value( $hash_spouse_person, "1000,1001,1002" );
		$hash_current_report->{SPS_AGE} = $hash_spouse_person->{PersonIssueAge};
		$hash_current_report->{SPS_DOB} = get_formatted_date( $hash_spouse_person->{DateBirth}, "YYYY-MM-DD", "MM/DD/YYYY" );
		$hash_current_report->{SPS_SEX} = $hash_spouse_person->{Sex};
		$hash_current_report->{SPS_PLACEOFBIRTH} = CDH::ExtractCommon::get_place_of_birth( $hash_spouse_person );
		$hash_current_report->{SPS_HEIGHTFEET} = $hash_spouse_person->{HeightFeet};
		$hash_current_report->{SPS_HEIGHTINCHES} = $hash_spouse_person->{HeightInches};
		$hash_current_report->{SPS_WEIGHT} = $hash_spouse_person->{WeightPounds};
		$hash_current_report->{SPS_SSN} = get_formatted_ssn( $hash_spouse_person->{SSN}, "AAAGGSSSS", "AAA-GG-SSSS" );
	}

	#Children Infomation
	my $hash_persons_in_form_by_sequence = get_persons_by_sequence( $hash_current_form->{Persons}, "3" );
	foreach my $str_person_sequence( sort keys %{$hash_persons_in_form_by_sequence} )
	{
		my $hash_single_person = $hash_persons_in_form_by_sequence->{$str_person_sequence};

		if( $int_child_counter == 1 )
		{
			$hash_current_report->{CH_NAME1} = get_component_value( $hash_single_person, "1000,1001,1002" );
			$hash_current_report->{CH_AGE1} = $hash_single_person->{PersonIssueAge};
			$hash_current_report->{CH_DOB1} = get_formatted_date( $hash_single_person->{DateBirth}, "YYYY-MM-DD", "MM/DD/YYYY" );
			$hash_current_report->{CH_SEX1} = $hash_single_person->{Sex};
			$hash_current_report->{CH_PLACEOFBIRTH1} = CDH::ExtractCommon::get_place_of_birth( $hash_single_person );
			$hash_current_report->{CH_HEIGHTFEET1} = $hash_single_person->{HeightFeet};
			$hash_current_report->{CH_HEIGHTINCHES1} = $hash_single_person->{HeightInches};
			$hash_current_report->{CH_WEIGHT1} = $hash_single_person->{WeightPounds};
			#$hash_current_report->{CH_SSN1} = get_formatted_ssn( $hash_single_person->{SSN}, "AAAGGSSSS", "AAA-GG-SSSS" );
			$hash_current_report->{_VALUE_CHILD_ONE_PERSON_IDENTIFIER} = $hash_single_person->{PersonIdentifier};
		}	
		if( $int_child_counter == 2 )
		{					
			$hash_current_report->{CH_NAME2} = get_component_value( $hash_single_person, "1000,1001,1002" );
			$hash_current_report->{CH_AGE2} = $hash_single_person->{PersonIssueAge};
			$hash_current_report->{CH_DOB2} = get_formatted_date( $hash_single_person->{DateBirth}, "YYYY-MM-DD", "MM/DD/YYYY" );
			$hash_current_report->{CH_SEX2} = $hash_single_person->{Sex};
			$hash_current_report->{CH_PLACEOFBIRTH2} = CDH::ExtractCommon::get_place_of_birth( $hash_single_person );
			$hash_current_report->{CH_HEIGHTFEET2} = $hash_single_person->{HeightFeet};
			$hash_current_report->{CH_HEIGHTINCHES2} = $hash_single_person->{HeightInches};
			$hash_current_report->{CH_WEIGHT2} = $hash_single_person->{WeightPounds};
			#$hash_current_report->{CH_SSN2} = get_formatted_ssn( $hash_single_person->{SSN}, "AAAGGSSSS", "AAA-GG-SSSS" );
			$hash_current_report->{_VALUE_CHILD_TWO_PERSON_IDENTIFIER} = $hash_single_person->{PersonIdentifier};
		}					
		if( $int_child_counter == 3 )
		{
			$hash_current_report->{CH_NAME3} = get_component_value( $hash_single_person, "1000,1001,1002" );
			$hash_current_report->{CH_AGE3} = $hash_single_person->{PersonIssueAge};
			$hash_current_report->{CH_DOB3} = get_formatted_date( $hash_single_person->{DateBirth}, "YYYY-MM-DD", "MM/DD/YYYY" );
			$hash_current_report->{CH_SEX3} = $hash_single_person->{Sex};
			$hash_current_report->{CH_PLACEOFBIRTH3} = CDH::ExtractCommon::get_place_of_birth( $hash_single_person );
			$hash_current_report->{CH_HEIGHTFEET3} = $hash_single_person->{HeightFeet};
			$hash_current_report->{CH_HEIGHTINCHES3} = $hash_single_person->{HeightInches};
			$hash_current_report->{CH_WEIGHT3} = $hash_single_person->{WeightPounds};
			#$hash_current_report->{CH_SSN3} = get_formatted_ssn( $hash_single_person->{SSN}, "AAAGGSSSS", "AAA-GG-SSSS" );
			$hash_current_report->{_VALUE_CHILD_THREE_PERSON_IDENTIFIER} = $hash_single_person->{PersonIdentifier};
		}						
		if( $int_child_counter == 4 )
		{
			$hash_current_report->{CH_NAME4} = get_component_value( $hash_single_person, "1000,1001,1002" );
			$hash_current_report->{CH_AGE4} = $hash_single_person->{PersonIssueAge};
			$hash_current_report->{CH_DOB4} = get_formatted_date( $hash_single_person->{DateBirth}, "YYYY-MM-DD", "MM/DD/YYYY" );
			$hash_current_report->{CH_SEX4} = $hash_single_person->{Sex};
			$hash_current_report->{CH_PLACEOFBIRTH4} = CDH::ExtractCommon::get_place_of_birth( $hash_single_person );
			$hash_current_report->{CH_HEIGHTFEET4} = $hash_single_person->{HeightFeet};
			$hash_current_report->{CH_HEIGHTINCHES4} = $hash_single_person->{HeightInches};
			$hash_current_report->{CH_WEIGHT4} = $hash_single_person->{WeightPounds};
			#$hash_current_report->{CH_SSN4} = get_formatted_ssn( $hash_single_person->{SSN}, "AAAGGSSSS", "AAA-GG-SSSS" );
			$hash_current_report->{_VALUE_CHILD_FOUR_PERSON_IDENTIFIER} = $hash_single_person->{PersonIdentifier};
		}						
		if( $int_child_counter == 5 )
		{
			$hash_current_report->{CH_NAME5} = get_component_value( $hash_single_person, "1000,1001,1002" );
			$hash_current_report->{CH_AGE5} = $hash_single_person->{PersonIssueAge};
			$hash_current_report->{CH_DOB5} = get_formatted_date( $hash_single_person->{DateBirth}, "YYYY-MM-DD", "MM/DD/YYYY" );
			$hash_current_report->{CH_SEX5} = $hash_single_person->{Sex};
			$hash_current_report->{CH_PLACEOFBIRTH5} = CDH::ExtractCommon::get_place_of_birth( $hash_single_person );
			$hash_current_report->{CH_HEIGHTFEET5} = $hash_single_person->{HeightFeet};
			$hash_current_report->{CH_HEIGHTINCHES5} = $hash_single_person->{HeightInches};
			$hash_current_report->{CH_WEIGHT5} = $hash_single_person->{WeightPounds};
			#$hash_current_report->{CH_SSN5} = get_formatted_ssn( $hash_single_person->{SSN}, "AAAGGSSSS", "AAA-GG-SSSS" );
			$hash_current_report->{_VALUE_CHILD_FIVE_PERSON_IDENTIFIER} = $hash_single_person->{PersonIdentifier};
		}	
		if( $int_child_counter == 6 )
		{
			$hash_current_report->{CH_NAME6} = get_component_value( $hash_single_person, "1000,1001,1002" );
			$hash_current_report->{CH_AGE6} = $hash_single_person->{PersonIssueAge};
			$hash_current_report->{CH_DOB6} = get_formatted_date( $hash_single_person->{DateBirth}, "YYYY-MM-DD", "MM/DD/YYYY" );
			$hash_current_report->{CH_SEX6} = $hash_single_person->{Sex};
			$hash_current_report->{CH_PLACEOFBIRTH6} = CDH::ExtractCommon::get_place_of_birth( $hash_single_person );
			$hash_current_report->{CH_HEIGHTFEET6} = $hash_single_person->{HeightFeet};
			$hash_current_report->{CH_HEIGHTINCHES6} = $hash_single_person->{HeightInches};
			$hash_current_report->{CH_WEIGHT6} = $hash_single_person->{WeightPounds};
			#$hash_current_report->{CH_SSN6} = get_formatted_ssn( $hash_single_person->{SSN}, "AAAGGSSSS", "AAA-GG-SSSS" );
			$hash_current_report->{_VALUE_CHILD_SIX_PERSON_IDENTIFIER} = $hash_single_person->{PersonIdentifier};
		}
		$int_child_counter++;
	}
}

sub build_muts_product_details_page1
{
	my $hash_current_form = shift;
	my $hash_current_report = shift;
	$hash_current_report->{EE_LIFE_AMT} = get_muts_face_amount( get_preferred_product_for_muts( $hash_current_form, {"1"=>"112","2"=>"104","3"=>"611","4"=>"601"}, "1" ) );
	$hash_current_report->{EE_ADD_AMT} = get_muts_face_amount( get_preferred_product_for_muts( $hash_current_form, {"1"=>"111","2"=>"105"}, "1" ) );
	$hash_current_report->{EE_LTD_AMT} = get_component_value( get_preferred_product_for_muts( $hash_current_form, {"1"=>"106"}, "1" ), "2055" );
	$hash_current_report->{EE_STD_AMT} = get_muts_face_amount( get_preferred_product_for_muts( $hash_current_form, {"1"=>"107"}, "1" ) );
	$hash_current_report->{SPS_LIFE_AMT} = get_muts_face_amount( get_preferred_product_for_muts( $hash_current_form, {"1"=>"113","2"=>"110","3"=>"614","4"=>"612","5"=>"604","6"=>"602"}, "2" ) );
	
	$hash_current_report->{EE_CRITICAL_ILLNESS_AMOUNT} = get_muts_face_amount( get_preferred_product_for_muts( $hash_current_form, {"1"=>"100","2"=>"407","3"=>"500"}, "1" ) );
	$hash_current_report->{SP_CRITICAL_ILLNESS_AMOUNT} = get_muts_face_amount( get_preferred_product_for_muts( $hash_current_form, {"1"=>"100","2"=>"407","3"=>"500"}, "2" ) );
	$hash_current_report->{_CH_LIFE_AMT1} = "Refer to Enrollment Team";
}

sub get_preferred_product_for_muts
{
	my $hash_current_form = shift;
	my $hash_str_product_id_preferences = shift;
	my $str_person_type = shift;
	
	my $boolean_person_type_check = 1;
	if( $str_person_type eq "0" )
	{
		$boolean_person_type_check = 0;
	}
	my $hash_products_in_current_form = $hash_current_form->{products};
	my $hash_no_product_found = {};
	foreach my $str_product_id_key( sort keys %{$hash_str_product_id_preferences} )
	{
		my $str_preferred_product_id = $hash_str_product_id_preferences->{$str_product_id_key};
		foreach my $str_product_sequence( keys %{$hash_products_in_current_form} )
		{
			my $hash_single_product = $hash_products_in_current_form->{$str_product_sequence};
			my $str_product_id = $hash_single_product->{ProductID};
			if( $str_product_id eq $str_preferred_product_id		&&
				is_enrollment( $hash_single_product->{TransactionType} )
			)
			{
				if( $boolean_person_type_check )
				{
					if( does_person_type_exist_in_hash( $hash_single_product, $hash_current_form->{Persons}, $str_person_type ) )
					{
						return $hash_single_product;
					}
				}
				else
				{
					return $hash_single_product;
				}
			}
		}
	}
	return $hash_no_product_found;
}

sub get_muts_face_amount
{
	my $hash_single_product = shift;

	my $str_return_value = "";
	$str_return_value = get_component_value( $hash_single_product, "2062" );	#FaceAmount
=head
	if( $str_return_value eq "" )
	{
		$str_return_value = get_component_value( $hash_single_product, "2004" );	#EmployeeFaceAmount
	}
=cut
	if( $str_return_value ne "" )
	{
		$str_return_value = "\$".commify( $str_return_value );
	}
	return $str_return_value;
}

sub build_muts_questions_page3
{
	my $hash_current_form = shift;
	my $hash_current_report = shift;

	my $hash_employee_person = $hash_current_form->{Persons}->{$hash_current_form->{EmployeeIdentifier}};
	my $int_question_counter = 0;
	$hash_current_report->{SSN_EMPLOYEE_PAGE_3} = get_formatted_ssn( $hash_employee_person->{SSN}, "AAAGGSSSS", "AAA-GG-SSSS" );
	$int_question_counter = build_muts_question_answers( $hash_current_form, $hash_current_report, $hash_current_form->{EmployeeIdentifier}, "EE", $int_question_counter );

	my $str_spouse_person_identifier = get_spouse_person_identifier( $hash_current_form->{Persons} );
	if( $str_spouse_person_identifier ne "" )
	{
		my $hash_spouse_person = $hash_current_form->{Persons}->{$str_spouse_person_identifier};
		$hash_current_report->{SSN_SPOUSE_PAGE_3} = get_formatted_ssn( $hash_spouse_person->{SSN}, "AAAGGSSSS", "AAA-GG-SSSS" );
		$int_question_counter = build_muts_question_answers( $hash_current_form, $hash_current_report, $str_spouse_person_identifier, "SP", $int_question_counter );
	}
	my $str_child_one_person_identifier = get_dependent_person( $hash_current_form->{Persons}, 1 );
	if( $str_child_one_person_identifier ne "" )
	{
		my $hash_child_one_person = $hash_current_form->{Persons}->{$str_child_one_person_identifier};
		$hash_current_report->{SSN_CHILD_1_PAGE_3} = get_formatted_ssn( $hash_child_one_person->{SSN}, "AAAGGSSSS", "AAA-GG-SSSS" );
		$int_question_counter = build_muts_question_answers( $hash_current_form, $hash_current_report, $str_child_one_person_identifier, "CH_1", $int_question_counter );
	}
	my $str_child_two_person_identifier = get_dependent_person( $hash_current_form->{Persons}, 2 );
	if( $str_child_two_person_identifier ne "" )
	{
		my $hash_child_two_person = $hash_current_form->{Persons}->{$str_child_two_person_identifier};
		$hash_current_report->{SSN_CHILD_2_PAGE_3} = get_formatted_ssn( $hash_child_two_person->{SSN}, "AAAGGSSSS", "AAA-GG-SSSS" );
		$int_question_counter = build_muts_question_answers( $hash_current_form, $hash_current_report, $str_child_two_person_identifier, "CH_2", $int_question_counter );
	}
	my $str_child_three_person_identifier = get_dependent_person( $hash_current_form->{Persons}, 3 );
	if( $str_child_three_person_identifier ne "" )
	{
		my $hash_child_three_person = $hash_current_form->{Persons}->{$str_child_three_person_identifier};
		$hash_current_report->{SSN_CHILD_3_PAGE_3} = get_formatted_ssn( $hash_child_three_person->{SSN}, "AAAGGSSSS", "AAA-GG-SSSS" );
		$int_question_counter = build_muts_question_answers( $hash_current_form, $hash_current_report, $str_child_three_person_identifier, "CH_3", $int_question_counter );
	}
	my $str_child_four_person_identifier = get_dependent_person( $hash_current_form->{Persons}, 4 );
	if( $str_child_four_person_identifier ne "" )
	{
		my $hash_child_four_person = $hash_current_form->{Persons}->{$str_child_four_person_identifier};
		$hash_current_report->{SSN_CHILD_4_PAGE_3} = get_formatted_ssn( $hash_child_four_person->{SSN}, "AAAGGSSSS", "AAA-GG-SSSS" );
		$int_question_counter = build_muts_question_answers( $hash_current_form, $hash_current_report, $str_child_four_person_identifier, "CH_4", $int_question_counter );
	}
	my $str_child_five_person_identifier = get_dependent_person( $hash_current_form->{Persons}, 5 );
	if( $str_child_five_person_identifier ne "" )
	{
		my $hash_child_five_person = $hash_current_form->{Persons}->{$str_child_five_person_identifier};
		$hash_current_report->{SSN_CHILD_5_PAGE_3} = get_formatted_ssn( $hash_child_five_person->{SSN}, "AAAGGSSSS", "AAA-GG-SSSS" );
		$int_question_counter = build_muts_question_answers( $hash_current_form, $hash_current_report, $str_child_five_person_identifier, "CH_5", $int_question_counter );
	}
	my $str_child_six_person_identifier = get_dependent_person( $hash_current_form->{Persons}, 6 );
	if( $str_child_six_person_identifier ne "" )
	{
		my $hash_child_six_person = $hash_current_form->{Persons}->{$str_child_six_person_identifier};
		$hash_current_report->{SSN_CHILD_6_PAGE_3} = get_formatted_ssn( $hash_child_six_person->{SSN}, "AAAGGSSSS", "AAA-GG-SSSS" );
		$int_question_counter = build_muts_question_answers( $hash_current_form, $hash_current_report, $str_child_six_person_identifier, "CH_6", $int_question_counter );
	}
}

sub build_muts_beneficiaries_page4
{
	my $hash_single_form = shift;
	my $hash_single_report = shift;

	$hash_single_report->{BENEFICIARY_NAME_PAGE_3} = "";
	foreach my $str_product_sequence( keys %{$hash_single_form->{products}} )
	{
		my $hash_single_product = $hash_single_form->{products}->{$str_product_sequence};

		my $hash_case_product = CDH::LookUpXRef::get_case_product( $hash_single_form->{CaseID}, $hash_single_product->{ProductID} );
		my $str_muts_flag = $hash_case_product->{MUTS_FLAG};

		if( exists $hash_single_product->{beneficiaries} && $str_muts_flag eq "Yes" )
		{
			my $hash_beneficiaries = $hash_single_product->{beneficiaries};
			foreach my $str_beneficiary_sequence( keys %{$hash_beneficiaries} )
			{
				my $hash_single_beneficiary = $hash_beneficiaries->{$str_beneficiary_sequence};
				# $hash_single_report->{BENEFICIARY_NAME_PAGE_3}.= get_component_value( $hash_single_beneficiary, "1000,1001,1002" );
				$hash_single_report->{BENEFICIARY_OF_EMPLOYEE} .= get_component_value( $hash_single_beneficiary, "1000,1001,1002" ).' '.$hash_beneficiaries->{$str_beneficiary_sequence}->{Percentage}.'% ,'.$hash_beneficiaries->{$str_beneficiary_sequence}->{Relationship};
				$hash_single_report->{BENEFICIARY_OF_EMPLOYEE}.= "\n";
			}
		}
	}
}
sub build_muts_agent_page
{
	my $hash_current_form = shift;
	my $hash_current_report = shift;
	$hash_current_report->{AGENT_NAME} = $hash_current_form->{agents}->{1}->{AgentFirstName}.' '.$hash_current_form->{agents}->{1}->{AgentLastName};
	$hash_current_report->{LICENSE_NUMBER} = $hash_current_form->{agents}->{1}->{AgentNumber};
}
sub build_muts_question_answers
{
	my $hash_current_form = shift;
	my $hash_current_report = shift;
	my $str_incoming_person_identifier = shift;
	my $str_question_person_identifier = shift;
	my $int_counter_of_questions = shift;
	my $str_form_id = $hash_current_form->{FormID};
	my $remarks_count = 0;
	my $remarks_additionalpage_flag = 0;
	foreach my $str_question_sequence( sort keys %{$hash_current_form->{questions}} ) 
	{
		if($hash_current_form->{questions}->{$str_question_sequence}->{Answer} eq 'Y'  or $hash_current_form->{questions}->{$str_question_sequence}->{Answer} eq 'y')
		{
			$remarks_count++;
		}
	}
	$remarks_additionalpage_flag = 1 if($remarks_count > 3);
	foreach my $str_question_sequence( sort keys %{$hash_current_form->{questions}} ) 
	{
		$int_counter_of_questions++;
		my $int_question_index = $int_counter_of_questions;
		my $hash_single_question = $hash_current_form->{questions}->{$str_question_sequence};
		my $str_person_identifier = $hash_single_question->{PersonIdentifier};
		my $str_question_answer = $hash_single_question->{Answer};
		my $str_question_number = CDH::LookUpXRef::get_question_number( $str_form_id, $hash_single_question->{QuestionID} );
		if( exists $hash_current_report->{QUESTION_NUMBERS}->{$str_question_number} )
		{
			$int_question_index = $hash_current_report->{QUESTION_NUMBERS}->{$str_question_number};
		}
		else
		{
			$hash_current_report->{QUESTION_NUMBERS}->{$str_question_number} = $int_counter_of_questions;
		}
		if( $str_person_identifier eq $str_incoming_person_identifier )
		{
			#Old Section - Quesitons
			$hash_current_report->{"QUESTION_NUMBER_".$int_question_index} = $str_question_number;
			$hash_current_report->{"ANSWER_".$str_question_person_identifier."_".$int_question_index} = $str_question_answer;
			#Old Section - END
			if(	$str_question_answer eq 'Y' || $str_question_answer eq 'y' )
			{
				$hash_current_report->{"CHECKBOX_ANSWER_".uc($str_question_number).'_'.$str_question_person_identifier."_YES"} = 'Yes';
				build_muts_question_answer_remarks( $hash_current_form, $hash_single_question, $hash_current_report, $int_counter_of_questions, $remarks_additionalpage_flag );
			}
			else
			{
				$hash_current_report->{"CHECKBOX_ANSWER_".uc($str_question_number).'_'.$str_question_person_identifier."_NO"} = 'Yes';
			}			
		}
	}
	return $int_counter_of_questions;
}

sub build_muts_question_answer_remarks
{
	my $hash_current_form = shift;
	my $hash_incoming_question = shift;
	my $hash_current_report = shift;
	my $remarks_additionalpage_flag = shift;
	my $str_question_number = CDH::LookUpXRef::get_question_number( $hash_current_form->{FormID}, $hash_incoming_question->{QuestionID} );
	my $hash_remarks = {};
	if( exists $hash_incoming_question->{Remarks} )
	{
		$hash_remarks = $hash_incoming_question->{Remarks};
		my $hash_person_answered = $hash_current_form->{Persons}->{$hash_incoming_question->{PersonIdentifier}};
		my $str_person_name = get_component_value( $hash_person_answered, "1000,1002" );
		foreach my $str_remark_sequence( sort keys %{$hash_remarks} )
		{
			my $hash_current_remark = {};
			my $hash_single_remark = $hash_remarks->{$str_remark_sequence};
			my $int_remark_counter = ++$hash_current_report->{REMARKS_PAGE_2_COUNTER};
			if($remarks_additionalpage_flag) # If Additional page applicable.
			{
				my $current_remark_array = [];
				push @$current_remark_array , $str_question_number;
				push @$current_remark_array , $str_person_name;
				push @$current_remark_array , $hash_single_remark->{Condition};
				push @$current_remark_array , get_formatted_date( $hash_single_remark->{DateOccurred}, "YYYY-MM-DD", "MM/DD/YYYY" );
				push @$current_remark_array , $hash_single_remark->{Duration};
				push @$current_remark_array , $hash_single_remark->{DegreeOfRecovery};
				push @$current_remark_array , $hash_single_remark->{PhysicalFacilityName};
				# push @$current_remark_array , $hash_single_remark->{PhysicalFacilityAddress1};
				# push @$current_remark_array , $hash_single_remark->{PhysicalFacilityState}." - ".$hash_single_remark->{PhysicalFacilityZip};
				# push @$current_remark_array , $hash_single_remark->{PhysicalFacilityPhone};
				$hash_current_report->{"R_QUESTIONNO1"} = "*";
				$hash_current_report->{"R_NAME1"} = "See additional page of health details.";
				$hash_current_report->{"R_CONDITION1"} = "*";
				$hash_current_report->{"R_DATEOCC1"} = "*";
				$hash_current_report->{"R_DURATION1"} = "*";
				$hash_current_report->{"R_DEGREEREC1"} = "*";
				$hash_current_report->{"R_PHYSICIAN1"} = "*";
				$hash_current_report->{"R_ADDRESSLINE11"} = "*";
				$hash_current_report->{"R_ADDRESSLINE21"} = "*";
				$hash_current_report->{"R_PHONE1"} = "*";
				push $remark_dataArray, $current_remark_array;
				$hash_current_report->{Additonalpage_Remarks} = $remark_dataArray;
			}
			else # No Additonal pages for remarks.
			{
				$hash_current_report->{"R_QUESTIONNO".$int_remark_counter} = $str_question_number;
				$hash_current_report->{"R_NAME".$int_remark_counter} = $str_person_name;
				$hash_current_report->{"R_CONDITION".$int_remark_counter} = $hash_single_remark->{Condition};
				$hash_current_report->{"R_DATEOCC".$int_remark_counter} = get_formatted_date( $hash_single_remark->{DateOccurred}, "YYYY-MM-DD", "MM/DD/YYYY" );
				$hash_current_report->{"R_DURATION".$int_remark_counter} = $hash_single_remark->{Duration};
				$hash_current_report->{"R_DEGREEREC".$int_remark_counter} = $hash_single_remark->{DegreeOfRecovery};
				$hash_current_report->{"R_PHYSICIAN".$int_remark_counter} = $hash_single_remark->{PhysicalFacilityName};
				$hash_current_report->{"R_ADDRESSLINE1".$int_remark_counter} = $hash_single_remark->{PhysicalFacilityAddress1};
				$hash_current_report->{"R_ADDRESSLINE2".$int_remark_counter} = $hash_single_remark->{PhysicalFacilityState}." - ".$hash_single_remark->{PhysicalFacilityZip};
				$hash_current_report->{"R_PHONE".$int_remark_counter} = $hash_single_remark->{PhysicalFacilityPhone};
			}
			
		}		
	}
}

sub add_remark_to_overflow_pages
{
	my $hash_current_report = shift;
	my $str_single_remark = shift;

	if( $hash_current_report->{REMARKS_PAGE_3_COUNTER} < 6 )
	{
		$hash_current_report->{REMARKS_PAGE_3}.= $str_single_remark;
		$hash_current_report->{REMARKS_PAGE_3_COUNTER}++;
	}
	else
	{
		$hash_current_report->{REMARKS_PAGE_4}.= $str_single_remark;
	}
}
#EOI_Phase_2_1::End - Ponmani - Made changes to fetch all questions and answers

sub create_muts_report_files
{
	my $array_muts_reports = shift;
	my $str_location_admin_files = shift;
	my $hash_systems = shift;
	my $str_file_name = "";
	my $int_count_of_reports = 0;
	foreach my $hash_single_report( @{$array_muts_reports} )
	{
		$int_count_of_reports++;
		my $str_muts_layout_file_name = $CDH::Common::CONFIG->param( '_CONFIG_FILE_MUTS_PDF_LAYOUT' ).';'.$hash_single_report->{STATE_FIELD_FORM};
		my $str_output_file_name = $hash_single_report->{FILE_NAME};
		$str_muts_layout_file_name =
		my $boolean_pdf_generated = generate_pdf( $hash_single_report, $str_muts_layout_file_name, $str_location_admin_files, $str_output_file_name, $hash_additionalpages );
		if( $boolean_pdf_generated )
		{
			my $hash_single_muts_file = {FILE_NAME=>$str_output_file_name, RECORD_COUNT=>1};
			push @{$hash_systems->{MUTS}->{MUTS}->{ARRAY_FILES}}, $hash_single_muts_file;
		}
	}
}

1;
