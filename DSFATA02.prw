#Include "Protheus.ch"
#Include "FWMVCDef.ch"
#Include "topconn.ch"
#Include "TbiConn.ch"

/*/{Protheus.doc} DSFATA02

Cadastro de Ficha

@author Otaviano Mattos
@since 17/09/2017
@version 1.0
@return Nil, Nulo
/*/

User Function DSFATA02()
	
	Local oMBrowse	:= Nil
	
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "Z03" )
	oMBrowse:SetMenuDef( "DSFATA02" )
	oMBrowse:SetDescription( "Cadastro de Ficha" )
	oMBrowse:Activate()
	
Return( Nil )

/*/{Protheus.doc} MenuDef

Menu da rotina

@author Otaviano Mattos
@since 17/09/2017
@version 1.0
@return Nil, Nulo
/*/

Static Function MenuDef()    
	
	Local aRotina := {}

	aAdd( aRotina, { "Pesquisar"  , "PesqBrw"          , 0 , 1 , 0 , .T. } )
	aAdd( aRotina, { "Visualizar" , "ViewDef.DSFATA02" , 0 , 2 , 0 , Nil } )
	aAdd( aRotina, { "Incluir"    , "ViewDef.DSFATA02" , 0 , 3 , 0 , Nil } )
	aAdd( aRotina, { "Alterar"    , "ViewDef.DSFATA02" , 0 , 4 , 0 , Nil } )
	aAdd( aRotina, { "Excluir"    , "ViewDef.DSFATA02" , 0 , 5 , 0 , Nil } )

Return( aRotina )

/*/{Protheus.doc} ModelDef

Modelo de dados

@author Otaviano Mattos
@since 17/09/2017
@version 1.0
@return Nil, Nulo
/*/
	
Static Function ModelDef()
	
	Local oStruZ03 := FWFormStruct( 1 , "Z03" )
	Local oModel   := MPFormModel():New( "FATA02PE" )
	
	oModel:AddFields( "Z03UNICO" , Nil , oStruZ03 )
	
	oModel:SetPrimaryKey( { "Z03_FILIAL" , "Z03_FICHA" } )
	
	oModel:SetDescription( "Ficha" )
	
	oModel:GetModel( "Z03UNICO" )
	
Return( oModel )

/*/{Protheus.doc} ViewDef

Visao de dados

@author Otaviano Mattos
@since 17/09/2017
@version 1.0
@return Nil, Nulo
/*/

Static Function ViewDef()

	Local oStruZ03 := FWFormStruct( 2 , "Z03" )
	Local oModel   := FWLoadModel( "DSFATA02" )
	Local oView    := FWFormView():New()
	
	oView:SetModel( oModel )
	
	oView:AddField( "VIEW_Z03" , oStruZ03 , "Z03UNICO" )
	
	oView:CreateHorizontalBox( "UNICO" , 100 )
	
	oView:SetOwnerView( "VIEW_Z03" , "UNICO" )
	
	oView:SetCloseOnOk( { || .T. } )

Return( oView )