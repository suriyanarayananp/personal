package CDH::LookUpXRef;

use CDH::Common;
use Data::Dumper;
use Exporter;
our @ISA=qw(Exporter);
our @EXPORT=qw();

use strict;
#use Data::Dumper;

our $hash_master_lookup={};

sub init
{
	my $database_handle = shift;

	$main::log->info("CDH::LookUpXRef::init - Begin");
	
	if( ! $hash_master_lookup->{LOOKUP_LOADED} )
	{			
		$hash_master_lookup->{ENROLLMENT_SYSTEMS} = read_enrollment_systems( $database_handle );
		$hash_master_lookup->{CODE_MANAGER_WSE} = read_code_manager_wse( $database_handle );
		$hash_master_lookup->{CODE_MANAGER_GROUP_NUMBERS} = read_code_manager_group_numbers( $database_handle );
		my $database_handle_redi = CDH::Common::open_connection( $CDH::Common::CONFIG->param('_DATABASE_DSN_REDI'));
		$hash_master_lookup->{EOI_GE_CASE_LEVEL_DATA} = read_ge_case_data( $database_handle_redi );
		$hash_master_lookup->{EOI_GE_PRODUCT_GI_AMOUNTS_ALL} = read_ge_gi_amounts_all( $database_handle_redi );
		$hash_master_lookup->{EOI_GE_PRODUCT_GI_AMOUNTS_SPOUSE} = read_ge_gi_amounts_spouse( $database_handle_redi );
		$hash_master_lookup->{EOI_GE_PRODUCT_GI_AMOUNTS_CHILDREN} = read_ge_gi_amounts_children( $database_handle_redi );
		$hash_master_lookup->{EOI_GE_PRODUCT_WAITING_PERIODS} = read_ge_waiting_periods( $database_handle_redi );
		$hash_master_lookup->{EOI_GE_GRANDFATHER_EMPLOYEE} = read_grandfathered_amount_employee( $database_handle_redi );
		$hash_master_lookup->{EOI_GE_GRANDFATHER_SPOUSE} = read_grandfathered_amount_spouse( $database_handle_redi );
		$hash_master_lookup->{EOI_GE_GRANDFATHER_CHILDREN}	= read_grandfathered_amount_children( $database_handle_redi );
		CDH::Common::close_connection( $database_handle_redi );
		$hash_master_lookup->{PRODUCT_MASTER} = read_product_master( $database_handle );		
		$hash_master_lookup->{EOI_COMPONENTS} = read_eoi_components( $database_handle );
		$hash_master_lookup->{EOI_QUESTIONS} = read_eoi_questions( $database_handle );
		$hash_master_lookup->{FORM_NUMBERS} = read_form_numbers( $database_handle );
		$hash_master_lookup->{COMPONENT_MASTER} = read_component_master( $database_handle );
		$hash_master_lookup->{QUESTION_MASTER} = read_question_master( $database_handle );
		$hash_master_lookup->{FORM_GROUPS} = read_form_groups( $database_handle );
		$hash_master_lookup->{PRODUCT_GROUPS} = read_product_groups( $database_handle );
		$hash_master_lookup->{STATE_MASTER} = read_state_master( $database_handle );
		$hash_master_lookup->{RIDER_MASTER} = read_rider_master( $database_handle );
		$hash_master_lookup->{ELEMENT_TYPES} = read_element_types( $database_handle );
		$hash_master_lookup->{CASE_PRODUCTS} = read_case_products( $database_handle );
		$hash_master_lookup->{CASE_PRODUCTS_iMax} = read_case_products_for_imax( $database_handle );
		$hash_master_lookup->{OUTPUT_CONFIG} = read_output_configuration( $database_handle );
		read_add_on_products( $database_handle );
		$hash_master_lookup->{PRODUCT_STATE_FORM} = read_product_state_form(		$database_handle );
		$hash_master_lookup->{FORM_FOR_PRODUCT_STATE} = read_form_for_product_state(	$database_handle );
		$hash_master_lookup->{FORM_QUESTION} = read_form_question(			$database_handle );
		$hash_master_lookup->{PRODUCT_RIDER_PERSON} = read_product_rider_person(	$database_handle );
		$hash_master_lookup->{FIELD_ALLOWED_VALUES} = read_valid_values_for_fields(	$database_handle );
		$hash_master_lookup->{REQUIRED_FIELDS} = read_required_fields(			$database_handle );
		$hash_master_lookup->{TABLE_COLUMNS_FORM}->{TABLE_NAME} = "M_Form";
		$hash_master_lookup->{TABLE_COLUMNS_FORM}->{COLUMNS} = get_columns( $database_handle, 'CDH', $hash_master_lookup->{TABLE_COLUMNS_FORM}->{TABLE_NAME} );
		$hash_master_lookup->{TABLE_COLUMNS_PRODUCT}->{TABLE_NAME} = "M_Product";
		$hash_master_lookup->{TABLE_COLUMNS_PRODUCT}->{COLUMNS}				= get_columns( $database_handle, 'CDH', $hash_master_lookup->{TABLE_COLUMNS_PRODUCT}->{TABLE_NAME} );
		$hash_master_lookup->{TABLE_COLUMNS_PERSON}->{TABLE_NAME}			= "M_Person";
		$hash_master_lookup->{TABLE_COLUMNS_PERSON}->{COLUMNS}				= get_columns( $database_handle, 'CDH', $hash_master_lookup->{TABLE_COLUMNS_PERSON}->{TABLE_NAME} );
		$hash_master_lookup->{TABLE_COLUMNS_FORM_COVERED_PERSON}->{TABLE_NAME}			= "M_Form_Covered_Person";
		$hash_master_lookup->{TABLE_COLUMNS_FORM_COVERED_PERSON}->{COLUMNS}				= get_columns( $database_handle, 'CDH', $hash_master_lookup->{TABLE_COLUMNS_FORM_COVERED_PERSON}->{TABLE_NAME} );
		$hash_master_lookup->{TABLE_COLUMNS_BENEFICIARY}->{TABLE_NAME}		= "M_Beneficiary";
		$hash_master_lookup->{TABLE_COLUMNS_BENEFICIARY}->{COLUMNS}			= get_columns( $database_handle, 'CDH', $hash_master_lookup->{TABLE_COLUMNS_BENEFICIARY}->{TABLE_NAME} );
		$hash_master_lookup->{TABLE_COLUMNS_AUTHORIZATION}->{TABLE_NAME}	= "M_Authorization";
		$hash_master_lookup->{TABLE_COLUMNS_AUTHORIZATION}->{COLUMNS}		= get_columns( $database_handle, 'CDH', $hash_master_lookup->{TABLE_COLUMNS_AUTHORIZATION}->{TABLE_NAME} );
		$hash_master_lookup->{TABLE_COLUMNS_AGENT}->{TABLE_NAME}			= "M_Agent";
		$hash_master_lookup->{TABLE_COLUMNS_AGENT}->{COLUMNS}				= get_columns( $database_handle, 'CDH', $hash_master_lookup->{TABLE_COLUMNS_AGENT}->{TABLE_NAME} );
		$hash_master_lookup->{TABLE_COLUMNS_QUESTION}->{TABLE_NAME}			= "M_Question";
		$hash_master_lookup->{TABLE_COLUMNS_QUESTION}->{COLUMNS}			= get_columns( $database_handle, 'CDH', $hash_master_lookup->{TABLE_COLUMNS_QUESTION}->{TABLE_NAME} );
		$hash_master_lookup->{TABLE_COLUMNS_REMARK}->{TABLE_NAME}			= "M_Remark";
		$hash_master_lookup->{TABLE_COLUMNS_REMARK}->{COLUMNS}				= get_columns( $database_handle, 'CDH', $hash_master_lookup->{TABLE_COLUMNS_REMARK}->{TABLE_NAME} );
		$hash_master_lookup->{TABLE_COLUMNS_RIDER}->{TABLE_NAME}			= "M_Rider";
		$hash_master_lookup->{TABLE_COLUMNS_RIDER}->{COLUMNS}				= get_columns( $database_handle, 'CDH', $hash_master_lookup->{TABLE_COLUMNS_RIDER}->{TABLE_NAME} );
		$hash_master_lookup->{TABLE_COLUMNS_PRODUCT_PERSON}->{TABLE_NAME}	= "M_Product_Person";
		$hash_master_lookup->{TABLE_COLUMNS_PRODUCT_PERSON}->{COLUMNS}		= get_columns( $database_handle, 'CDH', $hash_master_lookup->{TABLE_COLUMNS_PRODUCT_PERSON}->{TABLE_NAME} );
		$hash_master_lookup->{TABLE_COLUMNS_RIDER_PERSON}->{TABLE_NAME}		= "M_Rider_Person";
		$hash_master_lookup->{TABLE_COLUMNS_RIDER_PERSON}->{COLUMNS}		= get_columns( $database_handle, 'CDH', $hash_master_lookup->{TABLE_COLUMNS_RIDER_PERSON}->{TABLE_NAME} );
		$hash_master_lookup->{TABLE_COLUMNS_PIF_LINE_ITEM}->{TABLE_NAME}		= "M_Form_PIF_Line_Item";
		$hash_master_lookup->{TABLE_COLUMNS_PIF_LINE_ITEM}->{COLUMNS}		= get_columns( $database_handle, 'CDH', $hash_master_lookup->{TABLE_COLUMNS_PIF_LINE_ITEM}->{TABLE_NAME} );
		$hash_master_lookup->{CASE_AGENT} 									= read_case_agent(		$database_handle );
		$hash_master_lookup->{SUPPLEMENT_FORM}								= read_form_master_supplemental(	$database_handle );
		$hash_master_lookup->{PRODUCT_GROUP_FORM}							= read_product_group_form( $database_handle );
		$hash_master_lookup->{STATE_SPECIFIC_FORM} 							= read_state_specific_form( $database_handle );
		$hash_master_lookup->{LOOKUP_LOADED}								= 1;
		#DEBUG_POINT - Is lookup loaded
	}
	$main::log->info("CDH::LookUpXRef::init - End");
}

