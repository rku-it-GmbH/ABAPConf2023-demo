@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ABAPConf 2023 Demo: Verträge'
@VDM.viewType: #CONSUMPTION
@UI.headerInfo: { typeName: 'Vertrag',
                  typeNamePlural: 'Verträge',
                  title: { type: #STANDARD,
                           value: 'Contract' } }
define root view entity ZC_Demo_Contracts
  provider contract transactional_query
  as projection on ZI_Demo_Contracts
{
      @UI.facet: [{ type: #COLLECTION,
                    label: 'Übersicht',
                    id: 'overview' },

                  { type: #IDENTIFICATION_REFERENCE,
                    label: 'Details',
                    id: 'identification',
                    parentId: 'overview',
                    position: 10 }]

      @UI.lineItem: [{ position: 10 }]
      @UI.identification: [{ position: 10 }]
  key Contract,
      @UI.lineItem: [{ position: 20 }]
      @UI.identification: [{ position: 20 }]
      ContractAccount,
      @UI.lineItem: [{ position: 30 }]
      @UI.identification: [{ position: 30 }]
      BusinessPartner,
      @UI.lineItem: [{ position: 40 }]
      @UI.identification: [{ position: 40 }]
      ConnectionObject,
      @UI.lineItem: [{ position: 50 }]
      @UI.identification: [{ position: 50 }]
      Equipment,
      @UI.lineItem: [{ position: 60 }]
      @UI.identification: [{ position: 60 }]
      ContractStartDate,
      @UI.lineItem: [{ position: 70 }]
      @UI.identification: [{ position: 70 }]
      ContractEndDate,
      @UI.lineItem: [{ position: 80 }]
      @UI.identification: [{ position: 80 }]
      CreatedByUser,
      @UI.lineItem: [{ position: 90 }]
      @UI.identification: [{ position: 90 }]
      CreatedAtDate,
      @UI.lineItem: [{ position: 100 }]
      @UI.identification: [{ position: 100 }]
      CreatedAtTime,
      @UI.lineItem: [{ position: 110 }]
      @UI.identification: [{ position: 110 }]
      LastChangedByUser,
      @UI.lineItem: [{ position: 120 }]
      @UI.identification: [{ position: 120 }]
      LastChangedAtDate,
      @UI.lineItem: [{ position: 130 }]
      @UI.identification: [{ position: 130 }]
      LastChangedAtTime,
      // Associations
      _Documents : redirected to ZC_Demo_MeterReadingDocuments
}
