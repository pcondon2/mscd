CONNECT baninst1/&&baninst1_password;
SET SCAN OFF
-- BWCKCAP1.SQL - Package to Display (D)isplay (C)ompliance output.
--
-- AUDIT TRAIL : 5.3                              INIT    DATE
-- Initial Release of Package                     LM      07/10/2001
--
-- AUDIT TRAIL : 5.4                              LM      11/16/2001
-- 1) In-House Defect.
--    Changed all P_FormSelectOption Text from 'Not Applicable'
--    to 'Select One'.
--
-- 2) Procedure P_Submit :
--    A) Changed to decode new parameter orig_pidm,
--       which is the pidm of the web user.
--    B) Changed to accept new parameter dflt_ip,
--       which is the smbdflt_use_ip_crse value.
--       1) Added logic to test/display/accept
--          in-progress course usage indicator.
--          Display logic add to P_DispEvalTerm.
--    C) Changed call to bwckcmpl.p_do_capp to
--       pass the two new variables.
--
-- 3) Removed all hardcoded Compliance terminology
--    for output and replaced with variables in order
--    to facilitate easier customization for
--    client side specific CAPP terminology.
--    i.e
--    lbl_prog varchar2(10) default 'Program';
--    twbkfrmt.P_TableDataLabel(lbl_prog, calign=>'CENTER');
--    replaces
--    twbkfrmt.P_TableDataLabel('Program', calign=>'CENTER');
--
-- 4) Added logic to hide non-existent curriculum information
--    in procedure P_ .
--
-- 5) Relocation of numerous procedures to seperate
--    packages so that the code for displaying
--    compliance evaluation output is seperated
--    from this logic.
--
-- 6) Defect 75187                                LM      02/25/2002
--    Problem : When running compliance, if a student has more
--    than one source record, it is taking the record
--    with the maximum catalog term and not the
--    maximum effective term.
--    Resolution : Changed four cursors criteria
--    to match those in bwckcmp1.sql.
--    sgbstdn_prim_c, sgbstdn_secd_c,
--    saradap_prim_c, saradap_secd_c.
--
-- 7) Defect 75962                                LM      03/12/2002
--    Problem : Web Page P_DispCurrent, for
--    General Student display only ( SGBSTDN ), was
--    displaying the effective term as the catalog term.
--    Resolution : In procedure P_DispCurSourceSgbstdn,
--    change eff term to catalog term (1).
--
-- AUDIT TRAIL : 5.4.1                            LM      03/29/2002
-- 1) Changed P_Submit procedure.  Eliminated Degree and Major
--    parameters for change on P_DispEvalTerm.
-- 2) Changed P_DispEvalTerm.  Process now displays ONE
--    drop down box per a Program instead of the old method
--    of displaying 3 drop down boxes per program (program, major, degree).
--    This required changes to cursors
--    SGBSTDN_PRIM_C, SARADAP_PRIM_C, SHRDGMR_ALL_C, SRBRECR_ALL_C
--    to eliminate PROGRAM, DEGREE, and MAJOR from the query criteria.
--
--    Removed TWGRINFO records for bwckcapp.P_DispEvalTerm where label =
--    'NULLDEGR' and 'NULLMAJR'.
--
-- 3) Changed P_DispEvalViewOption & P_VerifyDispEvalViewoption
--    to add option to navigate to
--    new, third page of output(bwcksncr.P_DispEvalAdditional).
--    Also Added holds functionality to this page.
--
--
----------------------------------------------------------------------------
-- AUDIT TRAIL: 5.5
-- 1. Web Accessibility and UI changes            JRZ  06/27/2002
-- 2. Defect 79305                                LM   07/25/2002
--    Problem :  Department and First Concentration transposed
--               On P_DispCurrent.
--    Resolution:Change p_dispcurrent_majorX_format procedure
--               to correct transposition.
-- 3. Defect 80616                                JRZ 09/17/2002
--    Problem:   The Select Term page is looking at sorrtrm and
--               restricting the term selection by date and doesn't
--               need to.
--    Resolution:Changed the cursor to no longer look at sorrtrm, just
--               sobterm and stvterm.
----------------------------------------------------------------------------
-- AUDIT TRAIL: 6.0
-- 1. Web Accessibility and UI changes            JRZ  10/04/2002
--
----------------------------------------------------------------------------
-- AUDIT TRAIL: 6.1
-- RPE: SSSUI                                              JCK  07/16/2003
--    Convert twbkwbis.p_opendoc calls to bwckfrmt.p_open_doc
-------------------------------------------------------------------------
-- AUDIT TRAIL: 6.2                               JCK      04/05/2004
-- 1. Defect 80616
--    Problem: Web Registration Dates should not need to be defined on
--             SOATERM for a term to be a valid option in the term select
--             for degree evaluations.
--    Resolution: Altered cursor sorrtrm1c to check SOBTERM_WEB_CAPP_TERM_IND
--             rather than term registration dates.
-------------------------------------------------------------------------
-- AUDIT TRAIL: 7.0
-- 1) Migrate 6x changes to 7.0.                  JCK      05/21/04
-------------------------------------------------------------------------
-- AUDIT TRAIL: 7.1                               LM       01/13/2005
-- 1. Defect 92619.
--    Problem:   Printer friendly format obsolete with new use of
--               web_defaultprint.css.
--    Resolution: Remove printer friendly checkbox from
--                available view option page.
--
-- AUDIT TRAIL: 7.3                               LM       11/07/2005
-- 1. Defect 98483.
--    Problem:    On the generate new evaluation page, if the program
--                is not web enabled on form SMAPRLE, the web page
--                merely displays a drop down box with available terms
--                and a submit button.
--    Resolution: A) P_DispCurrent: Do not open and close tables, let:
--                B) (4)p_dispcurrsourcexxxxxx : changed procedures
--                    to open and close tables based upon f_prog_web_ind.
--                C) P_DispEvalTerm : encapsulated curriculum display,
--                   term dropdown box, and submit button logic in
--                   conditional logic.  If program not web enabled,
--                   then display TWGRINFO BWCKCAPP NOCUR informational
--                   message.
--
-- 1. Defect 103490,102433
--    Problem :  Webcapp uses the highest effective term record
--    instead of max effective term based upon term entered.
--
--    Resolution :
--    bwckcapp : The following cursors had the signature
--    changed to add p_term_in.  The sql was altered to
--    obtain the record with max effective term processing.
--    sgbstdn_prim_c
--    shrdgmr_all_c
--    saradap_prim_c
--    srbrecr_all_c
--    sgbstdn_disp_prim_c
--    saradap_disp_prim_c
--    shrdgmr_disp_all_c
--    srbrecr_disp_all_c
--
--    The following functions had the signature changed
--    to add p_term_in.  These functions were also changed
--    to remove the SQL and call the above new cursors.
--    f_test_shrdgmr_exist(p_pidm_in, p_term_in);
--    f_test_srbrecr_exist(p_pidm_in, p_term_in);
--    f_test_saradap_exist(p_pidm_in, p_term_in);
--    f_test_sgbstdn_exist(p_pidm_in, p_term_in);
--    f_test_sgbstdn_secd(p_pidm_in, p_term_in);
--    f_test_saradap_secd(p_pidm_in, p_term_in);
--
--    The following procedures had the signature changed
--    to add p_term_in.
--    P_DispCurSourceSgbstdn
--    P_DispCurSourceSaradap
--    P_DispCurSourceSrbrecr
--    P_DispCurSourceShrdgmr
--    P_Submit
--
--    bwckcmp1.sql changes :
--    The following cursors had the signature changed.
--    The sql was altered to obtain the record with max
--    effective term processing.
--    get_saradap_prim_c
--    get_saradap_secd_c
--    get_sgbstdn_prim_c
--    get_sgbstdn_secd_c
--
--    The following procedures had the signature changed.
--    p_do_capp
--    p_insert_smrrqcm
--
-- AUDIT TRAIL: NLS_DATE_SUPPORT
-- 1. TGKinderman   11/11/2005
--    This object was passed through a conversion process relative to preparing
--    the object to support internationalization needs.  Basically, hard coded
--    date format masks of DD-MON-YYYY are converted to a G$_DATE function that
--    returns nls_date_format.  The release number of this object was NOT
--    modified as part of this effort.  This object may or may not have had
--    conversion process code modifications.  However, this audit trail entry
--    does indicate that the object has been passed through the conversion.
--
-- AUDIT TRAIL: 7.3.1
-- 1. SR  80175                                  WG  08/16/2006
--    Problem: Previous and New Evaluations for a faculty member who had
--        run degree evaluations for an advisee were not evaluating for the
--        advisor who is also a student.
--    Fix:  added the calls to twbkwbis.p_setparam in the following
--
--      IF (nvl(twbkwbis.f_getparam(global_pidm, 'STUFAC_IND'), 'STU') ='FAC')
--          AND (calling_proc = 'bwlkfcap.P_FacDispCurrent') THEN
--         pidm      := to_number(twbkwbis.f_getparam(global_pidm, 'STUPIDM'),
--                                '999999999');
--         twbkwbis.p_setparam (global_pidm, 'STUFAC_IND', 'FAC');
--         call_path := 'F';
--      ELSE
--         call_path := 'S';
--         twbkwbis.p_setparam (global_pidm, 'STUFAC_IND', 'STU');
--         pidm      := global_pidm;
--      END IF;
--
-- AUDIT TRAIL: 7.3.3                             LM 24APR2007
-- 1. Defect 1-1C08BT
-- Problem   : Incorrect program displayed for degree evaluation when
-- using recruit, admissions, or degree records to determine the program.
-- The correction for CMS-DFCT102433 added the term code to the cursors
-- used by the degree evaluation to determine the student's program.
-- This was done for the recruit, admissions, general student, and degree
-- records.  However, only the general student record uses an effective
-- term for processing.  As such, the modified cursors for recruit,
-- admissions, and degree records need to be changed back to their pre-7.3
-- state that does not include a term code.  The general student cursor should
-- remain the same and continue to use the term code that was added to correct
-- defect CMS-DFCT102433.
--
-- Technical : Changed get_saradap_prim_c and get_saradap_secd_c cursors
-- not to use the term code sent in the sql criteria to determine correct
-- record source.
--
-- AUDIT TRAIL: 7.5                              ES 12MAY2008
-- 1. Defect 1-3CL1ZF and 1-3CL1VB
-- Problem : Master Web Term Control flag on SOATERM does not impact Degree
-- Evaluations - The Master Web Term Control flag on SOATERM should control
-- whether a term code is available anywhere in Self-Service Banner.
-- Solution: Changed the cursor sorrtrm1c, to include a check for
--          -->   sobterm_dynamic_sched_term_ind = 'Y'
--
-- AUDIT TRAIL: 8.0                               LM 20JUNE2007
-- 1. Migrate changes to 8.0.
-- 2. PVV   06/28/2007
--    Changed variable size for student_name for I18N changes.
-- 3. Defect 1-1ADJRE 1-1ADDDD I18N changes.      LM 27JUL2007
--
-- AUDIT TRAIL: 8.0.1                             ES 21MAY2008
-- 1. Migrate 7.5 changes to 8.0.1 - Defect 1-3CL1ZF and 1-3CL1VB
--
-- AUDIT TRAIL: 8.1
-- 1. 1-3R1IAA                                                 LVH 06/25/2008
--    A. Replace htf.formhidden and htp.formhidden with twbkfrmt.F_FormHidden
--       twbkfrmt.P_FormHidden to enable encoding of values.
--
-- AUDIT TRAIL: 8.2                               LM 15JAN2009
-- 1. CAPP XML report enhancement.
-- 2. Add calls to sokccur for replacing backfill.    WG 02/25/09
-- 3. Ran re-key utility tool.			RG 04/08/09
--
-- AUDIT TRAIL: 8.2.1                             JC 06/04/2009
-- 1. Checked out for release.
--
-- AUDIT TRAIL: 8.3 
-- 1.  Defect  1-6ZTGLN  MAH 8/24/09 
--    Problem:   sorlcur_current_cde is used instead of sovlcur_current_ind.  If clients have not run the 
--      susoplccv_learner (adm,recruit,outcome) to populate the current_cde no records will be returned. 
--   Solution:   remove all cursors that are in this package that use the current_cde, but are not used. 
--      Only one was used in the package to find the maximum term for the learner.  Replace that query with
--      api sb_learner.f_query_current to find the effective term for the term.  All curriculum for the learner should
--      be found for that term.
-- 2. Faculty Security Phase II changes                     AK  10/28/2009
--    Added two new parameters to p_dispevalterm.
--    1. pin_numb
--    2. msg
--    Added security using the call to siklibs.f_checksecurity. 
--
-- AUDIT TRAIL: 8.3.0.1
-- 1.  Checked out for release                              JC  11/04/2009
-- 2. Defect 1-7V3H92                                       LM  15DEC2009
--    Problem : "Term Code is invalid" error on degree evaluations for DEG records
--    and SMAWCRL settings to only display one record.
--    Solutions : P_DispCurrSourceShrdgmr;  Added initialization of variables
--    when rowcount = 1. P_DispTermSourceShrdgmr has a similar issue with the
--    hold_term variable as well as control for secondary curric display.
-- 3. Defect 1-983E4U                                       AB 29DEC2009
-- Problem : On Page p_dispCurrent, Concentrations need the catalogue term to get values from sokccur.p_parse_lfos_data
-- Solution : variable hold_term/term set to lv_term_ctlg coming from p_dispcurrent_table in the following functions
-- p_dispcursourcesgbstdn
-- p_dispcursourcesaradap
-- p_dispcursourceshrdgmr
-- p_dispcursourcesrbrecr
--
-- AUDIT TRAIL: 8.4
-- 1. Study Paths Phase II                                  JC  01/13/2010
--    Added display of term start and end dates to Term pulldown menus, based
--       on setting of new GTVSDAX 'WEBTRMDTE'.
-- AUDIT TRAIL END
--
CREATE OR REPLACE PACKAGE BODY bwckcapp AS
   --AUDIT_TRAIL_MSGKEY_UPDATE
-- PROJECT : MSGKEY
-- MODULE  : BWCKCAP1
-- SOURCE  : enUS
-- TARGET  : I18N
-- DATE    : Wed Dec 16 11:43:14 2009
-- MSGSIGN : #42f7c6442115e2d0
--TMI18N.ETR DO NOT CHANGE--
--
   -- FILE NAME..: bwckcap1.sql
   -- RELEASE....: 8.4
   -- OBJECT NAME: bwckcapp
   -- PRODUCT....: SCOMWEB
   -- USAGE......:
   -- COPYRIGHT..: Copyright (C) 2001 - 2009 SunGard. All rights reserved.
   --
   -- Contains confidential and proprietary information of SunGard and its subsidiaries.
   -- Use of these materials is limited to SunGard Higher Education licensees, and is
   -- subject to the terms and conditions of one or more written license agreements
   -- between SunGard Higher Education and the licensee in question
   --
   -- DESCRIPTION:
   --
   -- This package contains objects used to process and display
   -- Student's CAPP output to the web.
   --
   -- This package contains the following objects used to process
   -- student and CAPP releated data.
   --
   -- PROCEDURES :
   --
   -- DESCRIPTION END
   --
   pidm spriden.spriden_pidm%TYPE;
   curr_release CONSTANT VARCHAR2(10) := '8.4';
   smbpogn_row  smbpogn%ROWTYPE;
   global_pidm  spriden.spriden_pidm%TYPE;
   student_name VARCHAR2(185);
   confid_msg   VARCHAR2(90);
   smbwcrl_row  smbwcrl%ROWTYPE;
-- JDH output files
   uFile            UTL_FILE.FILE_TYPE;
   OutputFile      VARCHAR2(70) := 'jhorton3_bwckcap1.lis';
