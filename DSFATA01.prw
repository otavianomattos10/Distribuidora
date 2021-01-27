#Include 'Protheus.ch'
#Include 'Totvs.ch'
#Include 'FWMVCDef.ch'
#include 'FWBrowse.ch'

/*/{Protheus.doc} DSFATA01

Rotina de venda

@author Otaviano Mattos
@since 15/09/2017
@version 1.0
/*/

STATIC cRetSXB := ""

User Function DSFATA01()

	Local aCoors 	    := FWGetDialogSize( oMainWnd )
	Local nLstCta		:= 0
	Local nSuperior	    := 0
	Local nEsquerda	    := 005
	Local nInferior	    := 110
	Local nDireita	    := 640	

	Private cMarkNo	 	:= LoadBitmap( GetResources() , "unchecked_15" ) 	 
	Private cMarkOk	 	:= LoadBitmap( GetResources() , "checked_15" )
	Private cGet0		:= Space( 6 )
	Private cGet1		:= Space( 6 )
	Private cGet3		:= Space( 8 )
	Private cGet5	    := Space( 13 )
	Private aHeader     := {}
	Private aCols1   	:= {}
	Private nGet1		:= 1
	Private nGet2		:= 0
	Private nGet3       := 0
	Private nSldPag		:= 0
	Private nVlPag		:= 0
	Private nValTot		:= 0
	Private lClear	    := .F.
	Private lCheckOpen  := .F.
	Private lVendaFinal := .F.
	Private aTpVenda    := { "Venda" , "Fiado" , "Ficha" }
	Private aRecebedor  := { "Distribuidora" , "Espetinho" , "Lanche" }
	Private aFormaPagto := { "Dinheiro" , "Cartão de Crédito" , "Cartão de Débito" }	
	Private aPerda	    := { "Não" , "Sim" }
	Private cTipoVenda  := "Ficha"	
	Private cTpVenda    := aTpVenda[ 1 ]
	Private cRecebedor  := aRecebedor[ 1 ]
	Private cFormaPagto := aFormaPagto[ 1 ]
	Private cPerda	    := aPerda[ 1 ]

	SetPrvt( "oWindCx" , "oFWLayer" , "oPanelUp" , "oPanelDown" , "oGrid" , "oGroup1" , "oFont1" , "oSay1" , "oSay2" , "oSay3" , "oSay4"  , ; 
			 "oSay5" , "oSay6" , "oSay7" , "oSay8" , "oSay9" , "oSay10" , "oSay11" , "oSay12" , "oGet1" , "oGet2" , "oGet3" , "oCombo1"   , ;
			 "oCombo2" , "oCombo3" , "oCombo4" , "oLstCta" , "oTButton1" , "oTButton2" , "oGet4" , "oGet5" , "oSay0" , "oGet0" , "oSay13" , ;
			 "oSay14" , "oSay15" , "oSay16" , "oTButton3" , "oTButton4" , "oSay17" , "oGet6" , "oGet7" )	
	
	//Busco a numeração
	cGet0 := GetSx8Num( "Z00" , "Z00_CODIGO" )
	
	//Cria uma Dialog	
	oWindCx := MsDialog():New( aCoors[ 1 ] , aCoors[ 2 ] , aCoors[ 3 ] , aCoors[ 4 ] , "Vendas Distribuidora",,,,,,,,, .T. )

	oFWLayer := FWLayer():New() 
	oFWLayer:Init( oWindCx )	

	oFWLayer:AddLine( "Lin01" , 20 , .F. )                      
	oFWLayer:AddCollumn( "Col01" , 100 , .T. , "Lin01" )            
	oPanelUp := oFWLayer:GetColPanel( "Col01" , "Lin01" )    	
	
	oFWLayer:AddLine( "Lin02" , 80 , .F. )                                            
	oFWLayer:AddCollumn( "Col02", 100 , .T. , "Lin02" )  
	oFWLayer:AddWindow( "Col02" , "Win02" , "Produtos" , 60 , .F. , .F. , , "Lin02" )                      
	oPanelDown := oFWLayer:GetWinPanel( "Col02", "Win02", "Lin02" )        	
	
	aHeader := SFHeader()	
	
	oGrid	 := MsNewGetDados():New( nSuperior , nEsquerda , nInferior , nDireita , GD_UPDATE + GD_DELETE , "AlwaysTrue" ,,,,,,,, "U_SFDELOK" , oPanelDown , aHeader , aCols1 )
	oGrid:oBrowse:bLDblClick := { || SFMARCA() }	
    
    //->Separador com objetivo de informar as caixas de dialogo
	oGroup1 := TGroup():New( 02  , 02 , 55  , 650 , "Parâmetros" , oWindCx ,,, .T. )
	
	oFont1 := TFont():New( "Arial" ,, -12 , .F. )	

	oSay0   := TSay():New( 010 , 10  , { | | "Codigo" } , oGroup1 ,, oFont1 ,,,, .T. , CLR_BLACK , CLR_WHITE , 200 , 20 )
	oGet0   := TGet():New( 020 , 10  , { | u | If( PCount() == 0 , cGet0 , cGet0 := u ) } , oGroup1 , 025 , 010 , "!@" ,, 0 , 16777215 ,, .F. ,, .T. ,, .F. ,, .F. , .F. ,, .T. , .F. ,, "cGet0" ,,,, .T.  )	
	
	oSay1   := TSay():New( 010 , 80  , { | | "Cliente/Ficha" } , oGroup1 ,, oFont1 ,,,, .T. , CLR_BLACK , CLR_WHITE , 200 , 20 )
	oGet1   := TGet():New( 020 , 85  , { | u | If( PCount() == 0 , cGet1 , cGet1 := u ) } , oGroup1 , 025 , 010 , "!@" , { || SFVALIDCPO() } , 0 , 16777215 ,, .F. ,, .T. ,, .F. ,, .F. , .F. , { || IIf( cTpVenda <> "Ficha" , oSay10:cCaption := "<font size='03' color='green'>" + AllTrim( Posicione( "SA1" , 1 , xFilial( "SA1" ) + cGet1 , "A1_NOME" ) ) + "</font><br/>" , "" ) } , .F. , .F. , "DISTRI" , "cGet1" ,,,, .T.  )	
			
	oSay2   := TSay():New( 010 , 150  , { | | "Emissao" } , oGroup1 ,, oFont1 ,,,, .T. , CLR_BLACK , CLR_WHITE , 200 , 20 )
	oGet2   := TGet():New( 020 , 150  , { | | Date() } , oGroup1 , 050 , 010 , "@D" ,, 0 , 16777215 ,, .F. ,, .T. ,, .F. ,, .F. , .F. ,, .T. , .F. ,, "dGet2" ,,,, .T.  )
	
	oSay3   := TSay():New( 010 , 220 , { | | "Hora" } , oGroup1 ,, oFont1 ,,,, .T. , CLR_BLACK , CLR_WHITE , 200 , 20 )
	oGet3   := TGet():New( 020 , 220 , { | | Time() } , oGroup1 , 050 , 010 , "@!" ,, 0 , 16777215 ,, .F. ,, .T. ,, .F. ,, .F. , .F. ,, .T. , .F. ,, "cGet3" ,,,, .T.  )
	
	oSay4   := TSay():New( 010 , 290 , { | | "Tipo de Venda" } , oGroup1 ,, oFont1 ,,,, .T. , CLR_BLACK , CLR_WHITE , 200 , 20 )	
	oCombo1 := TComboBox():New( 020 , 290 , { | u | If( PCount() > 0 , cTpVenda := u , cTpVenda ) } , aTpVenda , 50 , 20 , oGroup1 ,, { || IIf( lCheckOpen , .T. , ( oGet1:cText := "" , .T. ) ) , U_SFCONPAD( cTpVenda ) } ,,,,.T.,,,,,,,,, "cTpVenda" )

	oSay5   := TSay():New( 010 , 360 , { | | "Recebedor" } , oGroup1 ,, oFont1 ,,,, .T. , CLR_BLACK , CLR_WHITE , 200 , 20 )	
	oCombo2 := TComboBox():New( 020 , 360 , { | u | If( PCount() > 0 , cRecebedor := u , cRecebedor ) } , aRecebedor , 50 , 20 , oGroup1 ,,,,,,.T.,,,,,,,,, "cRecebedor" )
	
	oSay6   := TSay():New( 010 , 430 , { | | "Forma de Pagto" } , oGroup1 ,, oFont1 ,,,, .T. , CLR_BLACK , CLR_WHITE , 200 , 20 )	
	oCombo3 := TComboBox():New( 020 , 430 , { | u | If( PCount() > 0 , cFormaPagto := u , cFormaPagto ) } , aFormaPagto , 50 , 20 , oGroup1 ,,,,,,.T.,,,,,,,,, "cFormaPagto" )	
	
	oSay7   := TSay():New( 010 , 500 , { | | "Perda?" } , oGroup1 ,, oFont1 ,,,, .T. , CLR_BLACK , CLR_WHITE , 200 , 20 )	
	oCombo4 := TComboBox():New( 020 , 500 , { | u | If( PCount() > 0 , cPerda := u , cPerda ) } , aPerda , 50 , 20 , oGroup1 ,,,,,,.T.,,,,,,,,, "cPerda" )	
    
	oSay12 := TSay():New( 190 , 270 , { | | "<font size='10' color='blue'>Fichas Ocupadas</font><br/>"    } , oWindCx ,, oFont1 ,,,, .T. , CLR_BLACK , CLR_WHITE , 200 , 20 ,,,,,, .T. )
    
    oTButton1 := TButton():New( 200 , 010 , "SALVAR" , oWindCx , { || IIf( cTpVenda <> "Venda" , SFSALVAR() , ( Help( "" , 1 , "DSFATA01" ,, "Não é possível salvar o tipo 'Venda'. " , 1 , 0 ) , .F. ) ) } , 050 , 050 ,,, .F. , .T. , .F. ,, .F. ,,, .F.  )
    oTButton3 := TButton():New( 200 , 100 , "LIMPAR" , oWindCx , { || SFCLEAR() } , 050 , 050 ,,, .F. , .T. , .F. ,, .F. ,,, .F.  )				
    
    //oTButton4 := TButton():New( 200 , 490 , "CANCELAR"  , oWindCx , { || alert( "CANCELAR"  ) } , 050 , 050 ,,, .F. , .T. , .F. ,, .F. ,,, .F.  )
    oTButton2 := TButton():New( 200 , 490 , "FINALIZAR" , oWindCx , { || IIf( MsgYesNo( "Deseja finalizar a venda?" , "Atenção" ) , SFFINALIZAR() , Nil ) } , 050 , 050 ,,, .F. , .T. , .F. ,, .F. ,,, .F.  )		
    
	oLstCta   := TListBox():New( 210 , 200 , { | u | If( Pcount() > 0 , nLstCta := u , nLstCta ) } , {} , 260 , 42 ,, oWindCx ,,,, .T. )
	
	//Adiciono itens na lista
	SFADDLIST()
    
	//->Agrupamento do totalizador
	oGroup2 := TGroup():New( 250 , 02 , 280 , 650 , "Totalizador Geral"   , oWindCx ,,, .T. )    
    
	//->Cabeçalho							
	oSay8  := TSay():New( 260 , 10  , { | | "<font size='04' color='blue'>Cliente</font><br/>"       } , oGroup2 ,, oFont1 ,,,, .T. , CLR_BLACK , CLR_WHITE , 200 , 20 ,,,,,, .T. )
	oSay13 := TSay():New( 260 , 320 , { | | "<font size='04' color='blue'>Saldo a Pagar</font><br/>" } , oGroup2 ,, oFont1 ,,,, .T. , CLR_BLACK , CLR_WHITE , 200 , 20 ,,,,,, .T. )
	oSay14 := TSay():New( 260 , 420 , { | | "<font size='04' color='blue'>Valor Pago</font><br/>"    } , oGroup2 ,, oFont1 ,,,, .T. , CLR_BLACK , CLR_WHITE , 200 , 20 ,,,,,, .T. )
	oSay9  := TSay():New( 260 , 520 , { | | "<font size='04' color='blue'>Valor Total</font><br/>"   } , oGroup2 ,, oFont1 ,,,, .T. , CLR_BLACK , CLR_WHITE , 200 , 20 ,,,,,, .T. )
	
	//->Valores
	oSay10 := TSay():New( 270 , 10  , { | | "<font size='03' color='green'></font><br/>" } , oGroup2 ,, oFont1 ,,,, .T. , CLR_BLACK , CLR_WHITE , 200 , 20 ,,,,,, .T. )
	oSay15 := TSay():New( 270 , 320 , { | | "<font size='03' color='green'>" + Transform( nSldPag , "@E 999,999,999.99" ) + "</font><br/>" } , oGroup2 ,, oFont1 ,,,, .T. , CLR_BLACK , CLR_WHITE , 200 , 20 ,,,,,, .T. )
	oSay16 := TSay():New( 270 , 420 , { | | "<font size='03' color='green'>" + Transform( nVlPag  , "@E 999,999,999.99" ) + "</font><br/>" } , oGroup2 ,, oFont1 ,,,, .T. , CLR_BLACK , CLR_WHITE , 200 , 20 ,,,,,, .T. )
	oSay11 := TSay():New( 270 , 520 , { | | "<font size='03' color='green'>" + Transform( nValTot , "@E 999,999,999.99" ) + "</font><br/>" } , oGroup2 ,, oFont1 ,,,, .T. , CLR_BLACK , CLR_WHITE , 200 , 20 ,,,,,, .T. )		
	
	SetKey( VK_F4, { || IIf( Empty( oGet1:cText ) , Help( "" , 1 , "DSFATA01" ,, "Preencha o cliente/ficha antes de continuar." , 1 , 0 ) , SFLANCTO() ) } )	
		
	//Exibe a Dialog	
	oWindCx:Activate( , , , .T. )
	
	//Retorno a numeração para a próxima abertura
	Z00->( RollBackSX8() )

