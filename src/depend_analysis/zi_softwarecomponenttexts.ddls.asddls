@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Software component texts'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.dataCategory: #TEXT
@ObjectModel.representativeKey: 'SoftwareComponent'
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@VDM.viewType: #BASIC
define view entity ZI_SoftwareComponentTexts
  as select from cvers_ref
  association [0..1] to I_Language as _Language on $projection.Language = _Language.Language
{
  key component as SoftwareComponent,
      @ObjectModel.foreignKey.association: '_Language'
      @Semantics.language: true
  key langu     as Language,
      @Semantics.text: true
      desc_text as DescriptionText,
      _Language
}