sub is_case_product_valid
{
	my ($c,$p)= @_;
	return $hash_master_lookup->{CASE_PRODUCTS}->{$c}->{$p};
}

sub read_lookup_hash
{
	my $database_handle = shift;
	my $sql = shift;
	my $key = shift;
	my $key2 = shift;
	my $hash_lookup = {};
 	my $sth=$database_handle->prepare($sql);
	$sth->execute();
	if($key2 eq '')
	{
		while(my $h=$sth->fetchrow_hashref())
		{
			$hash_lookup->{$h->{$key}} = $h;
		}
	}
	else
	{
		while(my $h=$sth->fetchrow_hashref())
		{
			
			$hash_lookup->{$h->{$key}.'~'.$h->{$key2}} = $h;
		} 
	}
	$sth->finish();
	
	return $hash_lookup;
}


sub read_form_numbers
{
	my $database_handle = shift;
	my $sql ="SELECT ID, FILEFORMATNUMBER AS FILE_FORMAT_NUMBER, FormGroupID FROM cdh.L_FORM_MASTER";
	my $hash_form_numbers = read_lookup_hash( $database_handle, $sql, "ID" );
	#DEBUG_POINT - Dump $hash_form_numbers
	return $hash_form_numbers;
}

sub read_component_master
{
	my $database_handle = shift;
	my $sql ="SELECT ID, NAME, FIELD_NAME FROM cdh.L_COMPONENT_MASTER";
	my $hash_component_master = read_lookup_hash( $database_handle, $sql, "ID" );
	return $hash_component_master;
}

sub read_question_master
{
	my $database_handle = shift;
	my $sql ="SELECT ID, QUESTIONNAME, QUESTIONDESCRIPTION, CREATEDBY, CREATEDDATE, MODIFIEDBY, MODIFIEDDATE FROM cdh.L_QUESTION_MASTER";
	my $question_master = read_lookup_hash( $database_handle, $sql, "ID" );
	#DEBUG_POINT - Dump $question_master
	return $question_master;
}

sub read_form_groups
{
	my $database_handle = shift;
	my $sql ="SELECT ID, FORMGROUPNAME, CREATEDBY, CREATEDDATE, MODIFIEDBY, MODIFIEDDATE FROM cdh.L_FORM_GROUP";
	my $form_group = read_lookup_hash( $database_handle, $sql, "ID" );
	#DEBUG_POINT - Dump $form_group
	return $form_group;
}

sub read_product_groups
{
	my $database_handle = shift;
	my $sql ="SELECT
					MASTER.ID	ID,
					GROOUP.ProductGroupName	PRODUCT_GROUP,
					GROOUP.ID PRODUCT_GROUP_ID
				FROM
					cdh.L_PRODUCT_GROUP GROOUP,
					cdh.L_PRODUCT_MASTER MASTER
				WHERE
					GROOUP.ID = MASTER.ProductGroup";
	my $product_group = read_lookup_hash( $database_handle, $sql, "ID" );
	#DEBUG_POINT - Dump $product_group
	return $product_group;
}

sub read_feed_admin_login_keys
{
	my $database_handle = shift;
	my $sql ="SELECT
					login_id		LOGIN_ID,
					login_key		LOGIN_KEY
			FROM
				dbo.tbl_login_details
			WHERE
				login_id = 'cdh_export'";
	my $hash_feed_admin_login_keys = read_lookup_hash( $database_handle, $sql, "LOGIN_ID" );
	return $hash_feed_admin_login_keys;
}

sub read_enrollment_systems
{
	my $database_handle = shift;
	my $sql ="SELECT
					ENROLLMENT_SYSTEM.CASENUMBER		CASE_NUMBER,
					ENROLLMENT_SYSTEM.CASENAME			CASE_NAME,
					SYSTEM_MASTER.SYSTEMNAME			SYSTEM_NAME,
					ENROLLMENT_SYSTEM.AGENTLOOKUP		AGENT_LOOKUP,
					ENROLLMENT_SYSTEM.FILETYPE			FILE_TYPE,
					ENROLLMENT_SYSTEM.EOICASEFLAG		EOI_LOOKUP,
					ENROLLMENT_SYSTEM.BILLINGFLAG		BILLING_FLAG,
					ENROLLMENT_SYSTEM.OutputFileType	OUTPUT_FILE_TYPE,
					ENROLLMENT_SYSTEM.SendOutput		SEND_OUTPUT,
					ENROLLMENT_SYSTEM.SITUSStateID		SITUS_STATE,
					ENROLLMENT_SYSTEM.GroupContactName 	GROUP_CONTACT_NAME,
					ENROLLMENT_SYSTEM.PhoneNumber		PHONE_NUMBER
					
				FROM
					CDH.L_SYSTEM_MASTER SYSTEM_MASTER,
					CDH.L_ENROLLMENT_SYSTEM_INFO ENROLLMENT_SYSTEM
				WHERE
					SYSTEM_MASTER.ID = ENROLLMENT_SYSTEM.SYSTEMID
					AND ENROLLMENT_SYSTEM.Status = 1";
	my $hash_enrollment_systems = read_lookup_hash( $database_handle, $sql, "CASE_NUMBER" );
	return $hash_enrollment_systems;
}

sub read_state_master
{
	my $database_handle = shift;
	my $sql ="SELECT ID, STATECODE, DISPLAYNAME, CREATEDBY, CREATEDDATE, MODIFIEDBY, MODIFIEDDATE FROM cdh.L_STATE_MASTER";
	my $state_master = read_lookup_hash( $database_handle, $sql, "ID" );
	return $state_master;
}

