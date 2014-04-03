connect baninst1/&&baninst1_password;

set scan off
set echo on

spool xxx 

create or replace package body bwmsinwb
is

/* Declare global variables */
global_pidm spriden.spriden_pidm%type;
curr_release   VARCHAR2 (10) := '8.0M';
term stvterm.stvterm_code%type;

submit_flag VARCHAR2(1) := 'N';

stvterm_rec    stvterm%ROWTYPE;
sorrtrm_rec    sorrtrm%ROWTYPE;


FormState VARCHAR2(2);

/* Name Variables */
disp_student_id    spriden.spriden_id%TYPE;
disp_first_name    spriden.spriden_first_name%TYPE;
disp_last_name     spriden.spriden_last_name%TYPE;
disp_middle_init   spriden.spriden_mi%TYPE;

/* Street Variables */
disp_street_line1   spraddr.spraddr_street_line1%TYPE;    
disp_street_line2   spraddr.spraddr_street_line2%TYPE;    
disp_street_line3   spraddr.spraddr_street_line3%TYPE;    
disp_city           spraddr.spraddr_city%TYPE;            
disp_stat_code      spraddr.spraddr_stat_code%TYPE;       
disp_zip            spraddr.spraddr_zip%TYPE;

whole_street        VARCHAR2(300); 
whole_city_state     VARCHAR2(100); 
TYPE Tm_dates IS VARRAY(3) OF VARCHAR2(20); -- VARRAY type
census_term      Tm_dates := Tm_dates(' ', ' ', ' ');
census_term_day  Tm_dates := Tm_dates(' ', ' ', ' ');
census_term_note Tm_dates := Tm_dates(' ', ' ', ' ');

/* bio information */
--disp_ssn   spbpers.spbpers_ssn%TYPE;                
disp_birth spbpers.spbpers_birth_date%TYPE; 

/* Email Information */
disp_email goremal.goremal_email_address%TYPE;

/*Phone Numbers */
disp_prim_phone VARCHAR2(100);

/* Processing options for screen validate  */
/* all should be true under production conditions  */
	PROC_CENSUS_DATE    boolean := TRUE;
	PROC_WAIVER         boolean := TRUE;
	PROC_PURCHASE       boolean := TRUE;
	PROC_START_TERM     boolean := TRUE;
	PROC_CREDIT_HOURS   boolean := TRUE;
	/* proc_all allows the other checks to process but resets the status back to A  */
	PROC_ALL            boolean := FALSE; 

---------------------------------- part1
-------------------------------- part2
/*****************************************************************************/
/* Function to determine if student already has an insurance waiver for the  */
/* given term.  The caller specifies both the PIDM and term code in question.*/
/* The function returns a value of TRUE if the term code falls with the range*/
/* of the starting and ending terms of an existing waiver entry. Otherwise,  */
/* this function returns FALSE.                                              */
/*****************************************************************************/

function has_waiver(pidm_parm NUMBER, start_term VARCHAR2) return BOOLEAN
is
  dummy VARCHAR2(1);
begin
     

select distinct 'x'  into dummy
       from twrwaiv
       where twrwaiv_pidm = pidm_parm and
             start_term between twrwaiv_from_term and twrwaiv_thru_term; 
                        
        return(TRUE);

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
              return(FALSE);
end;

/*****************************************************************************/
/* Function to determine if student already has an insurance purchase for the*/
/* given term.  The caller specifies both the PIDM and term code in question.*/
/* The function returns a value of TRUE if the term code falls with the range*/
/* of the starting and ending terms of an existing waiver entry. Otherwise,  */
/* this function returns FALSE.                                              */
/*****************************************************************************/

function has_purchase(pidm_parm NUMBER, start_term VARCHAR2) return BOOLEAN
is
  dummy VARCHAR2(1);
begin
     

select distinct 'x'  into dummy
       from tzrincp
       where tzrincp_pidm = pidm_parm and
             start_term = tzrincp_from_term; 
                        
        return(TRUE);

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
              return(FALSE);
end;

/*************************************************************************
This function returns boolean value that indicates whether or not the student
is allowed to access the insurance waiver form.  If the student has a status of
Web not-accessible(WN) they cannot submit a waiver via self-service.


Return Values:
   TRUE   Student cannot access web form (status WN)
   FALSE  Student can access web form (status other than WN)
   
***********************************************************************/
function denied_access(pidm_parm NUMBER, start_term VARCHAR2) return BOOLEAN
is
  dummy VARCHAR2(1);
begin
     
select distinct 'x'  into dummy
       from twrwaiv
       where twrwaiv_pidm = pidm_parm and
             twrwaiv_status_code = 'WN' and
             start_term between twrwaiv_from_term and twrwaiv_thru_term; 
                        
        return(TRUE);

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
              return(FALSE);
end;

function F_ScreenValidate (term IN stvterm.stvterm_code%TYPE) 
RETURN VARCHAR2

IS

	checkit         OWA_UTIL.ident_arr;
	msg_text_out    VARCHAR2(200);
  
begin
           
    /*------------------------------------------*/   
    /* Process any flags that disable this form */
    /*------------------------------------------*/
    
    /* Default to form is active */
    FormState := 'A';
   
   /* check if student already has waiver */
	IF PROC_WAIVER THEN
   if has_waiver(global_pidm,term ) then
      FormState := 'W';
   end if;
	END IF;
   
   /* check if student already has a purchase */
	IF PROC_PURCHASE THEN
   if has_purchase(global_pidm,term ) then
      FormState := 'P';
   end if;
	END IF;

   /* check if current term is past waiver deadline */
	IF PROC_CENSUS_DATE THEN
		if tzkar01.f_m_check_census(term) = 'N' then
      FormState := 'X';
   	end if;
	END IF;
	 
	IF PROC_START_TERM THEN
   /** check if term registration has started **/
  	if (tzkar01.f_m_after_start_reg(term) = 'N') then
    	FormState := 'I';
  	end if;
	END IF;

	IF PROC_CREDIT_HOURS THEN
   /** check if number of hours is >= 9 **/
  	if (f_m_term_credit_hours(global_pidm, term) < 9) then
    	FormState := 'H';
	  end if;
	END IF;

   /** check if student is denied access **/
  if denied_access(global_pidm,term ) then
    FormState := 'D';
  end if;

/* Uncomment this to bypass all filters for testing  */
/*  or set it to test filter conditions.             */

	IF NOT PROC_ALL THEN 
    twbkfrmt.P_PrintMessage('Processing is Proceeding but Form State is ' || FormState,'NOTE');
    FormState := 'A'; 
	END IF;    
	
   /*----------------------------------------------------*/
   /* Message section for insurance form activation      */
   /*----------------------------------------------------*/
 
   if FormState = 'I' then
                msg_text_out := G$_NLS.Get('BWMINS1-0004','SQL','Form is not active for this Term');
                twbkfrmt.P_PrintMessage(msg_text_out,'ERROR');
                htp.p(' ');
