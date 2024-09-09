@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ABAPConf 2023 Demo: Upload'
@VDM.viewType: #BASIC
define root view entity ZI_Demo_MeterReadingUpload
  as select from zdmo_mr_upload
  association [0..1] to ZI_Demo_MrUploadStatus as _Status on _Status.MrUploadStatus = $projection.UploadStatus
{
      @Semantics.uuid: true
  key uuid                          as MeterReadingUploadUUID,
      mr_document_id                as MeterReadingDocumentId,
      connection_object             as ConnectionObject,
      equipment                     as Equipment,
      serial_number                 as SerialNumber,
      @Semantics.businessDate.at: true
      mr_date                       as MeterReadingDate,
      mr_result                     as MeterReadingResult,
      mr_unit                       as MeterReadingUnit,
      mr_source                     as MeterReadingSource,
      contract                      as Contract,
      contract_account              as ContractAccount,
      business_partner              as BusinessPartner,
      @Semantics.name.givenName: true
      first_name                    as FirstName,
      @Semantics.name.familyName: true
      last_name                     as LastName,
      @Semantics.address.street: true
      street                        as Street,
      @Semantics.address.number: true
      house_number                  as HouseNumber,
      house_number_supplement       as HouseNumberSupplement,
      @Semantics.address.zipCode: true
      post_code                     as PostCode,
      @Semantics.address.city: true
      city                          as City,
      remark                        as Remark,
      upload_status                 as UploadStatus,
      case upload_status
        when 'E' then '1'
        when 'I' then '2'
        when 'C' then '3'
        when 'S' then '3'
        else          '0'
      end                           as UploadStatusCriticality,
      _Status.MrUploadStatusText    as UploadStatusText,
      @Semantics.user.createdBy: true
      created_by_user               as CreatedByUser,
      @Semantics.systemDateTime.createdAt: true
      created_at_timestamp          as CreatedAtTimestamp,
      @Semantics.user.lastChangedBy: true
      last_changed_by_user          as LastChangedByUser,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at_timestamp     as LastChangedAtTimestamp,
      @Semantics.user.localInstanceLastChangedBy: true
      loc_inst_changed_by_user      as LocInstChangedByUser,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      loc_inst_changed_at_timestamp as LocInstChangedAtTimestamp,
      _Status
}