sub read_case_agent
{
	my $database_handle = shift;
	my $sql ="SELECT	agent.AGENT_NUMBER
										,((caseid.CaseNumber) + '~' + UPPER(agent.AGENT_LAST_NAME) + '~' + UPPER(agent.AGENT_FIRST_NAME) ) as AGENT_LOOKUP
  					FROM    cdh.L_ENROLLMENT_AGENT 				agent
      							,cdh.L_ENROLLMENT_SYSTEM_INFO caseid
										where   agent.STATUS = 1
										and   agent.ENROLLMENT_SYSTEM_ID = caseid.ID";
	my $case_agent_number = read_lookup_hash( $database_handle, $sql, "AGENT_LOOKUP" );
	return $case_agent_number;
}
sub read_state_specific_form
{
	my $database_handle = shift;
	my $stateid = shift;
	my $formid = shift;
	my $sql = "select * from cdh.L_FORM_STATE_MUTS_XREF";
	my $state_filed_form = read_lookup_hash( $database_handle, $sql, "StateID", "FormID" );
	return $state_filed_form;
}

sub read_form_master_supplemental
{
	my $database_handle = shift;
	my $sql = "SELECT ID FROM cdh.L_FORM_MASTER Where FormType = 2";
	my $supplemental_form = read_lookup_hash( $database_handle, $sql, "ID" );
	return $supplemental_form;
}

sub read_rider_master
{
	my $database_handle = shift;
	my $sql ="SELECT ID, RIDERNAME, CREATEDBY, CREATEDDATE, MODIFIEDBY, MODIFIEDDATE FROM cdh.L_RIDER_MASTER";
	my $rider_master = read_lookup_hash( $database_handle, $sql, "ID" );
	#DEBUG_POINT - Dump $rider_master
	return $rider_master;
}

sub read_element_types
{
	my $database_handle = shift;
	my $sql ="SELECT ID, ELEMENT_NAME, CREATEDBY, CREATEDDATE, MODIFIEDBY, MODIFIEDDATE FROM cdh.L_ELEMENT_TYPES";
	my $element_type = read_lookup_hash( $database_handle, $sql, "ID" );
	return $element_type;
}

sub read_case_products
{
	my $database_handle = shift;
	my $sql ="SELECT
			ENROLLMENT_SYSTEM_INFO.CASENUMBER	CASE_NUMBER,
			PRODUCT_CONFIG.PRODUCT_ID			PRODUCT_ID,
			ParticipationCount					PARTICIPATION_COUNT,
			0									PARTICIPATION_COUNT_CURRENT_RUN,
			MUTSFlag							MUTS_FLAG,
			ProductIdentifier					PRODUCT_IDENTIFIER,
			EmployeeCoveredFlag					EMPLOYEE_COVEREDFLAG,
			iMax_Benefit_Type					IMAX_BENEFIT_TYPE,
			eoiMax_Benefit_Type					EOIMAX_BENEFIT_TYPE
		FROM
			CDH.L_CASE_PRODUCTS			CASE_PRODUCTS,
			CDH.L_PRODUCT_CONFIG			PRODUCT_CONFIG,
			CDH.L_ENROLLMENT_SYSTEM_INFO		ENROLLMENT_SYSTEM_INFO
		WHERE
			CASE_PRODUCTS.PRODUCT_CONFIG_ID = PRODUCT_CONFIG.ID
			AND CASE_PRODUCTS.ENROLLMENT_SYSTEM_NO_ID = ENROLLMENT_SYSTEM_INFO.ID
			AND CASE_PRODUCTS.STATUS = 1
		";
 	my $statement_handle = $database_handle->prepare($sql);
	$statement_handle->execute();
	my $hash_case_products = {};
	while( my $h=$statement_handle->fetchrow_hashref() )
	{
		$hash_case_products->{$h->{CASE_NUMBER}}->{$h->{PRODUCT_ID}} = $h;
	} 
	$statement_handle->finish();
	return $hash_case_products;
}

sub read_case_products_for_imax
{
	my $database_handle = shift;

	my $hash_case_products_imax = {};
	my $sql ="SELECT
			ENROLLMENT_SYSTEM_INFO.CASENUMBER + '~' + CAST( CASE_PRODUCTS.iMax_Benefit_Type AS VARCHAR( 100 ) ) CASE_BENEFIT_KEY,
			 PRODUCT_CONFIG.PRODUCT_ID	PRODUCT_ID
		FROM
			CDH.L_CASE_PRODUCTS			CASE_PRODUCTS,
			CDH.L_PRODUCT_CONFIG			PRODUCT_CONFIG,
			CDH.L_ENROLLMENT_SYSTEM_INFO		ENROLLMENT_SYSTEM_INFO
		WHERE
			CASE_PRODUCTS.PRODUCT_CONFIG_ID = PRODUCT_CONFIG.ID
			AND CASE_PRODUCTS.ENROLLMENT_SYSTEM_NO_ID = ENROLLMENT_SYSTEM_INFO.ID
			AND CASE_PRODUCTS.STATUS = 1
			AND CASE_PRODUCTS.iMax_Benefit_Type IS NOT NULL
		";
	my $hash_case_products_imax = read_lookup_hash( $database_handle, $sql, "CASE_BENEFIT_KEY" );
	return $hash_case_products_imax;
}

sub read_output_configuration
{
	my $database_handle = shift;
	my $sql ="SELECT
			ENROLLMENT_SYSTEM_INFO.CASENUMBER	CASE_NUMBER,
			PRODUCT_CONFIG.PRODUCT_ID			PRODUCT_ID,
			OUTPUT_CONFIG.OutputFormat			OUTPUT_FORMAT,
			OUTPUT_CONFIG.OutputDestination		OUTPUT_DESTINATION
		FROM
			CDH.L_CASE_PRODUCTS					CASE_PRODUCTS,
			CDH.L_CASE_PRODUCTS_OUTPUT_CONFIG	OUTPUT_CONFIG,
			CDH.L_PRODUCT_CONFIG				PRODUCT_CONFIG,
			CDH.L_ENROLLMENT_SYSTEM_INFO		ENROLLMENT_SYSTEM_INFO
		WHERE
			OUTPUT_CONFIG.CASE_PRODUCT_ID = CASE_PRODUCTS.ID
			AND CASE_PRODUCTS.PRODUCT_CONFIG_ID = PRODUCT_CONFIG.ID
			AND CASE_PRODUCTS.ENROLLMENT_SYSTEM_NO_ID = ENROLLMENT_SYSTEM_INFO.ID
			AND CASE_PRODUCTS.STATUS = 1
			AND OUTPUT_CONFIG.STATUS = 1
		";
 	my $statement_handle = $database_handle->prepare($sql);
	$statement_handle->execute();
	my $hash_output_configuration = {};
	while( my $h=$statement_handle->fetchrow_hashref() )
	{
		$hash_output_configuration->{$h->{CASE_NUMBER}}->{$h->{PRODUCT_ID}}->{$h->{OUTPUT_FORMAT}}->{$h->{OUTPUT_DESTINATION}} = $h;
	} 
	$statement_handle->finish();
	return $hash_output_configuration;
}

sub read_product_state_form
{
	my $database_handle = shift;
	my $sql ="SELECT
      			CAST( PRODUCTID AS VARCHAR(10) ) + '~' + 
      			CAST( STATE.STATECODE AS VARCHAR( 2 ) ) + '~' + 
      			CAST ( FORMID AS VARCHAR(10) ) PRODUCT_STATE_FORM_KEY
		FROM
			CDH.L_PRODUCT_ST_FRM_XREF XREF,
			CDH.L_PRODUCT_MASTER PRODUCT,
			CDH.L_STATE_MASTER STATE,
			CDH.L_FORM_MASTER FORM
		WHERE
			XREF.PRODUCTID = PRODUCT.ID
			AND XREF.STATEID = STATE.ID
			AND XREF.FORMID = FORM.ID
			AND GETDATE() BETWEEN XREF.EFFECTIVEDATE AND XREF.TERMINATIONDATE
		";
	my $product_state_form = read_lookup_hash( $database_handle, $sql, "PRODUCT_STATE_FORM_KEY" );

	return $product_state_form;
}

