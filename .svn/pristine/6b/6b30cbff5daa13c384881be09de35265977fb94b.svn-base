CONNECT baninst1/&&baninst1_password;
SET SCAN OFF
set echo on
spool xxx 

-- SMKMXML1.SQL - 
--
-- AUDIT TRAIL : 8.2                              LM      10APR2005
-- Initial Creation.
-- AUDIT TRAIL : 8.3.0.1
-- 1) 1-89BGLZ                                    AB      14DEC2009
-- Problem: Clobs larger than 32767 do not get copied using p_appendclob
-- Solution: Modified p_appendclob to read from source CLOB and append to 
-- dest CLOB in a loop so it can support values greater than 32727.
-- AUDIT TRAIL: 8.4                               LM      08JAN2010
-- Manual merge of 8.2.1.1 and 8.2.1.2 code to 8.4 release.
-- AUDIT TRAIL END
--
CREATE OR REPLACE PACKAGE BODY smkmxml AS
   --AUDIT_TRAIL_MSGKEY_UPDATE
-- PROJECT : MSGKEY
-- MODULE  : SMKMXML1
-- SOURCE  : enUS
-- TARGET  : I18N
-- DATE    : Fri Jan 08 13:17:00 2010
-- MSGSIGN : #0000000000000000
--TMI18N.ETR DO NOT CHANGE--
--
   -- FILE NAME..: smkmxml1.sql
   -- RELEASE....: 8.4
   -- OBJECT NAME: smkmxml 
   -- PRODUCT....: STUDENT
   -- USAGE......: Main common package to facilitate XML from dbase
   -- COPYRIGHT..: Copyright(C) 2009 SunGard. All rights reserved.
   --
   -- Contains confidential and proprietary information of SunGard and its subsidiaries.
   -- Use of these materials is limited to SunGard Higher Education licensees, and is
   -- subject to the terms and conditions of one or more written license agreements
   -- between SunGard Higher Education and the licensee in question.
   --
   -- DESCRIPTION:
   --
   -- DESCRIPTION END
   --
   ------------------------------------------------------------------------------
   --
   -- Procedure used to pick up a *.xsl style sheet off the file system.
   --
   PROCEDURE p_loadxsl(p_dir       IN VARCHAR2,
                       p_filename  IN VARCHAR2,
                       smrcrlt_xsl OUT xmltype) IS
-- JDH output files
      xml_file  BFILE;
      siz  INTEGER;
      dir_alias VARCHAR2(255);
      file_name VARCHAR2(255);
      uFile            UTL_FILE.FILE_TYPE;
      OutputFile       VARCHAR2(70) := 'jhorton3_smkmxml.lis';
--   OutputFile      VARCHAR2(70) := '&3';
--        UTL_FILE.PUT_LINE(uFile,v_TitleHeader);
--      uFile := UTL_FILE.FOPEN( '/jobsub', OutputFile, 'w' );      
--      UTL_FILE.FCLOSE( uFile );            
--   NL              VARCHAR2(1)  := CHR(10);
   BEGIN
      uFile := UTL_FILE.FOPEN( '/jobsub', OutputFile, 'w' );    -- JDH      
      FOR rec IN (SELECT * FROM dba_directories)  -- JDH 
      LOOP  -- JDH 
        UTL_FILE.PUT_LINE(uFile,'Name:' || rec.directory_name || ',' || rec.directory_path);    -- JDH
      END LOOP;  -- JDH 
      --
      -- See bwcksxml.report in regards to GTVSDAX in how you might use
      -- a different style sheet (outside of replacing smrcrlt.xsl ).
      --
        UTL_FILE.PUT_LINE(uFile,'pdir:' || p_dir || ',pfilename:' || p_filename);   -- JDH
      IF (p_dir IS NOT NULL and p_filename IS NOT NULL) THEN
        UTL_FILE.PUT_LINE(uFile,'run 1');   -- JDH
         smrcrlt_xsl := XMLTYPE(bfilename(p_dir, p_filename),nls_charset_id('AL32UTF8'));
      ELSE
         --
         -- The default location for the stylesheet is $BANNER_HOME/general/xsl.
         -- The default stylesheet name to render WebCAPP is smrcrlt.xsl.
         --
        UTL_FILE.PUT_LINE(uFile,'run 2');   -- JDH
        xml_file := bfilename('SCHEMA_XSLDIR', 'smrcrlt.xsl');
        siz := DBMS_LOB.GETLENGTH(xml_file);
--        siz := DBMS_LOB.FILEEXISTS(xml_file);
        UTL_FILE.PUT_LINE(uFile,'fil siz:' || TO_CHAR(siz));
         
         DBMS_LOB.FILEGETNAME (xml_file, dir_alias, file_name);
--         DBMS_LOB.FILEGETNAME (bf, dir_alias, file_name);
        UTL_FILE.PUT_LINE(uFile,'fil name:' || file_name);
        UTL_FILE.PUT_LINE(uFile,'path name:' || dir_alias);
         smrcrlt_xsl := XMLTYPE(xml_file,nls_charset_id('AL32UTF8'));
