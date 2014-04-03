<?xml version="1.0" encoding="utf-8"?><!-- DWXMLSource="jimcapp.xml" -->
<!DOCTYPE xsl:stylesheet  [
				<!ENTITY nbsp "&#160;">
]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:CappEval="urn:com:sungardhe:student:ComplianceEvaluation:v1.0.0"
                >
<!--
 AUDIT TRAIL: 8.2
 1. Initial Release                                                                           LM  10APRIL2009
 AUDIT TRAIL: 8.2.1.1                                                                         LM  27SEP2009
 1. Defect 1-6JRZLX
    Problem : Out of Last Earned line displays incorrect Met Indicator on degree evaluation.
    Solution : Incorrect equality comparison to determine met indicator.
 2. Defect 1-6J7T50
    Problem : On degree evaluation, "Out of Last Earned" displays a NULL in the used 
    credits/courses fields.
    Solution : Incorrect equality comparison.  Incorrect fields used.
 3. Defect 1-6JRZI5
    Problem : Out of Last Earned does not display values correctly.
    Solution : Correct the fields used to display Out of Last Earned section.
 4. Defect 1-6NK3VV
    Problem : Expected Graduation Date does not display on the report.
    Solution : Field SMRRQCM_EXP_GRAD_DATE was omitted from the section to display.
 5. Defect 1-71XA02
    Problem : In Progress courses show the course source of "R" in the course grade column.
    Solution : Incorrect evaluation criteria against SMRDOAN_CRSE_SOURCE field.
 6. Defect 1-6JRZGV
    Problem : Total Required line on Degree Evaluation displays incorrect Met Indicator.
    Solution : Change met indicator criteria from smbpogn_met_ind to actual evaluation
    of smbpogn required credits and courses.
 7. Defect 1-7PA6RT
    Problem : White space displays above "Program Restricted Subjects & Attributes" 
    heading in WebCAPP.
    Solution : SMRPOSA template contained erronoues line breaks in a for-each template.
 8. Defect 1-6IGV7B
    Problem : Rules do not display met/notmet indicator value.
    Solution : Modify FIRST_ROW template to test whether we are working with a rule
    or a detail line, and display the met indicator based upon what we are displaying.
 9. Defect 1-80IBHV                                                                             AB 18NOV2009
    Problem : Student Name and ID not shown
    Solution : Added template SPRIDEN_ROWSET to display Student's Name and ID
10. Defect 1-8179R7                                                                             AB 19NOV2009
    Problem : Group Requirements Met condition not checking course requirements
    Solution : Added code to check for courses
11. Defect 1-5LWVTD                                                                             AB  24NOV2009
    Problem : The display of the curriculum fields needs to be adjusted on CAPP SSB 
    output page.
    Solution : Cosmetic changes to the  code to match requirements.
12. Defect 1-87O7RP                                                                             LM  12DEC2009
    Problem : Whole number GPA's display with no decimal precision.
    Solution : gpafmt format variable was created to hold the precision
    format for whole number display.  This variable can be customized to
    clients preference.
13. Defect 1-8VKYQS                                                                             LM  12DEC2009
    Problem : Area GPA and Total Credit Hours do not display under detail section.
    Solution : Created new AREA_GPA_FOOTER to render this display.
14. Defect 1-8Q00A5                                                                             LM  12DEC209
    Problem : Catalog year may display incorrectly for degree evaluation on secondary curriculum.
    Solution : Display was incorrectly pointing to SMRRQCM_TERM_CURR_SOURCE_DESC when it should
    have been pointing to SMRRQCM_TERM_CTLG_2_DESC.
15. Defect 1-9MJZ0B                                                                             LM 12DEC2009
    Problem : Descriptions display for subjects, student and course attributes, and terms.
    Solution : Create new variable codedisplay, with a default setting of Y.  All sections
    of the report responsible for displaying this data were altered to have a switch between
    display of the description or code values by toggling the variables value.
16. Defect 1-6VT2CS                                                                             LM 12DEC2009
    Problem : The detail lines conditional logic of And's and Or's do not display.
    Solutions : Atlered the template to add logic to display Condition logic.  This
    solution also required changes to packages smrcrlt*.sql and smkxapi*.sql
 AUDIT TRAIL: 8.2.1.2
 1. Defect 1-876R1F                                                                             AB 23DEC2009
    If condition for testing Course source = 'R' changed from if conditions to When-Otherwise.
 2. Defect 1-8RRJDN                                                                             LM 29DEC2009
    Problem : Course link does not display for course catalog.
    Solution : Implemented href calls to course catalog page for not met requirements.
 3. Defect 1-9Y9GMV                                                                             LM 29DEC2009
    Problem : Sections that display text do not have spaces between the rows on the entered
    forms.
    Solution : Added spacing between display of records to prevent concatenation.
 FILE NAME..: smrcrlt.xsl
 RELEASE....: 8.2.1.2
 PRODUCT....: STUDENT
 USAGE......: This stylesheet formats the xml webcapp.
 COPYRIGHT..: Copyright(C) 2009 SunGard. All rights reserved.
 Contains confidential and proprietary information of SunGard and its subsidiaries.
 Use of these materials is limited to SunGard Higher Education licensees, and is
 subject to the terms and conditions of one or more written license agreements
 between SunGard Higher Education and the licensee in question.
 AUDIT TRAIL END
-->
<xsl:output method="html" indent="no" />
<xsl:param name="credit_value">N</xsl:param>
<xsl:param name="yes_no_ind">N</xsl:param>
<xsl:param name="incl_excl">N</xsl:param>
<xsl:param name="connect_ind">N</xsl:param>
<xsl:variable name="nmet-color">black</xsl:variable>
<xsl:variable name="met-color">black</xsl:variable>
<xsl:variable name="cprt_prle_prog_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_PRLE_PROG_IND"/>
<xsl:variable name="camp_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_PRLE_CAMP_IND"/>
<xsl:variable name="coll_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_PRLE_COLL_IND"/>
<xsl:variable name="degc_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_PRLE_DEGC_IND"/>
<xsl:variable name="levl_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_PRLE_LEVL_IND"/>
<xsl:variable name="eval_term_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_EVAL_TERM_IND"/>
<xsl:variable name="ctlg_term_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_IN_PROG_TERM_IND"/>
<xsl:variable name="exp_grad_date_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_EXP_GRAD_PRT"/>
<xsl:variable name="cprt_pgen_met_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_PGEN_MET_IND"/>
<xsl:variable name="pogn_met_ind" select="/SMRCRLT_XML/SMBPOGN_ROWSET/SMBPOGN_SET/SMBPOGN_MET_IND"/>
<xsl:variable name="cprt_pgen_nmet_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_PGEN_NMET_IND"/>
<xsl:variable name="pogn_min_prog_gpa" select="/SMRCRLT_XML/SMBPOGN_ROWSET/SMBPOGN_SET/SMBPOGN_MIN_PROGRAM_GPA"/>
<xsl:variable name="pogn_act_prog_gpa" select="/SMRCRLT_XML/SMBPOGN_ROWSET/SMBPOGN_SET/SMBPOGN_ACT_PROGRAM_GPA"/>
<xsl:variable name="pogn_min_gpa" select="/SMRCRLT_XML/SMBPOGN_ROWSET/SMBPOGN_SET/SMBPOGN_MIN_GPA"/>
<xsl:variable name="pogn_act_gpa" select="/SMRCRLT_XML/SMBPOGN_ROWSET/SMBPOGN_SET/SMBPOGN_ACT_GPA"/>
<xsl:variable name="pogn_ncrse_req_met_ind" select="/SMRCRLT_XML/SMBPOGN_ROWSET/SMBPOGN_SET/SMBPOGN_NCRSE_REQ_MET_IND"/>
<xsl:variable name="pogn_attr_req_met_ind" select="/SMRCRLT_XML/SMBPOGN_ROWSET/SMBPOGN_SET/SMBPOGN_ATTR_REQ_MET_IND"/>
<xsl:variable name="pogn_addl_level_ind" select="/SMRCRLT_XML/SMBPOGN_ROWSET/SMBPOGN_SET/SMBPOGN_ADDL_LEVEL_IND"/>
<xsl:variable name="pogn_excl_level_ind" select="/SMRCRLT_XML/SMBPOGN_ROWSET/SMBPOGN_SET/SMBPOGN_EXCL_LEVEL_IND"/>
<xsl:variable name="pogn_rstr_s_a_ind" select="/SMRCRLT_XML/SMBPOGN_ROWSET/SMBPOGN_SET/SMBPOGN_RSTR_S_A_IND"/>
<xsl:variable name="pogn_rstr_grd_ind" select="/SMRCRLT_XML/SMBPOGN_ROWSET/SMBPOGN_SET/SMBPOGN_RSTR_GRD_IND"/>
<xsl:variable name="cprt_pcmt_text_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_PCMT_TEXT_IND"/>
<xsl:variable name="cprt_pncr_met_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_PNCR_MET_IND"/>
<xsl:variable name="cprt_pncr_nmet_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_PNCR_NMET_IND"/>
<xsl:variable name="cprt_plvl_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_PLVL_IND"/>
<xsl:variable name="cprt_patr_met_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_PATR_MET_IND"/>
<xsl:variable name="cprt_patr_nmet_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_PATR_NMET_IND"/>
<xsl:variable name="cprt_prsa_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_PRSA_IND"/>
<xsl:variable name="cprt_prsc_text_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_PRSC_TEXT_IND"/>
<xsl:variable name="cprt_prgd_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_PRGD_IND"/>
<xsl:variable name="cprt_prgc_text_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_PRGC_TEXT_IND"/>
<xsl:variable name="cprt_in_prog_term_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_IN_PROG_TERM_IND"/>
<xsl:variable name="cprt_planned_crse_prt_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_PLANNED_CRSE_PRT_IND"/>
<xsl:variable name="cprt_rej_crse_prt_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_REJ_CRSE_PRT_IND"/>
<xsl:variable name="cprt_unused_crse_prt_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_UNUSED_CRSE_PRT_IND"/>
<xsl:variable name="aogn_met_ind" select="/SMRCRLT_XML/AREA/SMBAOGN_ROWSET/SMBAOGN_SET/SMBAOGN_MET_IND"/>
<xsl:variable name="aogn_rstr_s_a_ind" select="/SMRCRLT_XML/AREA/SMBAOGN_ROWSET/SMBAOGN_SET/SMBAOGN_RSTR_S_A_IND"/>
<xsl:variable name="aogn_rstr_grd_ind" select="/SMRCRLT_XML/AREA/SMBAOGN_ROWSET/SMBAOGN_SET/SMBAOGN_RSTR_GRD_IND"/>
<xsl:variable name="cprt_arsa_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_ARSA_IND"/>
<xsl:variable name="cprt_alvl_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_ALVL_IND"/>
<xsl:variable name="cprt_arsc_text_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_ARSC_TEXT_IND"/>
<xsl:variable name="cprt_argd_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_ARGD_IND"/>
<xsl:variable name="cprt_argc_text_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_ARGC_TEXT_IND"/>
<xsl:variable name="cprt_acaa_met_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_ACAA_MET_IND"/>
<xsl:variable name="cprt_acaa_nmet_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_ACAA_NMET_IND"/>
<xsl:variable name="cprt_agen_met_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_AGEN_MET_IND"/>
<xsl:variable name="cprt_agen_nmet_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_AGEN_NMET_IND"/>
<xsl:variable name="cprt_acmt_text_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_ACMT_TEXT_IND"/>
<xsl:variable name="cprt_agam_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_AGAM_IND"/>
<xsl:variable name="gogn_rstr_s_a_ind" select="/SMRCRLT_XML/AREA/GROUP/SMBGOGN_ROWSET/SMBGOGN_SET/SMBGOGN_RSTR_S_A_IND"/>
<xsl:variable name="gogn_rstr_grd_ind" select="/SMRCRLT_XML/AREA/GROUP/SMBGOGN_ROWSET/SMBGOGN_SET/SMBGOGN_RSTR_GRD_IND"/>
<xsl:variable name="cprt_ggen_met_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_GGEN_MET_IND"/>
<xsl:variable name="cprt_ggen_nmet_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_GGEN_NMET_IND"/>
<xsl:variable name="cprt_gcaa_met_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_GCAA_MET_IND"/>
<xsl:variable name="cprt_gcaa_nmet_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_GCAA_NMET_IND"/>
<xsl:variable name="cprt_gcmt_text_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_GCMT_TEXT_IND"/>
<xsl:variable name="cprt_glvl_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_GLVL_IND"/>
<xsl:variable name="cprt_grsa_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_GRSA_IND"/>
<xsl:variable name="cprt_grsc_text_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_GRSC_TEXT_IND"/>
<xsl:variable name="cprt_grgd_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_GRGD_IND"/>
<xsl:variable name="cprt_grgc_text_ind" select="/SMRCRLT_XML/SMRCPRT_ROWSET/SMRCPRT_SET/SMRCPRT_GRGC_TEXT_IND"/>
<xsl:variable name="term_code_ctlg_1" select="/SMRCRLT_XML/SMRRQCM_ROWSET/SMRRQCM_SET/SMRRQCM_TERM_CODE_CTLG_1"/>
<xsl:variable name="gpafmt">####0.00</xsl:variable>
<xsl:variable name="codedisplay">Y</xsl:variable>
<xsl:variable name="hdrdone">N</xsl:variable>
<!-- ********************************************************************** -->
<!-- The following section layouts out the overall format of the report.    -->
<!-- If there are sections not required, You can remove or comment out at   -->
<!-- at call to the template.                                               -->
<!-- ********************************************************************** -->

<xsl:template match="SMRCRLT_XML">
   <xsl:apply-templates select="SMRPRRQ_ROWSET"/>
   <xsl:apply-templates select="SPRIDEN_ROWSET"/>
<!--
   <xsl:apply-templates select="SPRIDEN_ROWSET"/>
-->
   <xsl:apply-templates select="SMRRQCM_ROWSET"/>
<!--
   <xsl:apply-templates select="SMBPOGN_ROWSET"/>
   <xsl:apply-templates select="SMRSPCM_ROWSET"/>
   <xsl:apply-templates select="SMRPCMT_ROWSET"/>
   <xsl:apply-templates select="SMRPONC_ROWSET"/>
   <xsl:if test="($pogn_addl_level_ind='Y')">
      <xsl:apply-templates select="SMRPOLV_ROWSET"/>
   </xsl:if>
   <xsl:apply-templates select="SMRPOAT_ROWSET"/>
      <xsl:if test="($pogn_rstr_s_a_ind='Y')">
   <xsl:apply-templates select="SMRPOSA"/>
   </xsl:if>
   <xsl:if test="($pogn_rstr_grd_ind='Y')">
      <xsl:apply-templates select="SMRPOGD"/>
   </xsl:if>
-->
   <xsl:call-template name="AREA_TABLE_HEADER"/>
   <xsl:apply-templates select="AREA/DETAILS"/>
<!--
   <xsl:apply-templates select="AREA"/>
   <xsl:apply-templates select="SMRDOUS_ROWSET"/>
   <xsl:apply-templates select="SMRDOCN_ROWSET"/>
   <xsl:apply-templates select="SMRDOAN_ROWSET"/>
   <xsl:apply-templates select="SMRPCRS_ROWSET"/>
   <xsl:apply-templates select="SMRDORJ_ROWSET"/>
 -->

</xsl:template>


<xsl:template match="SPRIDEN_ROWSETXX">
<BR></BR>
	<TABLE CLASS="datadisplaytable" WIDTH="40%" SUMMARY="summary">
		<CAPTION class="captiontext">Student Details</CAPTION>
		<TR>
			<TH COLSPAN="1" CLASS="ddlabel" ALIGN="LEFT" >Name : </TH>
			<TD COLSPAN="1" CLASS="dddefault"><xsl:value-of select="SPRIDEN_SET/SPRIDEN_NAME"/></TD>
		</TR>
		<TR>
			<TH COLSPAN="1" CLASS="ddlabel" ALIGN="LEFT" >ID : </TH>
			<TD COLSPAN="1" CLASS="dddefault"><xsl:value-of select="SPRIDEN_SET/SPRIDEN_ID"/></TD>
		</TR>
	</TABLE>
</xsl:template>

<xsl:template match="AREA">
     <xsl:if test="(($cprt_agen_met_ind='Y' and SMBAOGN_ROWSET/SMBAOGN_SET/SMBAOGN_MET_IND='Y') or
                    ($cprt_agen_nmet_ind!='2' and SMBAOGN_ROWSET/SMBAOGN_SET/SMBAOGN_MET_IND='N'))">
        <xsl:apply-templates select="SMBAOGN_ROWSET/SMBAOGN_SET"/>
     </xsl:if>
     <xsl:apply-templates select="SMRSACM_ROWSET"/>
     <xsl:apply-templates select="SMRACMT_ROWSET"/>
     <xsl:if test="SMBAOGN_ROWSET/SMBAOGN_SET/SMBAOGN_ADDL_LEVEL_IND='Y'">
        <xsl:apply-templates select="SMRAOLV_ROWSET"/>
     </xsl:if>
     <!--  Area restricted subjects
     <xsl:if test="SMBAOGN_ROWSET/SMBAOGN_SET/SMBAOGN_RSTR_S_A_IND='Y'">
        <xsl:apply-templates select="SMRAOSA"/>
     </xsl:if>
     -->
     <!--  Area Restricted
     <xsl:if test="SMBAOGN_ROWSET/SMBAOGN_SET/SMBAOGN_RSTR_GRD_IND='Y'">
        <xsl:apply-templates select="SMRAOGD"/>
     </xsl:if>
     -->
     <!--    Group Requirements
     <xsl:if test="SMBAOGN_ROWSET/SMBAOGN_SET/SMBAOGN_GC_IND='G'">
        <xsl:apply-templates select="SMRGOAT_ROWSET"/>
        <xsl:apply-templates select="GROUP"/>
     </xsl:if>
     -->
    <!--    Details
     <xsl:if test="SMBAOGN_ROWSET/SMBAOGN_SET/SMBAOGN_GC_IND='C'">
        <xsl:if test="(($cprt_acaa_met_ind='Y' and SMBAOGN_ROWSET/SMBAOGN_SET/SMBAOGN_DETL_REQ_MET_IND='Y') or
                       ($cprt_acaa_nmet_ind!='2' and SMBAOGN_ROWSET/SMBAOGN_SET/SMBAOGN_DETL_REQ_MET_IND='N'))">
           <xsl:apply-templates select="DETAILS"/>
        </xsl:if>
     </xsl:if>
     -->
</xsl:template>

<xsl:template match="GROUP">
     <xsl:if test="(($cprt_ggen_met_ind='Y' and SMBGOGN_ROWSET/SMBGOGN_SET/SMBGOGN_MET_IND='Y') or
                    ($cprt_ggen_nmet_ind!='2' and SMBGOGN_ROWSET/SMBGOGN_SET/SMBGOGN_MET_IND='N'))">
        <xsl:apply-templates select="SMBGOGN_ROWSET/SMBGOGN_SET"/>
     </xsl:if>
     <xsl:apply-templates select="SMRSGCM_ROWSET"/>
     <xsl:apply-templates select="SMRGCMT_ROWSET"/>
     <xsl:if test="SMBGOGN_ROWSET/SMBGOGN_SET/SMBGOGN_ADDL_LEVEL_IND='Y'">
        <xsl:apply-templates select="SMRGOLV_ROWSET"/>
     </xsl:if>
     <xsl:if test="SMBGOGN_ROWSET/SMBGOGN_SET/SMBGOGN_RSTR_S_A_IND='Y'">
        <xsl:apply-templates select="SMRGOSA"/>
     </xsl:if>
     <xsl:if test="SMBGOGN_ROWSET/SMBGOGN_SET/SMBGOGN_RSTR_GRD_IND='Y'">
        <xsl:apply-templates select="SMRGOGD"/>
     </xsl:if>
     <xsl:if test="(($cprt_gcaa_met_ind='Y' and SMBGOGN_ROWSET/SMBGOGN_SET/SMBGOGN_DETL_REQ_MET_IND='Y') or
                    ($cprt_gcaa_nmet_ind!='2' and SMBGOGN_ROWSET/SMBGOGN_SET/SMBGOGN_DETL_REQ_MET_IND='N'))">
        <xsl:apply-templates select="DETAILS"/>
     </xsl:if>
</xsl:template>
<xsl:template match="SMRRQCM_SET">
<BR></BR>
<TABLE CLASS="datadisplaytable" border="1" WIDTH="80%" SUMMARY="summary">
<CAPTION class="captiontext">Program Description</CAPTION>
<TR>
<!-- Defect 1-7P4GFW -->
<TH COLSPAN="1" CLASS="ddlabel" ALIGN="LEFT" >Degree Catalog:</TH>
      <xsl:choose>
         <xsl:when test="SMRRQCM_CURR_PRIM_SECD='P'">
            <TD COLSPAN="1" CLASS="dddefault"><xsl:value-of select="SMRRQCM_TERM_CTLG_1_DESC"/></TD>
         </xsl:when>
         <!-- 1-8Q00A5 -->
         <xsl:when test="SMRRQCM_CURR_PRIM_SECD='S'">
            <TD COLSPAN="1" CLASS="dddefault"><xsl:value-of select="SMRRQCM_TERM_CTLG_2_DESC"/></TD>
         </xsl:when>
         <xsl:otherwise>
            <TD COLSPAN="1" CLASS="dddefault"><xsl:value-of select="SMRRQCM_TERM_CTLG_1_DESC"/></TD>
         </xsl:otherwise>
      </xsl:choose>
      <TD COLSPAN="1" CLASS="dddefault"></TD>