sub read_form_for_product_state
{
	my $database_handle = shift;
	my $sql ="SELECT
      			CAST( PRODUCTID AS VARCHAR(10) ) + '~' + 
      			CAST( STATE.STATECODE AS VARCHAR( 2 ) ) PRODUCT_STATE_KEY,
      			CAST ( FORMID AS VARCHAR(10) ) FORM_ID
		FROM
			CDH.L_PRODUCT_ST_FRM_XREF XREF,
			CDH.L_PRODUCT_MASTER PRODUCT,
			CDH.L_STATE_MASTER STATE,
			CDH.L_FORM_MASTER FORM
		WHERE
			XREF.PRODUCTID = PRODUCT.ID
			AND XREF.STATEID = STATE.ID
			AND XREF.FORMID = FORM.ID
			AND GETDATE() BETWEEN XREF.EFFECTIVEDATE AND XREF.TERMINATIONDATE
		";
	my $hash_product_state = read_lookup_hash( $database_handle, $sql, "PRODUCT_STATE_KEY" );

	return $hash_product_state;
}

sub get_form_id_for_product_state
{
	my $str_product_id = shift;
	my $str_issue_state = shift;

	my $str_return_form_id = "";
	my $str_search_key = $str_product_id."~".$str_issue_state;
	if( exists $hash_master_lookup->{FORM_FOR_PRODUCT_STATE}->{$str_search_key} )
	{
		$str_return_form_id = $hash_master_lookup->{FORM_FOR_PRODUCT_STATE}->{$str_search_key}->{FORM_ID};
	}
	return $str_return_form_id;
}

sub read_form_question
{
	my $database_handle = shift;
	my $sql ="SELECT
			CAST( FORMID AS VARCHAR(10) ) + '~' + CAST( QUESTIONID AS VARCHAR( 10 ) ) FORM_QUESTION_KEY,
      		QUESTIONNUMBER	QUESTION_NUMBER
		FROM
			CDH.L_FORM_QUESTION_XREF
		";
	my $form_question = read_lookup_hash( $database_handle, $sql, "FORM_QUESTION_KEY" );
	#DEBUG_POINT - Dump $form_question

	return $form_question;
}

sub read_product_rider_person
{
	my $database_handle = shift;
	my $hash_lookup = {};
	my $sql = "SELECT 
			CAST( PRODUCTID AS VARCHAR(10) ) + '~' + 
			CAST( RIDERID AS VARCHAR(10) ) PRODUCT_RIDER_KEY,
			PERSONTYPE PERSON_TYPE
		FROM
			CDH.L_PRODUCT_RIDER_XREF
		";
 	my $statement_handle = $database_handle->prepare($sql);
	$statement_handle->execute();
	while( my $h=$statement_handle->fetchrow_hashref() )
	{
		$hash_lookup->{$h->{PRODUCT_RIDER_KEY}}->{$h->{PERSON_TYPE}} = $h->{PERSON_TYPE};
	} 
	$statement_handle->finish();

	return $hash_lookup;
}

sub get_columns
{
	my $database_handle = shift;
	my $str_schema_name = shift;
	my $str_table_name = shift;
	
	my $sql = "select COLUMN_NAME,DATA_TYPE,COLUMN_DEFAULT,IS_NULLABLE from
							INFORMATION_SCHEMA.COLUMNS
						where
							TABLE_SCHEMA = '$str_schema_name'
							and table_name = '$str_table_name';
						";
	my $column_names = {};
	my $column_names = read_lookup_hash( $database_handle, $sql, "COLUMN_NAME" );

	return $column_names;
}

sub read_valid_values_for_fields
{
	my $database_handle = shift;
	my $hash_lookup = {};

	my $sql = "SELECT 
			FIELD_NAME,
			VALID_VALUES
		FROM
			CDH.L_COMPONENT_MASTER
		WHERE
			VALID_VALUES IS NOT NULL
		";
 	my $statement_handle = $database_handle->prepare($sql);
	$statement_handle->execute();
	while( my $h=$statement_handle->fetchrow_hashref() )
	{
		my @array_valid_values = split(',', $h->{VALID_VALUES});
		foreach( @array_valid_values )
		{
			$hash_lookup->{$h->{FIELD_NAME}}->{$_} = $_;
		}
	} 
	$statement_handle->finish();

	return $hash_lookup;
}

sub read_required_fields
{
	my $database_handle = shift;
	my $hash_lookup = {};

	my $sql = "SELECT
					XREF.ELEMENT_TYPE,
					XREF.ELEMENT_MASTER_ID,
					MASTER.FIELD_NAME,
					XREF.VALID_VALUES
				FROM
					CDH.L_COMPONENT_MASTER	MASTER,
					CDH.L_COMPONENT_XREF	XREF
				WHERE
					XREF.COMPONENT_ID = MASTER.ID
					AND XREF.REQUIRED_FLAG = 1
		";
 	my $statement_handle = $database_handle->prepare($sql);
	$statement_handle->execute();
	while( my $h=$statement_handle->fetchrow_hashref() )
	{
		$hash_lookup->{$h->{ELEMENT_TYPE}}->{$h->{ELEMENT_MASTER_ID}}->{$h->{FIELD_NAME}} = $h->{VALID_VALUES};
	} 
	$statement_handle->finish();

	return $hash_lookup;
}

sub get_required_fields
{
	my $str_incoming_record_type = shift;
	my $str_incoming_master_id = shift;
	return $hash_master_lookup->{REQUIRED_FIELDS}->{$str_incoming_record_type};
}

sub read_admin_cases
{
	my $database_handle = shift;
	my $sql ="SELECT
					ENROLLMENT_SYSTEM.CASENUMBER + '~' + CAST( SYSTEM_MASTER.ID AS VARCHAR( 10 ) ) CASE_SYSTEM_KEY,
					ADMIN_CASE.ADMIN_CASE_NO ADMIN_CASE_NUMBER,
					ADMIN_CASE.NAME ADMIN_CASE_NAME
				FROM
					CDH.L_ADMIN_CASE_INFO ADMIN_CASE,
					CDH.L_ENROLLMENT_SYSTEM_INFO ENROLLMENT_SYSTEM,
					CDH.L_SYSTEM_MASTER SYSTEM_MASTER
				WHERE
					ADMIN_CASE.SYSTEM_ID = SYSTEM_MASTER.ID
					AND ADMIN_CASE.ENROLLMENT_SYSTEM_NO_ID = ENROLLMENT_SYSTEM.ID
					";
	my $hash_admin_cases = read_lookup_hash( $database_handle, $sql, "CASE_SYSTEM_KEY" );
	#DEBUG_POINT - Dump $hash_admin_cases
	return $hash_admin_cases;
}

sub read_product_group_form
{
	my $database_handle = shift;
	my $sql ="SELECT
					DISTINCT CAST(PRODUCT.PRODUCTGROUP AS VARCHAR( 10 ) ) + '~' + CAST( XREF.FORMID AS VARCHAR( 10 ) ) PRODUCT_GROUP_FORM_KEY
				FROM
					CDH.L_PRODUCT_ST_FRM_XREF XREF,
					CDH.L_PRODUCT_MASTER PRODUCT
				WHERE
					XREF.PRODUCTID = PRODUCT.ID
					AND GETDATE() BETWEEN XREF.EFFECTIVEDATE AND XREF.TERMINATIONDATE
			";
	my $hash_product_group_form = read_lookup_hash( $database_handle, $sql, "PRODUCT_GROUP_FORM_KEY" );
	return $hash_product_group_form;
}

sub read_eoi_components
{
	my $database_handle = shift;
	my $sql ="SELECT ComponentID,DisplayName FROM TPE.Master_Components";
	my $eoi_components = read_lookup_hash( $database_handle, $sql, "ComponentID" );
	return $eoi_components;
}

sub read_eoi_questions
{
	my $database_handle = shift;

	my $sql ="SELECT ID,ComponentID,StateID,ProductID,Relationship,FormQuestionNo,RefQuestionID,AIGFormNumber FROM TPE.XRef_QuestionStateProduct";
	my $eoi_questions = read_lookup_hash( $database_handle, $sql, "ComponentID" );

	return $eoi_questions;
}

