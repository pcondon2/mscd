rem gurrddl1.sql
rem
rem table: TWRWAIV
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
ALTER TABLE TAISMGR.TWRWAIV
  add (
  TWRWAIV_SUBSCRIB_INFO     VARCHAR2(1),
  TWRWAIV_DISAPPR_COUNT     VARCHAR2(1)
  );
rem
rem
rem Create comment
rem
COMMENT ON TABLE TAISMGR.TWRWAIV IS
'Student Health Insurance Auditing Table. RFC 3829,  TT HC8322';
COMMENT ON COLUMN TAISMGR.TWRWAIV.TWRWAIV_SUBSCRIB_INFO IS
'Subscriber Information updated by ECI. Initially blank, Y if updated by ECI.';
COMMENT ON COLUMN TAISMGR.TWRWAIV.TWRWAIV_DISAPPR_COUNT IS
'Disapproval Count.  Keep track of disapproved audits.  If an audit is disapproved up to two times, the student will be required to buy health insurtance plan.';
SPOOL OFF;
EXIT;