Return( Nil )

/*/{Protheus.doc} SFLANCTO

Realiza o lançamento dos produtos

@author Otaviano Mattos
@since 16/09/2017
@version 1.0
/*/

Static Function SFLANCTO()

	Local oWinLcto   := Nil
	Local oTSay1     := Nil
	Local oQuant	 := Nil
	Local oProduto	 := Nil
	Local oFont1	 := Nil
	Local lHasButton := .T.
	
	oFont1 := TFont():New( "Arial" ,, -20 , .F. )
	
	//Desabilito o F4
	SetKey( VK_F4 , { || } )
	
	//Cria uma Dialog	
	oWinLcto := MsDialog():New( 100 , 50 , 450 , 700 , "Lançamento" ,,,,,,,,, .T. )	
	
	If( cRecebedor <> "Distribuidora" )

		oQuant := TSay():New( 005 , 009 , { | | "<font size='20' color='blue'>Quantidade</font><br/>" } , oWinLcto ,, oFont1 ,,,, .T. , CLR_BLACK , CLR_WHITE , 200 , 30 ,,,,,, .T. )
		oSay17 := TSay():New( 005 , 200 , { | | "<font size='20' color='blue'>Valor</font><br/>" } , oWinLcto ,, oFont1 ,,,, .T. , CLR_BLACK , CLR_WHITE , 200 , 30 ,,,,,, .T. )
			
		oGet4 := TGet():New( 035 , 009 , { | u | If( PCount() == 0 , nGet1 , nGet1 := u ) } , oWinLcto , 120 , 050 , "@E 9999999" , { | | nGet1 > 0 } , 0 , 16777215 ,, .F. ,, .T. ,, .F. ,, .F. , .F. ,, .F. , .F. ,, "nGet1" ,,,, lHasButton  )
		oGet4:setCSS( "QLineEdit{color:black; background-color:white; font-size:72px; }" )	

		oGet6 := TGet():New( 035 , 150 , { | u | If( PCount() == 0 , nGet2 , nGet2 := u ) } , oWinLcto , 200 , 050 , "@E 9999.99" , { | | nGet2 > 0 } , 0 , 16777215 ,, .F. ,, .T. ,, .F. ,, .F. , .F. ,, .F. , .F. ,, "nGet2" ,,,, lHasButton  )
		oGet6:setCSS( "QLineEdit{color:black; background-color:white; font-size:72px; }" )	
		
		oProduto := TSay():New( 090 , 115  , { | | "<font size='20' color='blue'>Produto</font><br/>" } , oWinLcto ,, oFont1 ,,,, .T. , CLR_BLACK , CLR_WHITE , 200 , 30 ,,,,,, .T. )				
	
		cGet5 := Space( 6 )
	
		oGet5 := TGet():New( 120 , 009 , { | u | If( PCount() == 0 , cGet5 , cGet5 := u ) } , oWinLcto , 300 , 050 , "999999" , { || ADDPROD() } , 0 , 16777215 ,, .F. ,, .T. ,, .F. ,, .F. , .F. ,, .F. , .F. , "DISSB1" , "cGet5" ,,,, lHasButton )
		oGet5:setCSS( "QLineEdit{color:black; background-color:white; font-size:72px; }" )	
	
	Else
		
		oQuant := TSay():New( 005 , 100  , { | | "<font size='20' color='blue'>Quantidade</font><br/>" } , oWinLcto ,, oFont1 ,,,, .T. , CLR_BLACK , CLR_WHITE , 200 , 30 ,,,,,, .T. )
			
		oGet4 := TGet():New( 035 , 009 , { | u | If( PCount() == 0 , nGet1 , nGet1 := u ) } , oWinLcto , 300 , 050 , "@E 9999999" , { | | nGet1 > 0 } , 0 , 16777215 ,, .F. ,, .T. ,, .F. ,, .F. , .F. ,, .F. , .F. ,, "nGet1" ,,,, lHasButton  )
		oGet4:setCSS( "QLineEdit{color:black; background-color:white; font-size:72px; }" )	
		
		oProduto := TSay():New( 090 , 115  , { | | "<font size='20' color='blue'>Produto</font><br/>" } , oWinLcto ,, oFont1 ,,,, .T. , CLR_BLACK , CLR_WHITE , 200 , 30 ,,,,,, .T. )				
		
		nGet1 := 0
		cGet5 := Space( 13 )
		
		oGet5 := TGet():New( 120 , 009 , { | u | If( PCount() == 0 , cGet5 , cGet5 := u ) } , oWinLcto , 300 , 050 , "9999999999999" , { || ADDPROD() } , 0 , 16777215 ,, .F. ,, .T. ,, .F. ,, .F. , .F. ,, .F. , .F. ,, "cGet5" ,,,, lHasButton )
		oGet5:setCSS( "QLineEdit{color:black; background-color:white; font-size:72px; }" )
				
	EndIf
	
	oGet5:SetFocus()
		
	//Exibe a Dialog	
	oWinLcto:Activate( ,,, .T. )	
	
	SetKey( VK_F4, { || IIf( Empty( oGet1:cText ) , Help( "" , 1 , "DSFATA01" ,, "Preencha o cliente/ficha antes de continuar." , 1 , 0 ) , SFLANCTO() ) } )

Return( Nil )

/*/{Protheus.doc} SFHEADER

Tratamento dos documentos após a confirmação no browse

@author Otaviano Mattos
@since 16/09/2017
@version 1.0
/*/