</TR>
<TR>
<TH COLSPAN="1" CLASS="ddlabel" ALIGN="LEFT" >Program :</TH>
   <xsl:if test="$cprt_prle_prog_ind='2'"> 
      <TD COLSPAN="1" CLASS="dddefault" ></TD>
   </xsl:if>
   <xsl:if test="$cprt_prle_prog_ind!='2'">
      <TD COLSPAN="1" CLASS="dddefault"><xsl:value-of select="SMRRQCM_PROGRAM_DESC"/></TD>
   </xsl:if>
      <TD COLSPAN="1" CLASS="dddefault"></TD>
</TR>
<!-- Line 1 and 2 -->
<!--
<TR>
<TH COLSPAN="1" CLASS="ddlabel" ALIGN="LEFT" >Campus :</TH>
   <xsl:if test="$camp_ind='2'">     
      <TD COLSPAN="1" CLASS="dddefault" ></TD>
   </xsl:if>
   <xsl:if test="$camp_ind!='2'">    
      <TD COLSPAN="1" CLASS="dddefault"><xsl:value-of select="SMRRQCM_CAMP_DESC"/></TD>
   </xsl:if>
<TH COLSPAN="1" CLASS="ddlabel" ALIGN="LEFT" >Evaluation Term :</TH>
   <xsl:if test="$eval_term_ind='2'">
     <TD COLSPAN="1" CLASS="dddefault" ></TD>
   </xsl:if>
   <xsl:if test="$eval_term_ind!='2'">
      <TD COLSPAN="1" CLASS="dddefault"><xsl:value-of select="SMRRQCM_TERM_EVAL_DESC"/></TD>
   </xsl:if>
</TR>


<TR>
<TH COLSPAN="1" CLASS="ddlabel" ALIGN="LEFT" >College :</TH>
   <xsl:if test="$coll_ind='2'">
      <TD COLSPAN="1" CLASS="dddefault" ></TD>
   </xsl:if>
   <xsl:if test="$coll_ind!='2'">
      <TD COLSPAN="1" CLASS="dddefault"><xsl:value-of select="SMRRQCM_COLL_DESC"/></TD>
   </xsl:if>
-->
   <!-- Defect 1-6NK3VV -->
<!--
<TH COLSPAN="1" CLASS="ddlabel" ALIGN="LEFT" >Expected Graduation Date :</TH>
   <xsl:if test="$exp_grad_date_ind='N'">
      <TD COLSPAN="1" CLASS="dddefault" ></TD>
   </xsl:if>
   <xsl:if test="$exp_grad_date_ind='Y'">
      <TD COLSPAN="1" CLASS="dddefault" ><xsl:value-of select="SMRRQCM_EXP_GRAD_DATE"/></TD>
   </xsl:if>
<TD COLSPAN="1" CLASS="dddefault" ></TD>
</TR>

<TR>
<TH COLSPAN="1" CLASS="ddlabel" ALIGN="LEFT" >Degree: </TH>
   <xsl:if test="$degc_ind='2'">
      <TD COLSPAN="1" CLASS="dddefault" ></TD>
   </xsl:if>
   <xsl:if test="$degc_ind!='2'">
      <TD COLSPAN="1" CLASS="dddefault"><xsl:value-of select="SMRRQCM_DEGC_DESC"/></TD>
   </xsl:if>
<TH COLSPAN="1" CLASS="ddlabel" ALIGN="LEFT" >Request Number :</TH>
<TD COLSPAN="1" CLASS="dddefault" ><xsl:value-of select="SMRRQCM_REQUEST_NO"/></TD>
</TR>

<TR>
<TH COLSPAN="1" CLASS="ddlabel" ALIGN="LEFT" >Level :</TH>
   <xsl:if test="$levl_ind='2'">
      <TD COLSPAN="1" CLASS="dddefault" ></TD>
   </xsl:if>
   <xsl:if test="$levl_ind!='2'">
      <TD COLSPAN="1" CLASS="dddefault"><xsl:value-of select="SMRRQCM_LEVL_DESC"/></TD>
   </xsl:if>
<TH COLSPAN="1" CLASS="ddlabel" ALIGN="LEFT" >Results as of :</TH>
<TD COLSPAN="1" CLASS="dddefault" ><xsl:value-of select="SMRRQCM_COMPLY_DATE"/></TD>
</TR>
-->
<TR>
<TH COLSPAN="1" CLASS="ddlabel" ALIGN="LEFT" >Majors :</TH>
<xsl:choose>
   <xsl:when test="SMRRQCM_MAJR_1_2_DESC">
         <TD COLSPAN="1" CLASS="dddefault" disable-output-escaping="yes">
         <xsl:value-of select="SMRRQCM_MAJR_1_DESC"/><BR></BR><xsl:value-of select="SMRRQCM_MAJR_1_2_DESC"/></TD>
   </xsl:when>
   <xsl:otherwise>
      <TD COLSPAN="1" CLASS="dddefault" disable-output-escaping="yes"><xsl:value-of select="SMRRQCM_MAJR_1_DESC"/></TD>
   </xsl:otherwise>
</xsl:choose>

<TH COLSPAN="1" CLASS="ddlabel" ALIGN="LEFT" >Majors :</TH>
<xsl:choose>
   <xsl:when test="SMRRQCM_MAJR_1_2_DESC">
         <TD COLSPAN="1" CLASS="dddefault" disable-output-escaping="yes">
         <xsl:value-of select="SMRRQCM_MAJR_1_DESC"/><BR></BR><xsl:value-of select="SMRRQCM_MAJR_1_2_DESC"/></TD>
   </xsl:when>
   <xsl:otherwise>
      <TD COLSPAN="1" CLASS="dddefault" disable-output-escaping="yes"><xsl:value-of select="SMRRQCM_MAJR_1_DESC"/></TD>
   </xsl:otherwise>
</xsl:choose>

<!--
<TH COLSPAN="1" CLASS="ddlabel" ALIGN="LEFT" >Minors :</TH>
<xsl:choose>
   <xsl:when test="SMRRQCM_MAJR_MINR_1_2_DESC">
         <TD COLSPAN="1" CLASS="dddefault" disable-output-escaping="yes">
         <xsl:value-of select="SMRRQCM_MAJR_MINR_1_1_DESC"/><BR></BR><xsl:value-of select="SMRRQCM_MAJR_MINR_1_2_DESC"/></TD>
   </xsl:when>
   <xsl:otherwise>
      <TD COLSPAN="1" CLASS="dddefault" disable-output-escaping="yes"><xsl:value-of select="SMRRQCM_MAJR_MINR_1_1_DESC"/></TD>
   </xsl:otherwise>
</xsl:choose>
-->
</TR>

<TR>
<TH COLSPAN="1" CLASS="ddlabel" ALIGN="LEFT" >Departments :</TH>
<xsl:choose>
   <xsl:when test="SMRRQCM_DEPT_1_2_DESC">
         <TD COLSPAN="1" CLASS="dddefault" disable-output-escaping="yes">
         <xsl:value-of select="SMRRQCM_DEPT_DESC"/><BR></BR><xsl:value-of select="SMRRQCM_DEPT_1_2_DESC"/></TD>
   </xsl:when>
   <xsl:otherwise>
      <TD COLSPAN="1" CLASS="dddefault" disable-output-escaping="yes"><xsl:value-of select="SMRRQCM_DEPT_DESC"/></TD>
   </xsl:otherwise>
</xsl:choose>

<TH COLSPAN="1" CLASS="ddlabel" ALIGN="LEFT" >Departments :</TH>
<xsl:choose>
   <xsl:when test="SMRRQCM_DEPT_1_2_DESC">
         <TD COLSPAN="1" CLASS="dddefault" disable-output-escaping="yes">
         <xsl:value-of select="SMRRQCM_DEPT_DESC"/><BR></BR><xsl:value-of select="SMRRQCM_DEPT_1_2_DESC"/></TD>
   </xsl:when>
   <xsl:otherwise>
      <TD COLSPAN="1" CLASS="dddefault" disable-output-escaping="yes"><xsl:value-of select="SMRRQCM_DEPT_DESC"/></TD>
   </xsl:otherwise>
</xsl:choose>
</TR>
<!--
<TH COLSPAN="1" CLASS="ddlabel" ALIGN="LEFT" >Concentrations :</TH>
<TD COLSPAN="1" CLASS="dddefault" disable-output-escaping="yes">
<xsl:value-of select="SMRRQCM_MAJR_CONC_1_DESC"/>
<xsl:if test="(SMRRQCM_MAJR_CONC_1_2_DESC)"><BR /><xsl:value-of select="SMRRQCM_MAJR_CONC_1_2_DESC"/></xsl:if>
<xsl:if test="(SMRRQCM_MAJR_CONC_1_3_DESC)"><BR /><xsl:value-of select="SMRRQCM_MAJR_CONC_1_3_DESC"/></xsl:if>
<xsl:if test="(SMRRQCM_MAJR_CONC_121_DESC)"><BR /><xsl:value-of select="SMRRQCM_MAJR_CONC_121_DESC"/></xsl:if>
<xsl:if test="(SMRRQCM_MAJR_CONC_122_DESC)"><BR /><xsl:value-of select="SMRRQCM_MAJR_CONC_122_DESC"/></xsl:if>
<xsl:if test="(SMRRQCM_MAJR_CONC_123_DESC)"><BR /><xsl:value-of select="SMRRQCM_MAJR_CONC_123_DESC"/></xsl:if>
</TD>
</TR>
-->

</TABLE>
<BR></BR>
<p align="center"><font size="+2">PROGRAM GENERATING THIS CAPP REPORT</font></p>

<TABLE CLASS="datadisplaytable" border="1" WIDTH="80%" SUMMARY="summary">
<CAPTION class="captiontext">Program Description</CAPTION>
<TR>
<TH COLSPAN="1" CLASS="ddlabel" ALIGN="LEFT" >Degree Catalog:</TH>
      <xsl:choose>
         <xsl:when test="SMRRQCM_CURR_PRIM_SECD='P'">
            <TD COLSPAN="1" CLASS="dddefault"><xsl:value-of select="SMRRQCM_TERM_CTLG_1_DESC"/></TD>
         </xsl:when>
         <!-- 1-8Q00A5 -->
         <xsl:when test="SMRRQCM_CURR_PRIM_SECD='S'">
            <TD COLSPAN="1" CLASS="dddefault"><xsl:value-of select="SMRRQCM_TERM_CTLG_2_DESC"/></TD>
         </xsl:when>
         <xsl:otherwise>
            <TD COLSPAN="1" CLASS="dddefault"><xsl:value-of select="SMRRQCM_TERM_CTLG_1_DESC"/></TD>
         </xsl:otherwise>
      </xsl:choose>
      <TD COLSPAN="1" CLASS="dddefault"></TD>
</TR>
<TR>
<TH COLSPAN="1" CLASS="ddlabel" ALIGN="LEFT" >Program :</TH>
   <xsl:if test="$cprt_prle_prog_ind='2'"> 
      <TD COLSPAN="1" CLASS="dddefault" ></TD>
   </xsl:if>
   <xsl:if test="$cprt_prle_prog_ind!='2'">
      <TD COLSPAN="1" CLASS="dddefault"><xsl:value-of select="SMRRQCM_PROGRAM_DESC"/></TD>
   </xsl:if>
      <TD COLSPAN="1" CLASS="dddefault"></TD>
</TR>

<TR>
<TH COLSPAN="1" CLASS="ddlabel" ALIGN="LEFT" >Majors :</TH>
<xsl:choose>
   <xsl:when test="SMRRQCM_MAJR_1_2_DESC">
         <TD COLSPAN="1" CLASS="dddefault" disable-output-escaping="yes">
         <xsl:value-of select="SMRRQCM_MAJR_1_DESC"/><BR></BR><xsl:value-of select="SMRRQCM_MAJR_1_2_DESC"/></TD>
   </xsl:when>
   <xsl:otherwise>
      <TD COLSPAN="1" CLASS="dddefault" disable-output-escaping="yes"><xsl:value-of select="SMRRQCM_MAJR_1_DESC"/></TD>
   </xsl:otherwise>
</xsl:choose>
</TR>

<TR>
<TH COLSPAN="1" CLASS="ddlabel" ALIGN="LEFT" >Departments :</TH>
<xsl:choose>
   <xsl:when test="SMRRQCM_DEPT_1_2_DESC">
         <TD COLSPAN="1" CLASS="dddefault" disable-output-escaping="yes">
         <xsl:value-of select="SMRRQCM_DEPT_DESC"/><BR></BR><xsl:value-of select="SMRRQCM_DEPT_1_2_DESC"/></TD>
   </xsl:when>
   <xsl:otherwise>
      <TD COLSPAN="1" CLASS="dddefault" disable-output-escaping="yes"><xsl:value-of select="SMRRQCM_DEPT_DESC"/></TD>
   </xsl:otherwise>
</xsl:choose>
</TR>

</TABLE>

<!-- COMMENTS DO a loop to print all lines -->
<p>Comments: <xsl:value-of select="/SMRCRLT_XML/SMRPCMT_ROWSET/SMRPCMT_SET[1]/SMRPCMT_TEXT"/>
&nbsp;<xsl:value-of select="/SMRCRLT_XML/SMRPCMT_ROWSET/SMRPCMT_SET[2]/SMRPCMT_TEXT"/>
</p>
<br />

</xsl:template>

<xsl:template match="SMBPOGN_ROWSET/SMBPOGN_SET">
<xsl:choose>
<xsl:when test="($cprt_pgen_met_ind='N' and $pogn_met_ind='Y') or ($pogn_met_ind='N' and $cprt_pgen_nmet_ind='2')">
   <TD COLSPAN="1" CLASS="dddefault" ></TD>
</xsl:when>
<xsl:otherwise>
<!--  skip the headers
<TABLE BORDER="1" CLASS="datadisplaytable" WIDTH="65%" SUMMARY="summary">
<CAPTION class="captiontext">Program Evaluation</CAPTION>
   <TR>
      <TD COLSPAN="1" CLASS="dddead"></TD>
      <TH ROWSPAN="2" CLASS="ddheader" scope="col" >Met</TH>
      <TH COLSPAN="2" CLASS="ddtitle" scope="colgroup">Credits</TH>
      <TH COLSPAN="2" CLASS="ddtitle" scope="colgroup">Courses</TH>
   </TR>
   <TR>
      <TD COLSPAN="1"/>
      <TH CLASS="ddheader" scope="col" >Required</TH>
      <TH CLASS="ddheader" scope="col" >Used</TH>
      <TH CLASS="ddheader" scope="col" >Required</TH>
      <TH CLASS="ddheader" scope="col" >Used</TH>
   </TR>
-->
   <xsl:if test="(SMBPOGN_REQ_CREDITS_OVERALL) or (SMBPOGN_REQ_COURSES_OVERALL)">
   <TR>
      <TH COLSPAN="1" CLASS="ddlabel" scope="row" ALIGN="LEFT">Total Credits :</TH>
      <!-- Defect 1-6JRZGV -->
      <xsl:choose>
      <xsl:when test="(SMBPOGN_REQ_CREDITS_OVERALL) and (SMBPOGN_REQ_COURSES_OVERALL)">
      <xsl:choose>
         <xsl:when test="SMBPOGN_CONNECTOR_OVERALL='A'">
            <xsl:choose>
            <xsl:when test="(SMBPOGN_ACT_CREDITS_OVERALL &gt;= SMBPOGN_REQ_CREDITS_OVERALL) and
                            (SMBPOGN_ACT_COURSES_OVERALL &gt;= SMBPOGN_REQ_COURSES_OVERALL)">
               <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
               <xsl:call-template name="yes_no_ind_format">
                  <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
               </xsl:call-template>
               </font></TD>
            </xsl:when>
            <xsl:otherwise>
               <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
               <xsl:call-template name="yes_no_ind_format">
                  <xsl:with-param name="yes_no_ind">N</xsl:with-param>
               </xsl:call-template>
               </font></TD>
            </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
            <xsl:when test="(SMBPOGN_ACT_CREDITS_OVERALL &gt;= SMBPOGN_REQ_CREDITS_OVERALL) or
                            (SMBPOGN_ACT_COURSES_OVERALL &gt;= SMBPOGN_REQ_COURSES_OVERALL)">
               <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
               <xsl:call-template name="yes_no_ind_format">
                  <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
               </xsl:call-template>
               </font></TD>
            </xsl:when>
            <xsl:otherwise>
               <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
               <xsl:call-template name="yes_no_ind_format">
                  <xsl:with-param name="yes_no_ind">N</xsl:with-param>
               </xsl:call-template>
               </font></TD>
            </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
      </xsl:when>
      <xsl:when test="(SMBPOGN_REQ_CREDITS_OVERALL)">
      <xsl:choose>
         <xsl:when test="(SMBPOGN_ACT_CREDITS_OVERALL &gt;= SMBPOGN_REQ_CREDITS_OVERALL)"> 
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>
      </xsl:when>
      <xsl:when test="(SMBPOGN_REQ_COURSES_OVERALL)">
      <xsl:choose>
         <xsl:when test="(SMBPOGN_ACT_COURSES_OVERALL &gt;= SMBPOGN_REQ_COURSES_OVERALL)">
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>
      </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
          </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMBPOGN_REQ_CREDITS_OVERALL"/></xsl:with-param>
      </xsl:call-template>
      </TD>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMBPOGN_ACT_CREDITS_OVERALL"/></xsl:with-param>
      </xsl:call-template>
      </TD>
<!--
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:value-of select="SMBPOGN_REQ_COURSES_OVERALL"/>
      </TD>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:value-of select="SMBPOGN_ACT_COURSES_OVERALL"/>
      </TD>
-->
   </TR>
   </xsl:if>

   <xsl:if test="(SMBPOGN_REQ_CREDITS_INST) or (SMBPOGN_REQ_COURSES_INST)">
      <TR>
      <TH COLSPAN="1" CLASS="ddlabel" scope="row" ALIGN="LEFT">MSCD Resident Credits:</TH>
      <xsl:choose>
      <xsl:when test="(SMBPOGN_REQ_CREDITS_INST) and (SMBPOGN_REQ_COURSES_INST)">
      <xsl:choose>
         <xsl:when test="SMBPOGN_CONNECTOR_INST ='A'">
            <xsl:choose>
            <xsl:when test="(SMBPOGN_ACT_CREDITS_INST &gt;= SMBPOGN_REQ_CREDITS_INST) and
                            (SMBPOGN_ACT_COURSES_INST &gt;= SMBPOGN_REQ_COURSES_INST)">
               <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
               <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
               </xsl:call-template>
               </font></TD>
            </xsl:when>
            <xsl:otherwise>
               <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
               <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
               </xsl:call-template>
               </font></TD>
            </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
            <xsl:when test="(SMBPOGN_ACT_CREDITS_INST &gt;= SMBPOGN_REQ_CREDITS_INST) or
                            (SMBPOGN_ACT_COURSES_INST &gt;= SMBPOGN_REQ_COURSES_INST)">
               <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
               <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
               </xsl:call-template>
               </font></TD>
            </xsl:when>
            <xsl:otherwise>
               <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
               <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
               </xsl:call-template>
               </font></TD>
            </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
      </xsl:when>
      <xsl:when test="(SMBPOGN_REQ_CREDITS_INST)">
      <xsl:choose>
         <xsl:when test="(SMBPOGN_ACT_CREDITS_INST &gt;= SMBPOGN_REQ_CREDITS_INST)">
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>
      </xsl:when>
      <xsl:when test="(SMBPOGN_REQ_COURSES_INST)">
      <xsl:choose>
         <xsl:when test="(SMBPOGN_ACT_COURSES_INST &gt;= SMBPOGN_REQ_COURSES_INST)">
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>
      </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
          </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMBPOGN_REQ_CREDITS_INST"/></xsl:with-param>
      </xsl:call-template>
      </TD>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMBPOGN_ACT_CREDITS_INST"/></xsl:with-param>
      </xsl:call-template>
      </TD>
<!--
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:value-of select="SMBPOGN_REQ_COURSES_INST"/>
      </TD>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:value-of select="SMBPOGN_ACT_COURSES_INST"/>
      </TD>
   -->
   </TR>
   </xsl:if>

   <xsl:if test="(SMBPOGN_REQ_CREDITS_I_TRAD) or (SMBPOGN_REQ_COURSES_I_TRAD)">
      <TR>
      <TH COLSPAN="1" CLASS="ddlabel" scope="row" ALIGN="LEFT"> MSCD Resident Credits:</TH>
      <xsl:choose>
      <xsl:when test="(SMBPOGN_REQ_CREDITS_I_TRAD) and (SMBPOGN_REQ_COURSES_I_TRAD)">
      <xsl:choose>
         <xsl:when test="SMBPOGN_CONNECTOR_I_TRAD ='A'">
            <xsl:choose>
            <xsl:when test="(SMBPOGN_ACT_CREDITS_I_TRAD &gt;= SMBPOGN_REQ_CREDITS_I_TRAD) and
                            (SMBPOGN_ACT_COURSES_I_TRAD &gt;= SMBPOGN_REQ_COURSES_I_TRAD)">
               <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
               <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
               </xsl:call-template>
               </font></TD>
            </xsl:when>
            <xsl:otherwise>
               <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
               <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
               </xsl:call-template>
               </font></TD>
            </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
            <xsl:when test="(SMBPOGN_ACT_CREDITS_I_TRAD &gt;= SMBPOGN_REQ_CREDITS_I_TRAD) or
                            (SMBPOGN_ACT_COURSES_I_TRAD &gt;= SMBPOGN_REQ_COURSES_I_TRAD)">
               <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
               <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
               </xsl:call-template>
               </font></TD>
            </xsl:when>
            <xsl:otherwise>
               <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
               <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
               </xsl:call-template>
               </font></TD>
            </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
      </xsl:when>
      <xsl:when test="(SMBPOGN_REQ_CREDITS_I_TRAD)">
      <xsl:choose>
         <xsl:when test="(SMBPOGN_ACT_CREDITS_I_TRAD &gt;= SMBPOGN_REQ_CREDITS_I_TRAD)">
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>
      </xsl:when>
      <xsl:when test="(SMBPOGN_REQ_COURSES_I_TRAD)">
      <xsl:choose>
         <xsl:when test="(SMBPOGN_ACT_COURSES_I_TRAD &gt;= SMBPOGN_REQ_COURSES_I_TRAD)">
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>
      </xsl:when>
       <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
          </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMBPOGN_REQ_CREDITS_I_TRAD"/></xsl:with-param>
      </xsl:call-template>
      </TD>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMBPOGN_ACT_CREDITS_I_TRAD"/></xsl:with-param>
      </xsl:call-template>
      </TD>