#EOI_Phase_2_1::Begin - Anand
#Added MUTS_Product_Code in the query
sub read_product_master
{
	my $database_handle = shift;

	my $sql ="select ID as ProductId,ProductName,MUTS_Product_Code as MUTS_PRODUCT_CODE from cdh.L_PRODUCT_MASTER";
	my $hash_product_master = read_lookup_hash( $database_handle, $sql, "ProductId" );

	return $hash_product_master;
}
#EOI_Phase_2_1::Begin - Anand

sub get_product_id_for_imax_benefit
{
	my $str_case_id = shift;
	my $str_benefit_type = shift;

	my $str_search_key = $str_case_id."~".$str_benefit_type;
	my $str_return_product_id = "";
	
	if( exists $hash_master_lookup->{CASE_PRODUCTS_iMax}->{$str_search_key} )
	{
		$str_return_product_id = $hash_master_lookup->{CASE_PRODUCTS_iMax}->{$str_search_key}->{PRODUCT_ID};
	}
	return $str_return_product_id;
}

sub is_eoi_case
{
	my $str_case_id = shift;

	if( exists $hash_master_lookup->{ENROLLMENT_SYSTEMS}->{$str_case_id} )
	{
		if( $hash_master_lookup->{ENROLLMENT_SYSTEMS}->{$str_case_id}->{EOI_LOOKUP} ne "N" )
		{
			return 1;
		}
	}
	return 0;
}

sub increment_participation_count_for_current_run
{
	my $str_case_id = shift;
	my $str_product_id = shift;

	my $str_case_product_key = $str_case_id."~".$str_product_id;
	if( exists $hash_master_lookup->{CASE_PRODUCTS}->{$str_case_id}->{$str_product_id} )
	{
		$hash_master_lookup->{CASE_PRODUCTS}->{$str_case_id}->{$str_product_id}->{PARTICIPATION_COUNT_CURRENT_RUN}++;
	}
}

sub reset_participation_counts_for_current_run
{
	my $str_case_id = shift;

	foreach my $str_product_id( keys %{$hash_master_lookup->{CASE_PRODUCTS}->{$str_case_id}} )
	{
		$hash_master_lookup->{CASE_PRODUCTS}->{$str_case_id}->{$str_product_id}->{PARTICIPATION_COUNT_CURRENT_RUN} = 0;
	}
}

sub refresh_participation_count
{
	my $str_case_id = shift;
	my $str_product_id = shift;

	my $str_case_product_key = $str_case_id."~".$str_product_id;
	if( exists $hash_master_lookup->{CASE_PRODUCTS}->{$str_case_id}->{$str_product_id} )
	{
		$hash_master_lookup->{CASE_PRODUCTS}->{$str_case_id}->{$str_product_id}->{PARTICIPATION_COUNT} += 
						$hash_master_lookup->{CASE_PRODUCTS}->{$str_case_id}->{$str_product_id}->{PARTICIPATION_COUNT_CURRENT_RUN};
	}
}

sub get_case_product
{
	my $str_case_id = shift;
	my $str_product_id = shift;
	
	return $hash_master_lookup->{CASE_PRODUCTS}->{$str_case_id}->{$str_product_id};
}

sub get_output_configuration
{
	my $str_case_id = shift;
	my $str_product_id = shift;

	return $hash_master_lookup->{OUTPUT_CONFIG}->{$str_case_id}->{$str_product_id};
}

sub read_add_on_products
{
	my $database_handle = shift;

	my $sql ="SELECT
					ENROLLMENT_SYSTEM_INFO.CaseNumber					CASE_NUMBER,
					PRODUCT_CONFIG_FOR_CASE_PRODUCTS.PRODUCT_ID			PRODUCT_ID,
					PRODUCT_CONFIG_FOR_CASE_PRODUCTS_ADD_ON.PRODUCT_ID	ADD_ON_PRODUCT_ID
				FROM
					CDH.L_CASE_PRODUCTS									CASE_PRODUCTS,
					CDH.L_PRODUCT_CONFIG								PRODUCT_CONFIG_FOR_CASE_PRODUCTS,
					CDH.L_ENROLLMENT_SYSTEM_INFO						ENROLLMENT_SYSTEM_INFO,
					CDH.L_CASE_PRODUCTS_ADD_ON							CASE_PRODUCTS_ADD_ON,
					CDH.L_PRODUCT_CONFIG								PRODUCT_CONFIG_FOR_CASE_PRODUCTS_ADD_ON
				WHERE
					CASE_PRODUCTS_ADD_ON.CASE_PRODUCT_ID = CASE_PRODUCTS.ID
					and CASE_PRODUCTS.ENROLLMENT_SYSTEM_NO_ID = ENROLLMENT_SYSTEM_INFO.ID
					AND CASE_PRODUCTS.PRODUCT_CONFIG_ID = PRODUCT_CONFIG_FOR_CASE_PRODUCTS.ID
					AND CASE_PRODUCTS_ADD_ON.ADD_ON_PRODUCT_CONFIG_ID = PRODUCT_CONFIG_FOR_CASE_PRODUCTS_ADD_ON.ID
					AND CASE_PRODUCTS.STATUS = 1
					AND CASE_PRODUCTS_ADD_ON.STATUS = 1
			";
 	my $statement_handle = $database_handle->prepare($sql);
	$statement_handle->execute();
	while( my $h=$statement_handle->fetchrow_hashref() )
	{
		$hash_master_lookup->{ADD_ON_PRODUCTS}->{$h->{CASE_NUMBER}}->{$h->{PRODUCT_ID}}->{$h->{ADD_ON_PRODUCT_ID}} = $h->{ADD_ON_PRODUCT_ID};
		$hash_master_lookup->{PRIMARY_PRODUCTS}->{$h->{CASE_NUMBER}}->{$h->{ADD_ON_PRODUCT_ID}}->{$h->{PRODUCT_ID}} = $h->{PRODUCT_ID};
	} 
	$statement_handle->finish();
}

sub get_add_on_products
{
	my $str_case_id = shift;
	my $str_product_id = shift;

	my $hash_return_products = {};
	if( exists $hash_master_lookup->{ADD_ON_PRODUCTS}->{$str_case_id} )
	{
		if( exists $hash_master_lookup->{ADD_ON_PRODUCTS}->{$str_case_id}->{$str_product_id} )
		{
			$hash_return_products = $hash_master_lookup->{ADD_ON_PRODUCTS}->{$str_case_id}->{$str_product_id};
		}
	}
	return $hash_return_products;
}

sub get_question_number
{
	my $str_form_id = shift;
	my $str_question_id = shift;

	my $str_form_question_key = $str_form_id."~".$str_question_id;
	my $str_question_number = "";
	if( exists $hash_master_lookup->{FORM_QUESTION}->{$str_form_question_key} )
	{
		$str_question_number = $hash_master_lookup->{FORM_QUESTION}->{$str_form_question_key}->{QUESTION_NUMBER};
	}
	return $str_question_number;
}

sub get_primary_products
{
	my $str_case_id = shift;
	my $str_product_id = shift;

	my $hash_return_products = {};
	if( exists $hash_master_lookup->{PRIMARY_PRODUCTS}->{$str_case_id} )
	{
		if( exists $hash_master_lookup->{PRIMARY_PRODUCTS}->{$str_case_id}->{$str_product_id} )
		{
			$hash_return_products = $hash_master_lookup->{PRIMARY_PRODUCTS}->{$str_case_id}->{$str_product_id};
		}
	}
	return $hash_return_products;
}

sub get_feed_admin_login_key
{
	my $str_login_id = shift;
	return $hash_master_lookup->{FEED_ADMIN_LOGIN_KEYS}->{$str_login_id}->{LOGIN_KEY};
}

sub can_send_output_downstream
{
	my $str_case_id = shift;
	if( $hash_master_lookup->{ENROLLMENT_SYSTEMS}->{$str_case_id}->{SEND_OUTPUT} eq "1" )
	{
		return 1;
	}
	return 0;
}