Static Function SFHEADER()
	
	aAdd( aHeader , { "OK"			    , "MARCACAO"   , "@BMP"			     , 4  , 0 , "" ,, "C" ,,,,,, "V" ,,, .F. } )
	Aadd( aHeader , { "Item"	  	    , "Z01_ITEM"   , "999"			     , 3  , 0 , "" ,, "C" ,,,,,, "V" ,,, .F. } )		
	Aadd( aHeader , { "Produto"	        , "Z01_PRODUT" , "@!"				 , 6  , 0 , "" ,, "C" ,,,,,, "V" ,,, .F. } )
	Aadd( aHeader , { "Descrição"	    , "Z01_DESCRI" , "@!"				 , 30 , 0 , "" ,, "C" ,,,,,, "V" ,,, .F. } )
	Aadd( aHeader , { "Quantidade"	    , "Z01_QUANT"  , "@E 999,999,999.99" , 12 , 2 , "" ,, "N" ,,,,,, "V" ,,, .F. } )
	Aadd( aHeader , { "Qtd Paga"	    , "Z01_QTDPAG" , "@E 999,999,999.99" , 12 , 2 , "" ,, "N" ,,,,,, "V" ,,, .F. } )
	Aadd( aHeader , { "Qtd Aberta"	    , "Z01_QTDSLD" , "@E 999,999,999.99" , 12 , 2 , "" ,, "N" ,,,,,, "V" ,,, .F. } )				
	Aadd( aHeader , { "Prc Unitário"    , "Z01_PRCUNI" , "@E 999,999,999.99" , 12 , 2 , "" ,, "N" ,,,,,, "V" ,,, .F. } )
	Aadd( aHeader , { "Valor Total"     , "Z01_TOTAL"  , "@E 999,999,999.99" , 12 , 2 , "" ,, "N" ,,,,,, "V" ,,, .F. } )
	Aadd( aHeader , { "Valor Pago"      , "Z01_VLPAGO" , "@E 999,999,999.99" , 12 , 2 , "" ,, "N" ,,,,,, "V" ,,, .F. } )
	Aadd( aHeader , { "Saldo a Pagar"   , "Z01_SLDPAG" , "@E 999,999,999.99" , 12 , 2 , "" ,, "N" ,,,,,, "V" ,,, .F. } )
	Aadd( aHeader , { "Qtd Informada"   , "Z01QTDINFO" , "@E 999,999,999.99" , 12 , 2 , "" ,, "N" ,,,,,, "V" ,,, .F. } )
	Aadd( aHeader , { "Valor Informado" , "Z01VALINFO" , "@E 999,999,999.99" , 12 , 2 , "" ,, "N" ,,,,,, "V" ,,, .F. } )				
	
Return( aHeader )

/*/{Protheus.doc} SFDELOK

Tratamento no delete da linha

@author Otaviano Mattos
@since 16/09/2017
@version 1.0
/*/

User Function SFDELOK()
	
	If( oGrid:aCols[ n ][ Len( oGrid:aHeader ) + 1 ] )
	
		nValTot += oGrid:aCols[ n ][ 9 ]
		nSldPag += oGrid:aCols[ n ][ 9 ]
	
	Else
	
		nValTot -= oGrid:aCols[ n ][ 9 ]
		nSldPag -= oGrid:aCols[ n ][ 9 ]

	EndIf

	oSay11:cCaption := "<font size='03' color='green'>" + Transform( nValTot , "@E 999,999,999.99" ) + "</font><br/>"
	oSay15:cCaption := "<font size='03' color='green'>" + Transform( nSldPag , "@E 999,999,999.99" ) + "</font><br/>"
	oSay16:cCaption := "<font size='03' color='green'>" + Transform( ( nValTot - nSldPag ) , "@E 999,999,999.99" ) + "</font><br/>"

Return( .T. )

/*/{Protheus.doc} SFCONPAD

Tratamento no delete da linha

@author Otaviano Mattos
@since 16/09/2017
@version 1.0
/*/

User Function SFCONPAD( cTipoVenda )

	Local nOpcao       := 0	
	Private oDlg       := NIL
	Private oBrowse    := NIL
	Private aItens     := Array( 1 , 4 )
	Default cTipoVenda := "Ficha"

	If( lClear .OR. lCheckOpen )
	
		lClear     := .F.
		lCheckOpen := .F.
		
		Return( .T. )
	
	EndIf

	If( Type( "cTpVenda" ) == "C" )
		cTipoVenda := cTpVenda
	EndIf

	oDlg := MSDIALOG():New(180,180,550,700,"Consulta",,, .F. ,,,,,, .T. ,,, .F. )

	If( cTipoVenda == "Ficha" )
	
		oSay10:cCaption := "<font size='03' color='green'></font><br/>"
	
		oBrowse := TCBROWSE():New(1,1,260,156,,{"Ficha"},{50},oDlg,,,,,{|| nOpcao := oBrowse:nAt, oDlg:END() },,,,,,, .F. ,, .T. ,, .F. ,,,)
				
		oBrowse:AddColumn(TCCOLUMN():New("Ficha",{ || aItens[oBrowse:nAt,1] },,,,"LEFT",, .F. , .T. ,,,, .F. ,))
	
	Else
		
		oBrowse := TCBROWSE():New(1,1,260,156,,{"Cod. Cliente","Loja","Nome","CPF"},{50,50,150,50},oDlg,,,,,{|| nOpcao := oBrowse:nAt, oDlg:END() },,,,,,, .F. ,, .T. ,, .F. ,,,)
				
		oBrowse:AddColumn(TCCOLUMN():New("Cod. Cliente",{ || aItens[oBrowse:nAt,1] },,,,"LEFT",, .F. , .T. ,,,, .F. ,))
		oBrowse:AddColumn(TCCOLUMN():New("Loja",{ || aItens[oBrowse:nAt,2] },,,,"LEFT",, .F. , .T. ,,,, .F. ,))
		oBrowse:AddColumn(TCCOLUMN():New("Nome",{ || aItens[oBrowse:nAt,3] },,,,"LEFT",, .F. , .T. ,,,, .F. ,))
		oBrowse:AddColumn(TCCOLUMN():New("CPF",{ || aItens[oBrowse:nAt,4] },,,,"LEFT",, .F. , .T. ,,,, .F. ,))
	
	EndIf
	
	F3ITENS( cTipoVenda )
	
	TButton():New(170,12,"Confirmar",oDlg,{|| nOpcao := oBrowse:nAt, oDlg:END() },40,10,,, .F. , .T. , .F. ,, .F. ,,, .F. )
	TButton():New(170,54,"Cancelar",oDlg,{|| nOpcao := 0,           oDlg:END() },40,10,,, .F. , .T. , .F. ,, .F. ,,, .F. )
		
	oDlg:Activate(oDlg:BlClicked,oDlg:bMoved,oDlg:bPainted, .T. ,,,,oDlg:BrClicked,)
	
	If( nOpcao > 0 )
	
		cRetSXB     := aItens[ nOpcao , 1 ]	
	    oGet1:cText := cRetSXB
	    
	    If( .NOT. Empty( cRetSXB ) )
	    	SFVALIDCPO()
	    EndIf
	    	    
	Endif	

Return( .T. )

/*/{Protheus.doc} F3ITENS

Itens da consulta

@author Otaviano Mattos
@since 16/09/2017
@version 1.0
/*/

Static Function F3ITENS( cTipoVenda )

	Local aAreaAtu  := GetArea()
	Local aTempo    := Array( 0 )
	Local nX	    := 1
	Local cAliasTRB := GetNextAlias()
	
	If( Select( cAliasTRB ) > 0 )
	    ( cAliasTRB )->( DbCloseArea() )
	EndIf
	
	If( cTipoVenda == "Ficha" )
	
		BeginSQL Alias cAliasTRB   
	    
	    	%NoParser%
	    	
	    	SELECT Z03_FICHA
	    	FROM %TABLE:Z03% Z03
	    	WHERE %NOTDEL%
	    	ORDER BY Z03_FICHA
	    		
	    EndSQL	
		
		DbSelectArea( cAliasTRB )	
		( cAliasTRB )->( DbGoTop() )
		While( ( cAliasTRB )->( .NOT. EOF() ) )
		    
	        Aadd( aTempo , {} )
	        Aadd( aTempo[ nX ] , ( cAliasTRB )->Z03_FICHA )
		        
	        nX++
		        
		    ( cAliasTRB )->( DbSkip() ) 
		End	
	
	Else
		
		BeginSQL Alias cAliasTRB   
	    
	    	%NoParser%
	    	
	    	SELECT A1.A1_COD,
	    		   A1.A1_LOJA,
	    		   A1.A1_NOME,
	    		   A1.A1_CGC
	    	FROM %TABLE:SA1% A1
	    	WHERE %NOTDEL%
	    	ORDER BY A1_NOME
	    		
	    EndSQL	
		
		DbSelectArea( cAliasTRB )	
		( cAliasTRB )->( DbGoTop() )
		While( ( cAliasTRB )->( .NOT. EOF() ) )
		    
	        Aadd( aTempo , {} )
	        Aadd( aTempo[ nX ] , ( cAliasTRB )->A1_COD )
	        Aadd( aTempo[ nX ] , ( cAliasTRB )->A1_LOJA )
	        Aadd( aTempo[ nX ] , ( cAliasTRB )->A1_NOME )
	        Aadd( aTempo[ nX ] , ( cAliasTRB )->A1_CGC )
		        
	        nX++
		        
		    ( cAliasTRB )->( DbSkip() ) 
		End
	
	EndIf
	
	( cAliasTRB )->( DbCloseArea() )
	
	aItens := Aclone( aTempo )
	oBrowse:SetArray( aItens )
	
	RestArea( aAreaAtu )	

Return( Nil )

/*/{Protheus.doc} RETCONXB

Itens da consulta

@author Otaviano Mattos
@since 16/09/2017
@version 1.0
/*/

User Function RETCONXB()
Return( cRetSXB )

/*/{Protheus.doc} SFSB1SXB

Consulta específica SB1

@author Otaviano Mattos
@since 16/09/2017
@version 1.0
/*/