<!--
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:value-of select="SMBPOGN_REQ_COURSES_I_TRAD"/>
      </TD>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:value-of select="SMBPOGN_ACT_COURSES_I_TRAD"/>
      </TD>
-->
   </TR>      
   </xsl:if>

   <xsl:if test="(SMBPOGN_MAX_CREDITS_I_NONTRAD) or (SMBPOGN_MAX_COURSES_I_NONTRAD)">
      <TR>
      <TH COLSPAN="1" CLASS="ddlabel" scope="row" ALIGN="LEFT">MSCD Non-Classroom Credits:</TH>
      <TD CLASS="dddefault" ALIGN="CENTER"></TD>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMBPOGN_MAX_CREDITS_I_NONTRAD"/></xsl:with-param>
      </xsl:call-template>
      </TD>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMBPOGN_ACT_CREDITS_I_NONTRAD"/></xsl:with-param>
      </xsl:call-template>
      </TD>
      <!--
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:value-of select="SMBPOGN_MAX_COURSES_I_NONTRAD"/>
      </TD>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:value-of select="SMBPOGN_ACT_COURSES_I_NONTRAD"/>
      </TD>
      -->
   </TR>        
   </xsl:if>

   <xsl:if test="(SMBPOGN_LAST_INST_CREDITS) or (SMBPOGN_LAST_INST_COURSES)">
      <TR>
      <TH COLSPAN="1" CLASS="ddlabel" scope="row" ALIGN="LEFT"> Minimum Resident Credits Out of Last:</TH>
      <!-- Defect 1-6JRZI5 -->
      <xsl:choose>
      <xsl:when test="(SMBPOGN_LAST_INST_CREDITS) and (SMBPOGN_LAST_INST_COURSES)">
    <xsl:choose>
         <xsl:when test="SMBPOGN_CONNECTOR_LAST_INST ='A'">
            <xsl:choose>
            <xsl:when test="(SMBPOGN_ACT_LAST_INST_CREDITS &gt;= SMBPOGN_LAST_INST_CREDITS) and
                            (SMBPOGN_ACT_LAST_INST_COURSES &gt;= SMBPOGN_LAST_INST_COURSES)">
               <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
               <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
               </xsl:call-template>
               </font></TD>
            </xsl:when>
            <xsl:otherwise>
               <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
               <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
               </xsl:call-template>
               </font></TD>
            </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
            <xsl:when test="(SMBPOGN_ACT_LAST_INST_CREDITS &gt;= SMBPOGN_LAST_INST_CREDITS) or
                            (SMBPOGN_ACT_LAST_INST_COURSES &gt;= SMBPOGN_LAST_INST_COURSES)">
               <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
               <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
               </xsl:call-template>
               </font></TD>
            </xsl:when>
            <xsl:otherwise>
               <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
               <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
               </xsl:call-template>
               </font></TD>
            </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
      </xsl:when>
      <xsl:when test="(SMBPOGN_LAST_INST_CREDITS)">
      <xsl:choose>
         <xsl:when test="(SMBPOGN_ACT_LAST_INST_CREDITS &gt;= SMBPOGN_LAST_INST_CREDITS)"> 
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>
      </xsl:when>
      <xsl:when test="(SMBPOGN_LAST_INST_COURSES)">
      <xsl:choose>
         <xsl:when test="(SMBPOGN_ACT_LAST_INST_COURSES &gt;= SMBPOGN_LAST_INST_COURSES)"> 
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>
      </xsl:when>
       <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>

          </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMBPOGN_LAST_INST_CREDITS"/></xsl:with-param>
      </xsl:call-template>
      </TD>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMBPOGN_ACT_LAST_INST_CREDITS"/></xsl:with-param>
      </xsl:call-template>
      </TD>
<!--
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:value-of select="SMBPOGN_LAST_INST_COURSES"/>
      </TD>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:value-of select="SMBPOGN_ACT_LAST_INST_COURSES"/>
      </TD>
      -->
      </TR>    
   </xsl:if>

   <xsl:if test="(SMBPOGN_LAST_EARNED_CREDITS) or (SMBPOGN_LAST_EARNED_COURSES)">
      <TR>
      <TH COLSPAN="1" CLASS="ddlabel" scope="row" ALIGN="LEFT">Minimum Resident Credits Out of Last Earned :</TH>
      <!-- Defect 1-6JRZLX -->
      <!-- Defect 1-6J7T50 -->
      <xsl:choose>
      <xsl:when test="(SMBPOGN_LAST_EARNED_CREDITS) and (SMBPOGN_LAST_EARNED_COURSES)">
      <xsl:choose>
         <xsl:when test="SMBPOGN_CONNECTOR_LAST_EARNED ='A'">
            <xsl:choose>
            <xsl:when test="(SMBPOGN_ACT_LAST_EARN_CREDITS &gt;= SMBPOGN_LAST_EARNED_CREDITS) and
                            (SMBPOGN_ACT_LAST_EARN_COURSES &gt;= SMBPOGN_LAST_EARNED_COURSES)">
               <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
               <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
               </xsl:call-template>
               </font></TD>
            </xsl:when>
            <xsl:otherwise>
               <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
               <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
               </xsl:call-template>
               </font></TD>
            </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
            <xsl:when test="(SMBPOGN_ACT_LAST_EARN_CREDITS &gt;= SMBPOGN_LAST_EARNED_CREDITS) or
                            (SMBPOGN_ACT_LAST_EARN_COURSES &gt;= SMBPOGN_LAST_EARNED_COURSES)">
               <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
               <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
               </xsl:call-template>
               </font></TD>
            </xsl:when>
            <xsl:otherwise>
               <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
               <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
               </xsl:call-template>
               </font></TD>
            </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
      </xsl:when>
      <xsl:when test="(SMBPOGN_LAST_EARNED_CREDITS)">
      <xsl:choose>
         <xsl:when test="(SMBPOGN_ACT_LAST_EARN_CREDITS &gt;= SMBPOGN_LAST_EARNED_CREDITS)"> 
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>
      </xsl:when>
      <xsl:when test="(SMBPOGN_LAST_EARNED_COURSES)">
      <xsl:choose>
         <xsl:when test="(SMBPOGN_ACT_LAST_EARN_COURSES &gt;= SMBPOGN_LAST_EARNED_COURSES)"> 
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>
      </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMBPOGN_LAST_EARNED_CREDITS"/></xsl:with-param>
      </xsl:call-template>
      </TD>
      <!-- Defect 1-6J7T50 -->
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMBPOGN_ACT_LAST_EARN_CREDITS"/></xsl:with-param>
      </xsl:call-template>
      </TD>
<!--
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:value-of select="SMBPOGN_LAST_EARNED_COURSES"/>
      </TD>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:value-of select="SMBPOGN_ACT_LAST_EARN_COURSES"/>
      </TD>
-->
      <!-- Defect 1-6J7T50 -->
      </TR>        
   </xsl:if>

   <xsl:if test="(SMBPOGN_MAX_CREDITS_TRANSFER) or (SMBPOGN_MAX_COURSES_TRANSFER)">
      <TR>
      <TH COLSPAN="1" CLASS="ddlabel" scope="row" ALIGN="LEFT"> Maximum Transfer Credits:</TH>
      <TD CLASS="dddefault" ALIGN="CENTER"></TD>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMBPOGN_MAX_CREDITS_TRANSFER"/></xsl:with-param>
      </xsl:call-template>
      </TD>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMBPOGN_ACT_CREDITS_TRANSFER"/></xsl:with-param>
      </xsl:call-template>
      </TD>
<!--
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:value-of select="SMBPOGN_MAX_COURSES_TRANSFER"/>
      </TD>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:value-of select="SMBPOGN_ACT_COURSES_TRANSFER"/>
      </TD>
-->
      </TR>     
   </xsl:if>

   <xsl:if test="(SMBPOGN_MIN_PROGRAM_GPA) ">
      <TR>
      <TH COLSPAN="1" CLASS="ddlabel" scope="row" ALIGN="LEFT">Program GPA :</TH>
      <xsl:choose>
         <xsl:when test="SMBPOGN_ACT_PROGRAM_GPA &lt; SMBPOGN_MIN_PROGRAM_GPA">
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>
     <xsl:choose>
         <xsl:when test="(SMBPOGN_MIN_PROGRAM_GPA)">
            <TD CLASS="dddefault" ALIGN="CENTER">
            <xsl:value-of select="format-number(SMBPOGN_MIN_PROGRAM_GPA,$gpafmt)"/>
            </TD>
         </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER">
            </TD>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="(SMBPOGN_ACT_PROGRAM_GPA)">
            <TD CLASS="dddefault" ALIGN="CENTER">
            <xsl:value-of select="format-number(SMBPOGN_ACT_PROGRAM_GPA,$gpafmt)"/>
            </TD>
         </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER">
            </TD>
         </xsl:otherwise>
      </xsl:choose>
      </TR>   
   </xsl:if>

   <xsl:if test="(SMBPOGN_MIN_GPA)">
      <TR>
      <TH COLSPAN="1" CLASS="ddlabel" scope="row" ALIGN="LEFT">Minimum MSCD GPA :</TH>
      <xsl:choose>
         <xsl:when test="SMBPOGN_ACT_GPA &lt; SMBPOGN_MIN_GPA">
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>
     <xsl:choose>
         <xsl:when test="(SMBPOGN_MIN_GPA)">
            <TD CLASS="dddefault" ALIGN="CENTER">
            <xsl:value-of select="format-number(SMBPOGN_MIN_GPA,$gpafmt)"/>
            </TD>
         </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER">
            </TD>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="(SMBPOGN_ACT_GPA)">
            <TD CLASS="dddefault" ALIGN="CENTER">
            <xsl:value-of select="format-number(SMBPOGN_ACT_GPA,$gpafmt)"/>
            </TD>
         </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER">
            </TD>
         </xsl:otherwise>
      </xsl:choose>
      </TR>      
   </xsl:if>
<!--
</TABLE>
-->
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="SMRPCMT_ROWSET">
   <xsl:if test="$cprt_pcmt_text_ind='2'">  
      <BR></BR>
   </xsl:if>
   <xsl:if test="$cprt_pcmt_text_ind!='2'">    
      <BR></BR>
      <TABLE CLASS="datadisplaytable" WIDTH="65%" SUMMARY="summary">
      <CAPTION class="captiontext">Program Description</CAPTION>
      <TR>
         <TD CLASS="dddefault" ALIGN="LEFT">
         <xsl:for-each select="SMRPCMT_SET">
            <xsl:value-of select="SMRPCMT_TEXT" disable-output-escaping="yes"/>&#xa0;
         </xsl:for-each>
         </TD>
      </TR>
   </TABLE>
</xsl:if>
</xsl:template>
<xsl:template match="SMRSPCM_ROWSET">
   <xsl:if test="$cprt_pcmt_text_ind='2'">  
      <TD CLASS="dddefault" ALIGN="CENTER"></TD>
   </xsl:if>
   <xsl:if test="$cprt_pcmt_text_ind!='2'">    
      <BR></BR>
      <TABLE CLASS="datadisplaytable" WIDTH="65%" SUMMARY="summary">
      <CAPTION class="captiontext">Adjusted Program Description</CAPTION>
      <TR>
         <TD CLASS="dddefault" ALIGN="LEFT">
         <xsl:for-each select="SMRSPCM_SET">
            <xsl:value-of select="SMRSPCM_TEXT" disable-output-escaping="yes"/>&#xa0;
         </xsl:for-each>
         </TD>
      </TR>
   </TABLE>
</xsl:if>
</xsl:template>
<xsl:template match="SMRPOLV_ROWSET">
<xsl:if test="$cprt_plvl_ind='2'">
   <TD CLASS="dddefault" ALIGN="CENTER"></TD>
</xsl:if>
<xsl:if test="$cprt_plvl_ind!='2'">
<BR></BR>
<TABLE CLASS="datadisplaytable" WIDTH="65%" SUMMARY="summary">
<CAPTION class="captiontext">Program Additional Levels</CAPTION>
<TR>
<TH CLASS="ddheader" scope="col">Level</TH>
<TH CLASS="ddheader" scope="col">Include/Exclude</TH>
<TH CLASS="ddheader" scope="col">Grade</TH>
<TH CLASS="ddheader" scope="col">Maximum Credits</TH>
<TH CLASS="ddheader" scope="col">And/Or</TH>
<TH CLASS="ddheader" scope="col">Actual Credits</TH>
<TH CLASS="ddheader" scope="col">Actual Courses</TH>
</TR>
<xsl:for-each select="SMRPOLV_SET">
   <TR>
      <TD CLASS="dddefault" ALIGN="CENTER"><xsl:value-of select="SMRPOLV_LEVL_DESC"/></TD>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:call-template name="incl_excl_format">
         <xsl:with-param name="incl_excl"><xsl:value-of select="SMRPOLV_INCL_EXCL_IND"/></xsl:with-param>
      </xsl:call-template>
      </TD>
      <TD CLASS="dddefault" ALIGN="CENTER"><xsl:value-of select="SMRPOLV_GRDE_CODE"/></TD>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMRPOLV_MAX_CREDITS"/></xsl:with-param>
      </xsl:call-template>
      </TD>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:call-template name="connector_format">
         <xsl:with-param name="connect_ind"><xsl:value-of select="SMRPOLV_CONNECTOR_MAX"/></xsl:with-param>
      </xsl:call-template>
      </TD>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMRPOLV_ACT_CREDITS"/></xsl:with-param>
      </xsl:call-template>
      </TD>
      <TD CLASS="dddefault" ALIGN="CENTER"><xsl:value-of select="SMRPOLV_ACT_COURSES"/></TD>
   </TR>
</xsl:for-each>
</TABLE>
</xsl:if>
</xsl:template>
<xsl:template match="SMRPONC_ROWSET">
<xsl:choose>
<xsl:when test="($cprt_pncr_met_ind='N'  and $pogn_ncrse_req_met_ind='Y') or
                ($cprt_pncr_nmet_ind='2' and $pogn_ncrse_req_met_ind='N')">
   <TD COLSPAN="1" CLASS="dddefault" ></TD>
</xsl:when>
<xsl:otherwise>
<BR></BR>
<TABLE CLASS="datadisplaytable" WIDTH="65%" SUMMARY="summary">
<CAPTION class="captiontext">Non Course Requirements</CAPTION>
<TR>
<TH CLASS="ddheader" scope="col">Met</TH>
<TH CLASS="ddheader" scope="col">Requirement</TH>
</TR>
<xsl:for-each select="SMRPONC_SET">
<TR>
     <xsl:choose>
         <xsl:when test="SMRPONC_MET_IND = 'Y'">
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>
   <TD CLASS="dddefault" ALIGN="CENTER"><xsl:value-of select="SMRPONC_NCRQ_DESC"/></TD>
</TR>
</xsl:for-each>
</TABLE>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<xsl:template match="SMRPOAT_ROWSET">
<xsl:choose>
<xsl:when test="($cprt_patr_met_ind='N' and $pogn_attr_req_met_ind='Y') or 
                ($cprt_patr_nmet_ind='2' and $pogn_attr_req_met_ind='N')">
   <TD COLSPAN="1" CLASS="dddefault" ></TD>
</xsl:when>
<xsl:otherwise>
<BR></BR>
<TABLE CLASS="datadisplaytable" WIDTH="65%" SUMMARY="summary">
<CAPTION class="captiontext">Program Required Attributes</CAPTION>
<TR>
<TH CLASS="ddheader" scope="col">Met</TH>
<TH CLASS="ddheader" scope="col">Course Attribute</TH>
<TH CLASS="ddheader" scope="col">Student Attribute</TH>
<TH CLASS="ddheader" scope="col">Required Credits</TH>
<TH CLASS="ddheader" scope="col">And/Or</TH>
<TH CLASS="ddheader" scope="col">Actual Credits</TH>
<TH CLASS="ddheader" scope="col">Actual Courses</TH>
</TR>
<xsl:for-each select="SMRPOAT_SET">
<TR>
   <xsl:choose>
   <xsl:when test="(SMRPOAT_MET_IND = 'Y')">
   <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:call-template name="yes_no_ind_format">
   <xsl:with-param name="yes_no_ind"><xsl:value-of select="SMRPOAT_MET_IND"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   </xsl:when>
   <xsl:otherwise>
   <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
      <xsl:call-template name="yes_no_ind_format">
         <xsl:with-param name="yes_no_ind"><xsl:value-of select="SMRPOAT_MET_IND"/></xsl:with-param>
      </xsl:call-template>
   </font></TD>
   </xsl:otherwise>
   </xsl:choose>
   <xsl:choose>
      <xsl:when test="$codedisplay = 'Y'">
         <TD CLASS="dddefault" ALIGN="CENTER"><xsl:value-of select="SMRPOAT_ATTR_CODE"/></TD>
         <TD CLASS="dddefault" ALIGN="CENTER"><xsl:value-of select="SMRPOAT_ATTS_CODE"/></TD>
      </xsl:when>
      <xsl:otherwise>
         <TD CLASS="dddefault" ALIGN="CENTER"><xsl:value-of select="SMRPOAT_ATTR_DESC"/></TD>
         <TD CLASS="dddefault" ALIGN="CENTER"><xsl:value-of select="SMRPOAT_ATTS_DESC"/></TD>
      </xsl:otherwise>
   </xsl:choose>
   <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMRPOAT_REQ_CREDITS"/></xsl:with-param>
      </xsl:call-template>
  </TD>
   <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:call-template name="connector_format">
         <xsl:with-param name="connect_ind"><xsl:value-of select="SMRPOAT_CONNECTOR_REQ"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMRPOAT_ACT_CREDITS"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault" ALIGN="CENTER"><xsl:value-of select="SMRPOAT_ACT_COURSES"/></TD>
</TR>
</xsl:for-each>
</TABLE>
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<xsl:template match="SMRPOSA">
<xsl:if test="($cprt_prsa_ind != '2' or $cprt_prsc_text_ind != '2')">
<!-- Defect 1-7PA6RT -->
<BR></BR>
<TABLE CLASS="datadisplaytable" WIDTH="65%" SUMMARY="summary">
<xsl:if test="($cprt_prsa_ind != '2')">
<CAPTION class="captiontext">Program Restricted Subjects and Attributes</CAPTION>
<TR>
<TH CLASS="ddheader" scope="col">Subject</TH>
<TH CLASS="ddheader" scope="col">Attribute</TH>
<TH CLASS="ddheader" scope="col">Low</TH>
<TH CLASS="ddheader" scope="col">High</TH>
<TH CLASS="ddheader" scope="col">Campus</TH>
<TH CLASS="ddheader" scope="col">College</TH>
<TH CLASS="ddheader" scope="col">Department</TH>
<TH CLASS="ddheader" scope="col">Maximum Credits</TH>
<TH CLASS="ddheader" scope="col">And/Or</TH>
<TH CLASS="ddheader" scope="col">Actual Credits</TH>
<TH CLASS="ddheader" scope="col">Actual Courses</TH>
</TR>
</xsl:if>
<xsl:for-each select="SMRPOSA_DETAIL">
    <xsl:if test="$cprt_prsa_ind !='2'" >
    <xsl:apply-templates select="SMRPOSA_ROWSET"/>
    </xsl:if>
    <xsl:if test="$cprt_prsc_text_ind != '2'">
    <xsl:apply-templates select="SMRSPRC_ROWSET"/>
    <xsl:apply-templates select="SMRPRSC_ROWSET"/>
    </xsl:if>
</xsl:for-each>
</TABLE>
</xsl:if>
</xsl:template>
<xsl:template match="SMRPOSA_ROWSET">
<!-- Defect 1-7PA6RT 
<BR></BR>
-->
<xsl:for-each select="SMRPOSA_SET">
<TR>
   <xsl:choose>
      <xsl:when test="$codedisplay = 'Y'">
         <TD CLASS="dddefault"><xsl:value-of select="SMRPOSA_SUBJ_CODE"/></TD>
         <TD CLASS="dddefault"><xsl:value-of select="SMRPOSA_ATTR_CODE"/></TD>
      </xsl:when>
      <xsl:otherwise>
         <TD CLASS="dddefault"><xsl:value-of select="SMRPOSA_SUBJ_DESC"/></TD>
         <TD CLASS="dddefault"><xsl:value-of select="SMRPOSA_ATTR_DESC"/></TD>
      </xsl:otherwise>
   </xsl:choose>
   <TD CLASS="dddefault"><xsl:value-of select="SMRPOSA_CRSE_NUMB_LOW"/></TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRPOSA_CRSE_NUMB_HIGH"/></TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRPOSA_CAMP_DESC"/></TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRPOSA_COLL_DESC"/></TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRPOSA_DEPT_DESC"/></TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMRPOSA_MAX_CREDITS"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="connector_format">
         <xsl:with-param name="connect_ind"><xsl:value-of select="SMRPOSA_CONNECTOR_MAX"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMRPOSA_ACT_CREDITS"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRPOSA_ACT_COURSES"/></TD>
</TR>
</xsl:for-each>
</xsl:template>
<xsl:template match="SMRPRSC_ROWSET">
<TR></TR>
<TR><TD></TD>
<TD class="captiontext" COLSPAN="10">Program Restricted Subject/Attribute Text</TD>
<TD></TD>
</TR>
<TR>
<TD></TD>
<TD CLASS="dddefault" COLSPAN="10">
<xsl:for-each select="SMRPRSC_SET">
   <xsl:value-of select="SMRPRSC_TEXT" disable-output-escaping="yes"/>&#xa0;