--   OutputFile      VARCHAR2(70) := '&3';
--        UTL_FILE.PUT_LINE(uFile,v_TitleHeader);
--      uFile := UTL_FILE.FOPEN( '/jobsub', OutputFile, 'w' );      
--      UTL_FILE.FCLOSE( uFile );            
--   NL              VARCHAR2(1)  := CHR(10);


   -------------------------------------------
   --
   -- Common Label section:
   -- If change required, change label only.
   -- Labels current for bwckcapp.P_DispCurrent only.
   --
   -------------------------------------------

   lbl_header_prim VARCHAR2(25) DEFAULT g$_nls.get('BWCKCAP1-0000',
                                                   'SQL',
                                                   'Primary Curriculum');
   lbl_header_secd VARCHAR2(25) DEFAULT g$_nls.get('BWCKCAP1-0001',
                                                   'SQL',
                                                   'Secondary Curriculum');
   lbl_header_alt  VARCHAR2(20) DEFAULT g$_nls.get('BWCKCAP1-0002',
                                                   'SQL',
                                                   'Curriculum');
   lbl_ctlg_term   VARCHAR2(20) DEFAULT g$_nls.get('BWCKCAP1-0003',
                                                   'SQL',
                                                   'Catalog Term: ');
   lbl_lvl         VARCHAR2(20) DEFAULT g$_nls.get('BWCKCAP1-0004',
                                                   'SQL',
                                                   'Level: ');
   lbl_camp        VARCHAR2(20) DEFAULT g$_nls.get('BWCKCAP1-0005',
                                                   'SQL',
                                                   'Campus: ');
   lbl_coll        VARCHAR2(20) DEFAULT g$_nls.get('BWCKCAP1-0006',
                                                   'SQL',
                                                   'College: ');
   lbl_degc        VARCHAR2(20) DEFAULT g$_nls.get('BWCKCAP1-0007',
                                                   'SQL',
                                                   'Degree: ');
   lbl_prog        VARCHAR2(20) DEFAULT g$_nls.get('BWCKCAP1-0008',
                                                   'SQL',
                                                   'Program: ');
   lbl_majr1       VARCHAR2(20) DEFAULT g$_nls.get('BWCKCAP1-0009',
                                                   'SQL',
                                                   'First Major: ');
   lbl_majr2       VARCHAR2(20) DEFAULT g$_nls.get('BWCKCAP1-0010',
                                                   'SQL',
                                                   'Second Major: ');
   lbl_dept1       VARCHAR2(20) DEFAULT g$_nls.get('BWCKCAP1-0011',
                                                   'SQL',
                                                   'Department: ');
   lbl_dept2       VARCHAR2(20) DEFAULT g$_nls.get('BWCKCAP1-0012',
                                                   'SQL',
                                                   'Department: ');
   lbl_conc1       VARCHAR2(20) DEFAULT g$_nls.get('BWCKCAP1-0013',
                                                   'SQL',
                                                   'Concentrations: ');
   lbl_conc2       VARCHAR2(20) DEFAULT g$_nls.get('BWCKCAP1-0014',
                                                   'SQL',
                                                   'Concentrations: ');
   lbl_conc3       VARCHAR2(20) DEFAULT g$_nls.get('BWCKCAP1-0015',
                                                   'SQL',
                                                   'Concentrations: ');
   lbl_minr1       VARCHAR2(20) DEFAULT g$_nls.get('BWCKCAP1-0016',
                                                   'SQL',
                                                   'Minors: ');
   lbl_minr2       VARCHAR2(20) DEFAULT g$_nls.get('BWCKCAP1-0017',
                                                   'SQL',
                                                   'Second Minor: ');

   -------------------------------------------
   --
   -- Following cursors used for retrieving
   -- a specific curriculum source
   --
   -------------------------------------------

   CURSOR sgbstdn_prim_c(p_pidm_in IN spriden.spriden_pidm%TYPE,
                         p_term_in IN stvterm.stvterm_code%TYPE) IS
      SELECT DISTINCT *
        FROM sgbstdn
       WHERE sgbstdn_pidm = p_pidm_in
         AND sgbstdn_term_code_eff =
             (SELECT MAX(x.sgbstdn_term_code_eff)
                FROM sgbstdn x
               WHERE x.sgbstdn_pidm = p_pidm_in
                 AND x.sgbstdn_term_code_eff <= p_term_in);

   -------------------------------------------

   CURSOR saradap_prim_c(p_pidm_in IN spriden.spriden_pidm%TYPE,
                         p_term_in IN stvterm.stvterm_code%TYPE) IS
      SELECT DISTINCT *
        FROM saradap
       WHERE saradap_pidm = p_pidm_in
    ORDER BY saradap_term_code_entry DESC,
             saradap_appl_no ASC;
         /* 7.3.3 1-1C08BT.
         AND saradap_appl_no =
             (SELECT MAX(x.saradap_appl_no)
                FROM saradap x
               WHERE x.saradap_pidm = p_pidm_in
                 AND x.saradap_term_code_entry =
                     (SELECT MAX(y.saradap_term_code_entry)
                        FROM saradap y
                       WHERE y.saradap_pidm = p_pidm_in
                         AND y.saradap_term_code_entry <= p_term_in)); */

   -------------------------------------------
   CURSOR srbrecr_all_c(p_pidm_in IN spriden.spriden_pidm%TYPE,
                        p_term_in IN stvterm.stvterm_code%TYPE) IS
      SELECT DISTINCT *
        FROM srbrecr
       WHERE srbrecr_pidm = p_pidm_in
       ORDER BY srbrecr_admin_seqno      ASC;

   -------------------------------------------
   CURSOR srbrecr_disp_all_c(p_pidm_in IN spriden.spriden_pidm%TYPE,
                             p_term_in IN stvterm.stvterm_code%TYPE) IS
      SELECT DISTINCT srbrecr_admin_seqno, srbrecr_term_code
        FROM srbrecr
       WHERE srbrecr_pidm = p_pidm_in
       ORDER BY srbrecr_admin_seqno      ASC;
       
   -------------------------------------------
   CURSOR shrdgmr_all_c(p_pidm_in IN spriden.spriden_pidm%TYPE,
                        p_term_in IN stvterm.stvterm_code%TYPE) IS
      SELECT DISTINCT *
        FROM shrdgmr
       WHERE shrdgmr_pidm = p_pidm_in
       ORDER BY shrdgmr_term_code_sturec   DESC,
                shrdgmr_seq_no    ASC;

   -------------------------------------------
   CURSOR shrdgmr_disp_p1_c(p_pidm_in IN spriden.spriden_pidm%TYPE) IS
      SELECT DISTINCT shrdgmr_seq_no, shrdgmr_term_code_sturec
        FROM shrdgmr
       WHERE shrdgmr_pidm = p_pidm_in
       ORDER BY shrdgmr_term_code_sturec DESC,
                shrdgmr_seq_no  ASC;
       
   -------------------------------------------
   CURSOR shrdgmr_disp_all_c(p_pidm_in IN spriden.spriden_pidm%TYPE,
                             p_term_in IN stvterm.stvterm_code%TYPE) IS
      SELECT DISTINCT shrdgmr_seq_no
        FROM shrdgmr
       WHERE shrdgmr_pidm = p_pidm_in
       ORDER BY shrdgmr_seq_no  DESC;
   -------------------------------------------

   CURSOR sgbstdn_disp_prim_c(p_pidm_in IN spriden.spriden_pidm%TYPE,
                              p_term_in IN stvterm.stvterm_code%TYPE) IS
      SELECT *
        FROM sgbstdn
       WHERE sgbstdn_pidm = p_pidm_in
         AND sgbstdn_term_code_eff =
             (SELECT MAX(x.sgbstdn_term_code_eff)
                FROM sgbstdn x
               WHERE x.sgbstdn_pidm = p_pidm_in
                 AND x.sgbstdn_term_code_eff <= p_term_in)
        ORDER BY sgbstdn_term_code_eff DESC;
 -------------------------------------------

   CURSOR sgbstdn_disp_prim_p1_c(p_pidm_in IN spriden.spriden_pidm%TYPE,
                                 p_term_in IN stvterm.stvterm_code%TYPE) IS
      SELECT DISTINCT sgbstdn_term_code_eff
        FROM sgbstdn
       WHERE sgbstdn_pidm = p_pidm_in
         AND sgbstdn_term_code_eff <= p_term_in
        ORDER BY sgbstdn_term_code_eff DESC;
 -------------------------------------------
 --  CURSOR sgbstdn_disp_prim_p2_c(p_pidm_in IN spriden.spriden_pidm%TYPE,
 --                   p_term_in IN stvterm.stvterm_code%TYPE) IS
 --   SELECT DISTINCT sorlcur_term_code
 --     from sorlcur, sgbstdn
 --     where nvl(sorlcur_current_cde, 'N') = 'Y'
 --       and sgbstdn_pidm = sorlcur_pidm
 --       and sorlcur_pidm = p_pidm_in
 --       and sorlcur_lmod_code = sb_curriculum_str.f_learner
 --       and sgbstdn_term_code_eff <= p_term_in  
 --       and sorlcur_term_code <= p_term_in
  --        ORDER BY sorlcur_term_code DESC;  
    CURSOR sgbstdn_disp_prim_p2_c(p_pidm_in IN spriden.spriden_pidm%TYPE,
                    p_term_in IN stvterm.stvterm_code%TYPE) IS
    SELECT sgbstdn_term_code_eff
      from  sgbstdn
      where  sgbstdn_pidm =   p_pidm_in
          -- and sgbstdn_term_code_eff <= p_term_in   
           AND sgbstdn_term_code_eff =
             (SELECT MAX(x.sgbstdn_term_code_eff)
                FROM sgbstdn x
               WHERE x.sgbstdn_pidm = p_pidm_in
                 AND x.sgbstdn_term_code_eff <= p_term_in) ;
   -------------------------------------------

   CURSOR saradap_disp_prim_c(p_pidm_in IN spriden.spriden_pidm%TYPE,
                              p_term_in IN stvterm.stvterm_code%TYPE) IS
      SELECT DISTINCT saradap_appl_no, saradap_term_code_entry
        FROM saradap
       WHERE saradap_pidm = p_pidm_in
   /*      AND saradap_term_code_entry =
             (SELECT MAX(y.saradap_term_code_entry)
                FROM saradap y
               WHERE y.saradap_pidm = p_pidm_in
                 AND y.saradap_term_code_entry <= p_term_in) */      
    ORDER BY saradap_appl_no DESC;
   -------------------------------------------
   

   CURSOR sobterm_c IS
      SELECT stvterm_code,
             stvterm_desc,
             TO_CHAR(stvterm_start_date, twbklibs.date_display_fmt) || ' - ' ||
             TO_CHAR(stvterm_end_date, twbklibs.date_display_fmt) TERM_DATE
        FROM stvterm,
             sobterm
       WHERE stvterm_code = sobterm_term_code
         AND sobterm_web_capp_term_ind = 'Y'
       ORDER BY 1 DESC;

   -------------------------------------------
   --
   -- 5.4. New cursor for holds functionality.
   --

   CURSOR sprhold_cmpl_c(pidm IN NUMBER) IS
      SELECT 'X' hold_cmpl
        FROM stvhldd,
             sprhold
       WHERE sprhold_pidm = pidm
         AND sprhold_from_date <= SYSDATE
         AND sprhold_to_date >= SYSDATE
         AND stvhldd_code = sprhold_hldd_code
         AND stvhldd_compliance_hold_ind = 'Y';

   -------------------------------------------
   --
   -- 5.4. New cursor for SMAWCRL Form controls
   --

   CURSOR smbwcrl_c(term_in IN stvterm.stvterm_code%TYPE) IS
      SELECT *
        FROM smbwcrl
       WHERE smbwcrl_term_code =
             (SELECT MAX(x.smbwcrl_term_code)
                FROM smbwcrl x
               WHERE smbwcrl_term_code <= term_in);

   ------------------------------------------
   --
   -- Cursor to retrieve default values from SMBDFLT
   --
   CURSOR smbdflt_c IS
      SELECT * FROM smbdflt WHERE smbdflt_dflt_code = 'WEB';

   -------------------------------------------
   --
   -- Cursor for retrieving SMRCPRT
   -- ( compliance type values ) for print fields.
   --

   CURSOR smrcprt_c(cprt_code_in IN smrcprt.smrcprt_cprt_code%TYPE) IS
      SELECT * FROM smrcprt WHERE smrcprt_cprt_code = cprt_code_in;

   -------------------------------------------
   --
   -- Function Section
   --
   -------------------------------------------
   --
   -- Retrieves highest request number
   -- for student/curriculum source combination.
   --

   FUNCTION f_getmaxreqnocomplete(pidm    IN smrrqcm.smrrqcm_pidm%TYPE,
                                  program IN smrrqcm.smrrqcm_program%TYPE,
                                  source1 IN smrrqcm.smrrqcm_orig_curr_source%TYPE)
      RETURN smrrqcm.smrrqcm_request_no%TYPE IS
      return_value smrrqcm.smrrqcm_request_no%TYPE;
      cnvt_source  smrrqcm.smrrqcm_orig_curr_source%TYPE DEFAULT NULL;
   BEGIN
      IF source1 = 'shrdgmr' THEN
         cnvt_source := 'HISTORY';
      END IF;

      IF source1 = 'sgbstdn' THEN
         cnvt_source := 'GENLSTU';
      END IF;

      IF source1 = 'saradap' THEN
         cnvt_source := 'ADMISSN';
      END IF;

      IF source1 = 'srbrecr' THEN
         cnvt_source := 'RECRUIT';
      END IF;

      SELECT MAX(smrrqcm_request_no)
        INTO return_value
        FROM smrrqcm
       WHERE smrrqcm_pidm = pidm
         AND smrrqcm_process_ind = 'N'
         AND smrrqcm_program = program
         AND smrrqcm_orig_curr_source = cnvt_source;
      RETURN return_value;
   EXCEPTION
      WHEN no_data_found THEN
         RETURN return_value;
   END f_getmaxreqnocomplete;

   -------------------------------------------
   --
   -- Used in P_DispCurSourceXXXXXXX
   -- to determine if a data display
   -- table should be displayed.
   -- No table displayed if no data.
   --

   FUNCTION f_display_major_table(param1 IN stvmajr.stvmajr_code%TYPE,
                                  param2 IN stvmajr.stvmajr_code%TYPE,
                                  param3 IN stvdept.stvdept_code%TYPE,
                                  param4 IN stvmajr.stvmajr_code%TYPE,
                                  param5 IN stvmajr.stvmajr_code%TYPE)
      RETURN BOOLEAN IS
      return_value BOOLEAN DEFAULT FALSE;
   BEGIN
      IF (param1 IS NOT NULL) OR (param2 IS NOT NULL) OR
         (param3 IS NOT NULL) OR (param4 IS NOT NULL) OR
         (param5 IS NOT NULL) THEN
         return_value := TRUE;
      ELSE
         return_value := FALSE;
      END IF;

      RETURN return_value;
   END f_display_major_table;

   -------------------------------------------
   --
   -- Used in P_DispCurSourceXXXXXXX
   -- to determine if a data display
   -- table should be displayed.
   -- No table displayed if no data.
   --

   FUNCTION f_display_minor_table(param1 IN stvmajr.stvmajr_code%TYPE,
                                  param2 IN stvmajr.stvmajr_code%TYPE)
      RETURN BOOLEAN IS
      return_value BOOLEAN DEFAULT FALSE;
   BEGIN
      IF (param1 IS NOT NULL) OR (param2 IS NOT NULL) THEN
         return_value := TRUE;
      ELSE
         return_value := FALSE;
      END IF;

      RETURN return_value;
   END f_display_minor_table;

   -------------------------------------------
   --
   -- The following 6 functions denoted by
   -- f_test_curricsource_exist_or_secd
   -- merely test if a primary/secondary
   -- curriculumn source exists for student.
   --
   -------------------------------------------

   FUNCTION f_test_srbrecr_exist(p_pidm_in IN spriden.spriden_pidm%TYPE,
                                 p_term_in IN stvterm.stvterm_code%TYPE)
      RETURN BOOLEAN IS
      return_value BOOLEAN DEFAULT FALSE;
      cnt          NUMBER DEFAULT 0;
      srbrecr_row  srbrecr%ROWTYPE;
   BEGIN
      OPEN srbrecr_all_c(p_pidm_in, p_term_in);
      FETCH srbrecr_all_c INTO srbrecr_row;
      IF srbrecr_all_c%NOTFOUND THEN
         return_value := FALSE;
      ELSE
         return_value := TRUE;
      END IF;
      CLOSE srbrecr_all_c;
      RETURN return_value;
   EXCEPTION
      WHEN no_data_found THEN
         RETURN return_value;
   END f_test_srbrecr_exist;

   -------------------------------------------

   FUNCTION f_test_saradap_exist(p_pidm_in IN spriden.spriden_pidm%TYPE,
                                 p_term_in IN stvterm.stvterm_code%TYPE)
      RETURN BOOLEAN IS
      return_value BOOLEAN DEFAULT FALSE;
      cnt          NUMBER DEFAULT 0;
      saradap_row  SARADAP%ROWTYPE;
   BEGIN
      OPEN saradap_prim_c(p_pidm_in, p_term_in);
      FETCH saradap_prim_c INTO saradap_row;
      IF saradap_prim_c%NOTFOUND THEN
         return_value := FALSE;
      ELSE
         return_value := TRUE;
      END IF;
      CLOSE saradap_prim_c;
      RETURN return_value;
   EXCEPTION
      WHEN no_data_found THEN
         RETURN return_value;
   END f_test_saradap_exist;

   -------------------------------------------

   FUNCTION f_test_sgbstdn_exist(p_pidm_in IN spriden.spriden_pidm%TYPE,
                                 p_term_in IN stvterm.stvterm_code%TYPE)
      RETURN BOOLEAN IS
      return_value BOOLEAN DEFAULT FALSE;
      cnt          NUMBER DEFAULT 0;
      sgbstdn_row  SGBSTDN%ROWTYPE;
   BEGIN
      OPEN sgbstdn_prim_c(p_pidm_in, p_term_in);
      FETCH sgbstdn_prim_c INTO sgbstdn_row;
      IF sgbstdn_prim_c%NOTFOUND THEN
         return_value := FALSE;
      ELSE
         return_value := TRUE;
      END IF;
      CLOSE sgbstdn_prim_c;
      RETURN return_value;
   EXCEPTION
      WHEN no_data_found THEN
         RETURN return_value;
   END f_test_sgbstdn_exist;

   -------------------------------------------

   FUNCTION f_test_shrdgmr_exist(p_pidm_in IN spriden.spriden_pidm%TYPE,
                                 p_term_in IN stvterm.stvterm_code%TYPE)
      RETURN BOOLEAN IS
      return_value BOOLEAN DEFAULT FALSE;
      cnt          NUMBER DEFAULT 0;
      shrdgmr_row   SHRDGMR%ROWTYPE;
   BEGIN
      OPEN shrdgmr_all_c(p_pidm_in, p_term_in);
      FETCH shrdgmr_all_c INTO shrdgmr_row;
      IF shrdgmr_all_c%NOTFOUND THEN
         return_value := FALSE;
      ELSE
         return_value := TRUE;
      END IF;
      CLOSE shrdgmr_all_c;
      RETURN return_value;
   EXCEPTION
      WHEN no_data_found THEN
         RETURN return_value;
   END f_test_shrdgmr_exist;

   -------------------------------------------
   --
   -- The following eight functions denoted by
   -- get_xxx_desc merely return description
   -- for a code sent into function.
   --
   -------------------------------------------

   FUNCTION get_program_desc(param1 IN smrprle.smrprle_program%TYPE)
      RETURN smrprle.smrprle_program_desc%TYPE IS
      return_value smrprle.smrprle_program_desc%TYPE DEFAULT NULL;
   BEGIN
      SELECT smrprle_program_desc
        INTO return_value
        FROM smrprle
       WHERE smrprle_program = param1;
      RETURN return_value;
   EXCEPTION
      WHEN no_data_found THEN
         RETURN return_value;
   END get_program_desc;

   -------------------------------------------

   FUNCTION get_term_desc(param1 IN stvterm.stvterm_code%TYPE)
      RETURN stvterm.stvterm_desc%TYPE IS
      return_value stvterm.stvterm_desc%TYPE DEFAULT NULL;
   BEGIN
      SELECT stvterm_desc
        INTO return_value
        FROM stvterm
       WHERE stvterm_code = param1;
      RETURN return_value;
   EXCEPTION
      WHEN no_data_found THEN
         RETURN return_value;
   END get_term_desc;

   -------------------------------------------

   FUNCTION get_camp_desc(param1 IN stvcamp.stvcamp_code%TYPE)
      RETURN stvcamp.stvcamp_desc%TYPE IS
      return_value stvcamp.stvcamp_desc%TYPE DEFAULT NULL;
   BEGIN
      SELECT stvcamp_desc
        INTO return_value
        FROM stvcamp
       WHERE stvcamp_code = param1;
      RETURN return_value;
   EXCEPTION
      WHEN no_data_found THEN
         RETURN return_value;
   END get_camp_desc;

   -------------------------------------------

   FUNCTION get_coll_desc(param1 IN stvcoll.stvcoll_code%TYPE)
      RETURN stvcoll.stvcoll_desc%TYPE IS
      return_value stvcoll.stvcoll_desc%TYPE DEFAULT NULL;
   BEGIN
      SELECT stvcoll_desc
        INTO return_value
        FROM stvcoll
       WHERE stvcoll_code = param1;
      RETURN return_value;
   EXCEPTION
      WHEN no_data_found THEN
         RETURN return_value;
   END get_coll_desc;

   -------------------------------------------

   FUNCTION get_degc_desc(param1 IN stvdegc.stvdegc_code%TYPE)
      RETURN stvdegc.stvdegc_desc%TYPE IS
      return_value stvdegc.stvdegc_desc%TYPE DEFAULT NULL;
   BEGIN
      SELECT stvdegc_desc
        INTO return_value
        FROM stvdegc
       WHERE stvdegc_code = param1;
      RETURN return_value;
   EXCEPTION
      WHEN no_data_found THEN
         RETURN return_value;
   END get_degc_desc;

   -------------------------------------------

   FUNCTION get_majr_desc(param1 IN stvmajr.stvmajr_code%TYPE)
      RETURN stvmajr.stvmajr_desc%TYPE IS
      return_value stvmajr.stvmajr_desc%TYPE DEFAULT NULL;
   BEGIN
      SELECT stvmajr_desc
        INTO return_value
        FROM stvmajr
       WHERE stvmajr_code = param1;
      RETURN return_value;
   EXCEPTION
      WHEN no_data_found THEN
         RETURN return_value;
   END get_majr_desc;

   -------------------------------------------

   FUNCTION get_dept_desc(param1 IN stvdept.stvdept_code%TYPE)
      RETURN stvdept.stvdept_desc%TYPE IS
      return_value stvdept.stvdept_desc%TYPE DEFAULT NULL;
   BEGIN
      SELECT stvdept_desc
        INTO return_value
        FROM stvdept
       WHERE stvdept_code = param1;
      RETURN return_value;
   EXCEPTION
      WHEN no_data_found THEN
         RETURN return_value;
   END get_dept_desc;

   -------------------------------------------

   FUNCTION get_levl_desc(param1 IN stvlevl.stvlevl_code%TYPE)
      RETURN stvlevl.stvlevl_desc%TYPE IS
      return_value stvlevl.stvlevl_desc%TYPE DEFAULT NULL;
   BEGIN
      SELECT stvlevl_desc
        INTO return_value
        FROM stvlevl
       WHERE stvlevl_code = param1;
      RETURN return_value;
   EXCEPTION
      WHEN no_data_found THEN
         RETURN return_value;
   END get_levl_desc;

   -------------------------------------------
   --
   -- Function to determine which curriculum
   -- source to use based upon heirarchy in
   -- GTVSDAX.
   -- Processing based off 2 key factors.
   -- 1) Loop processes descending ( 4 .. 1 )
   -- 2) Boolean logic.
   -- Logic is such that, if the next highest
   -- curriculum source exists(true), then overwrite
   -- this new curriculum source with the last
   -- curric. source was true.  If the next highest
   -- curric source is not true,  then do not overwrite
   -- the last good value and keep the last 'good' value.

   FUNCTION f_get_mtch_curric_heir(param1 IN spriden.spriden_pidm%TYPE,
                                   stu_x  IN BOOLEAN,
                                   his_x  IN BOOLEAN,
                                   rec_x  IN BOOLEAN,
                                   adm_x  IN BOOLEAN) RETURN VARCHAR2 IS
      return_value VARCHAR2(7) DEFAULT NULL;
      source1      VARCHAR2(7) DEFAULT NULL;

      CURSOR gtvsdax_c IS
         SELECT gtvsdax_external_code
           FROM gtvsdax
          WHERE gtvsdax_internal_code_group = 'WEBCAPP'
            AND gtvsdax_internal_code = 'WEBCURR'
          ORDER BY gtvsdax_internal_code_seqno DESC;
   BEGIN
      FOR gtvsdax_row IN gtvsdax_c
      LOOP
         IF gtvsdax_row.gtvsdax_external_code = 'DEG' THEN
            IF his_x = TRUE THEN
               source1 := 'shrdgmr';
            END IF;
         END IF;

         IF gtvsdax_row.gtvsdax_external_code = 'GST' THEN
            IF stu_x = TRUE THEN
               source1 := 'sgbstdn';
            END IF;
         END IF;

         IF gtvsdax_row.gtvsdax_external_code = 'ADM' THEN
            IF adm_x = TRUE THEN
               source1 := 'saradap';
            END IF;
         END IF;

         IF gtvsdax_row.gtvsdax_external_code = 'REC' THEN
            IF rec_x = TRUE THEN
               source1 := 'srbrecr';
            END IF;
         END IF;
      END LOOP;

      return_value := source1;
      RETURN return_value;
   EXCEPTION
      WHEN no_data_found THEN
         RETURN return_value;
   END f_get_mtch_curric_heir;

   -------------------------------------------
   --
   -- Used to determine if organization
   -- set-up curriculumn values in gtvsdax.
   --

   FUNCTION f_gtvsdax_webcurr_exist(param1 IN NUMBER) RETURN BOOLEAN IS
      return_value BOOLEAN DEFAULT FALSE;
      cnt          NUMBER DEFAULT 0;
   BEGIN
      SELECT COUNT(1)
        INTO cnt
        FROM gtvsdax
       WHERE gtvsdax_internal_code = 'WEBCURR'
         AND gtvsdax_internal_code_group = 'WEBCAPP';

      IF cnt = 0 THEN
         return_value := TRUE;
      ELSIF cnt >= 1 THEN
         return_value := FALSE;
      END IF;

      RETURN return_value;
   EXCEPTION
      WHEN no_data_found THEN
         RETURN return_value;
   END f_gtvsdax_webcurr_exist;

   -------------------------------------------
   --
   -- Tests whether the program is allowed to
   -- display on the web.
   --

   FUNCTION f_prog_web_ind(param1 IN smrprle.smrprle_program%TYPE)
      RETURN BOOLEAN IS
      return_value BOOLEAN DEFAULT FALSE;
      cnt          NUMBER DEFAULT 0;
   BEGIN
      SELECT COUNT(1)
        INTO cnt
        FROM smrprle
       WHERE smrprle_program = param1
         AND smrprle_web_ind = 'Y';

      IF cnt = 0 THEN
         return_value := FALSE;
       
      ELSIF cnt >= 1 THEN
         return_value := TRUE;
      
      END IF;

      RETURN return_value;
   EXCEPTION
      WHEN no_data_found THEN
         RETURN return_value;
   END f_prog_web_ind;

   -------------------------------------------
   --
   -- returns the advisors pidm for the student
   -- term sent into function.
   --

   FUNCTION f_getadvrpidm(pidm IN spriden.spriden_pidm%TYPE,
                          term IN stvterm.stvterm_code%TYPE)
      RETURN spriden.spriden_pidm%TYPE IS
      return_value spriden.spriden_pidm%TYPE DEFAULT NULL;

      CURSOR get_advr_pidm_c(pidm smrrqcm.smrrqcm_pidm%TYPE, term sgradvr.sgradvr_term_code_eff%TYPE) IS
         SELECT spriden_pidm
           FROM spriden,
                sgradvr
          WHERE sgradvr_pidm = pidm
            AND sgradvr_prim_ind = 'Y'
            AND spriden_pidm = sgradvr_advr_pidm
            AND spriden_change_ind IS NULL
            AND sgradvr_term_code_eff =
                (SELECT MAX(x.sgradvr_term_code_eff)
                   FROM sgradvr x
                  WHERE x.sgradvr_pidm = pidm
                    AND x.sgradvr_term_code_eff <= term);
   BEGIN
      OPEN get_advr_pidm_c(pidm, term);
      FETCH get_advr_pidm_c
         INTO return_value;
      CLOSE get_advr_pidm_c;
      RETURN return_value;
   EXCEPTION
      WHEN no_data_found THEN
         RETURN return_value;
   END f_getadvrpidm;

   -------------------------------------------

   FUNCTION f_getemailnamestr(pidm IN spriden.spriden_pidm%TYPE)
      RETURN VARCHAR2 IS
      return_value VARCHAR2(100) DEFAULT NULL;

      CURSOR get_advr_namestr_c(pidm smrrqcm.smrrqcm_pidm%TYPE) IS
         SELECT spriden_first_name || ' ' || spriden_last_name
           FROM spriden
          WHERE spriden_pidm = pidm
            AND spriden_change_ind IS NULL;
   BEGIN
      OPEN get_advr_namestr_c(pidm);
      FETCH get_advr_namestr_c
         INTO return_value;
      CLOSE get_advr_namestr_c;
      RETURN return_value;
   EXCEPTION
      WHEN no_data_found THEN
         RETURN return_value;
   END f_getemailnamestr;

   -------------------------------------------

   FUNCTION f_getemailaddress(pidm_in       IN spriden.spriden_pidm%TYPE,
                              email_code_in IN goremal.goremal_emal_code%TYPE)
      RETURN goremal.goremal_email_address%TYPE IS
      return_value goremal.goremal_email_address%TYPE DEFAULT NULL;

      CURSOR get_goremal_email_c(pidm_in goremal.goremal_pidm%TYPE, email_code_in goremal.goremal_emal_code%TYPE) IS
         SELECT goremal_email_address
           FROM goremal
          WHERE goremal_pidm = pidm_in
            AND goremal_status_ind = 'A'
            AND goremal_preferred_ind = 'Y'
            AND goremal_disp_web_ind = 'Y'
            AND goremal_emal_code = email_code_in;
   BEGIN
      OPEN get_goremal_email_c(pidm_in, email_code_in);
      FETCH get_goremal_email_c
         INTO return_value;
      CLOSE get_goremal_email_c;
      RETURN return_value;
   EXCEPTION
      WHEN no_data_found THEN
         RETURN return_value;
   END f_getemailaddress;

   -------------------------------------------
   --
   -- Returns the actual value of the
   -- In-Progress Course usage flag
   -- as defined on SMADFLT/SMBDFLT
   -- For 'WEB' usage.
   --

   FUNCTION f_smbdflt_ip_crse_ind RETURN VARCHAR2 IS
      return_value VARCHAR2(1) DEFAULT 'N';

      CURSOR smbdflt_c IS
         SELECT smbdflt_use_ip_crse_ind
           FROM smbdflt
          WHERE smbdflt_dflt_code = 'WEB';
   BEGIN
      OPEN smbdflt_c;
      FETCH smbdflt_c
         INTO return_value;
      CLOSE smbdflt_c;
      RETURN return_value;
   EXCEPTION
      WHEN no_data_found THEN
         RETURN return_value;
   END f_smbdflt_ip_crse_ind;

   --------------------------------------------
   --
   -- Returns whether or not faculty or advrs.
   -- can override the default in-progress
   -- course usage setting on SMADFLT/SMBDFLT.
   --

   FUNCTION f_smbwcrl_ip_ovrd_flg(param1 IN stvterm.stvterm_code%TYPE)
      RETURN BOOLEAN IS
      return_value BOOLEAN DEFAULT FALSE;
      tmp          VARCHAR2(1) DEFAULT 'N';

      CURSOR smbwcrl_c(param1 IN stvterm.stvterm_code%TYPE) IS
         SELECT smbwcrl_fac_ip_override_ind
           FROM smbwcrl
          WHERE smbwcrl_term_code =
                (SELECT MAX(x.smbwcrl_term_code)
                   FROM smbwcrl x
                  WHERE x.smbwcrl_term_code <= param1);
   BEGIN
      OPEN smbwcrl_c(param1);
      FETCH smbwcrl_c
         INTO tmp;
      CLOSE smbwcrl_c;

      IF tmp = 'Y' THEN
         return_value := TRUE;
      ELSE
         return_value := FALSE;
      END IF;

      RETURN return_value;
   EXCEPTION
      WHEN no_data_found THEN
         RETURN return_value;
   END f_smbwcrl_ip_ovrd_flg;

   -------------------------------------------
   --
   -- Procedure Section
   --
   -------------------------------------------
   --
   -- Web Page
   -- This procedure displays the options for generating
   -- a compliance request to the web.
   -- It lists curriculum source available based upon
   -- GTVSDAX WEBCURR settings.
   --

PROCEDURE p_dispevalterm(sf_status IN NUMBER DEFAULT NULL,
                         term_in   IN VARCHAR2 DEFAULT NULL,
                         pin_numb  IN VARCHAR2 DEFAULT NULL,
                         msg       IN VARCHAR2 DEFAULT NULL) IS
  pidm          spriden.spriden_pidm%TYPE;
  call_path     VARCHAR2(1);
  term          smbpogn.smbpogn_term_code_eff%TYPE;
  advr_pidm     spriden.spriden_pidm%TYPE DEFAULT NULL;
  source1       VARCHAR2(8) DEFAULT NULL;
  stu_exist     BOOLEAN DEFAULT FALSE;
  his_exist     BOOLEAN DEFAULT FALSE;
  rec_exist     BOOLEAN DEFAULT FALSE;
  adm_exist     BOOLEAN DEFAULT FALSE;
  disp_secd     BOOLEAN DEFAULT FALSE;
  sgbstdn_secd  BOOLEAN DEFAULT FALSE;
  saradap_secd  BOOLEAN DEFAULT FALSE;
  web_disp_prog BOOLEAN DEFAULT FALSE;
  no_curric     BOOLEAN DEFAULT FALSE;
  config_err    BOOLEAN DEFAULT FALSE;
  dflt_ip       smbdflt_ind_tab;
  hold_term     stvterm.stvterm_code%TYPE DEFAULT NULL;
  smbdflt_row   smbdflt%ROWTYPE;
  count1        NUMBER;
  disp_curr     BOOLEAN DEFAULT FALSE;
  table_open    BOOLEAN DEFAULT FALSE;

  -- 5.4. Datatype for holds functionality.
  --
  TYPE sprhold_cmplc_type IS RECORD(
    hold_cmpl stvhldd.stvhldd_compliance_hold_ind%TYPE);

  sprhold_cmplc_rec sprhold_cmplc_type; -- Hold row.
  -- Common Label section.
  -- If change required, change label only.
  -- Labels current for bwckcapp.P_DispEvalTerm only.

  lbl_prog   VARCHAR2(15) DEFAULT g$_nls.get('BWCKCAP1-0018',
                                             'SQL',
                                             'Program: ');
  lbl_degc   VARCHAR2(14) DEFAULT g$_nls.get('BWCKCAP1-0019',
                                             'SQL',
                                             'Degree: ');
  lbl_majr   VARCHAR2(14) DEFAULT g$_nls.get('BWCKCAP1-0020',
                                             'SQL',
                                             'Major: ');
  lbl_term   VARCHAR2(12) DEFAULT g$_nls.get('BWCKCAP1-0021',
                                             'SQL',
                                             'Term: ');
  lbl_ip_txt VARCHAR2(25) DEFAULT g$_nls.get('BWCKCAP1-0022',
                                             'SQL',
                                             'Use In-Progress Courses');

  -- FSS phase II changes     
  lv_access VARCHAR2(1);
  l_name    VARCHAR2(185);
  gtvsdax_rec gtvsdax%ROWTYPE;
  lv_term_date   VARCHAR2(200):= NULL;
  lv_desc_length NUMBER;
