@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Texts for packages'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.dataCategory: #TEXT
@ObjectModel.representativeKey: 'ABAPPackage'
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #META
}
@VDM.viewType: #BASIC
define view entity ZI_ABAPPackageTexts
  as select from tdevct
  association [0..1] to I_Language as _Language on $projection.Language = _Language.Language
{
  key devclass as ABAPPackage,
      @ObjectModel.foreignKey.association: '_Language'
      @Semantics.language: true
  key spras    as Language,
      @Semantics.text: true
      ctext    as Text,
      _Language
}