</xsl:for-each>
</TD>
</TR>
<TR></TR>
</xsl:template>
<xsl:template match="SMRSPRC_ROWSET">
<TR></TR>
<TR><TD></TD>
<TD class="captiontext" COLSPAN="10">Adjusted Program Restricted Subject/Attribute Text</TD>
<TD></TD>
</TR>
<TR><TD></TD>
<TD CLASS="dddefault" COLSPAN="10">
<xsl:for-each select="SMRSPRC_SET">
   <xsl:value-of select="SMRSPRC_TEXT" disable-output-escaping="yes"/>&#xa0;
</xsl:for-each>
</TD>
</TR>
<TR></TR>
</xsl:template>
<xsl:template match="SMRPOGD">
<xsl:if test="($cprt_prgd_ind != '2' or $cprt_prgc_text_ind != '2')">
<BR></BR>
<TABLE CLASS="datadisplaytable" WIDTH="65%" SUMMARY="summary">
<xsl:if test="($cprt_prgd_ind != '2')">
<CAPTION class="captiontext">Program Restricted Grade</CAPTION>
<TR>
<TH CLASS="ddheader" scope="col">Grade</TH>
<TH CLASS="ddheader" scope="col">Maximum Credits</TH>
<TH CLASS="ddheader" scope="col">And/Or</TH>
<TH CLASS="ddheader" scope="col">Maximum Courses</TH>
<TH CLASS="ddheader" scope="col">Actual Credits</TH>
<TH CLASS="ddheader" scope="col">Actual Courses</TH>
</TR>
</xsl:if>
<xsl:for-each select="SMRPOGD_DETAIL">
    <xsl:if test="$cprt_prgd_ind !='2'" >
    <xsl:apply-templates select="SMRPOGD_ROWSET"/>
    </xsl:if>
    <xsl:if test="$cprt_prgc_text_ind != '2'">
    <xsl:apply-templates select="SMRSPGC_ROWSET"/>
    <xsl:apply-templates select="SMRPRGC_ROWSET"/>
    </xsl:if>
</xsl:for-each>
</TABLE>
</xsl:if>
</xsl:template>
<xsl:template match="SMRPOGD_ROWSET">
<xsl:for-each select="SMRPOGD_SET">
<TR>
   <TD CLASS="dddefault"><xsl:value-of select="SMRPOGD_GRDE_CODE"/></TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMRPOGD_MAX_CREDITS"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="connector_format">
         <xsl:with-param name="connect_ind"><xsl:value-of select="SMRPOGD_CONNECTOR_MAX"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRPOGD_MAX_COURSES"/></TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMRPOGD_ACT_CREDITS"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRPOGD_ACT_COURSES"/></TD>
</TR>
</xsl:for-each>
</xsl:template>
<xsl:template match="SMRSPGC_ROWSET">
<TR></TR>
<TR><TD></TD>
<TD class="captiontext" COLSPAN="5">Adjusted Program Restricted Grade Text</TD>
<TD></TD>
</TR>
<TR><TD></TD>
<TD CLASS="dddefault" COLSPAN="5">
<xsl:for-each select="SMRSPGC_SET">
   <xsl:value-of select="SMRSPGC_TEXT" disable-output-escaping="yes"/>&#xa0;
</xsl:for-each>
</TD>
</TR>
<TR></TR>
</xsl:template>
<xsl:template match="SMRPRGC_ROWSET">
<TR></TR>
<TR><TD></TD>
<TD class="captiontext" COLSPAN="5">Program Restricted Grade Text</TD>
<TD></TD>
</TR>
<TR><TD></TD>
<TD CLASS="dddefault" COLSPAN="5">
<xsl:for-each select="SMRPRGC_SET">
   <xsl:value-of select="SMRPRGC_TEXT" disable-output-escaping="yes"/>&#xa0;
</xsl:for-each>
</TD>
</TR>
<TR></TR>
</xsl:template>

<xsl:template match="SMBAOGN_ROWSET/SMBAOGN_SET">
	<TR>
    <TD CLASS="ddddefault" ALIGN="LEFT"><xsl:attribute name="NAME">
                                        <xsl:value-of select="SMBAOGN_AREA_DESC"/>
                                         </xsl:attribute>
                                        <xsl:value-of select="SMBAOGN_AREA_DESC"/>
      Total Required :
      </TD>

<!--
   <xsl:if test="(SMBAOGN_REQ_CREDITS_OVERALL) or (SMBAOGN_REQ_COURSES_OVERALL)">
   <TR>
      <TH COLSPAN="1" CLASS="ddlabel" scope="row" ALIGN="LEFT">Total Required :</TH>
-->
     <!-- Defect 1-6JRZGV -->

      <xsl:choose>
      <xsl:when test="(SMBAOGN_REQ_CREDITS_OVERALL) and (SMBAOGN_REQ_COURSES_OVERALL)">
      <xsl:choose>
         <xsl:when test="SMBAOGN_CONNECTOR_OVERALL ='A'">
            <xsl:choose>
               <xsl:when test="(SMBAOGN_ACT_CREDITS_OVERALL &gt;= SMBAOGN_REQ_CREDITS_OVERALL) and
                               (SMBAOGN_ACT_COURSES_OVERALL &gt;= SMBAOGN_REQ_COURSES_OVERALL)">
                  <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
                  <xsl:call-template name="yes_no_ind_format">
                  <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
                  </xsl:call-template>
                  </font>
                  </TD>
               </xsl:when>
               <xsl:otherwise>
                  <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
                  <xsl:call-template name="yes_no_ind_format">
                  <xsl:with-param name="yes_no_ind">N</xsl:with-param>
                  </xsl:call-template>
                  </font></TD>
               </xsl:otherwise>
             </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
               <xsl:when test="(SMBAOGN_ACT_CREDITS_OVERALL &gt;= SMBAOGN_REQ_CREDITS_OVERALL) or
                               (SMBAOGN_ACT_COURSES_OVERALL &gt;= SMBAOGN_REQ_COURSES_OVERALL)">
                  <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
                  <xsl:call-template name="yes_no_ind_format">
                  <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
                  </xsl:call-template>
                  </font></TD>
               </xsl:when>
               <xsl:otherwise>
                  <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
                  <xsl:call-template name="yes_no_ind_format">
                  <xsl:with-param name="yes_no_ind">N</xsl:with-param>
                  </xsl:call-template>
                  </font></TD>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
      </xsl:when>


     <xsl:when test="(SMBAOGN_REQ_CREDITS_OVERALL)">
      <xsl:choose>
         <xsl:when test="(SMBAOGN_ACT_CREDITS_OVERALL &gt;= SMBAOGN_REQ_CREDITS_OVERALL)"> 
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>

      </xsl:when>

      <xsl:when test="(SMBAOGN_REQ_COURSES_OVERALL)">
      <xsl:choose>
         <xsl:when test="(SMBAOGN_ACT_COURSES_OVERALL &gt;= SMBAOGN_REQ_COURSES_OVERALL)">
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>
      </xsl:when>

         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
          </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>


     <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMBAOGN_REQ_CREDITS_OVERALL"/></xsl:with-param>
      </xsl:call-template>
      </TD>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMBAOGN_ACT_CREDITS_OVERALL"/></xsl:with-param>
      </xsl:call-template>
      </TD>
</TR>
<!--
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:value-of select="SMBAOGN_REQ_COURSES_OVERALL"/>
      </TD>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:value-of select="SMBAOGN_ACT_COURSES_OVERALL"/>
      </TD>
   </TR>
-->
<!--
   </xsl:if>
   <xsl:if test="(SMBAOGN_REQ_CREDITS_INST) or (SMBAOGN_REQ_COURSES_INST)">
      <TR>
      <TH COLSPAN="1" CLASS="ddlabel" scope="row" ALIGN="LEFT">Required Institutional:</TH>
      <xsl:choose>
      <xsl:when test="(SMBAOGN_REQ_CREDITS_INST) and (SMBAOGN_REQ_COURSES_INST)">
      <xsl:choose>
         <xsl:when test="SMBAOGN_CONNECTOR_INST ='A'">
            <xsl:choose>
               <xsl:when test="(SMBAOGN_ACT_CREDITS_INST &gt;= SMBAOGN_REQ_CREDITS_INST) and
                               (SMBAOGN_ACT_COURSES_INST &gt;= SMBAOGN_REQ_COURSES_INST)">
                  <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
                  <xsl:call-template name="yes_no_ind_format">
                  <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
                  </xsl:call-template>
                  </font></TD>
               </xsl:when>
               <xsl:otherwise>
                  <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
                  <xsl:call-template name="yes_no_ind_format">
                  <xsl:with-param name="yes_no_ind">N</xsl:with-param>
                  </xsl:call-template>
                  </font></TD>
               </xsl:otherwise>
             </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
               <xsl:when test="(SMBAOGN_ACT_CREDITS_INST &gt;= SMBAOGN_REQ_CREDITS_INST) or
                               (SMBAOGN_ACT_COURSES_INST &gt;= SMBAOGN_REQ_COURSES_INST)">
                  <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
                  <xsl:call-template name="yes_no_ind_format">
                  <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
                  </xsl:call-template>
                  </font></TD>
               </xsl:when>
               <xsl:otherwise>
                  <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
                  <xsl:call-template name="yes_no_ind_format">
                  <xsl:with-param name="yes_no_ind">N</xsl:with-param>
                  </xsl:call-template>
                  </font></TD>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
      </xsl:when>
      <xsl:when test="(SMBAOGN_REQ_CREDITS_INST)">
      <xsl:choose>
         <xsl:when test="(SMBAOGN_ACT_CREDITS_INST &gt;= SMBAOGN_REQ_CREDITS_INST)">
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>
      </xsl:when>
      <xsl:when test="(SMBAOGN_REQ_COURSES_INST)">
      <xsl:choose>
         <xsl:when test="(SMBAOGN_ACT_COURSES_INST &gt;= SMBAOGN_REQ_COURSES_INST)">
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>
     </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
          </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMBAOGN_REQ_CREDITS_INST"/></xsl:with-param>
      </xsl:call-template>
      </TD>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMBAOGN_ACT_CREDITS_INST"/></xsl:with-param>
      </xsl:call-template>
      </TD>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:value-of select="SMBAOGN_REQ_COURSES_INST"/>
      </TD>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:value-of select="SMBAOGN_ACT_COURSES_INST"/>
      </TD>
   </TR>
   </xsl:if>
   <xsl:if test="(SMBAOGN_REQ_CREDITS_I_TRAD) or (SMBAOGN_REQ_COURSES_I_TRAD)">
      <TR>
      <TH COLSPAN="1" CLASS="ddlabel" scope="row" ALIGN="LEFT">Institutional Traditional:</TH>
      <xsl:choose>
      <xsl:when test="(SMBAOGN_REQ_CREDITS_I_TRAD) and (SMBAOGN_REQ_COURSES_I_TRAD)">
      <xsl:choose>
         <xsl:when test="SMBAOGN_CONNECTOR_I_TRAD ='A'">
            <xsl:choose>
               <xsl:when test="(SMBAOGN_ACT_CREDITS_I_TRAD &gt;= SMBAOGN_REQ_CREDITS_I_TRAD) and
                               (SMBAOGN_ACT_COURSES_I_TRAD &gt;= SMBAOGN_REQ_COURSES_I_TRAD)">
                  <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
                  <xsl:call-template name="yes_no_ind_format">
                  <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
                  </xsl:call-template>
                  </font></TD>
               </xsl:when>
               <xsl:otherwise>
                  <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
                  <xsl:call-template name="yes_no_ind_format">
                  <xsl:with-param name="yes_no_ind">N</xsl:with-param>
                  </xsl:call-template>
                  </font></TD>
               </xsl:otherwise>
             </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
               <xsl:when test="(SMBAOGN_ACT_CREDITS_I_TRAD &gt;= SMBAOGN_REQ_CREDITS_I_TRAD) or
                               (SMBAOGN_ACT_COURSES_I_TRAD &gt;= SMBAOGN_REQ_COURSES_I_TRAD)">
                  <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
                  <xsl:call-template name="yes_no_ind_format">
                  <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
                  </xsl:call-template>
                  </font></TD>
               </xsl:when>
               <xsl:otherwise>
                  <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
                  <xsl:call-template name="yes_no_ind_format">
                  <xsl:with-param name="yes_no_ind">N</xsl:with-param>
                  </xsl:call-template>
                  </font></TD>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
      </xsl:when>
      <xsl:when test="(SMBAOGN_REQ_CREDITS_I_TRAD)">
      <xsl:choose>
         <xsl:when test="(SMBAOGN_ACT_CREDITS_I_TRAD &gt;= SMBAOGN_REQ_CREDITS_I_TRAD)">
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>
      </xsl:when>
      <xsl:when test="(SMBAOGN_REQ_COURSES_I_TRAD)">
      <xsl:choose>
         <xsl:when test="(SMBAOGN_ACT_COURSES_I_TRAD &gt;= SMBAOGN_REQ_COURSES_I_TRAD)">
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>
      </xsl:when>
       <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
          </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMBAOGN_REQ_CREDITS_I_TRAD"/></xsl:with-param>
      </xsl:call-template>
      </TD>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMBAOGN_ACT_CREDITS_I_TRAD"/></xsl:with-param>
      </xsl:call-template>
      </TD>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:value-of select="SMBAOGN_REQ_COURSES_I_TRAD"/>
      </TD>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:value-of select="SMBAOGN_ACT_COURSES_I_TRAD"/>
      </TD>
      </TR>      
   </xsl:if>
   <xsl:if test="(SMBAOGN_MAX_CREDITS_I_NONTRAD) or (SMBAOGN_MAX_COURSES_I_NONTRAD)">
      <TR>
      <TH COLSPAN="1" CLASS="ddlabel" scope="row" ALIGN="LEFT">Max Inst. Non-Traditional:</TH>
      <TD CLASS="dddefault" ALIGN="CENTER"></TD>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMBAOGN_MAX_CREDITS_I_NONTRAD"/></xsl:with-param>
      </xsl:call-template>
      </TD>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMBAOGN_ACT_CREDITS_I_NONTRAD"/></xsl:with-param>
      </xsl:call-template>
      </TD>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:value-of select="SMBAOGN_MAX_COURSES_I_NONTRAD"/>
      </TD>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:value-of select="SMBAOGN_ACT_COURSES_I_NONTRAD"/>
      </TD>
      </TR>     
   </xsl:if>
   <xsl:if test="(SMBAOGN_MAX_CREDITS_TRANSFER) or (SMBAOGN_MAX_COURSES_TRANSFER)">
      <TR>
      <TH COLSPAN="1" CLASS="ddlabel" scope="row" ALIGN="LEFT">Max Transfer :</TH>
      <TD CLASS="dddefault" ALIGN="CENTER">
      </TD>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMBAOGN_MAX_CREDITS_TRANSFER"/></xsl:with-param>
      </xsl:call-template>
      </TD>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMBAOGN_ACT_CREDITS_TRANSFER"/></xsl:with-param>
      </xsl:call-template>
      </TD>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:value-of select="SMBAOGN_MAX_COURSES_TRANSFER"/>
      </TD>
      <TD CLASS="dddefault" ALIGN="CENTER">
      <xsl:value-of select="SMBAOGN_ACT_COURSES_TRANSFER"/>
      </TD>      
   </TR> 
   </xsl:if>
   <xsl:if test="(SMBAOGN_MIN_AREA_GPA)"> 
      <TR>
      <TH COLSPAN="1" CLASS="ddlabel" scope="row" ALIGN="LEFT">Area GPA :</TH>
      <xsl:choose>
         <xsl:when test="SMBAOGN_ACT_AREA_GPA &lt; SMBAOGN_MIN_AREA_GPA">
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="(SMBAOGN_MIN_AREA_GPA)">
            <TD CLASS="dddefault" ALIGN="CENTER">
            <xsl:value-of select="format-number(SMBAOGN_MIN_AREA_GPA,$gpafmt)"/>
            </TD>
         </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER">
            </TD>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="(SMBAOGN_ACT_AREA_GPA)">
            <TD CLASS="dddefault" ALIGN="CENTER">
            <xsl:value-of select="format-number(SMBAOGN_ACT_AREA_GPA,$gpafmt)"/>
            </TD>
         </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER">
            </TD>
         </xsl:otherwise>
      </xsl:choose>
   </TR>
   </xsl:if>
-->
   

</xsl:template>

<xsl:template match="SMRACMT_ROWSET">
<xsl:if test="SMRACMT_SET/SMRACMT_TEXT">
<xsl:if test="$cprt_acmt_text_ind='2'">
   <BR></BR>
</xsl:if>
<xsl:if test="$cprt_acmt_text_ind!='2'">
<BR></BR>
<TABLE CLASS="datadisplaytable" WIDTH="65%" SUMMARY="summary">
<CAPTION class="captiontext">Area Description</CAPTION>
<TR>
<TD CLASS="dddefault">
<xsl:for-each select="SMRACMT_SET">
<xsl:value-of select="SMRACMT_TEXT" disable-output-escaping="yes"/>&#xa0;
</xsl:for-each>
</TD>
</TR>
</TABLE>
</xsl:if>
</xsl:if>
</xsl:template>
<xsl:template match="SMRSACM_ROWSET">
<xsl:if test="SMRSACM_SET/SMRSACM_TEXT">
<xsl:if test="$cprt_acmt_text_ind='2'">
   <BR></BR>
</xsl:if>
<xsl:if test="$cprt_acmt_text_ind!='2'">
<BR></BR>
<TABLE CLASS="datadisplaytable" WIDTH="65%" SUMMARY="summary">
<CAPTION class="captiontext">Adjusted Area Description</CAPTION>
<TR>
<TD CLASS="dddefault">
<xsl:for-each select="SMRSACM_SET">
   <xsl:value-of select="SMRSACM_TEXT" disable-output-escaping="yes"/>&#xa0;
</xsl:for-each>
</TD>
</TR>
</TABLE>
</xsl:if>
</xsl:if>
</xsl:template>
<xsl:template match="SMRAOLV_ROWSET">
<xsl:if test="($cprt_alvl_ind!='2')">
<BR></BR>
<TABLE CLASS="datadisplaytable" WIDTH="65%" SUMMARY="summary">
<CAPTION class="captiontext">Area Additional Levels</CAPTION>
<TR>
<TH CLASS="ddheader" scope="col" >Level</TH>
<TH CLASS="ddheader" scope="col" >Incl/Excl</TH>
<TH CLASS="ddheader" scope="col" >Grade</TH>
<TH CLASS="ddheader" scope="col" >Max Credits</TH>
<TH CLASS="ddheader" scope="col" >And/Or</TH>
<TH CLASS="ddheader" scope="col" >Actual Credits</TH>
<TH CLASS="ddheader" scope="col" >Actual Courses</TH>
</TR>
<xsl:for-each select="SMRAOLV_SET">
<TR>
   <TD CLASS="dddefault"><xsl:value-of select="SMRAOLV_LEVL_DESC"/></TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="incl_excl_format">
         <xsl:with-param name="incl_excl"><xsl:value-of select="SMRAOLV_INCL_EXCL_IND"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRAOLV_GRDE_CODE_MIN"/></TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMRAOLV_MAX_CREDITS"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="connector_format">
         <xsl:with-param name="connect_ind"><xsl:value-of select="SMRAOLV_CONNECTOR_MAX"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMRAOLV_ACT_CREDITS"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRAOLV_ACT_COURSES"/></TD>
</TR>
</xsl:for-each>
</TABLE>
</xsl:if>
</xsl:template>
<xsl:template match="SMRAOSA">
<xsl:if test="($cprt_arsa_ind != '2' or $cprt_arsc_text_ind != '2')">
<BR></BR>
<TABLE CLASS="datadisplaytable" WIDTH="65%" SUMMARY="summary">
<xsl:if test="($cprt_arsa_ind != '2')">
<CAPTION class="captiontext">Area Restricted Subjects and Attributes</CAPTION>
<TR>
<TH CLASS="ddheader" scope="col" >Subject</TH>
<TH CLASS="ddheader" scope="col" >Attribute</TH>
<TH CLASS="ddheader" scope="col" >Low</TH>
<TH CLASS="ddheader" scope="col" >High</TH>
<TH CLASS="ddheader" scope="col" >Campus</TH>
<TH CLASS="ddheader" scope="col" >College</TH>
<TH CLASS="ddheader" scope="col" >Department</TH>
<TH CLASS="ddheader" scope="col" >Maximum Credits</TH>
<TH CLASS="ddheader" scope="col" >And/Or</TH>
<TH CLASS="ddheader" scope="col" >Actual Credits</TH>
<TH CLASS="ddheader" scope="col" >Actual Courses</TH>
</TR>
</xsl:if>
<xsl:for-each select="SMRAOSA_DETAIL">
    <xsl:if test="$cprt_arsa_ind !='2'" >
    <xsl:apply-templates select="SMRAOSA_ROWSET"/>
    </xsl:if>
    <xsl:if test="$cprt_arsc_text_ind != '2'">
    <xsl:apply-templates select="SMRSARC_ROWSET"/>
    <xsl:apply-templates select="SMRARSC_ROWSET"/>
    </xsl:if>
