
WITH CCS_SET AS
	(
	SELECT FND_CCS_ALCN.FND_CD
		  ,FND_CCS_ALCN.ORD_DT
		  ,FND_CCS_ALCN.ISIN_CD
		  ,ITM_TR.ITM_NM
		  ,MAX(ITM_TR.FNMN_USID) AS FNMN_USID
		  ,MAX(CMPL_APV.CIO_APV_TC) AS CIO_APV_YN
		  ,SUM(FND_CCS_ALCN.CCS_QTY) AS CCS_QTY
	  FROM ${SCHEMA_NAME}.TSOL_OM_INTG_ORD_FND_CCS_ALCN_SFS FND_CCS_ALCN   /* EOM_통합주문펀드체결배분명세 */
		   INNER JOIN ${SCHEMA_NAME}.TSOL_OM_INTG_BKR_ORD_ITM_TR_SFS BKR_ORD_ITM       /* EOM_통합브로커주문종목거래명세 */
		   ON (/* EOM_통합브로커주문종목거래명세 */
	           FND_CCS_ALCN.IST_CD = BKR_ORD_ITM.IST_CD
	       AND FND_CCS_ALCN.AMCO_CD = BKR_ORD_ITM.AMCO_CD
	       AND FND_CCS_ALCN.ORD_DT = BKR_ORD_ITM.ORD_DT
	       AND FND_CCS_ALCN.TR_CD = BKR_ORD_ITM.TR_CD
	       AND FND_CCS_ALCN.BKR_ITM_ORNO = BKR_ORD_ITM.BKR_ITM_ORNO
	       AND BKR_ORD_ITM.FST_CCS_DTM BETWEEN TO_DATE_NOA(#{ccuAsprSttHr, jdbcType=VARCHAR}, 'YYYY-MM-DD HH24:MI:SS') AND TO_DATE_NOA(#{ccuAsprEndHr, jdbcType=VARCHAR}, 'YYYY-MM-DD HH24:MI:SS') /*동시호가시간*/)

		   INNER JOIN ${SCHEMA_NAME}.TSOL_OM_INTG_ORD_ITM_TR_SFS ITM_TR                /* EOM_통합주문종목거래명세 */
		   ON (/* EOM_통합주문종목거래명세 */
	           FND_CCS_ALCN.IST_CD = ITM_TR.IST_CD
	       AND FND_CCS_ALCN.AMCO_CD = ITM_TR.AMCO_CD
	       AND FND_CCS_ALCN.ORD_DT = ITM_TR.ORD_DT
	       AND FND_CCS_ALCN.TR_CD = ITM_TR.TR_CD
	       AND FND_CCS_ALCN.ITM_ORNO = ITM_TR.ITM_ORNO
	       AND 'N' = ITM_TR.CCL_TC)

		   INNER JOIN ${SCHEMA_NAME}.TSOL_OM_INTG_ORD_CMPL_APV_SFS CMPL_APV            /* EOM_통합주문컴플승인명세 */
		   ON (/* EOM_통합주문컴플승인명세 */
	           FND_CCS_ALCN.IST_CD = CMPL_APV.IST_CD
	       AND FND_CCS_ALCN.AMCO_CD = CMPL_APV.AMCO_CD
	       AND FND_CCS_ALCN.ORD_DT = CMPL_APV.ORD_DT
	       AND FND_CCS_ALCN.TR_CD = CMPL_APV.TR_CD
	       AND FND_CCS_ALCN.ITM_ORNO = CMPL_APV.ITM_ORNO)

	 WHERE 1=1
	   /* EOM_통합주문펀드체결배분명세 */
	   AND FND_CCS_ALCN.IST_CD = #{istCd, jdbcType=VARCHAR}
	   AND FND_CCS_ALCN.ORD_DT = #{ordDt, jdbcType=VARCHAR} /* 영업일 구해서 지정 */
	   AND FND_CCS_ALCN.AMCO_CD = #{amcoCd, jdbcType=VARCHAR}
	   AND FND_CCS_ALCN.TR_CD = '101'
	   AND FND_CCS_ALCN.CCS_QTY > 0
	   AND FND_CCS_ALCN.DEL_YN = 'N'
	 GROUP BY FND_CCS_ALCN.FND_CD
			 ,FND_CCS_ALCN.ORD_DT
			 ,FND_CCS_ALCN.ISIN_CD
			 ,ITM_TR.ITM_NM
	UNION ALL
	SELECT FND_CCS_ALCN.FND_CD
		  ,FND_CCS_ALCN.ORD_DT
		  ,FND_CCS_ALCN.ISIN_CD
		  ,ITM_TR.ITM_NM
		  ,MAX(ITM_TR.FNMN_USID) AS FNMN_USID
		  ,MAX(CMPL_APV.CIO_APV_TC) AS CIO_APV_YN
		  ,SUM(FND_CCS_ALCN.CCS_QTY) AS CCS_QTY
	  FROM ${SCHEMA_NAME}.TSOL_OM_INTG_ORD_FND_CCS_ALCN_SFS FND_CCS_ALCN   /* EOM_통합주문펀드체결배분명세 */
		   INNER JOIN ${SCHEMA_NAME}.TSOL_OM_INTG_BKR_ORD_ITM_TR_SFS BKR_ORD_ITM       /* EOM_통합브로커주문종목거래명세 */
		   ON (/* EOM_통합브로커주문종목거래명세 */
	           FND_CCS_ALCN.IST_CD = BKR_ORD_ITM.IST_CD
	       AND FND_CCS_ALCN.AMCO_CD = BKR_ORD_ITM.AMCO_CD
	       AND FND_CCS_ALCN.ORD_DT = BKR_ORD_ITM.ORD_DT
	       AND FND_CCS_ALCN.TR_CD = BKR_ORD_ITM.TR_CD
	       AND FND_CCS_ALCN.BKR_ITM_ORNO = BKR_ORD_ITM.BKR_ITM_ORNO
	       AND BKR_ORD_ITM.FST_CCS_DTM BETWEEN TO_DATE_NOA(#{t1CcuAsprSttHr, jdbcType=VARCHAR}, 'YYYY-MM-DD HH24:MI:SS') AND TO_DATE_NOA(#{t1CcuAsprEndHr, jdbcType=VARCHAR}, 'YYYY-MM-DD HH24:MI:SS') /*T-1 동시호가시간*/)

		   INNER JOIN ${SCHEMA_NAME}.TSOL_OM_INTG_ORD_ITM_TR_SFS ITM_TR                /* EOM_통합주문종목거래명세 */
		   ON (/* EOM_통합주문종목거래명세 */
	           FND_CCS_ALCN.IST_CD = ITM_TR.IST_CD
	       AND FND_CCS_ALCN.AMCO_CD = ITM_TR.AMCO_CD
	       AND FND_CCS_ALCN.ORD_DT = ITM_TR.ORD_DT
	       AND FND_CCS_ALCN.TR_CD = ITM_TR.TR_CD
	       AND FND_CCS_ALCN.ITM_ORNO = ITM_TR.ITM_ORNO
	       AND 'N' = ITM_TR.CCL_TC)

		   INNER JOIN ${SCHEMA_NAME}.TSOL_OM_INTG_ORD_CMPL_APV_SFS CMPL_APV            /* EOM_통합주문컴플승인명세 */
		   ON (/* EOM_통합주문컴플승인명세 */
	           FND_CCS_ALCN.IST_CD = CMPL_APV.IST_CD
	       AND FND_CCS_ALCN.AMCO_CD = CMPL_APV.AMCO_CD
	       AND FND_CCS_ALCN.ORD_DT = CMPL_APV.ORD_DT
	       AND FND_CCS_ALCN.TR_CD = CMPL_APV.TR_CD
	       AND FND_CCS_ALCN.ITM_ORNO = CMPL_APV.ITM_ORNO)
	 WHERE 1=1
	   /* EOM_통합주문펀드체결배분명세 */
	   AND FND_CCS_ALCN.IST_CD = #{istCd, jdbcType=VARCHAR}
	   AND FND_CCS_ALCN.ORD_DT = F_BDD_SLS_DT_NOA(#{ordDt, jdbcType=VARCHAR} ,1) /* T-1 영업일 */
	   AND FND_CCS_ALCN.AMCO_CD = #{amcoCd, jdbcType=VARCHAR}
	   AND FND_CCS_ALCN.TR_CD = '101'
	   AND FND_CCS_ALCN.CCS_QTY > 0
	   AND FND_CCS_ALCN.DEL_YN = 'N'
	 GROUP BY FND_CCS_ALCN.FND_CD
			 ,FND_CCS_ALCN.ORD_DT
			 ,FND_CCS_ALCN.ISIN_CD
			 ,ITM_TR.ITM_NM
	)
	SELECT X.*
		FROM (
				SELECT SUM(CASE WHEN CAL_RT > 1 THEN 1 ELSE 0 END) AS VLT_CNT
					  ,FND_CD
					  ,FND_NM
					  ,ISIN_CD     AS ITM_CD
					  ,ITM_NM
					  ,HRK_DPM_ID
					  ,HRK_DPM_NM  AS FIEL_NM      /* 운용역본부코드명 AS HRK_DPM_NM*/
					  ,DPM_CD
					  ,DPM_NM                      /* 운용역팀코드명 */
					  ,FNMN_USID
					  ,USR_NM      AS FNMN_USR_NM	/* 운용역사용자명 */
					  ,MAX(CIO_APV_YN) AS CIO_APV_YN
					  ,SUM(CASE WHEN GUBUN = 'T-1' THEN CCS_QTY ELSE 0 END)      AS T1_CCS_QTY
					  ,SUM(CASE WHEN GUBUN = 'T-1' THEN D20_CCS_ASPR_VOLE ELSE 0 END) AS T1_D20_AVR_MKT_VOLE
					  ,SUM(CASE WHEN GUBUN = 'T-1' THEN CAL_RT ELSE 0 END)       AS T1_CAL_RT
					  ,SUM(CASE WHEN GUBUN = 'T' THEN CCS_QTY ELSE 0 END)        AS CCS_QTY
					  ,SUM(CASE WHEN GUBUN = 'T' THEN D20_CCS_ASPR_VOLE ELSE 0 END)   AS D20_AVR_MKT_VOLE
					  ,SUM(CASE WHEN GUBUN = 'T' THEN CAL_RT ELSE 0 END)         AS CAL_RT
					  ,MAX(ATIN_CTS) AS ATIN_CTS
				  FROM (
						SELECT CCS_SET.FND_CD
							  ,FND_BSC.FND_NM
							  ,CASE WHEN CCS_SET.ORD_DT = F_BDD_SLS_DT_NOA(#{ordDt, jdbcType=VARCHAR},1) THEN 'T-1'
									ELSE 'T'
									 END AS GUBUN
							  ,CCS_SET.ISIN_CD
							  ,CCS_SET.ITM_NM
							  ,FNMS_DPM_CD_CTL.HRK_DPM_ID
							  ,FNMS_HRK_DPM_CD_CTL.DPM_NM AS HRK_DPM_NM/* 운용역본부코드명 */
							  ,USR_BSC_FNMS.DPM_CD
							  ,FNMS_DPM_CD_CTL.DPM_NM /* 운용역부문명 */
							  ,CCS_SET.FNMN_USID
							  ,USR_BSC_FNMS.USR_NM    /* 운용역사용자명 */
							  ,CCS_SET.CIO_APV_YN
							  ,CCS_SET.CCS_QTY
							  ,ITM_AVR.D20_CCS_ASPR_VOLE
							  ,CASE WHEN NVL_NOA(ITM_AVR.D20_CCS_ASPR_VOLE,0) = 0 THEN 0
									ELSE (CCS_SET.CCS_QTY / ITM_AVR.D20_CCS_ASPR_VOLE) * 100
									 END AS CAL_RT
							  ,CASE WHEN CCS_SET.CIO_APV_YN = 'Y' THEN '' ELSE '사유확인' END ATIN_CTS
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
						       AND ITM_AVR.BSE_DT = F_NDD_SLS_DT_NOA(CCS_SET.ORD_DT, 1)
						       AND ITM_AVR.ISIN_CD = CCS_SET.ISIN_CD)
						 WHERE 1=1
					   ) AA
				 GROUP BY FND_CD
						 ,FND_NM
						 ,ISIN_CD
						 ,ITM_NM
						 ,HRK_DPM_ID
						 ,HRK_DPM_NM /* 운용역부문명 */
						 ,DPM_CD
						 ,DPM_NM /* 운용역팀코드명 */
						 ,FNMN_USID
						 ,USR_NM /* 운용역사용자명 */
			 ) X
	 WHERE X.VLT_CNT = 2
	   <if test='itmCd != null and itmCd != ""'>
	   AND X.ITM_CD = #{itmCd, jdbcType=VARCHAR}
	   </if>

	   <if test='fieldCd != null and fieldCd != ""'>
	   AND X.HRK_DPM_ID = #{fieldCd, jdbcType=VARCHAR}
	   </if>
	 ORDER BY 1,2,3