BEGIN
  IF NOT twbkwbis.f_validuser(global_pidm) THEN
    RETURN;
  END IF;

  -- Check if procedure is being run from facweb or stuweb.
  -- If stuweb, then use the pidm of the user. Else, use
  -- the pidm that corresponds to the student that was
  -- specified by the user.
  -- ==================================================

  IF nvl(twbkwbis.f_getparam(global_pidm, 'STUFAC_IND'), 'STU') = 'FAC' THEN
    pidm      := to_number(twbkwbis.f_getparam(global_pidm, 'STUPIDM'),
                           '999999999');
    call_path := 'F';
  ELSE
    call_path := 'S';
    pidm      := global_pidm;
  END IF;

  --
  -- Retrieve term.
  --
  IF term_in IS NULL THEN
    hold_term := twbkwbis.f_getparam(pidm, 'TERM');
  ELSE
    twbkwbis.p_setparam(pidm, 'TERM', term_in);
    hold_term := term_in;
  END IF;

  --
  -- Make sure a term has been selected
  IF hold_term IS NULL THEN
    bwckcapp.p_seldefterm(hold_term,
                          calling_proc_name => 'bwckcapp.P_DispEvalTerm');
    hold_term := twbkwbis.f_getparam(pidm, 'TERM');
    RETURN;
  END IF;
  -- FSS phase II changes      
  IF msg IS NOT NULL THEN
    bwckfrmt.p_open_doc('bwckcapp.P_DispEvalTerm', hold_term);
    twbkwbis.P_DispInfo('bwlkfcap.P_FacDispCurrent', msg);
  
    IF msg = 'Not_Student' THEN
      twbkwbis.p_closedoc(curr_release, print_bottom_links => FALSE);
      RETURN;
    END IF;
  END IF;

  IF call_path = 'F' THEN
    lv_access := siklibs.f_checksecurity(proc     => 'COMPLIANCE',
                                         term     => hold_term,
                                         fac_pidm => global_pidm,
                                         stu_pidm => pidm);
  
    IF pin_numb IS NOT NULL THEN
      IF NOT bwckcoms.f_ValidateStudentPIN(pidm, pin_numb, NULL) THEN
        bwckcapp.P_DispEvalTerm(sf_status => sf_status,
                                term_in   => hold_term,
                                msg       => 'Invalid_PIN');
        RETURN;
      END IF;
    ELSE
    
      IF lv_access = 'N' THEN
        bwckcapp.P_DispEvalTerm(sf_status => sf_status,
                                term_in   => hold_term,
                                msg       => 'Not_Student');
        RETURN;
      ELSIF lv_access = 'P' THEN
        IF msg IS NULL THEN
          bwckfrmt.p_open_doc('bwckcapp.P_DispEvalTerm', hold_term);
          twbkfrmt.p_paragraph(1);
        END IF;
      
        l_name := f_format_name(pidm, 'FMIL');
        twbkfrmt.p_printbold(G$_NLS.Get('BWCKCAP1-0023',
                                        'SQL',
                                        'Student Name: %01%',
                                        l_name));
        twbkfrmt.p_paragraph(2);
        HTP.formopen('bwckcapp.P_DispEvalTerm', 'POST');
        --pin_rule := 'T';
        twbkfrmt.P_FormHidden('sf_status', sf_status);
        twbkfrmt.P_FormHidden('term_in', hold_term);
      
        bwckcoms.p_disp_pin_prompt();
      
        HTP.formsubmit(NULL, G$_NLS.Get('BWCKCAP1-0024', 'SQL', 'Submit'));
        twbkwbis.p_closedoc(curr_release, print_bottom_links => FALSE);
        RETURN;
      
      ELSIF lv_access = 'Y' THEN
        NULL;
      END IF;
    END IF;
  END IF;
  -- FSS phase II changes       

  -- Initialize web page for facweb.
  -- ==================================================
  IF nvl(twbkwbis.f_getparam(global_pidm, 'STUFAC_IND'), 'STU') = 'FAC' THEN
    -- Format student name.
    -- ==================================================
    student_name := f_format_name(pidm, 'FMIL');
    bwckfrmt.p_open_doc('bwckcapp.P_DispEvalTerm');
  
    -- Check if student is confidential.
    -- ==================================================
    bwcklibs.p_confidstudinfo(pidm, hold_term);
  
    -- Initialize web page for stuweb.
    -- ==================================================
  ELSE
    bwckfrmt.p_open_doc('bwckcapp.P_DispEvalTerm');
  END IF;

  --
  -- Check for holds.
  -- ===================================================
  OPEN sprhold_cmpl_c(pidm);
  FETCH sprhold_cmpl_c
    INTO sprhold_cmplc_rec;

  IF sprhold_cmpl_c%FOUND THEN
    IF call_path = 'S' THEN
      twbkwbis.p_dispinfo('bwckcapp.P_DispCurrent', 'STUHOLD');
    ELSIF call_path = 'F' THEN
      twbkwbis.p_dispinfo('bwckcapp.P_DispCurrent', 'FACHOLD');
    END IF;
  END IF;

  IF (call_path = 'S') AND (sprhold_cmpl_c%FOUND) THEN
    NULL;
    -- If student user and holds exist, do not display
    -- any information(null).
  ELSE
    -- This code used when P_Submit can not create and
    -- run a request.
    --
    IF sf_status IS NOT NULL THEN
      IF sf_status <> 1 THEN
        IF sf_status = 0 THEN
          twbkwbis.p_dispinfo('bwckcapp.P_DispEvalTerm', 'CONNECT');
        END IF;
      
        IF sf_status = 51 THEN
          twbkwbis.p_dispinfo('bwckcapp.P_DispEvalTerm', 'NULLPROG');
        END IF;
      
        IF sf_status = 54 THEN
          twbkwbis.p_dispinfo('bwckcapp.P_DispEvalTerm', 'NULLTERM');
        END IF;
      
        IF sf_status = 55 THEN
          twbkwbis.p_dispinfo('bwckcapp.P_DispEvalTerm', 'FAILED');
        END IF;
      
        IF sf_status = 10 THEN
          twbkwbis.p_dispinfo('bwckcapp.P_DispEvalTerm', 'FAILED');
        END IF;
      END IF;
    END IF;
  
    htp.formopen(twbkwbis.f_cgibin || 'bwckcapp.P_Submit',
                 cattributes => 'onSubmit="return checkSubmit()"');
    stu_exist := f_test_sgbstdn_exist(pidm, hold_term);
    his_exist := f_test_shrdgmr_exist(pidm, hold_term);
    rec_exist := f_test_srbrecr_exist(pidm, hold_term);
    adm_exist := f_test_saradap_exist(pidm, hold_term);
    source1   := f_get_mtch_curric_heir(pidm,
                                        stu_exist,
                                        his_exist,
                                        rec_exist,
                                        adm_exist);
    --
    -- Get values from SMAWCRL/SMBWCRL - used
    -- for retrieving default in-progress course usage flag
    -- as well as curriculum information to display.
    --
    OPEN smbwcrl_c(hold_term);
    FETCH smbwcrl_c
      INTO smbwcrl_row;
    CLOSE smbwcrl_c;
    OPEN smbdflt_c;
    FETCH smbdflt_c
      INTO smbdflt_row;
    CLOSE smbdflt_c;
  
    IF smbwcrl_row.smbwcrl_disp_second_curr_ind = 'Y' THEN
      disp_secd := TRUE;
    ELSE
      disp_secd := FALSE;
    END IF;
  
    twbkfrmt.P_FormHidden('source1', source1);
  
    IF source1 IS NULL THEN
      config_err := f_gtvsdax_webcurr_exist(1);
    
      IF config_err = FALSE THEN
        no_curric := TRUE;
      END IF;
    END IF;
  
    IF config_err = TRUE THEN
      twbkwbis.p_dispinfo('bwckcapp.P_DispCurrent', 'CONFIG');
    END IF;
  
    IF no_curric = TRUE THEN
      twbkwbis.p_dispinfo('bwckcapp.P_DispCurrent', 'NOCUR');
    END IF;
  
    IF config_err = FALSE THEN
      IF no_curric = FALSE THEN
        IF sf_status IS NULL THEN
          twbkwbis.p_dispinfo('bwckcapp.P_DispEvalTerm', 'DEFAULT');
        END IF;
      
        --
        -- WebCAPP v 2.5
        -- Major revision on how 'Generate New' is processed.
        --
        -- Old version listed 1)program 2)degree 3) major
        -- in three seperate drop down boxes.
        -- New version to list all program information
        -- for Primary or Secondary or Multiple curriculums
        -- in ONE drop down box.
        --
        -- The Degree Record and Recruit Record
        -- differ from the General Student and Admissions
        -- record in the sense that
        -- degree/recruit creates a new record
        -- for each curriculum;  whereas the general student
        -- and admissions record can have a secondary curriculum
        -- (2nd program) on the primary curriculumn record.
        -- Therefor,  coding for general student/admissions will
        -- be similar to each other, but different from
        -- degree and recruit coding.
        --
        --
        -- General Student Section.
        --
      
        IF source1 = 'sgbstdn' THEN
          p_disptermsourcesgbstdn(pidm,
                                  source1,
                                  disp_secd,
                                  hold_term,
                                  count1);
        END IF; -- end source of sgbstdn;
      
        --
        -- Degree Record Section.
        --
      
        IF source1 = 'shrdgmr' THEN
          p_disptermsourceshrdgmr(pidm,
                                  source1,
                                  disp_secd,
                                  hold_term,
                                  count1);
        END IF; -- End if source = shrdgmr;
      
        --
        -- Admissions Record Section.
        --
      
        IF source1 = 'saradap' THEN
          p_disptermsourcesaradap(pidm,
                                  source1,
                                  disp_secd,
                                  hold_term,
                                  count1);
        END IF; -- end source of saradap;
      
        --
        -- Recruiting Record Section.
        --
      
        IF source1 = 'srbrecr' THEN
          p_disptermsourcesrbrecr(pidm,
                                  source1,
                                  disp_secd,
                                  hold_term,
                                  count1);
        END IF; -- End if source = srbrecr;
      
        --
        -- End srbrecr selection.
        --
        -- Display Term Selection
        --
        -- 98483
        --
        twbkfrmt.P_FormHidden('ctlg_term', hold_term);
      
        IF (count1 > 0) THEN
        
          twbkfrmt.p_tablerowopen;
          twbkfrmt.P_TableData('&nbsp;');
          twbkfrmt.p_tabledata(twbkfrmt.f_printtext(twbkfrmt.f_formlabel(lbl_term,
                                                                         idname => 'term_input_id')));
          twbkfrmt.p_tabledataopen;
          -- 8.0 I18N 1-1ADJRE
          htp.formselectopen('eval_term',
                             cattributes => ' ID="term_input_id"');
        
          --
          -- If there is a default eval term on SMADFLT; display this as first item ( not standard "Select One" text)
          --
          IF smbdflt_row.smbdflt_term_code_eval IS NOT NULL THEN   
            twbkwbis.p_formselectoption(get_term_desc(smbdflt_row.smbdflt_term_code_eval),
                                        smbdflt_row.smbdflt_term_code_eval);
            twbkwbis.p_formselectoption('---------------', NULL);
          END IF;
--
-- Check GTVSDAX 'WEBTRMDTE' controls. If N, display only term descriptions 
-- in term pull-down menu.  If Y, display term start and end dates as well. 
--
          IF NVL (twbkwbis.f_getparam(global_pidm,'STUFAC_IND'),'STU') = 'FAC'
          THEN
            gtvsdax_rec := goksels.f_get_gtvsdax_row('FACWEB','WEBTRMDTE');
          ELSE
            gtvsdax_rec := goksels.f_get_gtvsdax_row('STUWEB','WEBTRMDTE');
          END IF;
        
          FOR sobterm_row IN sobterm_c LOOP
            IF gtvsdax_rec.gtvsdax_external_code = 'Y'
            THEN
              lv_term_date := sobterm_row.term_date;         
              SELECT 50 - length(sobterm_row.stvterm_desc)
                INTO lv_desc_length
                FROM dual;
              lv_term_date :=rpad(' ', lv_desc_length, ' . ') ||lv_term_date;
            ELSE
              lv_term_date := NULL;
            END IF;
            twbkwbis.p_formselectoption(sobterm_row.stvterm_desc||lv_term_date,
                                        sobterm_row.stvterm_code);
          END LOOP;
        
          htp.formselectclose;
          twbkfrmt.p_tabledataclose;
          twbkfrmt.p_tablerowclose;
          --
          -- In Progress display and setting.
          --
          twbkfrmt.p_tablerowopen;
          twbkfrmt.p_tabledataopen(ccolspan => '3');
          twbkfrmt.P_FormHidden('dflt_ip', f_smbdflt_ip_crse_ind);
        
          IF call_path = 'F' THEN
            IF f_smbwcrl_ip_ovrd_flg(hold_term) THEN
              IF f_smbdflt_ip_crse_ind = 'Y' THEN
                htp.formcheckbox(cname       => 'dflt_ip',
                                 cvalue      => 'Y',
                                 cchecked    => 'CHECKED',
                                 cattributes => ' ID="dflt_ip_id"');
                twbkfrmt.p_printtext(twbkfrmt.f_formlabel(lbl_ip_txt,
                                                          idname => 'dflt_ip_id'));
                htp.br;
              ELSIF f_smbdflt_ip_crse_ind = 'N' THEN
                htp.formcheckbox(cname       => 'dflt_ip',
                                 cvalue      => 'Y',
                                 cattributes => ' ID="dflt_ip_id"');
                twbkfrmt.p_printtext(twbkfrmt.f_formlabel(lbl_ip_txt,
                                                          idname => 'dflt_ip_id'));
                htp.br;
              END IF;
            END IF;
          END IF;
        
          twbkfrmt.p_tabledataclose;
          twbkfrmt.p_tablerowclose;
        END IF;
      END IF; -- End no_curric
    END IF; -- End config_err
    --- email to margy
  
    IF (count1 > 0) THEN
      htp.br;
      htp.br;
      htp.formsubmit(NULL,
                     g$_nls.get('BWCKCAP1-0025', 'SQL', 'Generate Request'));
      htp.formclose;
    ELSE
      -- 98483 Display error message the program is not
      -- available online
      twbkwbis.p_dispinfo('bwckcapp.P_DispCurrent', 'NOCUR');
    END IF;
  END IF; -- End holds.

  CLOSE sprhold_cmpl_c;
  twbkwbis.p_closedoc(curr_release);
END p_dispevalterm;

   -------------------------------------------------------------------------
   --
   -- This procedure used for submitting a compliance request
   -- to the system.  This is called only from
   -- bwckcapp.P_DispEvalTerm.
   --

   PROCEDURE p_submit(source1   IN VARCHAR2 DEFAULT NULL,
                      program   IN VARCHAR2 DEFAULT NULL,
                      ctlg_term IN smrrqcm.smrrqcm_term_code_ctlg_1%TYPE,
                      eval_term IN smrrqcm.smrrqcm_term_code_eval%TYPE,
                      dflt_ip IN smbdflt_ind_tab) IS
      sf_status    NUMBER DEFAULT 0;
      request_no   smrrqcm.smrrqcm_request_no%TYPE;
      job_no       NUMBER DEFAULT NULL;
      call_path    VARCHAR2(1);
      orig_pidm    spriden.spriden_pidm%TYPE;
      pass_dflt_ip VARCHAR2(1) DEFAULT 'N';
      hold_term    stvterm.stvterm_code%TYPE;
      XSLTREPORT    BOOLEAN DEFAULT TRUE ;    --  JDH TEST
      NL              VARCHAR2(1)  := CHR(10);        -- JDH
   BEGIN
      IF NOT twbkwbis.f_validuser(global_pidm) THEN
         RETURN;
      END IF;
      uFile := UTL_FILE.FOPEN( '/jobsub', OutputFile, 'w' );   -- JDH      

      -- Check if procedure is being run from facweb or stuweb.
      -- If stuweb, then use the pidm of the user. Else, use
      -- the pidm that corresponds to the student that was
      -- specified by the user.
      -- ==================================================
      IF nvl(twbkwbis.f_getparam(global_pidm, 'STUFAC_IND'), 'STU') = 'FAC' THEN
         orig_pidm := global_pidm;
         pidm      := to_number(twbkwbis.f_getparam(global_pidm, 'STUPIDM'),
                                '999999999');
         call_path := 'F';
      ELSE
         call_path := 'S';
         pidm      := global_pidm;
         orig_pidm := global_pidm;
      END IF;
       UTL_FILE.PUT_LINE(uFile,'start submit ');   -- JDH
--      dbms_output.put_line('start submit ');
--  htp.p('<p>Running submit p1</p>');
      -- Error checking variable is sf_status.
      -- Numbers 0 - 50 will be reserved for technical error messages; database
      -- pipes, inserts, max extents, et ceterea.
      -- Number 51 - 100 will be reserved for invalid curriculum messages;
      -- no major entered, invalid program, et cetera.
      -- Not all error numbers are set nor are according error messages; future use.

      IF program IS NULL THEN
         sf_status := 51;
         twbkwbis.p_metaforward('bwckcapp.P_DispEvalTerm?sf_status=' ||
                                sf_status);
      END IF;
--htp.p('<p>Running submit p2</p>');
--      dbms_output.put_line('run submit 2');
       UTL_FILE.PUT_LINE(uFile,'running submit 2');   -- JDH

      IF eval_term IS NULL THEN
         sf_status := 54;
         twbkwbis.p_metaforward('bwckcapp.P_DispEvalTerm?sf_status=' ||
                                sf_status);
      END IF;

      IF sf_status <> 0 THEN
         twbkwbis.p_metaforward('bwckcapp.P_DispEvalTerm?sf_status=' ||
                                sf_status);
      ELSE
         sf_status  := 0;
         request_no := 0;
         -------------------------------------
         -- Logic for determining value of
         -- In-progess course usage flag.
         --
         -- 1) Set pass_dflt_ip to actual
         --    smbdflt_use_ip_crse_ind value
         --    based upon f_smbdflt_ip_crse_ind.
         --
         -- 2) f_smbdflt_ip_crse_ind is used
         --    as the value unless two values
         --    send in for the checkbox
         --    1) dummy - always sent in (actual dflt value )
         --    2) Checkbox = YES
         --
         --   The only time that f_smbdflt_use_ip_crse
         --   would equal = 'N' for this array is when
         --   smbdflt_ip_crse_ind = 'Y' , Overrides by
         --   faculty are allowed, and user overrode
         --   the IP setting to 'No'.  This is capture
         --   in the first logic step #1.
         --   All other values would equate to 'Y', which
         --   is denoted in step #2.

         pass_dflt_ip := f_smbdflt_ip_crse_ind;
--htp.p('<p>Running submit p3</p>');
--      dbms_output.put_line('run submit 3');
       UTL_FILE.PUT_LINE(uFile,'running submit 3');   -- JDH

         -- Step #1
         IF call_path = 'F' THEN
            hold_term := twbkwbis.f_getparam(orig_pidm, 'TERM');

            IF f_smbwcrl_ip_ovrd_flg(hold_term) THEN
               IF f_smbdflt_ip_crse_ind = 'Y' THEN
                  IF dflt_ip.COUNT = 1 THEN
                     pass_dflt_ip := 'N';
                  END IF;
               END IF; -- smbdflt_ip
            END IF; -- override
         END IF; -- call_path

         -- Step #2
         FOR j IN 2 .. nvl(dflt_ip.LAST, 0)
         LOOP
            IF dflt_ip.EXISTS(j) THEN
               pass_dflt_ip := 'Y';
            END IF;
         END LOOP;
--htp.p('<p>Running submit p4 ' || source1 || '</p>');
--      dbms_output.put_line('run submit 4:' || source1);
       UTL_FILE.PUT_LINE(uFile,'running submit 4' || source1);   -- JDH

         --
         --  End logic for determining smbdflt_use_ip_crse_ind
         --
         -------------------------------------
         IF source1 <>'sgbstdn' THEN
	         bwckcmpl.p_do_capp(pidm,
	                            orig_pidm,
	                            source1,
	                            program,
	                            ctlg_term,
	                            eval_term,
	                            pass_dflt_ip,
	                            request_no,
	                            sf_status);
          ELSE
	          bwckcmpl.p_do_capp(pidm,
	                            orig_pidm,
	                            source1,
	                            program,
	                            SUBSTR(program,2,6),
	                            eval_term,
	                            pass_dflt_ip,
	                            request_no,
	                            sf_status);
          END IF;
          