</xsl:for-each>
</TABLE>
</xsl:if>
</xsl:template>
<xsl:template match="SMRAOSA_ROWSET">
<BR></BR>
<xsl:for-each select="SMRAOSA_SET">
<TR>
   <xsl:choose>
      <xsl:when test="$codedisplay = 'Y'">
         <TD CLASS="dddefault"><xsl:value-of select="SMRAOSA_SUBJ_CODE"/></TD>
         <TD CLASS="dddefault"><xsl:value-of select="SMRAOSA_ATTR_CODE"/></TD>
      </xsl:when>
      <xsl:otherwise>
         <TD CLASS="dddefault"><xsl:value-of select="SMRAOSA_SUBJ_DESC"/></TD>
         <TD CLASS="dddefault"><xsl:value-of select="SMRAOSA_ATTR_DESC"/></TD>
      </xsl:otherwise>
   </xsl:choose>
   <TD CLASS="dddefault"><xsl:value-of select="SMRAOSA_CRSE_NUMB_LOW"/></TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRAOSA_CRSE_NUMB_HIGH"/></TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRAOSA_CAMP_DESC"/></TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRAOSA_COLL_DESC"/></TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRAOSA_DEPT_DESC"/></TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMRAOSA_MAX_CREDITS"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="connector_format">
         <xsl:with-param name="connect_ind"><xsl:value-of select="SMRAOSA_CONNECTOR_MAX"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMRAOSA_ACT_CREDITS"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRAOSA_ACT_COURSES"/></TD>
</TR>
</xsl:for-each>
</xsl:template>
<xsl:template match="SMRARSC_ROWSET">
<TR></TR>
<TR><TD></TD>
<TD class="captiontext" COLSPAN="10">Area Restricted Subject/Attribute Text</TD>
<TD></TD>
</TR>
<TR><TD></TD>
<TD CLASS="dddefault" COLSPAN="10">
<xsl:for-each select="SMRARSC_SET">
   <xsl:value-of select="SMRARSC_TEXT" disable-output-escaping="yes"/>&#xa0;
</xsl:for-each>
</TD>
</TR>
<TR></TR>
</xsl:template>
<xsl:template match="SMRSARC_ROWSET">
<TR></TR>
<TR><TD></TD>
<TD class="captiontext" COLSPAN="10">Area Restricted Subject/Attribute Text</TD>
</TR>
<TR><TD></TD>
<TD CLASS="dddefault" COLSPAN="10">
<xsl:for-each select="SMRSARC_SET">
   <xsl:value-of select="SMRSARC_TEXT" disable-output-escaping="yes"/>&#xa0;
</xsl:for-each>
</TD>
</TR>
<TR></TR>
</xsl:template>
<xsl:template match="SMRAOGD">
<xsl:if test="($cprt_argd_ind != '2' or $cprt_argc_text_ind != '2')">
<BR></BR>
<TABLE CLASS="datadisplaytable" WIDTH="65%" SUMMARY="summary">
<xsl:if test="($cprt_argd_ind != '2')">
<CAPTION class="captiontext">Area Restricted Grade</CAPTION>
<TR>
<TH CLASS="ddheader" scope="col">Grade</TH>
<TH CLASS="ddheader" scope="col">Maximum Credits</TH>
<TH CLASS="ddheader" scope="col">And/Or</TH>
<TH CLASS="ddheader" scope="col">Maximum Courses</TH>
<TH CLASS="ddheader" scope="col">Actual Credits</TH>
<TH CLASS="ddheader" scope="col">Actual Courses</TH>
</TR>
</xsl:if>
<xsl:for-each select="SMRAOGD_DETAIL">
    <xsl:if test="$cprt_argd_ind !='2'" >
    <xsl:apply-templates select="SMRAOGD_ROWSET"/>
    </xsl:if>
    <xsl:if test="$cprt_argc_text_ind != '2'">
    <xsl:apply-templates select="SMRSAGC_ROWSET"/>
    <xsl:apply-templates select="SMRARGC_ROWSET"/>
    </xsl:if>
</xsl:for-each>
</TABLE>
</xsl:if>
</xsl:template>
<xsl:template match="SMRAOGD_ROWSET">
<xsl:for-each select="SMRAOGD_SET">
<TR>
   <TD CLASS="dddefault"><xsl:value-of select="SMRAOGD_GRDE_CODE"/></TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMRAOGD_MAX_CREDITS"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="connector_format">
         <xsl:with-param name="connect_ind"><xsl:value-of select="SMRAOGD_CONNECTOR_MAX"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRAOGD_MAX_COURSES"/></TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMRAOGD_ACT_CREDITS"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRAOGD_ACT_COURSES"/></TD>
</TR>
</xsl:for-each>
</xsl:template>
<xsl:template match="SMRSAGC_ROWSET">
<TR></TR>
<TR><TD></TD>
<TD class="captiontext" COLSPAN="5">Adjusted Area Restricted Grade Text</TD>
<TD></TD>
</TR>
<TR><TD></TD>
<TD CLASS="dddefault" COLSPAN="5">
<xsl:for-each select="SMRSAGC_SET">
   <xsl:value-of select="SMRSAGC_TEXT" disable-output-escaping="yes"/>&#xa0;
</xsl:for-each>
</TD>
</TR>
<TR></TR>
</xsl:template>
<xsl:template match="SMRARGC_ROWSET">
<TR></TR>
<TR><TD></TD>
<TD class="captiontext" COLSPAN="5">Area Restricted Grade Text</TD>
<TD></TD>
</TR>
<TR><TD></TD>
<TD CLASS="dddefault" COLSPAN="5">
<xsl:for-each select="SMRARGC_SET">
   <xsl:value-of select="SMRARGC_TEXT" disable-output-escaping="yes"/>&#xa0;
</xsl:for-each>
</TD>
</TR>
<TR></TR>
</xsl:template>

<xsl:template match="SMRGOAT_ROWSET">
<xsl:if test="($cprt_agam_ind!='2')">
<BR></BR>
<TABLE CLASS="datadisplaytable" WIDTH="65%" SUMMARY="summary">
<CAPTION class="captiontext">Area Attached Groups</CAPTION>
<TR>
<TD CLASS="ddheader">Met</TD>
<TD CLASS="ddheader">Description</TD>
<TD CLASS="ddheader">General Requirements Met</TD>
<TD CLASS="ddheader">Detail Requirements Met</TD>
</TR>
<xsl:for-each select="SMRGOAT_SET">
<TR>
      <xsl:choose>
         <xsl:when test="SMRGOAT_MET_IND = 'Y'">
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>
   <TD CLASS="dddefault"><xsl:value-of select="SMRGOAT_GROUP_DESC"/></TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="yes_no_ind_format">
         <xsl:with-param name="yes_no_ind"><xsl:value-of select="SMRGOAT_GEN_REQ_MET_IND"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="yes_no_ind_format">
         <xsl:with-param name="yes_no_ind"><xsl:value-of select="SMRGOAT_DETL_REQ_MET_IND"/></xsl:with-param>
      </xsl:call-template>
   </TD>
</TR>
</xsl:for-each>
</TABLE>
</xsl:if>
</xsl:template>
<xsl:template match="SMBGOGN_ROWSET/SMBGOGN_SET">
<BR></BR>
<TABLE CLASS="datadisplaytable" WIDTH="65%" SUMMARY="summary">
   <CAPTION class="captiontext">Group Requirements </CAPTION>
   <TR>
      <TD COLSPAN="1" CLASS="dddead"></TD>
      <TH ROWSPAN="2" CLASS="ddheader" scope="col" >Met</TH>
      <TH COLSPAN="2" CLASS="ddtitle" scope="colgroup">Credits</TH>
      <TH COLSPAN="2" CLASS="ddtitle" scope="colgroup">Courses</TH>
   </TR>   
   <TR>
      <TH CLASS="ddheader" scope="col" >Group : <xsl:value-of select="SMBGOGN_GROUP_DESC"/></TH>
      <TH CLASS="ddheader" scope="col" >Required</TH>
      <TH CLASS="ddheader" scope="col" >Used</TH>
      <TH CLASS="ddheader" scope="col" >Required</TH>
      <TH CLASS="ddheader" scope="col" >Used</TH>
   </TR>
   <xsl:if test="(SMBGOGN_REQ_CREDITS_OVERALL) or (SMBGOGN_REQ_COURSES_OVERALL)">
   <TR>
   <TH COLSPAN="1" CLASS="ddlabel" scope="row" >Total Required :</TH>
      <!-- Defect 1-6JRZGV -->
      <xsl:choose>
      <xsl:when test="(SMBGOGN_REQ_CREDITS_OVERALL) and (SMBGOGN_REQ_COURSES_OVERALL)">
      <xsl:choose>
         <xsl:when test="SMBGOGN_CONNECTOR_OVERALL ='A'">
            <xsl:choose>
               <xsl:when test="(SMBGOGN_ACT_CREDITS_OVERALL &gt;= SMBGOGN_REQ_CREDITS_OVERALL) and
                               (SMBGOGN_ACT_COURSES_OVERALL &gt;= SMBGOGN_REQ_COURSES_OVERALL)">
                  <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
                  <xsl:call-template name="yes_no_ind_format">
                  <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
                  </xsl:call-template>
                  </font></TD>
               </xsl:when>
               <xsl:otherwise>
                  <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
                  <xsl:call-template name="yes_no_ind_format">
                  <xsl:with-param name="yes_no_ind">N</xsl:with-param>
                  </xsl:call-template>
                  </font></TD>
               </xsl:otherwise>
             </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
               <xsl:when test="(SMBGOGN_ACT_CREDITS_OVERALL &gt;= SMBGOGN_REQ_CREDITS_OVERALL) or
                               (SMBGOGN_ACT_COURSES_OVERALL &gt;= SMBGOGN_REQ_COURSES_OVERALL)">
                  <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
                  <xsl:call-template name="yes_no_ind_format">
                  <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
                  </xsl:call-template>
                  </font></TD>
               </xsl:when>
               <xsl:otherwise>
                  <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
                  <xsl:call-template name="yes_no_ind_format">
                  <xsl:with-param name="yes_no_ind">N</xsl:with-param>
                  </xsl:call-template>
                  </font></TD>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
      </xsl:when>
      <xsl:when test="(SMBGOGN_REQ_CREDITS_OVERALL)">
      <xsl:choose>
         <xsl:when test="(SMBGOGN_ACT_CREDITS_OVERALL &gt;= SMBGOGN_REQ_CREDITS_OVERALL)"> 
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>
      </xsl:when>
      <xsl:when test="(SMBGOGN_REQ_COURSES_OVERALL)">
      <xsl:choose>
         <xsl:when test="(SMBGOGN_ACT_COURSES_OVERALL &gt;= SMBGOGN_REQ_COURSES_OVERALL)">
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>
      </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
          </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>
      <TD CLASS="dddefault">
         <xsl:call-template name="creditformat">
            <xsl:with-param name="credit_value"><xsl:value-of select="SMBGOGN_REQ_CREDITS_OVERALL"/></xsl:with-param>
         </xsl:call-template>
      </TD>
      <TD CLASS="dddefault">
         <xsl:call-template name="creditformat">
            <xsl:with-param name="credit_value"><xsl:value-of select="SMBGOGN_ACT_CREDITS_OVERALL"/></xsl:with-param>
         </xsl:call-template>
      </TD>
      <TD CLASS="dddefault">
         <xsl:value-of select="SMBGOGN_REQ_COURSES_OVERALL"/>
      </TD>
      <TD CLASS="dddefault">
         <xsl:value-of select="SMBGOGN_ACT_COURSES_OVERALL"/>
      </TD>
   </TR>
   </xsl:if>
   <xsl:if test="(SMBGOGN_REQ_CREDITS_INST) or (SMBGOGN_REQ_COURSES_INST)">
      <TR>
      <TH COLSPAN="1" CLASS="ddlabel" scope="row" >Required Institutional:</TH>
      <xsl:choose>
      <xsl:when test="(SMBGOGN_REQ_CREDITS_INST) and (SMBGOGN_REQ_COURSES_INST)">
      <xsl:choose>
         <xsl:when test="SMBGOGN_CONNECTOR_INST ='A'">
            <xsl:choose>
               <xsl:when test="(SMBGOGN_ACT_CREDITS_INST &gt;= SMBGOGN_REQ_CREDITS_INST) and
                               (SMBGOGN_ACT_COURSES_INST &gt;= SMBGOGN_REQ_COURSES_INST)">
                  <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
                  <xsl:call-template name="yes_no_ind_format">
                  <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
                  </xsl:call-template>
                  </font></TD>
               </xsl:when>
               <xsl:otherwise>
                  <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
                  <xsl:call-template name="yes_no_ind_format">
                  <xsl:with-param name="yes_no_ind">N</xsl:with-param>
                  </xsl:call-template>
                  </font></TD>
               </xsl:otherwise>
             </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
               <xsl:when test="(SMBGOGN_ACT_CREDITS_INST &gt;= SMBGOGN_REQ_CREDITS_INST) or
                               (SMBGOGN_ACT_COURSES_INST &gt;= SMBGOGN_REQ_COURSES_INST)">
                  <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
                  <xsl:call-template name="yes_no_ind_format">
                  <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
                  </xsl:call-template>
                  </font></TD>
               </xsl:when>
               <xsl:otherwise>
                  <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
                  <xsl:call-template name="yes_no_ind_format">
                  <xsl:with-param name="yes_no_ind">N</xsl:with-param>
                  </xsl:call-template>
                  </font></TD>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
      </xsl:when>
      <xsl:when test="(SMBGOGN_REQ_CREDITS_INST)">
      <xsl:choose>
         <xsl:when test="(SMBGOGN_ACT_CREDITS_INST &gt;= SMBGOGN_REQ_CREDITS_INST)">
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>
      </xsl:when>
      <xsl:when test="(SMBGOGN_REQ_COURSES_INST)">
      <xsl:choose>
         <xsl:when test="(SMBGOGN_ACT_COURSES_INST &gt;= SMBGOGN_REQ_COURSES_INST)">
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>
      </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
          </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>
      <TD CLASS="dddefault">
         <xsl:call-template name="creditformat">
            <xsl:with-param name="credit_value"><xsl:value-of select="SMBGOGN_REQ_CREDITS_INST"/></xsl:with-param>
         </xsl:call-template>
      </TD>
      <TD CLASS="dddefault">
         <xsl:call-template name="creditformat">
            <xsl:with-param name="credit_value"><xsl:value-of select="SMBGOGN_ACT_CREDITS_INST"/></xsl:with-param>
         </xsl:call-template>
      </TD>
      <TD CLASS="dddefault">
         <xsl:value-of select="SMBGOGN_REQ_COURSES_INST"/></TD>
      <TD CLASS="dddefault">
         <xsl:value-of select="SMBGOGN_ACT_COURSES_INST"/></TD>
      </TR>
   </xsl:if>
   <xsl:if test="(SMBGOGN_REQ_CREDITS_I_TRAD) or (SMBGOGN_REQ_COURSES_I_TRAD)">
      <TR>
      <TH COLSPAN="1" CLASS="ddlabel" scope="row" >Institutional Traditional:</TH>
      <xsl:choose>
      <xsl:when test="(SMBGOGN_REQ_CREDITS_I_TRAD) and (SMBGOGN_REQ_COURSES_I_TRAD)">
      <xsl:choose>
         <xsl:when test="SMBGOGN_CONNECTOR_I_TRAD ='A'">
            <xsl:choose>
               <xsl:when test="(SMBGOGN_ACT_CREDITS_I_TRAD &gt;= SMBGOGN_REQ_CREDITS_I_TRAD) and
                               (SMBGOGN_ACT_COURSES_I_TRAD &gt;= SMBGOGN_REQ_COURSES_I_TRAD)">
                  <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
                  <xsl:call-template name="yes_no_ind_format">
                  <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
                  </xsl:call-template>
                  </font></TD>
               </xsl:when>
               <xsl:otherwise>
                  <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
                  <xsl:call-template name="yes_no_ind_format">
                  <xsl:with-param name="yes_no_ind">N</xsl:with-param>
                  </xsl:call-template>
                  </font></TD>
               </xsl:otherwise>
             </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
               <xsl:when test="(SMBGOGN_ACT_CREDITS_I_TRAD &gt;= SMBGOGN_REQ_CREDITS_I_TRAD) or
                               (SMBGOGN_ACT_COURSES_I_TRAD &gt;= SMBGOGN_REQ_COURSES_I_TRAD)">
                  <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
                  <xsl:call-template name="yes_no_ind_format">
                  <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
                  </xsl:call-template>
                  </font></TD>
               </xsl:when>
               <xsl:otherwise>
                  <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
                  <xsl:call-template name="yes_no_ind_format">
                  <xsl:with-param name="yes_no_ind">N</xsl:with-param>
                  </xsl:call-template>
                  </font></TD>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
      </xsl:when>
      <xsl:when test="(SMBGOGN_REQ_CREDITS_I_TRAD)">
      <xsl:choose>
         <xsl:when test="(SMBGOGN_ACT_CREDITS_I_TRAD &gt;= SMBGOGN_REQ_CREDITS_I_TRAD)">
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>
      </xsl:when>
      <xsl:when test="(SMBGOGN_REQ_COURSES_I_TRAD)">
      <xsl:choose>
         <xsl:when test="(SMBGOGN_ACT_COURSES_I_TRAD &gt;= SMBGOGN_REQ_COURSES_I_TRAD)">
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>
      </xsl:when>
       <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
          </xsl:call-template>
            </font></TD>
         </xsl:otherwise>
      </xsl:choose>
      <TD CLASS="dddefault">
            <xsl:call-template name="creditformat">
               <xsl:with-param name="credit_value"><xsl:value-of select="SMBGOGN_REQ_CREDITS_I_TRAD"/></xsl:with-param>
            </xsl:call-template>
      </TD>
      <TD CLASS="dddefault">
         <xsl:call-template name="creditformat">
            <xsl:with-param name="credit_value"><xsl:value-of select="SMBGOGN_ACT_CREDITS_I_TRAD"/></xsl:with-param>
         </xsl:call-template>
      </TD>
      <TD CLASS="dddefault">
         <xsl:value-of select="SMBGOGN_REQ_COURSES_I_TRAD"/></TD>
      <TD CLASS="dddefault">
         <xsl:value-of select="SMBGOGN_ACT_COURSES_I_TRAD"/></TD>
      </TR>
   </xsl:if>
   <xsl:if test="(SMBGOGN_MAX_CREDITS_I_NONTRAD) or (SMBGOGN_MAX_COURSES_I_NONTRAD)">
      <TR>
      <TH COLSPAN="1" CLASS="ddlabel" scope="row" >Max Inst. Non-Traditional:</TH>
      <TD CLASS="dddefault" ALIGN="CENTER"></TD>
      <TD CLASS="dddefault">
            <xsl:call-template name="creditformat">
               <xsl:with-param name="credit_value"><xsl:value-of select="SMBGOGN_MAX_CREDITS_I_NONTRAD"/></xsl:with-param>
            </xsl:call-template>
      </TD>
      <TD CLASS="dddefault">
         <xsl:call-template name="creditformat">
            <xsl:with-param name="credit_value"><xsl:value-of select="SMBGOGN_ACT_CREDITS_I_NONTRAD"/></xsl:with-param>
      </xsl:call-template>
      </TD>
      <TD CLASS="dddefault">
         <xsl:value-of select="SMBGOGN_MAX_COURSES_I_NONTRAD"/></TD>
      <TD CLASS="dddefault">
         <xsl:value-of select="SMBGOGN_ACT_COURSES_I_NONTRAD"/></TD>
   </TR>
   </xsl:if>
   <xsl:if test="(SMBGOGN_MAX_CREDITS_TRANSFER) or (SMBGOGN_MAX_COURSES_TRANSFER)">
      <TR>
      <TH COLSPAN="1" CLASS="ddlabel" scope="row" >Max Transfer :</TH>
      <TD CLASS="dddefault" ALIGN="CENTER"></TD>
      <TD CLASS="dddefault">
         <xsl:call-template name="creditformat">
            <xsl:with-param name="credit_value"><xsl:value-of select="SMBGOGN_MAX_CREDITS_TRANSFER"/></xsl:with-param>
         </xsl:call-template>
      </TD>
      <TD CLASS="dddefault">
         <xsl:call-template name="creditformat">
            <xsl:with-param name="credit_value"><xsl:value-of select="SMBGOGN_ACT_CREDITS_TRANSFER"/></xsl:with-param>
         </xsl:call-template>
      </TD>
      <TD CLASS="dddefault">
         <xsl:value-of select="SMBGOGN_MAX_COURSES_TRANSFER"/>
      </TD>
      <TD CLASS="dddefault">
         <xsl:value-of select="SMBGOGN_ACT_COURSES_TRANSFER"/>
      </TD>
   </TR>
   </xsl:if>
</TABLE>
</xsl:template>
<xsl:template match="SMRGCMT_ROWSET">
<xsl:if test="SMRGCMT_SET/SMRGCMT_TEXT">
<xsl:if test="$cprt_gcmt_text_ind='2'">
   <BR></BR>
</xsl:if>
<xsl:if test="$cprt_gcmt_text_ind!='2'">
<BR></BR>
<TABLE CLASS="datadisplaytable" WIDTH="65%" SUMMARY="summary">
<CAPTION class="captiontext">Group Description</CAPTION>
<TR>
<TD CLASS="dddefault" COLSPAN="7">
<xsl:for-each select="SMRGCMT_SET">
   <xsl:value-of select="SMRGCMT_TEXT" disable-output-escaping="yes"/>&#xa0;
</xsl:for-each>
</TD>
</TR>
</TABLE>
</xsl:if>
</xsl:if>
</xsl:template>
<xsl:template match="SMRSGCM_ROWSET">
<xsl:if test="SMRSGCM_SET/SMRSGCM_TEXT">
<xsl:if test="$cprt_gcmt_text_ind='2'">
   <BR></BR>
</xsl:if>
<xsl:if test="$cprt_gcmt_text_ind!='2'">
<BR></BR>
<TABLE CLASS="datadisplaytable" WIDTH="65%" SUMMARY="summary">
<CAPTION class="captiontext">Adjusted Group Description</CAPTION>
<TR>
<TD CLASS="dddefault" COLSPAN="7">
<xsl:for-each select="SMRSGCM_SET">
   <xsl:value-of select="SMRSGCM_TEXT" disable-output-escaping="yes"/>&#xa0;