--                GOTO endofform;
   end if;
  
    /* Student is not allowed to access web page, must contact student health first */
    if FormState = 'D' then
                msg_text_out := G$_NLS.Get('BWMINS1-0014','SQL', 'Attention Student!');
                twbkfrmt.P_PrintMessage(msg_text_out,'ERROR');
                htp.p('It&rsquo;s past your department&rsquo;s waiver deadline to submit insurance information. 
                       If you have questions, please contact the Student Insurance Office, Plaza 149, (303) 556-3873.');
--                GOTO endofform;
   end if;
      
   /* Deadline has passed to submitting insurance waiver */
   if FormState = 'X' then
       if has_waiver(global_pidm,term ) then
         if tzkar01.f_m_check_insure_waiver(global_pidm, term, tzkar01.ACCEPTED_WAIVER) = 'Y' then
                msg_text_out := G$_NLS.Get('BWMINS1-0011','SQL','After Census Insurance Waiver Status');
                twbkfrmt.P_PrintMessage(msg_text_out,'NOTE');

               htp.p('Your insurance waiver for this academic year has been <b>approved</b>.');
--               GOTO endofform;   
          elsif  tzkar01.f_m_check_insure_waiver(global_pidm, term, tzkar01.REJECTED_WAIVER) = 'Y' then
                msg_text_out := G$_NLS.Get('BWMINS1-0012','SQL','After Census Insurance Waiver Status');
                twbkfrmt.P_PrintMessage(msg_text_out,'NOTE');

                htp.p('Your waiver has been <b>audited and denied</b> based on the information you submitted to the College. Contact the 
                       Health Insurance Office if you have questions regarding this denial.');
--               GOTO endofform;   
          elsif tzkar01.f_m_check_insure_waiver(global_pidm, term, tzkar01.SUBMITTED_WAIVER) = 'Y' then
                msg_text_out := G$_NLS.Get('BWMINS1-0013','SQL','After Census Insurance Waiver Status');
                twbkfrmt.P_PrintMessage(msg_text_out,'NOTE');

               htp.p('Your health insurance waiver for this academic year is being audited. The audit process takes approximately 30 days.');
--               GOTO endofform;   
          end if;
      else
                msg_text_out := G$_NLS.Get('BWMINS1-0004','SQL','You can no longer submit a Waiver');
                twbkfrmt.P_PrintMessage(msg_text_out,'ERROR');
                htp.p('The insurance waiver deadline date has past. You can no longer complete 
                       an on-line electronic waiver form for this semester. If you have questions 
                       at this juncture, you need to contact the Student Health Insurance Office by 
                       stopping by Plaza, Room 149 or by calling 303-556-3873. ');
--                GOTO endofform;
      end if;
   end if;
 
   /*** Within insurance waiver period ***/
     
/* This set of messages refer to an insurance audit.  The messages are all the same .  */     
   if tzkar01.f_m_check_insure_waiver(global_pidm, term, tzkar01.ACCEPTED_WAIVER) = 'Y' then
                msg_text_out := 
                G$_NLS.Get('BWMINS1-0009','SQL','You have already submitted an Insurance Compliance Form for the current semester');
                twbkfrmt.P_PrintMessage(msg_text_out,'NOTE');
                htp.p('Contact the Health Insurance Office at 303-556-2525 if you have any questions');

--               htp.p('You have already submitted a health insurance waiver for this academic year and it has been <b>approved</b>.');
--               GOTO endofform;   
   elsif  tzkar01.f_m_check_insure_waiver(global_pidm, term, tzkar01.REJECTED_WAIVER) = 'Y' then
                msg_text_out := G$_NLS.Get('BWMINS1-0010','SQL','You have already submitted an Insurance Compliance Form for the current semester');
                twbkfrmt.P_PrintMessage(msg_text_out,'NOTE');
                htp.p('Contact the Health Insurance Office at 303-556-2525 if you have any questions');

--                htp.p('You have already submitted a health insurance waiver for this academic year and your waiver 
--                      has been <b>audited and denied</b> based on the information you submitted to the College. Contact the 
--                      Health Insurance Office if you have questions regarding this denial.');
--               GOTO endofform;   
   elsif tzkar01.f_m_check_insure_waiver(global_pidm, term, tzkar01.SUBMITTED_WAIVER) = 'Y' then
                msg_text_out := G$_NLS.Get('BWMINS1-0008','SQL','You have already submitted an Insurance Compliance Form for the current semester');
                twbkfrmt.P_PrintMessage(msg_text_out,'NOTE');
                htp.p('Contact the Health Insurance Office at 303-556-2525 if you have any questions');

--               htp.p('You have already submitted a health insurance waiver for this academic year and at this time your 
--                      waiver is being audited. The audit process takes approximately 30 days.');
--               GOTO endofform;   
/*   elsif tzkar01.f_m_check_census(term) = 'Y' then
                msg_text_out := G$_NLS.Get('BWMINS1-0004','SQL','Form is not active for this Term');
                twbkfrmt.P_PrintMessage(msg_text_out,'ERROR');
                htp.p(' ');
--                GOTO endofform; */
    end if;

/* This set of messages refer to an insurance purchase.  The messages are all the same .  */     
   if tzkar01.f_m_check_insure_purchase(global_pidm, term, tzkar01.ACCEPTED_PURCHASE) = 'Y' then
                msg_text_out := G$_NLS.Get('BWMINS1-0009','SQL','You have already submitted an Insurance Compliance Form for the current semester');
                twbkfrmt.P_PrintMessage(msg_text_out,'NOTE');
                htp.p('Contact the Health Insurance Office at 303-556-2525 if you have any questions');

--               htp.p('You have already submitted a insurance purchase for this academic year and it has been <b>approved</b>.');
--               GOTO endofform;   
   elsif  tzkar01.f_m_check_insure_purchase(global_pidm, term, tzkar01.REJECTED_PURCHASE) = 'Y' then
                msg_text_out := G$_NLS.Get('BWMINS1-0010','SQL','You have already submitted an Insurance Compliance Form for the current semester');
                twbkfrmt.P_PrintMessage(msg_text_out,'NOTE');
                htp.p('Contact the Health Insurance Office at 303-556-2525 if you have any questions');

--                htp.p('You have already submitted a health insurance purchase for this academic year and your purchase 
--                      has been <b>denied</b> based on the information you submitted to the College. Contact the 
--                      Health Insurance Office if you have questions regarding this denial.');
--               GOTO endofform;   
   elsif tzkar01.f_m_check_insure_purchase(global_pidm, term, tzkar01.SUBMITTED_PURCHASE) = 'Y' then
                msg_text_out := G$_NLS.Get('BWMINS1-0008','SQL','You have already submitted an Insurance Compliance Form for the current semester');
                twbkfrmt.P_PrintMessage(msg_text_out,'NOTE');
                htp.p('Contact the Health Insurance Office at 303-556-2525 if you have any questions');

--               htp.p('You have already submitted a health insurance purchase for this academic year and at this time your 
--                      purchase is in the approval process.');
--               GOTO endofform;   
/*   elsif tzkar01.f_m_check_census(term) = 'Y' then
                msg_text_out := G$_NLS.Get('BWMINS1-0004','SQL','Form is not active for this Term');
                twbkfrmt.P_PrintMessage(msg_text_out,'ERROR');
                htp.p(' ');
--                GOTO endofform; */
    end if;


    RETURN FormState;
END F_ScreenValidate; 

/***********************************************************************/ 
/* Procedure to retreive student's address of type AA.  If there is no */
/* address, the first line of the street address contains the string   */
/* No Address.                                                         */
/***********************************************************************/
procedure get_address(pidm_parm IN spriden.spriden_pidm%TYPE,
                      r_street_line1  OUT spraddr.spraddr_street_line1%TYPE,
                      r_street_line2  OUT spraddr.spraddr_street_line2%TYPE,
                      r_street_line3  OUT spraddr.spraddr_street_line3%TYPE,
                      r_city          OUT spraddr.spraddr_city%TYPE,
                      r_stat_code     OUT spraddr.spraddr_stat_code%TYPE,
                      r_zip           OUT spraddr.spraddr_zip%TYPE)
is
    addr gb_address.address_rec;
    ref_curs gb_address.address_ref;


retval VARCHAR2(1);
begin

    /* Initialize first line to No Address */
    r_street_line1 := '**** No Address *****';
    
    if ( 'Y' = gb_address.f_exists(pidm_parm,'AA')) then
        ref_curs := gb_address.f_query_all(pidm_parm);
    
        loop
        fetch ref_curs into addr;
            if( ref_curs%FOUND) then
               if (addr.r_atyp_code = 'AA' AND addr.r_status_ind is NULL) then
                   r_street_line1 := addr.r_street_line1;
                   r_street_line2 := addr.r_street_line2;
                   r_street_line3 := addr.r_street_line3;
                   r_city := addr.r_city;
                   r_stat_code := addr.r_stat_code;
                   r_zip := addr.r_zip;
               end if;
            else
               exit;
            end if;
        end loop;
    end if;
end get_address;

/*******************************************************************/
/* Procedure to retreive student's full name. If there is no name, */
/* this procedure returns the string No Name in the first name     */
/* variable.                                                       */
/*******************************************************************/
procedure get_name(pidm_parm IN spriden.spriden_pidm%TYPE, 
                   r_last_name     OUT       spriden.spriden_last_name%TYPE,
                   r_first_name    OUT       spriden.spriden_first_name%TYPE,
                   r_mi            OUT       spriden.spriden_mi%TYPE,
                   r_id            OUT       spriden.spriden_id%TYPE)
IS

    ref_cur gb_identification.identification_ref;
    id_ref gb_identification.identification_rec;

begin
    ref_cur := gb_identification.f_query_one(pidm_parm);
    fetch ref_cur into id_ref;
    
    /* retreive either the name or indicate no name */
    if (ref_cur%FOUND) then
        r_first_name := id_ref.r_first_name;
        r_last_name := id_ref.r_last_name;
        r_mi := id_ref.r_mi;
        r_id := id_ref.r_id;
    else 
        r_first_name := '*** No Name ****';
    end if;
end get_name;
 

/*******************************************************************/ 
/* Procedure to retrieve the student's social security number and  */
/* birth date.                                                     */
/*******************************************************************/
procedure get_bio(pidm_parm IN spriden.spriden_pidm%TYPE,
--                  ssn_value   OUT spbpers.spbpers_ssn%TYPE,
                  birth_value OUT spbpers.spbpers_birth_date%TYPE)
IS
bio_record    gb_bio.bio_rec;
bio_refcursor gb_bio.bio_ref;

begin

   bio_refcursor := gb_bio.f_query_one(pidm_parm);
   fetch bio_refcursor into bio_record;
   
--   ssn_value := bio_record.r_ssn;
   birth_value := bio_record.r_birth_date;
   
end get_bio;

/*************************************************************************/
/* Procedure to retrieve the student's email address.  If there is no    */
/* email address, the email address contains the string No Email Address */
/*************************************************************************/
procedure get_email(pidm_parm IN spriden.spriden_pidm%TYPE,
                    email_address OUT goremal.goremal_email_address%TYPE)
IS

   e_record gb_email.email_rec;
   e_cursor gb_email.email_ref;
begin
  e_cursor := gb_email.f_query_all(pidm_parm,'MSCD','%');
  fetch e_cursor into e_record;
  
  if (e_cursor%FOUND) then
     email_address := e_record.r_email_address;
  else
     email_address := ' *** No Email Address ***';
  end if;
end get_email;

/************************************************************************/  
/* Procedure to retrieve the student's phone number for address type AA */
/************************************************************************/
procedure get_prim_phone(pidm_parm IN spriden.spriden_pidm%TYPE,
                         complete_phone_number OUT VARCHAR2)
IS

 tel_record gb_telephone.telephone_rec;
 tel_cursor gb_telephone.telephone_ref;

begin

    tel_cursor := gb_telephone.f_query_all(pidm_parm);


   /* loop through all phone numbers until type AA number is found */
   loop
      fetch tel_cursor into tel_record;
      exit when tel_cursor%NOTFOUND;
   
     if (tel_record.r_tele_code = 'AA' OR tel_record.r_primary_ind = 'Y') then
      complete_phone_number := '(' || tel_record.r_phone_area || ') ' || tel_record.r_phone_number;
     else
      complete_phone_number := '*** No Primary Phone ***';
     end if;
   end loop;
end get_prim_phone ;

/*******************************************************************/ 
/* Procedure to retrieve the census waiver date for the            */
/* current three terms.                                            */
/*******************************************************************/
procedure get_census_date (term_in IN varchar2)
IS
 
  vl_term_code SOBPTRM.SOBPTRM_TERM_CODE%TYPE;  
  vl_census_date SOBPTRM.SOBPTRM_CENSUS_DATE%TYPE; 
  vl_month varchar2(10);
 CURSOR term_date 
 IS 
 SELECT SOBPTRM_TERM_CODE, SOBPTRM_CENSUS_DATE
 
 FROM SOBPTRM
 WHERE SOBPTRM_PTRM_CODE = '1' AND SOBPTRM_TERM_CODE >= term_in
 ORDER BY SOBPTRM_TERM_CODE;
 BEGIN

    OPEN term_date;
    FOR l IN 1..3 LOOP
    FETCH term_date INTO vl_term_code, vl_census_date;

    if (substr(vl_term_code, 5,2) = '30') then
      vl_month := 'Spring';
    elsif (substr(vl_term_code, 5,2) = '40') then
     vl_month := 'Summer';
    elsif (substr(vl_term_code, 5,2) = '50') then
     vl_month := 'Fall';
    end if;    

		census_term(l)     := vl_month ||' '|| substr(vl_term_code, 1, 4);
		census_term_day(l) := to_char(vl_census_date, 'MONTH DD, YYYY');
		 
		if (INSTR(vl_month, 'Spring') > 0) then 
		  census_term_note(l) := '*';  
		  elsif (INSTR(vl_month, 'Summer') > 0) then 
		    census_term_note(l) := '**';
		    else
		      census_term_note(l) := ' ';
		end if;
    END LOOP;
  CLOSE term_date;
END get_census_date;

/****************************************************
Function to verify that phone number is in proper format

This function verifies that the specified phone number is in a 
valid format, a string of 10 digits containing only numbers.  
If the phone passes both of these constraints, a value of 'Y' 
is passed to the caller, otherwise 'N'.

Parameters:
  phone number  Phone number to be checked
  phone number characters String containing digits for validation
  
Return:
  Y Phone number is valid
  N Invalid phone number
  
******************************************************/

FUNCTION has_phone_number_chars (
        p_candidate_phone_number    IN  VARCHAR2
    ,   p_phone_number_chars        IN  VARCHAR2 DEFAULT '0123456789+/'
    )
    RETURN VARCHAR2
    IS
        l_is_valid      VARCHAR2(1);
        check_phone_number    VARCHAR2(20);
    BEGIN
    
        check_phone_number := p_candidate_phone_number;
        
        /* phone number must be a string of numbers */   
        IF (TRANSLATE (check_phone_number
           ,          CHR(1) || p_phone_number_chars
           ,          CHR(1)) IS NULL) THEN
           l_is_valid := 'Y';
       ELSE
           l_is_valid := 'N';
       END IF;
       
       /* phone number must be exactly 10 digits long */
       if length(check_phone_number) <> 10 then
             l_is_valid := 'N';     
       end if;
       
       RETURN (l_is_valid);
   END has_phone_number_chars;

/*********************************************************************
Function to remove extra characters and spaces from phone number

This function removes spaces and non-numeric characters, such as dashes 
or parenthesis, commonly found in published phone numbers.  However, 
alphabetic characters remain in the phone number.  The function 
converts a phone number to a continuous string of numbers.

Parameters:
   phone_number Phone number to be changed

Return
   Filtered phone number.
************************************************************************/

FUNCTION filter_phone_number(phone_number IN  VARCHAR2) RETURN VARCHAR2
    IS
        check_phone_number    VARCHAR2(20);
    BEGIN
    
   check_phone_number := phone_number;
        
   /* remove extra characters in phone number */
   check_phone_number := translate(check_phone_number,' ().-',' ');
   check_phone_number := replace( check_phone_number, ' ' );
 
   /* Remove leading one from phone number */
   if (instr(check_phone_number,'1',1) = 1 AND  length(check_phone_number) > 10) then
       check_phone_number := rtrim(substr(check_phone_number , 2 , 11));
   end if;
  
  return(check_phone_number);
end filter_phone_number;

/*********************************************************************/
/*  This function returns the ending term for an insurance waiver.   */
/* The caller specifies the starting term for the insurance waiver   */
/* and this function computes the ending term for the waiver (always */
/* the following summer.                                             */
/*********************************************************************/
function endTerm(termcode_parm VARCHAR2) return VARCHAR2
is
 ret_string VARCHAR2(6);
begin

case
when substr(termcode_parm,5,2) = '50' then ret_string := substr(termcode_parm,1,4)+1 || '40';
when substr(termcode_parm,5,2) = '40' then ret_string := termcode_parm;
when substr(termcode_parm,5,2) = '30' then ret_string := substr(termcode_parm,1,4) || '40';
end case;

return(ret_string);
end;

-------------------------- part2

---------------------------------  part3

Procedure P_ShowIntro
IS

BEGIN

htp.p('<b>STEP BY STEP INSTRUCTIONS FOR COMPLETING THE REQUIRED ON-LINE HEALTH INSURANCE SELECTION FORM</b><br /> ');
htp.p('<p>To All Metro State Students,</p>

<p>Contained within these web pages are specific instructions for submitting an on-line health insurance 
selection form. At the end of the detailed instructions, you will find the on-line insurance selection
form that must be submitted electronically to the College.</p>');

htp.p('<p>You may proceed directly to the content that follows the video below, skipping the video. 
However, you may find it extremely helpful to watch the video <strong>first</strong> before proceeding, 
since it was designed to assist you in understanding the College student health insurance policy and 
how to become compliant.</p>'); 

htp.p('<p>Link to video here</p>');

htp.p('<p>All students, both undergraduate and graduate,
who are taking 9 or more credit hours during any semester are required to show proof of having health 
insurance that meets the College''s compliance standards. Students can either select to purchase the 
College offered health insurance plan or they can submit information regarding their outside health 
insurance coverage that meets each of the College''s compliance standards.</p>
 
<p><strong>The College is pleased to announce that it has successfully negotiated a high quality student health
insurance plan that is offered exclusively to Metro State students. The plan includes outstanding benefits
at an extremely low cost compared to similar private sector health insurance options. We encourage students
to become familiar with the College offered plan because of the outstanding value it represents. 
The College''s primary goal has been to provide Metro State students with an economical health insurance 
product that includes benefits which will assist students in keeping their healthcare costs as low as possible. 
When compared to private sector health insurance options, the College offered plan will be difficult to match. 
We encourage this type of comparison. Please note that the College offered plan already includes most of the 
Federal health insurance mandates for 2014, several years before they are actually required. Few, if any, 
private sector insurance plans have included similar benefits at this time; each of these benefits are 
extremely beneficial to the insured and are consumer improvements attained through 
Federal Health Care Reform.</strong></p>');

htp.p('<p><br>');

htp.p('<table width="97%" border="5" cellspacing="0" cellpadding="0">
     <tr><td><table border="0">
        <tr>
          <td><strong>PLEASE STOP AND READ THE IMPLICATIONS TO YOU</strong><br /></td>
        </tr>
        <tr>
          <td><strong>IF YOU ARE NOT IN COMPLIANCE WITH THE COLLEGE HEALTH INSURANCE REQUIREMENT</strong><br /></td>
        </tr>
        <tr>
          <td>It is essential that any student taking 9 credit hours or more in a semester follow through and 
          submit an insurance selection form. If a student does not submit an insurance selection form the following 
          implications will occur.</td>
        </tr>
        <tr>
          <td><br /><ol>
              <li>A &quot;hold&quot; will be placed on the student''s account and they will not be able to register
               for classes again until they have fully complied with the College policy. Students will either have 
               to purchase the College offered insurance plan or submit proof of outside coverage that meets 
               the College''s compliance standards BEFORE an insurance &quot;hold&quot; will be removed. </li>
              <li>In addition, so that lack of compliance will not occur a second time, insurance holds may be placed 
              on a student''s account for all future semester of attendance at Metro State College.</li>
          </ol></td>
        </tr>
        <tr>
          <td>STUDENTS CAN AVOID THESE IMPLICATIONS <u>BY SIMPLY SUBMITTING AN INSURANCE SELECTION FORM EACH SEMESTER</u> 
          THEY ARE TAKING 9 CREDIT HOURS OR MORE. FOR STUDENTS CHOOSING TO PURCHASE THE COLLEGE OFFERED PLAN THEY MUST 
          PROVIDE CREDIT CARD PAYMENT INFORMATION AT THE TIME OF SELECTION. HOWEVER, STUDENTS MAY CHOOSE TO DELAY WHEN 
          THEIR CREDIT CARD IS ACTUALLY CHARGED BY SELECTING THE DEFERRED PAYMENT OPTION. IN THIS CASE, A STUDENT''S 
          CREDIT CARD WILL BE CHARGED AFTER THE START OF THE SEMESTER, AFTER FINANCIAL AID FUNDS HAVE BEEN DISPERSED. </td>
        </tr>
      </table>
      </td></tr>
</table>');

htp.p('<p><br />');

htp.p('<table width="97%" border="5" cellspacing="0" cellpadding="0">
        <tr>
          <td valign="center">
            <p align="center">&nbsp;<br /><font size="+1"><strong>IMPORTANT FACT...</strong></font><br />
              Submission of an Insurance Selection Form is required EVERY semester a student takes nine (9) credit hours or more.&nbsp;<br /><br /></p></td>
        </tr>
      </table>');

htp.p('<p><br />');

END P_ShowIntro;

Procedure P_ShowPart1
IS

BEGIN

htp.p('<p align="center"><font size="+2"><strong>3 SIMPLE STEPS TO COMPLIANCE</strong></font></p>');
htp.p('<table width="97%" border="5" cellspacing="0" cellpadding="0">
  <tr>
    <td valign="top" align="center" bgcolor="#CCCCCC"><p align="center"><font size="+1">
      <strong>General Instructions - Step 1 of 3</strong><br />
      <strong>Become Familiar with the Requirements for Submitting an On-Line Insurance Selection Form to the College.</strong></font></p></td>
  </tr>
</table>
<p>&nbsp;</p>
<ul>
  <li>If you do not have outside health insurance or if your current health insurance does not meet
   each of the College''s minimum compliance standards outlined below (which include Federally 
   mandated requirements) you should select to purchase the College offered plan in order to meet 
   the College''s requirement for health insurance.</li>
<p>Or </p>
  <li>If  you have outside health insurance that meets each of the College''s minimum compliance 
   standards outlined below you can submit your current insurance carrier information which will 
   then be audited to confirm that your plan in fact meets each of the minimum compliance standards.
    DO NOT ASSUME THAT YOUR PLAN MEETS THE COMPLIANCE STANDARDS WITHOUT CONFIRMING THIS WITH YOUR 
    INSURANCE CARRIER <u>PRIOR TO SUBMITTING THE INSURANCE SELECTION FORM.</u></li>
</ul>
<br />

<p><strong><u>Metro State Insurance Compliance Standards</u></strong></p>

<p>All submitted outside insurance plans must meet each of these standards.
Students should NOT submit outside insurance plan information without confirming
that the plan they submit meets each of these compliance standards.  

<ol>
  <li>Must be a "Comprehensive Health Insurance Plan" that covers medical care for 
both Injury and Illness, including Out-Patient and In-Patient medical services.<BR /> 
(Note: Diagnosis only policies, such as cancer policies; Hospitalization only 
policies; Catastrophic only policies; Injury only policies and other "Non-
Comprehensive" polices do not comply.)</li> 
  <li>Annual deductible of $5000 or less</li>
  <li>Mental health coverage that includes both In-Patient and Out-Patient benefits.</li>
  <li>Lifetime maximum $750,000 or more</li>
  <li>Prescription drug coverage that is fully-insured(not a prescription discount program.)</ul>
</ol>
<br />
<p><strong><u>Notation One:</u></strong><br />
  Short Term Medical Plans (STM) are not acceptable for compliance purposes.<br />
  <strong><u>Notation Two:</u></strong><br />
  The Colorado Indigent Care Program (CICP) is not insurance and cannot be used for compliance purposes.<br />
  <strong><u>Notation Three:</u></strong><br />
  HSA Programs  (Health Savings Accounts) are not insurance plans; they are savings accounts.
  A HSA without an associated health insurance plan, cannot be used as proof of meeting 
  the College''s compliance standards. However, if in addition to an HSA account, a student 
  has another supplemental health insurance policy which could possibly meet the College''s 
  compliance standards, the Student Insurance Office should be contacted (303-556-2525) 
  prior to the compliance deadline. The insurance office will then make a determination 
  as to whether or not compliance can be granted. </p>
<p><strong><br />
</strong></p>');

END P_ShowPart1;

Procedure P_ShowPart2
IS

BEGIN

htp.p('<table width="97%" border="5">
<tr>
<td valign="top" align="center" bgcolor="#CCCCCC"><p align="center"><font size="+1">
<strong>General Instructions - Step 2 of 3</strong><br />
<strong>Become Familiar with the Insurance Compliance Deadline Dates.</strong></font></p></td>
</tr>
</table>');

htp.p('<br />
<p>Be Aware - <u>You must submit your insurance selection form by the compliance deadline for the semester 
you are applying.</u></p>
<p>The insurance compliance deadline dates are as follows:</p>');

-- htp.p('the term is ' || term);
get_census_date(term);

htp.p('<p>
    <table width="65%" border="0" cellspacing="0" cellpadding="0">
      <tr> 
        <td width="40%"><strong>SEMESTER</strong></td>
        <td width="60%"><strong>LAST DAY TO SUBMIT AN INSURANCE SELECTION FORM</strong></td>
      </tr>
      <tr> 
        <td>' || census_term(1) || '</td>
        <td>' || census_term_day(1) || census_term_note(1) ||'</td>
      </tr>
      <tr> 
        <td>' || census_term(2) ||'</td>
        <td>' || census_term_day(2) || census_term_note(2) ||'</td>
      </tr>
      <tr> 
        <td>' || census_term(3) || '</td>
        <td>' || census_term_day(3) || census_term_note(3) ||'</td>
      </tr>
    </table>');

htp.p('<p><strong>*</strong>If the student enrolls for the Spring semester, that enrollment is carried through the following Summer Semester in the same year.</p>');
htp.p('<p><strong>**</strong>Summer semester applies to students who enroll for the very first time during
the Summer semester.</p>');

htp.p('<p>Students who fail to submit an insurance compliance form by the compliance deadline will have
a "HOLD" placed on their student account and will NOT be permitted to register for any future 
semesters until an insurance selection form is submitted, audited and 
approved by the Student Health Insurance Office.</p>
<p>Compliance deadlines are contractually agreed to and are consequently strictly adhered to by 
the College. </p>
<p><font pointsize="16"><strong>NO INSURANCE SELECTION FORMS WILL BE ACCEPTED AFTER THE PUBLISHED 
COMPLIANCE DEADLINES.</strong></font></p>');

END P_ShowPart2;

Procedure P_ShowPart3
IS

BEGIN

htp.p('<table width="97%" border="5" cellspacing="0" cellpadding="0">
  <tr>
    <td valign="top" align="center" bgcolor="#CCCCCC"><p align="center"><font size="+1"><strong>General Instructions - Step 3 of 3</strong><br />
    <strong>Become Familiar with the Insurance Selection Form Instructions.<BR /> 
    Complete and Submit Your Insurance Selection Form.</strong></font></p></td>
  </tr>
</table>');

htp.p('<p><strong>Basic Information Students Must Know...</strong></p>
<ul>
  <li>If you are a legal dependent of your parent or  guardian, please share the College&rsquo;s 
  health insurance requirement information  with them prior to submitting an insurance selection form. </li>
</ul>
<ul>
  <li>Submit your insurance selection form by the  published compliance deadline indicated in step two (2) above. </li>
</ul>
<ul>
  <li>For students submitting outside health insurance  information you must first confirm that your plan 
  meets each of the College&rsquo;s  compliance standards. <strong><u>Prior to  submission of an insurance 
  selection form</u></strong> students are to contact their  insurance carrier to determine if their plan 
  meets each of the College&rsquo;s minimum compliance standards listed in step  one (1) above. If a 
  student&rsquo;s outside plan does not meet the College&rsquo;s  compliance standards, then a student 
  should either select the College offered plan or purchase outside insurance coverage that meets each 
  of the compliance  standards. </li>
</ul>
<ul>
  <li>Note that the submit button located at the end  of the Insurance Selection form will only work if a 
  student has completed all  of the required fields, including checking the agreement box after the  
  disclosures, acknowledgements and authorizations section. </li>
</ul>
<ul>
  <li>ECI (Evans Consulting, Inc.) is the third party  insurance processing agency in Denver, Colorado 
  hired by the insurance carrier.  ECI is the agency who will be collecting the insurance premiums and 
  doing the associated billing for those purchasing the College offered insurance plan. The College no 
  longer bills for student health insurance. </li>
</ul>
<p><strong>What Happens After a Student Submits an Insurance Selection Form...</strong></p><br />
<ul>
  <li>If a student selects to purchase the College  offered health insurance plan they will receive a 
  confirmation e-mail sent to their College e-mail account from ECI indicating that they are in receipt 
  of the  student&rsquo;s request to purchase the College offered plan. </li>
</ul>
<p>OR</p>
<ul>
  <li>If a student submits outside health insurance information on the insurance selection form and 
  it is verified as  meeting each of the College&rsquo;s compliance standards, the student will be 
  communicated to by e-mail confirming insurance compliance. </li>
</ul>
<p>OR</p>
<ul>
  <li>If a student submits outside health  insurance information on the insurance selection form and 
  this information <u>is  not verifiable</u> as meeting each of the college&rsquo;s compliance standards, 
  the  student&rsquo;s insurance selection form will not be approved. In this case the student will be 
  communicated to by either e-mail or phone requesting that the  student immediately contact ECI to 
  either purchase the College offered insurance plan or to provide other outside insurance information 
  that meets the  College&rsquo;s compliance standards. Students failing to respond to this  communication 
  to resolve their compliance issue will have their student account  placed on hold by the College, which 
  will prevent any future semester registrations at the College.</li>
</ul>');

htp.p('<p><strong>Notation One:</strong><br />If after submitting an electronic insurance selection form 
you do not receive a &ldquo;submission confirmation e-mail&rdquo;  within 24 hours, please contact the 
Student Insurance Office immediately at  303-556-2525, since your selection form very likely did not get 
transmitted successfully.</p>
<p><strong>Notation Two:</strong><br />If you need to make corrections or changes to the insurance selection 
information you already submitted electronically, you must call ECI at <strong>1-866-780-3824</strong>.
Your changes will then be manually entered by ECI. This is  
because after you &ldquo;click&rdquo; the &ldquo;SUBMIT&rdquo; button one time, the form is programmed  
so that you cannot access this form again until the next semester.<br /></p>
<p><strong>Notation Three:</strong><br />When you are completing  the insurance selection form, if you determine 
that you do not have all of the  required information needed, DO NOT &ldquo;click&rdquo; the &ldquo;SUBMIT&rdquo; 
button. Simply close  out of the site and come back at a later time to start over.</p>');

END P_ShowPart3;

---------------------------  part3

---------------------------------  part4

Procedure P_ShowStep1
IS

BEGIN

htp.p('<table width="97%" border="5" cellpadding="0" cellspacing="0">
  <tr>
    <td width="97%" valign="top" bgcolor="#CCCCCC">
      <p align="center"><font size="+2"><strong>Metropolitan State College of Denver Insurance Selection Form</strong></font></p></td>
  </tr>
</table>
<p>&nbsp;</p>
<table  width="97%" border="5" cellspacing="0" cellpadding="0">
  <tr>
    <td valign="top" align="center" bgcolor="#CCCCCC"><p><strong>STEP 1: REVIEW YOUR PERSONAL PROFILE DATA FOR ACCURACY</strong></p></td>
  </tr>
</table>
<p>Your current student profile in the College''s computer system includes the following personal data:</p>
<p><br />
  Current Personal Information - 900#, Current Name, Current Address, Primary Phone Number, College E-mail Address, Date  of Birth<br />
  </p>');
/*------------------------------*/
/* Display Personal Information */
/*------------------------------*/

htp.p('<font size="-1"><p>Your current student profile in the College&rsquo;s computer system includes the following personal data:<p></font>');

twbkfrmt.p_tableopen ('DATADISPLAY',
                      ccaption      => 'Current Personal Information',
                      cattributes   => 'SUMMARY="This table shows addresses and phones."');
      twbkfrmt.p_tablerowopen;
      twbkfrmt.p_tableheader('Student ID');
      twbkfrmt.p_tableheader('Current Name');
      twbkfrmt.p_tableheader('Current Address');
      twbkfrmt.p_tableheader('Phone Number');
      twbkfrmt.p_tableheader('Email Address');
      twbkfrmt.p_tableheader('Date of Birth');
      twbkfrmt.p_tablerowclose;
      
      twbkfrmt.p_tablerowopen;
      twbkfrmt.p_tabledata(disp_student_id);
      twbkfrmt.p_tabledata(rtrim(disp_first_name) || '<br>' || rtrim(disp_last_name)|| '&nbsp');
      twbkfrmt.p_tabledata(whole_street || '<br>' || whole_city_state|| '&nbsp');
      twbkfrmt.p_tabledata('Primary: ' || disp_prim_phone || '&nbsp');
      twbkfrmt.p_tabledata(disp_email|| '&nbsp');
      twbkfrmt.p_tabledata(TO_CHAR(disp_birth,'DD-Mon-YYYY'));
      twbkfrmt.p_tablerowclose;
      
twbkfrmt.p_tableclose;
  
-- variable part of this screen 
--<p>900-900-900<br />
--Mark Schultz <br />
--3321 W 10th Avenue Pl<br />
--Broomfield, CO 80020-6751<br />
--Primary: (303) 5552435 <br />
--schultzm@mscd.edu<br />
--01-Feb-1999<br />
-- ------------------

htp.p('</p>
<p>Please review your personal information for accuracy. If changes are needed, click the Update  
Address and Phone Number Link at the bottom of this page. Make the necessary changes to your Student 
Address information and then resume completing the insurance selection form.</p>
<p>&nbsp;</p>
');


END P_ShowStep1;

Procedure P_ShowStep2 (zipcode IN VARCHAR2)
IS

BEGIN

HTP.FormOpen('bwmsinwb.P_InsComplDisplay', 'post');
htp.p('
<table  width="97%" border="5" cellspacing="0" cellpadding="0">
  <tr>
    <td valign="top" bgcolor="#CCCCCC"><p align="center"><strong>STEP 2: REVIEW AND AGREE TO THE DISCLOSURES, 
    ACKNOWLEDGEMENTS AND AUTHORIZATIONS </strong><br />
      <strong>Agreement Box Must Be Checked Before Proceeding/Submitting</strong></p></td>
  </tr>
</table>
<p><strong>I am fully aware and agree to each of the following: </strong><strong> </strong></p>
<ul>
  <li>I release Metro State College, the Health Center at Auraria and ECI from any and all liability related to my health and/or  health care. </li>
</ul>
<ul>
  <li>If I am a legal dependant, I understand that I should discuss this policy with my parents prior to the compliance deadline. </li>
</ul>
<ul>
  <li>No insurance selection forms will be accepted after the published compliance deadline. </li>
</ul>
<ul>
  <li>If I miss the published compliance deadline I am to contact ECI at <strong>1-866-780-3824</strong>
  immediately. Based on the date when I call, ECI will inform me if there  
  are any options to avoid having my student account put on hold.</li>
</ul>
<ul>
  <li>If I selected to purchase the College offered  student health insurance plan I am financially 
  responsible for paying the  insurance premium to ECI. </li>
</ul>
<ul>
  <li>I am aware that I must have health insurance that meets the College&rsquo;s compliance standards 
  in force throughout the entire  course of any semester in which I am taking 9 credit hours or more. </li>
</ul>
<ul>
  <li>I understand that the Metro Connect e-mail service is the College&rsquo;s official 
  form of communication to students. It is each student&rsquo;s responsibility to routinely check 
  their Metro Connect e-mail for important College communications, some of which may include 
  critical deadlines  with financial implications. </li>
</ul>
<ul>
  <li>I acknowledge that the information I provide is  accurate and truthful. If my insurance carrier 
  fails to confirm my insurance  coverage as I have indicated, including the necessary level of benefits  
  required for compliance purposes, I understand that my insurance selection form  will be denied. 
  In which case I must contact ECI immediately upon notification  of my Insurance Selection Form being 
  denied so that I can either purchase the  College offered insurance plan or provide outside insurance 
  coverage that meets  each of the College&rsquo;s compliance standards. Otherwise, my student account 
  will be place on &ldquo;hold&rdquo; and I will not be permitted to register for future semesters. </li>
</ul>
<ul>
<li>If a student''s outside health information is audited twice and fails both times, then the student 
will be required to purchase the College offered plan in order to achieve compliance.</li>
</ul>
<ul>
  <li>I am aware that the student code of conduct and any associated disciplinary action may apply in 
  reference to supplying  information to the College that is not accurate and truthful. Prior to 
  submitting my insurance selection form I will confirm that my insurance is currently active and 
  that my level of  benefits meet each of the College&rsquo;s compliance standards. </li>
</ul>
<ul>
  <li>I am aware that prior to submitting an electronic Insurance Selection form with outside health insurance 
  information I must  verify that the phone number I am submitting as the customer/member services  
  phone number for my insurance company is in fact the correct number for verification of my coverage. 
  If not, I realize that my insurance selection form  may be denied for the semester in question.</li>
</ul>
<p><strong><u>HIPPA Authorization: </u></strong><br />
I authorize the  College, the College&rsquo;s student health insurance company and/or ECI to verify 
my health insurance coverage, including my mental health benefits. I also authorize my insurance company 
to provide such verification of coverage (for  medical and mental health services) and the associated 
level of benefits to the  College&rsquo;s student insurance carrier, ECI and/or College insurance personnel.</p>
<p><br />');
  
--  <input name="haack" type="checkbox" value="hippaack" />
--  Check the box to the left to indicate your understanding and agreement to all of the above disclosures, 
--  acknowledgements and authorizations, including the HIPPA authorization. </p>

	twbkfrmt.P_TableOpen('DATADISPLAY', CATTRIBUTES=>'width=100%');
	twbkfrmt.p_tablerowopen;
	twbkfrmt.P_TableDataOpen(ccolspan=>'1');
	twbkfrmt.p_tabledata(htf.formCheckbox('checkit','z'));
	twbkfrmt.p_tabledata('<b>Check the box to the left to indicate your understanding and agreement 
  to all of the above disclosures, acknowledgements and authorizations, including the HIPPA authorization.',
	CATTRIBUTES=>'width=95%');
	twbkfrmt.p_tablerowclose;
	twbkfrmt.P_Tableclose;

/* set value so there is no zero length checkit entries */
	htp.formHidden('checkit','z');
	htp.formHidden('zipcode', zipcode);
--	htp.formHidden('term_in', termcode);

--   if NOT has_waiver(global_pidm, term ) then
  twbkfrmt.P_TableOpen('DATADISPLAY', CATTRIBUTES=>'width=80%');
  twbkfrmt.P_TableRowOpen;
  twbkfrmt.P_TableDataOpen(ccolspan=>'2');
--  htp.formsubmit(null,'Continue');
  htp.formsubmit(NULL,'Continue','style="color:#FFF;background:#9C0;font-size:24px"');
  twbkfrmt.P_TableDataClose;
  twbkfrmt.P_tableRowClose;
  twbkfrmt.P_Tableclose;
--     htp.formreset('RESET');
--   end if;
-- htp.formhidden('aaa');

HTP.FormClose;
twbkwbis.P_CloseDoc(curr_release);
END P_ShowStep2;

Procedure P_ShowStep3 (TermCode in twrwaiv.twrwaiv_from_term%type,
                       zipcode in VARCHAR2, checkit in OWA_UTIL.ident_arr)
IS
/*  TERM SETUP SOME OTHER WAY  ******/
	trmloc NUMBER;
	TERM_NAME_S VARCHAR2(20) := ' ';
	TERM_NAME_E VARCHAR2(20) := ' ';

BEGIN
  get_census_date(TermCode);
	trmloc := INSTR(census_term(1),' ');
	TERM_NAME_S := SUBSTR(census_term(1),1,trmloc-1) || ' Semester ' || SUBSTR(census_term(1),trmloc+1);
	trmloc := INSTR(census_term(2),' ');
	TERM_NAME_E := SUBSTR(census_term(2),1,trmloc-1) || ' Semester ' || SUBSTR(census_term(2),trmloc+1);

	HTP.FormOpen('bwmsinwb.P_InsOutside', 'post');
-- htp.p('<p>LOC = ' || TO_CHAR(trmloc) || '</p>'); 
--	htp.formhidden('buy', 'x');
--	htp.formhidden('waive', 'x');
--	htp.formhidden('buy');
--	htp.formhidden('waive');
--	htp.formhidden('termcode', TermCode);
htp.formhidden('zipcode', zipcode);
htp.formhidden('checkit', 'z');

htp.p('
<table width="97%" border="5" cellpadding="0" cellspacing="0">
  <tr>
    <td width="97%" valign="top" bgcolor="#CCCCCC"><p align="center"><strong>STEP 3: </strong><br />
      <strong>CHOOSE OPTION ONE OR OPTION TWO </strong><br />
      <strong>AS YOUR SELECTED INSURANCE OPTION</strong></p></td>
  </tr>
</table>
<strong>OPTION ONE: Requires Two Steps</strong><br /><br />

<p><strong><u>FIRST REQUIRED STEP:</u></strong></p>

<p><input type="checkbox" name="buy" value="Y" />
Check the box to the left to purchase the College offered health insurance 
for ' || TERM_NAME_S || '. The cost is $665 and provides five months of coverage from the first day of 
' || TERM_NAME_S || ' until the first day of ' || TERM_NAME_E || '.<br /></p>

<p><strong><u>SECOND REQUIRED STEP:</u></strong></p>

<p>
&ldquo;Click&rdquo; the &ldquo;SUBMIT&rdquo; button and you will be 
directed to ECI&rsquo;s web-site to enter your credit card or electronic check information. <u>In order 
to complete your request to purchase the College offered insurance you must provide ECI with payment 
information at this time.</u> Once at ECI&rsquo;s web-site, you will have the option to select to pay 
ECI at the time of submission or to request that ECI defer charging your payment method until after the 
start of classes for the semester you are purchasing the insurance (which would be after financial aid  
dollars are distributed.) ECI, the insurance billing agency, will bill your credit card according to your 
preference.
</p>');

    twbkfrmt.P_TableOpen('DATADISPLAY', CATTRIBUTES=>'width=80%');
    twbkfrmt.P_TableRowOpen;
    twbkfrmt.P_TableDataOpen(ccolspan=>'2');
		htp.p('CLICK THE SUBMIT BUTTON TO PURCHASE THE COLLEGE OFFERED HEALTH INSURANCE');
    twbkfrmt.P_TableDataClose;
    twbkfrmt.P_tableRowClose;
    twbkfrmt.P_TableRowOpen;
    twbkfrmt.P_TableDataOpen(ccolspan=>'2');
    htp.formsubmit(NULL,'Submit','style="color:#FFF;background:#9C0;font-size:24px"');
    twbkfrmt.P_TableDataClose;
    twbkfrmt.P_tableRowClose;
    twbkfrmt.P_Tableclose;

--<table border="1" cellspacing="0" cellpadding="0" align="left">
--  <tr>
--    <td width="80%" height="62" valign="top">
--    <INPUT TYPE="button" value="Submit" onClick="goToECI(buy);return true" onMouseOver="window.status=''Click here to go to ECI''; return true"> 
--    </td>
--  </tr>
--  <tr>
--  <td>
--  <p>You will be transfered to an external site to enter your enrollment information</p>
--  </td>
--  </tr>
-- </table>
--    <button name="Submit" type="submit" onClick="location.href=http://www.mscd.edu">Submit</button> 
--     <td width="588"><strong>TO PURCHASE THE COLLEGE OFFERED HEALTH INSURANCE</strong></td>
--    <a href="http://www.eciservices.com">Click here to PURCHASE THE COLLEGE OFFERED HEALTH INSURANCE</a> 

/* setup the insurance audit screens  */

htp.p('<p><br /><br /><br /><br /><strong>OPTION TWO:Requires Two Steps</strong><br /></p>');

--  <p><strong><u>FIRST REQUIRED STEP:</u></strong></p>

htp.p('<table width="97%" border="1" cellspacing="0" cellpadding="0">
  <tr>
    <td height="21" bgcolor="#cccccc"><strong>FIRST REQUIRED STEP</strong></td>
  </tr>
</table>');

--    <td width="60%" bgcolor="#cccccc"><font color="#408080">&nbsp; </font></td>


htp.p('<p><input type="checkbox" name="waive" value="Y" />
Check the box to the left if you have outside health insurance and have 
personally verified with your insurance carrier that your health insurance meets each of the College&rsquo;s 
five (5) compliance standards (see below). Your insurance information will be audited for accuracy and coverage compliance. If 
during the audit process it is discovered that your outside insurance coverage does not meet each of the 
College&rsquo;s  compliance standards you will be notified through College e-mail or by phone that 
you must contact ECI immediately in order to either purchase the College offered plan or to provide outside 
health insurance coverage that meets each of the College&rsquo;s compliance standards.
If a student''s outside health information is audited twice and fails both times, then the student will be 
required to purchase the College offered plan in order to achieve compliance.<br /></p>');

htp.p('<p><b><u>Insurance Compliance Standards:</b></u></p>
<p>All submitted outside insurance plans must meet each of these standards. 
Students should NOT submit outside insurance plan information without confirming that 
the plan they submit meets each of these compliance standards.</p>');

htp.p('<ol>
<li>Must be a "Comprehensive Health Insurance Plan" that covers medical care for both 
Injury and Illness, including Out-Patient and In-Patient medical services.<br />
<i>(Note: Diagnosis only policies, such as cancer policies; Hospitalization only policies; 
Catastrophic only policies; Injury only policies and other "Non-Comprehensive" polices 
do not comply.)</i></li>

<li>Annual deductible of $5,000 or less.</li>
<li>Mental health coverage that includes both In-Patient and Out-Patient benefits.</li>  
<li>Lifetime maximum $750,000 or more.</li>
<li>Prescription drug coverage that is fully-insured (not a prescription discount program).</li>
</ol><br />');

htp.p('<p><b><u>Notation One:</b></u></p>
<p>Short Term Medical Plans (STM) are not acceptable</b> for waiver purposes.</p><br />

<p><b><u>Notation Two:</b></u></p>
<p>Colorado Indigent Care Program (CICP) is not insurance and cannot be used 
for waiver purposes.</p><br />

<p><b><u>Notation Three:</b></u></p>
	 HSA Programs (Health Savings Accounts) are not insurance plans; they are savings accounts. 
	 HSA&rsquo;s without an associated health insurance plan cannot be used as proof of meeting
	 the College&rsquo;s compliance standards. However, if in addition to an HSA account, a student
	 has a supplemental health insurance policy which could possibly meet the College&rsquo;s 
	 compliance standards the Student Insurance Office should be contacted (303-556-2525) prior to 
	 the compliance deadline.  The insurance office will then make a determination as to whether 
	 or not compliance can be granted.</p><br />');

htp.p('<p><b><u>ONLY PROCEED TO THE NEXT STEP IF YOU HAVE COMFIRMED THAT YOUR PLAN
MEETS ALL FIVE OF THE COMPLIANCE STANDARDS ABOVE.</b></u></p><br />');

/********************************************************************************/
/*                                 Step 2 of 2                                  */
/********************************************************************************/

htp.p('<p><br>');


htp.p('<table width="97%" border="1" cellspacing="0" cellpadding="0">
  <tr>
    <td height="21" bgcolor="#cccccc"><strong>SECOND REQUIRED STEP</strong></td>
  </tr>
</table>');

--    <td width="60%" bgcolor="#cccccc"><font color="#408080">&nbsp; </font></td>
 
htp.p('<br>'); 

htp.p('Complete all of the requested information below regarding your outside health insurance coverage 
for all outside health insurance companies including Medicare, Medicaid, Veteran&rsquo;s Administration and 
Active Duty Military.');

htp.p('<br><br>');
      
twbkfrmt.P_TableOpen('DATADISPLAY',
                     ccaption=> 'Insurance Information (Complete all fields)',
                     CATTRIBUTES=>'width=80%');
                                    
 twbkfrmt.p_tablerowopen;
 twbkfrmt.p_tableheader('Description');
 twbkfrmt.p_tableheader('Input Fields');
 twbkfrmt.p_tablerowclose;

twbkfrmt.P_TableRowOpen;
twbkfrmt.P_TableDataLabel('Insurance Company','left',ccolspan=>'1');
twbkfrmt.P_TableDataOpen;
htp.formselectopen('insur_comp');
htp.formselectoption(' ');
htp.formselectoption('Aetna');
htp.formselectoption('AmeriBen');
htp.formselectoption('Anthem or Blue Cross/Blue Shield');
htp.formselectoption('Beechstreet');
htp.formselectoption('Caremark');
htp.formselectoption('CICP');
htp.formselectoption('Cigna');
htp.formselectoption('Cofinity');
htp.formselectoption('Great West Healthcare');
htp.formselectoption('Humana');
htp.formselectoption('Kaiser Permanente');
htp.formselectoption('Medco');
htp.formselectoption('Medicaid');
htp.formselectoption('Medicare');
htp.formselectoption('Pacificare');
htp.formselectoption('PHCS');
htp.formselectoption('Rocky Mountain Health Plan');
htp.formselectoption('Tricare/TriWest');
htp.formselectoption('United Healthcare');
htp.formselectoption('Veterans Administration');
htp.formselectoption('Other');
htp.formselectclose;
twbkfrmt.P_TableDataClose;
twbkfrmt.P_TableRowClose;

twbkfrmt.P_TableRowOpen;
twbkfrmt.P_TableDataLabel('    If Other, please specify ','left',ccolspan=>'1');
twbkfrmt.P_TableDataOpen;
htp.formtext('alternate_insur',50,50);
twbkfrmt.P_TableDataClose;
twbkfrmt.P_TableRowClose;

twbkfrmt.P_TableRowOpen;
twbkfrmt.P_TableDataLabel('Group Number <strong>(No Dashes or Spaces)</strong>','left',ccolspan=>'1');
twbkfrmt.P_TableDataOpen;
htp.formtext('group_num',30,30);
twbkfrmt.P_TableDataClose;
twbkfrmt.P_TableRowClose;

twbkfrmt.P_TableRowOpen;
twbkfrmt.P_TableDataLabel('Insurance ID Number <strong>(Include All Letters, Prefixes and Numbers; NO Dashes or Spaces)</strong>','left',ccolspan=>'1');
twbkfrmt.P_TableDataOpen;
htp.formtext('policy_num',30,30);
twbkfrmt.P_TableDataClose;
twbkfrmt.P_TableRowClose;

twbkfrmt.P_TableRowOpen;
twbkfrmt.P_TableDataLabel('Insurance Verification Phone Number <strong>(Example 8001231234, Do NOT use dashes)</strong>','left',ccolspan=>'1');
twbkfrmt.P_TableDataOpen;
htp.formtext('cust_phone',10,10);
twbkfrmt.P_TableDataClose;
twbkfrmt.P_TableRowClose;

twbkfrmt.P_Tableclose;

htp.p('<table width="97%" border="5" cellpadding="0" cellspacing="0">
  <tr>
    <td width="97%" valign="top"><br />
      <strong>STOP! The insurance verification phone number you submit MUST be the correct CUSTOMER 
      SERVICE/MEMBER PHONE NUMBER  FOR YOUR INSURANCE CARRIER. It is HIGHLY suggested that you call this 
      number to confirm that the phone number you are submitting is in fact the correct  phone number 
      for verification of your insurance coverage. Failure to provide the correct phone number will 
      result in a denial of your insurance selection  form since auditing will not be possible. Do not 
      use any alphabetical letters in the phone number since only numbers are permitted.</strong></td>
  </tr>
</table>
<p></p>');
 
htp.p('<br><br>'); 
 
twbkfrmt.P_TableOpen('DATADISPLAY',
                      ccaption=> 'Subscriber Information (Complete all fields)',
                      CATTRIBUTES=>'width=80%');
                     
/*----------------------*/
/* Ask about dependents */
/*----------------------*/
htp.p(' <font color="#FF0000">*</font> Are you a Dependent on this Plan?');
htp.p('Yes');
htp.formradio('dependent_flag','Yes');
htp.p('No');
htp.formradio('dependent_flag','No','X');
htp.p('<br><br>');

htp.p('<strong>Note: If you are listed as a dependent on your spouse&rsquo;s plan or if you are a legal
dependent on a parent or guardian&rsquo;s plan, you would be considered a dependent for insurance purposes.
In this case your spouse, parent, or guardian would be the actual SUBSCRIBER of the insurance.</strong><br /><br />');

htp.p('If you answered Yes (you are a dependent on the plan you are submitting), then indicate the 
actual subscriber''s last name, subscriber''s first name, subscriber''s date of birth, subscriber''s gender, 
subscriber''s relationship to you and subscriber''s phone number in the fields below.<br /><br />');

htp.p('If you answered No (you are NOT a dependent on the plan you are submitting), then <strong>YOU are the 
SUBSCRIBER</strong> and should indicate <strong>YOUR</strong> last name, <strong>YOUR</strong> first name, 
<strong>YOUR</strong> date of birth, <strong>YOUR</strong> gender, <strong>YOUR</strong> phone number 
and in the relationship field type ''<strong>Self</strong>''.</p>');

htp.p('<br />');             

twbkfrmt.p_tablerowopen;
twbkfrmt.p_tableheader('Description');
twbkfrmt.p_tableheader('Input Fields');
twbkfrmt.p_tablerowclose;

twbkfrmt.P_TableRowOpen;
twbkfrmt.P_TableDataLabel('Subscriber Last Name ','left',ccolspan=>'1');
twbkfrmt.P_TableDataOpen;
htp.formtext('last_name',25,25);
twbkfrmt.P_TableDataClose;
twbkfrmt.P_TableRowClose;                     
                     
twbkfrmt.P_TableRowOpen;
twbkfrmt.P_TableDataLabel('Subscriber First Name ','left',ccolspan=>'1');
twbkfrmt.P_TableDataOpen;
htp.formtext('first_name',20,20);
twbkfrmt.P_TableDataClose;
twbkfrmt.P_TableRowClose;                     
/*                     
twbkfrmt.P_TableRowOpen;
twbkfrmt.P_TableDataLabel('Subscriber Birthdate (MM/DD/YYYY)','left',ccolspan=>'1');
twbkfrmt.P_TableDataOpen;
htp.formtext('birth_date',12,12);
htp.p('<font size="+1">Must be in MM/DD/YYYY format<font size="-1">');
twbkfrmt.P_TableDataClose;
twbkfrmt.P_TableRowClose;
*/
-------------------------------------
------- Below: Month dropdown menu
-------------------------------------
twbkfrmt.P_TableRowOpen;
twbkfrmt.P_TableDataLabel('Subscriber Birthdate (MM/DD/YYYY)','left',ccolspan=>'1');
twbkfrmt.P_TableDataOpen;
htp.formselectopen('month_temp');
htp.formselectoption('');
htp.formselectoption('January',cattributes=>'value="01"');
htp.formselectoption('Febuary',cattributes=>'value="02"');
htp.formselectoption('March',cattributes=>'value="03"');
htp.formselectoption('April',cattributes=>'value="04"');
htp.formselectoption('May',cattributes=>'value="05"');
htp.formselectoption('June',cattributes=>'value="06"');
htp.formselectoption('July',cattributes=>'value="07"');
htp.formselectoption('August',cattributes=>'value="08"');
htp.formselectoption('September',cattributes=>'value="09"');
htp.formselectoption('October',cattributes=>'value="10"');
htp.formselectoption('November',cattributes=>'value="11"');
htp.formselectoption('December',cattributes=>'value="12"');
htp.formselectclose;

-------------------------------------
------- Below: Day dropdown menu
-------------------------------------
htp.formselectopen('day_temp');
htp.formselectoption('');

declare
startDay number :=1;
endDay number :=31;

begin

while startDay <= endDay loop


htp.formselectoption(to_char(startDay,'09'));

startDay :=startDay+1;

end loop;

end;
htp.formselectclose;

-------------------------------------
------ Below: year dropdown menu
-------------------------------------
htp.formselectopen('year_temp');
htp.formselectoption('');

declare
startYear number :=1900;
endYear number :=2050;

begin

while startYear < endYear loop

htp.formselectoption(to_char(startYear));

startYear :=startYear+1;

end loop;
end;

htp.formselectclose;
twbkfrmt.P_TableDataClose;
twbkfrmt.P_TableRowClose;

                     
twbkfrmt.P_TableRowOpen;
twbkfrmt.P_TableDataLabel('Subscriber Gender (M/F)','left',ccolspan=>'1');
twbkfrmt.P_TableDataOpen;
htp.formselectopen('gender');
htp.formselectoption('');
htp.formselectoption('Male',cattributes=>'value="M"');
htp.formselectoption('Female',cattributes=>'value="F"');
htp.formselectclose;
twbkfrmt.P_TableDataClose;
twbkfrmt.P_TableRowClose;                    
                     
twbkfrmt.P_TableRowOpen;
twbkfrmt.P_TableDataLabel('Relationship to Subscriber(Type "Self" if Subscriber is You)','left',ccolspan=>'1');
twbkfrmt.P_TableDataOpen;
htp.formselectopen('relationshp');
htp.formselectoption('');
htp.formselectoption('Child/Dependent',cattributes=>'value="CH"');
htp.formselectoption('Self',cattributes=>'value="SE"');
htp.formselectoption('Spouse/Domestic Partner',cattributes=>'value="SP"');
htp.formselectclose;
twbkfrmt.P_TableDataClose;
twbkfrmt.P_TableRowClose;                     
                     
twbkfrmt.P_Tableclose;

 htp.p('<br><br>'); 

/* display submit button */

--   if NOT has_waiver(global_pidm, term ) then
    twbkfrmt.P_TableOpen('DATADISPLAY', CATTRIBUTES=>'width=80%');
    twbkfrmt.P_TableRowOpen;
    twbkfrmt.P_TableDataOpen(ccolspan=>'2');
		htp.p('CLICK THE SUBMIT BUTTON TO SEND IN OUTSIDE INSURANCE INFORMATION FOR AUDITING');
    twbkfrmt.P_TableDataClose;
    twbkfrmt.P_tableRowClose;
    twbkfrmt.P_TableRowOpen;
    twbkfrmt.P_TableDataOpen(ccolspan=>'2');
--    htp.formsubmit(NULL,'Submit');
    htp.formsubmit(NULL,'Submit','style="color:#FFF;background:#9C0;font-size:24px"');
    twbkfrmt.P_TableDataClose;
    twbkfrmt.P_tableRowClose;
    twbkfrmt.P_Tableclose;

--     htp.formreset('RESET');
--   end if;
	htp.formhidden('term_in', termcode);

HTP.FormClose;
--twbkwbis.P_CloseDoc(curr_release);


END P_ShowStep3;

---------------------------  part4


--  --------------------------------- part6

/***********************************************/
/* Procedure to insert into waiver information */
/* changed Waiver to Outside                   */
/***********************************************/
PROCEDURE insert_waivier( pidm_parm       twrwaiv.twrwaiv_pidm%type,
                          from_term       twrwaiv.twrwaiv_from_term%type,
                          thru_term       twrwaiv.twrwaiv_thru_term%type,
                          group_num       twrwaiv.twrwaiv_group_num%type,
                          policy_num      twrwaiv.twrwaiv_policy_num%type,
                          ins_name        twrwaiv.twrwaiv_ins_name%type,
                          cust_phone      twrwaiv.twrwaiv_cust_phone%TYPE,
                          first_name      twrwaiv.twrwaiv_parent_first_name%type,
                          last_name       twrwaiv.twrwaiv_parent_last_name%type,
                          birth_date      twrwaiv.twrwaiv_parent_dob%type,
                          relationshp     twrwaiv.twrwaiv_parent_relation%type,
                          gender          twrwaiv.twrwaiv_parent_sex%type,
                          alternate_insur twrwaiv.twrwaiv_ins_name%type,
                          zipcode         twrwaiv.twrwaiv_student_zip%type)
                       
is
format_phone_cust   varchar2(20);
format_phone_health varchar2(20);
other_ins           TWRWAIV.TWRWAIV_OTHER_INS%TYPE;

status_code    TWRWAIV.TWRWAIV_STATUS_CODE%TYPE;
approval_code  TWRWAIV.TWRWAIV_APPROVAL_CODE%TYPE;

/*  error processing variables  */
v_code NUMBER;
v_errm VARCHAR2(512);

begin

/*            htp.p('<p>' || 
             TO_CHAR(pidm_parm) || ',' ||
             from_term || ',' ||
             thru_term || ',' ||
             group_num || ',' ||
             policy_num || ',' ||
             ins_name || ',' ||
             cust_phone || ',' ||
             first_name || ',' ||
             last_name || ',' ||
             birth_date || ',' ||
             relationshp || ',' ||
             gender || ',' ||
             alternate_insur || ',' ||
             zipcode  || '</p>');
*/
  format_phone_cust := filter_phone_number(cust_phone);
/*
format_phone_health := filter_phone_number(health_phone);
*/
--  htp.p('<p>step 1</p>');  

if    ins_name like 'Aetna%' then 
    other_ins := 'A';
elsif ins_name like 'AmeriBen%' then
    other_ins :='AB';
elsif ins_name like 'Anthem%' then 
    other_ins := 'B';
elsif ins_name like 'Beech%' then
    other_ins :='BS';
elsif ins_name like 'Care%' then
    other_ins :='CM';
elsif ins_name like 'CICP%' then
    other_ins :='CI';
elsif ins_name like 'Cigna%' then 
    other_ins := 'C';
elsif ins_name like 'Cofinity%' then
    other_ins :='CF';
elsif ins_name like 'Medicaid%' then 
    other_ins := 'D';
elsif ins_name like 'Kaiser%' then 
    other_ins := 'K';
elsif ins_name like 'Medco%' then
    other_ins :='MC';
elsif ins_name like 'Great West%' then 
    other_ins := 'G';
elsif ins_name like 'Humana%' then 
    other_ins := 'H';
elsif ins_name like 'Rocky%' then 
    other_ins := 'M';
elsif ins_name like 'Pacificare%' then 
    other_ins := 'P';
elsif ins_name like 'PHCS%' then
    other_ins :='PH';
elsif ins_name like 'Medicare%' then 
    other_ins := 'R';
elsif ins_name like 'Tri%' then 
    other_ins := 'T';
elsif ins_name like 'United%' then 
    other_ins := 'U';
elsif ins_name like 'Veteran%' then 
    other_ins := 'V';
else
    other_ins := 'O';
end if;

--  htp.p('<p>step 2</p>');  

/* Auto Disapprovals requested by ECI  */
if (ins_name = 'AmeriBen' AND policy_num = '20094611') then
	  status_code := 'CM';
	  approval_code := '18';
elsif (ins_name = 'CICP') then
	  status_code := 'CM';
	  approval_code := '12';
elsif (ins_name = 'PHCS' OR ins_name = 'Beechstreet' OR ins_name = 'Cofinity' 
    OR ins_name = 'Medco' OR ins_name = 'Caremark') then
	  status_code := 'CM';
	  approval_code := '19';
else
	  status_code := 'PN';
	  approval_code := NULL;
end if;

submit_flag := 'N';
--                    TWRWAIV_PARENT_RELATION)
--  htp.p('<p>step 3</p>');  

insert into twrwaiv(TWRWAIV_PIDM ,  
                    TWRWAIV_WAIVCODE,
                    TWRWAIV_ENTRY_DATE ,                                                                                                                                      TWRWAIV_ACTIVITY_DATE ,                                                                                                               
                    TWRWAIV_FROM_TERM,                                      
                    TWRWAIV_THRU_TERM,                                                                                                                    
                    TWRWAIV_USER ,                                                                                                                        
                    TWRWAIV_STATUS_CODE , 
                    TWRWAIV_BATCH_SENT, 
                    TWRWAIV_APPROVAL_CODE,                                                                                                                
                    TWRWAIV_GROUP_NUM ,                                                                                                                   
                    TWRWAIV_POLICY_NUM,                                                                                                                   
                    TWRWAIV_INS_NAME, 
                    TWRWAIV_OTHER_INS,
                    TWRWAIV_CUST_PHONE,
                    TWRWAIV_INS_COMMENT,
                    TWRWAIV_PARENT_LAST_NAME,
                    TWRWAIV_PARENT_FIRST_NAME,
                    TWRWAIV_PARENT_DOB,
                    TWRWAIV_PARENT_SEX,
                    TWRWAIV_PARENT_RELATION,
                    TWRWAIV_STUDENT_ZIP,
                    TWRWAIV_ECI_COMMENT)
      values(pidm_parm,
             'HI',
             sysdate,
             sysdate,
             from_term,
             thru_term,
             USER,
             status_code,
             NULL,
             approval_code,
             group_num,
             policy_num,
             ins_name,
             other_ins,
             format_phone_cust,
             NULL,
             last_name,
             first_name,
             birth_date,
             gender,
             relationshp,
             zipcode, 
             NULL);

--             relationshp);
             
             gb_common.p_commit;
             submit_flag := 'Y';
             
             
         EXCEPTION
            WHEN OTHERS THEN
            v_code := SQLCODE;
            v_errm := SUBSTR(SQLERRM, 1, 80);
            
            htp.p('<p>Error while inserting audit record</p>');
            htp.p('<p>SQLERROR IS:' || TO_CHAR(v_code) || '</p>');
            htp.p('<p>SQLERROR IS:'|| v_errm || '</p>');
            htp.p('<p>SQLERROR IS:'|| DBMS_UTILITY.FORMAT_ERROR_STACK || '</p>');
            
            htp.p('<p>' || 
             TO_CHAR(pidm_parm) || ',' ||
             from_term || ',' ||
             thru_term || ',' ||
             status_code || ',' ||
             approval_code || ',' ||
             group_num || ',' ||
             policy_num || ',' ||
             ins_name || ',' ||
             other_ins || ',' ||
             format_phone_cust || ',' ||
             last_name || ',' ||
             first_name || ',' ||
             birth_date || ',' ||
             gender || ',' ||
             relationshp || ',' ||
             zipcode
             || '</p>');

              gb_common.p_rollback;
end;


/*---------------------------------------------------------------------------*/
/* function to compute fingerprint string displayed on the confirmation page */
/* for insurance audit.  The fingerprint string consists the student's pidm,*/
/* year-month-day string and the last nine digits of the rowid.  The program */
/* re-queries the database using information just inserted into the table to */
/* retrieve the rowid.  If there is an error retreiving the record, this     */
/* function returns a fake rowid with the letters 'bad' in the final three   */
/* positions.                                                                */
/*---------------------------------------------------------------------------*/
function compute_key(pidm_parm   twrwaiv.twrwaiv_pidm%type,
                     from_term   twrwaiv.twrwaiv_from_term%type,
                     thru_term   twrwaiv.twrwaiv_thru_term%type,
                     group_num   twrwaiv.twrwaiv_group_num%type,
                     policy_num  twrwaiv.twrwaiv_policy_num%type,
                     ins_name    twrwaiv.twrwaiv_ins_name%type,
                     cust_phone  twrwaiv.twrwaiv_cust_phone%TYPE,
                     last_name   twrwaiv.twrwaiv_parent_last_name%type,
                     first_name  twrwaiv.twrwaiv_parent_first_name%type,
                     birth_date  twrwaiv.twrwaiv_parent_dob%type,
                     gender      twrwaiv.twrwaiv_parent_sex%type,
                     relationshp twrwaiv.twrwaiv_parent_relation%type)
                     
RETURN varchar2
is
    key_value  rowid;
    key_code varchar2(60);
    
begin

/* Retrieve rowid */
select rowid into key_value
from twrwaiv
where  pidm_parm = twrwaiv_pidm and                  
       from_term = twrwaiv_from_term and             
       thru_term = twrwaiv_thru_term AND
       twrwaiv_status_code = 'PN' and
       TRUNC(sysdate) = TRUNC(twrwaiv_entry_date) AND
       TRUNC(sysdate) = TRUNC(twrwaiv_activity_date); 
       
       /* build finger print string */
       key_code := to_char(pidm_parm) || to_char(sysdate,'YYYYMMDD') || substr(key_value, length(key_value)-9 ,length(key_value));
       key_code := rtrim(key_code);
       
       RETURN(key_code); 
       
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
              return('AAAA1234QQQbad');
end;    
 
/*************************************************/
/* Procedure to insert into purchase information */
/*                                               */
/*************************************************/
PROCEDURE insert_purchase(pidm_parm       TZRINCP.TZRINCP_PIDM%TYPE,
                          from_term       TZRINCP.TZRINCP_FROM_TERM%TYPE,
                          payment_type    TZRINCP.TZRINCP_PAYMENT_TYPE%TYPE,
                          payment_status  TZRINCP.TZRINCP_PAYMENT_STATUS%TYPE)
                       
is

--status_code    TZRINCP.TZRINCP_STATUS_CODE%TYPE;
/*  error processing variables  */
v_code NUMBER;
v_errm VARCHAR2(512);

begin

submit_flag := 'N';

INSERT INTO TZRINCP(TZRINCP_PIDM,
                    TZRINCP_FROM_TERM,                                      
                    TZRINCP_PAYMENT_TYPE,                                                                                                                
                    TZRINCP_PAYMENT_STATUS, 
                    TZRINCP_ACTIVITY_DATE,                                                                                                               
                    TZRINCP_USER)                                                                                                                  
      values(pidm_parm,
            from_term,
						payment_type,
						payment_status,
            sysdate,
            USER);

             gb_common.p_commit;
             submit_flag := 'Y';
             
         EXCEPTION
            WHEN OTHERS THEN
            v_code := SQLCODE;
            v_errm := SUBSTR(SQLERRM, 1, 80);
            
            htp.p('<p>Error while inserting purchase record</p>');
            htp.p('<p>SQLERROR IS:' || TO_CHAR(v_code) || '</p>');
            htp.p('<p>SQLERROR IS:'|| v_errm || '</p>');
            htp.p('<p>SQLERROR IS:'|| DBMS_UTILITY.FORMAT_ERROR_STACK || '</p>');
            
            htp.p('<p>' || 
             TO_CHAR(pidm_parm) || ',' ||
             from_term    || ',' ||
             payment_type || ',' ||
             payment_status || '</p>');

             gb_common.p_rollback;
end insert_purchase;
 

/** Display summary of information entered in by student **/
procedure P_InsOutsideDisplay(TermCode in varchar2,
                             group_num in varchar2,
                             policy_num in varchar2,
                             cust_phone in varchar2,
                             insur_comp in varchar2,
                             dependent_flag in varchar2,
                             first_name IN varchar2,
                             last_name IN varchar2,
                             month_temp in varchar2,
                             day_temp in varchar2,
                             year_temp in varchar2,
                             relationshp IN varchar2,
                             gender IN varchar2,
                             alternate_insur in varchar2,
                             checkit OWA_UTIL.ident_arr,
                             zipcode IN varchar2)
is
      pidm_asign        NUMBER;
      teststring        VARCHAR2(20);
      msg_text_out      VARCHAR2(200);
      missing_error     BOOLEAN := FALSE;
      format_error      BOOLEAN := FALSE;
      already_submitted BOOLEAN := FALSE;

      /* variables for Banner Database update */
      pidm_parm_in     twrwaiv.twrwaiv_pidm%type;
      TermCode_in      twrwaiv.twrwaiv_from_term%type;
      group_num_in     twrwaiv.twrwaiv_group_num%type;
      policy_num_in    twrwaiv.twrwaiv_policy_num%type;
      cust_phone_in    varchar2(30);
      insur_comp_in    twrwaiv.twrwaiv_ins_name%type;
      last_name_in     twrwaiv.twrwaiv_parent_last_name%type;
      first_name_in    twrwaiv.twrwaiv_parent_first_name%type;
      birth_date_in    twrwaiv.twrwaiv_parent_dob%type;
      gender_in        twrwaiv.twrwaiv_parent_sex%type;
      relationshp_in   twrwaiv.twrwaiv_parent_relation%type;
      zipcode_in       twrwaiv.twrwaiv_student_zip%type;
            
      dependent_flag_in     varchar2(3);
--      annual_flag_in        varchar2(3);
--      occurrence_flag_in    varchar2(3);
--      maxximmum_flag_in     varchar2(3);
--      mental_flag           varchar2(3);
      alternate_insur_in    varchar2(50);
/*      
      ass_insur_Id_in       varchar2(30);
      hlth_cover_phone_in   varchar2(15);   
*/          
      stnd_insur   BOOLEAN := FALSE;
      other_insur  BOOLEAN := FALSE;
      alter_flag   BOOLEAN := FALSE;
      
      birth_date varchar2(10);
      
begin
  
     birth_date := month_temp||day_temp||year_temp; 
      
     if not twbkwbis.F_ValidUser(global_pidm) then
        return;
     end if;
  
    twbkwbis.p_opendoc('bwmsinwb.P_InsOutside');
    twbkwbis.p_dispinfo('bwmsinwb.P_InsOutside',  'DEFAULT');
        
     /*------------------------------------------------------*/
     /* Check for insurance                                  */
     /*------------------------------------------------------*/

     if(group_num is NOT NULL OR policy_num is NOT NULL OR
         cust_phone is NOT NULL OR insur_comp is NOT NULL  OR
        first_name is NOT NULL OR last_name is NOT NULL OR
        --birth_date is NOT NULL OR 
        month_temp is NOT NULL OR day_temp is NOT NULL OR
        year_temp is NOT NULL OR gender is NOT NULL OR
        relationshp is NOT NULL) then
             stnd_insur := TRUE;  
     end if; 
     
     if alternate_insur is NOT NULL then
        other_insur := TRUE;
        stnd_insur := FALSE;
     end if;        
     
     if insur_comp <> 'Other' and alternate_insur is NOT NULL then
        alter_flag := TRUE;
     end if;    
     
      /*----------------------------------------------------*/      
      /* Check for missing information.  Students may still */
      /* have missing information.  Validate phone number.  */
      /*----------------------------------------------------*/
      
      /* check for missing information */
      if (stnd_insur AND (group_num is NULL OR policy_num is NULL OR
          cust_phone is NULL OR insur_comp is NULL OR
          first_name is NULL OR last_name is NULL OR month_temp is NULL OR
          day_temp is NULL OR year_temp is NULL OR --birth_date is NULL OR
          gender is NULL OR relationshp is NULL)) then
             missing_error := TRUE;  
      end if;
      
      if (other_insur AND (group_num is NULL OR policy_num is NULL OR
          cust_phone is NULL OR alternate_insur is NULL OR
          first_name is NULL OR last_name is NULL OR month_temp is NULL OR
          day_temp is NULL OR year_temp is NULL OR --birth_date is NULL OR
          gender is NULL OR relationshp is NULL)) then
             missing_error := TRUE;  
      end if;

      /* Check for missing checkbox for both sections of insurance */
      if( checkit.count <> 2) then
          missing_error := TRUE;
      end if;


      /*------------------------------*/      
      /* Validate phone number format */
      /*------------------------------*/
      
      /* check for erroneous phone number */
      if (stnd_insur AND has_phone_number_chars(filter_phone_number(cust_phone)) = 'N') then
          format_error := TRUE;
      end if;
      
      if (other_insur AND has_phone_number_chars(filter_phone_number(cust_phone)) = 'N') then
          format_error := TRUE;
      end if;
      
      /* check if audit has already been submitted, include this section */
-- JDH for test
--      if  has_waiver(global_pidm, TermCode ) then
--           already_submitted := TRUE;
--      end if;
      
      /*-----------------------------------------------------------------------------*/
      /* Building Missing, incomplete or bad format insurance information text field */
      /*-----------------------------------------------------------------------------*/
      
      if already_submitted then
          msg_text_out := G$_NLS.Get('BWMINS1-0007','SQL','audit has been Submitted');
          twbkfrmt.P_PrintMessage(msg_text_out,'ERROR');      
      elsif (NOT other_insur AND NOT stnd_insur) then
             msg_text_out := G$_NLS.Get('BWMINS1-0002','SQL','No Insurance Information has been Entered! <b>Please enter Insurance Information<b>');
             twbkfrmt.P_PrintMessage(msg_text_out,'ERROR');
      elsif (alter_flag AND NOT stnd_insur) then
             msg_text_out := G$_NLS.Get('BWMINS1-0002','SQL','You have Entered Insurance Company Names for both Insurance Company Name fields! <b>Please Select from Drop Down List OR Specify Other Insurance Company Name<b>');
             twbkfrmt.P_PrintMessage(msg_text_out,'ERROR');
      elsif missing_error then
          msg_text_out := G$_NLS.Get('BWMINS1-0001','SQL','Not all Required Information has been Entered');
          twbkfrmt.P_PrintMessage(msg_text_out,'ERROR');
      elsif format_error then
          msg_text_out := G$_NLS.Get('BWMINS1-0008','SQL','Not all Required Information has been Entered in Correctly');
          twbkfrmt.P_PrintMessage(msg_text_out,'ERROR');
      else            
          HTP.formopen('bwmsinwb.P_InsOutsideConfirm', 'post');
      end if;
      
      /*---------------------------------------------------*/
      /* Display title information for student             */
      /*---------------------------------------------------*/
      if (missing_error OR format_error) then
           twbkfrmt.P_TableOpen('DATADISPLAY', ccaption=> 'Insurance audit Information(Use Back Button to complete audit Form)',CATTRIBUTES=>'width=70%');
      elsif already_submitted then 
           twbkfrmt.P_TableOpen('DATADISPLAY', ccaption=> 'Submitted Insurance Audit Information(Use Back Button to return to audit Form)',CATTRIBUTES=>'width=70%');      
      else
           twbkfrmt.P_TableOpen('DATADISPLAY', ccaption=> 'Insurance Audit Information 
           (Must click SUBMIT Button below after confirming that your insurance information
           was correctly entered).',CATTRIBUTES=>'width=70%');

      end if;

--           (Click Submit Button to Finish)',CATTRIBUTES=>'width=70%');
 /*---------------------------------------------*/
 /* Insurance have been entered in by the user  */ 
 /* Show data and force user to correct problem */
 /*---------------------------------------------*/
if (other_insur OR stnd_insur) then
       
   /* process insurance information */
   if (stnd_insur) then 
      twbkfrmt.p_tablerowopen;
      twbkfrmt.p_tableheader('Insurance Section');
      twbkfrmt.p_tableheader('Input Information');
      twbkfrmt.p_tablerowclose;
      
      twbkfrmt.P_TableRowOpen;
      twbkfrmt.P_TableDataLabel('Group Number');
      twbkfrmt.P_TableData(NVL(group_num, '<font color="#FF0000">** Missing **</font>'));
      twbkfrmt.P_TableRowClose;
      
      twbkfrmt.P_TableRowOpen;
      twbkfrmt.P_TableDataLabel('Insurance ID Number');
      twbkfrmt.P_TableData(NVL(policy_num, '<font color="#FF0000">** Missing **</font>'));
      twbkfrmt.P_TableRowClose;
      
      if (has_phone_number_chars(filter_phone_number(cust_phone)) = 'N') then
           twbkfrmt.P_TableRowOpen;
           twbkfrmt.P_TableDataLabel('Health Coverage Verification Phone Number');
           twbkfrmt.P_TableData('<font color="#FF0000">* Requires 10 Digits [0-9] *</font>');
           twbkfrmt.P_TableRowClose;
      else 
           twbkfrmt.P_TableRowOpen;
           twbkfrmt.P_TableDataLabel('Health Coverage Verification Phone Number');
           twbkfrmt.P_TableData(NVL(cust_phone, '<font color="#FF0000">** Missing **</font>'));
           twbkfrmt.P_TableRowClose;
      end if;
      
      twbkfrmt.P_TableRowOpen;
      twbkfrmt.P_TableDataLabel('Insurance Company ');
      twbkfrmt.P_TableData(NVL(insur_comp, '<font color="#FF0000">** Missing **</font>'));
      twbkfrmt.P_TableRowClose;
      
      twbkfrmt.P_TableRowOpen;
      twbkfrmt.P_TableDataLabel('Subscriber Last Name');
      twbkfrmt.P_TableData(NVL(last_name,'<font color="#FF0000">** Missing **</font>'));
      twbkfrmt.P_TableRowClose;

      twbkfrmt.P_TableRowOpen;
      twbkfrmt.P_TableDataLabel('Subscriber First Name');
      twbkfrmt.P_TableData(NVL(first_name,'<font color="#FF0000">** Missing **</font>'));
      twbkfrmt.P_TableRowClose;

      /*
      twbkfrmt.P_TableRowOpen;
      twbkfrmt.P_TableDataLabel('Subscriber Birth Date');
      twbkfrmt.P_TableData(NVL(birth_date,'<font color="#FF0000">** Missing **</font>'));
      twbkfrmt.P_TableRowClose;
      */
      twbkfrmt.P_TableRowOpen;
      twbkfrmt.P_TableDataLabel('Subscriber Birth Month');
      twbkfrmt.P_TableData(NVL(month_temp,'<font color="#FF0000">** Missing **</font>'));
      twbkfrmt.P_TableRowClose;
      
      twbkfrmt.P_TableRowOpen;
      twbkfrmt.P_TableDataLabel('Subscriber Birth Day');
      twbkfrmt.P_TableData(NVL(day_temp,'<font color="#FF0000">** Missing **</font>'));
      twbkfrmt.P_TableRowClose;
      
      twbkfrmt.P_TableRowOpen;
      twbkfrmt.P_TableDataLabel('Subscriber Birth Year');
      twbkfrmt.P_TableData(NVL(year_temp,'<font color="#FF0000">** Missing **</font>'));
      twbkfrmt.P_TableRowClose;      
      
      twbkfrmt.P_TableRowOpen;
      twbkfrmt.P_TableDataLabel('Subscriber Gender');
      twbkfrmt.P_TableData(NVL(gender,'<font color="#FF0000">** Missing **</font>'));
      twbkfrmt.P_TableRowClose;

      twbkfrmt.P_TableRowOpen;
      twbkfrmt.P_TableDataLabel('Subscriber Relationship');
      twbkfrmt.P_TableData(NVL(relationshp,'<font color="#FF0000">** Missing **</font>'));
      twbkfrmt.P_TableRowClose;
          
   end if;

   if (other_insur) then 
      twbkfrmt.p_tablerowopen;
      twbkfrmt.p_tableheader('Insurance Section');
      twbkfrmt.p_tableheader('Input Information');
      twbkfrmt.p_tablerowclose;
      
      twbkfrmt.P_TableRowOpen;
      twbkfrmt.P_TableDataLabel('Group Number');
      twbkfrmt.P_TableData(NVL(group_num, '<font color="#FF0000">** Missing **</font>'));
      twbkfrmt.P_TableRowClose;
      
      twbkfrmt.P_TableRowOpen;
      twbkfrmt.P_TableDataLabel('Insurance ID Number');
      twbkfrmt.P_TableData(NVL(policy_num, '<font color="#FF0000">** Missing **</font>'));
      twbkfrmt.P_TableRowClose;
      
      if (has_phone_number_chars(filter_phone_number(cust_phone)) = 'N') then
           twbkfrmt.P_TableRowOpen;
           twbkfrmt.P_TableDataLabel('Health Coverage Verification Phone Number');
           twbkfrmt.P_TableData('<font color="#FF0000">* Requires 10 Digits [0-9] *</font>');
           twbkfrmt.P_TableRowClose;
      else 
           twbkfrmt.P_TableRowOpen;
           twbkfrmt.P_TableDataLabel('Health Coverage Verification Phone Number');
           twbkfrmt.P_TableData(NVL(cust_phone, '<font color="#FF0000">** Missing **</font>'));
           twbkfrmt.P_TableRowClose;
      end if;
      
      twbkfrmt.P_TableRowOpen;
      twbkfrmt.P_TableDataLabel('Insurance Company ');
      twbkfrmt.P_TableData(NVL(alternate_insur, '<font color="#FF0000">** Missing **</font>'));
      twbkfrmt.P_TableRowClose;
      
      twbkfrmt.P_TableRowOpen;
      twbkfrmt.P_TableDataLabel('Subscriber Last Name');
      twbkfrmt.P_TableData(NVL(last_name,'<font color="#FF0000">** Missing **</font>'));
      twbkfrmt.P_TableRowClose;

      twbkfrmt.P_TableRowOpen;
      twbkfrmt.P_TableDataLabel('Subscriber First Name');
      twbkfrmt.P_TableData(NVL(first_name,'<font color="#FF0000">** Missing **</font>'));
      twbkfrmt.P_TableRowClose;

      twbkfrmt.P_TableRowOpen;
      twbkfrmt.P_TableDataLabel('Subscriber Birth Date');
      twbkfrmt.P_TableData(NVL(birth_date,'<font color="#FF0000">** Missing **</font>'));
      twbkfrmt.P_TableRowClose;

      twbkfrmt.P_TableRowOpen;
      twbkfrmt.P_TableDataLabel('Subscriber Gender');
      twbkfrmt.P_TableData(NVL(gender,'<font color="#FF0000">** Missing **</font>'));
      twbkfrmt.P_TableRowClose;

      twbkfrmt.P_TableRowOpen;
      twbkfrmt.P_TableDataLabel('Subscriber Relationship');
      twbkfrmt.P_TableData(NVL(relationshp,'<font color="#FF0000">** Missing **</font>'));
      twbkfrmt.P_TableRowClose;

    end if;
      
    /* validate checkbox for both sections */
    if checkit.count <> 2 then
          twbkfrmt.P_TableRowOpen;
          twbkfrmt.P_TableDataLabel('Acknowledge Checkbox');
          twbkfrmt.P_TableData('<font color="#FF0000">** Unchecked **</font>');
          twbkfrmt.P_TableRowClose;
    else
          twbkfrmt.P_TableRowOpen;
          twbkfrmt.P_TableDataLabel('Acknowledge Checkbox');
          twbkfrmt.P_TableData('Checked');
          twbkfrmt.P_TableRowClose;
    end if;
      
elsif (NOT other_insur AND NOT stnd_insur) then
   NULL;
end if;

twbkfrmt.P_Tableclose;

/* Set up data for Banner database update */
TermCode_in    := TermCode;
group_num_in   := group_num;
policy_num_in  := policy_num;
cust_phone_in  := cust_phone;
first_name_in  := first_name;
last_name_in   := last_name;
birth_date_in  := month_temp||'/'||day_temp||'/'||year_temp; 
gender_in      := gender;
relationshp_in := relationshp;
zipcode_in     := zipcode;


if alternate_insur is NOT NULL then
   insur_comp_in := alternate_insur;
end if;

if insur_comp <> 'Other' then
   insur_comp_in := insur_comp;
end if;

alternate_insur_in := alternate_insur;

/*
hlth_cover_phone_in := hlth_cover_phone;
ass_insur_Id_in := ass_insur_Id;
*/

--   annual_flag_in          := annual_flag;
--   occurrence_flag_in      := occurrence_flag;
--   maxximmum_flag_in       := maxximmum_flag;
--   mental_flag             := mental_flag;
   

htp.formhidden('TermCode_in',TermCode_in);
htp.formhidden('group_num_in',group_num_in);
htp.formhidden('policy_num_in',policy_num_in);
htp.formhidden('cust_phone_in',cust_phone_in);
htp.formhidden('insur_comp_in',insur_comp_in);
htp.formhidden('first_name_in',first_name_in);
htp.formhidden('last_name_in',last_name_in);
htp.formhidden('birth_date_in',birth_date_in);
htp.formhidden('gender_in',gender_in);
htp.formhidden('relationshp_in',relationshp_in);

htp.formhidden('alternate_insur_in',alternate_insur_in);
htp.formhidden('zipcode_in',zipcode_in);
/*
htp.formhidden('hlth_cover_phone_in',hlth_cover_phone_in);
htp.formhidden('ass_insur_Id_in',ass_insur_Id_in);
*/

--htp.formhidden('annual_flag_in',annual_flag_in);
--htp.formhidden('occurrence_flag_in',occurrence_flag_in);
--htp.formhidden('maxximmum_flag_in',maxximmum_flag_in);
--htp.formhidden('mental_flag_in',mental_flag_in);


/*--------------------------------------------------*/
/* Show submit button only if all fields have been  */
/* properly entered.                                */
/*--------------------------------------------------*/

if already_submitted = FALSE AND missing_error = FALSE AND  format_error = FALSE AND 
   NOT(other_insur AND stnd_insur) AND (other_insur OR stnd_insur) AND ( insur_comp = 'Medicaid') then
 htp.p('<p><u><b><font size="-1">Attention! Students who are insured with Medicaid</u></b> will be required to obtain a letter 
                  of eligibility directly from Medicaid. Students should bring this letter to the Student 
                  Insurance Office (Plaza Building 149) prior to the insurance audit deadline. Without 
                  an official letter of eligibility from Medicaid on file by the deadline your 
                  audit cannot be approved.<font size="+1"><p>');
end if;
                       
if already_submitted = FALSE AND missing_error = FALSE AND  format_error = FALSE AND NOT(other_insur AND stnd_insur) AND (other_insur OR stnd_insur) then
      htp.p('<p><b><font color="#0000FF" size = -1 >IMPORTANT!</b> To ensure 
  that your audit form was successfully transmitted there are two essential verification 
  checks that the College has implemented. It is <strong>your responsibility to 
  confirm that each of these verifications has occurred in order to assure that 
  your audit form was successfully transmitted.</strong> 
<ol>
  <li type = a> After you click the submit button at the 
    end of the on-line audit form you should then see a screen that shows your 
    900# and says, &ldquo;YOU HAVE CONFIRMED YOUR ENTRY&rdquo;. If you do not see this screen, 
    then your audit was NOT successfully transmitted. In this case, contact the 
    Student Health Insurance Office at 303-556-2525. </li>
  <li type =a>After you submit your on-line audit form 
    you will receive a confirmation e-mail sent to your Metro Connect e-mail account. 
    This confirmation confirms delivery of your audit request to the College.<strong> 
    It does not confirm that your audit has been approved, since the verification 
    process has not yet been completed.</strong> Keep a copy of your delivery 
    confirmation for you records. If you do not receive this e-mail in 24 hours 
    after submitting your audit form, then your audit was NOT successfully transmitted. 
    In this case, contact the Student Health Insurance Office at 303-556-2525.</font></li>
</ol></P> ');

--    htp.formsubmit(null,'Submit');
    htp.formsubmit(NULL,'Submit','style="color:#FFF;background:#9C0;font-size:24px"');
      already_submitted := TRUE;

end if; 

htp.formclose; 
twbkwbis.P_CloseDoc(curr_release);
end P_InsOutsideDisplay;


/********************************************************************************/
/* Procedure to accept student's submission of insurance audit information and */
/* update the Banner database.                                                  */
/********************************************************************************/


procedure P_InsOutsideConfirm(TermCode_in in varchar2,         
                             group_num_in in varchar2,        
                             policy_num_in varchar2,          
                             cust_phone_in varchar2,          
                             insur_comp_in varchar2,          
                             last_name_in varchar2,
                             first_name_in varchar2,
                             birth_date_in varchar2,
                             relationshp_in varchar2,
                             gender_in varchar2, 
                             alternate_insur_in varchar2,
                             zipcode_in varchar2) 
is    

  pidm_value NUMBER;
  start_term VARCHAR2(6);
  end_term VARCHAR2(6);
  ID         varchar2(11);
  submittime varchar2(20);
  confirm_text varchar2(200);
  total_text varchar2(4000);
  
  key_value varchar2(40);
  
begin

if not twbkwbis.F_ValidUser(global_pidm) then
   return;
 end if;
 
  twbkwbis.p_opendoc('bwmsinwb.P_InsOutsideConfirm');
  twbkwbis.p_dispinfo('bwmsinwb.P_InsOutsideConfirm',  'DEFAULT');
 

  pidm_value := global_pidm;
  

/* Compute current term specified */
end_term := endterm(TermCode_in);
 
  /*-------------------------------------*/   
  /* Create waiver record and send email */
  /*-------------------------------------*/
  if NOT has_waiver(global_pidm, TermCode_in ) then
      
       /*----------------------------------*/ 
       /* Create waiver record for student */
       /*----------------------------------*/
       insert_waivier(pidm_value,
                      TermCode_in,
                      end_term,
                      group_num_in,
                      policy_num_in,
                      insur_comp_in,
                      cust_phone_in,
                      first_name_in,
                      last_name_in,
                      birth_date_in,
                      relationshp_in,
                      gender_in,
                      alternate_insur_in,
                      zipcode_in
                     );
                      
        /*-------------------------*/
        /* Send Confirmation email */
        /*-------------------------*/ 
--  JDH disabled        if submit_flag = 'Y' then
--        SendEmail(pidm_value, TermCode_in);
--        end if;
        
 end if;
 
/* Commit all information to the database */ 
gb_common.p_commit;

/*-------------------------------------------------*/
/* Compute fingerprint string for confirmaion page */
/*-------------------------------------------------*/
key_value := compute_key(pidm_value,
                TermCode_in,
                end_term,
                group_num_in,
                policy_num_in,
                insur_comp_in,
                cust_phone_in,
                first_name_in,
                last_name_in,
                birth_date_in,
                relationshp_in,
                gender_in
                );
                
  
  /*--------------------------------*/             
  /* Build confirmation page        */
  /*--------------------------------*/            
  ID := substr(tzkar04.f_m_get_id(pidm_value),1,11);
  submittime := to_char(sysdate,'DD-Mon-YYYY HH:MI');
  
  confirm_text := '';
  confirm_text := confirm_text || '<b>YOU HAVE CONFIRMED YOUR ENTRY &nbsp&nbsp</b>';
  confirm_text := confirm_text ||'<b>Date:</b> ' || submittime || '&nbsp&nbsp&nbsp&nbsp';
  confirm_text := confirm_text || '<b>ID:</b> ' || ID || '&nbsp';
  confirm_text := '<p>' || confirm_text || '</p>';
  
  total_text := confirm_text;
  
  total_text := total_text || '<font size="-1"><p>Your outside insurance has been submitted for auditing! Please print this page and save for 
                              future reference as your proof of audit submission';
                
 total_text := total_text || '<p><b><font color="#0000FF" size = -1 >IMPORTANT!</b> To ensure 
                              that your audit form was successfully transmitted there is a verification 
                              check that the College has implemented. It is <strong>your responsibility to 
                              confirm that this verification has occurred in order to assure that 
                              your audit form was successfully transmitted.</strong></p> 
                              <p>After you submit your on-line audit form 
                                  you will receive a confirmation e-mail sent to your Metro Connect e-mail account. 
                                  This confirmation confirms delivery of your audit request to the College.<strong> 
                                  It does not confirm that your audit has been approved, since the verification 
                                  process has not yet been completed.</strong> Keep a copy of your delivery 
                                  confirmation for you records. If you do not receive this e-mail in 24 hours 
                                  after submitting your audit form, then your audit was NOT successfully transmitted. 
                                  In this case, contact the Student Health Insurance Office at 303-556-2525.
                              </P></font>';
   htp.p(total_text);  
                                                                  
total_text := '<p><font size="-1"> If you need to make corrections or changes to the insurance information you 
                                 submitted electronically, you should call ECI at <strong>1-866-780-3824</strong>.
                                 Your changes will be manually entered by ECI.<font size="+1">';
  
    htp.p(total_text);
  
  
  /* Display fingerprint string */
  htp.p('<p><font size="-2">');
  htp.p(key_value);
  htp.p('<p><font size="+2">');

  twbkwbis.p_closedoc (curr_release);
end P_InsOutsideConfirm;

-------------------------------------------- part6

--------------------------------------- part8
procedure P_InsOutside(term_in IN stvterm.stvterm_code%TYPE,
                            buy   in varchar2 DEFAULT NULL,
                            waive in varchar2 DEFAULT NULL,
                                group_num in varchar2,
                                policy_num in varchar2,
                                cust_phone in varchar2,
                                insur_comp in varchar2,
                                dependent_flag in varchar2,
                                first_name IN varchar2,
                                last_name IN varchar2,
                                month_temp in varchar2,
                                day_temp in varchar2,
                                year_temp in varchar2,                                
                                relationshp IN varchar2,
                                gender IN varchar2,
                                alternate_insur IN varchar2,
                                checkit OWA_UTIL.ident_arr,
                                zipcode IN varchar2   )
 is

	msg_text_out    VARCHAR2(200);
--	term            stvterm.stvterm_code%TYPE;
	eci_prod_url VARCHAR2 (256) :=                                      
	       'http://www.eciservices.com';        
  checkbox OWA_UTIL.ident_arr;
  
begin
	
    if not twbkwbis.F_ValidUser(global_pidm) then
        return;
    end if;

htp.p('start proc');
htp.p('buy:' || buy);
htp.p('audit:' || waive);
htp.p('term:' || term_in);

if (buy = 'Y') then
		insert_purchase(global_pidm,
		term_in,
		'P',
		'D');
		/*----------------------------------*/ 
/* Create purchase record for student */
/*----------------------------------*/
/*  insert_purchase(pidm_value,
                  TermCode_in,
                  end_term,
                  payment_type,
                  payment_status);
*/
-- This will do the real redirect but not for testing
	  htp.init;
		owa_util.redirect_url(eci_prod_url);
-- 	  HTP.formopen (eci_prod_url, 'post');
--    HTP.formsubmit (NULL, 'Submit');
--    HTP.formclose;
		return;
end if;

if waive = 'Y' then
	checkbox(1) := 'z';
	checkbox(2) := 'z';
end if;

P_InsOutsideDisplay(Term_in,
                  group_num,
									policy_num,
      				    cust_phone,
    						  insur_comp,
   			         	dependent_flag,
  					      first_name,
        					last_name,
       		  	    month_temp,
        			  	day_temp,
            		 	year_temp,
            			relationshp,
              		gender,
             			alternate_insur,
              		checkbox,
              		zipcode);
    
 
/* ************* */

--htp.formhidden('TERMCODE',term_in);


/* display submit button */
       
end P_InsOutside;

 
procedure P_InsCompl(term_in IN stvterm.stvterm_code%TYPE DEFAULT NULL)
is

	dependent_flag  varchar2(3);
--	annual_flag     varchar2(3);
--  occurrence_flag varchar2(3);
--	maxximmum_flag  varchar2(3);
--	mental_flag     varchar2(3);
	checkit         OWA_UTIL.ident_arr;
	msg_text_out    VARCHAR2(200);
--	term            stvterm.stvterm_code%TYPE;
  alternate_insur varchar2(50);
  insur_comp      varchar2(50);
  zipcode         varchar2(5);
  form_state      varchar2(1);
begin
	
    if not twbkwbis.F_ValidUser(global_pidm) then
        return;
    end if;

--
-- Check for term.
-- =====================================================
      IF term_in IS NOT NULL
      THEN
         twbkwbis.P_SetParam (global_pidm, 'TERM', term_in);
         term := term_in;
      ELSE
         term := twbkwbis.F_GetParam (global_pidm, 'TERM');
      END IF;

-- Get a term.
-- =====================================================
      IF NOT bwskflib.F_ValidTerm (term, stvterm_rec, sorrtrm_rec)
      THEN
         bwskflib.P_SelDefTerm (term, 'bwmsinwb.P_InsCompl');
         RETURN;
      END IF;      
           
    /*------------------------------------------*/   
    /* Process any flags that disable this form */
    /*------------------------------------------*/
         
  twbkwbis.p_opendoc ('bwmsinwb.P_InsCompl','Insurance Compliance');
  twbkwbis.p_dispinfo ('bwmsinwb.P_InsCompl',  'DEFAULT');
   
/* Check for the form status and insurance status  */

	form_state := F_ScreenValidate(term);   
	htp.p('<br />Form state is ' || form_state);
  if form_state != 'A' 
  THEN
	  twbkwbis.p_closedoc (curr_release);
		RETURN;
  END IF;    /*  if form failed status so don't display */ 

	HTP.formopen('bwmsinwb.P_InsComplDisplay', 'post');

	htp.formhidden('term_in',term);

  /*----------------------------------------------------------*/ 
  /* Retreive and process the student's personnel information */
  /*----------------------------------------------------------*/
  get_name(global_pidm, disp_last_name, disp_first_name ,disp_middle_init, disp_student_id);
--  get_bio(global_pidm, disp_ssn, disp_birth);
  get_bio(global_pidm, disp_birth);
  get_email(global_pidm,disp_email);
  get_prim_phone(global_pidm,disp_prim_phone);
  get_address(global_pidm,disp_street_line1, disp_street_line2, disp_street_line3, disp_city, disp_stat_code, disp_zip);
  
	zipcode := substr(disp_zip, 1, 5);  
--	htp.formhidden('ZIPCODE',zipcode);
  
  /* Format string address by omitting zero length entries and */
  /* trimming trailing spaces.                                 */
  if (length(disp_street_line2) > 0 AND length(disp_street_line3) > 0 )then
        whole_street := rtrim(disp_street_line1) || '<br>' || rtrim(disp_street_line2)  || '<br>' || rtrim(disp_street_line3);
  elsif length(disp_street_line2) > 0 then 
        whole_street := rtrim(disp_street_line1) || '<br>' || rtrim(disp_street_line2);
  elsif length(disp_street_line3) > 0 then
        whole_street := rtrim(disp_street_line1) || '<br>' || rtrim(disp_street_line3);
  else
        whole_street := rtrim(disp_street_line1);
  end if;
  
  whole_city_state := disp_city || ', ' || disp_stat_code || ' ' || disp_zip;

/* display the form up to the hippa disclosure  */
	P_ShowIntro;
	P_ShowPart1;
	P_ShowPart2;
	P_ShowPart3;
	P_ShowStep1;
	P_ShowStep2(zipcode);

END P_InsCompl;

/** Display summary of information entered in by student **/
procedure P_InsComplDisplay(term_in IN stvterm.stvterm_code%TYPE,
                            zipcode IN varchar2,
                            checkit IN OWA_UTIL.ident_arr)

--TermCode in varchar2,
--procedure P_InsComplDisplay(TermCode in varchar2,
--                             group_num in varchar2,
--                             policy_num in varchar2,
--                             cust_phone in varchar2,
--                             insur_comp in varchar2,
--                             dependent_flag in varchar2,
--                             first_name IN varchar2,
--                             last_name IN varchar2,
--                             --birth_date IN varchar2,
--                             month_temp in varchar2,
--                             day_temp in varchar2,
--                             year_temp in varchar2,
--                             relationshp IN varchar2,
--                             gender IN varchar2,
--                             alternate_insur in varchar2,
--                             checkit OWA_UTIL.ident_arr,
--                             zipcode IN varchar2)
is
      pidm_asign        NUMBER;
      teststring        VARCHAR2(20);
      msg_text_out      VARCHAR2(200);
      missing_error     BOOLEAN := FALSE;
      format_error      BOOLEAN := FALSE;
      already_submitted BOOLEAN := FALSE;

      /* variables for Banner Database update */
      pidm_parm_in     twrwaiv.twrwaiv_pidm%type;
      TermCode_in      twrwaiv.twrwaiv_from_term%type;
      group_num_in     twrwaiv.twrwaiv_group_num%type;
      policy_num_in    twrwaiv.twrwaiv_policy_num%type;
      cust_phone_in    varchar2(30);
      insur_comp_in    twrwaiv.twrwaiv_ins_name%type;
      last_name_in     twrwaiv.twrwaiv_parent_last_name%type;
      first_name_in    twrwaiv.twrwaiv_parent_first_name%type;
      birth_date_in    twrwaiv.twrwaiv_parent_dob%type;
      gender_in        twrwaiv.twrwaiv_parent_sex%type;
      relationshp_in   twrwaiv.twrwaiv_parent_relation%type;
      zipcode_in       twrwaiv.twrwaiv_student_zip%type;
            
      dependent_flag_in     varchar2(3);
      alternate_insur_in    varchar2(50);
      stnd_insur   BOOLEAN := FALSE;
      other_insur  BOOLEAN := FALSE;
      alter_flag   BOOLEAN := FALSE;
      
      birth_date varchar2(10);

--			' alert ("check is " + chk.checked); ' ||

			scriptText        VARCHAR2(2000) :=
			' function goToECI(chk) { '  ||
			'  if (chk.checked)  ' ||
			' { window.open(''http://www.eciservices.com''); } ' ||
			' else ' ||
			' { alert ("The checkbox is not checked"); } ' ||
			'	} ';

--			' window.open(''http://www.eciservices.com''); ' ||
      
begin
  
--     birth_date := month_temp||day_temp||year_temp; 
      
     if not twbkwbis.F_ValidUser(global_pidm) then
        return;
     end if;
  
		twbkwbis.p_opendoc('bwmsinwb.P_InsComplDisplay','Insurance Compliance');
    twbkwbis.p_dispinfo('bwmsinwb.P_InsComplDisplay',  'DEFAULT');

		HTP.SCRIPT(scriptText, 'Javascript');

--		htp.p('<p>Checkit is ' || checkit.count || '</p>');
/* Check for missing checkbox for both sections of insurance */
     if( checkit.count <> 2) then
          missing_error := TRUE;
     end if;

if (missing_error) then	      
      /*---------------------------------------------------*/
      /* Display title information for student             */
      /*---------------------------------------------------*/
      if (missing_error OR format_error) then
           twbkfrmt.P_TableOpen('DATADISPLAY', ccaption=> 'HIPPA Information has not been Accepted (Use Back Button and check box to Accept Form)',CATTRIBUTES=>'width=70%');
      elsif already_submitted then 
           twbkfrmt.P_TableOpen('DATADISPLAY', ccaption=> 'Submitted Insurance Audit Information(Use Back Button to return to audit Form)',CATTRIBUTES=>'width=70%');      
      else
           twbkfrmt.P_TableOpen('DATADISPLAY', ccaption=> 'Insurance Audit Information (
           Must click SUBMIT Button below after confirming that your insurance information
           was correctly entered).',CATTRIBUTES=>'width=70%');
      end if;

      msg_text_out := G$_NLS.Get('BWMINS1-0001','SQL','Not all Required Information has been Entered');
      
--      twbkfrmt.P_TableRowOpen;
--      twbkfrmt.P_TableData(msg_text_out);
--      twbkfrmt.P_TableRowClose;
--      twbkfrmt.P_TableClose;

      twbkfrmt.P_PrintMessage(msg_text_out,'ERROR');

--      twbkwbis.P_CloseDoc(curr_release);
	else
		P_ShowStep3(term_in, zipcode, checkit);
		
	end if;
	 
twbkwbis.P_CloseDoc(curr_release);

END P_InsComplDisplay;

/********************************************************************************/
/* Procedure to accept student's submission of insurance audit information and */
/* update the Banner database.                                                  */
/********************************************************************************/
PROCEDURE P_InsComplConfirm(TermCode_in in varchar2,         
                             group_num_in in varchar2,        
                             policy_num_in varchar2,          
                             cust_phone_in varchar2,          
                             insur_comp_in varchar2,          
                             last_name_in varchar2,
                             first_name_in varchar2,
                             birth_date_in varchar2,
                             relationshp_in varchar2,
                             gender_in varchar2, 
                             alternate_insur_in varchar2,
                             zipcode_in varchar2) 
IS    

  pidm_value NUMBER;
  start_term VARCHAR2(6);
  end_term VARCHAR2(6);
  ID         varchar2(11);
  submittime varchar2(20);
  confirm_text varchar2(200);
  total_text varchar2(4000);
  
  key_value varchar2(40);
  
BEGIN

if not twbkwbis.F_ValidUser(global_pidm) then
   return;
 end if;
 
END P_InsComplConfirm;


end bwmsinwb;
/
spool off

show errors
set scan on
exit;
