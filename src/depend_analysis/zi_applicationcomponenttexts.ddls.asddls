@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Application component texts'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.dataCategory:#TEXT
@ObjectModel.representativeKey: 'ApplicationComponent'
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@VDM.viewType: #BASIC
define view entity ZI_ApplicationComponentTexts
  as select from df14t
  association [0..1] to I_Language as _Language on $projection.Language = _Language.Language
{
      @ObjectModel.foreignKey.association: '_Language'
      @Semantics.language: true
  key langu   as Language,
  key fctr_id as ApplicationComponent,
      @Semantics.text: true
      name    as ApplicationComponentName,
      _Language
}
where
      addon    = ''
  and as4local = 'A'