</xsl:for-each>
</TD>
</TR>
</TABLE>
</xsl:if>
</xsl:if>
</xsl:template>
<xsl:template match="SMRGOSA">
<xsl:if test="($cprt_grsa_ind != '2' or $cprt_grsc_text_ind != '2')">
<BR></BR>
<TABLE CLASS="datadisplaytable" WIDTH="65%" SUMMARY="summary">
<xsl:if test="($cprt_grsa_ind != '2')">
<CAPTION class="captiontext">Group Restricted Subjects and Attributes</CAPTION>
<TR>
<TH CLASS="ddheader" scope="col" >Subject</TH>
<TH CLASS="ddheader" scope="col" >Attribute</TH>
<TH CLASS="ddheader" scope="col" >Low</TH>
<TH CLASS="ddheader" scope="col" >High</TH>
<TH CLASS="ddheader" scope="col" >Campus</TH>
<TH CLASS="ddheader" scope="col" >College</TH>
<TH CLASS="ddheader" scope="col" >Department</TH>
<TH CLASS="ddheader" scope="col" >Maximum Credits</TH>
<TH CLASS="ddheader" scope="col" >And/Or</TH>
<TH CLASS="ddheader" scope="col" >Actual Credits</TH>
<TH CLASS="ddheader" scope="col" >Actual Courses</TH>
</TR>
</xsl:if>
<xsl:for-each select="SMRGOSA_DETAIL">
    <xsl:if test="$cprt_grsa_ind !='2'" >
    <xsl:apply-templates select="SMRGOSA_ROWSET"/>
    </xsl:if>
    <xsl:if test="$cprt_grsc_text_ind != '2'">
    <xsl:apply-templates select="SMRSGRC_ROWSET"/>
    <xsl:apply-templates select="SMRGRSC_ROWSET"/>
    </xsl:if>
</xsl:for-each>
</TABLE>
</xsl:if>
</xsl:template>
<xsl:template match="SMRGOSA_ROWSET">
<BR></BR>
<xsl:for-each select="SMRGOSA_SET">
<TR>
   <xsl:choose>
      <xsl:when test="$codedisplay = 'Y'">
         <TD CLASS="dddefault"><xsl:value-of select="SMRGOSA_SUBJ_CODE"/></TD>
         <TD CLASS="dddefault"><xsl:value-of select="SMRGOSA_ATTR_CODE"/></TD>
      </xsl:when>
      <xsl:otherwise>
         <TD CLASS="dddefault"><xsl:value-of select="SMRGOSA_SUBJ_DESC"/></TD>
         <TD CLASS="dddefault"><xsl:value-of select="SMRGOSA_ATTR_DESC"/></TD>
      </xsl:otherwise>
   </xsl:choose>
   <TD CLASS="dddefault"><xsl:value-of select="SMRGOSA_CRSE_NUMB_LOW"/></TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRGOSA_CRSE_NUMB_HIGH"/></TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRGOSA_CAMP_DESC"/></TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRGOSA_COLL_DESC"/></TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRGOSA_DEPT_DESC"/></TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMRGOSA_MAX_CREDITS"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="connector_format">
         <xsl:with-param name="connect_ind"><xsl:value-of select="SMRGOSA_CONNECTOR_MAX"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMRGOSA_ACT_CREDITS"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRGOSA_ACT_COURSES"/></TD>
</TR>
</xsl:for-each>
</xsl:template>
<xsl:template match="SMRGRSC_ROWSET">
<TR></TR>
<TR><TD></TD>
<TD class="captiontext" COLSPAN="10">Group Restricted Subject/Attribute Text</TD>
<TD></TD>
</TR>
<TR><TD></TD>
<TD CLASS="dddefault" COLSPAN="10">
<xsl:for-each select="SMRGRSC_SET">
   <xsl:value-of select="SMRGRSC_TEXT" disable-output-escaping="yes"/>&#xa0;
</xsl:for-each>
</TD>
</TR>
<TR></TR>
</xsl:template>
<xsl:template match="SMRSGRC_ROWSET">
<TR></TR>
<TR><TD></TD>
<TD class="captiontext" COLSPAN="10">Adjusted Group Restricted Subject/Attribute Text</TD>
<TD></TD>
</TR>
<TR><TD></TD>
<TD CLASS="dddefault" COLSPAN="10">
<xsl:for-each select="SMRSGRC_SET">
   <xsl:value-of select="SMRSGRC_TEXT" disable-output-escaping="yes"/>&#xa0;
</xsl:for-each>
</TD>
</TR>
<TR></TR>
</xsl:template>
<xsl:template match="SMRGOLV_ROWSET">
<xsl:if test="($cprt_glvl_ind!='2')">
<BR></BR>
<TABLE CLASS="datadisplaytable" WIDTH="65%" SUMMARY="summary">
<CAPTION class="captiontext">Group Additional Levels</CAPTION>
<TR>
<TH CLASS="ddheader" scope="col" >Level</TH>
<TH CLASS="ddheader" scope="col" >Include/Exclude</TH>
<TH CLASS="ddheader" scope="col" >Grade</TH>
<TH CLASS="ddheader" scope="col" >Maximum Credits</TH>
<TH CLASS="ddheader" scope="col" >And/Or</TH>
<TH CLASS="ddheader" scope="col" >Actual Credits</TH>
<TH CLASS="ddheader" scope="col" >Actual Courses</TH>
</TR>
<xsl:for-each select="SMRGOLV_SET">
<TR>
   <TD CLASS="dddefault"><xsl:value-of select="SMRGOLV_LEVL_DESC"/></TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="incl_excl_format">
         <xsl:with-param name="incl_excl"><xsl:value-of select="SMRGOLV_INCL_EXCL_IND"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRGOLV_GRDE_CODE_MIN"/></TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMRGOLV_MAX_CREDITS"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="connector_format">
         <xsl:with-param name="connect_ind"><xsl:value-of select="SMRGOLV_CONNECTOR_MAX"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMRGOLV_ACT_CREDITS"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRGOLV_ACT_COURSES"/></TD>
</TR>
</xsl:for-each>
</TABLE>
</xsl:if>
</xsl:template>
<xsl:template match="SMRGOGD">
<xsl:if test="($cprt_grgd_ind != '2' or $cprt_grgc_text_ind != '2')">
<BR></BR>
<TABLE CLASS="datadisplaytable" WIDTH="65%" SUMMARY="summary">
<xsl:if test="($cprt_grgd_ind != '2')">
<CAPTION class="captiontext">Group Restricted Grade</CAPTION>
<TR>
<TH CLASS="ddheader" scope="col">Grade</TH>
<TH CLASS="ddheader" scope="col">Maximum Credits</TH>
<TH CLASS="ddheader" scope="col">And/Or</TH>
<TH CLASS="ddheader" scope="col">Maximum Courses</TH>
<TH CLASS="ddheader" scope="col">Actual Credits</TH>
<TH CLASS="ddheader" scope="col">Actual Courses</TH>
</TR>
</xsl:if>
<xsl:for-each select="SMRGOGD_DETAIL">
    <xsl:if test="$cprt_grgd_ind !='2'" >
    <xsl:apply-templates select="SMRGOGD_ROWSET"/>
    </xsl:if>
    <xsl:if test="$cprt_grgc_text_ind != '2'">
    <xsl:apply-templates select="SMRSGGC_ROWSET"/>
    <xsl:apply-templates select="SMRGRGC_ROWSET"/>
    </xsl:if>
</xsl:for-each>
</TABLE>
</xsl:if>
</xsl:template>
<xsl:template match="SMRGOGD_ROWSET">
<xsl:for-each select="SMRGOGD_SET">
<TR>
   <TD CLASS="dddefault"><xsl:value-of select="SMRGOGD_GRDE_CODE"/></TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMRGOGD_MAX_CREDITS"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="connector_format">
         <xsl:with-param name="connect_ind"><xsl:value-of select="SMRGOGD_CONNECTOR_MAX"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRGOGD_MAX_COURSES"/></TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMRGOGD_ACT_CREDITS"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRGOGD_ACT_COURSES"/></TD>
</TR>
</xsl:for-each>
</xsl:template>
<xsl:template match="SMRSGGC_ROWSET">
<TR></TR>
<TR><TD></TD>
<TD class="captiontext" COLSPAN="5">Adjusted Group Restricted Grade Text</TD>
<TD></TD>
</TR>
<TR><TD></TD>
<TD CLASS="dddefault" COLSPAN="5">
<xsl:for-each select="SMRSGGC_SET">
   <xsl:value-of select="SMRSGGC_TEXT" disable-output-escaping="yes"/>&#xa0;
</xsl:for-each>
</TD>
</TR>
<TR></TR>
</xsl:template>
<xsl:template match="SMRGRGC_ROWSET">
<TR></TR>
<TR><TD></TD>
<TD class="captiontext" COLSPAN="5">Group Restricted Grade Text</TD>
<TD></TD>
</TR>
<TR><TD></TD>
<TD CLASS="dddefault" COLSPAN="5">
<xsl:for-each select="SMRGRGC_SET">
   <xsl:value-of select="SMRGRGC_TEXT" disable-output-escaping="yes"/>&#xa0;
</xsl:for-each>
</TD>
</TR>
<TR></TR>
</xsl:template>
<xsl:template match="SMRPCRS_ROWSET">
<xsl:if test="$cprt_planned_crse_prt_ind='Y'">
<BR></BR>
<TABLE CLASS="datadisplaytable" WIDTH="65%" SUMMARY="summary">
<CAPTION class="captiontext">Planned Course Work</CAPTION>
<TR>
<TH CLASS="ddheader" scope="col" >Term</TH>
<TH CLASS="ddheader" scope="col" >Subject</TH>
<TH CLASS="ddheader" scope="col" >Course</TH>
<TH CLASS="ddheader" scope="col" >Title</TH>
<TH CLASS="ddheader" scope="col" >Credits</TH>
</TR>
<xsl:for-each select="SMRPCRS_SET">
<TR>
   <xsl:choose>
      <xsl:when test="$codedisplay = 'Y'">
         <TD CLASS="dddefault"><xsl:value-of select="SMRPCRS_TERM_CODE"/></TD>
         <TD CLASS="dddefault"><xsl:value-of select="SMRPCRS_SUBJ_CODE"/></TD>
      </xsl:when>
      <xsl:otherwise>
         <TD CLASS="dddefault"><xsl:value-of select="SMRPCRS_TERM_DESC"/></TD>
         <TD CLASS="dddefault"><xsl:value-of select="SMRPCRS_SUBJ_DESC"/></TD>
      </xsl:otherwise>
   </xsl:choose>
   <TD CLASS="dddefault"><xsl:value-of select="SMRPCRS_CRSE_NUMB"/></TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRPCRS_TITLE"/></TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMRPCRS_CREDIT_HR"/></xsl:with-param>
      </xsl:call-template>
   </TD>
</TR>
</xsl:for-each>
</TABLE>
</xsl:if>
</xsl:template>
<xsl:template match="SMRDOUS_ROWSET">
<xsl:if test="$cprt_in_prog_term_ind='Y'">    
<BR></BR>
<TABLE CLASS="datadisplaytable" WIDTH="65%" SUMMARY="summary">
<CAPTION class="captiontext">In Progress Courses</CAPTION>
<TR>
<TH CLASS="ddheader" scope="col" >Area</TH>
<TH CLASS="ddheader" scope="col" >Subject</TH>
<TH CLASS="ddheader" scope="col" >Course</TH>
<TH CLASS="ddheader" scope="col" >Title</TH>
<TH CLASS="ddheader" scope="col" >Credits</TH>
</TR>
<xsl:for-each select="SMRDOUS_SET">
<TR>
   <TD CLASS="dddefault"><xsl:value-of select="SMRDOUS_AREA_DESC"/></TD>
   <xsl:choose>
      <xsl:when test="$codedisplay = 'Y'">
         <TD CLASS="dddefault"><xsl:value-of select="SMRDOUS_SUBJ_CODE"/></TD>
      </xsl:when>
      <xsl:otherwise>
         <TD CLASS="dddefault"><xsl:value-of select="SMRDOUS_SUBJ_DESC"/></TD>
      </xsl:otherwise>
   </xsl:choose>
   <TD CLASS="dddefault"><xsl:value-of select="SMRDOUS_CRSE_NUMB"/></TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRDOUS_TITLE"/></TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMRDOUS_CREDIT_HOURS"/></xsl:with-param>
      </xsl:call-template>
   </TD>
</TR>
</xsl:for-each>
</TABLE>
 </xsl:if>
</xsl:template>
<xsl:template match="SMRDOCN_ROWSET">
<xsl:if test="$cprt_unused_crse_prt_ind='Y'">
<BR></BR>
<TABLE CLASS="datadisplaytable" WIDTH="65%" SUMMARY="summary">
<CAPTION class="captiontext">Courses Not Used</CAPTION>
<TR>
<TH CLASS="ddheader" scope="col" >Subject</TH>
<TH CLASS="ddheader" scope="col" >Course</TH>
<TH CLASS="ddheader" scope="col" >Title</TH>
<TH CLASS="ddheader" scope="col" >Term</TH>
<TH CLASS="ddheader" scope="col" >Credits</TH>
<TH CLASS="ddheader" scope="col" >Grade</TH>
</TR>
<xsl:for-each select="SMRDOCN_SET">
<TR>
   <xsl:choose>
      <xsl:when test="$codedisplay = 'Y'">
         <TD CLASS="dddefault"><xsl:value-of select="SMRDOCN_SUBJ_CODE"/></TD>
      </xsl:when>
      <xsl:otherwise>
         <TD CLASS="dddefault"><xsl:value-of select="SMRDOCN_SUBJ_DESC"/></TD>
      </xsl:otherwise>
   </xsl:choose>
   <TD CLASS="dddefault"><xsl:value-of select="SMRDOCN_CRSE_NUMB"/></TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRDOCN_CRSE_TITLE"/></TD>
   <xsl:choose>
      <xsl:when test="$codedisplay = 'Y'">
         <TD CLASS="dddefault"><xsl:value-of select="SMRDOCN_TERM_CODE"/></TD>
      </xsl:when>
      <xsl:otherwise>
         <TD CLASS="dddefault"><xsl:value-of select="SMRDOCN_TERM_DESC"/></TD>
      </xsl:otherwise>
   </xsl:choose>
   <TD CLASS="dddefault">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMRDOCN_CREDIT_HOURS"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <xsl:if test="SMRDOCN_CRSE_SOURCE !='R'">
   <TD CLASS="dddefault"><xsl:value-of select="SMRDOCN_GRDE_CODE"/></TD>
   </xsl:if>
   <xsl:if test="SMRDOCN_CRSE_SOURCE = 'R'">
   <TD CLASS="dddefault"></TD>
   </xsl:if>
</TR>
</xsl:for-each>
</TABLE>
</xsl:if>
</xsl:template>
<xsl:template match="SMRDOAN_ROWSET">
<xsl:if test="$cprt_unused_crse_prt_ind='Y'">
<BR></BR>
<TABLE CLASS="datadisplaytable" WIDTH="65%" SUMMARY="summary">
<CAPTION class="captiontext">Attributes Not Used</CAPTION>
<TR>
<TH CLASS="ddheader" scope="col" >Attribute</TH>
<TH CLASS="ddheader" scope="col" >Subject</TH>
<TH CLASS="ddheader" scope="col" >Course</TH>
<TH CLASS="ddheader" scope="col" >Title</TH>
<TH CLASS="ddheader" scope="col" >Term</TH>
<TH CLASS="ddheader" scope="col" >Credits</TH>
<TH CLASS="ddheader" scope="col" >Grade</TH>
</TR>
<xsl:for-each select="SMRDOAN_SET">
<TR>
   <xsl:choose>
      <xsl:when test="$codedisplay = 'Y'">
         <TD CLASS="dddefault"><xsl:value-of select="SMRDOAN_ATTR_CODE"/></TD>
         <TD CLASS="dddefault"><xsl:value-of select="SMRDOAN_SUBJ_CODE"/></TD>
      </xsl:when>
      <xsl:otherwise>
         <TD CLASS="dddefault"><xsl:value-of select="SMRDOAN_ATTR_DESC"/></TD>
         <TD CLASS="dddefault"><xsl:value-of select="SMRDOAN_SUBJ_DESC"/></TD>
      </xsl:otherwise>
   </xsl:choose>
   <TD CLASS="dddefault"><xsl:value-of select="SMRDOAN_CRSE_NUMB"/></TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRDOAN_CRSE_TITLE"/></TD>
   <xsl:choose>
      <xsl:when test="$codedisplay = 'Y'">
         <TD CLASS="dddefault"><xsl:value-of select="SMRDOAN_TERM_CODE"/></TD>
      </xsl:when>
      <xsl:otherwise>
         <TD CLASS="dddefault"><xsl:value-of select="SMRDOAN_TERM_DESC"/></TD>
      </xsl:otherwise>
   </xsl:choose>
   <TD CLASS="dddefault">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMRDOAN_CREDIT_HOURS"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <xsl:if test="SMRDOAN_CRSE_SOURCE !='R'">
   <TD CLASS="dddefault"><xsl:value-of select="SMRDOAN_GRDE_CODE"/></TD>
   </xsl:if>
   <xsl:if test="SMRDOAN_CRSE_SOURCE = 'R'">
   <TD CLASS="dddefault"></TD>
   </xsl:if>
</TR>
</xsl:for-each>
</TABLE>
</xsl:if>
</xsl:template>
<xsl:template match="SMRSSUB_ROWSET">
<BR></BR>
<TABLE CLASS="datadisplaytable" WIDTH="65%" SUMMARY="summary">
<CAPTION class="captiontext">Substitutions</CAPTION>
<TR>
<TH CLASS="ddheader" scope="col" >Area</TH>
<TH CLASS="ddheader" scope="col" >Required Subject</TH>
<TH CLASS="ddheader" scope="col" >Required Course</TH>
<TH CLASS="ddheader" scope="col" >Substituted Subject</TH>
<TH CLASS="ddheader" scope="col" >Substituted Course</TH>
<TH CLASS="ddheader" scope="col" >Credits</TH>
<TH CLASS="ddheader" scope="col" >Action</TH>
</TR>
<xsl:for-each select="SMRSSUB_SET">
<TR>
   <TD CLASS="dddefault"><xsl:value-of select="SMRSSUB_AREA_DESC"/></TD>
   <xsl:choose>
      <xsl:when test="$codedisplay = 'Y'">
         <TD CLASS="dddefault"><xsl:value-of select="SMRSSUB_SUBJ_CODE_REQ"/></TD>
      </xsl:when>
      <xsl:otherwise>
         <TD CLASS="dddefault"><xsl:value-of select="SMRSSUB_SUBJ_DESC_REQ"/></TD>
      </xsl:otherwise>
   </xsl:choose>
   <TD CLASS="dddefault"><xsl:value-of select="SMRSSUB_CRSE_NUMB_REQ"/></TD>
   <xsl:choose>
      <xsl:when test="$codedisplay = 'Y'">
         <TD CLASS="dddefault"><xsl:value-of select="SMRSSUB_SUBJ_CODE_SUB"/></TD>
      </xsl:when>
      <xsl:otherwise>
         <TD CLASS="dddefault"><xsl:value-of select="SMRSSUB_SUBJ_DESC_SUB"/></TD>
      </xsl:otherwise>
   </xsl:choose>
   <TD CLASS="dddefault"><xsl:value-of select="SMRSSUB_CRSE_NUMB_SUB"/></TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMRSSUB_CREDITS"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRSSUB_ACTN_DESC"/></TD>
</TR>
</xsl:for-each>
</TABLE>
</xsl:template>
<xsl:template match="SMRSTRG_ROWSET">
<BR></BR>
<TABLE CLASS="datadisplaytable" WIDTH="65%" SUMMARY="summary">
<CAPTION class="captiontext">Targets</CAPTION>
<TR>
<TH CLASS="ddheader" scope="col" >Area</TH>
<TH CLASS="ddheader" scope="col" >Subject</TH>
<TH CLASS="ddheader" scope="col" >Course</TH>
<TH CLASS="ddheader" scope="col" >Attribute</TH>
</TR>
<xsl:for-each select="SMRSTRG_SET">
<TR>
   <TD CLASS="dddefault"><xsl:value-of select="SMRSTRG_AREA_DESC"/></TD>
   <xsl:choose>
      <xsl:when test="$codedisplay = 'Y'">
         <TD CLASS="dddefault"><xsl:value-of select="SMRSTRG_SUBJ_CODE"/></TD>
      </xsl:when>
      <xsl:otherwise>
         <TD CLASS="dddefault"><xsl:value-of select="SMRSTRG_SUBJ_DESC"/></TD>
      </xsl:otherwise>
   </xsl:choose>
   <TD CLASS="dddefault"><xsl:value-of select="SMRSTRG_CRSE_NUMB"/></TD>
   <xsl:choose>
      <xsl:when test="$codedisplay = 'Y'">
         <TD CLASS="dddefault"><xsl:value-of select="SMRSTRG_ATTR_CODE"/></TD>
      </xsl:when>
      <xsl:otherwise>
         <TD CLASS="dddefault"><xsl:value-of select="SMRSTRG_ATTR_DESC"/></TD>
      </xsl:otherwise>
   </xsl:choose>