--htp.p('<p>Running submit p4 ' || sf_status || '</p>');
       UTL_FILE.PUT_LINE(uFile,'running submit 5:' || sf_status);   -- JDH

         IF sf_status = 0 THEN
            -- This means pipes are down.
            twbkwbis.p_metaforward('bwckcapp.P_DispEvalTerm?sf_status=0');
         END IF;

         IF sf_status = 1 THEN
            -- This means CAPP ran to completion.
            -- 8.2 CAPP XML
            IF XSLTREPORT THEN
       UTL_FILE.PUT_LINE(uFile,'running submit XML:' || sf_status);   -- JDH
               bwcksxml.report(request_no);
            ELSE
       UTL_FILE.PUT_LINE(uFile,'running submit view:' || sf_status);   -- JDH
               bwckcapp.p_dispevalviewoption(request_no);
            END IF;
         END IF;

      UTL_FILE.FCLOSE( uFile );    --  JDH        
         IF sf_status > 1 THEN
            --    This is where sf_status > 1 returned from the sfkpipe
            --    could determine the error message sent back to the
            --    submitting page.  For example, one could customize
            --    bwckcmpl.p_do_capp so that if there was a max extent(?),
            --    one would assign sf_status to a number 0-50, and return
            --    that value to this package.  Then, bwckcap1.P_DispEvalTerm
            --    would be modified such that if sf_status = 'X', then
            --    the error message would be "Max Extents" or "could not save request".

            twbkwbis.p_metaforward('bwckcapp.P_DispEvalTerm?sf_status=' ||
                                   sf_status);
         END IF;
      END IF;
   END p_submit;

   ----------------------------------------------------------------------------
   --
   -- This procedure displays a web page so that end user
   -- can choose which display type they prefer to view.
   --

   PROCEDURE p_dispevalviewoption(request_no IN smrrqcm.smrrqcm_request_no%TYPE DEFAULT NULL) IS
      req_no           NUMBER;
      call_path        VARCHAR2(1);
      pidm             spriden.spriden_pidm%TYPE;
      global_pidm      spriden.spriden_pidm%TYPE;
      printer_friendly VARCHAR2(1) DEFAULT 'N';
      hold_term        stvterm.stvterm_code%TYPE;
      smrcprt_row      smrcprt%ROWTYPE;
      use_hardcopy     BOOLEAN DEFAULT FALSE;
      page3_prnt_ind   BOOLEAN DEFAULT FALSE;

      TYPE sprhold_cmplc_type IS RECORD(
         hold_cmpl stvhldd.stvhldd_compliance_hold_ind%TYPE);

      sprhold_cmplc_rec sprhold_cmplc_type; -- Hold row.
   BEGIN
      -- Validate the current user.
      -- ====================================================
      -- Check if procedure is being run from facweb or stuweb.
      -- If stuweb, then use the pidm of the user. Else, use
      -- the pidm that corresponds to the student that was
      -- specified by the user.
      -- ==================================================
      IF NOT twbkwbis.f_validuser(global_pidm) THEN
         RETURN;
      END IF;

      IF nvl(twbkwbis.f_getparam(global_pidm, 'STUFAC_IND'), 'STU') = 'FAC' THEN
         pidm      := to_number(twbkwbis.f_getparam(global_pidm, 'STUPIDM'),
                                '999999999');
         call_path := 'F';
         hold_term := twbkwbis.f_getparam(global_pidm, 'TERM');
      ELSE
         call_path := 'S';
         pidm      := global_pidm;
         hold_term := twbkwbis.f_getparam(pidm, 'TERM');
      END IF;

      OPEN sprhold_cmpl_c(pidm);
      FETCH sprhold_cmpl_c
         INTO sprhold_cmplc_rec;

      -- Initialize web page for facweb.
      -- ==================================================
      IF nvl(twbkwbis.f_getparam(global_pidm, 'STUFAC_IND'), 'STU') = 'FAC' THEN

         -- Format student name.
         -- ==================================================
         student_name := f_format_name(pidm, 'FMIL');
         bwckfrmt.p_open_doc('bwckcapp.P_DispEvalViewOption');

         -- Check if student is confidential.
         -- ==================================================
         bwcklibs.p_confidstudinfo(pidm, hold_term);

         htp.formopen('bwckcapp.P_VerifyDispEvalViewOption');

         IF sprhold_cmpl_c%FOUND THEN
            twbkwbis.p_dispinfo('bwckcapp.P_DispCurrent', 'FACHOLD');
         END IF;

         twbkwbis.p_dispinfo('bwckcapp.P_DispEvalViewOption', 'DEFAULT');
         -- Initialize web page for stuweb.
         -- ==================================================
      ELSE
         bwckfrmt.p_open_doc('bwckcapp.P_DispEvalViewOption');
         htp.formopen('bwckcapp.P_VerifyDispEvalViewOption');

         IF sprhold_cmpl_c%FOUND THEN
            twbkwbis.p_dispinfo('bwckcapp.P_DispCurrent', 'STUHOLD');
         ELSE
            twbkwbis.p_dispinfo('bwckcapp.P_DispEvalViewOption', 'DEFAULT');
         END IF;
      END IF;

      IF (call_path = 'S') AND (sprhold_cmpl_c%FOUND) THEN
         NULL;
         -- If student user and holds exist, do not display
         -- any information(null).
      ELSE
         /* This means they generated a new capp request, get the highest number */
         IF request_no IS NOT NULL THEN
            req_no := request_no;
         END IF;

         OPEN smbwcrl_c(hold_term);
         FETCH smbwcrl_c
            INTO smbwcrl_row;
         CLOSE smbwcrl_c;

         -- If using a compliance type to build evaluation output,
         -- get this data now.

         IF smbwcrl_row.smbwcrl_dflt_eval_cprt_code IS NOT NULL THEN
            OPEN smrcprt_c(smbwcrl_row.smbwcrl_dflt_eval_cprt_code);
            FETCH smrcprt_c
               INTO smrcprt_row;
            CLOSE smrcprt_c;
            use_hardcopy := TRUE;

            IF smrcprt_row.smrcprt_page3_prt_ind = 'Y' THEN
               page3_prnt_ind := TRUE;
            END IF;
         END IF;

         twbkfrmt.P_FormHidden('request_no', req_no);
         htp.formradio('program_summary',
                       '1',
                       'CHECKED',
                       cattributes => ' ID = "program_summary_id1"');
         twbkfrmt.p_printtext(twbkfrmt.f_formlabel(g$_nls.get('BWCKCAP1-0026',
                                                              'SQL',
                                                              'General Requirements'),
                                                   idname => 'program_summary_id1'));
         htp.br;
         htp.formradio('program_summary',
                       '3',
                       cattributes => ' ID="program_summary_id3"');
         twbkfrmt.p_printtext(twbkfrmt.f_formlabel(g$_nls.get('BWCKCAP1-0027',
                                                              'SQL',
                                                              'Detail Requirements'),
                                                   idname => 'program_summary_id3'));
         htp.br;

         --
         -- The only time we would NOT display
         -- the 3rd page is when one is using a compliance
         -- type to build output(use_hardcopy), AND the compliance type
         -- rules specifically state do not build the third page(page3_prnt_ind).
         -- Otherwise, display this as a choice for output.
         --

         IF use_hardcopy THEN
            IF page3_prnt_ind THEN
               htp.formradio('program_summary',
                             '2',
                             cattributes => ' ID="program_summary_id2"');
               twbkfrmt.p_printtext(twbkfrmt.f_formlabel(g$_nls.get('BWCKCAP1-0028',
                                                                    'SQL',
                                                                    'Additional Information'),
                                                         idname => 'program_summary_id2'));
            END IF;
         ELSE
            htp.formradio('program_summary',
                          '2',
                          cattributes => ' ID="program_summary_id2"');
            twbkfrmt.p_printtext(twbkfrmt.f_formlabel(g$_nls.get('BWCKCAP1-0029',
                                                                 'SQL',
                                                                 'Additional Information'),
                                                      idname => 'program_summary_id2'));
         END IF;

         htp.br;
         htp.br;
         htp.formsubmit(NULL, g$_nls.get('BWCKCAP1-0030', 'SQL', 'Submit'));
         htp.formclose;
      END IF; -- End holds.

      CLOSE sprhold_cmpl_c;
      twbkwbis.p_closedoc(curr_release);
   END p_dispevalviewoption;

   ----------------------------------------------------------------------------
   --
   -- This procedure used for accepting parameters that were submitted on
   -- web page P_DispEvalViewOption, and redirecting them to the display
   -- pages.
   --

   PROCEDURE p_verifydispevalviewoption(request_no       IN OUT smrrqcm.smrrqcm_request_no%TYPE,
                                        program_summary  IN VARCHAR2 DEFAULT NULL,
                                        printer_friendly IN VARCHAR2 DEFAULT 'N') IS
      call_path     VARCHAR2(1);
      pidm          spriden.spriden_pidm%TYPE;
      global_pidm   spriden.spriden_pidm%TYPE;
      tmp_prnt_frnd VARCHAR2(1) DEFAULT 'N';
      email         goremal.goremal_email_address%TYPE;
      namestr       VARCHAR2(90) DEFAULT NULL;
      advr_pidm     spriden.spriden_pidm%TYPE DEFAULT NULL;
      smbpogn_row   smbpogn%ROWTYPE;
      smbwcrl_row   smbwcrl%ROWTYPE;
      smrcprt_row   smrcprt%ROWTYPE;
   BEGIN
      -- Validate the current user.
      -- ====================================================
      -- Check if procedure is being run from facweb or stuweb.
      -- If stuweb, then use the pidm of the user. Else, use
      -- the pidm that corresponds to the student that was
      -- specified by the user.
      -- ==================================================
      IF NOT twbkwbis.f_validuser(global_pidm) THEN
         RETURN;
      END IF;

      IF nvl(twbkwbis.f_getparam(global_pidm, 'STUFAC_IND'), 'STU') = 'FAC' THEN
         pidm      := to_number(twbkwbis.f_getparam(global_pidm, 'STUPIDM'),
                                '999999999');
         call_path := 'F';
      ELSE
         call_path := 'S';
         pidm      := global_pidm;
      END IF;

      IF printer_friendly = 'N' THEN
         tmp_prnt_frnd := 'N';
      ELSE
         tmp_prnt_frnd := 'Y';
      END IF;

      IF program_summary = '1' THEN
         bwcksmlt.p_dispevalgeneralreq(request_no, printer_friendly);
      ELSIF program_summary = '2' THEN
         bwcksncr.p_dispevaladditional(request_no, tmp_prnt_frnd);
      ELSIF program_summary = '3' THEN
         bwcksmlt.p_dispevaldetailreq(request_no, tmp_prnt_frnd);
      ELSE
         RETURN;
      END IF;
   END p_verifydispevalviewoption;

   ----------------------------------------------------------------------------
   --
   -- Web Page.
   -- Procedure used to display web page;
   -- Displays student current curriculum enrollement
   -- based upon curriculum hierarchy in GTVSDAX.
   --

   PROCEDURE p_dispcurrent(term_in      IN VARCHAR2 DEFAULT NULL,
                           calling_proc IN VARCHAR2 DEFAULT NULL) IS
      term       smbpogn.smbpogn_term_code_eff%TYPE;
      email1     goremal.goremal_email_address%TYPE;
      namestr    VARCHAR2(90) DEFAULT NULL;
      rec_source smrrqcm.smrrqcm_orig_curr_source%TYPE DEFAULT NULL;
      request_no smrrqcm.smrrqcm_request_no%TYPE DEFAULT NULL;
      source1    VARCHAR2(8) DEFAULT NULL;
      pidm       spriden.spriden_pidm%TYPE;
      call_path  VARCHAR2(1);
      advr_pidm  spriden.spriden_pidm%TYPE DEFAULT NULL;
      stu_exist  BOOLEAN DEFAULT FALSE;
      his_exist  BOOLEAN DEFAULT FALSE;
      rec_exist  BOOLEAN DEFAULT FALSE;
      adm_exist  BOOLEAN DEFAULT FALSE;
      no_curric  BOOLEAN DEFAULT FALSE;
      config_err BOOLEAN DEFAULT FALSE;
      disp_secd  BOOLEAN DEFAULT FALSE;
      hold_term  stvterm.stvterm_code%TYPE DEFAULT NULL;

      --
      -- 5.4. Datatype for holds functionality.
      --
      TYPE sprhold_cmplc_type IS RECORD(
         hold_cmpl stvhldd.stvhldd_compliance_hold_ind%TYPE);

      sprhold_cmplc_rec sprhold_cmplc_type; -- Hold row.

   BEGIN
      IF NOT twbkwbis.f_validuser(global_pidm) THEN
         RETURN;
      END IF;

      --
      -- Check if procedure is being run from facweb or stuweb.
      -- If stuweb, then use the pidm of the user. Else, use
      -- the pidm that corresponds to the student that was
      -- specified by the user.
      -- ==================================================
      IF (nvl(twbkwbis.f_getparam(global_pidm, 'STUFAC_IND'), 'STU') ='FAC')
          AND (calling_proc = 'bwlkfcap.P_FacDispCurrent') THEN
         pidm      := to_number(twbkwbis.f_getparam(global_pidm, 'STUPIDM'),
                                '999999999');
         twbkwbis.p_setparam (global_pidm, 'STUFAC_IND', 'FAC');
         call_path := 'F';
      ELSE
         call_path := 'S';
         twbkwbis.p_setparam (global_pidm, 'STUFAC_IND', 'STU');
         pidm      := global_pidm;
      END IF;
      --
      --
      IF term_in IS NULL THEN
         hold_term := twbkwbis.f_getparam(pidm, 'TERM');
      ELSE
         twbkwbis.p_setparam(pidm, 'TERM', term_in);
         hold_term := term_in;
      END IF;

      -- Make sure a term has been selected
      IF hold_term IS NULL THEN
         bwckcapp.p_seldefterm(hold_term,
                               calling_proc_name => 'bwckcapp.P_DispCurrent');
         hold_term := twbkwbis.f_getparam(pidm, 'TERM');
         RETURN;
      END IF;

      --
      -- Initialize web page for facweb.
      -- ==================================================
      IF nvl(twbkwbis.f_getparam(global_pidm, 'STUFAC_IND'), 'STU') = 'FAC' THEN

         -- Format student name.
         -- ==================================================
         student_name := f_format_name(pidm, 'FMIL');
         bwckfrmt.p_open_doc('bwlkfcap.P_FacDispCurrent');

         -- Check if student is confidential.
         -- ==================================================
         bwcklibs.p_confidstudinfo(pidm, hold_term);
         htp.br;
         htp.formopen('bwckcapp.P_DispEvalViewOption');
         -- Initialize web page for stuweb.
         -- ==================================================
      ELSE
         bwckfrmt.p_open_doc('bwckcapp.P_DispCurrent');
         htp.formopen('bwckcapp.P_DispEvalViewOption');
      END IF;

      --
      -- Check for holds.
      -- ===================================================

      OPEN sprhold_cmpl_c(pidm);
      FETCH sprhold_cmpl_c
         INTO sprhold_cmplc_rec;

      IF sprhold_cmpl_c%FOUND THEN
         IF call_path = 'S' THEN
            twbkwbis.p_dispinfo('bwckcapp.P_DispCurrent', 'STUHOLD');
         ELSIF call_path = 'F' THEN
            twbkwbis.p_dispinfo('bwckcapp.P_DispCurrent', 'FACHOLD');
         END IF;
      END IF;

      IF (call_path = 'S') AND (sprhold_cmpl_c%FOUND) THEN
         NULL;
         -- If student user and holds exist, do not display
         -- any information(null).
      ELSE
         --
         -- Get values from SMAWCRL/SMBWCRL
         --
         OPEN smbwcrl_c(hold_term);
         FETCH smbwcrl_c
            INTO smbwcrl_row;
         CLOSE smbwcrl_c;

         IF smbwcrl_row.smbwcrl_disp_second_curr_ind = 'Y' THEN
            disp_secd := TRUE;
         ELSE
            disp_secd := FALSE;
         END IF;

         twbkfrmt.P_FormHidden('pidm', pidm);
      

         stu_exist := f_test_sgbstdn_exist(pidm, hold_term);
         his_exist := f_test_shrdgmr_exist(pidm, hold_term);
         rec_exist := f_test_srbrecr_exist(pidm, hold_term);
         adm_exist := f_test_saradap_exist(pidm, hold_term);
       
   

         source1   := f_get_mtch_curric_heir(pidm,
                                             stu_exist,
                                             his_exist,
                                             rec_exist,
                                             adm_exist);
         IF source1 IS NULL THEN
            config_err := f_gtvsdax_webcurr_exist(1);

            IF config_err = FALSE THEN
               no_curric := TRUE;
            END IF;
         END IF;

         IF config_err = TRUE THEN
            twbkwbis.p_dispinfo('bwckcapp.P_DispCurrent', 'CONFIG');
         END IF;

         IF no_curric = TRUE THEN
            twbkwbis.p_dispinfo('bwckcapp.P_DispCurrent', 'NOCUR');
         END IF;
         
         IF config_err = FALSE THEN
            IF no_curric = FALSE THEN
               twbkwbis.p_dispinfo('bwckcapp.P_DispCurrent', 'DEFAULT');             
               IF source1 = 'sgbstdn' THEN
                  p_dispcursourcesgbstdn(pidm, source1, disp_secd, hold_term, term);
               END IF;
               
               IF source1 = 'saradap' THEN
                  p_dispcursourcesaradap(pidm, source1, disp_secd, hold_term, term);
               END IF;

               IF source1 = 'shrdgmr' THEN
                  p_dispcursourceshrdgmr(pidm, source1, disp_secd, hold_term, term);
               END IF;

               IF source1 = 'srbrecr' THEN
                  p_dispcursourcesrbrecr(pidm, source1, disp_secd, hold_term, term);
               END IF;
            END IF;
         END IF;

         IF call_path = 'S' THEN
            advr_pidm := f_getadvrpidm(pidm, hold_term);
            email1    := f_getemailaddress(advr_pidm,
                                           smbwcrl_row.smbwcrl_fac_email_code);

            IF email1 IS NOT NULL THEN
               namestr := f_getemailnamestr(advr_pidm);
               htp.br;

               IF namestr IS NOT NULL THEN
                  twbkwbis.p_dispinfo('bwckcapp.P_DispCurrent',
                                      'EMAIL',
                                      value1 => email1,
                                      value2 => namestr);
               END IF;
            END IF;
         END IF;

         IF call_path = 'F' THEN
            email1 := f_getemailaddress(pidm,
                                        smbwcrl_row.smbwcrl_stu_email_code);

            IF email1 IS NOT NULL THEN
               htp.br;
               twbkwbis.p_dispinfo('bwlkfcap.P_FacDispCurrent',
                                   'EMAIL',
                                   value1 => email1,
                                   value2 => student_name);
            END IF;
         END IF;
      END IF; -- End holds.

      CLOSE sprhold_cmpl_c;
      htp.formclose;
      twbkwbis.p_closedoc(curr_release);
   END p_dispcurrent;

   ----------------------------------------------------------------------------
PROCEDURE p_dispcursourcesgbstdn(pidm      IN spriden.spriden_pidm%TYPE DEFAULT NULL,
                                 source1   IN VARCHAR2 DEFAULT NULL,
                                 disp_secd IN BOOLEAN DEFAULT FALSE,
                                 p_term_in IN STVTERM.STVTERM_CODE%TYPE,
                                 term      OUT stvterm.stvterm_code%TYPE) IS
    program    smrrqcm.smrrqcm_program%TYPE DEFAULT NULL;
    request_no smrrqcm.smrrqcm_request_no%TYPE DEFAULT NULL;
    table_open BOOLEAN DEFAULT FALSE;
    disp_curr  BOOLEAN DEFAULT FALSE;
    seq_no     sorlcur.sorlcur_key_seqno%TYPE DEFAULT 99;
    lv_lmod_code stvlmod.stvlmod_code%TYPE := sb_curriculum_str.f_learner;
    lv_seqno sorlcur.sorlcur_seqno%TYPE;
    lv_levl sorlcur.sorlcur_levl_code%TYPE;
    lv_coll sorlcur.sorlcur_coll_code%TYPE;
    lv_camp sorlcur.sorlcur_camp_code%TYPE;
    lv_degc sorlcur.sorlcur_degc_code%TYPE;
    lv_program sorlcur.sorlcur_program%TYPE;
    lv_term_ctlg stvterm.stvterm_code%TYPE;
    lv_term_admit stvterm.stvterm_code%TYPE;
    lv_term_matric stvterm.stvterm_code%TYPE;
    lv_admt sorlcur.sorlcur_admt_code%TYPE;
    lv_roll_ind sovlcur.sovlcur_roll_ind%TYPE;
    lv_rule sorlcur.sorlcur_curr_rule%TYPE;
    lv_majr sovlfos.sovlfos_majr_code%TYPE;
    lv_term_end stvterm.stvterm_code%TYPE;
    lv_dept sovlfos.sovlfos_dept_code%TYPE;
    lv_concrule sorlfos.sorlfos_conc_attach_rule%TYPE;
    lv_lfosrule sovlfos.sovlfos_lfos_rule%TYPE;
    lv_lfosseqno sovlfos.sovlfos_seqno%TYPE;
    lv_lfosseqno2 sovlfos.sovlfos_seqno%TYPE;
    lv_startdate DATE;
    lv_enddate DATE;
    lv_majr_attach stvmajr.stvmajr_code%TYPE;
    lv_rolledseqno sorlfos.sorlfos_rolled_seqno%TYPE;
    lv_tmstcode sorlfos.sorlfos_tmst_code%TYPE;
    lv_majr_1 sovlfos.sovlfos_majr_code%TYPE;
    lv_majr_2 sovlfos.sovlfos_majr_code%TYPE;
    lv_majr_3 sovlfos.sovlfos_majr_code%TYPE;
    hold_term   stvterm.stvterm_code%TYPE;     
    sgbstdn_row sgbstdn_disp_prim_p2_c%ROWTYPE;
    lv_lcurAdmtCount        NUMBER(4):=NULL;
    lv_lcurRecrCount        NUMBER(4):=NULL;
    lv_lcurOutcCount        NUMBER(4):=NULL;
    lv_lcurLrnrCount        NUMBER(4):=NULL;
    lv_majr_max     NUMBER:=NULL;
    lv_minr_max     NUMBER:=NULL;
    lv_conc_max     NUMBER:=NULL;    
    limit                   NUMBER(1):=1;
    hold_sec_term   stvterm.stvterm_code%TYPE; 
    hold_one_term   stvterm.stvterm_code%TYPE;
    split_cur       VARCHAR2(1):='Y';
    bypass_i        VARCHAR2(1):='N';
BEGIN
      hold_one_term := P_term_in;
      FOR sgbstdn_row IN sgbstdn_disp_prim_p2_c(pidm, p_term_in)
      LOOP
         EXIT WHEN sgbstdn_disp_prim_p2_c%NOTFOUND;
         soklcur.p_create_sotvcur(p_pidm => pidm,
           p_lmod_code => sb_curriculum_str.f_learner,
           p_term_code => sgbstdn_row.sgbstdn_term_code_eff );
          
  
	          	seq_no := 99;
         	    sokccur.p_get_curricula_data( p_pidm  => pidm,
						   p_term  => p_term_in,
						   p_lmod  => lv_lmod_code,
						   p_key_seqno => seq_no);
	          sokccur.p_number_of_lcur (    p_term       =>  p_term_in,
						    p_lcurAdmtCount  =>  lv_lcurAdmtCount,
					  	  p_lcurRecrCount  =>  lv_lcurRecrCount,
						    p_lcurOutcCount  =>  lv_lcurOutcCount,
					  	  p_lcurLrnrCount  =>  lv_lcurLrnrCount);      
	 

            IF (disp_secd = FALSE or lv_lcurLrnrCount = 1) THEN
               limit := 1;
            ELSE 
               limit := 2;            
            END IF;
                               

            FOR i IN 1..NVL (limit, 0)
            LOOP 
            sokccur.p_parse_lcur_data(p_lmod        => lv_lmod_code,
                                      p_term        => p_term_in,
                                      p_lcurindex   => i,
                                      p_seqno       => lv_seqno,
                                      p_levl        => lv_levl,
                                      p_coll_code   => lv_coll,
                                      p_camp_code   => lv_camp,
                                      p_degc_code   => lv_degc,
                                      p_program     => lv_program,
                                      p_term_ctlg   => lv_term_ctlg,
                                      p_term_admit  => lv_term_admit,
                                      p_term_matric => lv_term_matric,
                                      p_admt_code   => lv_admt,
                                      p_roll_ind    => lv_roll_ind,
                                      p_lcur_rule   => lv_rule);    
            -- Assign the out parameters value to variables
            request_no := f_getmaxreqnocomplete(pidm, lv_program, source1);
            program := lv_program;
             IF (i=2 and  lv_program IS NOT NULL) 
                THEN 
                  split_cur := 'N';
             END IF;
            
            IF f_prog_web_ind(lv_program) THEN
                IF NOT table_open OR NOT disp_curr THEN
                    twbkfrmt.p_tableopen('NONTABULAR',
                                         cattributes => g$_nls.get('BWCKCAP1-0031',
                                                                   'SQL',
                                                                   'summary="This table will display curriculum information."'),
                                         ccaption => g$_nls.get('BWCKCAP1-0032',
                                                                'SQL',
                                                                'Curriculum Information'));
                    table_open := TRUE;
                    disp_curr  := TRUE;
                END IF;

                IF i = 1 THEN
                   lbl_header_alt:= 'Primary Curriculum';
                ELSIF i = 2 THEN
                   lbl_header_alt:= 'Secondary Curriculum';
                END IF;

                IF (i=1   ) OR 
                   ((i=2 and   split_cur = 'N') OR
                    (i=2 and    split_cur = 'Y'))
                THEN
                p_dispcurrent_table(lbl_header_alt,
                                    lv_program,
                                    request_no,
                                    lv_term_ctlg,
                                    lv_levl,
                                    lv_camp,
                                    lv_coll,
                                    lv_degc);
                twbkfrmt.p_tablerowopen;
                twbkfrmt.p_tabledata('&nbsp;');
                twbkfrmt.p_tablerowclose;
                --1-983E4U
                hold_term := lv_term_ctlg;
            
                FOR k in 1 .. 3 loop
                
                    sokccur.p_parse_lfos_data(p_lmod             => lv_lmod_code,
                                              p_term             => hold_term,
                                              p_seqno            => lv_seqno,
                                              p_lcurindex        => i,
                                              p_lfosindex        => 1,
                                              p_concindex        => k,
                                              p_lfstcode         => sb_fieldofstudy_str.f_concentration,
                                              p_majr_code        => lv_majr,
                                              p_term_code_ctlg   => lv_term_ctlg,
                                              p_term_code_end    => lv_term_end,
                                              p_dept_code        => lv_dept,
                                              p_lfos_rule        => lv_lfosrule,
                                              p_lfosseqno        => lv_lfosseqno2,
                                              p_conc_attach_rule => lv_concrule,
                                              p_start_date       => lv_startdate,
                                              p_end_date         => lv_enddate,
                                              p_tmst_code        => lv_tmstcode,
                                              p_rolled_seqno     => lv_rolledseqno,
                                              p_majr_code_attach => lv_majr_attach);
                
                    IF k = 1 THEN
                        lv_majr_1 := lv_majr;
                    ELSIF k = 2 THEN
                        lv_majr_2 := lv_majr;
                    ELSIF k = 3 THEN
                        lv_majr_3 := lv_majr;
                    END IF;
                
                END LOOP;
            
                sokccur.p_parse_lfos_data(p_lmod             => lv_lmod_code,
                                          p_term             => hold_term,
                                          p_seqno            => lv_seqno,
                                          p_lcurindex        => i,
                                          p_lfosindex        => 1,
                                          p_concindex        => NULL,
                                          p_lfstcode         => sb_fieldofstudy_str.f_major,
                                          p_majr_code        => lv_majr,
                                          p_term_code_ctlg   => lv_term_ctlg,
                                          p_term_code_end    => lv_term_end,
                                          p_dept_code        => lv_dept,
                                          p_lfos_rule        => lv_lfosrule,
                                          p_lfosseqno        => lv_lfosseqno,
                                          p_conc_attach_rule => lv_concrule,
                                          p_start_date       => lv_startdate,
                                          p_end_date         => lv_enddate,
                                          p_tmst_code        => lv_tmstcode,
                                          p_rolled_seqno     => lv_rolledseqno,
                                          p_majr_code_attach => lv_majr_attach);
              
                p_dispcurrent_major1_format(lv_majr,
                                            lv_majr_1,
                                            lv_dept,
                                            lv_majr_2,
                                            lv_majr_3);
            
                -- If there is no information for these fields, do not display the table.
            
                FOR k in 1 .. 3 loop
                
                    sokccur.p_parse_lfos_data(p_lmod             => lv_lmod_code,
                                              p_term             => hold_term,
                                              p_seqno            => lv_seqno,
                                              p_lcurindex        => i,
                                              p_lfosindex        => 2,
                                              p_concindex        => k,
                                              p_lfstcode         => sb_fieldofstudy_str.f_concentration,
                                              p_majr_code        => lv_majr,
                                              p_term_code_ctlg   => lv_term_ctlg,
                                              p_term_code_end    => lv_term_end,
                                              p_dept_code        => lv_dept,
                                              p_lfos_rule        => lv_lfosrule,
                                              p_lfosseqno        => lv_lfosseqno2,
                                              p_conc_attach_rule => lv_concrule,
                                              p_start_date       => lv_startdate,
                                              p_end_date         => lv_enddate,
                                              p_tmst_code        => lv_tmstcode,
                                              p_rolled_seqno     => lv_rolledseqno,
                                              p_majr_code_attach => lv_majr_attach);
                
                    IF k = 1 THEN
                        lv_majr_1 := lv_majr;
                    ELSIF k = 2 THEN
                        lv_majr_2 := lv_majr;
                    ELSIF k = 3 THEN
                        lv_majr_3 := lv_majr;
                    END IF;
                
                END LOOP;
            
                sokccur.p_parse_lfos_data(p_lmod             => lv_lmod_code,
                                          p_term             => hold_term,
                                          p_seqno            => lv_seqno,
                                          p_lcurindex        => i,
                                          p_lfosindex        => 2,
                                          p_concindex        => NULL,
                                          p_lfstcode         => sb_fieldofstudy_str.f_major,
                                          p_majr_code        => lv_majr,
                                          p_term_code_ctlg   => lv_term_ctlg,
                                          p_term_code_end    => lv_term_end,
                                          p_dept_code        => lv_dept,
                                          p_lfos_rule        => lv_lfosrule,
                                          p_lfosseqno        => lv_lfosseqno,
                                          p_conc_attach_rule => lv_concrule,
                                          p_start_date       => lv_startdate,
                                          p_end_date         => lv_enddate,
                                          p_tmst_code        => lv_tmstcode,
                                          p_rolled_seqno     => lv_rolledseqno,
                                          p_majr_code_attach => lv_majr_attach);
            
                IF f_display_major_table(lv_majr,
                                         lv_majr_1,
                                         lv_dept,
                                         lv_majr_2,
                                         lv_majr_3) THEN
                    twbkfrmt.p_tablerowopen;
                    twbkfrmt.p_tabledata('&nbsp;');
                    twbkfrmt.p_tablerowclose;
                
                    p_dispcurrent_major2_format(lv_majr,
                                                lv_majr_1,
                                                lv_dept,
                                                lv_majr_2,
                                                lv_majr_3);
                END IF;
            
                FOR j in 1 .. 2 loop
                    sokccur.p_parse_lfos_data(p_lmod             => lv_lmod_code,
                                              p_term             => hold_term,
                                              p_seqno            => lv_seqno,
                                              p_lcurindex        => i,
                                              p_lfosindex        => j,
                                              p_concindex        => NULL,
                                              p_lfstcode         => sb_fieldofstudy_str.f_minor,
                                              p_majr_code        => lv_majr,
                                              p_term_code_ctlg   => lv_term_ctlg,
                                              p_term_code_end    => lv_term_end,
                                              p_dept_code        => lv_dept,
                                              p_lfos_rule        => lv_lfosrule,
                                              p_lfosseqno        => lv_lfosseqno,
                                              p_conc_attach_rule => lv_concrule,
                                              p_start_date       => lv_startdate,
                                              p_end_date         => lv_enddate,
                                              p_tmst_code        => lv_tmstcode,
                                              p_rolled_seqno     => lv_rolledseqno,
                                              p_majr_code_attach => lv_majr_attach);
                
                    IF j = 1 THEN
                        lv_majr_1 := lv_majr; 
                    ELSIF j = 2 THEN
                        lv_majr_2 := lv_majr;
                    END IF;
                END LOOP;
            
                -- If there is no information for these fields, do not display table.
            
                IF f_display_minor_table(lv_majr_1, lv_majr_2) THEN
                    twbkfrmt.p_tablerowopen;
                    twbkfrmt.p_tabledata('&nbsp;');
                    twbkfrmt.p_tablerowclose;                
                    p_dispcurrent_minor_format(lv_majr_1, lv_majr_2);
                END IF;
            
                IF (disp_secd = TRUE) AND (disp_curr = TRUE) THEN
                    twbkfrmt.p_tablerowopen;
                    twbkfrmt.p_tabledata('&nbsp;');
                    twbkfrmt.p_tablerowclose;
                END IF;
                END IF;
            END IF;
        END LOOP;
        
        END LOOP;  
         IF NOT (disp_curr) THEN
            twbkwbis.p_dispinfo('bwckcapp.P_DispCurrent', 'NOCUR');
        ELSE
            twbkfrmt.p_tableclose;
        END IF;
        
    END p_dispcursourcesgbstdn;
   -------------------------------------------------------------------------
