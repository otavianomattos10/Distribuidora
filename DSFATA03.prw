#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'TOPCONN.CH'
#Include "TBICONN.CH"

/*/{Protheus.doc} DSFATA03

Geração do título financeiro

@author Otaviano Mattos
@since 15/09/2017
@version 1.0
/*/

User Function DSFATA03()
	
	Local cAliasTRB 	:= GetNextAlias()
	Local cNumero   	:= ""
	Local cNatureza 	:= ""
	Local cCliente  	:= ""
	Local cPrefixo		:= ""
	Local nValTot		:= 0
	Local aBaixa    	:= {}
	Local aArray		:= {}
	Local dData     	:= CtoD( "" )
	Private lMsErroAuto := .F.

	PREPARE ENVIRONMENT Empresa '99' Filial '01' Tables 'Z00','Z01','SE1' MODULO "FIN"

	If( Select( cAliasTRB ) > 0 )
		( cAliasTRB )->( DbCloseArea() )
	EndIf

	ConOut( "Consultando vendas em aberto" )

	BeginSql Alias cAliasTRB

		COLUMN Z00_DATA AS DATE

		SELECT Z00_CODIGO, Z00_CLIENT, Z00_LOJA, 
			   Z00_DATA, Z00_TIPOVD, Z00_FORMPG,
			   SUM( Z01_TOTAL ) Z01_TOTAL, Z00.R_E_C_N_O_ Z00RECNO FROM %TABLE:Z00% Z00
		INNER JOIN %TABLE:Z01% Z01
			ON Z00_FILIAL = Z01_FILIAL
			AND Z00_CODIGO = Z01_CODIGO
		WHERE Z00_STATUS = "F"
		AND Z00_CONSUM = '1'
		AND Z00.%NOTDEL%
		AND Z01.%NOTDEL%
		GROUP BY Z00_CODIGO, Z00_CLIENT, Z00_LOJA, Z00_DATA, Z00_TIPOVD, Z00_FORMPG, Z00.R_E_C_N_O_
	
	EndSql	
	
	Begin Transaction
	
	DbSelectArea( cAliasTRB )
	( cAliasTRB )->( DbGoTop() )
	While ( cAliasTRB )->( .NOT. EOF() )
	
		ConOut( "Venda: " + ( cAliasTRB )->Z00_CODIGO )
	
		cNumero := ( cAliasTRB )->Z00_CODIGO
		nValTot := ( cAliasTRB )->Z01_TOTAL
		dData   := ( cAliasTRB )->Z00_DATA
		
		If( ( cAliasTRB )->Z00_TIPOVD <> "3" )
		
			cCliente := ( cAliasTRB )->Z00_CLIENT
			cPrefixo := "VND"
			
		Else
		
			cCliente := "000001"
			cPrefixo := "FCH"
			
		EndIf
	
		If( ( cAliasTRB )->Z00_FORMPG == "1" )
			cNatureza := "DINHEIRO"
		ElseIf( ( cAliasTRB )->Z00_FORMPG == "2" )
			cNatureza := "CARTAOCREDI"
		Else
		 	cNatureza := "CARTAODEBI"
		EndIf	
	
		aArray := { { "E1_PREFIXO"  , cPrefixo  , NIL } , ;
		            { "E1_NUM"      , cNumero   , NIL } , ;
		            { "E1_TIPO"     , "NF "     , NIL } , ;
		            { "E1_NATUREZ"  , cNatureza , NIL } , ;
		            { "E1_CLIENTE"  , cCliente  , NIL } , ;
		            { "E1_LOJA"     , "01"      , NIL } , ;
		            { "E1_EMISSAO"  , dData 	, NIL } , ;
		            { "E1_VENCTO"   , dData	    , NIL } , ;
		            { "E1_VENCREA"  , dData  	, NIL } , ;
		            { "E1_VALOR"    , nValTot   , NIL } }
			 
		MsExecAuto( { | x , y | FINA040( x , y ) } , aArray, 3 )  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
			 
		If( lMsErroAuto )
		
			ConOut( "Falha na geração do título" )
		
		    MostraErro( "\system\" , "errogeratitulo" )
		    
		Else
		
			lMsErroAuto := .F.
		
			ConOut( "Título gerado com Sucesso!" )
		
			Z00->( DbGoTo( ( cAliasTRB )->Z00RECNO ) )
		
			If( Reclock( "Z00" , .F. ) )
			
				Z00->Z00_STATUS := "G"
				
				Z00->( MsUnlock() )
			
			EndIf
		
			aBaixa := { { "E1_PREFIXO"   , cPrefixo      , Nil       } , ;
			            { "E1_NUM"       , cNumero       , Nil       } , ;
			            { "E1_TIPO"      , "NF "         , Nil       } , ;
			            { "AUTMOTBX"     , "NOR"         , Nil       } , ;
			            { "AUTBANCO"     , "CX1"         , Nil       } , ;
			            { "AUTAGENCIA"   , "00001"       , Nil       } , ;
			            { "AUTCONTA"     , "0000000001"  , Nil       } , ;
			            { "AUTDTBAIXA"   , dData         , Nil       } , ;
			            { "AUTDTCREDITO" , dData         , Nil       } , ;
			            { "AUTHIST"      , "BAIXA"       , Nil       } , ;
			            { "AUTJUROS"     , 0             , Nil , .T. } , ;
			            { "AUTVALREC"    , nValTot       , Nil       } }
			            
			MSExecAuto( { | x , y | FINA070( x , y ) } , aBaixa , 3 )            
			
			If( lMsErroAuto )
				MostraErro( "\system\" , "errobaixa" )
			Else									
				
				ConOut( "Título baixado com Sucesso!" )
				
				If( Reclock( "Z00" , .F. ) )
			
					Z00->Z00_STATUS := "B"
				
					Z00->( MsUnlock() )
			
				EndIf
															
			EndIf
		    
		Endif

		( cAliasTRB )->( DbSkip() )

	End

	End Transaction

	( cAliasTRB )->( DbCloseArea() )
	
	RESET ENVIRONMENT
	
Return( Nil )