</TR>
</xsl:for-each>
</TABLE>
</xsl:template>
<xsl:template match="SMRSWAV_ROWSET">
<BR></BR>
<TABLE CLASS="datadisplaytable" WIDTH="65%" SUMMARY="summary">
<CAPTION class="captiontext">Waivers</CAPTION>
<TR>
<TH CLASS="ddheader" scope="col" >Area</TH>
<TH CLASS="ddheader" scope="col" >Subject</TH>
<TH CLASS="ddheader" scope="col" >Course</TH>
<TH CLASS="ddheader" scope="col" >Attribute</TH>
<TH CLASS="ddheader" scope="col" >Credits</TH>
<TH CLASS="ddheader" scope="col" >Action</TH>
</TR>
<xsl:for-each select="SMRSWAV_SET">
<TR>
   <TD CLASS="dddefault"><xsl:value-of select="SMRSWAV_AREA_DESC"/></TD>
   <xsl:choose>
      <xsl:when test="$codedisplay = 'Y'">
         <TD CLASS="dddefault"><xsl:value-of select="SMRSWAV_SUBJ_CODE"/></TD>
      </xsl:when>
      <xsl:otherwise>
         <TD CLASS="dddefault"><xsl:value-of select="SMRSWAV_SUBJ_DESC"/></TD>
      </xsl:otherwise>
   </xsl:choose>
   <TD CLASS="dddefault"><xsl:value-of select="SMRSWAV_CRSE_NUMB"/></TD>
   <xsl:choose>
      <xsl:when test="$codedisplay = 'Y'">
         <TD CLASS="dddefault"><xsl:value-of select="SMRSWAV_ATTR_CODE"/></TD>
      </xsl:when>
      <xsl:otherwise>
         <TD CLASS="dddefault"><xsl:value-of select="SMRSWAV_ATTR_DESC"/></TD>
      </xsl:otherwise>
   </xsl:choose>
   <TD CLASS="dddefault">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMRSWAV_CREDITS"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRSWAV_ACTN_DESC"/></TD>
</TR>
</xsl:for-each>
</TABLE>
</xsl:template>
<xsl:template match="SMRDORJ_ROWSET">
<xsl:if test="$cprt_rej_crse_prt_ind='Y'">
<BR></BR>
<TABLE CLASS="datadisplaytable" WIDTH="65%" SUMMARY="summary">
<CAPTION class="captiontext">Rejected Courses</CAPTION>
<TR>
<TH CLASS="ddheader" scope="col" >Subject</TH>
<TH CLASS="ddheader" scope="col" >Course</TH>
<TH CLASS="ddheader" scope="col" >Area</TH>
<TH CLASS="ddheader" scope="col" >Reason</TH>
<TH CLASS="ddheader" scope="col" >Attribute</TH>
</TR>
<xsl:for-each select="SMRDORJ_SET">
<TR>
   <xsl:choose>
      <xsl:when test="$codedisplay = 'Y'">
         <TD CLASS="dddefault"><xsl:value-of select="SMRDORJ_SUBJ_CODE"/></TD>
      </xsl:when>
      <xsl:otherwise>
         <TD CLASS="dddefault"><xsl:value-of select="SMRDORJ_SUBJ_DESC"/></TD>
      </xsl:otherwise>
   </xsl:choose>
   <TD CLASS="dddefault"><xsl:value-of select="SMRDORJ_CRSE_NUMB"/></TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRDORJ_AREA_DESC"/></TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRDORJ_REJECTION_REASON"/></TD>
   <xsl:choose>
      <xsl:when test="$codedisplay = 'Y'">
         <TD CLASS="dddefault"><xsl:value-of select="SMRDORJ_ATTR_CODE"/></TD>
      </xsl:when>
      <xsl:otherwise>
         <TD CLASS="dddefault"><xsl:value-of select="SMRDORJ_ATTR_DESC"/></TD>
      </xsl:otherwise>
   </xsl:choose>
</TR>
</xsl:for-each>
</TABLE>
</xsl:if>
</xsl:template>

<xsl:template match="DETAILS">
<BR></BR>
<TABLE BORDER="1" CLASS="datadisplaytable" WIDTH="90%" SUMMARY="summary">
<CAPTION class="captiontext">Detail Requirements </CAPTION>
<TR>
<xsl:comment>This is the report header JDH</xsl:comment>
<TH CLASS="ddheader" scope="col" >Met</TH>
<!-- TH CLASS="ddheader" scope="col" >Condition</TH>   -->
<TH CLASS="ddheader" scope="col" >Rule</TH>
<TH CLASS="ddheader" scope="col" >Subject</TH>
<TH CLASS="ddheader" scope="col" >Attribute</TH>
<TH CLASS="ddheader" scope="col" >Low</TH>

<TH CLASS="ddheader" scope="col" >High</TH>
<!--
<TH CLASS="ddheader" scope="col" >Required Credits</TH>
<TH CLASS="ddheader" scope="col" >Required Courses</TH>
-->
<TH CLASS="ddheader" scope="col" >Term</TH>
<TH CLASS="ddheader" scope="col" >Subject</TH>
<TH CLASS="ddheader" scope="col" >Course</TH>
<TH CLASS="ddheader" scope="col" >Title</TH>
<TH CLASS="ddheader" scope="col" >Attribute</TH>
<TH CLASS="ddheader" scope="col" >Credits</TH>
<TH CLASS="ddheader" scope="col" >Grade</TH>
<TH CLASS="ddheader" scope="col" >Source</TH>
</TR>
<xsl:apply-templates select="DETAIL_REQUIREMENT"/>
<!-- 1-8VKYQS -->
<xsl:if test="../SMBAOGN_ROWSET/SMBAOGN_SET/SMBAOGN_GC_IND ='C'">
<xsl:call-template name="AREA_GPA_FOOTER">
</xsl:call-template>
</xsl:if>
</TABLE>
</xsl:template>

<xsl:template match="DETAIL_REQUIREMENT">
  <!--   
       Detail Requirement for rules, and rules within rules, does not go into
       full detail.  Only the rule name, and the courses used within the rule,
       as well as the rule text, additional levels, and exclusions. Anything additional
       will require a client side modification.
  -->
  <xsl:call-template name="FIRST_ROW"/>
  <xsl:apply-templates select="DETAIL_REQUIREMENT_USED/SMRDOUS_ROWSET/SMRDOUS_SET"/>
  <xsl:apply-templates select="DTLTXT_ROWSET"/>
  <xsl:apply-templates select="SMRARLT_ROWSET"/>
  <xsl:apply-templates select="SMRSARD_ROWSET"/>
  <xsl:apply-templates select="SMRGRLT_ROWSET"/>
  <xsl:apply-templates select="SMRSGRD_ROWSET"/>
  <xsl:apply-templates select="SMRDOLV_ROWSET"/>
  <xsl:apply-templates select="SMRDOEX_ROWSET"/>
</xsl:template>

<xsl:template name="FIRST_ROW">
<TR>
<!-- Defect 1-6IGV7B -->
<!--  met indicator  col 1  -->
   <xsl:choose>
      <xsl:when test="(RULE_REQUIREMENT/SMBDRRQ_ROWSET/SMBDRRQ_SET/SMBDRRQ_MET_IND)">
         <xsl:choose>
            <xsl:when test="RULE_REQUIREMENT/SMBDRRQ_ROWSET/SMBDRRQ_SET/SMBDRRQ_MET_IND = 'Y'">
               <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
               <xsl:call-template name="yes_no_ind_format">
                  <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
               </xsl:call-template>
               </font></TD>
            </xsl:when>
            <xsl:otherwise>
               <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
               <xsl:call-template name="yes_no_ind_format">
                  <xsl:with-param name="yes_no_ind">N</xsl:with-param>
               </xsl:call-template>
               </font></TD>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
      <xsl:choose>
         <xsl:when test="SMRDORQ_ROWSET/SMRDORQ_SET/SMRDORQ_MET_IND = 'Y'">
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$met-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">Y</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:when>
         <xsl:when test="SMRDORQ_ROWSET/SMRDORQ_SET/SMRDORQ_MET_IND = 'N'">
            <TD CLASS="dddefault" ALIGN="CENTER"><font color="{$nmet-color}">
            <xsl:call-template name="yes_no_ind_format">
               <xsl:with-param name="yes_no_ind">N</xsl:with-param>
            </xsl:call-template>
            </font></TD>
         </xsl:when>
         <xsl:otherwise>
            <TD CLASS="dddefault" ALIGN="CENTER">
            </TD>
         </xsl:otherwise>
      </xsl:choose>
      </xsl:otherwise>
   </xsl:choose>
<!--  CONDITION   THERE is a rule followed by a condition-->
   <xsl:comment> The following line shows the condition JDH</xsl:comment>
	<xsl:choose>
    <xsl:when test="SMRDORQ_ROWSET/SMRDORQ_SET/CONDITION = ')OR('">
		<TD CLASS="dddefault" scope="col" >OR</TD>
    </xsl:when> 
    </xsl:choose>
<!-- TD CLASS="dddefault" scope="col" ><xsl:value-of select="SMRDORQ_ROWSET/SMRDORQ_SET/CONDITION"/></TD -->

<xsl:comment>This shows the text for the cond  JDH</xsl:comment>
<TD CLASS="dddefault" scope="col" ><xsl:value-of select="RULE_REQUIREMENT/SMBDRRQ_ROWSET/SMBDRRQ_SET/SMBDRRQ_DESC"/></TD>
<xsl:choose>
   <xsl:when test="$codedisplay = 'Y'">
      <xsl:choose>
      <xsl:when test="SMRDORQ_ROWSET/SMRDORQ_SET/SMRDORQ_MET_IND = 'N'">
         <xsl:choose>
         <xsl:when test="(SMRDORQ_ROWSET/SMRDORQ_SET/SMRDORQ_CRSE_NUMB_HIGH)">
         <TD CLASS="dddefault" scope="col" >
         <A><xsl:attribute name="href"><xsl:value-of select="concat('bwckctlg.p_display_courses?term_in=',
            $term_code_ctlg_1,
            '&amp;one_subj=',SMRDORQ_ROWSET/SMRDORQ_SET/SMRDORQ_SUBJ_CODE,
            '&amp;sel_subj=',NULL,
            '&amp;sel_crse_strt=',SMRDORQ_ROWSET/SMRDORQ_SET/SMRDORQ_CRSE_NUMB_LOW,
            '&amp;sel_crse_end=',SMRDORQ_ROWSET/SMRDORQ_SET/SMRDORQ_CRSE_NUMB_HIGH,
            '&amp;sel_title=',NULL,
            '&amp;sel_levl=NULL&amp;sel_schd=NULL&amp;sel_coll=NULL&amp;sel_divs=NULL&amp;sel_dept=NULL&amp;sel_attr=NULL')"/>
            </xsl:attribute>
         <xsl:value-of select="SMRDORQ_ROWSET/SMRDORQ_SET/SMRDORQ_SUBJ_CODE"/></A>
         </TD>
         </xsl:when>
         <xsl:otherwise>
         <TD CLASS="dddefault" scope="col" >
         <A><xsl:attribute name="href"><xsl:value-of select="concat('bwckctlg.p_display_courses?term_in=',
            $term_code_ctlg_1,
            '&amp;one_subj=',SMRDORQ_ROWSET/SMRDORQ_SET/SMRDORQ_SUBJ_CODE,
            '&amp;sel_subj=',NULL,
            '&amp;sel_crse_strt=',SMRDORQ_ROWSET/SMRDORQ_SET/SMRDORQ_CRSE_NUMB_LOW,
            '&amp;sel_crse_end=',SMRDORQ_ROWSET/SMRDORQ_SET/SMRDORQ_CRSE_NUMB_LOW,
            '&amp;sel_title=',NULL,
            '&amp;sel_levl=NULL&amp;sel_schd=NULL&amp;sel_coll=NULL&amp;sel_divs=NULL&amp;sel_dept=NULL&amp;sel_attr=NULL')"/>
            </xsl:attribute>
         <xsl:value-of select="SMRDORQ_ROWSET/SMRDORQ_SET/SMRDORQ_SUBJ_CODE"/></A>
         </TD>
         </xsl:otherwise>
         </xsl:choose>
      </xsl:when>

      <xsl:otherwise>
         <TD CLASS="dddefault" scope="col" ><xsl:value-of select="SMRDORQ_ROWSET/SMRDORQ_SET/SMRDORQ_SUBJ_CODE"/></TD>
      </xsl:otherwise>
      </xsl:choose>
      <TD CLASS="dddefault" scope="col" ><xsl:value-of select="SMRDORQ_ROWSET/SMRDORQ_SET/SMRDORQ_ATTR_CODE"/></TD>
   </xsl:when>

   <xsl:otherwise>
      <xsl:choose>
      <xsl:when test="SMRDORQ_ROWSET/SMRDORQ_SET/SMRDORQ_MET_IND = 'N'">
         <xsl:choose>
         <xsl:when test="(SMRDORQ_ROWSET/SMRDORQ_SET/SMRDORQ_CRSE_NUMB_HIGH)">
         <TD CLASS="dddefault" scope="col" >
         <A><xsl:attribute name="href"><xsl:value-of select="concat('bwckctlg.p_display_courses?term_in=',
            $term_code_ctlg_1,
            '&amp;one_subj=',SMRDORQ_ROWSET/SMRDORQ_SET/SMRDORQ_SUBJ_CODE,
            '&amp;sel_subj=',NULL,
            '&amp;sel_crse_strt=',SMRDORQ_ROWSET/SMRDORQ_SET/SMRDORQ_CRSE_NUMB_LOW,
            '&amp;sel_crse_end=',SMRDORQ_ROWSET/SMRDORQ_SET/SMRDORQ_CRSE_NUMB_HIGH,
            '&amp;sel_title=',NULL,
            '&amp;sel_levl=NULL&amp;sel_schd=NULL&amp;sel_coll=NULL&amp;sel_divs=NULL&amp;sel_dept=NULL&amp;sel_attr=NULL')"/>
            </xsl:attribute>
         <xsl:value-of select="SMRDORQ_ROWSET/SMRDORQ_SET/SMRDORQ_SUBJ_DESC"/></A>
         </TD>
         </xsl:when>
         <xsl:otherwise>
         <TD CLASS="dddefault" scope="col" >
         <A><xsl:attribute name="href"><xsl:value-of select="concat('bwckctlg.p_display_courses?term_in=',
            $term_code_ctlg_1,
            '&amp;one_subj=',SMRDORQ_ROWSET/SMRDORQ_SET/SMRDORQ_SUBJ_CODE,
            '&amp;sel_subj=',NULL,
            '&amp;sel_crse_strt=',SMRDORQ_ROWSET/SMRDORQ_SET/SMRDORQ_CRSE_NUMB_LOW,
            '&amp;sel_crse_end=',SMRDORQ_ROWSET/SMRDORQ_SET/SMRDORQ_CRSE_NUMB_LOW,
            '&amp;sel_title=',NULL,
            '&amp;sel_levl=NULL&amp;sel_schd=NULL&amp;sel_coll=NULL&amp;sel_divs=NULL&amp;sel_dept=NULL&amp;sel_attr=NULL')"/>
            </xsl:attribute>
         <xsl:value-of select="SMRDORQ_ROWSET/SMRDORQ_SET/SMRDORQ_SUBJ_DESC"/></A>
         </TD>
         </xsl:otherwise>
         </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
         <TD CLASS="dddefault" scope="col" ><xsl:value-of select="SMRDORQ_ROWSET/SMRDORQ_SET/SMRDORQ_SUBJ_DESC"/></TD>
      </xsl:otherwise>
      </xsl:choose>
      <TD CLASS="dddefault" scope="col" ><xsl:value-of select="SMRDORQ_ROWSET/SMRDORQ_SET/SMRDORQ_ATTR_DESC"/></TD>
   </xsl:otherwise>
</xsl:choose>

<!--   low and high course number -->
<TD CLASS="dddefault" scope="col" ><xsl:value-of select="SMRDORQ_ROWSET/SMRDORQ_SET/SMRDORQ_CRSE_NUMB_LOW"/></TD>
<TD CLASS="dddefault" scope="col" ><xsl:value-of select="SMRDORQ_ROWSET/SMRDORQ_SET/SMRDORQ_CRSE_NUMB_HIGH"/></TD>
<!--
<TD CLASS="dddefault" scope="col">
   <xsl:call-template name="creditformat">
      <xsl:with-param name="credit_value"><xsl:value-of select="SMRDORQ_ROWSET/SMRDORQ_SET/SMRDORQ_REQ_CREDITS"/></xsl:with-param>
   </xsl:call-template>
</TD>
<TD CLASS="dddead" scope="col" ><xsl:value-of select="SMRDORQ_ROWSET/SMRDORQ_SET/SMRDORQ_REQ_COURSES"/></TD>
-->
<xsl:choose>
   <xsl:when test="$codedisplay = 'Y'">
      <TD CLASS="dddead" scope="col" ><xsl:value-of select="DETAIL_REQUIREMENT_USED/SMRDOUS_ROWSET/SMRDOUS_SET/SMRDOUS_TERM_CODE"/></TD>
      <TD CLASS="dddefault" scope="col"><xsl:value-of select="DETAIL_REQUIREMENT_USED/SMRDOUS_ROWSET/SMRDOUS_SET/SMRDOUS_SUBJ_CODE"/></TD>
   </xsl:when>
   <xsl:otherwise>
      <TD CLASS="dddead" scope="col" ><xsl:value-of select="DETAIL_REQUIREMENT_USED/SMRDOUS_ROWSET/SMRDOUS_SET/SMRDOUS_TERM_DESC"/></TD>
      <TD CLASS="dddefault" scope="col"><xsl:value-of select="DETAIL_REQUIREMENT_USED/SMRDOUS_ROWSET/SMRDOUS_SET/SMRDOUS_SUBJ_DESC"/></TD>
   </xsl:otherwise>
</xsl:choose>
<TD CLASS="dddefault" scope="col" ><xsl:value-of select="DETAIL_REQUIREMENT_USED/SMRDOUS_ROWSET/SMRDOUS_SET/SMRDOUS_CRSE_NUMB"/></TD>
<TD CLASS="dddefault" scope="col" ><xsl:value-of select="DETAIL_REQUIREMENT_USED/SMRDOUS_ROWSET/SMRDOUS_SET/SMRDOUS_TITLE"/></TD>
<xsl:choose>
   <xsl:when test="$codedisplay = 'Y'">
      <TD CLASS="dddefault" scope="col" ><xsl:value-of select="DETAIL_REQUIREMENT_USED/SMRDOUS_ROWSET/SMRDOUS_SET/SMRDOUS_ATTR_CODE"/></TD>
   </xsl:when>
   <xsl:otherwise>
      <TD CLASS="dddefault" scope="col" ><xsl:value-of select="DETAIL_REQUIREMENT_USED/SMRDOUS_ROWSET/SMRDOUS_SET/SMRDOUS_ATTR_DESC"/></TD>
   </xsl:otherwise>
</xsl:choose>
<TD CLASS="dddefault" scope="col">
<xsl:if test="(DETAIL_REQUIREMENT_USED/SMRDOUS_ROWSET/SMRDOUS_SET/SMRDOUS_CREDIT_HOURS)">
   <xsl:call-template name="creditformat">
      <xsl:with-param name="credit_value"><xsl:value-of select="DETAIL_REQUIREMENT_USED/SMRDOUS_ROWSET/SMRDOUS_SET/SMRDOUS_CREDIT_HOURS"/></xsl:with-param>
   </xsl:call-template>
</xsl:if>
</TD>
<xsl:choose>
   <xsl:when test="DETAIL_REQUIREMENT_USED/SMRDOUS_ROWSET/SMRDOUS_SET/SMRDOUS_CRSE_SOURCE = 'R'">
      <TD CLASS="dddefault"></TD>
   </xsl:when>
   <xsl:otherwise>
      <TD CLASS="dddefault" scope="col" >
      <xsl:value-of select="DETAIL_REQUIREMENT_USED/SMRDOUS_ROWSET/SMRDOUS_SET/SMRDOUS_GRDE_CODE"/>
      </TD>
   </xsl:otherwise>
</xsl:choose>
<TD CLASS="dddefault" scope="col" ><xsl:value-of select="DETAIL_REQUIREMENT_USED/SMRDOUS_ROWSET/SMRDOUS_SET/SMRDOUS_CRSE_SOURCE"/></TD>
</TR>
</xsl:template>
<xsl:template match="DETAIL_REQUIREMENT_USED/SMRDOUS_ROWSET/SMRDOUS_SET">
<xsl:if test="position()!= '1'">
<TR>
   <TD CLASS="dddefault" scope="col" ></TD>
   <TD CLASS="dddefault" scope="col" ></TD>
   <TD CLASS="dddefault" scope="col" ></TD>
   <TD CLASS="dddefault" scope="col" ></TD>
   <TD CLASS="dddefault" scope="col" ></TD>
   <TD CLASS="dddefault" scope="col" ></TD>
   <TD CLASS="dddefault" scope="col" ></TD>
   <TD CLASS="dddefault" scope="col"></TD>
   <TD CLASS="dddefault" scope="col"></TD>
   <xsl:choose>
      <xsl:when test="$codedisplay = 'Y'">
         <TD CLASS="dddefault" scope="col" ><xsl:value-of select="SMRDOUS_TERM_CODE"/></TD>
         <TD CLASS="dddefault" scope="col" ><xsl:value-of select="SMRDOUS_SUBJ_CODE"/></TD>
      </xsl:when>
      <xsl:otherwise>
         <TD CLASS="dddefault" scope="col" ><xsl:value-of select="SMRDOUS_TERM_DESC"/></TD>
         <TD CLASS="dddefault" scope="col" ><xsl:value-of select="SMRDOUS_SUBJ_DESC"/></TD>
      </xsl:otherwise>
   </xsl:choose>
   <TD CLASS="dddefault" scope="col" ><xsl:value-of select="SMRDOUS_CRSE_NUMB"/></TD>
   <TD CLASS="dddefault" scope="col" ><xsl:value-of select="SMRDOUS_TITLE"/></TD>
   <xsl:choose>
      <xsl:when test="$codedisplay = 'Y'">
         <TD CLASS="dddefault" scope="col" ><xsl:value-of select="SMRDOUS_ATTR_CODE"/></TD>
      </xsl:when>
      <xsl:otherwise>
         <TD CLASS="dddefault" scope="col" ><xsl:value-of select="SMRDOUS_ATTR_DESC"/></TD>
      </xsl:otherwise>
   </xsl:choose>
   <TD CLASS="dddefault">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMRDOUS_CREDIT_HOURS_USED"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <xsl:if test="SMRDOUS_CRSE_SOURCE !='R'">
      <TD CLASS="dddefault" scope="col" ><xsl:value-of select="SMRDOUS_GRDE_CODE"/></TD>
   </xsl:if>
   <!-- Defect 1-71XA02 -->
   <xsl:if test="SMRDOUS_CRSE_SOURCE = 'R'">
      <TD CLASS="dddefault"></TD>
   </xsl:if>
   <TD CLASS="dddefault" scope="col" ><xsl:value-of select="SMRDOUS_CRSE_SOURCE"/></TD>
