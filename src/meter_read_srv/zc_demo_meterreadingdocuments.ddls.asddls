@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ABAPConf 2023 Demo: Ablesebelege'
@VDM.viewType: #CONSUMPTION
@UI.headerInfo: { typeName: 'Ablesebeleg',
                  typeNamePlural: 'Ablesebeleg',
                  title: { type: #STANDARD,
                           value: 'MeterReadingDocumentId' } }
define root view entity ZC_Demo_MeterReadingDocuments
  provider contract transactional_query
  as projection on ZI_Demo_MeterReadingDocuments
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
  key MeterReadingDocumentId,
      @UI.lineItem: [{ position: 20 }]
      @UI.identification: [{ position: 20 }]
      Equipment,
      @UI.lineItem: [{ position: 30 }]
      @UI.identification: [{ position: 30 }]
      MeterReadingDate,
      @UI.lineItem: [{ position: 40 }]
      @UI.identification: [{ position: 40 }]
      MeterReadingResult,
      @UI.lineItem: [{ position: 50 }]
      @UI.identification: [{ position: 50 }]
      MeterReadingUnit,
      @UI.hidden: true
      MeterReadingStatus,
      @UI.lineItem: [{ position: 60 }]
      @UI.identification: [{ position: 60 }]
      MeterReadingStatusText,
      @UI.lineItem: [{ position: 70 }]
      @UI.identification: [{ position: 70 }]
      MeterReadingSource,
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
      LastChangedAtTime
}
