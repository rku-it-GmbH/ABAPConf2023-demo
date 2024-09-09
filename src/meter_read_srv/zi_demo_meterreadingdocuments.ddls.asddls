@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ABAPConf 2023 Demo: Meter reading documents'
@VDM.viewType: #BASIC
define root view entity ZI_Demo_MeterReadingDocuments
  as select from zdmo_mr_docs
  association [0..1] to ZI_Demo_MeterReadingStatus as _Status on _Status.MeterReadingStatus = $projection.MeterReadingStatus
  with default filter _Status.Language = $session.system_language
{
  key mr_document_id                 as MeterReadingDocumentId,
      equipment                      as Equipment,
      @Semantics.businessDate.at: true
      mr_date                        as MeterReadingDate,
      mr_result                      as MeterReadingResult,
      mr_unit                        as MeterReadingUnit,
      mr_status                      as MeterReadingStatus,
      _Status.MeterReadingStatusText as MeterReadingStatusText,
      mr_source                      as MeterReadingSource,
      remark                         as Remark,
      @Semantics.user.createdBy: true
      ernam                          as CreatedByUser,
      @Semantics.systemDate.createdAt: true
      erdat                          as CreatedAtDate,
      @Semantics.systemTime.createdAt: true
      erzet                          as CreatedAtTime,
      @Semantics.user.lastChangedBy: true
      aenam                          as LastChangedByUser,
      @Semantics.systemDate.lastChangedAt: true
      aedat                          as LastChangedAtDate,
      @Semantics.systemTime.lastChangedAt: true
      aezet                          as LastChangedAtTime,
      _Status
}