</TR>
</xsl:if>
</xsl:template>
<xsl:template match="SMRARLT_ROWSET">
<TR>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="captiontext" COLSPAN="8">Area Course Attribute Attachment Rule Description</TD>
</TR>
<TR>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault" COLSPAN="8">
   <xsl:for-each select="SMRARLT_SET">
      <xsl:value-of select="SMRARLT_TEXT" disable-output-escaping="yes"/>&#xa0;
   </xsl:for-each>
   </TD>
</TR>
</xsl:template>
<xsl:template match="SMRSARD_ROWSET">
<TR>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="captiontext" COLSPAN="8">Adjusted Area Course Attribute Attachment Rule Description</TD>
</TR>
<TR>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault" COLSPAN="8">
   <xsl:for-each select="SMRSARD_SET">
      <xsl:value-of select="SMRSARD_TEXT" disable-output-escaping="yes"/>&#xa0;
   </xsl:for-each>
   </TD>
</TR>
</xsl:template>
<xsl:template match="SMRGRLT_ROWSET">
<TR>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="captiontext" COLSPAN="8">Group Course Attribute Attachment Rule Description</TD>
</TR>
<TR>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault" COLSPAN="8">
   <xsl:for-each select="SMRGRLT_SET">
      <xsl:value-of select="SMRGRLT_TEXT" disable-output-escaping="yes"/>&#xa0;
   </xsl:for-each>
   </TD>
</TR>
</xsl:template>
<xsl:template match="SMRSGRD_ROWSET">
<TR>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="captiontext" COLSPAN="8">Adjusted Group Course Attribute Attachment Rule Description</TD>
</TR>
<TR>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault" COLSPAN="8">
   <xsl:for-each select="SMRSGRD_SET">
      <xsl:value-of select="SMRSGRD_TEXT" disable-output-escaping="yes"/>&#xa0;
   </xsl:for-each>
   </TD>
</TR>
</xsl:template>
<xsl:template match="DTLTXT_ROWSET">
<TR>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="captiontext" COLSPAN="6">Course Attribute Attachment Description</TD>
</TR>
<TR>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault" COLSPAN="6">
   <xsl:for-each select="DTLTXT_SET">
      <xsl:value-of select="SMRACCM_TEXT" disable-output-escaping="yes"/>&#xa0;
   </xsl:for-each>
   </TD>
</TR>
<TR>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault" COLSPAN="6">
   <xsl:for-each select="DTLTXT_SET">
      <xsl:value-of select="SMRSACT_TEXT" disable-output-escaping="yes"/>&#xa0;
   </xsl:for-each>
   </TD>
</TR>
<TR>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault" COLSPAN="6">
   <xsl:for-each select="DTLTXT_SET">
      <xsl:value-of select="SMRGCCM_TEXT" disable-output-escaping="yes"/>&#xa0;
   </xsl:for-each>
   </TD>
</TR>
<TR>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault" COLSPAN="6">
   <xsl:for-each select="DTLTXT_SET">
      <xsl:value-of select="SMRSGCT_TEXT" disable-output-escaping="yes"/>&#xa0;
   </xsl:for-each>
   </TD>
</TR>
</xsl:template>
<xsl:template match="SMRDOLV_ROWSET">
<TR>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="captiontext" COLSPAN="6">Course Include/Exclude Additional Levels</TD>
</TR>
<TR>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TH CLASS="ddheader" scope="col" >Level</TH>
   <TH CLASS="ddheader" scope="col" >Include/Exclude</TH>
   <TH CLASS="ddheader" scope="col" >Grade</TH>
   <TH CLASS="ddheader" scope="col" >Maximum Credits</TH>
   <TH CLASS="ddheader" scope="col" >And/Or</TH>
   <TH CLASS="ddheader" scope="col" >Actual Credits</TH>
   <TH CLASS="ddheader" scope="col" >Actual Courses</TH>
</TR>
<xsl:for-each select="SMRDOLV_SET">
<TR>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRDOLV_LEVL_DESC"/></TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="incl_excl_format">
         <xsl:with-param name="incl_excl"><xsl:value-of select="SMRDOLV_INCL_EXCL_IND"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRDOLV_GRDE_CODE_MIN"/></TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMRDOLV_MAX_CREDITS"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="connector_format">
         <xsl:with-param name="connect_ind"><xsl:value-of select="SMRDOLV_CONNECTOR_MAX"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMRDOLV_ACT_CREDITS"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRDOLV_ACT_COURSES"/></TD>
</TR>
</xsl:for-each>
</xsl:template>
<xsl:template match="SMRDOEX_ROWSET">
<xsl:comment>The subject restricted area  JDH</xsl:comment>
<!-- TR>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="captiontext" COLSPAN="6">Subject Restricted Subjects and Attributes</TD>
</TR>
<TR>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TH CLASS="ddheader" scope="col" >Subject</TH>
   <TH CLASS="ddheader" scope="col" >Attribute</TH>
   <TH CLASS="ddheader" scope="col" >Low</TH>
   <TH CLASS="ddheader" scope="col" >High</TH>
   <TH CLASS="ddheader" scope="col" >Campus</TH>
   <TH CLASS="ddheader" scope="col" >College</TH>
   <TH CLASS="ddheader" scope="col" >Department</TH>
   <TH CLASS="ddheader" scope="col" >Maximum Credits</TH>
   <TH CLASS="ddheader" scope="col" >And/Or</TH>
   <TH CLASS="ddheader" scope="col" >Actual Credits</TH>
   <TH CLASS="ddheader" scope="col" >Actual Courses</TH>
</TR -->
<xsl:for-each select="SMRDOEX_SET">
<TR>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <TD CLASS="dddefault"></TD>
   <xsl:choose>
      <xsl:when test="$codedisplay = 'Y'">
         <TD CLASS="dddefault"><xsl:value-of select="SMRDOEX_SUBJ_CODE"/></TD>
         <TD CLASS="dddefault"><xsl:value-of select="SMRDOEX_ATTR_CODE"/></TD>
      </xsl:when>
      <xsl:otherwise>
         <TD CLASS="dddefault"><xsl:value-of select="SMRDOEX_SUBJ_DESC"/></TD>
         <TD CLASS="dddefault"><xsl:value-of select="SMRDOEX_ATTR_DESC"/></TD>
      </xsl:otherwise>
   </xsl:choose>
   <TD CLASS="dddefault"><xsl:value-of select="SMRDOEX_CRSE_NUMB_LOW"/></TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRDOEX_CRSE_NUMB_HIGH"/></TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRDOEX_CAMP_DESC"/></TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRDOEX_COLL_DESC"/></TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRDOEX_DEPT_DESC"/></TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMRDOEX_MAX_CREDITS"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="connector_format">
         <xsl:with-param name="connect_ind"><xsl:value-of select="SMRDOEX_CONNECTOR_MAX"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault">
      <xsl:call-template name="creditformat">
         <xsl:with-param name="credit_value"><xsl:value-of select="SMRDOEX_ACT_CREDITS"/></xsl:with-param>
      </xsl:call-template>
   </TD>
   <TD CLASS="dddefault"><xsl:value-of select="SMRDOEX_ACT_COURSES"/></TD>
</TR>
</xsl:for-each>
</xsl:template>
<xsl:template match="message">
  <table Summary="This displays error messages to displayed in report">
  <tr>
     <td class="uportal-text">
     <b><xsl:value-of select="text"/></b>
     </td>
  </tr>
  </table>
</xsl:template>
<xsl:template name="creditformat">
  <xsl:param name="credit_value">notdefined</xsl:param>
    <xsl:choose>
    <xsl:when test="$credit_value=0">
       <xsl:value-of select="$credit_value"/>
    </xsl:when>
    <xsl:when test="$credit_value=''">
       <xsl:value-of select="'-'"/>
    </xsl:when>
    <xsl:when test="$credit_value!=0">
       <xsl:value-of select="format-number($credit_value, '###,###,##0.00')"/>
    </xsl:when>
    <xsl:otherwise>
       <xsl:text></xsl:text>
    </xsl:otherwise>
    </xsl:choose>
</xsl:template>
<xsl:template name="yes_no_ind_format">
  <xsl:param name="yes_no_ind">notdefined</xsl:param>
    <xsl:if test="$yes_no_ind='N'">
       <xsl:text>No</xsl:text>
    </xsl:if>
    <xsl:if test="$yes_no_ind='Y'">
       <xsl:text>Yes</xsl:text>
    </xsl:if>
</xsl:template>
<xsl:template name="incl_excl_format">
  <xsl:param name="incl_excl">notdefined</xsl:param>
    <xsl:if test="$incl_excl='I'">
       <xsl:text>Include</xsl:text>
    </xsl:if>
    <xsl:if test="$incl_excl='E'">
       <xsl:text>Exclude</xsl:text>
    </xsl:if>
</xsl:template>
<xsl:template name="connector_format">
  <xsl:param name="connect_ind">notdefined</xsl:param>
    <xsl:if test="$connect_ind='N'">
       <xsl:text>None</xsl:text>
    </xsl:if>
    <xsl:if test="$connect_ind='A'">
       <xsl:text>And</xsl:text>
    </xsl:if>
    <xsl:if test="$connect_ind='O'">
       <xsl:text>Or</xsl:text>
    </xsl:if>
</xsl:template>
<xsl:template name="formatDate">
<xsl:param name="DateTime" />
<!-- date format 1998-03-15 -->
<xsl:variable name="year">
<xsl:value-of select="substring-before($DateTime,'-')" />
</xsl:variable>
<xsl:variable name="mo-temp">
<xsl:value-of select="substring-after($DateTime,'-')" />
</xsl:variable>
<xsl:variable name="mo">
<xsl:value-of select="substring-before($mo-temp,'-')" />
</xsl:variable>
<xsl:variable name="day">
<xsl:value-of select="substring-after($mo-temp,'-')" />
</xsl:variable>
<xsl:if test="$day != '00'">
<xsl:value-of select="$day"/>
<xsl:value-of select="''"/> 
</xsl:if>
<xsl:choose>
<xsl:when test="$mo = '1' or $mo = '01'">-JAN-</xsl:when>
<xsl:when test="$mo = '2' or $mo = '02'">-FEB-</xsl:when>
<xsl:when test="$mo = '3' or $mo = '03'">-MAR-</xsl:when>
<xsl:when test="$mo = '4' or $mo = '04'">-APR-</xsl:when>
<xsl:when test="$mo = '5' or $mo = '05'">-MAY-</xsl:when>
<xsl:when test="$mo = '6' or $mo = '06'">-JUN-</xsl:when>
<xsl:when test="$mo = '7' or $mo = '07'">-JUL-</xsl:when>
<xsl:when test="$mo = '8' or $mo = '08'">-AUG-</xsl:when>
<xsl:when test="$mo = '9' or $mo = '09'">-SEP-</xsl:when>
<xsl:when test="$mo = '10'">-OCT-</xsl:when>
<xsl:when test="$mo = '11'">-NOV-</xsl:when>
<xsl:when test="$mo = '12'">-DEC-</xsl:when>
<xsl:when test="$mo = '0' or $mo = '00'"></xsl:when><!-- do nothing -->
</xsl:choose>
<xsl:value-of select="$year"/>
</xsl:template> 
<xsl:template name="AREA_GPA_FOOTER">
<TR>
<TD CLASS="dddefault" COLSPAN="15"></TD>
<TD CLASS="dddefault" COLSPAN="1">GPA : </TD>
<TD CLASS="dddefault"><xsl:value-of select="format-number(../SMBAOGN_ROWSET/SMBAOGN_SET/SMBAOGN_ACT_AREA_GPA, $gpafmt)"/></TD>
</TR>
</xsl:template>
<!-- Start of MSCD additions  -->
<xsl:template match="SMRPRRQ_ROWSET">
<p align="center">METROPOLITAN STATE COLLEGE OF DENVER</p>
<P align="center"><font size="+2"><strong>CAPP Compliance Report</strong></font></P>
<BR></BR>
	<TABLE CLASS="datadisplaytable" WIDTH="100%" border="1" SUMMARY="summary">
		<TR>
			<TD COLSPAN="1" CLASS="dddefault"><xsl:value-of select="SMRPRRQ_SET/SMRPRRQ_ADDR_NAME"/></TD>
			<TD COLSPAN="1" CLASS="dddefault"><xsl:value-of select="/SMRCRLT_XML/SPRIDEN_ROWSET/SPRIDEN_SET/SPRIDEN_NAME"/></TD>
		</TR>
		<TR>
			<TD COLSPAN="1" CLASS="dddefault"><xsl:value-of select="SMRPRRQ_SET/SMRPRRQ_STREET_LINE1"/></TD>
			<TD COLSPAN="1" CLASS="dddefault">ID: <xsl:value-of select="/SMRCRLT_XML/SPRIDEN_ROWSET/SPRIDEN_SET/SPRIDEN_ID"/></TD>
		</TR>
		<TR>
			<TD COLSPAN="1" CLASS="dddefault"><xsl:value-of select="SMRPRRQ_SET/SMRPRRQ_STREET_LINE2"/></TD>
			<TD COLSPAN="1" CLASS="dddefault">Print Date: <xsl:value-of select="/SMRCRLT_XML/SMRRQCM_ROWSET/SMRRQCM_SET/SMRRQCM_REQUEST_DATE"/></TD>
		</TR>
		<TR>
			<TD COLSPAN="1" CLASS="dddefault"><xsl:value-of select="SMRPRRQ_SET/SMRPRRQ_CITY"/> ,
			<xsl:value-of select="SMRPRRQ_SET/SMRPRRQ_STAT_CODE"/> &nbsp;
			<xsl:value-of select="SMRPRRQ_SET/SMRPRRQ_ZIP"/></TD>

			<TD COLSPAN="1" CLASS="dddefault">Degree Catalog: <xsl:value-of select="/SMRCRLT_XML/SMRRQCM_ROWSET/SMRRQCM_SET/SMRRQCM_TERM_CTLG_1_DESC"/></TD>
		</TR>
	</TABLE>
<BR></BR>
<hr noshade="noshade" width="100%" size="5" />
</xsl:template>

<xsl:template match="SPRIDEN_ROWSET">
<p>The <strong>CAPP</strong> (Curriculum, Advising, and Program Planning) Compliance Report is an advising 
tool to be used by students and<br />
their advisors throughout the students' academic career at MSCD. 
Students with declared majors and/or minors should discuss<br />
their progress towards completion of their major (minor) program with their faculty advisor. Undeclared majors should check with<br />
the Academic Advising Center (CN104) until a major (minor) is declared.</p>
<p><strong> Declaring or Changing a Major/Minor/Degree Catalog</strong> -- To declare a major, minor, or degree catalog obtain a Declaration of <br />
Major/Minor Form from the Academic Advising Center, CN104 or from the academic department. Signatures approving the<br />
declaration/change must be obtained from the faculty advisor in the major or minor department before the form is returned to the<br />
Academic Advising Center.  If appropriate, a concentration in the major/minor should also be declared.
</p>
<p><strong>Degree Catalog</strong> -- This is the MSCD Catalog under which a student meets all degree requirements. Students are eligible to <br />
follow any catalog in effect while maintaining continuous enrollment at MSCD. 
See "Selection of Catalog for Requirements" in<br />
the MSCD Catalog. It is extremely important for students to indicate the same degree catalog when declaring their major/minor,<br />
concentration, requesting CAPP Compliance Reports, having adustments made, and applying to graduate. A degree catalog may<br />
be indicated in either the format "1999-2000" or "Fall 1999". The 1999-2000 Catalog, for example, covers the semesters Fall<br />
1999, Spring 2000, and Summer 2000.</p>

<p> NOTE: 1) The CAPP Compliance Report is NOT an Application for Graduation. 
  <strong>All prospective degree 
  candidates must file <br />
  an Application for Graduation Card in the Office of the Registrar at the 
  start of their final semester of <br />
  graduation.  Deadlines are as follows: Summer 2011 - June 3, 2011;  Fall 2011 - August 30, 2011;  Spring 2012 - January 27, 2012.</strong></p>
<p>2) If students have repeated courses, either at MSCD or in transfer, their CAPP report may show more credit than can be<br />
applied to their degree requirements. It is their responsibility to report this to the
Office of the Registrar, and failure to<br />
do so may negatively affect their ability to graduate as planned.</p>
  <hr width="100%" size="3" />
  <p align="center">Explanation of Terms and Symbols Used in the Compliance Report</p>
  <table width="800" border="1" cellspacing="1" cellpadding="1">
  <caption>
      Explanation of Terms and Symbols Used in the Compliance Report
  </caption>
    <tr>
      <th scope="col" colspan="2">Requirements</th>
      <th scope="col" colspan="7">Courses Completed/In-Progress</th>
    </tr>
    <tr>
      <td width="38">Met</td>
      <td width="152">Description</td>
      <td width="32">Term</td>
      <td width="108">Course</td>
      <td width="180">Title</td>
      <td width="25">Cr</td>
      <td width="35">Grd</td>
      <td width="28">S</td>
      <td width="40">Act'n</td>
    </tr>
    <tr>
      <td colspan="9"><strong>Met</strong> -- Y = the requirement has been met.  N = the requirement has NOT been met, or an option has not been completed though the overall requirement may be met.<br />
        <strong>Description</strong> -- A description of the requirement given in one of several ways:<br />
* By listing a specific course that must be taken,<br />
* By briefly describing a type of course that must be taken, or<br />
* By listing an attribute that a course must have, e.g., MA02 is the attribute for the General Studies Mathematics course. <br />
<strong>Term</strong>-- Semester the course was taken. <em>Transfer courses are assigned the term they were entered on the student's MSCD record.</em><br />
<strong>Course </strong>-- Course prefix and number.  Course numbers are four digits beginning Spring 1998.  Lower-division transfer courses are often assigned an 8000 number; upper-division transfer courses are often assigned a 9000 number.<br />
<strong>Title</strong> -- Title of the course.<br />
<strong>Cr</strong> -- Course Credit hours. Courses taken under the quarter hour system may appear with a decimal.<br />
<strong>Grd </strong>-- Grade or Notation:  A, B, C, D, P, S; T = Transfer course; AP = Advanced Placement; 
    CL = CLEP; EX = Credit by Exam; PL = Credit for Prior Learning; and PP = Proficiency Examination Program.
    NOTE: The following grades/notations and their coursework will not appear on the Compliance Report: 
    F = Failure; I = Incomplete; CC = Incomplete Correspondence Course; NC = No Credit; NR = Grade Not Reported <br />
    <strong>S</strong>-- Source:  H = Historical (completed) MSCD course;  R = Registered but not completed; T = Transfer course<br />
    <strong>Act'n</strong> -- Action:  Describes actions taken relative to the requirement, e.g., Wav = Waived, Sub = Substitution.
    -- Action:  Describes actions taken relative to the requirement, e.g., Wav = Waived; Sub = Substituted; PDG = Completed with previous degree; [MPD = Met with previous degree; MBE = Met by exam (for Teacher Licensure Only)].</td>
    </tr>
  </table>
  <p align="center"><strong>YOUR CURRENT MSCD DECLARED PROGRAM</strong></p>
<p>Below is your currently declared program on your MSCD student record. If you wish to change your declared major, minor,<br />
concentration or degree catalog, see page 1 of this report. If you have questions, please contact the Academic Advising Center, CN104. <br />
To view requirements for a second major or teacher licensure a separate CAPP Report must be run. Please check your major program <br />
for required concentrations or minor
</p>


</xsl:template>

<xsl:template name="AREA_TABLE_HEADER">
<!-- xsl:if test="hdrdone='N'"   -->
<BR></BR>
<TABLE BORDER="1" CLASS="datadisplaytable" WIDTH="65%" SUMMARY="summary">
   <CAPTION class="captiontext">Area Requirements </CAPTION>
   <TR>
      <TH COLSPAN="1" CLASS="dddead">Area</TH>
      <TH COLSPAN="1" CLASS="dddead">Met</TH>
 <!--
      <TH COLSPAN="1" CLASS="dddead">Credits</TH>
       <TH COLSPAN="2" CLASS="ddtitle" scope="colgroup">Courses</TH>
 -->
      <TH CLASS="ddheader" scope="col">Required</TH>
      <TH CLASS="ddheader" scope="col">Completed/In-Progress</TH>
<!--
      <TH CLASS="ddheader" scope="col">Required</TH>
      <TH CLASS="ddheader" scope="col">Used</TH>
-->
   </TR>
 
   <xsl:apply-templates select="AREA"/>
   <xsl:apply-templates select="SMBPOGN_ROWSET"/>

<!-- xsl:if test="hdrdone='N'"   -->
</TABLE>   
<!-- /xsl:if  -->   

<p align="center"><strong>
*** IMPORTANT NOTES ***<br />
It is your responsibility to read and seek advice regarding information contained throughout this<br />
CAPP Compliance Report. Please refer specifically to subsequent pages of the report for details about<br />
any areas of the Program Summary that show as N (NOT MET).<br />
Grades for current semester courses showing on this report with a source (column S) of R are<br />
unofficial and subject to change until grades are officially posted after the end of the semester.<br />
Corresponding grade point averages do not reflect these grades.<br />
</strong></p>

</xsl:template>

<!-- bottom -->
</xsl:stylesheet>
