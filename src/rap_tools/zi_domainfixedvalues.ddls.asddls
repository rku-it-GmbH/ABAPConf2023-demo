@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Domänenfestwerte'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
define view entity ZI_DomainFixedValues
  with parameters
    p_domain_name : abap.char(30)
  as select from dd07l as value
    inner join   dd07t as text on  text.domname  = value.domname
                               and text.valpos   = value.valpos
                               and text.as4local = value.as4local
                               and text.as4vers  = value.as4vers
{
  key value.domname    as DomainName,
  key value.valpos     as ValuePosition,
  key text.ddlanguage  as Language,
      value.domvalue_l as ValueLow,
      value.domvalue_h as ValueHigh,
      text.ddtext      as Text
}
where
      value.domname  = $parameters.p_domain_name
  and value.as4local = 'A'
