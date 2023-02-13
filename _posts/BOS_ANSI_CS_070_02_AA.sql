
WITH CCS_SET AS
	(
	<![CDATA[
	SELECT FND_CCS_ALCN.FND_CD
		  ,FND_CCS_ALCN.ORD_DT
		  ,FND_CCS_ALCN.ISIN_CD
		  ,ITM_TR.ITM_NM
		  ,MAX(ITM_TR.FNMN_USID) AS FNMN_USID
		  ,MAX(CMPL_APV.CIO_APV_TC) AS CIO_APV_YN
		  ,SUM(FND_CCS_ALCN.CCS_QTY) AS CCS_QTY
	  FROM ${SCHEMA_NAME}.TSOL_OM_INTG_ORD_FND_CCS_ALCN_SFS FND_CCS_ALCN               /* EOM_통합주문펀드체결배분명세 */
		   INNER JOIN ${SCHEMA_NAME}.TSOL_OM_INTG_BKR_ORD_ITM_TR_SFS BKR_ORD_ITM       /* EOM_통합브로커주문종목거래명세 */
           ON (/* EOM_통합브로커주문종목거래명세 */
	           FND_CCS_ALCN.IST_CD = BKR_ORD_ITM.IST_CD
	       AND FND_CCS_ALCN.AMCO_CD = BKR_ORD_ITM.AMCO_CD
	       AND FND_CCS_ALCN.ORD_DT = BKR_ORD_ITM.ORD_DT
	       AND FND_CCS_ALCN.TR_CD = BKR_ORD_ITM.TR_CD
	       AND FND_CCS_ALCN.BKR_ITM_ORNO = BKR_ORD_ITM.BKR_ITM_ORNO
	       AND BKR_ORD_ITM.FST_CCS_DTM BETWEEN TO_DATE_NOA(#{ccuAsprSttHr, jdbcType=VARCHAR}, 'YYYY-MM-DD HH24:MI:SS') AND TO_DATE_NOA(#{ccuAsprEndHr, jdbcType=VARCHAR}, 'YYYY-MM-DD HH24:MI:SS'))

		   INNER JOIN ${SCHEMA_NAME}.TSOL_OM_INTG_ORD_ITM_TR_SFS ITM_TR                /* EOM_통합주문종목거래명세 */
           ON (/* EOM_통합주문종목거래명세 */
	           FND_CCS_ALCN.IST_CD = ITM_TR.IST_CD
	       AND FND_CCS_ALCN.AMCO_CD = ITM_TR.AMCO_CD
	       AND FND_CCS_ALCN.ORD_DT = ITM_TR.ORD_DT
	       AND FND_CCS_ALCN.TR_CD = ITM_TR.TR_CD
	       AND FND_CCS_ALCN.ITM_ORNO = ITM_TR.ITM_ORNO
	       AND 'N' = ITM_TR.CCL_TC)
		   
           INNER JOIN ${SCHEMA_NAME}.TSOL_CP_BFR_CKG_SAF CMPL_APV                      /* ECP_사전점검현황 */
           ON (/* EOM_통합주문컴플승인명세 */
	           FND_CCS_ALCN.IST_CD = CMPL_APV.IST_CD
	       AND FND_CCS_ALCN.AMCO_CD = CMPL_APV.AMCO_CD
	       AND FND_CCS_ALCN.ORD_DT = CMPL_APV.ORD_DT
	       AND FND_CCS_ALCN.TR_CD = CMPL_APV.TR_CD
	       AND FND_CCS_ALCN.ITM_ORNO = CMPL_APV.ITM_ORNO
	       AND CMPL_APV.CKG_HDN_CD = 'STAL002Z21'	/*동시호가[장중 체결 없이 20일 평균 거래량의 1% 초과 여부 점검]*/
	       AND CMPL_APV.VLT_WRN_TC = '1')
	 WHERE 1=1
	   /* EOM_통합주문펀드체결배분명세 */
	   AND FND_CCS_ALCN.IST_CD = #{istCd, jdbcType=VARCHAR}
	   AND FND_CCS_ALCN.ORD_DT = #{ordDt, jdbcType=VARCHAR}
	   AND FND_CCS_ALCN.AMCO_CD = #{amcoCd, jdbcType=VARCHAR}
	   AND FND_CCS_ALCN.TR_CD = '101'
	   AND FND_CCS_ALCN.CCS_QTY > 0
	   AND FND_CCS_ALCN.DEL_YN = 'N'

	   AND NOT EXISTS(
						SELECT 1
						  FROM ${SCHEMA_NAME}.TSOL_OM_INTG_ORD_ITM_TR_SFS A
							   INNER JOIN ${SCHEMA_NAME}.TSOL_OM_INTG_ORD_PRG_STA_SFS B
                               ON (A.IST_CD = B.IST_CD
						       AND A.AMCO_CD = B.AMCO_CD
						       AND A.ORD_DT = B.ORD_DT
						       AND A.TR_CD = B.TR_CD
						       AND A.ORNO = B.ORNO
						       AND B.ORD_GNT_DTM <= TO_DATE_NOA(#{mktEndHr, jdbcType=VARCHAR}, 'YYYY-MM-DD HH24:MI:SS'))
						 WHERE A.IST_CD = #{istCd, jdbcType=VARCHAR}
						   AND A.AMCO_CD = #{amcoCd, jdbcType=VARCHAR}
						   AND A.ORD_DT = #{ordDt, jdbcType=VARCHAR}
						   AND A.TR_CD = '101'
						   AND A.FND_CD = FND_CCS_ALCN.FND_CD
						   AND A.ISIN_CD = FND_CCS_ALCN.ISIN_CD
						   AND A.BUY_SLL_TC = 'B'
						   AND A.ORD_QTY > 0	/*전량취소가 되지 않은 것*/
					 )
	 GROUP BY FND_CCS_ALCN.FND_CD
			 ,FND_CCS_ALCN.ORD_DT
			 ,FND_CCS_ALCN.ISIN_CD
			 ,ITM_TR.ITM_NM
			 ,BKR_ORD_ITM.FST_CCS_DTM
	]]>
	)
	SELECT X.*
	  FROM (
			SELECT CASE WHEN (
								CASE WHEN NVL_NOA(ITM_AVR.D20_AVR_VOLE,0) = 0 THEN 0
									 ELSE (CCS_SET.CCS_QTY / ITM_AVR.D20_CCS_ASPR_VOLE) * 100
									  END
							 ) > 1 THEN '1.위반'
						ELSE '2.정상'
						 END AS CAL_STATUS
				  ,CCS_SET.FND_CD
				  ,FND_BSC.FND_NM
				  ,CCS_SET.ISIN_CD            AS ITM_CD
				  ,CCS_SET.ITM_NM
				  ,FNMS_DPM_CD_CTL.HRK_DPM_ID
				  ,FNMS_HRK_DPM_CD_CTL.DPM_NM AS FIEL_NM     /* 운용역본부코드명 AS HRK_DPM_NM*/
				  ,USR_BSC_FNMS.DPM_CD
				  ,FNMS_DPM_CD_CTL.DPM_NM                    /* 운용역부문명 */
				  ,CCS_SET.FNMN_USID
				  ,USR_BSC_FNMS.USR_NM        AS FNMN_USR_NM	/* 운용역사용자명 */
				  ,CCS_SET.CIO_APV_YN
				  ,CCS_SET.CCS_QTY
				  ,ITM_AVR.D20_CCS_ASPR_VOLE       AS D20_AVR_MKT_VOLE
				  ,CASE WHEN NVL_NOA(ITM_AVR.D20_AVR_VOLE,0) = 0 THEN 0
						ELSE (CCS_SET.CCS_QTY / ITM_AVR.D20_CCS_ASPR_VOLE) * 100
						 END AS CAL_RT
				  ,CASE WHEN CCS_SET.CIO_APV_YN = 'Y' THEN ''
						ELSE '사유확인'
						 END ATIN_CTS
			  FROM CCS_SET
				   INNER JOIN ${SCHEMA_NAME}.TSOL_OM_FND_BSC FND_BSC
                   ON (#{istCd, jdbcType=VARCHAR} = FND_BSC.IST_CD
			       AND #{amcoCd, jdbcType=VARCHAR} = FND_BSC.AMCO_CD
			       AND CCS_SET.FND_CD = FND_BSC.FND_CD)

				   LEFT OUTER JOIN ${SCHEMA_NAME}.TSOL_FW_USR_BSC USR_BSC_FNMS            /* EFW_사용자기본 운용역 */
                   ON (/* 운용역명 */
			           #{istCd, jdbcType=VARCHAR} = USR_BSC_FNMS.IST_CD
			       AND #{amcoCd, jdbcType=VARCHAR} = USR_BSC_FNMS.AMCO_CD
			       AND CCS_SET.FNMN_USID = USR_BSC_FNMS.USID)
				   
                   LEFT OUTER JOIN ${SCHEMA_NAME}.TSOL_FW_DPM_CD_CTL FNMS_DPM_CD_CTL      /* 운용역부서코드  */
                   ON (/* 운용역부서코드 */
			           #{istCd, jdbcType=VARCHAR} = FNMS_DPM_CD_CTL.IST_CD
			       AND USR_BSC_FNMS.DPM_CD = FNMS_DPM_CD_CTL.DPM_CD)
				   
                   LEFT OUTER JOIN ${SCHEMA_NAME}.TSOL_FW_DPM_CD_CTL FNMS_HRK_DPM_CD_CTL  /* 운용역본부코드 */
                   ON (/* 운용역본부코드 */
			           #{istCd, jdbcType=VARCHAR} = FNMS_HRK_DPM_CD_CTL.IST_CD
			       AND FNMS_DPM_CD_CTL.HRK_DPM_ID = FNMS_HRK_DPM_CD_CTL.DPM_CD)

				   INNER JOIN ${SCHEMA_NAME}.TSOL_DM_STK_ITM_AVR_VOLE_SFS ITM_AVR    /*EDM_주식종목평균거래량명세*/
                   ON (/*20일평균시장거래량*/
			           ITM_AVR.IST_CD = #{istCd, jdbcType=VARCHAR}
			       AND ITM_AVR.BSE_DT = #{marketDt, jdbcType=VARCHAR}
			       AND ITM_AVR.ISIN_CD = CCS_SET.ISIN_CD)
			 WHERE 1=1 
		   ) X
	 WHERE X.CAL_STATUS = '1.위반'
	   <if test='itmCd != null and itmCd != ""'>
	   AND X.ITM_CD = #{itmCd, jdbcType=VARCHAR}
	   </if>

	   <if test='fieldCd != null and fieldCd != ""'>
	   AND X.HRK_DPM_ID = #{fieldCd, jdbcType=VARCHAR}
	   </if>
	 ORDER BY 1,2,3