PROCEDURE p_dispcursourcesaradap(pidm      IN spriden.spriden_pidm%TYPE DEFAULT NULL,
                                 source1   IN VARCHAR2 DEFAULT NULL,
                                 disp_secd IN BOOLEAN DEFAULT FALSE,
                                 p_term_in IN STVTERM.STVTERM_CODE%TYPE,
                                 term      OUT stvterm.stvterm_code%TYPE) IS
    program    smrrqcm.smrrqcm_program%TYPE DEFAULT NULL;
    request_no smrrqcm.smrrqcm_request_no%TYPE DEFAULT NULL;
    table_open BOOLEAN DEFAULT FALSE;
    disp_curr  BOOLEAN DEFAULT FALSE;
    seq_no   sorlcur.sorlcur_key_seqno%TYPE ;
    lv_lmod_code stvlmod.stvlmod_code%TYPE := sb_curriculum_str.f_admissions;
    lv_seqno sorlcur.sorlcur_seqno%TYPE;
    lv_levl sorlcur.sorlcur_levl_code%TYPE;
    lv_coll sorlcur.sorlcur_coll_code%TYPE;
    lv_camp sorlcur.sorlcur_camp_code%TYPE;
    lv_degc sorlcur.sorlcur_degc_code%TYPE;
    lv_program sorlcur.sorlcur_program%TYPE;
    lv_term_ctlg stvterm.stvterm_code%TYPE;
    lv_term_admit stvterm.stvterm_code%TYPE;
    lv_term_matric stvterm.stvterm_code%TYPE;
    lv_admt sorlcur.sorlcur_admt_code%TYPE;
    lv_roll_ind sovlcur.sovlcur_roll_ind%TYPE;
    lv_rule sorlcur.sorlcur_curr_rule%TYPE;
    lv_majr sovlfos.sovlfos_majr_code%TYPE;
    lv_term_end stvterm.stvterm_code%TYPE;
    lv_dept sovlfos.sovlfos_dept_code%TYPE;
    lv_concrule sorlfos.sorlfos_conc_attach_rule%TYPE;
    lv_lfosrule sovlfos.sovlfos_lfos_rule%TYPE;
    lv_lfosseqno sovlfos.sovlfos_seqno%TYPE;
    lv_lfosseqno2 sovlfos.sovlfos_seqno%TYPE;
    lv_startdate DATE;
    lv_enddate DATE;
    lv_majr_attach stvmajr.stvmajr_code%TYPE;
    lv_rolledseqno sorlfos.sorlfos_rolled_seqno%TYPE;
    lv_tmstcode sorlfos.sorlfos_tmst_code%TYPE;
    lv_majr_1 sovlfos.sovlfos_majr_code%TYPE;
    lv_majr_2 sovlfos.sovlfos_majr_code%TYPE;
    lv_majr_3 sovlfos.sovlfos_majr_code%TYPE;
    hold_term   stvterm.stvterm_code%TYPE := p_term_in;
 
    lv_lcurAdmtCount        NUMBER(4):=NULL;
    lv_lcurRecrCount        NUMBER(4):=NULL;
    lv_lcurOutcCount        NUMBER(4):=NULL;
    lv_lcurLrnrCount        NUMBER(4):=NULL;
    limit                   NUMBER(1):=1;
BEGIN
     FOR saradap_row IN saradap_disp_prim_c(pidm, p_term_in)
      LOOP
         EXIT WHEN saradap_disp_prim_c%NOTFOUND;

 

       term := saradap_row.saradap_term_code_entry; ---- sorlcur_aro_rec.sovlcur_term_code; 

      -- set all variables from source to values that we'll need later
      -- on to pass to various functions/procedures
      seq_no     := saradap_row.saradap_appl_no;         
      hold_term  := term;
      
            sokccur.p_get_curricula_data( p_pidm  => pidm,
                                          p_term  => hold_term,
                                          p_lmod  => lv_lmod_code,
                                          p_key_seqno => seq_no);
            sokccur.p_number_of_lcur (    p_term       =>  hold_term,
                                   p_lcurAdmtCount  =>  lv_lcurAdmtCount,
                                   p_lcurRecrCount  =>  lv_lcurRecrCount,
                                   p_lcurOutcCount  =>  lv_lcurOutcCount,
                                   p_lcurLrnrCount  =>  lv_lcurLrnrCount);
            IF (disp_secd = FALSE) THEN
               limit := 1;
            ELSIF (lv_lcurAdmtCount<=1 )THEN
               limit := lv_lcurAdmtCount;
            ELSE
               limit := 2;
            END IF;

            FOR i IN 1..NVL (limit, 0)
            LOOP
            sokccur.p_parse_lcur_data(p_lmod        => lv_lmod_code,
                                      p_term        => hold_term,
                                      p_lcurindex   => i,
                                      p_seqno       => lv_seqno,
                                      p_levl        => lv_levl,
                                      p_coll_code   => lv_coll,
                                      p_camp_code   => lv_camp,
                                      p_degc_code   => lv_degc,
                                      p_program     => lv_program,
                                      p_term_ctlg   => lv_term_ctlg,
                                      p_term_admit  => lv_term_admit,
                                      p_term_matric => lv_term_matric,
                                      p_admt_code   => lv_admt,
                                      p_roll_ind    => lv_roll_ind,
                                      p_lcur_rule   => lv_rule);
            -- Assign the out parameters value to variables
            program    := lv_program;
            request_no := f_getmaxreqnocomplete(pidm, program, source1);
            IF f_prog_web_ind(lv_program) THEN
                IF NOT table_open OR NOT disp_curr THEN
                    twbkfrmt.p_tableopen('NONTABULAR',
                                         cattributes => g$_nls.get('BWCKCAP1-0033',
                                                                   'SQL',
                                                                   'summary="This table will display curriculum information."'),
                                         ccaption => g$_nls.get('BWCKCAP1-0034',
                                                                'SQL',
                                                                'Curriculum Information'));
                    table_open := TRUE;
                    disp_curr  := TRUE;
                END IF;

                IF i = 1 THEN
                   lbl_header_alt:= 'Primary Curriculum';
                ELSIF i = 2 THEN
                   lbl_header_alt:= 'Secondary Curriculum';
                END IF;
            
                p_dispcurrent_table(lbl_header_alt,
                                    lv_program,
                                    request_no,
                                    lv_term_ctlg,
                                    lv_levl,
                                    lv_camp,
                                    lv_coll,
                                    lv_degc);
                twbkfrmt.p_tablerowopen;
                twbkfrmt.p_tabledata('&nbsp;');
                twbkfrmt.p_tablerowclose;
            
				--1-983E4U
                hold_term := lv_term_ctlg;
            
                FOR k in 1 .. 3 loop
                
                    sokccur.p_parse_lfos_data(p_lmod             => lv_lmod_code,
                                              p_term             => hold_term,
                                              p_seqno            => lv_seqno,
                                              p_lcurindex        => i,
                                              p_lfosindex        => 1,
                                              p_concindex        => k,
                                              p_lfstcode         => sb_fieldofstudy_str.f_concentration,
                                              p_majr_code        => lv_majr,
                                              p_term_code_ctlg   => lv_term_ctlg,
                                              p_term_code_end    => lv_term_end,
                                              p_dept_code        => lv_dept,
                                              p_lfos_rule        => lv_lfosrule,
                                              p_lfosseqno        => lv_lfosseqno2,
                                              p_conc_attach_rule => lv_concrule,
                                              p_start_date       => lv_startdate,
                                              p_end_date         => lv_enddate,
                                              p_tmst_code        => lv_tmstcode,
                                              p_rolled_seqno     => lv_rolledseqno,
                                              p_majr_code_attach => lv_majr_attach);
                
                    IF k = 1 THEN
                        lv_majr_1 := lv_majr;
                    ELSIF k = 2 THEN
                        lv_majr_2 := lv_majr;
                    ELSIF k = 3 THEN
                        lv_majr_3 := lv_majr;
                    END IF;
                
                END LOOP;
            
                sokccur.p_parse_lfos_data(p_lmod             => lv_lmod_code,
                                          p_term             => hold_term,
                                          p_seqno            => lv_seqno,
                                          p_lcurindex        => i,
                                          p_lfosindex        => 1,
                                          p_concindex        => NULL,
                                          p_lfstcode         => sb_fieldofstudy_str.f_major,
                                          p_majr_code        => lv_majr,
                                          p_term_code_ctlg   => lv_term_ctlg,
                                          p_term_code_end    => lv_term_end,
                                          p_dept_code        => lv_dept,
                                          p_lfos_rule        => lv_lfosrule,
                                          p_lfosseqno        => lv_lfosseqno,
                                          p_conc_attach_rule => lv_concrule,
                                          p_start_date       => lv_startdate,
                                          p_end_date         => lv_enddate,
                                          p_tmst_code        => lv_tmstcode,
                                          p_rolled_seqno     => lv_rolledseqno,
                                          p_majr_code_attach => lv_majr_attach);
            
                p_dispcurrent_major1_format(lv_majr,
                                            lv_majr_1,
                                            lv_dept,
                                            lv_majr_2,
                                            lv_majr_3);
            
                -- If there is no information for these fields, do not display the table.
            
                FOR k in 1 .. 3 loop
                
                    sokccur.p_parse_lfos_data(p_lmod             => lv_lmod_code,
                                              p_term             => hold_term,
                                              p_seqno            => lv_seqno,
                                              p_lcurindex        => i,
                                              p_lfosindex        => 2,
                                              p_concindex        => k,
                                              p_lfstcode         => sb_fieldofstudy_str.f_concentration,
                                              p_majr_code        => lv_majr,
                                              p_term_code_ctlg   => lv_term_ctlg,
                                              p_term_code_end    => lv_term_end,
                                              p_dept_code        => lv_dept,
                                              p_lfos_rule        => lv_lfosrule,
                                              p_lfosseqno        => lv_lfosseqno2,
                                              p_conc_attach_rule => lv_concrule,
                                              p_start_date       => lv_startdate,
                                              p_end_date         => lv_enddate,
                                              p_tmst_code        => lv_tmstcode,
                                              p_rolled_seqno     => lv_rolledseqno,
                                              p_majr_code_attach => lv_majr_attach);
                
                    IF k = 1 THEN
                        lv_majr_1 := lv_majr;
                    ELSIF k = 2 THEN
                        lv_majr_2 := lv_majr;
                    ELSIF k = 3 THEN
                        lv_majr_3 := lv_majr;
                    END IF;
                
                END LOOP;
            
                sokccur.p_parse_lfos_data(p_lmod             => lv_lmod_code,
                                          p_term             => hold_term,
                                          p_seqno            => lv_seqno,
                                          p_lcurindex        => i,
                                          p_lfosindex        => 2,
                                          p_concindex        => NULL,
                                          p_lfstcode         => sb_fieldofstudy_str.f_major,
                                          p_majr_code        => lv_majr,
                                          p_term_code_ctlg   => lv_term_ctlg,
                                          p_term_code_end    => lv_term_end,
                                          p_dept_code        => lv_dept,
                                          p_lfos_rule        => lv_lfosrule,
                                          p_lfosseqno        => lv_lfosseqno,
                                          p_conc_attach_rule => lv_concrule,
                                          p_start_date       => lv_startdate,
                                          p_end_date         => lv_enddate,
                                          p_tmst_code        => lv_tmstcode,
                                          p_rolled_seqno     => lv_rolledseqno,
                                          p_majr_code_attach => lv_majr_attach);
            
                IF f_display_major_table(lv_majr,
                                         lv_majr_1,
                                         lv_dept,
                                         lv_majr_2,
                                         lv_majr_3) THEN
                    twbkfrmt.p_tablerowopen;
                    twbkfrmt.p_tabledata('&nbsp;');
                    twbkfrmt.p_tablerowclose;
                
                    p_dispcurrent_major2_format(lv_majr,
                                                lv_majr_1,
                                                lv_dept,
                                                lv_majr_2,
                                                lv_majr_3);
                END IF;
            
                FOR j in 1 .. 2 loop
                    sokccur.p_parse_lfos_data(p_lmod             => lv_lmod_code,
                                              p_term             => hold_term,
                                              p_seqno            => lv_seqno,
                                              p_lcurindex        => i,
                                              p_lfosindex        => j,
                                              p_concindex        => NULL,
                                              p_lfstcode         => sb_fieldofstudy_str.f_minor,
                                              p_majr_code        => lv_majr,
                                              p_term_code_ctlg   => lv_term_ctlg,
                                              p_term_code_end    => lv_term_end,
                                              p_dept_code        => lv_dept,
                                              p_lfos_rule        => lv_lfosrule,
                                              p_lfosseqno        => lv_lfosseqno,
                                              p_conc_attach_rule => lv_concrule,
                                              p_start_date       => lv_startdate,
                                              p_end_date         => lv_enddate,
                                              p_tmst_code        => lv_tmstcode,
                                              p_rolled_seqno     => lv_rolledseqno,
                                              p_majr_code_attach => lv_majr_attach);
                
                    IF j = 1 THEN
                        lv_majr_1 := lv_majr; 
                    ELSIF j = 2 THEN
                        lv_majr_2 := lv_majr;
                    END IF;
                
                END LOOP;
            
                -- If there is no information for these fields, do not display table.
            
                IF f_display_minor_table(lv_majr_1, lv_majr_2) THEN
                    twbkfrmt.p_tablerowopen;
                    twbkfrmt.p_tabledata('&nbsp;');
                    twbkfrmt.p_tablerowclose;                
                    p_dispcurrent_minor_format(lv_majr_1, lv_majr_2);
                END IF;
            
                IF (disp_curr = TRUE) THEN
                    twbkfrmt.p_tablerowopen;
                    twbkfrmt.p_tabledata('&nbsp;');
                    twbkfrmt.p_tablerowclose;
                END IF;
            END IF;
     
        END LOOP;
         
        IF NOT (disp_curr) THEN
            twbkwbis.p_dispinfo('bwckcapp.P_DispCurrent', 'NOCUR');
        ELSE
            twbkfrmt.p_tableclose;
            disp_curr  := FALSE;
        END IF;
        END LOOP;        
    END p_dispcursourcesaradap;
   -------------------------------------------------------------------------
PROCEDURE p_dispcursourceshrdgmr(pidm      IN spriden.spriden_pidm%TYPE DEFAULT NULL,
                                 source1   IN VARCHAR2 DEFAULT NULL,
                                 disp_secd IN BOOLEAN DEFAULT FALSE,
                                 p_term_in IN STVTERM.STVTERM_CODE%TYPE,
                                 term      OUT stvterm.stvterm_code%TYPE) IS
    program    smrrqcm.smrrqcm_program%TYPE DEFAULT NULL;
    request_no smrrqcm.smrrqcm_request_no%TYPE DEFAULT NULL;
    table_open BOOLEAN DEFAULT FALSE;
    disp_curr  BOOLEAN DEFAULT FALSE;
    seq_no  sorlcur.sorlcur_key_seqno%TYPE ;
    lv_lmod_code stvlmod.stvlmod_code%TYPE := sb_curriculum_str.f_outcome;
    lv_seqno sorlcur.sorlcur_seqno%TYPE;
    lv_levl sorlcur.sorlcur_levl_code%TYPE;
    lv_coll sorlcur.sorlcur_coll_code%TYPE;
    lv_camp sorlcur.sorlcur_camp_code%TYPE;
    lv_degc sorlcur.sorlcur_degc_code%TYPE;
    lv_program sorlcur.sorlcur_program%TYPE;
    lv_term_ctlg stvterm.stvterm_code%TYPE;
    lv_term_admit stvterm.stvterm_code%TYPE;
    lv_term_matric stvterm.stvterm_code%TYPE;
    lv_admt sorlcur.sorlcur_admt_code%TYPE;
    lv_roll_ind sovlcur.sovlcur_roll_ind%TYPE;
    lv_rule sorlcur.sorlcur_curr_rule%TYPE;
    lv_seqno2 sorlcur.sorlcur_seqno%TYPE;
    lv_levl2 sorlcur.sorlcur_levl_code%TYPE;
    lv_coll2 sorlcur.sorlcur_coll_code%TYPE;
    lv_camp2 sorlcur.sorlcur_camp_code%TYPE;
    lv_degc2 sorlcur.sorlcur_degc_code%TYPE;
    lv_program2 sorlcur.sorlcur_program%TYPE;
    lv_term_ctlg2 stvterm.stvterm_code%TYPE;
    lv_term_admit2 stvterm.stvterm_code%TYPE;
    lv_term_matric2 stvterm.stvterm_code%TYPE;
    lv_admt2 sorlcur.sorlcur_admt_code%TYPE;
    lv_roll_ind2 sovlcur.sovlcur_roll_ind%TYPE;
    lv_rule2 sorlcur.sorlcur_curr_rule%TYPE;
    lv_majr sovlfos.sovlfos_majr_code%TYPE;
    lv_term_end stvterm.stvterm_code%TYPE;
    lv_dept sovlfos.sovlfos_dept_code%TYPE;
    lv_concrule sorlfos.sorlfos_conc_attach_rule%TYPE;
    lv_lfosrule sovlfos.sovlfos_lfos_rule%TYPE;
    lv_lfosseqno sovlfos.sovlfos_seqno%TYPE;
    lv_lfosseqno2 sovlfos.sovlfos_seqno%TYPE;
    lv_startdate DATE;
    lv_enddate DATE;
    lv_majr_attach stvmajr.stvmajr_code%TYPE;
    lv_rolledseqno sorlfos.sorlfos_rolled_seqno%TYPE;
    lv_tmstcode sorlfos.sorlfos_tmst_code%TYPE;
    lv_majr_1 sovlfos.sovlfos_majr_code%TYPE;
    lv_majr_2 sovlfos.sovlfos_majr_code%TYPE;
    lv_majr_3 sovlfos.sovlfos_majr_code%TYPE;
    hold_sec_seq   shrdgmr.shrdgmr_seq_no%TYPE; 
    hold_one_seq   shrdgmr.shrdgmr_seq_no%TYPE;
    hold_seq    shrdgmr.shrdgmr_seq_no%TYPE;
    hold_term   stvterm.stvterm_code%TYPE;
    high_term   stvterm.stvterm_code%TYPE;
  --  sorlcur_aro_rec  sorlcur_aro2_c%rowtype;
BEGIN
  IF disp_secd = FALSE THEN
                                   
  FOR shrdgmr_row IN shrdgmr_disp_p1_c(pidm)
  LOOP
       
    EXIT WHEN shrdgmr_disp_p1_c%NOTFOUND; --- ROWCOUNT = 2; --AK 1-5J52II

  

       term :=p_term_in;   
         
        -- set all variables from source to values that we'll need later
        -- on to pass to various functions/procedures
        hold_term  := term;
        seq_no     := shrdgmr_row.shrdgmr_seq_no; 
            sokccur.p_get_curricula_data( p_pidm  => pidm,
                                          p_term  => term,
                                          p_lmod  => lv_lmod_code,
                                          p_key_seqno => seq_no);
        
            sokccur.p_parse_lcur_data(p_lmod        => lv_lmod_code,
                                      p_term        => hold_term,
                                      p_lcurindex   => 1,
                                      p_seqno       => lv_seqno,
                                      p_levl        => lv_levl,
                                      p_coll_code   => lv_coll,
                                      p_camp_code   => lv_camp,
                                      p_degc_code   => lv_degc,
                                      p_program     => lv_program,
                                      p_term_ctlg   => lv_term_ctlg,
                                      p_term_admit  => lv_term_admit,
                                      p_term_matric => lv_term_matric,
                                      p_admt_code   => lv_admt,
                                      p_roll_ind    => lv_roll_ind,
                                      p_lcur_rule   => lv_rule);
                                      
 
   
   -- 1-7V3H92
   IF (shrdgmr_disp_p1_c%ROWCOUNT = 1) THEN
      high_term  := lv_term_ctlg;
      hold_seq   := seq_no;   
   END IF;
   IF (lv_term_ctlg >= high_term) and (seq_no <= hold_seq) THEN
       high_term := lv_term_ctlg;
       hold_seq := seq_no;
   END IF;                                                             

   
 END LOOP; 
         
        -- set all variables from source to values that we'll need later
        -- on to pass to various functions/procedures

            sokccur.p_get_curricula_data( p_pidm  => pidm,
                                          p_term  => high_term,
                                          p_lmod  => lv_lmod_code,
                                          p_key_seqno => hold_seq);
        
            sokccur.p_parse_lcur_data(p_lmod        => lv_lmod_code,
                                      p_term        => high_term,
                                      p_lcurindex   => 1,
                                      p_seqno       => lv_seqno,
                                      p_levl        => lv_levl,
                                      p_coll_code   => lv_coll,
                                      p_camp_code   => lv_camp,
                                      p_degc_code   => lv_degc,
                                      p_program     => lv_program,
                                      p_term_ctlg   => lv_term_ctlg,
                                      p_term_admit  => lv_term_admit,
                                      p_term_matric => lv_term_matric,
                                      p_admt_code   => lv_admt,
                                      p_roll_ind    => lv_roll_ind,
                                      p_lcur_rule   => lv_rule);                                      
                                      
                                      
                                      
         request_no := f_getmaxreqnocomplete(pidm, lv_program, source1);
            -- Assign the out parameters value to variables
        
            IF f_prog_web_ind(lv_program) THEN
                IF NOT table_open OR NOT disp_curr THEN
                    twbkfrmt.p_tableopen('NONTABULAR',
                                         cattributes => g$_nls.get('BWCKCAP1-0035',
                                                                   'SQL',
                                                                   'summary="This table will display curriculum information."'),
                                         ccaption => g$_nls.get('BWCKCAP1-0036',
                                                                'SQL',
                                                                'Curriculum Information'));
                    table_open := TRUE;
                    disp_curr  := TRUE;
                END IF;
            
                p_dispcurrent_table(lbl_header_alt,
                                    lv_program,
                                    request_no,
                                    lv_term_ctlg,
                                    lv_levl,
                                    lv_camp,
                                    lv_coll,
                                    lv_degc);
                twbkfrmt.p_tablerowopen;
                twbkfrmt.p_tabledata('&nbsp;');
                twbkfrmt.p_tablerowclose;
            
				--1-983E4U
                term := lv_term_ctlg;
            
                FOR k in 1 .. 3 loop
                
                    sokccur.p_parse_lfos_data(p_lmod             => lv_lmod_code,
                                              p_term             => term,
                                              p_seqno            => lv_seqno,
                                              p_lcurindex        => 1,
                                              p_lfosindex        => 1,
                                              p_concindex        => k,
                                              p_lfstcode         => sb_fieldofstudy_str.f_concentration,
                                              p_majr_code        => lv_majr,
                                              p_term_code_ctlg   => lv_term_ctlg,
                                              p_term_code_end    => lv_term_end,
                                              p_dept_code        => lv_dept,
                                              p_lfos_rule        => lv_lfosrule,
                                              p_lfosseqno        => lv_lfosseqno2,
                                              p_conc_attach_rule => lv_concrule,
                                              p_start_date       => lv_startdate,
                                              p_end_date         => lv_enddate,
                                              p_tmst_code        => lv_tmstcode,
                                              p_rolled_seqno     => lv_rolledseqno,
                                              p_majr_code_attach => lv_majr_attach);
                
                    IF k = 1 THEN
                        lv_majr_1 := lv_majr;
                    ELSIF k = 2 THEN
                        lv_majr_2 := lv_majr;
                    ELSIF k = 3 THEN
                        lv_majr_3 := lv_majr;
                    END IF;
                
                END LOOP;
            
                sokccur.p_parse_lfos_data(p_lmod             => lv_lmod_code,
                                          p_term             => term,
                                          p_seqno            => lv_seqno,
                                          p_lcurindex        => 1,
                                          p_lfosindex        => 1,
                                          p_concindex        => NULL,
                                          p_lfstcode         => sb_fieldofstudy_str.f_major,
                                          p_majr_code        => lv_majr,
                                          p_term_code_ctlg   => lv_term_ctlg,
                                          p_term_code_end    => lv_term_end,
                                          p_dept_code        => lv_dept,
                                          p_lfos_rule        => lv_lfosrule,
                                          p_lfosseqno        => lv_lfosseqno,
                                          p_conc_attach_rule => lv_concrule,
                                          p_start_date       => lv_startdate,
                                          p_end_date         => lv_enddate,
                                          p_tmst_code        => lv_tmstcode,
                                          p_rolled_seqno     => lv_rolledseqno,
                                          p_majr_code_attach => lv_majr_attach);
           
                p_dispcurrent_major1_format(lv_majr,
                                            lv_majr_1,
                                            lv_dept,
                                            lv_majr_2,
                                            lv_majr_3);
            
                -- If there is no information for these fields, do not display the table.
            
                FOR k in 1 .. 3 loop
                
                    sokccur.p_parse_lfos_data(p_lmod             => lv_lmod_code,
                                              p_term             => term,
                                              p_seqno            => lv_seqno,
                                              p_lcurindex        => 1,
                                              p_lfosindex        => 2,
                                              p_concindex        => k,
                                              p_lfstcode         => sb_fieldofstudy_str.f_concentration,
                                              p_majr_code        => lv_majr,
                                              p_term_code_ctlg   => lv_term_ctlg,
                                              p_term_code_end    => lv_term_end,
                                              p_dept_code        => lv_dept,
                                              p_lfos_rule        => lv_lfosrule,
                                              p_lfosseqno        => lv_lfosseqno2,
                                              p_conc_attach_rule => lv_concrule,
                                              p_start_date       => lv_startdate,
                                              p_end_date         => lv_enddate,
                                              p_tmst_code        => lv_tmstcode,
                                              p_rolled_seqno     => lv_rolledseqno,
                                              p_majr_code_attach => lv_majr_attach);
                
                    IF k = 1 THEN
                        lv_majr_1 := lv_majr;
                    ELSIF k = 2 THEN
                        lv_majr_2 := lv_majr;
                    ELSIF k = 3 THEN
                        lv_majr_3 := lv_majr;
                    END IF;
                
                END LOOP;
            
                sokccur.p_parse_lfos_data(p_lmod             => lv_lmod_code,
                                          p_term             => term,
                                          p_seqno            => lv_seqno,
                                          p_lcurindex        => 1,
                                          p_lfosindex        => 2,
                                          p_concindex        => NULL,
                                          p_lfstcode         => sb_fieldofstudy_str.f_major,
                                          p_majr_code        => lv_majr,
                                          p_term_code_ctlg   => lv_term_ctlg,
                                          p_term_code_end    => lv_term_end,
                                          p_dept_code        => lv_dept,
                                          p_lfos_rule        => lv_lfosrule,
                                          p_lfosseqno        => lv_lfosseqno,
                                          p_conc_attach_rule => lv_concrule,
                                          p_start_date       => lv_startdate,
                                          p_end_date         => lv_enddate,
                                          p_tmst_code        => lv_tmstcode,
                                          p_rolled_seqno     => lv_rolledseqno,
                                          p_majr_code_attach => lv_majr_attach);
            
                IF f_display_major_table(lv_majr,
                                         lv_majr_1,
                                         lv_dept,
                                         lv_majr_2,
                                         lv_majr_3) THEN
                    twbkfrmt.p_tablerowopen;
                    twbkfrmt.p_tabledata('&nbsp;');
                    twbkfrmt.p_tablerowclose;
                
                    p_dispcurrent_major2_format(lv_majr,
                                                lv_majr_1,
                                                lv_dept,
                                                lv_majr_2,
                                                lv_majr_3);
                END IF;
            
                FOR j in 1 .. 2 loop
                    sokccur.p_parse_lfos_data(p_lmod             => lv_lmod_code,
                                              p_term             => term,
                                              p_seqno            => lv_seqno,
                                              p_lcurindex        => 1,
                                              p_lfosindex        => j,
                                              p_concindex        => NULL,
                                              p_lfstcode         => sb_fieldofstudy_str.f_minor,
                                              p_majr_code        => lv_majr,
                                              p_term_code_ctlg   => lv_term_ctlg,
                                              p_term_code_end    => lv_term_end,
                                              p_dept_code        => lv_dept,
                                              p_lfos_rule        => lv_lfosrule,
                                              p_lfosseqno        => lv_lfosseqno,
                                              p_conc_attach_rule => lv_concrule,
                                              p_start_date       => lv_startdate,
                                              p_end_date         => lv_enddate,
                                              p_tmst_code        => lv_tmstcode,
                                              p_rolled_seqno     => lv_rolledseqno,
                                              p_majr_code_attach => lv_majr_attach);
                
                    IF j = 1 THEN
                        lv_majr_1 := lv_majr; 
                    ELSIF j = 2 THEN
                        lv_majr_2 := lv_majr;
                    END IF;
                
                END LOOP;
            
                -- If there is no information for these fields, do not display table.
            
                IF f_display_minor_table(lv_majr_1, lv_majr_2) THEN
                    twbkfrmt.p_tablerowopen;
                    twbkfrmt.p_tabledata('&nbsp;');
                    twbkfrmt.p_tablerowclose;                
                    p_dispcurrent_minor_format(lv_majr_1, lv_majr_2);
                END IF;
            
                IF (disp_curr = TRUE) THEN            
                    twbkfrmt.p_tablerowopen;
                    twbkfrmt.p_tabledata('&nbsp;');
                    twbkfrmt.p_tablerowclose;
                END IF;
            END IF;
        
        IF NOT (disp_curr) THEN
            twbkwbis.p_dispinfo('bwckcapp.P_DispCurrent', 'NOCUR');
        ELSE
            twbkfrmt.p_tableclose;
        END IF;