sub read_code_manager_wse
{
	my $database_handle = shift;
	my $sql ="SELECT
					ENROLLMENT_SYSTEM.CASENUMBER	CASE_NUMBER,
					CODE_MANAGER.CaseName			CODE_MANAGER_CASE_NAME,
					CODE_MANAGER.Level1				LEVEL_ONE
				FROM
					CDH.L_Code_Manager CODE_MANAGER,
					CDH.L_ENROLLMENT_SYSTEM_INFO ENROLLMENT_SYSTEM
				WHERE
					CODE_MANAGER.CaseNumber = ENROLLMENT_SYSTEM.CASENUMBER
					AND CODE_MANAGER.AdminSystemID = 7
					";
	my $hash_code_manager_wse = read_lookup_hash( $database_handle, $sql, "CASE_NUMBER" );
	return $hash_code_manager_wse;
}

sub get_code_manager_wse
{
	my $str_case_id = shift;
	if( exists $hash_master_lookup->{CODE_MANAGER_WSE}->{$str_case_id} )
	{
		return $hash_master_lookup->{CODE_MANAGER_WSE}->{$str_case_id};
	}
	return {};
}

#EOI_Phase_2_1::Begin - Anand	
sub read_code_manager_group_numbers
{
	my $database_handle = shift;
	my $sql ="SELECT
					ENROLLMENT_SYSTEM.CASENUMBER	CASE_NUMBER,
					CODE_MANAGER.ProductID			PRODUCT_ID,
					CODE_MANAGER.Level1				LEVEL_ONE
				FROM
					CDH.L_Code_Manager CODE_MANAGER,
					CDH.L_ENROLLMENT_SYSTEM_INFO ENROLLMENT_SYSTEM
				WHERE
					CODE_MANAGER.CaseNumber = ENROLLMENT_SYSTEM.CASENUMBER
					AND CODE_MANAGER.AdminSystemID = 13
					";
 	my $hash_code_manager_group_numbers = {};
 	my $statement_handle = $database_handle->prepare($sql);
	$statement_handle->execute();
	while( my $h=$statement_handle->fetchrow_hashref() )
	{
		$hash_code_manager_group_numbers->{$h->{CASE_NUMBER}}->{$h->{PRODUCT_ID}} = $h->{LEVEL_ONE};
	}
	$statement_handle->finish();
	return $hash_code_manager_group_numbers;
}

sub get_code_manager_group_number
{
	my $str_case_id = shift;
	my $str_product_id = shift;

	$main::log->info( "CDH::LookUpXRef::get_code_manager_group_number::Case ID:".$str_case_id );
	$main::log->info( "CDH::LookUpXRef::get_code_manager_group_number::Product ID:".$str_product_id );
	if( exists $hash_master_lookup->{CODE_MANAGER_GROUP_NUMBERS}->{$str_case_id}->{$str_product_id} )
	{
		return $hash_master_lookup->{CODE_MANAGER_GROUP_NUMBERS}->{$str_case_id}->{$str_product_id};
	}
	if( exists $hash_master_lookup->{CODE_MANAGER_GROUP_NUMBERS}->{$str_case_id}->{0} )
	{
		return $hash_master_lookup->{CODE_MANAGER_GROUP_NUMBERS}->{$str_case_id}->{0};
	}
	return "";
}
#EOI_Phase_2_1::End - Anand	

#EOI_Phase_2_1::Begin - Ponmani	
sub read_ge_case_data
{
	my $database_handle = shift;
	my $sql = "   Select sc.COECaseNumber CASENUMBER, qt.GroupName GROUPNAME,
    ISNULL(qt.Address1,'') + CASE WHEN qt.Address1 <> '' THEN ', ' ELSE '' END + ISNULL(qt.Address2,'') 
    + CASE WHEN qt.Address2 <> '' THEN ', ' ELSE '' END + ISNULL(qt.City,'') 
    + CASE WHEN qt.City <> '' THEN ', ' ELSE '' END+ ISNULL(qt.State,'') 
    + CASE WHEN qt.State <> '' THEN ', ' ELSE '' END + ISNULL(qt.ZipCode,'') as GROUPADDRESS from dbo.Quote qt
    join dbo.SoldCase sc on qt.QuoteId = sc.QuoteId";
	my $hash_ge_case_level_data = {};
	my $statement_handle = $database_handle->prepare($sql);
	$statement_handle->execute();
	while(my $h=$statement_handle->fetchrow_hashref())
	{
		$hash_ge_case_level_data->{$h->{CASENUMBER}} = $h;
	}
	$statement_handle->finish();
	#print Dumper($hash_ge_case_level_data);
	return $hash_ge_case_level_data;
}

sub read_ge_gi_amounts_all
{
	my $database_handle = shift;
	my $sql =  "SELECT
						sc.COECaseNumber as CASENUMBER,
						pt.COEProductId as Product_ID,
						ebp.GIMaxLimitAmount as EmployeeGIAmount,
						ebp.SpouseGIAmount,
						ebp.ChildGIAmount,
						qc.QuoteClassId as ClassId, 
						qc.ClassName as JOBCLASS
				FROM
						dbo.EnrollmentBenefitPackage ebp,
						dbo.QuoteProductPackage qpp,
						dbo.EnrollmentProductPlans epp,
						dbo.EnrollmentProduct ep,
						dbo.SoldCase sc,
						dbo.product pt,
						QuoteClassPackage qcp,
						QuoteClass qc 
				WHERE
						ebp.QuoteProductPackageId = qpp.QuoteProductPackageId
						AND qpp.QuoteProductPlanId = epp.QuoteProductPlanId
						AND epp.EnrollmentProductId = ep.EnrollmentProductId
						AND ep.IsActive = 1
						AND ebp.IsActive = 1
						AND ep.ProductId = pt.ProductId
						AND ep.soldcaseid = sc.soldcaseid
						AND sc.COECaseNumber like 'L1%'
						AND pt.COEProductId is not null
						AND pt.productid not in (25,198,199,26,44,196,197)
						AND qpp.QuoteProductPackageId = qcp.QuoteProductPackageId
						AND qcp.QuoteClassId = qc.QuoteClassId ";
						
	my $hash_ge_product_data = {};
	my $statement_handle = $database_handle->prepare($sql);
	$statement_handle->execute();
	while(my $h=$statement_handle->fetchrow_hashref())
	{
		$hash_ge_product_data->{$h->{CASENUMBER}}->{$h->{Product_ID}}->{$h->{JOBCLASS}} = $h;	
	}
	$statement_handle->finish();
	return $hash_ge_product_data;
}

sub read_ge_gi_amounts_spouse
{
	my $database_handle = shift;
	my $sql =  "SELECT
					distinct sc.COECaseNumber as CASENUMBER,
					pt.COEProductId as Product_ID,
					ebp.GIMaxLimitAmount as SpouseGIAmount,
					qc.QuoteClassId as ClassId, 
					qc.ClassName as JOBCLASS
		    	FROM
					dbo.EnrollmentBenefitPackage ebp,
					dbo.QuoteProductPackage qpp,
					dbo.EnrollmentProductPlans epp,
					dbo.EnrollmentProduct ep,
					dbo.SoldCase sc,
					dbo.product pt,
					QuoteClassPackage qcp,
					QuoteClass qc 
		    	WHERE
					ebp.QuoteProductPackageId = qpp.QuoteProductPackageId
					AND qpp.QuoteProductPlanId = epp.QuoteProductPlanId
					AND epp.EnrollmentProductId = ep.EnrollmentProductId
					AND ep.IsActive = 1
					AND ep.ProductId = pt.ProductId
					AND ep.soldcaseid=sc.soldcaseid
					AND sc.COECaseNumber like 'L1%'
					AND pt.COEProductId is not null
					AND pt.productid in (26,44,196,197)
					AND qpp.QuoteProductPackageId = qcp.QuoteProductPackageId
					AND qcp.QuoteClassId = qc.QuoteClassId ";

	my $hash_ge_product_data = {};
	my $statement_handle = $database_handle->prepare($sql);
	$statement_handle->execute();
	while(my $h=$statement_handle->fetchrow_hashref())
	{
		$hash_ge_product_data->{$h->{CASENUMBER}}->{$h->{Product_ID}}->{$h->{JOBCLASS}} = $h;	
	}
	$statement_handle->finish();
	return $hash_ge_product_data;
}

