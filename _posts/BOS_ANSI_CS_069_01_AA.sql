
WITH CCS_SET AS
	(
		SELECT BD_CCS_BSC.FND_CD
			  ,BD_CCS_BSC.ORNO
			  ,BD_CCS_BSC.ORD_DT
			  ,BD_CCS_BSC.ISIN_CD
			  ,BD_CCS_BSC.BKR_CD
			  ,BD_ITM.ITM_NM
			  ,BD_CCS_BSC.FNMN_USID
			  ,BKR_ITM_TR.TRR_USID
			  ,BD_CCS_BSC.BUY_SLL_TC
			  ,BD_CCS_BSC.KSD_MNG_NO
			  ,MIN(PRG_STA.FNMN_HDER_APV_DTM) AS FNMN_HDER_APV_DTM /* 운용역헤더승인일시 */
			  ,MIN(BKR_ORD_TR.TRR_SHR_DTM) AS TRR_SHR_DTM /* 트레이더배분일시 */
			  ,MIN(BD_CCS_BSC.FST_CCS_DTM) AS FST_CCS_DTM /* 최초체결일시 */
			  ,SUM(NVL_NOA(BD_CCS_BSC.ORD_PAR_AMT, 0)) AS ORD_QTY /* 주문수량(액면)  */
			  ,SUM(NVL_NOA(BD_CCS_BSC.CCS_PAR_AMT, 0)) AS CCS_QTY /* 체결금액  */
			  ,MAX(NVL_NOA(BD_CCS_BSC.CCS_UPR, 0)) AS CCS_UPR /* 체결단가 */
			  ,MAX(NVL_NOA(BD_CCS_BSC.DLN_ROR, 0)) AS CCS_ROR /*매매이율*/
		  FROM ${SCHEMA_NAME}.TSOL_OM_BD_CCS_BSC BD_CCS_BSC /* EOM_채권체결기본 */
			   INNER JOIN ${SCHEMA_NAME}.TSOL_OM_INTG_BKR_ORD_ITM_TR_SFS BKR_ITM_TR /* EOM_통합브로커주문종목거래명세 */
			   ON (/* EOM_통합브로커주문종목거래명세 */
		           BD_CCS_BSC.IST_CD = BKR_ITM_TR.IST_CD
		       AND BD_CCS_BSC.AMCO_CD = BKR_ITM_TR.AMCO_CD
		       AND BD_CCS_BSC.ORD_DT = BKR_ITM_TR.ORD_DT
		       AND BD_CCS_BSC.TR_CD = BKR_ITM_TR.TR_CD
		       AND BD_CCS_BSC.BKR_ITM_ORNO = BKR_ITM_TR.BKR_ITM_ORNO)

			   INNER JOIN ${SCHEMA_NAME}.TSOL_OM_INTG_BKR_ORD_TR_BSC BKR_ORD_TR /* EOM_통합브로커주문거래기본 */
			   ON (/* EOM_통합브로커주문거래기본 */
		           BKR_ITM_TR.IST_CD = BKR_ORD_TR.IST_CD
		       AND BKR_ITM_TR.AMCO_CD = BKR_ORD_TR.AMCO_CD
		       AND BKR_ITM_TR.ORD_DT = BKR_ORD_TR.ORD_DT
		       AND BKR_ITM_TR.TR_CD = BKR_ORD_TR.TR_CD
		       AND BKR_ITM_TR.ORNO = BKR_ORD_TR.ORNO
		       AND BKR_ITM_TR.BKR_ORNO = BKR_ORD_TR.BKR_ORNO)

			   INNER JOIN ${SCHEMA_NAME}.TSOL_OM_INTG_ORD_PRG_STA_SFS PRG_STA /* EOM_통합주문진행상황명세 */
			   ON (/* EOM_통합주문진행상황명세 */
		           BD_CCS_BSC.IST_CD = PRG_STA.IST_CD
		       AND BD_CCS_BSC.AMCO_CD = PRG_STA.AMCO_CD
		       AND BD_CCS_BSC.ORD_DT = PRG_STA.ORD_DT
		       AND BD_CCS_BSC.TR_CD = PRG_STA.TR_CD
		       AND BD_CCS_BSC.ORNO = PRG_STA.ORNO
		       AND 'N' = PRG_STA.DEL_YN)

			   INNER JOIN ${SCHEMA_NAME}.TSOL_DM_BD_ITM_SFS BD_ITM
			   ON (/* */ 
				   BD_CCS_BSC.IST_CD = BD_ITM.IST_CD
		       AND BD_CCS_BSC.ISIN_CD = BD_ITM.ISIN_CD

		       <if test='(itmCls != null and itmCls != "") and itmCls == "4"'>
		       /*그 외*/
		       AND BD_ITM.BD_KD_TC NOT IN ('111100', '111200', '111300', '111350', '111400', '111500', '111600', '111700', '111800', '411000', '113100')
		       </if>

		       <if test='(itmCls != null and itmCls != "") and itmCls == "2"'>
		       /*국채*/
		       AND BD_ITM.BD_KD_TC IN ('111100', '111200', '111300', '111350', '111400', '111500', '111600', '111700', '111800', '411000')
		       </if>

		       <if test='(itmCls != null and itmCls != "") and itmCls == "3"'>
		       /*통안채*/
		       AND BD_ITM.BD_KD_TC = '113100'
		       </if>)

		 WHERE 1 = 1
		   /* EOM_채권체결기본 */
		   AND BD_CCS_BSC.IST_CD = #{istCd, jdbcType=VARCHAR}
		   AND BD_CCS_BSC.ORD_DT BETWEEN #{shrFrom, jdbcType=VARCHAR} AND #{shrTo, jdbcType=VARCHAR}
		   AND BD_CCS_BSC.AMCO_CD = #{amcoCd, jdbcType=VARCHAR}
		   AND BD_CCS_BSC.TR_CD = '301'
		   AND BD_CCS_BSC.DEL_YN = 'N'
		   
		   <if test='fnmnId != null and fnmnId != ""'>
		   AND BD_CCS_BSC.FNMN_USID = #{fnmnId, jdbcType=VARCHAR}
		   </if>

		   <if test='itmCd != null and itmCd != ""'>
		   AND BD_CCS_BSC.ISIN_CD = #{itmCd, jdbcType=VARCHAR}
		   </if>

		   <if test='mgmtFildCd != null and mgmtFildCd != ""'>
		   AND (
				   SELECT HRK_DPM_ID
				     FROM ${SCHEMA_NAME}.TSOL_FW_DPM_CD_CTL
				    WHERE IST_CD = #{istCd, jdbcType=VARCHAR}
				   AND DPM_CD = (
								   SELECT DPM_CD
								     FROM ${SCHEMA_NAME}.TSOL_FW_USR_BSC
								    WHERE IST_CD = #{istCd, jdbcType=VARCHAR}
								      AND USID = ITM_TR.FNMN_USID
							    )
			   )= #{mgmtFildCd, jdbcType=VARCHAR}
		   </if>
		 GROUP BY BD_CCS_BSC.FND_CD,
				  BD_CCS_BSC.ORNO,
				  BD_CCS_BSC.ORD_DT,
				  BD_CCS_BSC.ISIN_CD,
				  BD_CCS_BSC.BKR_CD,
				  BD_ITM.ITM_NM,
				  BD_CCS_BSC.FNMN_USID,
				  BKR_ITM_TR.TRR_USID,
				  BD_CCS_BSC.BUY_SLL_TC,
				  BD_CCS_BSC.KSD_MNG_NO
	),SMLT_CRS AS
	(
	SELECT CCS_SET.ISIN_CD             AS ITM_CD
		  ,CCS_SET.ITM_NM
		  ,CCS_SET.ORD_DT
		  ,CCS_SET.BUY_SLL_TC
		  ,DTL_BUY_SLL_TC.CO_CVA_NM  AS BUY_SLL_NM /* 매수매도구분 */
		  ,CCS_SET.ORNO
		  ,CCS_SET.FND_CD
		  ,FND_BSC.FND_NM
		  ,CCS_SET.FNMN_USID
		  ,USR_BSC_FNMS.USR_NM       AS FNMN_USR_NM  /* 운용역사용자명 */
		  ,CCS_SET.TRR_USID
		  ,USR_BSC_TRR.USR_NM        AS TRR_USR_NM	/*트레이더명*/
		  ,CCS_SET.BKR_CD
		  ,BKR_BSC.BKR_NM            AS BKR_NM       /* 브로커명 */
		  ,CCS_SET.CCS_QTY           AS CCS_PAR_AMT  /* 체결금액 */
		  ,CCS_SET.CCS_UPR           AS CCS_UPR      /* 체결단가 */
		  ,CCS_SET.CCS_ROR           AS TR_IRRT      /* 거래이율 */
		  ,BD_GR.LST_YTM             AS MKT_IRRT     /* 시장이율 */
		  ,TO_CHAR_NOA(CCS_SET.FNMN_HDER_APV_DTM, 'HH24:MI:SS') AS ORD_HR /*주문시간*/
		  ,TO_CHAR_NOA(CCS_SET.FST_CCS_DTM, 'HH24:MI:SS')       AS CCS_HR /*체결시간*/
	  FROM CCS_SET
		   LEFT OUTER JOIN ${SCHEMA_NAME}.TSOL_OM_FND_BSC FND_BSC
		   ON (#{istCd, jdbcType=VARCHAR} = FND_BSC.IST_CD
	       AND #{amcoCd, jdbcType=VARCHAR} = FND_BSC.AMCO_CD
	       AND CCS_SET.FND_CD = FND_BSC.FND_CD)

		   LEFT OUTER JOIN ${SCHEMA_NAME}.TSOL_FW_USR_BSC USR_BSC_FNMS      /* 사용자기본 운용역 */
		   ON (/* 운용역명 */
	           #{istCd, jdbcType=VARCHAR} = USR_BSC_FNMS.IST_CD
	       AND #{amcoCd, jdbcType=VARCHAR} = USR_BSC_FNMS.AMCO_CD
	       AND CCS_SET.FNMN_USID = USR_BSC_FNMS.USID)

		   LEFT OUTER JOIN ${SCHEMA_NAME}.TSOL_FW_USR_BSC USR_BSC_TRR		 /*사용자기본 트레이더*/
		   ON (/* 트레이더명 */
	           #{istCd, jdbcType=VARCHAR} = USR_BSC_TRR.IST_CD
	       AND #{amcoCd, jdbcType=VARCHAR} = USR_BSC_TRR.AMCO_CD
	       AND CCS_SET.TRR_USID = USR_BSC_TRR.USID)

		   LEFT OUTER JOIN ${SCHEMA_NAME}.TSOL_FW_TEM_CD_CTL TEM_CD_CTL     /* 운용역팀코드  */
		   ON (/* 운용역팀코드 */
	           #{istCd, jdbcType=VARCHAR} = TEM_CD_CTL.IST_CD
	       AND USR_BSC_FNMS.TEM_CD = TEM_CD_CTL.TEM_CD)

		   LEFT OUTER JOIN ${SCHEMA_NAME}.TSOL_FW_CO_CD_DTL DTL_BUY_SLL_TC  /* 매수매도구분코드 */
		   ON (/* 매수매도구분코드 */
	           #{istCd, jdbcType=VARCHAR} = DTL_BUY_SLL_TC.IST_CD
	       AND 'M0300' = DTL_BUY_SLL_TC.CO_CD_ID
	       AND CCS_SET.BUY_SLL_TC = DTL_BUY_SLL_TC.CO_CVA
	       AND 'KO' = DTL_BUY_SLL_TC.LAN_CD)
		  
		   LEFT OUTER JOIN ${SCHEMA_NAME}.TSOL_OM_BKR_BSC BKR_BSC           /* 브로커기본 */
		   ON (/* 브로커기본 */
	           #{istCd, jdbcType=VARCHAR} = BKR_BSC.IST_CD
	       AND #{amcoCd, jdbcType=VARCHAR} = BKR_BSC.AMCO_CD
	       AND CCS_SET.BKR_CD = BKR_BSC.BKR_CD)
		   
		   LEFT OUTER JOIN ${SCHEMA_NAME}.TSOL_DM_BD_GR_SFS BD_GR           /* EDM_채권등급명세 */
		   ON (/* EDM_채권등급명세 */
	           #{istCd, jdbcType=VARCHAR} = BD_GR.IST_CD
	       AND TO_CHAR_NOA(DATE_CAL_NOA(TO_DATE_NOA(CCS_SET.ORD_DT,'YYYYMMDD'),-1),'YYYYMMDD') = BD_GR.BSE_DT
	       AND CCS_SET.ISIN_CD = BD_GR.ISIN_CD)

	WHERE 1=1
	  AND CCS_SET.ORD_QTY > 0	/*전량취소가 되지 않은 것*/
	  
	  <if test='abrRng != null and abrRng != ""'>
	  <![CDATA[
	  AND ABS(CCS_SET.CCS_ROR - BD_GR.LST_YTM) <= (#{abrRng, jdbcType=NUMERIC}/100)
	  ]]>
	  </if>
	  AND EXISTS(
				  SELECT 1
				    FROM CCS_SET A
				   WHERE A.ISIN_CD = CCS_SET.ISIN_CD
				     AND A.ORD_DT = CCS_SET.ORD_DT
				     AND A.BUY_SLL_TC = (
										  CASE WHEN CCS_SET.BUY_SLL_TC = 'B' THEN 'S'
										  WHEN CCS_SET.BUY_SLL_TC = 'S' THEN 'B'
										  END
										)
				     <if test='fnmnId != null and fnmnId != ""'>
				     AND A.FNMN_USID = CCS_SET.FNMN_USID
				     </if>
				     <if test='itmCd != null and itmCd != ""'>
				     AND A.ISIN_CD = CCS_SET.ISIN_CD
				     </if>

				     <if test='smeTrQty == "1"'>
				     AND A.CCS_QTY = CCS_SET.CCS_QTY
				     </if>
				     <if test='smeBkr == "1"'>
				     AND A.BKR_CD = CCS_SET.BKR_CD
				     </if>
				     <if test='smeCcsUpr == "1"'>
				     AND A.CCS_UPR = CCS_SET.CCS_UPR
				     </if>
				)
	)
	SELECT X.*
	FROM (
			SELECT ITM_CD
				  ,ITM_NM
				  ,ORD_DT
				  ,'' AS BUY_SLL_TC
				  ,'' AS BUY_SLL_NM
				  ,'' AS ORNO
				  ,'' AS FND_CD
				  ,'' AS FND_NM
				  ,'' AS FNMN_USID
				  ,'' AS FNMN_USR_NM
				  ,'' AS TRR_USID
				  ,'' AS TRR_USR_NM
				  ,'' AS BKR_CD
				  ,'' AS BKR_NM
				  ,0 AS CCS_PAR_AMT
				  ,0 AS CCS_UPR
				  ,0 AS TR_IRRT
				  ,0 AS MKT_IRRT
				  ,'' AS ORD_HR
				  ,'' AS CCS_HR
				  ,'1' AS LVL
			  FROM SMLT_CRS
			 GROUP BY ITM_CD, ITM_NM, ORD_DT
			UNION ALL
			SELECT ITM_CD
				  ,ITM_NM
				  ,ORD_DT
				  ,BUY_SLL_TC
				  ,BUY_SLL_NM
				  ,TO_CHAR_NOA(ORNO) AS ORNO
				  ,FND_CD
				  ,FND_NM
				  ,FNMN_USID
				  ,FNMN_USR_NM
				  ,TRR_USID
				  ,TRR_USR_NM
				  ,BKR_CD
				  ,BKR_NM
				  ,CCS_PAR_AMT
				  ,CCS_UPR
				  ,(TR_IRRT * 100) AS TR_IRRT
				  ,(MKT_IRRT * 100) AS MKT_IRRT
				  ,ORD_HR
				  ,CCS_HR
				  ,'2' AS LVL
			  FROM SMLT_CRS
		 ) X
	 WHERE 1=1
	 <if test='filterList != null and filterList != ""'>
	   ${filterList}
	 </if>
	 <choose>
	 	<when test='sortList != null and sortList != ""'>
	 ORDER BY X.ORD_DT, X.ITM_CD, X.LVL, X.ORNO${sortList}
	 	</when>
	 	<otherwise>
	 ORDER BY X.ORD_DT, X.ITM_CD, X.LVL, X.ORNO
	 	</otherwise>
	 </choose>
