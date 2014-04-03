rem gurrddl1.sql
rem
rem table: TZPIMP1
rem owner: TAISMGR
rem
rem sizing:   C
rem all ddl:  Y
rem table:    Y
rem index:    Y
rem grants:   Y
rem comments: Y
rem
rem **********************************************
rem If the table was dropped, you may want to break
rem the script into two parts.  After the creation
rem of the table, do the import and then run the
rem rest of the script to recreate the indexes,
rem constraints, grants and comments.  This will
rem help performance.  Look for the BREAK HERE
rem marker.
rem **********************************************
rem
CONNECT TAISMGR/&&taismgr_password
rem
SET ECHO ON FEEDB ON TIME OFF TIMING OFF;
rem
SPOOL gurrddl2
rem
ALTER TABLE TAISMGR.TZPIMP1
  add (
  TZPIMP1_DISAPPR_COUNT    VARCHAR2(1)
  );
ALTER TABLE TAISMGR.TZPIMP1
  RENAME TZPIMP1_SECTION_TYPE TO TZPIMP1_SUBSCRIB_INFO;
rem
rem Create comment
rem
COMMENT ON TABLE TAISMGR.TZPIMP1 IS
'Table for storing import date for insurance audit - RFC3829, TT HC8322';
COMMENT ON COLUMN TAISMGR.TZPIMP1.TZPIMP1_SUBSCRIB_INFO IS
'Subscriber Information updated by ECI. Initally blank, Y if updated by ECI.';
COMMENT ON COLUMN TAISMGR.TZPIMP1.TZPIMP1_DISAPPR_COUNT IS
'Disapproval Count. Keep track of disapproved audits.';
SPOOL OFF;
EXIT;