ELSE
   FOR shrdgmr_row IN shrdgmr_disp_p1_c(pidm)
  LOOP
   
       EXIT WHEN shrdgmr_disp_p1_c%NOTFOUND;
  
       term :=  p_term_in;  --- sorlcur_aro_rec.sovlcur_term_code;  
         
        -- set all variables from source to values that we'll need later
        -- on to pass to various functions/procedures
        hold_term  := term;
        seq_no     := shrdgmr_row.shrdgmr_seq_no; 
         sokccur.p_get_curricula_data( p_pidm  => pidm,
                                          p_term  => term,
                                          p_lmod  => lv_lmod_code,
                                          p_key_seqno => seq_no);
           sokccur.p_parse_lcur_data(p_lmod        => lv_lmod_code,
                                      p_term        => hold_term,
                                      p_lcurindex   => 1,
                                      p_seqno       => lv_seqno,
                                      p_levl        => lv_levl,
                                      p_coll_code   => lv_coll,
                                      p_camp_code   => lv_camp,
                                      p_degc_code   => lv_degc,
                                      p_program     => lv_program,
                                      p_term_ctlg   => lv_term_ctlg,
                                      p_term_admit  => lv_term_admit,
                                      p_term_matric => lv_term_matric,
                                      p_admt_code   => lv_admt,
                                      p_roll_ind    => lv_roll_ind,
                                      p_lcur_rule   => lv_rule);
      
         request_no := f_getmaxreqnocomplete(pidm, lv_program, source1);
            -- Assign the out parameters value to variables
             IF f_prog_web_ind(lv_program) THEN
                IF NOT table_open OR NOT disp_curr THEN
                    twbkfrmt.p_tableopen('NONTABULAR',
                                         cattributes => g$_nls.get('BWCKCAP1-0037',
                                                                   'SQL',
                                                                   'summary="This table will display curriculum information."'),
                                         ccaption => g$_nls.get('BWCKCAP1-0038',
                                                                'SQL',
                                                                'Curriculum Information'));
                    table_open := TRUE;
                    disp_curr  := TRUE;
                END IF;
            
                p_dispcurrent_table(lbl_header_alt,
                                    lv_program,
                                    request_no,
                                    lv_term_ctlg,
                                    lv_levl,
                                    lv_camp,
                                    lv_coll,
                                    lv_degc);
                twbkfrmt.p_tablerowopen;
                twbkfrmt.p_tabledata('&nbsp;');
                twbkfrmt.p_tablerowclose;
            
              
            
                FOR k in 1 .. 3 loop
                
                    sokccur.p_parse_lfos_data(p_lmod             => lv_lmod_code,
                                              p_term             => term,
                                              p_seqno            => lv_seqno,
                                              p_lcurindex        => 1,
                                              p_lfosindex        => 1,
                                              p_concindex        => k,
                                              p_lfstcode         => sb_fieldofstudy_str.f_concentration,
                                              p_majr_code        => lv_majr,
                                              p_term_code_ctlg   => lv_term_ctlg,
                                              p_term_code_end    => lv_term_end,
                                              p_dept_code        => lv_dept,
                                              p_lfos_rule        => lv_lfosrule,
                                              p_lfosseqno        => lv_lfosseqno2,
                                              p_conc_attach_rule => lv_concrule,
                                              p_start_date       => lv_startdate,
                                              p_end_date         => lv_enddate,
                                              p_tmst_code        => lv_tmstcode,
                                              p_rolled_seqno     => lv_rolledseqno,
                                              p_majr_code_attach => lv_majr_attach);
                
                    IF k = 1 THEN
                        lv_majr_1 := lv_majr;
                    ELSIF k = 2 THEN
                        lv_majr_2 := lv_majr;
                    ELSIF k = 3 THEN
                        lv_majr_3 := lv_majr;
                    END IF;
                
                END LOOP;
            
                sokccur.p_parse_lfos_data(p_lmod             => lv_lmod_code,
                                          p_term             => term,
                                          p_seqno            => lv_seqno,
                                          p_lcurindex        => 1,
                                          p_lfosindex        => 1,
                                          p_concindex        => NULL,
                                          p_lfstcode         => sb_fieldofstudy_str.f_major,
                                          p_majr_code        => lv_majr,
                                          p_term_code_ctlg   => lv_term_ctlg,
                                          p_term_code_end    => lv_term_end,
                                          p_dept_code        => lv_dept,
                                          p_lfos_rule        => lv_lfosrule,
                                          p_lfosseqno        => lv_lfosseqno,
                                          p_conc_attach_rule => lv_concrule,
                                          p_start_date       => lv_startdate,
                                          p_end_date         => lv_enddate,
                                          p_tmst_code        => lv_tmstcode,
                                          p_rolled_seqno     => lv_rolledseqno,
                                          p_majr_code_attach => lv_majr_attach);
             
                p_dispcurrent_major1_format(lv_majr,
                                            lv_majr_1,
                                            lv_dept,
                                            lv_majr_2,
                                            lv_majr_3);
            
                -- If there is no information for these fields, do not display the table.
            
                FOR k in 1 .. 3 loop
                
                    sokccur.p_parse_lfos_data(p_lmod             => lv_lmod_code,
                                              p_term             => term,
                                              p_seqno            => lv_seqno,
                                              p_lcurindex        => 1,
                                              p_lfosindex        => 2,
                                              p_concindex        => k,
                                              p_lfstcode         => sb_fieldofstudy_str.f_concentration,
                                              p_majr_code        => lv_majr,
                                              p_term_code_ctlg   => lv_term_ctlg,
                                              p_term_code_end    => lv_term_end,
                                              p_dept_code        => lv_dept,
                                              p_lfos_rule        => lv_lfosrule,
                                              p_lfosseqno        => lv_lfosseqno2,
                                              p_conc_attach_rule => lv_concrule,
                                              p_start_date       => lv_startdate,
                                              p_end_date         => lv_enddate,
                                              p_tmst_code        => lv_tmstcode,
                                              p_rolled_seqno     => lv_rolledseqno,
                                              p_majr_code_attach => lv_majr_attach);
                
                    IF k = 1 THEN
                        lv_majr_1 := lv_majr;
                    ELSIF k = 2 THEN
                        lv_majr_2 := lv_majr;
                    ELSIF k = 3 THEN
                        lv_majr_3 := lv_majr;
                    END IF;
                
                END LOOP;
            
                sokccur.p_parse_lfos_data(p_lmod             => lv_lmod_code,
                                          p_term             => term,
                                          p_seqno            => lv_seqno,
                                          p_lcurindex        => 1,
                                          p_lfosindex        => 2,
                                          p_concindex        => NULL,
                                          p_lfstcode         => sb_fieldofstudy_str.f_major,
                                          p_majr_code        => lv_majr,
                                          p_term_code_ctlg   => lv_term_ctlg,
                                          p_term_code_end    => lv_term_end,
                                          p_dept_code        => lv_dept,
                                          p_lfos_rule        => lv_lfosrule,
                                          p_lfosseqno        => lv_lfosseqno,
                                          p_conc_attach_rule => lv_concrule,
                                          p_start_date       => lv_startdate,
                                          p_end_date         => lv_enddate,
                                          p_tmst_code        => lv_tmstcode,
                                          p_rolled_seqno     => lv_rolledseqno,
                                          p_majr_code_attach => lv_majr_attach);
            
                IF f_display_major_table(lv_majr,
                                         lv_majr_1,
                                         lv_dept,
                                         lv_majr_2,
                                         lv_majr_3) THEN
                    twbkfrmt.p_tablerowopen;
                    twbkfrmt.p_tabledata('&nbsp;');
                    twbkfrmt.p_tablerowclose;
                
                    p_dispcurrent_major2_format(lv_majr,
                                                lv_majr_1,
                                                lv_dept,
                                                lv_majr_2,
                                                lv_majr_3);
                END IF;
            
                FOR j in 1 .. 2 loop
                    sokccur.p_parse_lfos_data(p_lmod             => lv_lmod_code,
                                              p_term             => term,
                                              p_seqno            => lv_seqno,
                                              p_lcurindex        => 1,
                                              p_lfosindex        => j,
                                              p_concindex        => NULL,
                                              p_lfstcode         => sb_fieldofstudy_str.f_minor,
                                              p_majr_code        => lv_majr,
                                              p_term_code_ctlg   => lv_term_ctlg,
                                              p_term_code_end    => lv_term_end,
                                              p_dept_code        => lv_dept,
                                              p_lfos_rule        => lv_lfosrule,
                                              p_lfosseqno        => lv_lfosseqno,
                                              p_conc_attach_rule => lv_concrule,
                                              p_start_date       => lv_startdate,
                                              p_end_date         => lv_enddate,
                                              p_tmst_code        => lv_tmstcode,
                                              p_rolled_seqno     => lv_rolledseqno,
                                              p_majr_code_attach => lv_majr_attach);
                
                    IF j = 1 THEN
                        lv_majr_1 := lv_majr; 
                    ELSIF j = 2 THEN
                        lv_majr_2 := lv_majr;
                    END IF;
                
                END LOOP;
            
                -- If there is no information for these fields, do not display table.
            
                IF f_display_minor_table(lv_majr_1, lv_majr_2) THEN
                    twbkfrmt.p_tablerowopen;
                    twbkfrmt.p_tabledata('&nbsp;');
                    twbkfrmt.p_tablerowclose;                
                    p_dispcurrent_minor_format(lv_majr_1, lv_majr_2);
                END IF;
            
                IF (disp_curr = TRUE) THEN            
                    twbkfrmt.p_tablerowopen;
                    twbkfrmt.p_tabledata('&nbsp;');
                    twbkfrmt.p_tablerowclose;
                END IF;
            END IF;
            
      
        END LOOP;
       
        IF NOT (disp_curr) THEN
            twbkwbis.p_dispinfo('bwckcapp.P_DispCurrent', 'NOCUR');
        ELSE
            twbkfrmt.p_tableclose;
        END IF;
     END IF;
    END p_dispcursourceshrdgmr;
   -------------------------------------------------------------------------
PROCEDURE p_dispcursourcesrbrecr(pidm      IN spriden.spriden_pidm%TYPE DEFAULT NULL,
                                 source1   IN VARCHAR2 DEFAULT NULL,
                                 disp_secd IN BOOLEAN DEFAULT FALSE,
                                 p_term_in IN STVTERM.STVTERM_CODE%TYPE,
                                 term      OUT stvterm.stvterm_code%TYPE) IS
    program    smrrqcm.smrrqcm_program%TYPE DEFAULT NULL;
    request_no smrrqcm.smrrqcm_request_no%TYPE DEFAULT NULL;
    table_open BOOLEAN DEFAULT FALSE;
    disp_curr  BOOLEAN DEFAULT FALSE;
    seq_no   sorlcur.sorlcur_key_seqno%TYPE ;
    lv_lmod_code stvlmod.stvlmod_code%TYPE := sb_curriculum_str.f_recruit;
    lv_seqno sorlcur.sorlcur_seqno%TYPE;
    lv_levl sorlcur.sorlcur_levl_code%TYPE;
    lv_coll sorlcur.sorlcur_coll_code%TYPE;
    lv_camp sorlcur.sorlcur_camp_code%TYPE;
    lv_degc sorlcur.sorlcur_degc_code%TYPE;
    lv_program sorlcur.sorlcur_program%TYPE;
    lv_term_ctlg stvterm.stvterm_code%TYPE;
    lv_term_admit stvterm.stvterm_code%TYPE;
    lv_term_matric stvterm.stvterm_code%TYPE;
    lv_admt sorlcur.sorlcur_admt_code%TYPE;
    lv_roll_ind sovlcur.sovlcur_roll_ind%TYPE;
    lv_rule sorlcur.sorlcur_curr_rule%TYPE;
    lv_majr sovlfos.sovlfos_majr_code%TYPE;
    lv_term_end stvterm.stvterm_code%TYPE;
    lv_dept sovlfos.sovlfos_dept_code%TYPE;
    lv_concrule sorlfos.sorlfos_conc_attach_rule%TYPE;
    lv_lfosrule sovlfos.sovlfos_lfos_rule%TYPE;
    lv_lfosseqno sovlfos.sovlfos_seqno%TYPE;
    lv_lfosseqno2 sovlfos.sovlfos_seqno%TYPE;
    lv_startdate DATE;
    lv_enddate DATE;
    lv_majr_attach stvmajr.stvmajr_code%TYPE;
    lv_rolledseqno sorlfos.sorlfos_rolled_seqno%TYPE;
    lv_tmstcode sorlfos.sorlfos_tmst_code%TYPE;
    lv_majr_1 sovlfos.sovlfos_majr_code%TYPE;
    lv_majr_2 sovlfos.sovlfos_majr_code%TYPE;
    lv_majr_3 sovlfos.sovlfos_majr_code%TYPE;
    hold_term   stvterm.stvterm_code%TYPE;
     
BEGIN
     FOR srbrecr_row IN srbrecr_disp_all_c(pidm, p_term_in) LOOP
  
       EXIT WHEN srbrecr_disp_all_c%NOTFOUND;
 
        -- set all variables from source to values that we'll need later
        -- on to pass to various functions/procedures
        hold_term := srbrecr_row.srbrecr_term_code; --- sorlcur_aro_rec.sovlcur_term_code;
        seq_no := srbrecr_row.srbrecr_admin_seqno; 



            sokccur.p_get_curricula_data( p_pidm  => pidm,
                                          p_term  => hold_term,
                                          p_lmod  => lv_lmod_code,
                                          p_key_seqno => seq_no);
        
            sokccur.p_parse_lcur_data(p_lmod        => lv_lmod_code,
                                      p_term        => hold_term,
                                      p_lcurindex   => 1,
                                      p_seqno       => lv_seqno,
                                      p_levl        => lv_levl,
                                      p_coll_code   => lv_coll,
                                      p_camp_code   => lv_camp,
                                      p_degc_code   => lv_degc,
                                      p_program     => lv_program,
                                      p_term_ctlg   => lv_term_ctlg,
                                      p_term_admit  => lv_term_admit,
                                      p_term_matric => lv_term_matric,
                                      p_admt_code   => lv_admt,
                                      p_roll_ind    => lv_roll_ind,
                                      p_lcur_rule   => lv_rule);
        
            -- Assign the out parameters value to variables
        
            IF f_prog_web_ind(lv_program) THEN
                IF NOT table_open OR NOT disp_curr THEN
                    twbkfrmt.p_tableopen('NONTABULAR',
                                         cattributes => g$_nls.get('BWCKCAP1-0039',
                                                                   'SQL',
                                                                   'summary="This table will display curriculum information."'),
                                         ccaption => g$_nls.get('BWCKCAP1-0040',
                                                                'SQL',
                                                                'Curriculum Information'));
                    table_open := TRUE;
                    disp_curr  := TRUE;
                END IF;
            
                p_dispcurrent_table(lbl_header_alt,
                                    lv_program,
                                    request_no,
                                    lv_term_ctlg,
                                    lv_levl,
                                    lv_camp,
                                    lv_coll,
                                    lv_degc);
                twbkfrmt.p_tablerowopen;
                twbkfrmt.p_tabledata('&nbsp;');
                twbkfrmt.p_tablerowclose;
            
				--1-983E4U
                hold_term := lv_term_ctlg;
            
                FOR k in 1 .. 3 loop
                
                    sokccur.p_parse_lfos_data(p_lmod             => lv_lmod_code,
                                              p_term             => hold_term,
                                              p_seqno            => lv_seqno,
                                              p_lcurindex        => 1,
                                              p_lfosindex        => 1,
                                              p_concindex        => k,
                                              p_lfstcode         => sb_fieldofstudy_str.f_concentration,
                                              p_majr_code        => lv_majr,
                                              p_term_code_ctlg   => lv_term_ctlg,
                                              p_term_code_end    => lv_term_end,
                                              p_dept_code        => lv_dept,
                                              p_lfos_rule        => lv_lfosrule,
                                              p_lfosseqno        => lv_lfosseqno2,
                                              p_conc_attach_rule => lv_concrule,
                                              p_start_date       => lv_startdate,
                                              p_end_date         => lv_enddate,
                                              p_tmst_code        => lv_tmstcode,
                                              p_rolled_seqno     => lv_rolledseqno,
                                              p_majr_code_attach => lv_majr_attach);
                
                    IF k = 1 THEN
                        lv_majr_1 := lv_majr;
                    ELSIF k = 2 THEN
                        lv_majr_2 := lv_majr;
                    ELSIF k = 3 THEN
                        lv_majr_3 := lv_majr;
                    END IF;
                
                END LOOP;
            
                sokccur.p_parse_lfos_data(p_lmod             => lv_lmod_code,
                                          p_term             => hold_term,
                                          p_seqno            => lv_seqno,
                                          p_lcurindex        => 1,
                                          p_lfosindex        => 1,
                                          p_concindex        => NULL,
                                          p_lfstcode         => sb_fieldofstudy_str.f_major,
                                          p_majr_code        => lv_majr,
                                          p_term_code_ctlg   => lv_term_ctlg,
                                          p_term_code_end    => lv_term_end,
                                          p_dept_code        => lv_dept,
                                          p_lfos_rule        => lv_lfosrule,
                                          p_lfosseqno        => lv_lfosseqno,
                                          p_conc_attach_rule => lv_concrule,
                                          p_start_date       => lv_startdate,
                                          p_end_date         => lv_enddate,
                                          p_tmst_code        => lv_tmstcode,
                                          p_rolled_seqno     => lv_rolledseqno,
                                          p_majr_code_attach => lv_majr_attach);
            
                p_dispcurrent_major1_format(lv_majr,
                                            lv_majr_1,
                                            lv_dept,
                                            lv_majr_2,
                                            lv_majr_3);
            
                -- If there is no information for these fields, do not display the table.
            
                FOR k in 1 .. 3 loop
                
                    sokccur.p_parse_lfos_data(p_lmod             => lv_lmod_code,
                                              p_term             => hold_term,
                                              p_seqno            => lv_seqno,
                                              p_lcurindex        => 1,
                                              p_lfosindex        => 2,
                                              p_concindex        => k,
                                              p_lfstcode         => sb_fieldofstudy_str.f_concentration,
                                              p_majr_code        => lv_majr,
                                              p_term_code_ctlg   => lv_term_ctlg,
                                              p_term_code_end    => lv_term_end,
                                              p_dept_code        => lv_dept,
                                              p_lfos_rule        => lv_lfosrule,
                                              p_lfosseqno        => lv_lfosseqno2,
                                              p_conc_attach_rule => lv_concrule,
                                              p_start_date       => lv_startdate,
                                              p_end_date         => lv_enddate,
                                              p_tmst_code        => lv_tmstcode,
                                              p_rolled_seqno     => lv_rolledseqno,
                                              p_majr_code_attach => lv_majr_attach);
                
                    IF k = 1 THEN
                        lv_majr_1 := lv_majr;
                    ELSIF k = 2 THEN
                        lv_majr_2 := lv_majr;
                    ELSIF k = 3 THEN
                        lv_majr_3 := lv_majr;
                    END IF;
                
                END LOOP;
            
                sokccur.p_parse_lfos_data(p_lmod             => lv_lmod_code,
                                          p_term             => hold_term,
                                          p_seqno            => lv_seqno,
                                          p_lcurindex        => 1,
                                          p_lfosindex        => 2,
                                          p_concindex        => NULL,
                                          p_lfstcode         => sb_fieldofstudy_str.f_major,
                                          p_majr_code        => lv_majr,
                                          p_term_code_ctlg   => lv_term_ctlg,
                                          p_term_code_end    => lv_term_end,
                                          p_dept_code        => lv_dept,
                                          p_lfos_rule        => lv_lfosrule,
                                          p_lfosseqno        => lv_lfosseqno,
                                          p_conc_attach_rule => lv_concrule,
                                          p_start_date       => lv_startdate,
                                          p_end_date         => lv_enddate,
                                          p_tmst_code        => lv_tmstcode,
                                          p_rolled_seqno     => lv_rolledseqno,
                                          p_majr_code_attach => lv_majr_attach);
            
                IF f_display_major_table(lv_majr,
                                         lv_majr_1,
                                         lv_dept,
                                         lv_majr_2,
                                         lv_majr_3) THEN
                    twbkfrmt.p_tablerowopen;
                    twbkfrmt.p_tabledata('&nbsp;');
                    twbkfrmt.p_tablerowclose;
                
                    p_dispcurrent_major2_format(lv_majr,
                                                lv_majr_1,
                                                lv_dept,
                                                lv_majr_2,
                                                lv_majr_3);
                END IF;
            
                FOR j in 1 .. 2 loop
                    sokccur.p_parse_lfos_data(p_lmod             => lv_lmod_code,
                                              p_term             => hold_term,
                                              p_seqno            => lv_seqno,
                                              p_lcurindex        => 1,
                                              p_lfosindex        => j,
                                              p_concindex        => NULL,
                                              p_lfstcode         => sb_fieldofstudy_str.f_minor,
                                              p_majr_code        => lv_majr,
                                              p_term_code_ctlg   => lv_term_ctlg,
                                              p_term_code_end    => lv_term_end,
                                              p_dept_code        => lv_dept,
                                              p_lfos_rule        => lv_lfosrule,
                                              p_lfosseqno        => lv_lfosseqno,
                                              p_conc_attach_rule => lv_concrule,
                                              p_start_date       => lv_startdate,
                                              p_end_date         => lv_enddate,
                                              p_tmst_code        => lv_tmstcode,
                                              p_rolled_seqno     => lv_rolledseqno,
                                              p_majr_code_attach => lv_majr_attach);
                
                    IF j = 1 THEN 
                        lv_majr_1 := lv_majr; 
                    ELSIF j = 2 THEN
                        lv_majr_2 := lv_majr;
                    END IF;
                
                END LOOP;
            
                -- If there is no information for these fields, do not display table.
            
                IF f_display_minor_table(lv_majr_1, lv_majr_2) THEN
                    twbkfrmt.p_tablerowopen;
                    twbkfrmt.p_tabledata('&nbsp;');
                    twbkfrmt.p_tablerowclose;                
                    p_dispcurrent_minor_format(lv_majr_1, lv_majr_2);
                END IF;
            
                IF (disp_curr = TRUE) THEN             
                    twbkfrmt.p_tablerowopen;
                    twbkfrmt.p_tabledata('&nbsp;');
                    twbkfrmt.p_tablerowclose;
                END IF;
            END IF;
     --    END LOOP;
        END LOOP;
        IF NOT (disp_curr) THEN
            twbkwbis.p_dispinfo('bwckcapp.P_DispCurrent', 'NOCUR');
        ELSE
            twbkfrmt.p_tableclose;
        END IF;
    
    END p_dispcursourcesrbrecr; 
   -------------------------------------------------------------------------
   PROCEDURE P_DispTermSourceSgbstdn (
      pidm        IN       SPRIDEN.SPRIDEN_PIDM%TYPE DEFAULT NULL,
      source1     IN       VARCHAR2 DEFAULT NULL,
      disp_secd   IN       BOOLEAN DEFAULT FALSE,
      p_term_in   IN       STVTERM.STVTERM_CODE%TYPE,
      p_count     OUT      NUMBER) IS
    program    smrrqcm.smrrqcm_program%TYPE DEFAULT NULL;
    request_no smrrqcm.smrrqcm_request_no%TYPE DEFAULT NULL;
    table_open BOOLEAN DEFAULT FALSE;
    disp_curr  BOOLEAN DEFAULT FALSE;
    seq_no   sorlcur.sorlcur_key_seqno%TYPE ;
    lv_lmod_code stvlmod.stvlmod_code%TYPE := sb_curriculum_str.f_learner;
    lv_seqno sorlcur.sorlcur_seqno%TYPE;
    lv_levl sorlcur.sorlcur_levl_code%TYPE;
    lv_coll sorlcur.sorlcur_coll_code%TYPE;
    lv_camp sorlcur.sorlcur_camp_code%TYPE;
    lv_degc sorlcur.sorlcur_degc_code%TYPE;
    lv_program sorlcur.sorlcur_program%TYPE;
    lv_term_ctlg stvterm.stvterm_code%TYPE;
    lv_term_admit stvterm.stvterm_code%TYPE;
    lv_term_matric stvterm.stvterm_code%TYPE;
    lv_admt sorlcur.sorlcur_admt_code%TYPE;
    lv_roll_ind sovlcur.sovlcur_roll_ind%TYPE;
    lv_rule sorlcur.sorlcur_curr_rule%TYPE;
    lv_majr sovlfos.sovlfos_majr_code%TYPE;
    lv_term_end stvterm.stvterm_code%TYPE;
    lv_dept sovlfos.sovlfos_dept_code%TYPE;
    lv_concrule sorlfos.sorlfos_conc_attach_rule%TYPE;
    lv_lfosrule sovlfos.sovlfos_lfos_rule%TYPE;
    lv_lfosseqno sovlfos.sovlfos_seqno%TYPE;
    lv_lfosseqno2 sovlfos.sovlfos_seqno%TYPE;
    lv_startdate DATE;
    lv_enddate DATE;
    lv_majr_attach stvmajr.stvmajr_code%TYPE;
    lv_rolledseqno sorlfos.sorlfos_rolled_seqno%TYPE;
    lv_tmstcode sorlfos.sorlfos_tmst_code%TYPE;
    lv_majr_1 sovlfos.sovlfos_majr_code%TYPE;
    lv_majr_2 sovlfos.sovlfos_majr_code%TYPE;
    lv_majr_3 sovlfos.sovlfos_majr_code%TYPE;
    lv_lcurAdmtCount        NUMBER(4):=NULL;
    lv_lcurRecrCount        NUMBER(4):=NULL;
    lv_lcurOutcCount        NUMBER(4):=NULL;
    lv_lcurLrnrCount        NUMBER(4):=NULL;     
    hold_term   stvterm.stvterm_code%TYPE := p_term_in;
    count1        NUMBER;
   
    P_S_var                VARCHAR2(1) := 'P';
    limit                   NUMBER(1):=0;
    hold_sec_term   stvterm.stvterm_code%TYPE; 
    hold_one_term   stvterm.stvterm_code%TYPE;
    split_cur       VARCHAR2(1):='Y';
    bypass_i        VARCHAR2(1):='N';
