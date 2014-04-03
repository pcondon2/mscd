CONNECT baninst1/&&baninst1_password;
SET SCAN OFF
--
-- bwcksxm1.sql
--
-- AUDIT TRAIL: 8.2                       INIT   DATE
-- Initial  Release of Package             LM     15JAN2009 
-- AUDIT TRAIL: 8.3                       LM     05OCT2009
-- 1. Defect 1-7QLT3R
-- Problem : Degree Evaluation web page no longer displays DEFAULT 
-- information text defined in Web Tailor
-- Solution : Add twbkwbis.p_dispinfo call.
-- AUDIT TRAIL: 8.3.0.1                   LM     12DEC2009
-- 1. Defect 1-8Y4UD7
-- Problems : Email link doesn't show on degree evaluation report.
-- Technical : Implemented the email icon functionality from 
-- bwcksml1.sql
-- 1. Defect 1-80IBHV
-- Problem : Students name does not display on the report.
-- Technical : Add common fac and stu logic to render student
-- information in header location of report. 
-- AUDIT TRAIL: 8.3.0.2                   LM     08FEB2010
-- 1) Defect 1-AV6ANO
-- Problem : The optional dropdown box to show SMACPRT print
-- options does not autosubmit to redraw the page.
-- Technical : Form open was not included in the 
-- original package.
-- AUDIT TRAIL: 8.4                       LM     08FEB2010 
-- 1) Manual merge
-- AUDIT TRAIL END
--
CREATE OR REPLACE PACKAGE BODY bwcksxml AS
   --AUDIT_TRAIL_MSGKEY_UPDATE
-- PROJECT : MSGKEY
-- MODULE  : BWCKSXM1
-- SOURCE  : enUS
-- TARGET  : I18N
-- DATE    : Tue Feb 09 14:43:43 2010
-- MSGSIGN : #0000000000000000
--TMI18N.ETR DO NOT CHANGE--
--
   -- FILE NAME..: bwcksxm1.sql
   -- RELEASE....: 8.4
   -- OBJECT NAME: BWCKSXML
   -- PRODUCT....: SCOMWEB
   -- USAGE......: Package to display WebCAPP output via XML
   -- COPYRIGHT..: Copyright(C) 2009 SunGard. All rights reserved.
   --
   -- Contains confidential and proprietary information of SunGard and its subsidiaries.
   -- Use of these materials is limited to SunGard Higher Education licensees, and is
   -- subject to the terms and conditions of one or more written license agreements
   -- between SunGard Higher Education and the licensee in question.
   --
   ------------------------------------------------------------------------------ 
   --
   -- This procedure is responsible for displaying the New WebCAPP output
   -- That is generated by the API/XML/XSL process.
   --
   PROCEDURE report(p_request_no  IN smrrqcm.smrrqcm_request_no%TYPE DEFAULT NULL,
                    p_stvcprt     IN stvcprt.stvcprt_code%TYPE DEFAULT NULL) IS
   
      pidm             spriden.spriden_pidm%TYPE;
      global_pidm      spriden.spriden_pidm%TYPE;
      term             smbpogn.smbpogn_term_code_eff%TYPE;
      hold_term        stvterm.stvterm_code%TYPE DEFAULT NULL;
      call_path        VARCHAR2(2) DEFAULT NULL;
      hold_request_no  smrrqcm.smrrqcm_request_no%TYPE;
      hold_stvcprt     stvcprt.stvcprt_code%TYPE;
      email            GOREMAL.GOREMAL_EMAIL_ADDRESS%TYPE;
      namestr          VARCHAR2(90) DEFAULT NULL;
      student_name     VARCHAR2(185);
      advr_pidm        SPRIDEN.SPRIDEN_PIDM%TYPE DEFAULT NULL;

      curr_release     CONSTANT VARCHAR2(10) := '8.4';

      path             VARCHAR2(255) DEFAULT NULL;
      xsl_file_name    VARCHAR2(100) DEFAULT NULL;
   
-- JDH output files
      uFile            UTL_FILE.FILE_TYPE;
      OutputFile       VARCHAR2(70) := 'jhorton3_bwcksxm1.lis';
