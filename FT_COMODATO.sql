----------------------------------------------------------------------
----------------------FT_COMODATO-----------------------------
----------------------------------------------------------------------

SELECT 
             TEC.CD_TECNICO     AS COD_TECNICO, 
             TEC.NM_TECNICO     AS NOME_TECNICO,
             'BR' as COUNTRY,
             CONCAT('BR',CONVERT(VARCHAR, CLI.CD_CLIENTE, (5)))     AS COD_CLIENTE, 
             REL.DT_DATA_OS     AS DT_CRIACAO, 
             REL.CD_ATIVO_FIXO  AS COD_ATIVO_FIXO,
    --CASE
    --    WHEN 
    --            (SELECT  MIN (PA.id_relato_peca) FROM COMODATOPRD.DBO.tb_relato_equip_peca AS PA
    --          WHERE PA.ID_RELATO_EQUIP=REQ.ID_RELATO_EQUIP) = RPE.id_relato_peca
    --          OR
    --          (SELECT MIN(PA.id_relato_peca) FROM COMODATOPRD.DBO.tb_relato_equip_peca AS PA
    --              WHERE PA.ID_RELATO_EQUIP=REQ.ID_RELATO_EQUIP) = 0
    --         OR
    --         (SELECT MIN(PA.id_relato_peca) FROM COMODATOPRD.DBO.tb_relato_equip_peca AS PA
    --              WHERE PA.ID_RELATO_EQUIP=REQ.ID_RELATO_EQUIP) is null
    --           THEN
    --                COALESCE(REQ.HR_TRABALHADAS,0)
    --   Else
    --       0
    --END AS 
       Cast((Convert(float,Substring(REL.HR_FIM,0,3)) + Convert(float,Substring(REL.HR_FIM,4,2))/60)
		-(Convert(float,Substring(REL.HR_INICIO,0,3)) + Convert(float,Substring(REL.HR_INICIO,4,2))/60) 
			as float)												  AS QTD_HORAS,
	   REL.HR_INICIO												  AS HORA_INICIO,
	   REL.HR_FIM													  AS HORA_FIM,
       TEC.VL_CUSTO_HORA                                              AS VAL_HORAS,
       CASE	REL.CD_TIPO_OS 
				WHEN '1' THEN 'P'
				WHEN '2' THEN 'C'
				WHEN '3' THEN 'I'
				WHEN '4' THEN 'O'
				--ELSE REL.CD_TIPO_OS 
	   END  														  AS TIPO_MANUT,
       PEC.CD_PECA                                                    AS COD_PECA,
       PEC.DS_PECA                                                    AS DESCR_PECA,
       RPE.QT_PECA	                                                  AS QTD_UTILIZADA,
       RPE.VL_VALOR_PECA                                              AS VALOR_PECA,
       REL.DS_OBSERVACAO                                              AS OBSERVACAO,
       Cast((Convert(float,Substring(REL.HR_FIM,0,3)) + Convert(float,Substring(REL.HR_FIM,4,2))/60)
		-(Convert(float,Substring(REL.HR_INICIO,0,3)) + Convert(float,Substring(REL.HR_INICIO,4,2))/60) 
			as float)                                                 AS HORAS_TRAB,
       REL.ID_OS	                                                  AS NUM_RELATORIO,
       LEFT(CONVERT(varchar, REL.DT_DATA_OS,112),6)                   AS ANO_MES,
       --(REQ.HR_TRABALHADAS * REQ.VL_HORA)                             AS VAL_MANUTENCAO,
	   (Cast((Convert(float,Substring(REL.HR_FIM,0,3)) + Convert(float,Substring(REL.HR_FIM,4,2))/60)
		-(Convert(float,Substring(REL.HR_INICIO,0,3)) + Convert(float,Substring(REL.HR_INICIO,4,2))/60) 
			as float) * TEC.VL_CUSTO_HORA)                            AS VAL_MANUTENCAO,
       (Cast((Convert(float,Substring(REL.HR_FIM,0,3)) + Convert(float,Substring(REL.HR_FIM,4,2))/60)
		-(Convert(float,Substring(REL.HR_INICIO,0,3)) + Convert(float,Substring(REL.HR_INICIO,4,2))/60) 
			as float) / 3)		                                      AS PERIODO_1,  
       (RPE.QT_PECA * RPE.VL_VALOR_PECA)                              AS VALOR_PECA,
       ((Cast((Convert(float,Substring(REL.HR_FIM,0,3)) + Convert(float,Substring(REL.HR_FIM,4,2))/60)
		-(Convert(float,Substring(REL.HR_INICIO,0,3)) + Convert(float,Substring(REL.HR_INICIO,4,2))/60) 
			as float) * TEC.VL_CUSTO_HORA) * (Cast((Convert(float,Substring(REL.HR_FIM,0,3)) + Convert(float,Substring(REL.HR_FIM,4,2))/60)
		-(Convert(float,Substring(REL.HR_INICIO,0,3)) + Convert(float,Substring(REL.HR_INICIO,4,2))/60) 
			as float) / 3))											  AS PERIODO_2 
        FROM
             COMODATOPRD.DBO.tbOSPadrao REL
             INNER JOIN COMODATOPRD.DBO.TB_TECNICO TEC                       ON TEC.CD_TECNICO = REL.CD_TECNICO
             INNER JOIN COMODATOPRD.DBO.TB_CLIENTE CLI                       ON REL.CD_CLIENTE = CLI.CD_CLIENTE
             LEFT JOIN  COMODATOPRD.DBO.TB_GRUPO GRP                         ON CLI.CD_GRUPO = GRP.CD_GRUPO
             LEFT JOIN  COMODATOPRD.DBO.V_REGIAO REG                         ON CLI.CD_REGIAO = REG.CD_REGIAO
             --LEFT JOIN  COMODATOPRD.DBO.TB_RELATO_EQUIP REQ                  ON REQ.ID_RELATO = REL.ID_RELATO
             LEFT JOIN  COMODATOPRD.DBO.tbPecaOS RPE				         ON RPE.ID_OS = REL.ID_OS
             LEFT JOIN  COMODATOPRD.DBO.TB_ATIVO_FIXO EQP                    ON REL.CD_ATIVO_FIXO = EQP.CD_ATIVO_FIXO
             LEFT JOIN  COMODATOPRD.DBO.TB_MODELO MOD                        ON MOD.CD_MODELO = EQP.CD_MODELO
             LEFT JOIN  COMODATOPRD.DBO.TB_PECA PEC                          ON PEC.CD_PECA = RPE.CD_PECA
		Where REL.ST_STATUS_OS in (3) and REL.HR_FIM is not null and REL.HR_INICIO is not null
      ORDER BY DT_CRIACAO DESC