BEGIN
    count1 := 0;
      FOR sgbstdn_row IN sgbstdn_disp_prim_p2_c(pidm, p_term_in)
      LOOP
         EXIT WHEN sgbstdn_disp_prim_p2_c%NOTFOUND;
         
         hold_term := sgbstdn_row.sgbstdn_term_code_eff; 
          soklcur.p_create_sotvcur(p_pidm => pidm,
           p_lmod_code => sb_curriculum_str.f_learner,
           p_term_code => sgbstdn_row.sgbstdn_term_code_eff );
    
         		seq_no := 99;
            
	
		        sokccur.p_get_curricula_data( p_pidm  => pidm,
						   p_term  => hold_term,
						   p_lmod  => lv_lmod_code,
						   p_key_seqno => seq_no);
		      sokccur.p_number_of_lcur (    p_term       =>  hold_term,
						  p_lcurAdmtCount  =>  lv_lcurAdmtCount,
						  p_lcurRecrCount  =>  lv_lcurRecrCount,
						  p_lcurOutcCount  =>  lv_lcurOutcCount,
						  p_lcurLrnrCount  =>  lv_lcurLrnrCount);      
	     

            IF (disp_secd = FALSE or lv_lcurLrnrCount = 1) THEN
               limit := 1;
            ELSE 
               limit := 2;            
            END IF;
                 

            FOR i IN 1..NVL (limit, 0)
            LOOP 
                                           
            sokccur.p_parse_lcur_data(p_lmod        => lv_lmod_code,
                                      p_term        => hold_term,
                                      p_lcurindex   => i,
                                      p_seqno       => lv_seqno,
                                      p_levl        => lv_levl,
                                      p_coll_code   => lv_coll,
                                      p_camp_code   => lv_camp,
                                      p_degc_code   => lv_degc,
                                      p_program     => lv_program,
                                      p_term_ctlg   => lv_term_ctlg,
                                      p_term_admit  => lv_term_admit,
                                      p_term_matric => lv_term_matric,
                                      p_admt_code   => lv_admt,
                                      p_roll_ind    => lv_roll_ind,
                                      p_lcur_rule   => lv_rule);
                IF (i=2 and  lv_program IS NOT NULL) 
                THEN 
                  split_cur := 'N';
                END IF;                                      
                IF (i=1   ) OR 
                   ((i=2  and split_cur = 'N') OR
                    (i=2   and split_cur = 'Y'))
                THEN
            program    := lv_program;              
            -- Assign the out parameters value to variables
            IF lv_program IS NOT NULL AND f_prog_web_ind(lv_program) THEN
                IF NOT table_open AND (count1 = 0) THEN
	             		twbkfrmt.p_tableopen('DATAENTRY',
				        	     cattributes => g$_nls.get('BWCKCAP1-0041',
								       'SQL',
			'summary="This table allows the user to select a valid combination of program, degree and major as well as an evaluation termect "'));
	             		disp_curr  := TRUE;
		            	table_open := TRUE;
                END IF;
                count1 := count1+1;  
                IF (i = 1) THEN
                    P_S_var := 'P';
                ELSE 
                    P_S_var := 'S';
                END IF;
              
                        twbkfrmt.p_tablerowopen;
                        /* 1-1C08BT 7.3.3.  Append saradap_appl_no TO PROGRAM value. */
                        twbkfrmt.p_tabledata(htf.formradio('program',
                                                           P_S_var||hold_term,
                                                           cattributes => ' ID="program_id' ||
                                                                          count1 || '"'));
                        twbkfrmt.p_tabledata(twbkfrmt.f_formlabel(lbl_prog,
                                                                  idname => 'program_id' ||
                                                                            count1) ||
                                             twbkfrmt.f_printtext('&nbsp;'));
                        twbkfrmt.p_tabledata(get_program_desc(lv_program));
                        twbkfrmt.p_tablerowclose;
                        twbkfrmt.p_tablerowopen;
                        twbkfrmt.p_tabledata('&nbsp;');
                        twbkfrmt.p_tabledata(twbkfrmt.f_formlabel(g$_nls.get('BWCKCAP1-0042',
                                                                             'SQL',
                                                                             'Degree: ')));
                        twbkfrmt.p_tabledata(get_degc_desc(lv_degc));
                        twbkfrmt.p_tablerowclose;                           
                      sokccur.p_parse_lfos_data(p_lmod             => lv_lmod_code,
                                          p_term             => hold_term,
                                          p_seqno            => lv_seqno,
                                          p_lcurindex        => i,
                                          p_lfosindex        => 1,
                                          p_concindex        => NULL,
                                          p_lfstcode         => sb_fieldofstudy_str.f_major,
                                          p_majr_code        => lv_majr,
                                          p_term_code_ctlg   => lv_term_ctlg,
                                          p_term_code_end    => lv_term_end,
                                          p_dept_code        => lv_dept,
                                          p_lfos_rule        => lv_lfosrule,
                                          p_lfosseqno        => lv_lfosseqno,
                                          p_conc_attach_rule => lv_concrule,
                                          p_start_date       => lv_startdate,
                                          p_end_date         => lv_enddate,
                                          p_tmst_code        => lv_tmstcode,
                                          p_rolled_seqno     => lv_rolledseqno,
                                          p_majr_code_attach => lv_majr_attach);
                        twbkfrmt.p_tablerowopen;
                        twbkfrmt.p_tabledata('&nbsp;');
                        twbkfrmt.p_tabledata(twbkfrmt.f_formlabel(g$_nls.get('BWCKCAP1-0043',
                                                                             'SQL',
                                                                             'Major: ')));
                        twbkfrmt.p_tabledata(get_majr_desc(lv_majr));
                        twbkfrmt.p_tablerowclose;
                        twbkfrmt.p_tablerowopen;
                        twbkfrmt.p_tabledata('&nbsp;');
                        twbkfrmt.p_tablerowclose;                
            
                IF (disp_secd = TRUE) AND (disp_curr = TRUE) THEN
                    twbkfrmt.p_tablerowopen;
                    twbkfrmt.p_tabledata('&nbsp;');
                    twbkfrmt.p_tablerowclose;
                END IF;
                END IF;
            END IF;
       -- END LOOP;
        END LOOP;
        END LOOP;     
        
        IF (lv_lcurLrnrCount=0) THEN
            twbkwbis.p_dispinfo('bwckcapp.P_DispCurrent', 'NOCUR');
        ELSE
            twbkfrmt.p_tableclose;
        END IF;
        p_count := count1;
    END P_DispTermSourceSgbstdn;   
       
   -------------------------------------------------------------------------
   PROCEDURE P_DispTermSourceSaradap (
      pidm        IN       SPRIDEN.SPRIDEN_PIDM%TYPE DEFAULT NULL,
      source1     IN       VARCHAR2 DEFAULT NULL,
      disp_secd   IN       BOOLEAN DEFAULT FALSE,
      p_term_in   IN       STVTERM.STVTERM_CODE%TYPE,
      p_count     OUT      NUMBER) IS
    program    smrrqcm.smrrqcm_program%TYPE DEFAULT NULL;
    request_no smrrqcm.smrrqcm_request_no%TYPE DEFAULT NULL;
    table_open BOOLEAN DEFAULT FALSE;
    disp_curr  BOOLEAN DEFAULT FALSE;
    seq_no   sorlcur.sorlcur_key_seqno%TYPE ;
    lv_lmod_code stvlmod.stvlmod_code%TYPE := sb_curriculum_str.f_admissions;
    lv_seqno sorlcur.sorlcur_seqno%TYPE;
    lv_levl sorlcur.sorlcur_levl_code%TYPE;
    lv_coll sorlcur.sorlcur_coll_code%TYPE;
    lv_camp sorlcur.sorlcur_camp_code%TYPE;
    lv_degc sorlcur.sorlcur_degc_code%TYPE;
    lv_program sorlcur.sorlcur_program%TYPE;
    lv_term_ctlg stvterm.stvterm_code%TYPE;
    lv_term_admit stvterm.stvterm_code%TYPE;
    lv_term_matric stvterm.stvterm_code%TYPE;
    lv_admt sorlcur.sorlcur_admt_code%TYPE;
    lv_roll_ind sovlcur.sovlcur_roll_ind%TYPE;
    lv_rule sorlcur.sorlcur_curr_rule%TYPE;
    lv_majr sovlfos.sovlfos_majr_code%TYPE;
    lv_term_end stvterm.stvterm_code%TYPE;
    lv_dept sovlfos.sovlfos_dept_code%TYPE;
    lv_concrule sorlfos.sorlfos_conc_attach_rule%TYPE;
    lv_lfosrule sovlfos.sovlfos_lfos_rule%TYPE;
    lv_lfosseqno sovlfos.sovlfos_seqno%TYPE;
    lv_lfosseqno2 sovlfos.sovlfos_seqno%TYPE;
    lv_startdate DATE;
    lv_enddate DATE;
    lv_majr_attach stvmajr.stvmajr_code%TYPE;
    lv_rolledseqno sorlfos.sorlfos_rolled_seqno%TYPE;
    lv_tmstcode sorlfos.sorlfos_tmst_code%TYPE;
    lv_majr_1 sovlfos.sovlfos_majr_code%TYPE;
    lv_majr_2 sovlfos.sovlfos_majr_code%TYPE;
    lv_majr_3 sovlfos.sovlfos_majr_code%TYPE;
    lv_lcurAdmtCount        NUMBER(4):=NULL;
    lv_lcurRecrCount        NUMBER(4):=NULL;
    lv_lcurOutcCount        NUMBER(4):=NULL;
    lv_lcurLrnrCount        NUMBER(4):=NULL;     
    hold_term   stvterm.stvterm_code%TYPE := p_term_in;
 
    count1        NUMBER;
    P_S_var                VARCHAR2(1) := 'P';
    limit                   NUMBER(1):=1;
BEGIN
    count1       := 0;
    FOR saradap_row IN saradap_disp_prim_c(pidm, p_term_in)
      LOOP
            EXIT WHEN saradap_disp_prim_c%NOTFOUND;
  
      -- set all variables from source to values that we'll need later
      -- on to pass to various functions/procedures
      seq_no     := saradap_row.saradap_appl_no;         
      hold_term  :=  saradap_row.saradap_term_code_entry; -- saradap_row.saradap_term_code_entry;
      
            sokccur.p_get_curricula_data( p_pidm  => pidm,
                                          p_term  => hold_term,
                                          p_lmod  => lv_lmod_code,
                                          p_key_seqno => seq_no);     
            sokccur.p_number_of_lcur (    p_term       =>  hold_term,
                                   p_lcurAdmtCount  =>  lv_lcurAdmtCount,
                                   p_lcurRecrCount  =>  lv_lcurRecrCount,
                                   p_lcurOutcCount  =>  lv_lcurOutcCount,
                                   p_lcurLrnrCount  =>  lv_lcurLrnrCount);
            IF (disp_secd = FALSE) THEN
               limit := 1;
            ELSIF (lv_lcurAdmtCount<=1 )THEN
               limit := lv_lcurAdmtCount;
            ELSE
               limit := 2;
            END IF;

            FOR i IN 1..NVL (limit, 0)
            LOOP
            sokccur.p_parse_lcur_data(p_lmod        => lv_lmod_code,
                                      p_term        => hold_term,
                                      p_lcurindex   => i,
                                      p_seqno       => lv_seqno,
                                      p_levl        => lv_levl,
                                      p_coll_code   => lv_coll,
                                      p_camp_code   => lv_camp,
                                      p_degc_code   => lv_degc,
                                      p_program     => lv_program,
                                      p_term_ctlg   => lv_term_ctlg,
                                      p_term_admit  => lv_term_admit,
                                      p_term_matric => lv_term_matric,
                                      p_admt_code   => lv_admt,
                                      p_roll_ind    => lv_roll_ind,
                                      p_lcur_rule   => lv_rule);
                                                                         
            -- Assign the out parameters value to variables
            IF lv_program IS NOT NULL AND f_prog_web_ind(lv_program) THEN
                IF NOT table_open AND (count1 = 0) THEN
			twbkfrmt.p_tableopen('DATAENTRY',
					     cattributes => g$_nls.get('BWCKCAP1-0044',
								       'SQL',
			'summary="This table allows the user to select a valid combination of program, degree and major as well as an evaluation termect "'));
			disp_curr  := TRUE;
			table_open := TRUE;
                END IF;
                count1 := count1 + 1;  
                IF (i = 1) THEN
                    P_S_var := 'P';
                ELSE 
                    P_S_var := 'S';
                END IF; 
                        twbkfrmt.p_tablerowopen;
                        /* 1-1C08BT 7.3.3.  Append saradap_appl_no TO PROGRAM value. */
                        twbkfrmt.p_tabledata(htf.formradio('program',
                                                           P_S_var ||hold_term||seq_no,
                                                           cattributes => ' ID="program_id' ||
                                                                          count1 || '"'));
                        twbkfrmt.p_tabledata(twbkfrmt.f_formlabel(lbl_prog,
                                                                  idname => 'program_id' ||
                                                                            count1) ||
                                             twbkfrmt.f_printtext('&nbsp;'));
                        twbkfrmt.p_tabledata(get_program_desc(lv_program));
                        twbkfrmt.p_tablerowclose;
                        twbkfrmt.p_tablerowopen;
                        twbkfrmt.p_tabledata('&nbsp;');
                        twbkfrmt.p_tabledata(twbkfrmt.f_formlabel(g$_nls.get('BWCKCAP1-0045',
                                                                             'SQL',
                                                                             'Degree: ')));
                        twbkfrmt.p_tabledata(get_degc_desc(lv_degc));
                        twbkfrmt.p_tablerowclose;                           
                sokccur.p_parse_lfos_data(p_lmod             => lv_lmod_code,
                                          p_term             => hold_term,
                                          p_seqno            => lv_seqno,
                                          p_lcurindex        => i,
                                          p_lfosindex        => 1,
                                          p_concindex        => NULL,
                                          p_lfstcode         => sb_fieldofstudy_str.f_major,
                                          p_majr_code        => lv_majr,
                                          p_term_code_ctlg   => lv_term_ctlg,
                                          p_term_code_end    => lv_term_end,
                                          p_dept_code        => lv_dept,
                                          p_lfos_rule        => lv_lfosrule,
                                          p_lfosseqno        => lv_lfosseqno,
                                          p_conc_attach_rule => lv_concrule,
                                          p_start_date       => lv_startdate,
                                          p_end_date         => lv_enddate,
                                          p_tmst_code        => lv_tmstcode,
                                          p_rolled_seqno     => lv_rolledseqno,
                                          p_majr_code_attach => lv_majr_attach);
                        twbkfrmt.p_tablerowopen;
                        twbkfrmt.p_tabledata('&nbsp;');
                        twbkfrmt.p_tabledata(twbkfrmt.f_formlabel(g$_nls.get('BWCKCAP1-0046',
                                                                             'SQL',
                                                                             'Major: ')));
                        twbkfrmt.p_tabledata(get_majr_desc(lv_majr));
                        twbkfrmt.p_tablerowclose;
                        twbkfrmt.p_tablerowopen;
                        twbkfrmt.p_tabledata('&nbsp;');
                        twbkfrmt.p_tablerowclose;                
            
		IF (count1 = lv_lcurAdmtCount) THEN
		    twbkfrmt.p_tablerowopen;
		    twbkfrmt.p_tabledata('&nbsp;');
		    twbkfrmt.p_tablerowclose;
		END IF;
	    END IF;
	END LOOP;
 
        END LOOP;
        
	IF (lv_lcurAdmtCount = 0) THEN
	    twbkwbis.p_dispinfo('bwckcapp.P_DispCurrent', 'NOCUR');
	ELSE
	    twbkfrmt.p_tableclose;
        END IF;
        p_count := count1;
    END p_disptermsourcesaradap;   
   -------------------------------------------------------------------------
   PROCEDURE P_DispTermSourceShrdgmr (
      pidm        IN       SPRIDEN.SPRIDEN_PIDM%TYPE DEFAULT NULL,
      source1     IN       VARCHAR2 DEFAULT NULL,
      disp_secd   IN       BOOLEAN DEFAULT FALSE,
      p_term_in   IN       STVTERM.STVTERM_CODE%TYPE,
      p_count     OUT      NUMBER) IS 
    program    smrrqcm.smrrqcm_program%TYPE DEFAULT NULL;
    request_no smrrqcm.smrrqcm_request_no%TYPE DEFAULT NULL;
    table_open BOOLEAN DEFAULT FALSE;
    disp_curr  BOOLEAN DEFAULT FALSE;
    seq_no   sorlcur.sorlcur_key_seqno%TYPE ;
    lv_lmod_code stvlmod.stvlmod_code%TYPE := sb_curriculum_str.f_outcome;
    lv_seqno sorlcur.sorlcur_seqno%TYPE;
    lv_levl sorlcur.sorlcur_levl_code%TYPE;
    lv_coll sorlcur.sorlcur_coll_code%TYPE;
    lv_camp sorlcur.sorlcur_camp_code%TYPE;
    lv_degc sorlcur.sorlcur_degc_code%TYPE;
    lv_program sorlcur.sorlcur_program%TYPE;
    lv_term_ctlg stvterm.stvterm_code%TYPE;
    lv_term_admit stvterm.stvterm_code%TYPE;
    lv_term_matric stvterm.stvterm_code%TYPE;
    lv_admt sorlcur.sorlcur_admt_code%TYPE;
    lv_roll_ind sovlcur.sovlcur_roll_ind%TYPE;
    lv_rule sorlcur.sorlcur_curr_rule%TYPE;
    lv_majr sovlfos.sovlfos_majr_code%TYPE;
    lv_term_end stvterm.stvterm_code%TYPE;
    lv_dept sovlfos.sovlfos_dept_code%TYPE;
    lv_concrule sorlfos.sorlfos_conc_attach_rule%TYPE;
    lv_lfosrule sovlfos.sovlfos_lfos_rule%TYPE;
    lv_lfosseqno sovlfos.sovlfos_seqno%TYPE;
    lv_lfosseqno2 sovlfos.sovlfos_seqno%TYPE;
    lv_startdate DATE;
    lv_enddate DATE;
    lv_majr_attach stvmajr.stvmajr_code%TYPE;
    lv_rolledseqno sorlfos.sorlfos_rolled_seqno%TYPE;
    lv_tmstcode sorlfos.sorlfos_tmst_code%TYPE;
    lv_majr_1 sovlfos.sovlfos_majr_code%TYPE;
    lv_majr_2 sovlfos.sovlfos_majr_code%TYPE;
    lv_majr_3 sovlfos.sovlfos_majr_code%TYPE;
    lv_lcurAdmtCount        NUMBER(4):=NULL;
    lv_lcurRecrCount        NUMBER(4):=NULL;
    lv_lcurOutcCount        NUMBER(4):=NULL;
    lv_lcurLrnrCount        NUMBER(4):=NULL;     
    hold_term   stvterm.stvterm_code%TYPE := p_term_in;
    count1        NUMBER;
    keep_going  BOOLEAN DEFAULT TRUE;
BEGIN
    count1       := 0;  
     FOR shrdgmr_row IN shrdgmr_all_c(pidm, p_term_in)
        LOOP
         EXIT WHEN shrdgmr_all_c%NOTFOUND;        
 
      -- set all variables from source to values that we'll need later
      -- on to pass to various functions/procedures
      hold_term  := shrdgmr_row.shrdgmr_term_code_ctlg_1;
      seq_no     := shrdgmr_row.shrdgmr_seq_no;       
            sokccur.p_get_curricula_data( p_pidm  => pidm,
                                          p_term  => hold_term,
                                          p_lmod  => lv_lmod_code,
                                          p_key_seqno => seq_no);
            sokccur.p_number_of_lcur (    p_term       =>  hold_term,
	                                  p_lcurAdmtCount  =>  lv_lcurAdmtCount,
	                                  p_lcurRecrCount  =>  lv_lcurRecrCount, 
	                                  p_lcurOutcCount  =>  lv_lcurOutcCount,
                                          p_lcurLrnrCount  =>  lv_lcurLrnrCount);
                                                     
            sokccur.p_parse_lcur_data(p_lmod        => lv_lmod_code,
                                      p_term        => p_term_in,
                                      p_lcurindex   => 1,
                                      p_seqno       => lv_seqno,
                                      p_levl        => lv_levl,
                                      p_coll_code   => lv_coll,
                                      p_camp_code   => lv_camp,
                                      p_degc_code   => lv_degc,
                                      p_program     => lv_program,
                                      p_term_ctlg   => lv_term_ctlg,
                                      p_term_admit  => lv_term_admit,
                                      p_term_matric => lv_term_matric,
                                      p_admt_code   => lv_admt,
                                      p_roll_ind    => lv_roll_ind,
                                      p_lcur_rule   => lv_rule);
                                                                         
            -- Assign the out parameters value to variables
            IF lv_program IS NOT NULL AND f_prog_web_ind(lv_program) THEN
                IF NOT table_open AND (count1 = 0) THEN
			twbkfrmt.p_tableopen('DATAENTRY',
					     cattributes => g$_nls.get('BWCKCAP1-0047',
								       'SQL',
			'summary="This table allows the user to select a valid combination of program, degree and major as well as an evaluation termect "'));
			disp_curr  := TRUE;
			table_open := TRUE;
                END IF;
                count1 := count1 + 1;                 


                IF (keep_going) THEN
                        twbkfrmt.p_tablerowopen;
                         twbkfrmt.p_tabledata(htf.formradio('program',
                                                              hold_term||'_'||to_char(seq_no),
                                                              cattributes => ' ID="program_id' ||
                                                              count1 || '"'));
                        twbkfrmt.p_tabledata(twbkfrmt.f_formlabel(lbl_prog,
                                                                  idname => 'program_id' ||
                                                                  count1) ||
                                             twbkfrmt.f_printtext('&nbsp;'));
                        twbkfrmt.p_tabledata(get_program_desc(lv_program));
                        twbkfrmt.p_tablerowclose;
                        twbkfrmt.p_tablerowopen;
                        twbkfrmt.p_tabledata('&nbsp;');
                        twbkfrmt.p_tabledata(twbkfrmt.f_formlabel(g$_nls.get('BWCKCAP1-0048',
                                                                             'SQL',
                                                                             'Degree: ')));
                        twbkfrmt.p_tabledata(get_degc_desc(lv_degc));
                        twbkfrmt.p_tablerowclose;                           
                sokccur.p_parse_lfos_data(p_lmod             => lv_lmod_code,
                                          p_term             => hold_term,
                                          p_seqno            => lv_seqno,
                                          p_lcurindex        => 1,
                                          p_lfosindex        => 1,
                                          p_concindex        => NULL,
                                          p_lfstcode         => sb_fieldofstudy_str.f_major,
                                          p_majr_code        => lv_majr,
                                          p_term_code_ctlg   => lv_term_ctlg,
                                          p_term_code_end    => lv_term_end,
                                          p_dept_code        => lv_dept,
                                          p_lfos_rule        => lv_lfosrule,
                                          p_lfosseqno        => lv_lfosseqno,
                                          p_conc_attach_rule => lv_concrule,
                                          p_start_date       => lv_startdate,
                                          p_end_date         => lv_enddate,
                                          p_tmst_code        => lv_tmstcode,
                                          p_rolled_seqno     => lv_rolledseqno,
                                          p_majr_code_attach => lv_majr_attach);
                        twbkfrmt.p_tablerowopen;
                        twbkfrmt.p_tabledata('&nbsp;');
                        twbkfrmt.p_tabledata(twbkfrmt.f_formlabel(g$_nls.get('BWCKCAP1-0049',
                                                                             'SQL',
                                                                             'Major: ')));
                        twbkfrmt.p_tabledata(get_majr_desc(lv_majr));
                        twbkfrmt.p_tablerowclose;
                        twbkfrmt.p_tablerowopen;
                        twbkfrmt.p_tabledata('&nbsp;');
                        twbkfrmt.p_tablerowclose;                
            
                
		IF (count1 = lv_lcurOutcCount) THEN
		    twbkfrmt.p_tablerowopen;
		    twbkfrmt.p_tabledata('&nbsp;');
		    twbkfrmt.p_tablerowclose;
		END IF;


                 IF ((disp_secd = FALSE) AND (count1 >=1)) THEN
                    keep_going := FALSE;
                 END IF;

                END IF;
	    END IF;
