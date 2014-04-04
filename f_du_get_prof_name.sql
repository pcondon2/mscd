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
create or replace function f_du_get_prof_name (p_pidm in NUMBER)
RETURN VARCHAR IS

   v_prof_name	VARCHAR2(225);

   CURSOR get_prof_name_c 
   IS
    SELECT spbpers_name_prefix || decode(nvl(spbpers_name_prefix,'X'),'X','',' ') || nvl(spbpers_pref_first_name,spriden_first_name) || ' ' || spriden_last_name || decode(nvl(spbpers_name_suffix,'X'),'X','',', ') || spbpers_name_suffix
      FROM spriden join spbpers
	 on (spriden_pidm = spbpers_pidm)
     WHERE spriden_change_ind = 'N'
       AND spriden_ntyp_code = 'PROF'
       AND spriden_pidm = p_pidm
	;

   CURSOR get_spriden_name_c 
   IS
    SELECT spbpers_name_prefix || decode(nvl(spbpers_name_prefix,'X'),'X','',' ') || nvl(spbpers_pref_first_name,spriden_first_name) || ' ' || spriden_last_name || decode(nvl(spbpers_name_suffix,'X'),'X','',', ') || spbpers_name_suffix
      FROM spriden join spbpers
	 on (spriden_pidm = spbpers_pidm)
     WHERE spriden_change_ind is null
       AND spriden_pidm = p_pidm
	;
BEGIN

   OPEN get_prof_name_c;
   FETCH get_prof_name_c INTO v_prof_name;
   IF get_prof_name_c%NOTFOUND
   THEN
	OPEN get_spriden_name_c;
	FETCH get_spriden_name_c INTO v_prof_name;
	CLOSE get_spriden_name_c;
   END IF;
   CLOSE get_prof_name_c;

   RETURN v_prof_name;

END;
/
create or replace public synonym f_du_get_prof_name for dustu.f_du_get_prof_name
/