User Function SFSB1SXB()

	Local nOpcao       := 0	
	Private oDlg       := NIL
	Private oBrowse    := NIL
	Private aItens     := Array( 1 , 3 )

	If( Type( "cTpVenda" ) == "C" )
		cTipoVenda := cTpVenda
	EndIf

	oDlg := MSDIALOG():New(180,180,550,700,"Consulta",,, .F. ,,,,,, .T. ,,, .F. )

	oBrowse := TCBROWSE():New(1,1,260,156,,{"Produto","Descrição","Preço"},{50,150,50},oDlg,,,,,{|| nOpcao := oBrowse:nAt, oDlg:END() },,,,,,, .F. ,, .T. ,, .F. ,,,)
				
	oBrowse:AddColumn(TCCOLUMN():New("Produto",{ || aItens[oBrowse:nAt,1] },,,,"LEFT",, .F. , .T. ,,,, .F. ,))
	oBrowse:AddColumn(TCCOLUMN():New("Descrição",{ || aItens[oBrowse:nAt,2] },,,,"LEFT",, .F. , .T. ,,,, .F. ,))
	oBrowse:AddColumn(TCCOLUMN():New("Preço",{ || aItens[oBrowse:nAt,3] },,,,"RIGHT",, .F. , .T. ,,,, .F. ,))
	
	F3SB1( cTipoVenda )
	
	TButton():New(170,12,"Confirmar",oDlg,{|| nOpcao := oBrowse:nAt, oDlg:END() },40,10,,, .F. , .T. , .F. ,, .F. ,,, .F. )
	TButton():New(170,54,"Cancelar",oDlg,{|| nOpcao := 0,           oDlg:END() },40,10,,, .F. , .T. , .F. ,, .F. ,,, .F. )
		
	oDlg:Activate(oDlg:BlClicked,oDlg:bMoved,oDlg:bPainted, .T. ,,,,oDlg:BrClicked,)
	
	If( nOpcao > 0 )
	
		cRetSXB     := aItens[ nOpcao , 1 ]	
	    oGet5:cText := cRetSXB
	    	    
	endif	

Return( .T. )

/*/{Protheus.doc} F3SB1

Itens da consulta

@author Otaviano Mattos
@since 16/09/2017
@version 1.0
/*/

Static Function F3SB1()

	Local aAreaAtu  := GetArea()
	Local aTempo    := Array( 0 )
	Local nX	    := 1
	Local cPropProd := IIf( cRecebedor == "Espetinho" , "2" , "3" )
	Local cAliasTRB := GetNextAlias()
	
	If( Select( cAliasTRB ) > 0 )
	    ( cAliasTRB )->( DbCloseArea() )
	EndIf
	
	BeginSQL Alias cAliasTRB   
	    
    	%NoParser%
	    	
    	SELECT B1_COD, B1_DESC, B1_PRV1
    	FROM %TABLE:SB1% B1
    	WHERE %NOTDEL%
    	AND B1_XPROPRI = %Exp:cPropProd%
    	ORDER BY B1_DESC
    		
    EndSQL	
	
	DbSelectArea( cAliasTRB )	
	( cAliasTRB )->( DbGoTop() )
	While( ( cAliasTRB )->( .NOT. EOF() ) )
	    
        Aadd( aTempo , {} )
        Aadd( aTempo[ nX ] , ( cAliasTRB )->B1_COD )
        Aadd( aTempo[ nX ] , ( cAliasTRB )->B1_DESC )
        Aadd( aTempo[ nX ] , ( cAliasTRB )->B1_PRV1 )
	        
        nX++
	        
	    ( cAliasTRB )->( DbSkip() ) 
	End

	( cAliasTRB )->( DbCloseArea() )
	
	aItens := Aclone( aTempo )
	oBrowse:SetArray( aItens )
	
	RestArea( aAreaAtu )	

Return( Nil )

/*/{Protheus.doc} SFVALIDCPO

Validação do campo cliente/ficha

@author Otaviano Mattos
@since 16/09/2017
@version 1.0
/*/

Static Function SFVALIDCPO( cGet1 )

	Local lRetorno := .T.

	If( cTpVenda == "Ficha" )
		
		SFCHECKOPEN()
		
		If( .NOT. ExistCpo( "Z03" , oGet1:cText ) .AND. .NOT. Empty( oGet1:cText ) )		
			lRetorno := .F.		
		EndIf
		
	Else
	
		SFCHECKOPEN()
		
		If( .NOT. ExistCpo( "SA1" , oGet1:cText ) .AND. .NOT. Empty( oGet1:cText ) )		
			lRetorno := .F.			   
		EndIf		
		 
	EndIf

Return( lRetorno )

/*/{Protheus.doc} ADDPROD

Adiciono os produtos

@author Otaviano Mattos
@since 16/09/2017
@version 1.0
/*/

Static Function ADDPROD()

	Local nA          := 0
	Local nLinGrid	  := 0
	Local nValUnit	  := 0
	Local nIndice     := 12
	Local cTamCpoPrd  := Space( 13 )
	Local cProduto    := ""
	Local lExiste	  := .F.
	Local lPrimeiro	  := .T.
	Local nPosItem    := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_ITEM" } )
	Local nPosProd    := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_PRODUT" } )
	Local nPosDesc    := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_DESCRI" } )
	Local nPosQuant   := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_QUANT" } )
	Local nPosQtdPg   := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_QTDPAG" } )
	Local nPosQtdSld  := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_QTDSLD" } )
	Local nPosPrcUni  := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_PRCUNI" } )
	Local nPosTotal   := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_TOTAL" } )
	Local nPosVlPago  := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_VLPAGO" } )
	Local nPosSldPag  := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_SLDPAG" } )
	Local nPosQtdInfo := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01QTDINFO" } )
	Local nPosValInfo := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01VALINFO" } )
	
	//Verifico se o produto foi preenchido ou a quantidade informada
	If( nGet1 < 1 .OR. Empty( cGet5 ) )		
		Return( Nil )		
	EndIf
		
	If( cRecebedor <> "Distribuidora" )
	
		If( nGet2 <= 0 )
			
			Help( "" , 1 , "ADDPROD" ,, "Informe o preço unitário antes de continuar." , 1 , 0 )
			Return( Nil )   
			
		EndIf
	
		nIndice    := 1
		cTamCpoPrd := Space( 6 )	
		nValUnit   := nGet2
		
		If( .NOT. ExistCpo( "SB1" , PadR( &( ReadVar() ) , TamSX3( "B1_COD" )[ 1 ] ) , nIndice ) )
			Return( Nil )
		EndIf
	
	Else
		
		nValUnit := Posicione( "SB1" , nIndice , xFilial( "SB1" ) + &( ReadVar() ) , "B1_PRV1" )
		
		If( .NOT. ExistCpo( "SB1" , PadR( &( ReadVar() ) , TamSX3( "B1_COD" )[ 1 ] ) , nIndice ) )
			Return( Nil )
		EndIf		
		
	EndIf
	
	cProduto := AllTrim( Posicione( "SB1" , nIndice , xFilial( "SB1" ) + &( ReadVar() ) , "B1_COD" ) )	
	
	//Verifico se já existe um produto na grid
	If( .NOT. Empty( oGrid:aCols[ 1 ][ nPosItem ] ) )
		lPrimeiro := .F.
	EndIf
	
	If( lPrimeiro )
	
		oGrid:aCols[ 1 ][ 1 ]           := cMarkNo
		oGrid:aCols[ 1 ][ nPosItem   ]  := "001"
		oGrid:aCols[ 1 ][ nPosProd   ]  := cProduto
		oGrid:aCols[ 1 ][ nPosDesc   ]  := Posicione( "SB1" , nIndice , xFilial( "SB1" ) + &( ReadVar() ) , "B1_DESC" )
		oGrid:aCols[ 1 ][ nPosQuant  ]  := nGet1
		oGrid:aCols[ 1 ][ nPosQtdPg  ]  := 0
		oGrid:aCols[ 1 ][ nPosQtdSld ]  := nGet1
		oGrid:aCols[ 1 ][ nPosPrcUni ]  := nValUnit
		oGrid:aCols[ 1 ][ nPosTotal  ]  := nGet1 * nValUnit
		oGrid:aCols[ 1 ][ nPosVlPago ]  := 0
		oGrid:aCols[ 1 ][ nPosSldPag ]  := oGrid:aCols[ 1 ][ nPosTotal  ]
		oGrid:aCols[ 1 ][ nPosQtdInfo ] := 0
		oGrid:aCols[ 1 ][ nPosValInfo ] := 0		
		oGrid:aCols[ 1 ][ Len( oGrid:aHeader ) + 1 ] := .F.
		
		nValTot += nGet1 * oGrid:aCols[ 1 ][ nPosPrcUni  ]
		nSldPag += nGet1 * oGrid:aCols[ 1 ][ nPosPrcUni  ]
		
		oSay11:cCaption := "<font size='03' color='green'>" + Transform( nValTot , "@E 999,999,999.99" ) + "</font><br/>"
		oSay15:cCaption := "<font size='03' color='green'>" + Transform( nSldPag , "@E 999,999,999.99" ) + "</font><br/>"
		oSay16:cCaption := "<font size='03' color='green'>" + Transform( ( nValTot - nSldPag ) , "@E 999,999,999.99" ) + "</font><br/>"					
		
		lPrimeiro := .F.
	
	Else
		
		//Verifico se o produto já existe na grid
		For nA := 1 To Len( oGrid:aCols )
		
			If( cProduto == oGrid:aCols[ nA ][ nPosProd ] .AND. oGrid:aCols[ nA ][ Len( oGrid:aHeader ) + 1 ] )
			
				oGrid:aCols[ nA ][ nPosQuant  ] := nGet1 
				oGrid:aCols[ nA ][ nPosQtdSld ]	:= nGet1
				oGrid:aCols[ nA ][ nPosTotal  ] := oGrid:aCols[ nA ][ nPosQuant  ] * oGrid:aCols[ nA ][ nPosPrcUni ]
				oGrid:aCols[ nA ][ nPosSldPag ] := nGet1 * oGrid:aCols[ nA ][ nPosPrcUni ] 
				
				nValTot += nGet1 * oGrid:aCols[ nA ][ nPosPrcUni ]
				nSldPag += nGet1 * oGrid:aCols[ nA ][ nPosPrcUni ]
			
				oSay11:cCaption := "<font size='03' color='green'>" + Transform( nValTot , "@E 999,999,999.99" ) + "</font><br/>"
				oSay15:cCaption := "<font size='03' color='green'>" + Transform( nSldPag , "@E 999,999,999.99" ) + "</font><br/>"							
				oSay16:cCaption := "<font size='03' color='green'>" + Transform( ( nValTot - nSldPag ) , "@E 999,999,999.99" ) + "</font><br/>"
				
				oGrid:aCols[ nA ][ Len( oGrid:aHeader ) + 1 ] := .F.
								
				//Produto existe na grid
				lExiste := .T.			
			
			ElseIf( cProduto == oGrid:aCols[ nA ][ nPosProd ] )
				
				oGrid:aCols[ nA ][ nPosQuant  ] += nGet1 
				oGrid:aCols[ nA ][ nPosQtdSld ]	+= nGet1
				oGrid:aCols[ nA ][ nPosTotal  ] := oGrid:aCols[ nA ][ nPosQuant  ] * oGrid:aCols[ nA ][ nPosPrcUni ]
				oGrid:aCols[ nA ][ nPosSldPag ] += nGet1 * oGrid:aCols[ nA ][ nPosPrcUni ] 
				
				nValTot += nGet1 * oGrid:aCols[ nA ][ nPosPrcUni ]
				nSldPag += nGet1 * oGrid:aCols[ nA ][ nPosPrcUni ]
			
				oSay11:cCaption := "<font size='03' color='green'>" + Transform( nValTot , "@E 999,999,999.99" ) + "</font><br/>"
				oSay15:cCaption := "<font size='03' color='green'>" + Transform( nSldPag , "@E 999,999,999.99" ) + "</font><br/>"
				oSay16:cCaption := "<font size='03' color='green'>" + Transform( ( nValTot - nSldPag ) , "@E 999,999,999.99" ) + "</font><br/>"							
								
				//Produto existe na grid
				lExiste := .T.
				
			EndIf
		
		Next nA
		
		If( .NOT. lExiste )
		
			//Adiciono uma linha
			aAdd( oGrid:aCols, Array( Len( oGrid:aHeader ) + 1 ) )
		
			nLinGrid := Len( oGrid:aCols )				
		
			oGrid:aCols[ 1 ][ 1 ]                  := cMarkNo
			oGrid:aCols[ nLinGrid ][ nPosItem   ]  := StrZero( nLinGrid , 3 )
			oGrid:aCols[ nLinGrid ][ nPosProd   ]  := cProduto
			oGrid:aCols[ nLinGrid ][ nPosDesc   ]  := Posicione( "SB1" , nIndice , xFilial( "SB1" ) + &( ReadVar() ) , "B1_DESC" )
			oGrid:aCols[ nLinGrid ][ nPosQuant  ]  := nGet1 
			oGrid:aCols[ nLinGrid ][ nPosQtdPg  ]  := 0
			oGrid:aCols[ nLinGrid ][ nPosQtdSld ]  := nGet1			
			oGrid:aCols[ nLinGrid ][ nPosPrcUni ]  := nValUnit
			oGrid:aCols[ nLinGrid ][ nPosTotal  ]  := nGet1 * oGrid:aCols[ nLinGrid ][ nPosPrcUni ]
			oGrid:aCols[ nLinGrid ][ nPosVlPago ]  := 0
			oGrid:aCols[ nLinGrid ][ nPosSldPag ]  := oGrid:aCols[ nLinGrid ][ nPosTotal  ]	
			oGrid:aCols[ nLinGrid ][ nPosQtdInfo ] := 0
			oGrid:aCols[ nLinGrid ][ nPosValInfo ] := 0									
			oGrid:aCols[ nLinGrid ][ Len( oGrid:aHeader ) + 1 ] := .F.		
			
			nValTot += nGet1 * oGrid:aCols[ nLinGrid ][ nPosPrcUni ]
			nSldPag += nGet1 * oGrid:aCols[ nLinGrid ][ nPosPrcUni ]
		
			oSay11:cCaption := "<font size='03' color='green'>" + Transform( nValTot , "@E 999,999,999.99" ) + "</font><br/>"
			oSay15:cCaption := "<font size='03' color='green'>" + Transform( nSldPag , "@E 999,999,999.99" ) + "</font><br/>"
			oSay16:cCaption := "<font size='03' color='green'>" + Transform( ( nValTot - nSldPag ) , "@E 999,999,999.99" ) + "</font><br/>"			
		
		EndIf
	
	EndIf

	oWindCx:Refresh()
	oGrid:Refresh()

	//Retorno a quantidade para 1
	nGet1 := 1
	nGet2 := 0
	
	//Limpo o campo do produto
	cGet5 := cTamCpoPrd
	
	//Volto o foco para o produto
	oGet5:SetFocus()

