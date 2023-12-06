@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ABAPConf 2023 Demo: Uploadstatus'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
define view entity ZI_Demo_MrUploadStatus
  as select from ZI_DomainFixedValues(  p_domain_name: 'ZDMO_MR_UPLOAD_STATUS' )
{
  key Language                                       as Language,
  key cast( ValueLow as zdmo_mr_upload_status      ) as MrUploadStatus,
      cast( Text     as zdmo_mr_upload_status_text ) as MrUploadStatusText
}