--   OutputFile      VARCHAR2(70) := '&3';
--        UTL_FILE.PUT_LINE(uFile,v_TitleHeader);
--      uFile := UTL_FILE.FOPEN( '/jobsub', OutputFile, 'w' );      
--      UTL_FILE.FCLOSE( uFile );            
--   NL              VARCHAR2(1)  := CHR(10);
   
      smrcrlt_clob CLOB;
      smrcrlt_xsl  xmltype;
      xmldata      xmltype;
      html         xmltype;
      
      stvcprt_row  stvcprt%ROWTYPE;
      smbwcrl_row  smbwcrl%ROWTYPE;

      CURSOR stvcprt_c(p_stvcprt STVCPRT.STVCPRT_CODE%TYPE) IS
      SELECT * 
      FROM STVCPRT 
      WHERE STVCPRT_CODE <> p_stvcprt
        AND STVCPRT_OFFICIAL_IND = 'Y'
      ORDER BY 2 ASC; 
      --
      -- One could alter the above cursor to pull specific compliance print types
      -- to display on the web as a dropdown box to dynamically redraw the report.
      --
      CURSOR smbwcrl_c(term_in STVTERM.STVTERM_CODE%TYPE) IS
      SELECT *
      FROM SMBWCRL
      WHERE SMBWCRL_TERM_CODE = ( SELECT MAX(X.SMBWCRL_TERM_CODE)
                                  FROM SMBWCRL X
                                  WHERE SMBWCRL_TERM_CODE <= term_in );


      FUNCTION f_stvcprt_desc(p_stvcprt STVCPRT.STVCPRT_CODE%TYPE)
      RETURN STVCPRT.STVCPRT_DESC%TYPE IS
         return_value STVCPRT.STVCPRT_DESC%TYPE;

         CURSOR stvcprt_d(p_stvcprt STVCPRT.STVCPRT_CODE%TYPE) IS
         SELECT STVCPRT_DESC
           FROM STVCPRT
          WHERE STVCPRT_CODE = p_stvcprt;
      BEGIN
         OPEN stvcprt_d(p_stvcprt);
         FETCH stvcprt_d INTO return_value;
         CLOSE stvcprt_d; 
         RETURN return_value;
      END f_stvcprt_desc;
 
   BEGIN
   
      uFile := UTL_FILE.FOPEN( '/jobsub', OutputFile, 'w' );  -- JDH     
      UTL_FILE.PUT_LINE(uFile,'Start bwcksxm1 1');    -- JDH
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
      -- Defect 1-80IBHV
      -- Initialize web page for facweb.
      -- ==================================================
      IF NVL (twbkwbis.f_getparam (global_pidm, 'STUFAC_IND'), 'STU') = 'FAC'
      THEN
         -- Format student name.
         -- ==================================================
         student_name := f_format_name (pidm, 'FMIL');
         bwckfrmt.p_open_doc('bwcksxml.report');

         -- Check if student is confidential.
         -- ==================================================
         bwcklibs.P_ConfidStudInfo(pidm, hold_term);
      --
      -- Initialize web page for stuweb.
      -- ==================================================
      ELSE
         bwckfrmt.p_open_doc('bwcksxml.report');
      END IF;
      twbkwbis.P_DispInfo('bwcksxml.report','DEFAULT');

      -- Defect 1-80IBHV
      -- twbkwbis.p_opendoc('bwcksxml.report');
      -- 8.3 Defect 1-7QLT3R
      -- twbkwbis.P_DispInfo('bwcksxml.report','DEFAULT');
      UTL_FILE.PUT_LINE(uFile,'Run bwcksxm1 2');    -- JDH

      OPEN smbwcrl_c(hold_term);
      FETCH smbwcrl_c INTO smbwcrl_row;
      CLOSE smbwcrl_c;
      hold_stvcprt := smbwcrl_row.smbwcrl_dflt_eval_cprt_code;
      --
      -- This section of code is being delivered commented out.
      -- The purpose of this code is to draw a dropdown box
      -- that lists the available compliance print type codes
      -- from the STVCPRT table.
      --
      -- The issue is that STVCPRT does not have a web_ind
      -- to indicate which stvcprt codes should be allowed to
      -- display.  One could easily change the stvcprt_c cursor
      -- in this package for your specific criteria, and activate
      -- this chunk of code.
      --
      -- The purpose would be that the web report page would also
      -- have a drop down box that list other compliance print types
      -- to render the output against.  I.E. A met, notmet, printall,
      -- printtext print types.
      --
      UTL_FILE.PUT_LINE(uFile,'Run bwcksxm1 3');    -- JDH
      htp.p('<p>----------running in bwcksxm1</p>');
