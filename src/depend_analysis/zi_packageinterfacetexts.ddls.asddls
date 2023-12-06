@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Package interface texts'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.dataCategory: #TEXT
@ObjectModel.representativeKey: 'InterfaceName'
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #META
}
@VDM.viewType: #BASIC
define view entity ZI_PackageInterfaceTexts
  as select from intftext
  association [0..1] to I_Language as _Language on _Language.Language = $projection.Language
{
  key intf_name as InterfaceName,
      @ObjectModel.foreignKey.association: '_Language'
      @Semantics.language: true
  key langu     as Language,
      @Semantics.text: true
      descript  as Description,
      _Language
}