--         smrcrlt_xsl := XMLTYPE(bfilename('SCHEMA_XSLDIR', 'smrcrlt.xsl'),nls_charset_id('AL32UTF8'));
      END IF;
      IF (smrcrlt_xsl IS NULL)  THEN
        UTL_FILE.PUT_LINE(uFile,'xsl is null');   -- JDH
      ELSE
        UTL_FILE.PUT_LINE(uFile,'not null');   -- JDH
      END IF;
      
    UTL_FILE.FCLOSE( uFile );            
   END p_loadxsl;

   ------------------------------------------------------------------------------
   --
   -- Procedure used to output the results of the XML clob to htp.
   --
   PROCEDURE p_htpclob(result_clob IN CLOB) IS
   BEGIN
      IF length(result_clob) > 200 THEN
         htp.prn(substr(result_clob, 1, 200));
         smkmxml.p_htpclob(substr(result_clob, 201, length(result_clob)));
      ELSE
         htp.prn(result_clob);
      END IF;
   END;
   
   ------------------------------------------------------------------------------
   --
   -- Procedure used to print the XML clob via dbms_output.
   --
   PROCEDURE p_printclob(result_clob IN CLOB) IS
   BEGIN
      IF length(result_clob) > 200 THEN
         dbms_output.put_line(substr(result_clob, 1, 200));
         p_printclob(substr(result_clob, 201, length(result_clob)));
      ELSE
         dbms_output.put_line(result_clob);
      END IF;
   END p_printclob;

   ---------------------------------------------------------------------------------------------- 
   --
   -- Procedure used to append the XML Result clob with the most recent result set
   -- of XML information.
   --
   PROCEDURE p_appendclob(dest_clob IN OUT CLOB,
                          src_clob  IN OUT CLOB) IS

      clob_length     NUMBER;
      lv_cnt          INTEGER;                                       -- loop counter.
      lv_max_clob     INTEGER DEFAULT 8191;                          -- max read, read amount.
      lv_xml          VARCHAR2(32727);                               -- varchar to read into.
      lv_tag          VARCHAR2(22) DEFAULT '<?xml version="1.0"?>';  -- xml gen xml header.
      lv_tag_exist    INTEGER;                                       -- if xml gen header exists(recursion).
      lv_gr           INTEGER;                                       -- end position of xml header.
      lv_il           INTEGER;                                       -- loop counter manipulation.
      lv_start        NUMBER;                                        -- indicator as to position to start reading.
      lv_temp         NUMBER;                                        -- to keep clob_length-lv_start
   BEGIN
      clob_length := dbms_lob.getlength(src_clob);
      lv_start := 23; 
      IF clob_length > 1 THEN
         LOOP
            lv_temp := clob_length - lv_start;
            IF lv_temp > 32726 THEN
               lv_temp := 32726;
            END IF;
            DBMS_LOB.READ(src_clob, lv_temp, lv_start, lv_xml);
            lv_start := lv_start + 32726; 
            dbms_lob.writeappend(dest_clob, lv_temp , lv_xml);
            EXIT WHEN lv_start >= clob_length;
         END LOOP;
         dbms_lob.erase(src_clob, clob_length, 1);
         dbms_lob.freetemporary(src_clob);
      END IF;
   END p_appendclob;

   ------------------------------------------------------------------------------
   --
   -- Main Procedure used to format a ref_cursor into an XML wrapped CLOB result set. 
   --
   PROCEDURE p_get_xmlclob(rcursor_in    IN sys_refcursor,
                           result_clob   OUT CLOB)
   IS
      queryctx    dbms_xmlgen.ctxtype; 
   BEGIN

      queryctx    := dbms_xmlgen.newcontext(rcursor_in);
      result_clob := dbms_xmlgen.getxml(queryctx);
      dbms_xmlgen.closecontext(queryctx);        

   END p_get_xmlclob;

   ---------------------------------------------------------------------------------------------- 
   --
   -- Main Procedure used to format a ref_cursor
   -- into an XML wrapped CLOB result set.
   --
   PROCEDURE p_get_xmlclob(rcursor_in    IN sys_refcursor,
                           table_name_in IN VARCHAR2,
                           result_clob   OUT CLOB) IS
   
      queryctx    dbms_xmlgen.ctxtype;
      t_rowsettag VARCHAR2(14);
      t_rowset    VARCHAR2(11);
   
   BEGIN
   
      t_rowsettag := upper(table_name_in) || '_ROWSET';
      t_rowset    := upper(table_name_in) || '_SET';
      queryctx    := dbms_xmlgen.newcontext(rcursor_in);
      dbms_xmlgen.setrowsettag(queryctx, t_rowsettag);
      dbms_xmlgen.setrowtag(queryctx, t_rowset);
      result_clob := dbms_xmlgen.getxml(queryctx);
      dbms_xmlgen.closecontext(queryctx);

   END p_get_xmlclob;

   ---------------------------------------------------------------------------------------------- 
   --
   -- Procedure used to initilize the CLOB used to store the XML Results.
   --
   PROCEDURE p_init_clob(result_clob IN OUT CLOB) IS
   BEGIN
      dbms_lob.createtemporary(result_clob, TRUE, dbms_lob.session);
   END p_init_clob;

------------------------------------------------------------------------------ 
-- BOTTOM BOTTOM BOTTOM
-- Package Body SMKMXML
--
END;
/
show errors
set scan on

