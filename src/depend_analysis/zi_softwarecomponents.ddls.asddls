@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Software components'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.representativeKey: 'SoftwareComponent'
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@VDM.viewType: #BASIC
define view entity ZI_SoftwareComponents
  as select from cvers
  association [0..1] to ZI_SoftwareComponentTexts as _Text on _Text.SoftwareComponent = $projection.SoftwareComponent
  with default filter _Text.Language = $session.system_language
{
      @ObjectModel.text.association: '_Text'
  key component  as SoftwareComponent,
      release    as SapRelease,
      extrelease as PatchLevel,
      comp_type  as ComponentType,
      _Text
}