Return( .T. )

/*/{Protheus.doc} SFCLEAR

Limpo a tela

@author Otaviano Mattos
@since 16/09/2017
@version 1.0
/*/

Static Function SFCLEAR()
	
	Local nTam		 := 0
	Local nCont		 := 0
	Local nPosItem   := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_ITEM" } )
	Local nPosProd   := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_PRODUT" } )
	Local nPosDesc   := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_DESCRI" } )
	Local nPosQuant  := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_QUANT" } )
	Local nPosQtdPg  := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_QTDPAG" } )
	Local nPosQtdSld := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_QTDSLD" } )
	Local nPosPrcUni := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_PRCUNI" } )
	Local nPosTotal  := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_TOTAL" } )
	Local nPosVlPago := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_VLPAGO" } )
	Local nPosSldPag := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_SLDPAG" } )	
	
	DbSelectArea( "Z00" )
	Z00->( DbSetOrder( 1 ) )
	If( Z00->( DbSeek( xFilial( "Z00" ) + cGet0 ) ) )
		
		Z00->( RollBackSX8() )
		
		cGet0  := GetSx8Num( "Z00" , "Z00_CODIGO" )

	EndIf
	
	lClear := .T.	
	
	cGet1  := Space( 6 )
	oCombo1:Select( 1 )
	oCombo2:Select( 1 )
	oCombo3:Select( 1 )
	oCombo4:Select( 1 )
	
	nValTot := 0
	nSldPag := 0
	nVlPag  := 0
	
	oSay11:cCaption := "<font size='03' color='green'>" + Transform( nValTot , "@E 999,999,999.99" ) + "</font><br/>"
	oSay15:cCaption := "<font size='03' color='green'>" + Transform( nSldPag , "@E 999,999,999.99" ) + "</font><br/>"	
	oSay16:cCaption := "<font size='03' color='green'>" + Transform( nVlPag  , "@E 999,999,999.99" ) + "</font><br/>"
	oSay10:cCaption := "<font size='03' color='green'></font><br/>"

	nTam := Len( oGrid:aCols )
	
	If( nTam > 1 )
		
		For nCont := 1 To nTam
		
			If( Len( oGrid:aCols ) > 1 )					
				aDel( oGrid:aCols  , nCont )										
			EndIf
			
		Next nCont  
		
		aSize( oGrid:aCols , 1 )
	
	EndIf	

	oGrid:aCols[ 1 ][ 1 ] := cMarkNo
	oGrid:aCols[ 1 ][ nPosItem   ] := ""
	oGrid:aCols[ 1 ][ nPosProd   ] := ""
	oGrid:aCols[ 1 ][ nPosDesc   ] := ""
	oGrid:aCols[ 1 ][ nPosQuant  ] := 0
	oGrid:aCols[ 1 ][ nPosQtdPg  ] := 0
	oGrid:aCols[ 1 ][ nPosQtdSld ] := 0			
	oGrid:aCols[ 1 ][ nPosPrcUni ] := 0
	oGrid:aCols[ 1 ][ nPosTotal  ] := 0
	oGrid:aCols[ 1 ][ nPosVlPago ] := 0
	oGrid:aCols[ 1 ][ nPosSldPag ] := 0					
	oGrid:aCols[ 1 ][ Len( oGrid:aHeader ) + 1 ] := .F.		

	Z00->( DbCloseArea() )

Return( .T. )

/*/{Protheus.doc} SFSALVAR

Salva a ficha ou venda

@author Otaviano Mattos
@since 16/09/2017
@version 1.0
/*/

