
SELECT X.CKG_HDN_CLS_NM
		  ,X.CKG_HDN_CD
		  ,X.FND_CD
		  ,X.PUBO_PSS_NM
		  ,X.FND_NM
		  ,X.ITM_CD
		  ,X.ITM_NM
		  ,X.TR_NM
		  ,X.BD_GR_LLT
		  ,X.CUR_EDF_GR
		<![CDATA[
		  ,CASE WHEN X.BD_GR_LLT_PIT > X.CUR_EDF_PIT THEN 'Y'
		  		ELSE 'N'
		  		 END AS VLT_TC
		  ]]>
		  ,X.DPM_NM
		  ,X.USR_NM
	  FROM (
			SELECT (
					SELECT CO_CVA_NM
					  FROM ${SCHEMA_NAME}.TSOL_FW_CO_CD_DTL
					 WHERE IST_CD = A.IST_CD
					   AND CO_CD_ID = 'M0150'
					   AND LAN_CD = 'KO'
					   AND CO_CVA = (
										SELECT CKG_HDN_CLS_TC
										  FROM ${SCHEMA_NAME}.TSOL_CP_CKG_HDN_BSC
										 WHERE IST_CD = A.IST_CD
										   AND AMCO_CD = A.AMCO_CD
										   AND CKG_HDN_CD = A.CKG_HDN_CD
									)
				   ) AS CKG_HDN_CLS_NM	/*점검항목분류(법규구분)*/
				  ,A.CKG_HDN_CD	/*점검항목코드*/
				  ,A.FND_CD	/*펀드코드*/
				  ,(
					SELECT CO_CVA_NM
					  FROM ${SCHEMA_NAME}.TSOL_FW_CO_CD_DTL
					 WHERE IST_CD = A.IST_CD
					   AND CO_CD_ID = 'M0309'
					   AND LAN_CD = 'KO'
					   AND CO_CVA = (
										SELECT PUBO_PSS_TC
										  FROM ${SCHEMA_NAME}.TSOL_OM_FND_BSC
										 WHERE IST_CD = A.IST_CD
										   AND AMCO_CD = A.AMCO_CD
										   AND FND_CD = A.FND_CD
									)
				   ) AS PUBO_PSS_NM	/*공모/사모*/
				  ,(
					SELECT FND_NM
					  FROM ${SCHEMA_NAME}.TSOL_OM_FND_BSC
					 WHERE IST_CD = A.IST_CD
					   AND AMCO_CD = A.AMCO_CD
					   AND FND_CD = A.FND_CD
				   ) AS FND_NM	/*펀드명*/
				  ,B.PRD_NO AS ITM_CD	/*종목코드*/
				  ,CASE WHEN B.PRD_TP_ID = '101' THEN (
														SELECT STN_ITM_NM AS ITM_NM
														  FROM ${SCHEMA_NAME}.TSOL_DM_STK_ITM_SFS
														 WHERE IST_CD = A.IST_CD
														   AND ISIN_CD = B.PRD_NO
													  )
						WHEN B.PRD_TP_ID = '301' THEN (
														SELECT ITM_NM
														  FROM ${SCHEMA_NAME}.TSOL_DM_BD_ITM_SFS
														 WHERE IST_CD = A.IST_CD
														   AND ISIN_CD = B.PRD_NO
													  )
						 END AS ITM_NM	/*종목명*/
				  ,B.PRD_TP_ID AS TR_CD	/*거래코드*/
				  ,(
				  	SELECT TR_CD_NM
				  	  FROM ${SCHEMA_NAME}.TSOL_OM_AST_TR_CD_CTL
				  	 WHERE IST_CD = A.IST_CD
				  	   AND TR_CD = B.PRD_TP_ID
				   ) AS TR_NM	/*거래명*/
				  ,(
					SELECT DPM_CD
					  FROM ${SCHEMA_NAME}.TSOL_FW_USR_BSC
					 WHERE IST_CD = A.IST_CD
					   AND USID = C.USID
				   ) AS DPM_CD
				  ,(
					SELECT DPM_NM
					  FROM ${SCHEMA_NAME}.TSOL_FW_DPM_CD_CTL
					 WHERE IST_CD = A.IST_CD
					   AND DPM_CD = (
										SELECT DPM_CD
										  FROM ${SCHEMA_NAME}.TSOL_FW_USR_BSC
										 WHERE IST_CD = A.IST_CD
										   AND USID = C.USID
									)
				   ) AS DPM_NM
				  ,C.USID	/*사용자ID(책임운용역)*/
				  ,(
					SELECT USR_NM
					  FROM ${SCHEMA_NAME}.TSOL_FW_USR_BSC
					 WHERE IST_CD = A.IST_CD
					   AND AMCO_CD = A.AMCO_CD
					   AND USID = C.USID
				   ) AS USR_NM	/*사용자(책임운용역)*/
				  ,A.BD_GR_LLT 	/*채권등급하한*/
				  ,A.BD_GR_LLT_PIT	/*채권등급하한점수*/
				  ,CASE WHEN B.PRD_TP_ID = '101' THEN (
				  										SELECT EDF_CRD_CD
														  FROM ${SCHEMA_NAME}.TSOL_IF_DW_KRM_EDF
														 WHERE BASE_DT = (
																			SELECT MAX(BASE_DT)
																			  FROM ${SCHEMA_NAME}.TSOL_IF_DW_KRM_EDF
																		 )
														   AND SHORT_NO = (
																			SELECT KSC_CD
																			  FROM ${SCHEMA_NAME}.TSOL_DM_STK_ITM_SFS
																			 WHERE IST_CD = A.IST_CD
																			   AND ISIN_CD = B.PRD_NO
														   				  )
													  )
						WHEN B.PRD_TP_ID = '301' THEN (
														SELECT EDF_CRD_CD
														  FROM ${SCHEMA_NAME}.TSOL_IF_DW_KRM_EDF
														 WHERE BASE_DT = (
																			SELECT MAX(BASE_DT)
																			  FROM ${SCHEMA_NAME}.TSOL_IF_DW_KRM_EDF
																		 )
														   AND KSC_CODE = (
																			SELECT KSC_PUB_IST_CD
																			  FROM ${SCHEMA_NAME}.TSOL_DM_BD_ITM_SFS
																			 WHERE IST_CD = A.IST_CD
																			   AND ISIN_CD = B.PRD_NO
														   				  )
													  )
						 END AS CUR_EDF_GR
				  ,CASE WHEN B.PRD_TP_ID = '101' THEN (
				  										SELECT HRK_CO_CVA
														  FROM ${SCHEMA_NAME}.TSOL_FW_CO_CD_DTL
														 WHERE IST_CD = A.IST_CD
														   AND CO_CD_ID = 'M0356'
														   AND LAN_CD = 'KO'
														   AND CO_CVA = (
																			SELECT EDF_CRD_CD
																			  FROM ${SCHEMA_NAME}.TSOL_IF_DW_KRM_EDF
																			 WHERE BASE_DT = (
																								SELECT MAX(BASE_DT)
																								  FROM ${SCHEMA_NAME}.TSOL_IF_DW_KRM_EDF
																							 )
																			   AND SHORT_NO = (
																								SELECT KSC_CD
																								  FROM ${SCHEMA_NAME}.TSOL_DM_STK_ITM_SFS
																								 WHERE IST_CD = A.IST_CD
																								   AND ISIN_CD = B.PRD_NO
																			   				  )
																		)
													  )
						WHEN B.PRD_TP_ID = '301' THEN (
														SELECT HRK_CO_CVA
														  FROM ${SCHEMA_NAME}.TSOL_FW_CO_CD_DTL
														 WHERE IST_CD = A.IST_CD
														   AND CO_CD_ID = 'M0356'
														   AND LAN_CD = 'KO'
														   AND CO_CVA = (
																			SELECT EDF_CRD_CD
																			  FROM ${SCHEMA_NAME}.TSOL_IF_DW_KRM_EDF
																			 WHERE BASE_DT = (
																								SELECT MAX(BASE_DT)
																								  FROM ${SCHEMA_NAME}.TSOL_IF_DW_KRM_EDF
																							 )
																			   AND KSC_CODE = (
																								SELECT KSC_PUB_IST_CD
																								  FROM ${SCHEMA_NAME}.TSOL_DM_BD_ITM_SFS
																								 WHERE IST_CD = A.IST_CD
																								   AND ISIN_CD = B.PRD_NO
																			   				  )
																		)
													  )
						 END AS CUR_EDF_PIT
			  FROM ${SCHEMA_NAME}.TSOL_CP_CKG_HDN_FND_MPN_SFS A
				  ,${SCHEMA_NAME}.TSOL_CR_PT_TLZ_BSC B
				  ,(
					SELECT IST_CD
						  ,AMCO_CD
						  ,FND_CD
						  ,MAX(USID) AS USID	/*책임운용역이 여러명일 경우 MAX*/
						  ,TR_CD
					  FROM ${SCHEMA_NAME}.TSOL_OM_USR_FND_ATH_SFS
					 WHERE IST_CD = #{istCd, jdbcType=VARCHAR}
					   AND AMCO_CD = #{amcoCd, jdbcType=VARCHAR}
					   AND MGMT_CLS_TC = '1'
					   <if test='usid == null and usid == ""'>
					   AND MGMT_CLS_TC = '1'	/*책임*/
					   </if>
					   <if test='usid != null and usid != ""'>
					   AND USID = #{usid, jdbcType=VARCHAR}
					   </if>
					   <if test='ogzCd != null and ogzCd != ""'>
					   AND USID IN (
					   				SELECT USID
					   				  FROM ${SCHEMA_NAME}.TSOL_FW_USR_BSC
					   				 WHERE IST_CD = #{istCd, jdbcType=VARCHAR}
					   				   AND AMCO_CD = #{amcoCd, jdbcType=VARCHAR}
					   				   <choose>
									   	<when test='ogzTc == "26"'>
									   /*팀코드*/
									   AND TEM_CD = #{ogzCd, jdbcType=VARCHAR}
									   	</when>
									   	<when test='ogzTc == "01"'>
									   /*본부코드*/
									   AND HDQ_CD = #{ogzCd, jdbcType=VARCHAR}
									   	</when>
									   	<when test='ogzTc == "24"'>
									   /*부문코드*/
									   AND FILD_CD = #{ogzCd, jdbcType=VARCHAR}
									   	</when>
									   	<when test='ogzTc == "20"'>
									   /*총괄코드*/
									   AND SUMZ_CD = #{ogzCd, jdbcType=VARCHAR}
									   	</when>
									   </choose>
					   			   )
					   </if>
					   AND #{bseDt, jdbcType=VARCHAR} BETWEEN MGMT_STT_DT AND MGMT_END_DT
					   AND ATH_USE_YN = 'Y'
					 GROUP BY IST_CD, AMCO_CD, FND_CD, TR_CD
				   ) C
			 WHERE A.IST_CD = #{istCd, jdbcType=VARCHAR}
			   AND A.AMCO_CD = #{amcoCd, jdbcType=VARCHAR}
			   AND A.CKG_HDN_CD = 'CPAL007B01'	/*EDF등급 (채권신용등급하한) 이상 투자가능*/
			   AND A.IST_CD = B.IST_CD
			   AND B.PT_BSE_DT = #{bseDt, jdbcType=VARCHAR}
			   AND B.AC_MNG_GRP_ID = 'OMSCL'
			   AND B.PRD_TP_ID IN ('101', '301', '302')
			   AND A.AMCO_CD = B.POF_ID
			   AND A.FND_CD = B.PT_TLZ_ID
			   AND A.IST_CD = C.IST_CD
			   AND A.AMCO_CD = C.AMCO_CD
			   AND A.FND_CD = C.FND_CD
			   AND B.PRD_TP_ID = C.TR_CD
			   AND EXISTS (
						    SELECT 1
						      FROM TABLE(F_GET_ATH_FND(#{istCd,  jdbcType=VARCHAR}, #{amcoCd, jdbcType=VARCHAR}, #{loginUsid, jdbcType=VARCHAR}, '', '', '', '', '', '')) ATH
						     WHERE ATH.FND_CD = A.FND_CD
						  )
			   <if test='fndCd != null and fndCd != ""'>
			   AND A.FND_CD = #{fndCd, jdbcType=VARCHAR}
			   </if>
	  	   ) X
	 WHERE 1=1
	   <if test='edfGr != null and edfGr != ""'>
	   AND X.CUR_EDF_GR = #{edfGr, jdbcType=VARCHAR}
	   </if>
	   <if test='vltTc != null and vltTc != ""'>
	   <![CDATA[
	   AND (
	   		CASE WHEN X.BD_GR_LLT_PIT > X.CUR_EDF_PIT THEN 'Y'
		  		 ELSE 'N'
		  		  END
		   ) = #{vltTc, jdbcType=VARCHAR}
		]]>
	   </if>