sub read_ge_gi_amounts_children
{
	my $database_handle = shift;
	my $sql =  "SELECT
						DISTINCT sc.COECaseNumber as CASENUMBER,
						pt.COEProductId as Product_ID,
						ebp.GIMaxLimitAmount as ChildGIAmount,
						qc.QuoteClassId as ClassId, 
						qc.ClassName as JOBCLASS
		    	FROM
						dbo.EnrollmentBenefitPackage ebp,
						dbo.QuoteProductPackage qpp,
						dbo.EnrollmentProductPlans epp,
						dbo.EnrollmentProduct ep,
						dbo.SoldCase sc,
						dbo.product pt,
						QuoteClassPackage qcp,
						QuoteClass qc 
		    	WHERE
						ebp.QuoteProductPackageId = qpp.QuoteProductPackageId
						AND qpp.QuoteProductPlanId = epp.QuoteProductPlanId
						AND epp.EnrollmentProductId = ep.EnrollmentProductId
						AND ep.IsActive = 1
						AND ep.ProductId = pt.ProductId
						AND ep.soldcaseid=sc.soldcaseid
						AND sc.COECaseNumber like 'L1%'
						AND pt.COEProductId is not null
						AND pt.productid in (25,198,199)
						AND qpp.QuoteProductPackageId = qcp.QuoteProductPackageId
						AND qcp.QuoteClassId = qc.QuoteClassId ";
	my $hash_ge_product_data = {};
	my $statement_handle = $database_handle->prepare($sql);
	$statement_handle->execute();
	while(my $h=$statement_handle->fetchrow_hashref())
	{
		$hash_ge_product_data->{$h->{CASENUMBER}}->{$h->{Product_ID}}->{$h->{JOBCLASS}} = $h;	
	}
	$statement_handle->finish();
	return $hash_ge_product_data;
}

sub read_ge_waiting_periods
{
	my $database_handle = shift;
	my $sql =  "SELECT
					sc.COECaseNumber as CASENUMBER,
					pt.COEProductId as Product_ID,
					ebp.WaitingPeriodDayOfMonth,
					ebp.WaitingPeriodDaysOfService as EligibilityWaitingPeriod,
					qc.QuoteClassId as ClassId, 
					qc.ClassName as JOBCLASS
				FROM
					dbo.EnrollmentBenefitPackage ebp,
					dbo.QuoteProductPackage qpp,
					dbo.EnrollmentProductPlans epp,
					dbo.EnrollmentProduct ep,
					dbo.SoldCase sc,
					dbo.product pt,
					QuoteClassPackage qcp,
					QuoteClass qc 
				WHERE
					ebp.QuoteProductPackageId = qpp.QuoteProductPackageId
					AND qpp.QuoteProductPlanId = epp.QuoteProductPlanId
					AND epp.EnrollmentProductId = ep.EnrollmentProductId
					AND ep.IsActive = 1
					AND ep.ProductId = pt.ProductId
					AND ep.soldcaseid = sc.soldcaseid
					AND sc.COECaseNumber like 'L1%'
					AND qpp.QuoteProductPackageId = qcp.QuoteProductPackageId
					AND qcp.QuoteClassId = qc.QuoteClassId
					AND pt.COEProductId IS NOT NULL ";
				
	my $hash_ge_product_data = {};
	my $statement_handle = $database_handle->prepare($sql);
	$statement_handle->execute();
	while(my $h=$statement_handle->fetchrow_hashref())
	{
		$hash_ge_product_data->{$h->{CASENUMBER}}->{$h->{Product_ID}}->{$h->{JOBCLASS}} = $h;	
	}
	$statement_handle->finish();
	return $hash_ge_product_data;
}

sub read_grandfathered_amount_employee
{
	my $database_handle = shift;
	my $sql = "Select
					sc.COECaseNumber as CASENUMBER,
					AEB.UniqueIdentifier as UniqueIdentifier,
					pt.COEProductId as ProductId ,
					AEB.Volume as GRAND_FATHERED_AMOUNT
					from
					dbo.AEBenefitDetails AEB ,
					dbo.SoldCase sc,
					dbo.product pt
					WHERE
					sc.SoldCaseId = AEB.SoldCaseId
					and AEB.ProductId = pt.ProductId
					and AEB.Volume > 0.00
					and sc.COECaseNumber like 'L1%'";
	my $hash_ge_benefit_data = {};
	my $statement_handle = $database_handle->prepare($sql);
	$statement_handle->execute();
	while(my $h=$statement_handle->fetchrow_hashref())
	{
		$hash_ge_benefit_data->{$h->{CASENUMBER}}->{$h->{UniqueIdentifier}}->{$h->{ProductId}} = $h;	
	}
	$statement_handle->finish();
	return $hash_ge_benefit_data;
}

#EOI_Phase_2_1::Begin - Anand
sub read_grandfathered_amount_spouse
{
	my $database_handle = shift;
	my $sql = "Select
					sc.COECaseNumber as CASENUMBER,
					AEB.UniqueIdentifier as UniqueIdentifier,
					pt.COEProductId as ProductId ,
					AEB.SPVolume as GRAND_FATHERED_AMOUNT
					from
					dbo.AEBenefitDetails AEB ,
					dbo.SoldCase sc,
					dbo.product pt
					WHERE
					sc.SoldCaseId = AEB.SoldCaseId
					and AEB.ProductId = pt.ProductId
					and AEB.SPVolume > 0.00
					and sc.COECaseNumber like 'L1%'
          ";
	my $hash_ge_benefit_data = {};
	my $statement_handle = $database_handle->prepare($sql);
	$statement_handle->execute();
	while(my $h=$statement_handle->fetchrow_hashref())
	{
		$hash_ge_benefit_data->{$h->{CASENUMBER}}->{$h->{UniqueIdentifier}}->{$h->{ProductId}} = $h;	
	}
	$statement_handle->finish();
	return $hash_ge_benefit_data;
}

sub read_grandfathered_amount_children
{
	my $database_handle = shift;
	my $sql = "Select
					sc.COECaseNumber as CASENUMBER,
					AEB.UniqueIdentifier as UniqueIdentifier,
					pt.COEProductId as ProductId ,
					AEB.CHVolume as GRAND_FATHERED_AMOUNT
					from
					dbo.AEBenefitDetails AEB ,
					dbo.SoldCase sc,
					dbo.product pt
					WHERE
					sc.SoldCaseId = AEB.SoldCaseId
					and AEB.ProductId = pt.ProductId
					and AEB.CHVolume > 0.00
					and sc.COECaseNumber like 'L1%'";
	my $hash_ge_benefit_data = {};
	my $statement_handle = $database_handle->prepare($sql);
	$statement_handle->execute();
	while(my $h=$statement_handle->fetchrow_hashref())
	{
		$hash_ge_benefit_data->{$h->{CASENUMBER}}->{$h->{UniqueIdentifier}}->{$h->{ProductId}} = $h;	
	}
	$statement_handle->finish();
	return $hash_ge_benefit_data;
}

sub is_eoi_file_feed_case
{
	my $str_case_id = shift;
	if( exists $hash_master_lookup->{ENROLLMENT_SYSTEMS}->{$str_case_id} )
	{
		if( $hash_master_lookup->{ENROLLMENT_SYSTEMS}->{$str_case_id}->{EOI_LOOKUP} eq "2" )
		{
			return 1;
		}
	}
	return 0;
}