Static Function SFSALVAR()

	Local nA		 := 0
	Local lDeletado  := .F.
	Local lContinua  := .F.
	Local cTpVdZ00   := IIf( cTpVenda == "Fiado" , "2" , IIf( cTpVenda == "Ficha" , "3" , "1" ) )
	Local cRecbZ00   := IIf( cRecebedor == "Distribuidora" , "1" , IIf( cRecebedor == "Espetinho" , "2" , "3" ) )
	Local cForPgZ00  := IIf( cFormaPagto == "Dinheiro" , "1" , IIf( cFormaPagto == "Cartão de Crédito" , "2" , "3" ) )
	Local cConsZ00   := IIf( cPerda == "Sim" , "2" , "1" )
	Local nPosItem   := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_ITEM" } )
	Local nPosProd   := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_PRODUT" } )
	Local nPosDesc   := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_DESCRI" } )
	Local nPosQuant  := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_QUANT" } )
	Local nPosQtdPg  := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_QTDPAG" } )
	Local nPosQtdSld := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_QTDSLD" } )
	Local nPosPrcUni := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_PRCUNI" } )
	Local nPosTotal  := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_TOTAL" } )
	Local nPosVlPago := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_VLPAGO" } )
	Local nPosSldPag := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_SLDPAG" } )		

	If( Empty( cGet1 ) )
	
		Help( "" , 1 , "SFFINALIZAR" ,, "Informe uma ficha ou cliente antes de continuar." , 1 , 0 )   
		Return( Nil )
	
	EndIf
	
	For nA := 1 To Len( oGrid:aCols )
	
		lDeletado := oGrid:aCols[ nA ][ Len( oGrid:aHeader ) + 1 ]
		
		If( .NOT. lDeletado )
		
			If( .NOT. Empty( oGrid:aCols[ nA ][ 3 ] ) )
				lContinua := .T.
			EndIf
		
		EndIf
	
	Next nA
	
	If( .NOT. lContinua )
		
		Help( "" , 1 , "SFFINALIZAR" ,, "Informe um item antes de continuar." , 1 , 0 )   
		Return( Nil )
		
	EndIf

	Begin Transaction

	//If( cTpVenda == "Ficha" .OR. cTpVenda == "Fiado" )
		
		DbSelectArea( "Z00" )
		DbSelectArea( "Z01" )
		Z00->( DbSetOrder( 1 ) )
		Z01->( DbSetOrder( 1 ) )
			
		If( Z00->( DbSeek( xFilial( "Z00" ) + cGet0 + "A" ) ) )
		
			For nA := 1 To Len( oGrid:aCols )
				
				If( Z01->( DbSeek( xFilial( "Z01" ) + cGet0 + oGrid:aCols[ nA ][ nPosItem ] ) ) )
				
					lDeletado := oGrid:aCols[ nA ][ Len( oGrid:aHeader ) + 1 ]
					
					If( lDeletado )
					
						If( Reclock( "Z01" , .F. ) )
							
							Z01->( DbDelete() )
							
							Z01->( MsUnlock() )
							
						EndIf
					
						Loop
					
					EndIf				
				
					If( Reclock( "Z01" , .F. ) )
						
						Z01->Z01_QUANT  := oGrid:aCols[ nA ][ nPosQuant ]
						Z01->Z01_QTDSLD := ( oGrid:aCols[ nA ][ nPosQuant ] - oGrid:aCols[ nA ][ nPosQtdPg ] )
						Z01->Z01_PRCUNI := oGrid:aCols[ nA ][ nPosPrcUni ] 
						Z01->Z01_TOTAL  := oGrid:aCols[ nA ][ nPosTotal ]
						Z01->Z01_SLDPAG := ( oGrid:aCols[ nA ][ nPosTotal ] - oGrid:aCols[ nA ][ nPosVlPago ] )
						
						Z01->( MsUnlock() )
					
					EndIf
				
				Else
				
					lDeletado := oGrid:aCols[ nA ][ Len( oGrid:aHeader ) + 1 ]
				
					If( lDeletado )
						Loop
					EndIf
				
					If( Reclock( "Z01" , .T. ) )
						
						Z01->Z01_FILIAL := xFilial( "Z01" )
						Z01->Z01_CODIGO := cGet0
						Z01->Z01_ITEM	:= oGrid:aCols[ nA ][ nPosItem ]
						Z01->Z01_PRODUT := oGrid:aCols[ nA ][ nPosProd ]
						Z01->Z01_DESCRI := oGrid:aCols[ nA ][ nPosDesc ]
						Z01->Z01_QUANT  := oGrid:aCols[ nA ][ nPosQuant ]
						Z01->Z01_QTDPAG := 0
						Z01->Z01_QTDSLD := oGrid:aCols[ nA ][ nPosQuant ]
						Z01->Z01_PRCUNI := oGrid:aCols[ nA ][ nPosPrcUni ] 
						Z01->Z01_TOTAL  := oGrid:aCols[ nA ][ nPosTotal ]
						Z01->Z01_VLPAGO := 0
						Z01->Z01_SLDPAG := oGrid:aCols[ nA ][ nPosTotal ]
						
						Z01->( MsUnlock() )
					
					EndIf									
						
				EndIf			
				
			Next nA		
		
		Else
		
			If( Reclock( "Z00" , .T. ) )
			
				Z00->Z00_FILIAL := xFilial( "Z00" )
				Z00->Z00_CODIGO := cGet0
				Z00->Z00_CLIENT := cGet1
				Z00->Z00_LOJA   := "01"
				Z00->Z00_NOME   := Posicione( "SA1" , 1 , xFilial( "SA1" ) + cGet1 + "01" , "A1_NOME" )
				Z00->Z00_DATA   := Date()
				Z00->Z00_TIPOVD := cTpVdZ00
				Z00->Z00_RECEB  := cRecbZ00
				Z00->Z00_FORMPG := cForPgZ00
				Z00->Z00_CONSUM := cConsZ00
				Z00->Z00_HORA   := Time()
				
				If( cTpVenda == "Venda" )
					Z00->Z00_STATUS := "F"
				Else
					Z00->Z00_STATUS := "A"
				EndIf
			
				Z00->( MsUnlock() )
				
			EndIf
					
			For nA := 1 To Len( oGrid:aCols )
				
				lDeletado := oGrid:aCols[ nA ][ Len( oGrid:aHeader ) + 1 ]
				
				If( lDeletado )
					Loop
				EndIf				
				
				If( Reclock( "Z01" , .T. ) )
					
					If( cTpVenda == "Venda" )
						
						Z01->Z01_FILIAL := xFilial( "Z01" )
						Z01->Z01_CODIGO := cGet0
						Z01->Z01_ITEM	:= oGrid:aCols[ nA ][ nPosItem ]
						Z01->Z01_PRODUT := oGrid:aCols[ nA ][ nPosProd ]
						Z01->Z01_DESCRI := oGrid:aCols[ nA ][ nPosDesc ]
						Z01->Z01_QUANT  := oGrid:aCols[ nA ][ nPosQuant ]
						Z01->Z01_QTDPAG := oGrid:aCols[ nA ][ nPosQuant ]
						Z01->Z01_QTDSLD := 0
						Z01->Z01_PRCUNI := oGrid:aCols[ nA ][ nPosPrcUni ] 
						Z01->Z01_TOTAL  := oGrid:aCols[ nA ][ nPosTotal ]
						Z01->Z01_VLPAGO := oGrid:aCols[ nA ][ nPosTotal ]
						Z01->Z01_SLDPAG := 0						
						
					Else
						
						Z01->Z01_FILIAL := xFilial( "Z01" )
						Z01->Z01_CODIGO := cGet0
						Z01->Z01_ITEM	:= oGrid:aCols[ nA ][ nPosItem ]
						Z01->Z01_PRODUT := oGrid:aCols[ nA ][ nPosProd ]
						Z01->Z01_DESCRI := oGrid:aCols[ nA ][ nPosDesc ]
						Z01->Z01_QUANT  := oGrid:aCols[ nA ][ nPosQuant ]
						Z01->Z01_QTDPAG := 0
						Z01->Z01_QTDSLD := oGrid:aCols[ nA ][ nPosQuant ]
						Z01->Z01_PRCUNI := oGrid:aCols[ nA ][ nPosPrcUni ] 
						Z01->Z01_TOTAL  := oGrid:aCols[ nA ][ nPosTotal ]
						Z01->Z01_VLPAGO := 0
						Z01->Z01_SLDPAG := oGrid:aCols[ nA ][ nPosTotal ]						
						
					EndIf
					
					Z01->( MsUnlock() )
				
				EndIf					
				
			Next nA
			
			//Salvo o número utilizado e busco um novo
			Z00->( ConfirmSX8() )
				
			cGet0 := GetSx8Num( "Z00" , "Z00_CODIGO" )
			
		EndIf
		
		MsgInfo( "Venda salva com sucesso!" , "Sucesso" )
		
		If( .NOT. lVendaFinal )
		
			SFCLEAR()
			SFADDLIST()
			
		EndIf
		
		Z00->( DbCloseArea() )
		Z01->( DbCloseArea() )
		
	//Else
	//	Help( "" , 1 , "SFSALVAR" ,, "Não é possível salvar vendas Venda." , 1 , 0 )   
	//EndIf

	End Transaction

Return( .T. )

/*/{Protheus.doc} SFADDLIST

Adiciona a lista das fichas ativas

@author Otaviano Mattos
@since 16/09/2017
@version 1.0
/*/

Static Function SFADDLIST()

	Local cAliasTRB := GetNextAlias()

	If( Select( cAliasTRB ) > 0 )
		( cAliasTRB )->( DbCloseArea() )
	EndIf

	BeginSql Alias cAliasTRB

		SELECT DISTINCT Z00_CLIENT FROM %TABLE:Z00% Z00
		INNER JOIN %TABLE:Z01% Z01
			ON Z00_FILIAL = Z01_FILIAL
			AND Z00_CODIGO = Z01_CODIGO
		WHERE Z00_TIPOVD = '3'
		AND   Z00_STATUS = 'A'
		AND   Z01_SLDPAG > 0
		AND Z00.%NOTDEL%
		AND Z01.%NOTDEL%
	
	EndSql

	//Limpo a list
	oLstCta:Reset()

	DbSelectArea( cAliasTRB )
	( cAliasTRB )->( DbGoTop() )
	While ( cAliasTRB )->( .NOT. EOF() )

		oLstCta:Add( ( cAliasTRB )->Z00_CLIENT )
	
		( cAliasTRB )->( DbSkip() )
	
	End

	( cAliasTRB )->( DbCloseArea() )

Return( Nil )

/*/{Protheus.doc} SFCHECKOPEN

Verifico se já existe algo lançado para está ficha ou cliente

@author Otaviano Mattos
@since 16/09/2017
@version 1.0
/*/

