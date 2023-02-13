
WITH CCS_SET AS
      (
        SELECT
           FND_CCS_ALCN.FND_CD
          , FND_CCS_ALCN.ORNO
          , ORD_TR.ORD_NM
          , ORD_TR.TR_CD
          , FND_CCS_ALCN.ORD_DT
          , FND_CCS_ALCN.BKR_CD
          , ITM_TR.FNMN_USID
          , MIN(PRG_STA.ORD_APV_REQ_DTM)    AS ORD_APV_REQ_DTM    /* 주문승인요청시간 */
          , MIN(PRG_STA.FNMN_HDER_USID)     AS FNMN_HDER_USID     /* 주문승인자ID */
          , MIN(PRG_STA.FNMN_HDER_APV_TC)	AS FNMN_HDER_APV_TC   /* 운용역헤더승인구분 */
          , MIN(PRG_STA.FNMN_HDER_APV_DTM)  AS FNMN_HDER_APV_DTM  /* 운용역헤더승인일시 */
          , MIN(PRG_STA.FNMN_HDER_USR_IP)   AS FNMN_HDER_USR_IP   /* 운용역헤더승인IP */
          , MIN(BKR_ORD_TR.TRR_USID)        AS TRR_USID           /* 트레이더배정자 */
          , MIN(BKR_ORD_TR.TRR_SHR_DTM)     AS TRR_SHR_DTM        /* 트레이더배분일시 */
          , MIN(BKR_ORD_TR.FST_ENR_IP)      AS TRR_USR_IP         /* 매매실행IP */
          , MIN(CASE WHEN FND_CCS_ALCN.TR_CD IN ('301')
                THEN BD_CCS_BSC.FST_CCS_DTM
                ELSE BKR_ITM_TR.FST_CCS_DTM END) AS FST_CCS_DTM   /* 최초체결일시 */
          <!-- 추가 -->
          , (CASE WHEN FNMN_HDER_USR_IP = MIN(BKR_ORD_TR.FST_ENR_IP) THEN 'Y'
				ELSE 'N'
				END)                        AS SRT_VLT            /* 분리위반여부 */
		  , CASE WHEN (TO_CHAR(MIN(PRG_STA.FNMN_HDER_APV_DTM), 'HH24:MI:SS') > TO_CHAR(MIN(BKR_ORD_TR.TRR_SHR_DTM), 'HH24:MI:SS')
                       OR
                       TO_CHAR(MIN(BKR_ORD_TR.TRR_SHR_DTM), 'HH24:MI:SS') > TO_CHAR(BD_CCS_BSC.FST_CCS_DTM, 'HH24:MI:SS')
                       OR
                       TO_CHAR(MIN(PRG_STA.FNMN_HDER_APV_DTM), 'HH24:MI:SS') > TO_CHAR(BD_CCS_BSC.FST_CCS_DTM, 'HH24:MI:SS')
                      ) THEN 'Y'
            ELSE 'N'
            END                             AS TR_PCDR_VLT        /* 거래절차여부 */

        FROM ${SCHEMA_NAME}.TSOL_OM_INTG_ORD_FND_CCS_ALCN_SFS FND_CCS_ALCN /* EOM_통합주문펀드체결배분명세 */
          ,${SCHEMA_NAME}.TSOL_OM_INTG_ORD_ITM_TR_SFS ITM_TR               /* EOM_통합주문종목거래명세 */
          ,${SCHEMA_NAME}.TSOL_OM_INTG_BKR_ORD_TR_BSC BKR_ORD_TR           /* EOM_통합브로커주문거래기본 */
          ,${SCHEMA_NAME}.TSOL_OM_INTG_ORD_PRG_STA_SFS PRG_STA             /* EOM_통합주문진행상황명세 */
          ,${SCHEMA_NAME}.TSOL_OM_INTG_ORD_TR_BSC ORD_TR                   /* EOM_통합주문거래기본 */
          ,${SCHEMA_NAME}.TSOL_OM_INTG_BKR_ORD_ITM_TR_SFS BKR_ITM_TR       /* EOM_통합브로커주문종목거래명세 */
          ,${SCHEMA_NAME}.TSOL_OM_BD_CCS_BSC BD_CCS_BSC                    /* EOM_채권체결기본 */

        WHERE 1=1
         /* EOM_통합주문펀드체결배분명세 */
          AND FND_CCS_ALCN.IST_CD = #{istCd,jdbcType=VARCHAR}
          AND FND_CCS_ALCN.ORD_DT BETWEEN #{fromOrdDt,jdbcType=VARCHAR} AND #{toOrdDt,jdbcType=VARCHAR}
          AND FND_CCS_ALCN.AMCO_CD = #{amcoCd,jdbcType=VARCHAR}
          AND FND_CCS_ALCN.DEL_YN = 'N'

          <if test='astCd == "A"'>
          	<choose>
          		<when test='hbrdCd == "1"'>
          AND FND_CCS_ALCN.TR_CD IN ('101', '301', '302', '201', '202', '203', '204', '205', '206')
          		</when>
          		<when test='hbrdCd == "2"'>
          AND FND_CCS_ALCN.TR_CD IN ('401', '402', '501', '508', '509')
          		</when>
          		<otherwise>
          AND FND_CCS_ALCN.TR_CD IN ('101', '401', '301', '402', '302', '201', '202', '203', '204', '205', '206', '501', '508', '509')
          		</otherwise>
          	</choose>
          </if>

          <if test='astCd == "S"'>
          	<choose>
          		<when test='hbrdCd == "1"'>
          AND FND_CCS_ALCN.TR_CD = '101'
          		</when>
          		<when test='hbrdCd == "2"'>
          AND FND_CCS_ALCN.TR_CD = '401'
          		</when>
          		<otherwise>
          AND FND_CCS_ALCN.TR_CD IN ('101', '401')
          		</otherwise>
          	</choose>
          </if>

          <if test='astCd == "B"'>
          	<choose>
          		<when test='hbrdCd == "1"'>
          AND FND_CCS_ALCN.TR_CD = '301'
          		</when>
          		<when test='hbrdCd == "2"'>
          AND FND_CCS_ALCN.TR_CD = '402'
          		</when>
          		<otherwise>
          AND FND_CCS_ALCN.TR_CD IN ('301', '402')
          		</otherwise>
          	</choose>
          </if>

          <if test='astCd == "C"'>
          AND FND_CCS_ALCN.TR_CD = '302'
          </if>

          <if test='astCd == "D"'>
          	<choose>
          		<when test='hbrdCd == "1"'>
          AND FND_CCS_ALCN.TR_CD IN ('201', '202', '203', '204', '205', '206')
          		</when>
          		<when test='hbrdCd == "2"'>
          AND FND_CCS_ALCN.TR_CD IN ('501', '508', '509')
          		</when>
          		<otherwise>
          AND FND_CCS_ALCN.TR_CD IN ('201', '202', '203', '204', '205', '206', '501', '508', '509')
          		</otherwise>
          	</choose>
          </if>

        /* EOM_통합주문거래기본 */
        AND FND_CCS_ALCN.IST_CD = ORD_TR.IST_CD
        AND FND_CCS_ALCN.AMCO_CD = ORD_TR.AMCO_CD
        AND FND_CCS_ALCN.ORD_DT = ORD_TR.ORD_DT
        AND FND_CCS_ALCN.TR_CD = ORD_TR.TR_CD
        AND FND_CCS_ALCN.ORNO = ORD_TR.ORNO

        /* EOM_통합주문종목거래명세 */
        AND FND_CCS_ALCN.IST_CD = ITM_TR.IST_CD
        AND FND_CCS_ALCN.AMCO_CD = ITM_TR.AMCO_CD
        AND FND_CCS_ALCN.ORD_DT = ITM_TR.ORD_DT
        AND FND_CCS_ALCN.TR_CD = ITM_TR.TR_CD
        AND FND_CCS_ALCN.ITM_ORNO = ITM_TR.ITM_ORNO
        AND 'N' = ITM_TR.CCL_TC

        /* EOM_채권체결기본 */
        AND FND_CCS_ALCN.IST_CD = BD_CCS_BSC.IST_CD (+)
        AND FND_CCS_ALCN.AMCO_CD = BD_CCS_BSC.AMCO_CD (+)
        AND FND_CCS_ALCN.ORD_DT = BD_CCS_BSC.ORD_DT (+)
        AND FND_CCS_ALCN.TR_CD = BD_CCS_BSC.TR_CD (+)
        AND FND_CCS_ALCN.FND_CD = BD_CCS_BSC.FND_CD (+)
        AND FND_CCS_ALCN.BKR_ITM_ORNO = BD_CCS_BSC.BKR_ITM_ORNO (+)
        AND 'N' = BD_CCS_BSC.DEL_YN (+)

        /* EOM_통합브로커주문거래기본 */
        AND FND_CCS_ALCN.IST_CD = BKR_ORD_TR.IST_CD
        AND FND_CCS_ALCN.AMCO_CD = BKR_ORD_TR.AMCO_CD
        AND FND_CCS_ALCN.ORD_DT = BKR_ORD_TR.ORD_DT
        AND FND_CCS_ALCN.TR_CD = BKR_ORD_TR.TR_CD
        AND FND_CCS_ALCN.ORNO = BKR_ORD_TR.ORNO
        AND FND_CCS_ALCN.BKR_ORNO = BKR_ORD_TR.BKR_ORNO

        /* EOM_통합브로커주문종목거래명세 */
        AND FND_CCS_ALCN.IST_CD = BKR_ITM_TR.IST_CD
        AND FND_CCS_ALCN.AMCO_CD = BKR_ITM_TR.AMCO_CD
        AND FND_CCS_ALCN.ORD_DT = BKR_ITM_TR.ORD_DT
        AND FND_CCS_ALCN.TR_CD = BKR_ITM_TR.TR_CD
        AND FND_CCS_ALCN.BKR_ITM_ORNO = BKR_ITM_TR.BKR_ITM_ORNO

        /* EOM_통합주문진행상황명세 */
        AND FND_CCS_ALCN.IST_CD = PRG_STA.IST_CD
        AND FND_CCS_ALCN.AMCO_CD = PRG_STA.AMCO_CD
        AND FND_CCS_ALCN.ORD_DT = PRG_STA.ORD_DT
        AND FND_CCS_ALCN.TR_CD = PRG_STA.TR_CD
        AND FND_CCS_ALCN.ORNO = PRG_STA.ORNO
        AND 'N' = PRG_STA.DEL_YN
        AND EXISTS (
				    SELECT 1
				      FROM TABLE(F_GET_ATH_FND(#{istCd,  jdbcType=VARCHAR}, #{amcoCd, jdbcType=VARCHAR}, #{usid, jdbcType=VARCHAR}, '', '', '', '', '', '')) ATH
				     WHERE ATH.FND_CD = FND_CCS_ALCN.FND_CD
				   )
        GROUP BY
           FND_CCS_ALCN.FND_CD
          , FND_CCS_ALCN.ORNO
          , ORD_TR.ORD_NM
          , ORD_TR.TR_CD
          , FND_CCS_ALCN.ORD_DT
          , FND_CCS_ALCN.BKR_CD
          , ITM_TR.FNMN_USID
          , PRG_STA.FNMN_HDER_USR_IP
          , PRG_STA.FNMN_HDER_APV_DTM
          , BKR_ORD_TR.TRR_SHR_DTM
          , BD_CCS_BSC.FST_CCS_DTM
      )

      SELECT
         CCS_SET.ORD_DT
        , AST_TR_CD.TR_CD_NM                               AS TR_NM              /* 자산명 */
        , USR_BSC_FNMS.TEM_CD
        , TEM_CD_CTL.TEM_NM                                                     /* 운용역팀코드명 */
        , CCS_SET.ORNO
        , CCS_SET.ORD_NM
        , CCS_SET.FNMN_USID                                AS US_ID              /* 사용자ID */
        , USR_BSC_FNMS.USR_NM                              AS FNMN_USR_NM        /* 운용역사용자명 */
        , CCS_SET.SRT_VLT
        , CCS_SET.TR_PCDR_VLT
        , TO_CHAR(CCS_SET.ORD_APV_REQ_DTM, 'HH24:MI:SS')   AS ORD_APV_REQ_HR     /* 주문승인요청시간 */
        , CCS_SET.FNMN_HDER_USID                           AS ORD_APV_USR_NM     /* 주문승인자ID */
        , CCS_SET.FNMN_HDER_APV_TC                         AS ORD_APV_YN         /* 운용역헤더승인구분 */
        , TO_CHAR(CCS_SET.FNMN_HDER_APV_DTM, 'HH24:MI:SS') AS ORD_APV_HR         /* 운용역헤더승인일시 */
        , CCS_SET.FNMN_HDER_USR_IP                         AS ORD_APV_IP         /* 운용역헤더승인IP */

        , CCS_SET.TRR_USID                                 AS SHR_USR_NM         /* 트레이더배정자 */
        , TO_CHAR(CCS_SET.TRR_SHR_DTM, 'HH24:MI:SS')       AS SHR_HR             /* 트레이더배분일시 */
        , CCS_SET.TRR_USR_IP                               AS SHR_IP             /* 매매실행IP */
        , TO_CHAR(CCS_SET.FST_CCS_DTM, 'HH24:MI:SS')       AS CCS_HR             /* 최초체결일시 */
        , CCS_SET.BKR_CD
        , BKR_BSC.BKR_NM                                   AS BKR_NM             /* 브로커명 */
        , CCS_SET.FND_CD
        , FND_BSC.FND_NM

      FROM CCS_SET
        , ${SCHEMA_NAME}.TSOL_OM_FND_BSC FND_BSC
        , ${SCHEMA_NAME}.TSOL_FW_USR_BSC USR_BSC_FNMS    /* EFW_사용자기본 운용역 */
        , ${SCHEMA_NAME}.TSOL_FW_TEM_CD_CTL TEM_CD_CTL   /* 운용역팀코드  */
        , ${SCHEMA_NAME}.TSOL_OM_BKR_BSC BKR_BSC         /* 브로커기본 */
        , ${SCHEMA_NAME}.TSOL_OM_AST_TR_CD_CTL AST_TR_CD /* 거래코드  */

      WHERE 1=1

      AND #{istCd,jdbcType=VARCHAR} = FND_BSC.IST_CD
      AND #{amcoCd,jdbcType=VARCHAR} = FND_BSC.AMCO_CD
      AND CCS_SET.FND_CD = FND_BSC.FND_CD

      /* 운용역명 */
      AND #{istCd,jdbcType=VARCHAR} = USR_BSC_FNMS.IST_CD (+)
      AND #{amcoCd,jdbcType=VARCHAR} = USR_BSC_FNMS.AMCO_CD (+)
      AND CCS_SET.FNMN_USID = USR_BSC_FNMS.USID (+)

      /* 운용역팀코드 */
      AND #{istCd,jdbcType=VARCHAR} = TEM_CD_CTL.IST_CD (+)
      AND USR_BSC_FNMS.TEM_CD = TEM_CD_CTL.TEM_CD (+)

      <if test='ogzCd != null and ogzCd != ""'>
        <choose>
	   	<when test='ogzTc == "26"'>
	   /*팀코드*/
	   AND USR_BSC_FNMS.TEM_CD = #{ogzCd, jdbcType=VARCHAR}
	   	</when>
	   	<when test='ogzTc == "01"'>
	   /*본부코드*/
	   AND USR_BSC_FNMS.HDQ_CD = #{ogzCd, jdbcType=VARCHAR}
	   	</when>
	   	<when test='ogzTc == "24"'>
	   /*부문코드*/
	   AND USR_BSC_FNMS.FILD_CD = #{ogzCd, jdbcType=VARCHAR}
	   	</when>
	   	<when test='ogzTc == "20"'>
	   /*총괄코드*/
	   AND USR_BSC_FNMS.SUMZ_CD = #{ogzCd, jdbcType=VARCHAR}
	   	</when>
	   </choose>
      </if>

      /* 브로커기본 */
      AND #{istCd,jdbcType=VARCHAR} = BKR_BSC.IST_CD (+)
      AND #{amcoCd,jdbcType=VARCHAR} = BKR_BSC.AMCO_CD (+)
      AND CCS_SET.BKR_CD = BKR_BSC.BKR_CD (+)

      /* 거래코드  */
      AND #{istCd,jdbcType=VARCHAR} = AST_TR_CD.IST_CD (+)
      AND CCS_SET.TR_CD = AST_TR_CD.TR_CD (+)

      /* 조회조건 반영*/
      <if test='srtVltYn != null and srtVltYn != "N"'>
        AND SRT_VLT = #{srtVltYn, jdbcType=VARCHAR}
      </if>
      <if test='trPcdrVltYn != null and trPcdrVltYn != "N"'>
        AND TR_PCDR_VLT = #{trPcdrVltYn, jdbcType=VARCHAR}
      </if>

      ORDER BY 1, 2, 3