sub get_grandfathered_amount_employee
{
	my $str_case_id = shift;
	my $str_member_identifier = shift;
	my $str_product_id = shift;

	if( exists $hash_master_lookup->{EOI_GE_GRANDFATHER_EMPLOYEE}->{$str_case_id}->{$str_member_identifier}->{$str_product_id} )
	{
		my $str_return_amount = $hash_master_lookup->{EOI_GE_GRANDFATHER_EMPLOYEE}->{$str_case_id}->{$str_member_identifier}->{$str_product_id}->{GRAND_FATHERED_AMOUNT};
		$str_return_amount = sprintf("%.2f", $str_return_amount );
		return $str_return_amount;
	}
	return "";
}

sub get_grandfathered_amount_spouse
{
	my $str_case_id = shift;
	my $str_member_identifier = shift;
	my $str_product_id = shift;

	if( exists $hash_master_lookup->{EOI_GE_GRANDFATHER_SPOUSE}->{$str_case_id}->{$str_member_identifier}->{$str_product_id} )
	{
		my $str_return_amount = $hash_master_lookup->{EOI_GE_GRANDFATHER_SPOUSE}->{$str_case_id}->{$str_member_identifier}->{$str_product_id}->{GRAND_FATHERED_AMOUNT};
		$str_return_amount = sprintf("%.2f", $str_return_amount );
		return $str_return_amount;
	}
	return "";
}

sub get_grandfathered_amount_children
{
	my $str_case_id = shift;
	my $str_member_identifier = shift;
	my $str_product_id = shift;

	if( exists $hash_master_lookup->{EOI_GE_GRANDFATHER_CHILDREN}->{$str_case_id}->{$str_member_identifier}->{$str_product_id} )
	{
		my $str_return_amount = $hash_master_lookup->{EOI_GE_GRANDFATHER_CHILDREN}->{$str_case_id}->{$str_member_identifier}->{$str_product_id}->{GRAND_FATHERED_AMOUNT};
		$str_return_amount = sprintf("%.2f", $str_return_amount );
		return $str_return_amount;
	}
	return "";
}

sub get_ge_gi_amount
{
	my $str_case_id = shift;
	my $str_product_id = shift;
	my $str_jobclass = shift;
	my $str_person_type = shift;

	my $str_return_amount = "";
	if( $str_person_type eq "1" )
	{
		return get_ge_gi_amount_all( $str_case_id, $str_product_id,$str_jobclass, "EmployeeGIAmount" );
	}
	elsif( $str_person_type eq "2" )
	{
		my $str_gi_amount_spouse = get_ge_gi_amount_all( $str_case_id, $str_product_id,$str_jobclass, "SpouseGIAmount" );
		if( $str_gi_amount_spouse eq "" )
		{
			return get_ge_gi_amount_spouse( $str_case_id, $str_product_id,$str_jobclass );
		}
		return $str_gi_amount_spouse;
	}
	elsif( $str_person_type eq "3" )
	{
		my $str_gi_amount_children = get_ge_gi_amount_all( $str_case_id, $str_product_id,$str_jobclass, "ChildGIAmount" );
		if( $str_gi_amount_children eq "" )
		{
			return get_ge_gi_amount_children( $str_case_id, $str_product_id,$str_jobclass );
		}
		return $str_gi_amount_children;
	}
	return $str_return_amount;
}

sub get_ge_gi_amount_all
{
	my $str_case_id = shift;
	my $str_product_id = shift;
	my $str_jobclass = shift;
	my $str_field_name = shift;

	my $str_return_amount = "";
	if( exists $hash_master_lookup->{EOI_GE_PRODUCT_GI_AMOUNTS_ALL}->{$str_case_id}->{$str_product_id}->{$str_jobclass} )
	{
		$str_return_amount = $hash_master_lookup->{EOI_GE_PRODUCT_GI_AMOUNTS_ALL}->{$str_case_id}->{$str_product_id}->{$str_jobclass}->{$str_field_name};
	}
	if( $str_return_amount eq ".00" )
	{
		$str_return_amount = "";
	}
	return $str_return_amount;
}

sub get_ge_gi_amount_spouse
{
	my $str_case_id = shift;
	my $str_product_id = shift;
	my $str_jobclass = shift;

	my $str_return_amount = "";
	if( exists $hash_master_lookup->{EOI_GE_PRODUCT_GI_AMOUNTS_SPOUSE}->{$str_case_id}->{$str_product_id}->{$str_jobclass} )
	{
		$str_return_amount = $hash_master_lookup->{EOI_GE_PRODUCT_GI_AMOUNTS_SPOUSE}->{$str_case_id}->{$str_product_id}->{$str_jobclass}->{SpouseGIAmount};
	}
	if( $str_return_amount eq ".00" )
	{
		$str_return_amount = "";
	}
	return $str_return_amount;
}

sub get_ge_gi_amount_children
{
	my $str_case_id = shift;
	my $str_product_id = shift;
	my $str_jobclass = shift;

	my $str_return_amount = "";
	if( exists $hash_master_lookup->{EOI_GE_PRODUCT_GI_AMOUNTS_CHILDREN}->{$str_case_id}->{$str_product_id}->{$str_jobclass} )
	{
		$str_return_amount = $hash_master_lookup->{EOI_GE_PRODUCT_GI_AMOUNTS_CHILDREN}->{$str_case_id}->{$str_product_id}->{$str_jobclass}->{ChildGIAmount};
	}
	if( $str_return_amount eq ".00" )
	{
		$str_return_amount = "";
	}
	return $str_return_amount;
}

sub get_ge_waiting_period
{
	my $str_case_id = shift;
	my $str_product_id = shift;
	my $str_jobclass = shift;

	my $str_return_period = "";
	if( exists $hash_master_lookup->{EOI_GE_PRODUCT_WAITING_PERIODS}->{$str_case_id}->{$str_product_id}->{$str_jobclass} )
	{
		$str_return_period = $hash_master_lookup->{EOI_GE_PRODUCT_WAITING_PERIODS}->{$str_case_id}->{$str_product_id}->{$str_jobclass}->{EligibilityWaitingPeriod};
	}
	return $str_return_period;
}



#EOI_Phase_2_1::End - Anand

####################################################################################################################################################
#Defect/User Story		Developer		Description
#13401				    Arunkumar T		Incorrect GI Amount populated in MUTS Page
####################################################################################################################################################
sub get_jobclass_from_redi
{
	my $database_handle = shift;
	my $str_case_number = shift;
	my $str_ssn	= shift;
	
	my $str_query	= "SELECT
							sc.SoldCaseId,
							sc.COECaseNumber as CASENUMBER,
							m.SSN,
							qc.ClassName as JOBCLASS
						FROM
							QuoteClass as qc 
							INNER JOIN
							EnrollmentCensusClassMapping as ecm 
							ON qc.QuoteClassId =ecm.ClassId 
							INNER JOIN 
							Member as m 
							ON ecm.SoldCaseId = m.SoldCaseId 
							INNER JOIN
							SoldCase as sc 
							ON m.SoldCaseId = sc.SoldCaseId
						WHERE 
							(ecm.Department is null or ecm.Department = m.Department)
							AND (ecm.Division is null or ecm.Division=m.Division)
							AND (ecm.ClassMappingField1 is null or ecm.ClassMappingField1 = m.ClassMappingField1)
							AND (ecm.ClassMappingField2 is null or ecm.ClassMappingField2 = m.ClassMappingField2)
							AND (ecm.ClassMappingField3 is null or ecm.ClassMappingField3 = m.ClassMappingField3)
							AND (ecm.EmployeeClass is null or ecm.EmployeeClass = m.EmployeeClass)
							AND sc.COECaseNumber = '$str_case_number'
							AND m.SSN= '$str_ssn'";
				
	my $hash_ge_jobclass	= {};
	my $str_jobclass	= "";
	my $statement_handle = $database_handle->prepare($str_query);
	$statement_handle->execute();
	while(my $h=$statement_handle->fetchrow_hashref())
	{
		$hash_ge_jobclass->{$h->{CASENUMBER}}->{$h->{SSN}} = $h;	
	}
	$statement_handle->finish();
	
	$str_jobclass = $hash_ge_jobclass->{$str_case_number}->{$str_ssn}->{JOBCLASS};
	return $str_jobclass;
}			
						
1;