Static Function SFCHECKOPEN()

	Local lFirst      := .T.
	Local nTam		  := 0
	Local nCont		  := 0
	Local nLinGrid    := 0
	Local cTpVdZ00    := IIf( cTpVenda == "Fiado" , "2" , IIf( cTpVenda == "Ficha" , "3" , "1" ) )
	Local cAliasTRB   := GetNextAlias()
	Local nPosItem    := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_ITEM" } )
	Local nPosProd    := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_PRODUT" } )
	Local nPosDesc    := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_DESCRI" } )
	Local nPosQuant   := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_QUANT" } )
	Local nPosQtdPg   := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_QTDPAG" } )
	Local nPosQtdSld  := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_QTDSLD" } )
	Local nPosPrcUni  := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_PRCUNI" } )
	Local nPosTotal   := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_TOTAL" } )
	Local nPosVlPago  := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_VLPAGO" } )
	Local nPosSldPag  := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_SLDPAG" } )	
	Local nPosQtdInfo := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01QTDINFO" } )
	Local nPosValInfo := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01VALINFO" } )	

	//If( cTpVenda == "Ficha" )
	
		lCheckOpen := .T.
	
		If( Select( cAliasTRB ) > 0 )
			( cAliasTRB )->( DbCloseArea() )
		EndIf
	
		BeginSql Alias cAliasTRB
		
			SELECT * FROM %TABLE:Z00% Z00
			INNER JOIN %TABLE:Z01% Z01
				ON Z00_FILIAL = Z01_FILIAL
				AND Z00_CODIGO = Z01_CODIGO
			WHERE Z00_CLIENT = %Exp:cGet1%
			AND Z00_TIPOVD = %Exp:cTpVdZ00%
			AND Z00_STATUS = "A"
			AND Z00.%NOTDEL%
			AND Z01.%NOTDEL%
			ORDER BY Z01_CODIGO, Z01_ITEM
		
		EndSql

		nTam := Len( oGrid:aCols )
    		
		If( nTam > 1 )
				
			For nCont := 1 To nTam
				
				If( Len( oGrid:aCols ) > 1 )					
					aDel( oGrid:aCols  , nCont )										
				EndIf
				
			Next nCont  
				
			aSize( oGrid:aCols , 1 )
			
		EndIf	
	
		
		oGrid:aCols[ 1 ][ nPosItem   ]  := ""
		oGrid:aCols[ 1 ][ nPosProd   ]  := ""
		oGrid:aCols[ 1 ][ nPosDesc   ]  := ""
		oGrid:aCols[ 1 ][ nPosQuant  ]  := 0
		oGrid:aCols[ 1 ][ nPosQtdPg  ]  := 0
		oGrid:aCols[ 1 ][ nPosQtdSld ]  := 0			
		oGrid:aCols[ 1 ][ nPosPrcUni ]  := 0
		oGrid:aCols[ 1 ][ nPosTotal  ]  := 0
		oGrid:aCols[ 1 ][ nPosVlPago ]  := 0
		oGrid:aCols[ 1 ][ nPosSldPag ]  := 0					
		oGrid:aCols[ 1 ][ nPosQtdInfo ] := 0
		oGrid:aCols[ 1 ][ nPosValInfo ] := 0							
		oGrid:aCols[ 1 ][ Len( oGrid:aHeader ) + 1 ] := .F.		
		
		nValTot := 0
		nSldPag := 0 
			
		oSay11:cCaption := "<font size='03' color='green'>" + Transform( nValTot , "@E 999,999,999.99" ) + "</font><br/>"
		oSay15:cCaption := "<font size='03' color='green'>" + Transform( nSldPag , "@E 999,999,999.99" ) + "</font><br/>"							
		oSay16:cCaption := "<font size='03' color='green'>" + Transform( ( nValTot - nSldPag ) , "@E 999,999,999.99" ) + "</font><br/>"
	
		DbSelectArea( cAliasTRB )
		( cAliasTRB )->( DbGoTop() )
		While ( cAliasTRB )->( .NOT. EOF() )

			If( lFirst )

				cGet0 := ( cAliasTRB )->Z00_CODIGO
				cGet1 := ( cAliasTRB )->Z00_CLIENT
				oCombo1:Select( Val( ( cAliasTRB )->Z00_TIPOVD ) )
				oCombo2:Select( Val( ( cAliasTRB )->Z00_RECEB  ) )
				oCombo3:Select( Val( ( cAliasTRB )->Z00_FORMPG ) )
				oCombo4:Select( Val( ( cAliasTRB )->Z00_CONSUM ) )

				oGrid:aCols[ 1 ][ 1 ]           := cMarkNo
				oGrid:aCols[ 1 ][ nPosItem   ]  := ( cAliasTRB )->Z01_ITEM
				oGrid:aCols[ 1 ][ nPosProd   ]  := ( cAliasTRB )->Z01_PRODUT
				oGrid:aCols[ 1 ][ nPosDesc   ]  := ( cAliasTRB )->Z01_DESCRI
				oGrid:aCols[ 1 ][ nPosQuant  ]  := ( cAliasTRB )->Z01_QUANT
				oGrid:aCols[ 1 ][ nPosQtdPg  ]  := ( cAliasTRB )->Z01_QTDPAG
				oGrid:aCols[ 1 ][ nPosQtdSld ]  := ( cAliasTRB )->Z01_QTDSLD
				oGrid:aCols[ 1 ][ nPosPrcUni ]  := ( cAliasTRB )->Z01_PRCUNI
				oGrid:aCols[ 1 ][ nPosTotal  ]  := ( cAliasTRB )->Z01_TOTAL
				oGrid:aCols[ 1 ][ nPosVlPago ]  := ( cAliasTRB )->Z01_VLPAGO
				oGrid:aCols[ 1 ][ nPosSldPag ]  := ( cAliasTRB )->Z01_SLDPAG	
				oGrid:aCols[ 1 ][ nPosQtdInfo ] := 0
				oGrid:aCols[ 1 ][ nPosValInfo ] := 0												
				oGrid:aCols[ 1 ][ Len( oGrid:aHeader ) + 1 ] := .F.
				
				nValTot += nGet1 * oGrid:aCols[ 1 ][ nPosTotal  ]
				nSldPag += nGet1 * oGrid:aCols[ 1 ][ nPosSldPag ]
				
				oSay11:cCaption := "<font size='03' color='green'>" + Transform( nValTot , "@E 999,999,999.99" ) + "</font><br/>"
				oSay15:cCaption := "<font size='03' color='green'>" + Transform( nSldPag , "@E 999,999,999.99" ) + "</font><br/>"
				oSay16:cCaption := "<font size='03' color='green'>" + Transform( ( nValTot - nSldPag ) , "@E 999,999,999.99" ) + "</font><br/>"					
				
				lFirst := .F.
			
			Else
			
				//Adiciono uma linha
				aAdd( oGrid:aCols, Array( Len( oGrid:aHeader ) + 1 ) )
			
				nLinGrid := Len( oGrid:aCols )							
			
				oGrid:aCols[ nLinGrid ][ 1 ]           := cMarkNo
				oGrid:aCols[ nLinGrid ][ nPosItem   ]  := ( cAliasTRB )->Z01_ITEM
				oGrid:aCols[ nLinGrid ][ nPosProd   ]  := ( cAliasTRB )->Z01_PRODUT
				oGrid:aCols[ nLinGrid ][ nPosDesc   ]  := ( cAliasTRB )->Z01_DESCRI
				oGrid:aCols[ nLinGrid ][ nPosQuant  ]  := ( cAliasTRB )->Z01_QUANT
				oGrid:aCols[ nLinGrid ][ nPosQtdPg  ]  := ( cAliasTRB )->Z01_QTDPAG
				oGrid:aCols[ nLinGrid ][ nPosQtdSld ]  := ( cAliasTRB )->Z01_QTDSLD
				oGrid:aCols[ nLinGrid ][ nPosPrcUni ]  := ( cAliasTRB )->Z01_PRCUNI
				oGrid:aCols[ nLinGrid ][ nPosTotal  ]  := ( cAliasTRB )->Z01_TOTAL
				oGrid:aCols[ nLinGrid ][ nPosVlPago ]  := ( cAliasTRB )->Z01_VLPAGO
				oGrid:aCols[ nLinGrid ][ nPosSldPag ]  := ( cAliasTRB )->Z01_SLDPAG	
				oGrid:aCols[ nLinGrid ][ nPosQtdInfo ] := 0
				oGrid:aCols[ nLinGrid ][ nPosValInfo ] := 0												
				oGrid:aCols[ nLinGrid ][ Len( oGrid:aHeader ) + 1 ] := .F.
				
				nValTot += oGrid:aCols[ nLinGrid ][ nPosTotal  ]
				nSldPag += oGrid:aCols[ nLinGrid ][ nPosSldPag ]
				
				oSay11:cCaption := "<font size='03' color='green'>" + Transform( nValTot , "@E 999,999,999.99" ) + "</font><br/>"
				oSay15:cCaption := "<font size='03' color='green'>" + Transform( nSldPag , "@E 999,999,999.99" ) + "</font><br/>"
				oSay16:cCaption := "<font size='03' color='green'>" + Transform( ( nValTot - nSldPag ) , "@E 999,999,999.99" ) + "</font><br/>"								
				
			EndIf			 			
		
			( cAliasTRB )->( DbSkip() )
		
		End
	
		oWindCx:Refresh()
		oGrid:Refresh()	
	
		( cAliasTRB )->( DbCloseArea() )
		
	//EndIf

Return( Nil )

/*/{Protheus.doc} SFMARCA

Tratamento da marcação do registro

@author Otaviano Mattos
@since 30/09/2017
@version 1.0
/*/

Static Function SFMARCA()

	Local nPosVlSel  := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01VALINFO" } )
	Local nPosQtdSel := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01QTDINFO" } )	

	If( Empty( oGrid:aCols[ oGrid:nAt ][ 2 ] ) )
		Return( Nil )
	EndIf

    //Se NÃO estiver marcado, passa a ser marcado.    
    If( oGrid:aCols[ oGrid:nAt ][ 1 ] = cMarkNo )
                
    	oGrid:aCols[ oGrid:nAt ][ 1 ] := cMarkOk
    	
    	//Tela para o lançamento da quantidade a ser paga
    	SFQTDFAT()
    	    	    	
    Else
        
    	oGrid:aCols[ oGrid:nAt ][ 1 ] := cMarkNo
    	
		oGrid:aCols[ oGrid:nAt ][ nPosQtdSel ] := 0
		oGrid:aCols[ oGrid:nAt ][ nPosVlSel  ] := 0    	
    	
	EndIf     

Return( Nil )

/*/{Protheus.doc} SFFINALIZAR

Tratamento da marcação do registro

@author Otaviano Mattos
@since 30/09/2017
@version 1.0
/*/

