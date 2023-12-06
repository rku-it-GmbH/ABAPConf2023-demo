@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ABAPConf 2023 Demo: Ablesebelegstatus'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
define view entity ZI_Demo_MeterReadingStatus
  as select from ZI_DomainFixedValues(  p_domain_name: 'ZDMO_MR_UPLOAD_STATUS' )
{ 
  key Language                                      as Language,
  key cast( ValueLow as zdmo_meter_reading_status ) as MeterReadingStatus,
      Text                                          as MeterReadingStatusText
}