/*
      HTP.PRINT('<script LANGUAGE="JavaScript">');
      HTP.PRINT('function formHandler(form){ ');
      HTP.PRINT('var URL = form.site.options[form.site.selectedIndex].value;');
      HTP.PRINT('window.location.href = URL;}');
      HTP.PRINT('</script>');
      --
      -- 
      -- 
      HTP.formopen(twbkwbis.f_cgibin  || 'bwcksxml.report');
      hold_request_no := p_request_no;
      htp.formhidden('p_request_no', hold_request_no);

      twbkfrmt.p_tableopen(cattributes=> 'WIDTH="100%"');
      twbkfrmt.p_tablerowopen;
      twbkfrmt.p_tabledataopen(CALIGN=>'RIGHT');

      htp.formselectopen(g$_nls.get('BWCKSXML-0001',
                                     'SQL',
                                     'p_stvcprt'),
                                     cattributes => 'onChange="form.submit()"');
      --
      -- 
      -- 
      IF p_stvcprt IS NOT NULL THEN
         twbkwbis.p_formselectoption(f_stvcprt_desc(p_stvcprt), p_stvcprt);
         hold_stvcprt := p_stvcprt;
      ELSE
         OPEN smbwcrl_c(hold_term);
         FETCH smbwcrl_c INTO smbwcrl_row;
         CLOSE smbwcrl_c;
         twbkwbis.p_formselectoption(f_stvcprt_desc(smbwcrl_row.smbwcrl_dflt_eval_cprt_code),
                                     smbwcrl_row.smbwcrl_dflt_eval_cprt_code);
         hold_stvcprt := smbwcrl_row.smbwcrl_dflt_eval_cprt_code;
      END IF;
      --
      -- Do not redisplay current working print type in drop down.
      --
      FOR stvcprt_row IN stvcprt_c(hold_stvcprt) 
      LOOP
         twbkwbis.p_formselectoption(stvcprt_row.stvcprt_desc,
                                     stvcprt_row.stvcprt_code);
      END LOOP;
               
      htp.formselectclose;
      twbkfrmt.p_tabledataclose;
      twbkfrmt.p_tablerowclose;
      htp.formclose;
      twbkfrmt.P_TableClose;
*/
      UTL_FILE.PUT_LINE(uFile,'Run bwcksxm1 4');    -- JDH
      --
      -- End of code that is responsible for drawing a drop down on the webpage.
      --
      --
      -- This block of code draws a hyperlink on the capp report page to 
      -- link to the xml output.   Used during development to quickly 
      -- navigate from the HTML to the XML.
      --
      /*
      twbkfrmt.P_PrintText (
         twbkfrmt.f_printanchor (
            curl => twbkfrmt.f_encodeurl
                    (
                    twbkwbis.f_cgibin || 'bwcksxml.xml' ||
                    '?p_request_no=' ||
                    twbkfrmt.f_encode(p_request_no)
                    ),
            ctext => twbkfrmt.f_printtext('XML Output')
         )
      );
      */
      --
      -- Initialize our DATA clob.
      --
      smkmxml.p_init_clob(smrcrlt_clob);
      --
      -- Call the new "API"  that generates a compliance
      -- requests DATA in XML format.
      --
         UTL_FILE.PUT_LINE(uFile,'Run bwcksxm1 4');    -- JDH
   
      smrcrlt.p_get_smrcrlt(pidm, p_request_no, hold_stvcprt, smrcrlt_clob);
      --
      -- Use Oracles builtin to transfor the XML DATA clob from
      -- above into an Oracle XMLType variable.
      --
            UTL_FILE.PUT_LINE(uFile,'Run bwcksxm1 5');    -- JDH

      xmldata := xmltype.createxml(smrcrlt_clob);
      --
      -- The XSL file is now stored on the dbase server machine.
      -- This, as oppossed to, the option of storing this
      -- on the webserver and letting the webserver do the XSLTransformation.
      --
      -- This new process requires :
      -- 1) That an oracle directory be defined in SQL/Dbase.  
      -- 2) The use of Oracles BFILENAME function - to read a file off the host
      --    path/tree - and to load that into a clob variable.
      --
      -- The Stylesheet is currently a hardcoded value that is mapped to 
      -- banner_home/general/xsl/smrcrlt.xsl.  smkmxml.p_loadxsl is hardcoded
      -- to search this path if null values are sent into the procedure.
      --
      -- Alternately, you could fill in an oracle directory name (path)
      -- and a stylesheet name in GTVSDAX for the following values and read
      -- an alternate stylesheet.
      --
      path          := NVL (gokeacc.f_getgtvsdaxextcode ('WCXSLPATH', 'WCXSLPATH'), 'FALSE');
      xsl_file_name := NVL (gokeacc.f_getgtvsdaxextcode ('WCXSLFILE', 'WCXSLFILE'), 'FALSE');
      path := 'SCHEMA_XSLDIR';    -- must be a directory in the DB
      xsl_file_name := 'swrmscp.xsl';