-- 	END LOOP;

	END LOOP;
	IF (lv_lcurOutcCount = 0) THEN
	    twbkwbis.p_dispinfo('bwckcapp.P_DispCurrent', 'NOCUR');
	ELSE
	    twbkfrmt.p_tableclose;
        END IF;
        p_count := count1;
    END P_DispTermSourceShrdgmr;    
   -------------------------------------------------------------------------
   PROCEDURE P_DispTermSourceSrbrecr (
      pidm        IN       SPRIDEN.SPRIDEN_PIDM%TYPE DEFAULT NULL,
      source1     IN       VARCHAR2 DEFAULT NULL,
      disp_secd   IN       BOOLEAN DEFAULT FALSE,
      p_term_in   IN       STVTERM.STVTERM_CODE%TYPE,
      p_count     OUT      NUMBER) IS  
    program    smrrqcm.smrrqcm_program%TYPE DEFAULT NULL;
    request_no smrrqcm.smrrqcm_request_no%TYPE DEFAULT NULL;
    table_open BOOLEAN DEFAULT FALSE;
    disp_curr  BOOLEAN DEFAULT FALSE;
    seq_no   sorlcur.sorlcur_key_seqno%TYPE ;
    lv_lmod_code stvlmod.stvlmod_code%TYPE := sb_curriculum_str.f_recruit;
    lv_seqno sorlcur.sorlcur_seqno%TYPE;
    lv_levl sorlcur.sorlcur_levl_code%TYPE;
    lv_coll sorlcur.sorlcur_coll_code%TYPE;
    lv_camp sorlcur.sorlcur_camp_code%TYPE;
    lv_degc sorlcur.sorlcur_degc_code%TYPE;
    lv_program sorlcur.sorlcur_program%TYPE;
    lv_term_ctlg stvterm.stvterm_code%TYPE;
    lv_term_admit stvterm.stvterm_code%TYPE;
    lv_term_matric stvterm.stvterm_code%TYPE;
    lv_admt sorlcur.sorlcur_admt_code%TYPE;
    lv_roll_ind sovlcur.sovlcur_roll_ind%TYPE;
    lv_rule sorlcur.sorlcur_curr_rule%TYPE;
    lv_majr sovlfos.sovlfos_majr_code%TYPE;
    lv_term_end stvterm.stvterm_code%TYPE;
    lv_dept sovlfos.sovlfos_dept_code%TYPE;
    lv_concrule sorlfos.sorlfos_conc_attach_rule%TYPE;
    lv_lfosrule sovlfos.sovlfos_lfos_rule%TYPE;
    lv_lfosseqno sovlfos.sovlfos_seqno%TYPE;
    lv_lfosseqno2 sovlfos.sovlfos_seqno%TYPE;
    lv_startdate DATE;
    lv_enddate DATE;
    lv_majr_attach stvmajr.stvmajr_code%TYPE;
    lv_rolledseqno sorlfos.sorlfos_rolled_seqno%TYPE;
    lv_tmstcode sorlfos.sorlfos_tmst_code%TYPE;
    lv_majr_1 sovlfos.sovlfos_majr_code%TYPE;
    lv_majr_2 sovlfos.sovlfos_majr_code%TYPE;
    lv_majr_3 sovlfos.sovlfos_majr_code%TYPE;
    lv_lcurAdmtCount        NUMBER(4):=NULL;
    lv_lcurRecrCount        NUMBER(4):=NULL;
    lv_lcurOutcCount        NUMBER(4):=NULL;
    lv_lcurLrnrCount        NUMBER(4):=NULL;    
    hold_term   stvterm.stvterm_code%TYPE := p_term_in;
   
    count1        NUMBER;
BEGIN
    count1       := 0;           
    FOR srbrecr_row IN srbrecr_disp_all_c(pidm, p_term_in) LOOP
   
       EXIT WHEN srbrecr_disp_all_c%NOTFOUND;
   
      hold_term :=  srbrecr_row.srbrecr_term_code; ---  srbrecr_row.srbrecr_term_code;
      seq_no := srbrecr_row.srbrecr_admin_seqno;      
            sokccur.p_get_curricula_data( p_pidm  => pidm,
                                          p_term  => hold_term,
                                          p_lmod  => lv_lmod_code,
                                          p_key_seqno => seq_no);
                                                                   
            sokccur.p_parse_lcur_data(p_lmod        => lv_lmod_code,
                                      p_term        => hold_term,
                                      p_lcurindex   => 1,
                                      p_seqno       => lv_seqno,
                                      p_levl        => lv_levl,
                                      p_coll_code   => lv_coll,
                                      p_camp_code   => lv_camp,
                                      p_degc_code   => lv_degc,
                                      p_program     => lv_program,
                                      p_term_ctlg   => lv_term_ctlg,
                                      p_term_admit  => lv_term_admit,
                                      p_term_matric => lv_term_matric,
                                      p_admt_code   => lv_admt,
                                      p_roll_ind    => lv_roll_ind,
                                      p_lcur_rule   => lv_rule);

            -- Assign the out parameters value to variables
            IF lv_program IS NOT NULL AND f_prog_web_ind(lv_program) THEN           
                IF NOT table_open AND (count1 = 0) THEN
                	twbkfrmt.p_tableopen('DATAENTRY',
					     cattributes => g$_nls.get('BWCKCAP1-0050',
								       'SQL',
			'summary="This table allows the user to select a valid combination of program, degree and major as well as an evaluation termect "'));
			disp_curr  := TRUE;
			table_open := TRUE;
                END IF;
                count1 := count1 + 1;  
                
                        twbkfrmt.p_tablerowopen;
                        twbkfrmt.p_tabledata(htf.formradio('program',
                                             hold_term||'_'||to_char(seq_no),
                                             cattributes => ' ID="program_id' ||
                                             count1 || '"'));                        
                        twbkfrmt.p_tabledata(twbkfrmt.f_formlabel(lbl_prog,
                                                                  idname => 'program_id' ||
                                                                            count1) ||
                                             twbkfrmt.f_printtext('&nbsp;'));
                        twbkfrmt.p_tabledata(get_program_desc(lv_program));
                        twbkfrmt.p_tablerowclose;
                        twbkfrmt.p_tablerowopen;
                        twbkfrmt.p_tabledata('&nbsp;');
                        twbkfrmt.p_tabledata(twbkfrmt.f_formlabel(g$_nls.get('BWCKCAP1-0051',
                                                                             'SQL',
                                                                             'Degree: ')));
                        twbkfrmt.p_tabledata(get_degc_desc(lv_degc));
                        twbkfrmt.p_tablerowclose;                           
                sokccur.p_parse_lfos_data(p_lmod             => lv_lmod_code,
                                          p_term             => hold_term,
                                          p_seqno            => lv_seqno,
                                          p_lcurindex        => 1,
                                          p_lfosindex        => 1,
                                          p_concindex        => NULL,
                                          p_lfstcode         => sb_fieldofstudy_str.f_major,
                                          p_majr_code        => lv_majr,
                                          p_term_code_ctlg   => lv_term_ctlg,
                                          p_term_code_end    => lv_term_end,
                                          p_dept_code        => lv_dept,
                                          p_lfos_rule        => lv_lfosrule,
                                          p_lfosseqno        => lv_lfosseqno,
                                          p_conc_attach_rule => lv_concrule,
                                          p_start_date       => lv_startdate,
                                          p_end_date         => lv_enddate,
                                          p_tmst_code        => lv_tmstcode,
                                          p_rolled_seqno     => lv_rolledseqno,
                                          p_majr_code_attach => lv_majr_attach);
                        twbkfrmt.p_tablerowopen;
                        twbkfrmt.p_tabledata('&nbsp;');
                        twbkfrmt.p_tabledata(twbkfrmt.f_formlabel(g$_nls.get('BWCKCAP1-0052',
                                                                             'SQL',
                                                                             'Major: ')));
                        twbkfrmt.p_tabledata(get_majr_desc(lv_majr));
                        twbkfrmt.p_tablerowclose;
                        twbkfrmt.p_tablerowopen;
                        twbkfrmt.p_tabledata('&nbsp;');
                        twbkfrmt.p_tablerowclose;                
            
                IF (count1 = lv_lcurRecrCount) THEN
                    twbkfrmt.p_tablerowopen;
                    twbkfrmt.p_tabledata('&nbsp;');
                    twbkfrmt.p_tablerowclose;
                END IF;
            END IF;
    
          
        END LOOP;
        IF (lv_lcurRecrCount = 0) THEN
            twbkwbis.p_dispinfo('bwckcapp.P_DispCurrent', 'NOCUR');
        ELSE
            twbkfrmt.p_tableclose;
        END IF;
        p_count := count1;
    END P_DispTermSourceSrbrecr;       
   -------------------------------------------------------------------------    
   --
   --  This procedure formats table column labels
   --  on dispcurrent for all curriculumn sources.
   --

   PROCEDURE p_dispcurrent_table(label_in IN VARCHAR2 DEFAULT NULL,
                                 prog_in  IN smrrqcm.smrrqcm_program%TYPE,
                                 reqno_in IN smrrqcm.smrrqcm_request_no%TYPE,
                                 term_in  IN stvterm.stvterm_code%TYPE,
                                 levl_in  IN stvlevl.stvlevl_code%TYPE,
                                 camp_in  IN stvcamp.stvcamp_code%TYPE,
                                 coll_in  IN stvcoll.stvcoll_code%TYPE,
                                 degc_in  IN stvdegc.stvdegc_code%TYPE) 
   IS
      XSLTREPORT    BOOLEAN DEFAULT FALSE;
   BEGIN
      -- Primary Curric Table
      twbkfrmt.p_tablerowopen;
      twbkfrmt.p_tabledataheader(cvalue => label_in, ccolspan => '6');
      twbkfrmt.p_tablerowclose;
      twbkfrmt.p_tablerowopen;
      twbkfrmt.p_tabledatalabel(lbl_prog);

      IF prog_in IS NULL THEN
         twbkfrmt.p_tabledata(get_program_desc(prog_in));
      ELSE
         IF reqno_in IS NULL THEN
            twbkfrmt.p_tabledata(get_program_desc(prog_in));
         ELSE
            IF XSLTREPORT THEN
               twbkfrmt.P_TableData (
                  twbkfrmt.f_printanchor (
                  curl => twbkfrmt.f_encodeurl
                    (
                    twbkwbis.f_cgibin || 'bwcksxml.report' ||
                    '?p_request_no=' ||
                    twbkfrmt.f_encode(reqno_in)
                    ),
                  ctext => get_program_desc (prog_in)
                  )
             );
          ELSE
            twbkfrmt.p_tabledata(twbkfrmt.f_printanchor(curl  => twbkfrmt.f_encodeurl(twbkwbis.f_cgibin ||
                                                                                      'bwckcapp.P_DispEvalViewOption' ||
                                                                                      '?request_no=' ||
                                                                                      twbkfrmt.f_encode(reqno_in)),
                                                        ctext => get_program_desc(prog_in)));
            END IF;
         END IF;
      END IF;

      twbkfrmt.p_tablerowclose;
      twbkfrmt.p_tablerowopen;
      twbkfrmt.p_tabledatalabel(lbl_ctlg_term);
      twbkfrmt.p_tabledata(get_term_desc(term_in));
      twbkfrmt.p_tablerowclose;
      twbkfrmt.p_tablerowopen;
      twbkfrmt.p_tabledatalabel(lbl_lvl);
      twbkfrmt.p_tabledata(get_levl_desc(levl_in));
      twbkfrmt.p_tablerowclose;
      twbkfrmt.p_tablerowopen;
      twbkfrmt.p_tabledatalabel(lbl_camp);
      twbkfrmt.p_tabledata(get_camp_desc(camp_in));
      twbkfrmt.p_tablerowclose;
      twbkfrmt.p_tablerowopen;
      twbkfrmt.p_tabledatalabel(lbl_coll);
      twbkfrmt.p_tabledata(get_coll_desc(coll_in));
      twbkfrmt.p_tablerowclose;
      twbkfrmt.p_tablerowopen;
      twbkfrmt.p_tabledatalabel(lbl_degc);
      twbkfrmt.p_tabledata(get_degc_desc(degc_in));
      twbkfrmt.p_tablerowclose;
   END p_dispcurrent_table;

   -------------------------------------------------------------------------
   --
   --  This procedure formats table column data
   --  for the first major only
   --  on dispcurrent for all curriculumn sources.
   --

   PROCEDURE p_dispcurrent_major1_format(majr1_in IN stvmajr.stvmajr_code%TYPE,
                                         conc1_in IN stvmajr.stvmajr_code%TYPE,
                                         dept1_in IN stvdept.stvdept_code%TYPE,
                                         conc2_in IN stvmajr.stvmajr_code%TYPE,
                                         conc3_in IN stvmajr.stvmajr_code%TYPE) IS
      conc_printed BOOLEAN;
   BEGIN
      -- Major one table
      IF get_majr_desc(majr1_in) IS NOT NULL THEN
         twbkfrmt.p_tablerowopen;
         twbkfrmt.p_tabledatalabel(lbl_majr1);
         twbkfrmt.p_tabledata(get_majr_desc(majr1_in));
         twbkfrmt.p_tablerowclose;
      END IF;

      IF get_dept_desc(dept1_in) IS NOT NULL THEN
         twbkfrmt.p_tablerowopen;
         twbkfrmt.p_tabledatalabel(lbl_dept1, cnowrap => 'NOWRAP');
         twbkfrmt.p_tabledata(get_dept_desc(dept1_in));
         twbkfrmt.p_tablerowclose;
      END IF;

      conc_printed := FALSE;

      IF get_majr_desc(conc1_in) IS NOT NULL THEN
         twbkfrmt.p_tablerowopen;
         twbkfrmt.p_tabledatalabel(lbl_conc1);
         twbkfrmt.p_tabledataopen;
         twbkfrmt.p_printtext(get_majr_desc(conc1_in));
         conc_printed := TRUE;
      END IF;

      IF get_majr_desc(conc2_in) IS NOT NULL THEN
         twbkfrmt.p_printtext(', ' || get_majr_desc(conc2_in));
         conc_printed := TRUE;
      END IF;

      IF get_majr_desc(conc3_in) IS NOT NULL THEN
         twbkfrmt.p_printtext(', ' || get_majr_desc(conc3_in));
         conc_printed := TRUE;
      END IF;

      IF conc_printed THEN
         twbkfrmt.p_tabledataclose;
         twbkfrmt.p_tablerowclose;
      END IF;
   END p_dispcurrent_major1_format;

   -------------------------------------------------------------------------
   --
   --  This procedure formats table column data
   --  for the second major only
   --  on dispcurrent for all curriculumn sources.
   --
   PROCEDURE p_dispcurrent_major2_format(majr2_in IN stvmajr.stvmajr_code%TYPE,
                                         conc1_in IN stvmajr.stvmajr_code%TYPE,
                                         dept2_in IN stvdept.stvdept_code%TYPE,
                                         conc2_in IN stvmajr.stvmajr_code%TYPE,
                                         conc3_in IN stvmajr.stvmajr_code%TYPE) IS
   BEGIN
      -- Major two Table
      twbkfrmt.p_tablerowopen;
      twbkfrmt.p_tabledatalabel(lbl_majr2);
      twbkfrmt.p_tabledata(get_majr_desc(majr2_in));
      twbkfrmt.p_tablerowclose;
      
      IF get_dept_desc(dept2_in) IS NOT NULL THEN
         twbkfrmt.p_tablerowopen;
         twbkfrmt.p_tabledatalabel(lbl_dept2);
         twbkfrmt.p_tabledata(get_dept_desc(dept2_in));
         twbkfrmt.p_tablerowclose;
      END IF;          

      twbkfrmt.p_tablerowopen;
      IF get_majr_desc(conc1_in) IS NOT NULL THEN      
         twbkfrmt.p_tabledatalabel(lbl_conc1);
      END IF;
      twbkfrmt.p_tabledataopen;

      IF get_majr_desc(conc1_in) IS NOT NULL THEN
         twbkfrmt.p_printtext(get_majr_desc(conc1_in));

         IF get_majr_desc(conc2_in) IS NOT NULL THEN
            twbkfrmt.p_printtext(', ');
         END IF;
      END IF;

      IF get_majr_desc(conc2_in) IS NOT NULL THEN
         twbkfrmt.p_printtext(get_majr_desc(conc2_in));

         IF get_majr_desc(conc3_in) IS NOT NULL THEN
            twbkfrmt.p_printtext(', ');
         END IF;
      END IF;

      IF get_majr_desc(conc3_in) IS NOT NULL THEN
         twbkfrmt.p_printtext(get_majr_desc(conc3_in));
      END IF;

      twbkfrmt.p_tabledataclose;
      twbkfrmt.p_tablerowclose;
   END p_dispcurrent_major2_format;

   -------------------------------------------------------------------------
   --
   --  This procedure formats table column data
   --  for the minors only
   --  on dispcurrent for all curriculumn sources.
   --
   PROCEDURE p_dispcurrent_minor_format(minr1_in IN stvmajr.stvmajr_code%TYPE,
                                        minr2_in IN stvmajr.stvmajr_code%TYPE) IS
   BEGIN
      -- Minors Table
      twbkfrmt.p_tablerowopen;
      IF get_majr_desc(minr1_in) IS NOT NULL THEN
         twbkfrmt.p_tabledatalabel(lbl_minr1);
      END IF;
      twbkfrmt.p_tabledataopen;

      IF get_majr_desc(minr1_in) IS NOT NULL THEN
         twbkfrmt.p_printtext(get_majr_desc(minr1_in));

         IF get_majr_desc(minr2_in) IS NOT NULL THEN
            twbkfrmt.p_printtext(', ');
         END IF;
      END IF;

      IF get_majr_desc(minr2_in) IS NOT NULL THEN
         twbkfrmt.p_printtext(get_majr_desc(minr2_in));
      END IF;

      twbkfrmt.p_tabledataclose;
      twbkfrmt.p_tablerowclose;
   END p_dispcurrent_minor_format;

   -------------------------------------------------------------------------
   --
   -- Procedure based of bwckflib.P_SelDefTerm. Created under SCOMWEB
   -- to resolve any dependancy issues between web products.
   --
   PROCEDURE p_seldefterm(term              IN stvterm.stvterm_code%TYPE DEFAULT NULL,
                          calling_proc_name IN VARCHAR2 DEFAULT NULL) IS
      CURSOR sorrtrm1c IS
         SELECT stvterm_code,
                stvterm_desc
           FROM stvterm,
                sobterm
          WHERE nvl(sobterm_web_capp_term_ind, 'N') = 'Y'
            AND stvterm_code = sobterm_term_code
            AND sobterm_dynamic_sched_term_ind = 'Y'
          ORDER BY 1 DESC;

      CURSOR sorrtrmc IS
         SELECT stvterm_code,
                stvterm_desc
           FROM stvterm,
                sobterm
          WHERE nvl(sobterm_reg_allowed, 'N') = 'Y'
         UNION
         SELECT a.stvterm_code,
                g$_nls.get('BWCKCAP1-0053',
                           'SQL',
                           '%01% (View Schedule Only)',
                           a.stvterm_desc)
           FROM stvterm a,
                sfbetrm
          WHERE sfbetrm_pidm = global_pidm
            AND a.stvterm_code = sfbetrm_term_code
          ORDER BY 1 DESC;

      CURSOR stvterm_dates_c (p_term STVTERM.STVTERM_CODE%TYPE) IS
        SELECT TO_CHAR(stvterm_start_date,twbklibs.date_display_fmt)
               ||'-'||
               TO_CHAR(stvterm_end_date,twbklibs.date_display_fmt)
          FROM stvterm
         WHERE stvterm_code = p_term;

      menu_name      VARCHAR2(30);
      gtvsdax_rec    gtvsdax%ROWTYPE;
      stvterm_rec    stvterm%ROWTYPE;
      sorrtrm_rec    sorrtrmc%ROWTYPE;
      row_count      NUMBER DEFAULT NULL;
      lv_term_date   VARCHAR2(400):= NULL;
      lv_desc_length NUMBER;

   BEGIN
      IF NOT twbkwbis.f_validuser(global_pidm) THEN
         RETURN;
      END IF;

      bwckfrmt.p_open_doc('bwckcapp.P_SelDefTerm');
      htp.br;
      htp.formopen(twbkwbis.f_cgibin || calling_proc_name);
      twbkwbis.p_dispinfo('bwckcapp.P_SelDefTerm', 'DEFAULT');
      row_count := 0;
--
-- Check GTVSDAX 'WEBTRMDTE' controls. If N, display only term descriptions 
-- in term pull-down menu.  If Y, display term start and end dates as well. 
--
      IF NVL (twbkwbis.f_getparam(global_pidm,'STUFAC_IND'),'STU') = 'FAC'
      THEN
        gtvsdax_rec := goksels.f_get_gtvsdax_row('FACWEB','WEBTRMDTE');
      ELSE
        gtvsdax_rec := goksels.f_get_gtvsdax_row('STUWEB','WEBTRMDTE');
      END IF;
      --
      -- Minor code change from original bwskflib.P_SelDefTerm,
      -- adding "DISP" and "WHATIF" to evaluation criteria
      -- to capture WebCAPP packages.
      --

      IF instr(upper(calling_proc_name), 'ADD') > 0 OR
         instr(upper(calling_proc_name), 'CHG') > 0 OR
         instr(upper(calling_proc_name), 'FEE') > 0 OR
         instr(upper(calling_proc_name), 'CHANGE') > 0 OR
         instr(upper(calling_proc_name), 'SEARCH') > 0 OR
         instr(upper(calling_proc_name), 'ALTPIN') > 0 OR
         instr(upper(calling_proc_name), 'DISP') > 0 OR
         instr(upper(calling_proc_name), 'WHATIF') > 0 THEN
--
         FOR sorrtrm IN sorrtrm1c
         LOOP
            IF sorrtrm1c%ROWCOUNT = 1 THEN
               twbkfrmt.p_tableopen('DATAENTRY',
                                    cattributes => g$_nls.get('BWCKCAP1-0054',
                                                              'SQL',
                                                              'summary="This table is for term selection."'));
               twbkfrmt.p_tablerowopen;
               twbkfrmt.p_tabledatalabel(twbkfrmt.f_formlabel(g$_nls.get('BWCKCAP1-0055',
                                                                         'SQL',
                                                                         'Select a Term: '),
                                                              idname => 'term_in_id'));
               twbkfrmt.p_tabledataopen;
               htp.formselectopen('term_in',
                                  NULL,
                                  1,
                                  cattributes => ' ID="term_in_id"');
            END IF;
--
            IF gtvsdax_rec.gtvsdax_external_code = 'Y'
            THEN
              OPEN stvterm_dates_c(sorrtrm.stvterm_code);
              FETCH stvterm_dates_c INTO lv_term_date;
              CLOSE stvterm_dates_c;
              SELECT 50 - length(sorrtrm.stvterm_desc)
                INTO lv_desc_length
                FROM dual;
              lv_term_date :=rpad(' ', lv_desc_length, ' . ') ||lv_term_date ;
            ELSE
              lv_term_date := NULL;
            END IF;

            IF term IS NOT NULL AND sorrtrm.stvterm_code = term THEN
               twbkwbis.p_formselectoption(sorrtrm.stvterm_desc||lv_term_date,
                                           sorrtrm.stvterm_code);
            ELSE
               twbkwbis.p_formselectoption(sorrtrm.stvterm_desc||lv_term_date,
                                           sorrtrm.stvterm_code);
            END IF;

            row_count := sorrtrm1c%ROWCOUNT;
         END LOOP;

         htp.formselectclose;
      ELSE
         FOR sorrtrm IN sorrtrmc
         LOOP
            IF sorrtrmc%ROWCOUNT = 1 THEN
               twbkfrmt.p_tableopen('DATAENTRY',
                                    cattributes => g$_nls.get('BWCKCAP1-0056',
                                                              'SQL',
                                                              'summary="This table is for term selection."'));
               twbkfrmt.p_tablerowopen;
               twbkfrmt.p_tabledatalabel(twbkfrmt.f_formlabel(g$_nls.get('BWCKCAP1-0057',
                                                                         'SQL',
                                                                         'Term '),
                                                              idname => 'term_in_id2'));
               twbkfrmt.p_tabledataopen;
               htp.formselectopen('term_in',
                                  NULL,
                                  1,
                                  cattributes => ' ID="term_in_id2"');
            END IF;
--
            IF gtvsdax_rec.gtvsdax_external_code = 'Y'
            THEN
              OPEN stvterm_dates_c(sorrtrm.stvterm_code);
              FETCH stvterm_dates_c INTO lv_term_date;
              CLOSE stvterm_dates_c;
              SELECT 50 - length(sorrtrm.stvterm_desc)
                INTO lv_desc_length
                FROM dual;
              lv_term_date :=rpad(' ', lv_desc_length, ' . ') ||lv_term_date ;
            ELSE
              lv_term_date := NULL;
            END IF;

            IF term IS NOT NULL AND sorrtrm.stvterm_code = term THEN
               twbkwbis.p_formselectoption(sorrtrm.stvterm_desc||lv_term_date,
                                           sorrtrm.stvterm_code);
            ELSE
               twbkwbis.p_formselectoption(sorrtrm.stvterm_desc||lv_term_date,
                                           sorrtrm.stvterm_code);
            END IF;

            row_count := sorrtrmc%ROWCOUNT;
         END LOOP;

         htp.formselectclose;
      END IF;
      twbkfrmt.p_tabledataclose;
      twbkfrmt.p_tablerowclose;

      IF row_count = 0 THEN
         twbkfrmt.p_printtext(g$_nls.get('BWCKCAP1-0058',
                                         'SQL',
                                         'No term available'),
                              class_in => 'fieldlabeltext');
      ELSE
         twbkfrmt.p_tablerowopen;
         twbkfrmt.p_tabledatadead(ccolspan => '2');
         twbkfrmt.p_tablerowclose;
         twbkfrmt.p_tablerowopen;
         twbkfrmt.p_tabledataopen;
         -- 8.0 1-1ADDDD
         htp.formsubmit(NULL, g$_nls.get('BWCKCAP1-0059', 'SQL', 'Submit'));
         twbkfrmt.p_tabledataclose;
         twbkfrmt.p_tabledatadead;
         twbkfrmt.p_tablerowclose;
      END IF;

      twbkfrmt.p_tableclose;
      htp.formclose;
      twbkwbis.p_closedoc(curr_release);
   END p_seldefterm;
   -------------------------------------------------------------------------
-- BOTTOM
END; -- Package Body BWCKCAPP
/
SHOW errors
SET scan on
