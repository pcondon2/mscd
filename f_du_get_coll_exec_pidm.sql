--****************************************************************
--Disclaimer of Liability, Compatibility, or Endorsement
--
--The University of Denver assumes no legal liability or responsibility for the completeness,
--accuracy or usefulness of any of the Software Source Code disclosed. Source Code is 
--provided solely for the requester’s information and is provided strictly "as is." The 
--University of Denver makes no representation or warranty, express or implied, including 
--without limitation, as to: 
--
--1. The accuracy, adequacy, completeness or reliability of the Source Code transmitted; or 
--2. The merchantability or fitness for a particular purpose or use of the Source Code; or 
--3. The results to be obtained from Code. 

--****************************************************************
create or replace function f_du_get_coll_exec_pidm (p_attr_code in VARCHAR2, p_coll_code in VARCHAR2, p_dept_code in VARCHAR2 DEFAULT NULL, p_levl_code VARCHAR2 DEFAULT NULL)
RETURN NUMBER IS

   v_exec_pidm	NUMBER(8);

   CURSOR get_coll_exec_levl_c
   IS
    SELECT sirattr_pidm
      FROM sirattr s1 join sirdpcl d1 on (sirattr_pidm = sirdpcl_pidm)
     WHERE s1.sirattr_term_code_eff =
        	(select max(sirattr_term_code_eff) from sirattr s2
		 where s2.sirattr_pidm = s1.sirattr_pidm)
       AND d1.sirdpcl_term_code_eff =
	        (select max(sirdpcl_term_code_eff) from sirdpcl d2
		where d2.sirdpcl_pidm = d1.sirdpcl_pidm)
       AND decode(s1.sirattr_fatt_code,'DESD','DEAN','DECH','CHAR',s1.sirattr_fatt_code) = p_attr_code
       AND sirdpcl_coll_code = p_coll_code
       AND (sirdpcl_dept_code = p_dept_code or (sirdpcl_dept_code is NULL and p_attr_code = 'DEAN'))
       AND exists (select 'Y' from sirattr s3
		    where s3.sirattr_pidm = s1.sirattr_pidm
		    and s3.sirattr_fatt_code = p_levl_code
		    and s3.sirattr_term_code_eff = s1.sirattr_term_code_eff
		   )
	;

   CURSOR get_coll_exec_c
   IS
    SELECT sirattr_pidm
      FROM sirattr s1 join sirdpcl d1 on (sirattr_pidm = sirdpcl_pidm)
     WHERE s1.sirattr_term_code_eff =
        	(select max(sirattr_term_code_eff) from sirattr s2
		 where s2.sirattr_pidm = s1.sirattr_pidm)
       AND d1.sirdpcl_term_code_eff =
	        (select max(sirdpcl_term_code_eff) from sirdpcl d2
		where d2.sirdpcl_pidm = d1.sirdpcl_pidm)
       AND decode(s1.sirattr_fatt_code,'DESD','DEAN','DECH','CHAR',s1.sirattr_fatt_code) = p_attr_code
       AND sirdpcl_coll_code = p_coll_code
       AND (sirdpcl_dept_code = p_dept_code or (sirdpcl_dept_code is NULL and p_attr_code = 'DEAN'))
	;

BEGIN

   OPEN get_coll_exec_levl_c;
   FETCH get_coll_exec_levl_c INTO v_exec_pidm;

   IF get_coll_exec_levl_c%NOTFOUND THEN
	CLOSE get_coll_exec_levl_c;

	OPEN get_coll_exec_c;
   	FETCH get_coll_exec_c INTO v_exec_pidm;
   	IF get_coll_exec_c%NOTFOUND
   	THEN
		CLOSE get_coll_exec_c;
		RETURN 0;
   	ELSE
		CLOSE get_coll_exec_c;
		RETURN v_exec_pidm;
   	END IF;
   ELSE
	CLOSE get_coll_exec_levl_c;
	RETURN v_exec_pidm;
   END IF;

END;
/
create or replace public synonym f_du_get_coll_exec_pidm for f_du_get_coll_exec_pidm
/
grant execute on f_du_get_coll_exec_pidm to baninst1
/