Static Function SFFINALIZAR()

	Local lVendaCheia    := .T.
	Local lContinua		 := .F.
	Local lFinalizaVenda := .F.
	Local lDeletado		 := .F.
	Local nA			 := 0
	
	If( Empty( cGet1 ) )
	
		Help( "" , 1 , "SFFINALIZAR" ,, "Informe uma ficha ou cliente antes de continuar." , 1 , 0 )   
		Return( Nil )
	
	EndIf
	
	For nA := 1 To Len( oGrid:aCols )
	
		lDeletado := oGrid:aCols[ nA ][ Len( oGrid:aHeader ) + 1 ]
		
		If( .NOT. lDeletado )
		
			If( .NOT. Empty( oGrid:aCols[ nA ][ 3 ] ) )
				lContinua := .T.
			EndIf
		
		EndIf
	
	Next nA
	
	If( .NOT. lContinua )
		
		Help( "" , 1 , "SFFINALIZAR" ,, "Informe um item antes de continuar." , 1 , 0 )   
		Return( Nil )
		
	EndIf
	
	lVendaCheia := SFCHECKCOMPLETE()
	
	If( lVendaCheia )
	
		If( MsgYesNo( "Todos os itens da venda serão faturados, deseja continuar?" , "Atenção" ) )
			lFinalizaVenda := .T.
		EndIf

	Else
	
		If( MsgYesNo( "Os itens selecionados serão faturados, deseja continuar?" , "Atenção" ) )
			lFinalizaVenda := .T.
		EndIf	
	
	EndIf

	If( lFinalizaVenda )
	
		lVendaFinal := .T.
		SFSALVAR()
	
		If( lVendaCheia )		
			Processa( { || SFVENDACHEIA() } , "Aguarde..." , "Lançando os itens..." , .F. )			
		Else
			Processa( { || SFVENDAPARCIAL() } , "Aguarde..." , "Lançando os itens..." , .F. )
		EndIf
	
		lVendaFinal := .F.
		SFADDLIST()
		SFCLEAR()
	
	EndIf

Return( Nil )

/*/{Protheus.doc} SFCHECKCOMPLETE

Verifico se o faturamento será completo ou parcial

@author Otaviano Mattos
@since 30/09/2017
@version 1.0
/*/

Static Function SFCHECKCOMPLETE()

	Local lRetorno := .T.
	Local nA	   := 0
	
	For nA := 1 To Len( oGrid:aCols )
	
		If( oGrid:aCols[ nA ][ 1 ] <> cMarkNo )
			Return( .F. )
		EndIf
	
	Next nA

Return( lRetorno )

/*/{Protheus.doc} SFQTDFAT

Informa a quantidade do item a ser faturada

@author Otaviano Mattos
@since 16/09/2017
@version 1.0
/*/

Static Function SFQTDFAT()

	Local oWinLcto   := Nil
	Local oTSay2     := Nil
	Local oQuantFin	 := Nil
	Local oFont1	 := Nil
	Local oButtonOk  := Nil
	Local lHasButton := .T.
	Local nOpcaoOk   := 0
	Local nPosVlSel  := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01VALINFO" } )
	Local nPosQtdSel := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01QTDINFO" } )	
	Local nPosQtdSld := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_QTDSLD" } )
	Local nPosPrcUni := aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_PRCUNI" } )
	
	oFont1 := TFont():New( "Arial" ,, -20 , .F. )
	
	//Desabilito o F4
	SetKey( VK_F4 , { || } )
	
	//Cria uma Dialog	
	oWinLcto := MsDialog():New( 100 , 50 , 400 , 700 , "Lançamento" ,,,,,,,,, .T. )	
		
	oQuantFin := TSay():New( 005 , 100  , { | | "<font size='20' color='blue'>Quantidade</font><br/>" } , oWinLcto ,, oFont1 ,,,, .T. , CLR_BLACK , CLR_WHITE , 200 , 30 ,,,,,, .T. )
			
	oGet7 := TGet():New( 035 , 009 , { | u | If( PCount() == 0 , nGet3 , nGet3 := u ) } , oWinLcto , 300 , 050 , "@E 9999999" , { | |  } , 0 , 16777215 ,, .F. ,, .T. ,, .F. ,, .F. , .F. ,, .F. , .F. ,, "nGet3" ,,,, lHasButton  )
	oGet7:setCSS( "QLineEdit{color:black; background-color:white; font-size:72px; }" )	

    oTButton1 := TButton():New( 090 , 009 , "CONFIRMAR" , oWinLcto , { || IIf( nGet3 > 0 , IIf( nGet3 > oGrid:aCols[ oGrid:nAt ][ nPosQtdSld ] , ( nOpcaoOk := 0 , MsgAlert( "A quantidade informada não deve ser maior do que " + cValToChar( oGrid:aCols[ oGrid:nAt ][ nPosQtdSld ] ) ) ) , ( nOpcaoOk := 1 , oWinLcto:End() ) ) , ( nOpcaoOk := 0 , MsgAlert( "Informe a quantidade antes de continuar!" ) ) ) } , 300 , 050 ,,, .F. , .T. , .F. ,, .F. ,,, .F.  )
			
	//Exibe a Dialog	
	oWinLcto:Activate( ,,, .T. )	
	
	SetKey( VK_F4, { || IIf( Empty( oGet1:cText ) , Help( "" , 1 , "DSFATA01" ,, "Preencha o cliente/ficha antes de continuar." , 1 , 0 ) , SFLANCTO() ) } )
	
	//Desmarco o item caso a quantidade do mesmo não seja informada
	If( nGet3 <= 0 .OR. nGet3 > oGrid:aCols[ oGrid:nAt ][ nPosQtdSld ] )
		oGrid:aCols[ oGrid:nAt ][ 1 ] := cMarkNo
	Else
	
		oGrid:aCols[ oGrid:nAt ][ nPosQtdSel ] := nGet3
		oGrid:aCols[ oGrid:nAt ][ nPosVlSel  ] := ( nGet3 * oGrid:aCols[ oGrid:nAt ][ nPosPrcUni ] )
		
	EndIf

	nGet3 := 0

Return( Nil )

/*/{Protheus.doc} SFVENDACHEIA

Venda completa

@author Otaviano Mattos
@since 30/09/2017
@version 1.0
/*/

Static Function SFVENDACHEIA()

	Local cAliasTRB 	:= GetNextAlias()
	Private lMsErroAuto := .F.
	
	If( Select( cAliasTRB ) > 0 )
		( cAliasTRB )->( DbCloseArea() )
	EndIf

	BeginSql Alias cAliasTRB
	
		SELECT Z01_TOTAL, Z01.R_E_C_N_O_ AS Z01RECNO, Z00.R_E_C_N_O_ AS Z00RECNO FROM %TABLE:Z00% Z00
		INNER JOIN %TABLE:Z01% Z01
			ON Z00_FILIAL = Z01_FILIAL
			AND Z00_CODIGO = Z01_CODIGO
		WHERE Z00_CODIGO = %Exp:cGet0%
		AND Z00_STATUS = "A"
		AND Z00.%NOTDEL%
		AND Z01.%NOTDEL%	
		
	EndSql

	DbSelectArea( cAliasTRB )
	( cAliasTRB )->( DbGoTop() )
	While ( cAliasTRB )->( .NOT. EOF() )
		
		Z01->( DbGoTo( ( cAliasTRB )->Z01RECNO ) )
		Z00->( DbGoTo( ( cAliasTRB )->Z00RECNO ) )
	
		If( Reclock( "Z00" , .F. ) )
		
			Z00->Z00_STATUS := "F"
			
			Z00->( MsUnlock() )
		
		EndIf	
	
		If( Reclock( "Z01" , .F. ) )
		
			Z01->Z01_QTDPAG := Z01->Z01_QTDSLD
			Z01->Z01_QTDSLD := 0
			Z01->Z01_VLPAGO := Z01->Z01_SLDPAG
			Z01->Z01_SLDPAG := 0
			
			Z01->( MsUnlock() )
		
		EndIf
	
		( cAliasTRB )->( DbSkip() )
	
	End

	( cAliasTRB )->( DbCloseArea() )
	
Return( .T. )

/*/{Protheus.doc} SFVENDAPARCIAL

Venda parcial

@author Otaviano Mattos
@since 30/09/2017
@version 1.0
/*/

Static Function SFVENDAPARCIAL()

	Local cAliasTRB 	:= GetNextAlias()
	Local nA			:= 0
	Local lFinal		:= .T.
	Local nPosItem   	:= aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_ITEM" } )
	Local nPosQtdInfo 	:= aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01QTDINFO" } )
	Local nPosValInfo 	:= aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01VALINFO" } )
	Local nPosQtdSld 	:= aScan( aHeader , { | x | AllTrim( x[ 2 ] ) == "Z01_QTDSLD" } )					
	Private lMsErroAuto := .F.
	
	DbSelectArea( "Z00" )
	DbSelectArea( "Z01" )
	
	Z00->( DbSetOrder( 1 ) )
	Z01->( DbSetOrder( 1 ) )
	
	For nA := 1 To Len( oGrid:aCols )
		
		If( Z01->( DbSeek( xFilial( "Z01" ) + cGet0 + oGrid:aCols[ nA ][ nPosItem ] ) ) )
		
			If( oGrid:aCols[ nA ][ nPosQtdInfo ] > 0 )
		
				If( Reclock( "Z01" , .F. ) )
				
					Z01->Z01_QTDPAG += oGrid:aCols[ nA ][ nPosQtdInfo ]
					Z01->Z01_QTDSLD -= oGrid:aCols[ nA ][ nPosQtdInfo ]
					Z01->Z01_VLPAGO += oGrid:aCols[ nA ][ nPosValInfo ]
					Z01->Z01_SLDPAG -= oGrid:aCols[ nA ][ nPosValInfo ]
					
					Z01->( MsUnlock() )
				
				EndIf
			
			EndIf
			
			If( Z01->Z01_QTDSLD > 0 )
				lFinal := .F.
			EndIf	
	
		EndIf
	
	Next nA

	If( lFinal )
	
		If( Z00->( DbSeek( xFilial( "Z00" ) + cGet0 + "A" ) ) )
		
			If( Reclock( "Z00" , .F. ) )
				
				Z00->Z00_STATUS := "F"
					
				Z00->( MsUnlock() )
				
			EndIf
		
		EndIf
	
	EndIf

Return( .T. )