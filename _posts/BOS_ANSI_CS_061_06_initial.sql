#JOB ID	JOB SEQ	작성자	Oracle Function 사용여부	비고
#BOS_ANSI_CS_061	05			
#특이사항	작업간 특이사항 기입

#ORACLE SQL

WITH CCS_SET AS
	(
	SELECT FND_CCS_ALCN.FND_CD
		  ,FND_CCS_ALCN.ORNO
		  ,FND_CCS_ALCN.ORD_DT
		  ,FND_CCS_ALCN.ISIN_CD
		  ,BD_CCS_BSC.BKR_CD
		  ,ITM_TR.ITM_NM
		  ,ITM_TR.FNMN_USID
		  ,ITM_TR.ITM_ORNO
		  ,FND_CCS_ALCN.BUY_SLL_TC
		  ,MIN(PRG_STA.FNMN_HDER_APV_DTM)      AS FNMN_HDER_APV_DTM /* 운용역헤더승인일시 */
		  ,MIN(BKR_ORD_TR.TRR_SHR_DTM)         AS TRR_SHR_DTM /* 트레이더배분일시 */
		  ,MIN(BD_CCS_BSC.FST_CCS_DTM)         AS FST_CCS_DTM /* 최초체결일시 */
		  ,SUM(NVL(BD_CCS_BSC.CCS_PAR_AMT,0))  AS CCS_QTY /* 체결금액  */
		  ,SUM(NVL(BD_CCS_BSC.STM_AMT,0))      AS STM_AMT /* 결제금액 */
		  ,MAX(NVL(BKR_ITM_TR.CCS_ROR,0))      AS CCS_ROR /*매매이율*/
	  FROM ${SCHEMA_NAME}.TSOL_OM_INTG_ORD_FND_CCS_ALCN_SFS FND_CCS_ALCN /* EOM_통합주문펀드체결배분명세 */
		  ,${SCHEMA_NAME}.TSOL_OM_BD_CCS_BSC BD_CCS_BSC                   /* EOM_채권체결기본 */
		  ,${SCHEMA_NAME}.TSOL_OM_INTG_ORD_ITM_TR_SFS ITM_TR              /* EOM_통합주문종목거래명세 */
		  ,${SCHEMA_NAME}.TSOL_OM_INTG_BKR_ORD_ITM_TR_SFS BKR_ITM_TR      /* EOM_통합브로커주문종목거래명세 */
		  ,${SCHEMA_NAME}.TSOL_OM_INTG_BKR_ORD_TR_BSC BKR_ORD_TR          /* EOM_통합브로커주문거래기본 */
		  ,${SCHEMA_NAME}.TSOL_OM_INTG_ORD_PRG_STA_SFS PRG_STA            /* EOM_통합주문진행상황명세 */
	 WHERE 1=1
	   /* EOM_통합주문펀드체결배분명세 */
	   AND FND_CCS_ALCN.IST_CD = #{istCd, jdbcType=VARCHAR}
	   AND FND_CCS_ALCN.ORD_DT = #{ordDt, jdbcType=VARCHAR}
	   AND FND_CCS_ALCN.AMCO_CD = #{amcoCd, jdbcType=VARCHAR}
	   AND FND_CCS_ALCN.TR_CD = '301'
	   AND FND_CCS_ALCN.DEL_YN = 'N'

	   /* EOM_채권체결기본 */
	   AND FND_CCS_ALCN.IST_CD = BD_CCS_BSC.IST_CD
	   AND FND_CCS_ALCN.AMCO_CD = BD_CCS_BSC.AMCO_CD
	   AND FND_CCS_ALCN.ORD_DT = BD_CCS_BSC.ORD_DT
	   AND FND_CCS_ALCN.TR_CD = BD_CCS_BSC.TR_CD
	   AND FND_CCS_ALCN.FND_CD = BD_CCS_BSC.FND_CD
	   AND FND_CCS_ALCN.BKR_ITM_ORNO = BD_CCS_BSC.BKR_ITM_ORNO
	   AND 'N' = BD_CCS_BSC.DEL_YN

	   /* EOM_통합주문종목거래명세 */
	   AND FND_CCS_ALCN.IST_CD = ITM_TR.IST_CD
	   AND FND_CCS_ALCN.AMCO_CD = ITM_TR.AMCO_CD
	   AND FND_CCS_ALCN.ORD_DT = ITM_TR.ORD_DT
	   AND FND_CCS_ALCN.TR_CD = ITM_TR.TR_CD
	   AND FND_CCS_ALCN.ITM_ORNO = ITM_TR.ITM_ORNO
	   AND 'N' = ITM_TR.CCL_TC

	   /* EOM_통합브로커주문종목거래명세 */
	   AND FND_CCS_ALCN.IST_CD = BKR_ITM_TR.IST_CD
	   AND FND_CCS_ALCN.AMCO_CD = BKR_ITM_TR.AMCO_CD
	   AND FND_CCS_ALCN.ORD_DT = BKR_ITM_TR.ORD_DT
	   AND FND_CCS_ALCN.TR_CD = BKR_ITM_TR.TR_CD
	   AND FND_CCS_ALCN.BKR_ITM_ORNO = BKR_ITM_TR.BKR_ITM_ORNO

	   /* EOM_통합브로커주문거래기본 */
	   AND FND_CCS_ALCN.IST_CD = BKR_ORD_TR.IST_CD
	   AND FND_CCS_ALCN.AMCO_CD = BKR_ORD_TR.AMCO_CD
	   AND FND_CCS_ALCN.ORD_DT = BKR_ORD_TR.ORD_DT
	   AND FND_CCS_ALCN.TR_CD = BKR_ORD_TR.TR_CD
	   AND FND_CCS_ALCN.ORNO = BKR_ORD_TR.ORNO
	   AND FND_CCS_ALCN.BKR_ORNO = BKR_ORD_TR.BKR_ORNO

	   /* EOM_통합주문진행상황명세 */
	   AND FND_CCS_ALCN.IST_CD = PRG_STA.IST_CD
	   AND FND_CCS_ALCN.AMCO_CD = PRG_STA.AMCO_CD
	   AND FND_CCS_ALCN.ORD_DT = PRG_STA.ORD_DT
	   AND FND_CCS_ALCN.TR_CD = PRG_STA.TR_CD
	   AND FND_CCS_ALCN.ORNO = PRG_STA.ORNO
	   AND 'N' = PRG_STA.DEL_YN
	 GROUP BY FND_CCS_ALCN.FND_CD
			 ,FND_CCS_ALCN.ORNO
			 ,ITM_TR.ITM_ORNO
			 ,FND_CCS_ALCN.ORD_DT
			 ,FND_CCS_ALCN.ISIN_CD
			 ,BD_CCS_BSC.BKR_CD
			 ,ITM_TR.ITM_NM
			 ,ITM_TR.FNMN_USID
			 ,FND_CCS_ALCN.BUY_SLL_TC
	)
	SELECT X.*
	  FROM (
			/* 평가수익율 대비 괴리율 */
			SELECT CASE WHEN ABS(NVL(CCS_SET.CCS_ROR,0) - (NVL(BD_GR.LST_YTM,0) * 100)) > #{dprtRt, jdbcType=NUMERIC} THEN '1.위반'
						ELSE '2.정상'
						 END AS CAL_STATUS
				  ,CCS_SET.ORD_DT
				  ,USR_BSC_FNMS.TEM_CD
				  ,TEM_CD_CTL.TEM_NM        /* 운용역팀코명 */
				  ,CCS_SET.FNMN_USID
				  ,USR_BSC_FNMS.USR_NM        AS FNMN_USR_NM /* 운용역사용자명 */
				  ,CCS_SET.FND_CD
				  ,FND_BSC.FND_NM
				  ,DTL_BUY_SLL_TC.CO_CVA_NM   AS BUY_SLL_NM /* 매수매도구분 */
				  ,CCS_SET.ORNO
				  ,CCS_SET.ISIN_CD            AS ITM_CD
				  ,CCS_SET.ITM_NM
				  ,CCS_SET.BKR_CD
				  ,BKR_BSC.BKR_NM             AS BKR_NM     /* 브로커명 */
				  ,CCS_SET.CCS_QTY            AS PAR_AMT    /* 체결금액  */
				  ,CCS_SET.STM_AMT                          /* 결제금액 */
				  ,CCS_SET.CCS_ROR            AS BUY_SLL_RT /* 매매이율 */
				  ,NVL(BD_GR.LST_YTM,0) * 100   AS EVL_ERN_RT /* 평가수익율 */
				  ,ABS(NVL(CCS_SET.CCS_ROR,0) - (NVL(BD_GR.LST_YTM,0) * 100)) AS DPRT_RT /*괴리율*/
				  ,BD_ITM.PUB_DT                              /* 발행일자 */
				  ,BD_ITM.RDM_DT              AS XRT_DT       /* 상환일자 */
				  ,UNFR_SFS.RSN_CTS           AS VLT_RSN_CTSL /* 사유 */
			  FROM CCS_SET
				  ,${SCHEMA_NAME}.TSOL_OM_FND_BSC FND_BSC
				  ,${SCHEMA_NAME}.TSOL_FW_USR_BSC USR_BSC_FNMS     /* EFW_사용자기본 운용역 */
				  ,${SCHEMA_NAME}.TSOL_FW_TEM_CD_CTL TEM_CD_CTL    /* 운용역팀코드  */
				  ,${SCHEMA_NAME}.TSOL_FW_CO_CD_DTL DTL_BUY_SLL_TC /*매수매도구분코드*/
				  ,${SCHEMA_NAME}.TSOL_OM_BKR_BSC BKR_BSC          /* 브로커기본 */
				  ,(
					SELECT ORNO
						  ,CKG_HDN_CD
						  ,FND_CD
						  ,ISIN_CD
						  ,FNMN_USID
						  ,RSN_CTS
					  FROM ${SCHEMA_NAME}.TSOL_CP_BD_UNFR_RSN_SFS
					 WHERE IST_CD= #{istCd, jdbcType=VARCHAR}
					   AND AMCO_CD = #{amcoCd, jdbcType=VARCHAR}
					   AND ORD_DT = #{ordDt, jdbcType=VARCHAR}
					 GROUP BY ORNO
							 ,CKG_HDN_CD
							 ,FND_CD
							 ,ISIN_CD
							 ,FNMN_USID
							 ,RSN_CTS
				  ) UNFR_SFS                 /* ECP_채권불공정사유명세 */
				  ,${SCHEMA_NAME}.TSOL_DM_BD_GR_SFS BD_GR      /* EDM_채권등급명세 */
				  ,${SCHEMA_NAME}.TSOL_DM_BD_ITM_SFS BD_ITM    /* EDM_채권종목명세 */
			WHERE 1=1
			  AND #{istCd, jdbcType=VARCHAR} = FND_BSC.IST_CD
			  AND #{amcoCd, jdbcType=VARCHAR} = FND_BSC.AMCO_CD
			  AND CCS_SET.FND_CD = FND_BSC.FND_CD
			  AND CCS_SET.CCS_QTY > 0

			  /* 운용역명 */
			  AND #{istCd, jdbcType=VARCHAR} = USR_BSC_FNMS.IST_CD (+)
			  AND #{amcoCd, jdbcType=VARCHAR} = USR_BSC_FNMS.AMCO_CD (+)
			  AND CCS_SET.FNMN_USID = USR_BSC_FNMS.USID (+)

			  /* 운용역팀코드 */
			  AND #{istCd, jdbcType=VARCHAR} = TEM_CD_CTL.IST_CD (+)
			  AND USR_BSC_FNMS.TEM_CD = TEM_CD_CTL.TEM_CD (+)

			  /* 매수매도구분코드 */
			  AND #{istCd, jdbcType=VARCHAR} = DTL_BUY_SLL_TC.IST_CD (+)
			  AND 'M0300' = DTL_BUY_SLL_TC.CO_CD_ID (+)
			  AND CCS_SET.BUY_SLL_TC = DTL_BUY_SLL_TC.CO_CVA (+)
			  AND 'KO' = DTL_BUY_SLL_TC.LAN_CD (+)

			  /* 브로커기본 */
			  AND #{istCd, jdbcType=VARCHAR} = BKR_BSC.IST_CD (+)
			  AND #{amcoCd, jdbcType=VARCHAR} = BKR_BSC.AMCO_CD (+)
			  AND CCS_SET.BKR_CD = BKR_BSC.BKR_CD (+)

			  /* ECP_채권불공정사유명세 */
			  AND CCS_SET.ORNO = UNFR_SFS.ORNO (+)
			  AND CCS_SET.FND_CD = UNFR_SFS.FND_CD (+)
			  AND CCS_SET.ISIN_CD = UNFR_SFS.ISIN_CD (+)
			  AND CCS_SET.FNMN_USID = UNFR_SFS.FNMN_USID (+)
			  AND UNFR_SFS.CKG_HDN_CD (+) = 'E'

			  /* EDM_채권등급명세 */
			  AND #{istCd, jdbcType=VARCHAR} = BD_GR.IST_CD (+)
			  AND F_BDD_SLS_DT(#{ordDt, jdbcType=VARCHAR}, 1) = BD_GR.BSE_DT(+)
			  AND CCS_SET.ISIN_CD = BD_GR.ISIN_CD (+)

			  /* EDM_채권종목명세 */
			  AND #{istCd, jdbcType=VARCHAR} = BD_ITM.IST_CD
			  AND CCS_SET.ISIN_CD = BD_ITM.ISIN_CD
			) X
	 WHERE X.CAL_STATUS = '1.위반'
	   AND EXISTS (
				  SELECT 1
				    FROM TABLE(F_GET_ATH_FND(#{istCd, jdbcType=VARCHAR}, #{amcoCd, jdbcType=VARCHAR}, #{loginUsid, jdbcType=VARCHAR}, '', '', '', '', '', '')) ATH
				   WHERE ATH.FND_CD = X.FND_CD
		   )
	   <if test='fndCd != null and fndCd != ""'>
	   AND X.FND_CD = #{fndCd, jdbcType=VARCHAR}
	   </if>
	   <if test='itmCd != null and itmCd != ""'>
	   AND X.ITM_CD = #{itmCd, jdbcType=VARCHAR}
	   </if>
	   <if test='fieldCd != null and fieldCd != ""'>
	   AND (
			   SELECT HRK_DPM_ID
			     FROM ${SCHEMA_NAME}.TSOL_FW_DPM_CD_CTL
			    WHERE IST_CD = #{istCd, jdbcType=VARCHAR}
			      AND DPM_CD = (
								SELECT DPM_CD
								  FROM ${SCHEMA_NAME}.TSOL_FW_USR_BSC
								 WHERE IST_CD = #{istCd, jdbcType=VARCHAR}
								   AND AMCO_CD = #{amcoCd, jdbcType=VARCHAR}
								   AND USID = X.FNMN_USID
							   )
		   ) = #{fieldCd, jdbcType=VARCHAR}
	</if>
	 ORDER BY X.ORNO

#ANSI SQL

