@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ABAPConf 2023 Demo: Contracts'
@VDM.viewType: #BASIC
define root view entity ZI_Demo_Contracts
  as select from zdmo_contracts
  association [0..*] to ZI_Demo_MeterReadingDocuments as _Documents on  _Documents.Equipment        = $projection.Equipment
                                                                    and _Documents.MeterReadingDate >= $projection.ContractStartDate
                                                                    and _Documents.MeterReadingDate <= $projection.ContractEndDate
{
  key contract            as Contract,
      contract_account    as ContractAccount,
      business_partner    as BusinessPartner,
      connection_object   as ConnectionObject,
      equipment           as Equipment,
      @Semantics.businessDate.from: true
      contract_start_date as ContractStartDate,
      @Semantics.businessDate.to: true
      contract_end_date   as ContractEndDate,
      @Semantics.user.createdBy: true
      ernam               as CreatedByUser,
      @Semantics.systemDate.createdAt: true
      erdat               as CreatedAtDate,
      @Semantics.systemTime.createdAt: true
      erzet               as CreatedAtTime,
      @Semantics.user.lastChangedBy: true
      aenam               as LastChangedByUser,
      @Semantics.systemDate.lastChangedAt: true
      aedat               as LastChangedAtDate,
      @Semantics.systemTime.lastChangedAt: true
      aezet               as LastChangedAtTime,
      // Associations
      _Documents
}