-- Name:SCHEMA_XSLDIR,/u01/oracle/local/xsl
--      FOR rec IN (SELECT * FROM all_directories)
--      LOOP
--        UTL_FILE.PUT_LINE(uFile,'Name:' || rec.directory_name || ',' || rec.directory_path);    -- JDH
--      END LOOP;
            
    UTL_FILE.PUT_LINE(uFile,'Run bwcksxm1 6:' || path || ',' || xsl_file_name);    -- JDH
      --
      -- First, GTVSDAX only allows uppercase external code values; place a lower
      -- function on it for the file name.
      -- Also, if these values are not present, set them to null such that 
      -- smkmxml.p_loadxsl knows to get the xsl from default location.
      --
      IF (xsl_file_name <> 'FALSE') THEN
         xsl_file_name := lower(xsl_file_name);
      END IF;
      IF (path = 'FALSE' OR xsl_file_name = 'FALSE') THEN
         path := NULL;
         xsl_file_name := NULL;
      END IF;
      --
    UTL_FILE.PUT_LINE(uFile,'Run bwcksxm1 7:' || path || ',' || xsl_file_name);    -- JDH
      smkmxml.p_loadxsl(path, xsl_file_name, smrcrlt_xsl);
    UTL_FILE.PUT_LINE(uFile,'Run bwcksxm1 8:' );    -- JDH
      --
      -- Once we call the procedure to read the *.xsl file sheet from
      -- the host/path/directory  - it is returned in XMLType format.
      --
      -- The following line is the Oracles built in transformation process.
      -- It will take our DATA XML XMLType variable,  and transform it
      -- to the stylesheet that is found in the STYLE XSL XMLType variable.
      --
      html := xmldata.transform(smrcrlt_xsl);
    UTL_FILE.PUT_LINE(uFile,'Run bwcksxm1 9:' );    -- JDH
      --
      -- The following line merely prints our "HTML" out to the webpage.
      --
      smkmxml.p_htpclob(html.getclobval());
    UTL_FILE.PUT_LINE(uFile,'Run bwcksxm1 10:' );    -- JDH
      --
      -- Defect 1-8Y4UD7
      -- Email link section.
      --
      htp.br;
      UTL_FILE.PUT_LINE(uFile,'Run bwcksxm1 11:' || call_path );    -- JDH

      UTL_FILE.FCLOSE( uFile );            -- JDH
      IF call_path = 'S' THEN
         advr_pidm := F_GetAdvrPidm(pidm, hold_term);
         email := F_GetEmailAddress(advr_pidm, smbwcrl_row.smbwcrl_fac_email_code);
         IF email IS NOT NULL THEN
            namestr := F_GetEmailNamestr(advr_pidm);
            IF namestr IS NOT NULL THEN
               twbkwbis.P_DispInfo('bwcksmlt.P_DispEvalDetailReq','EMAIL',value1=>email, value2=>namestr );
            END IF;
         END IF;
      END IF;
      IF call_path = 'F' THEN
         email := F_GetEmailAddress(pidm, smbwcrl_row.smbwcrl_stu_email_code);
         IF email IS NOT NULL THEN
            twbkwbis.P_DispInfo('bwlkfcap.P_FacDispCurrent','EMAIL',value1=>email, value2=> student_name );
         END IF;
      END IF;
      --
      --
      --
      twbkwbis.p_closedoc(curr_release);
   
   END report;
   ------------------------------------------------------------------------------
   --
   -- The intent/purpose of this procedure is to display
   -- the XML data to the webpage in its original TREE format.
   --       
   -- This procedure should be thought of as a debugging procedure
   -- to see the xml content without stylesheet transformation.
   -- 
   PROCEDURE xml(p_request_no IN smrrqcm.smrrqcm_request_no%TYPE DEFAULT NULL)
   IS
   
      pidm        spriden.spriden_pidm%TYPE;
      global_pidm spriden.spriden_pidm%TYPE;
      term        smbpogn.smbpogn_term_code_eff%TYPE;
      hold_term   stvterm.stvterm_code%TYPE DEFAULT NULL;
      call_path   VARCHAR2(2) DEFAULT NULL;
      curr_release CONSTANT VARCHAR2(10) := '8.4';
   
      smrcrlt_clob CLOB;
      smrcrlt_xsl  CLOB;
      xmldata xmltype;
      html    xmltype;
      position            INTEGER := 1;
      amount              INTEGER := 5000;
      charString          VARCHAR2(5000);
   
   BEGIN
   
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

      smkmxml.p_init_clob(smrcrlt_clob);
      smrcrlt.p_get_smrcrlt(pidm, p_request_no, NULL, smrcrlt_clob);
      htp.print('<?xml version = "1.0"?>');
      dbms_lob.open(smrcrlt_clob, dbms_lob.lob_readonly);
      loop
          dbms_lob.read(smrcrlt_clob, amount, position, charString);
          htp.prn(charString);
          position := position + amount;
      end loop;
      dbms_lob.freetemporary(smrcrlt_clob);

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      dbms_lob.close(smrcrlt_clob);
      dbms_lob.freetemporary(smrcrlt_clob);
   
   END xml;

  -------------------------------------------

   FUNCTION F_GetAdvrPidm
      (pidm IN spriden.spriden_pidm%type,
       term IN stvterm.stvterm_code%type)
      RETURN spriden.spriden_pidm%TYPE IS

      return_value           spriden.spriden_pidm%TYPE DEFAULT NULL;

      CURSOR get_advr_pidm_c(pidm smrrqcm.smrrqcm_pidm%type,
                             term sgradvr.sgradvr_term_code_eff%type)
      IS
      SELECT spriden_pidm
      FROM   SPRIDEN, SGRADVR
      WHERE  sgradvr_pidm = pidm
      AND    sgradvr_prim_ind = 'Y'
      AND    spriden_pidm = sgradvr_advr_pidm
      AND    spriden_change_ind IS NULL
      AND    sgradvr_term_code_eff = ( SELECT MAX(X.SGRADVR_TERM_CODE_EFF)
                                         FROM SGRADVR X
                                        WHERE X.SGRADVR_PIDM = pidm
                                          AND X.SGRADVR_TERM_CODE_EFF <= term);

   BEGIN

      OPEN get_advr_pidm_c(pidm, term);
      FETCH get_advr_pidm_c INTO
         return_value;
      CLOSE get_advr_pidm_c;

      RETURN return_value;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN return_value;

   END F_GetAdvrPidm;

  -------------------------------------------

   FUNCTION F_GetEmailNamestr
      (  pidm IN spriden.spriden_pidm%type )
      RETURN VARCHAR2 IS

      return_value           VARCHAR2(130) DEFAULT NULL;

      CURSOR get_advr_namestr_c(pidm smrrqcm.smrrqcm_pidm%type)
      IS
      SELECT spriden_first_name || ' ' || spriden_last_name
      FROM   SPRIDEN
      WHERE  spriden_pidm = pidm
      AND    spriden_change_ind IS NULL;

   BEGIN

      OPEN get_advr_namestr_c(pidm);
      FETCH get_advr_namestr_c INTO
         return_value;
      CLOSE get_advr_namestr_c;

      RETURN return_value;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN return_value;

   END F_GetEmailNamestr;

  -------------------------------------------

   FUNCTION F_GetEmailAddress
      (pidm_in       IN spriden.spriden_pidm%type,
       email_code_in IN GOREMAL.GOREMAL_EMAL_CODE%TYPE)
      RETURN GOREMAL.GOREMAL_EMAIL_ADDRESS%TYPE IS

      return_value   goremal.goremal_email_address%type DEFAULT NULL;

      CURSOR get_goremal_email_c(pidm_in GOREMAL.GOREMAL_PIDM%TYPE,
                                 email_code_in goremal.goremal_emal_code%TYPE)
      IS
      SELECT GOREMAL_EMAIL_ADDRESS
      FROM   GOREMAL
      WHERE  GOREMAL_PIDM = pidm_in
      AND    GOREMAL_STATUS_IND = 'A'
      AND    GOREMAL_PREFERRED_IND = 'Y'
      AND    GOREMAL_DISP_WEB_IND = 'Y'
      AND    GOREMAL_EMAL_CODE = email_code_in;

   BEGIN

      OPEN get_goremal_email_c(pidm_in, emaIl_code_in);
      FETCH get_goremal_email_c INTO
         return_value;
      CLOSE get_goremal_email_c;

      RETURN return_value;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN return_value;

   END F_GetEmailAddress;

------------------------------------------------------------------------------ 
-- BOTTOM
END;
/
SHOW ERRORS
SET SCAN ON
