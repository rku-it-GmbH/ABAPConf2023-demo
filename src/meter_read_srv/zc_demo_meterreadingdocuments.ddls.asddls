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
      
      @Consumption.filter.selectionType: #RANGE
      @UI.lineItem:       [{ position: 10 }]
      @UI.identification: [{ position: 10 }]
  key MeterReadingDocumentId,
      @Consumption.filter.selectionType: #RANGE
      @UI.lineItem:       [{ position: 20, type: #WITH_INTENT_BASED_NAVIGATION, semanticObject: 'Equipment', semanticObjectAction: 'Display' }]
      @UI.identification: [{ position: 20, type: #WITH_INTENT_BASED_NAVIGATION, semanticObject: 'Equipment', semanticObjectAction: 'Display' }]
      Equipment,
      @Consumption.filter.selectionType: #RANGE
      @UI.lineItem:       [{ position: 30 }]
      @UI.identification: [{ position: 30 }]
      MeterReadingDate,
      @UI.lineItem:       [{ position: 40 }]
      @UI.identification: [{ position: 40 }]
      MeterReadingResult,
      @UI.lineItem:       [{ position: 50 }]
      @UI.identification: [{ position: 50 }]
      MeterReadingUnit,
      @Consumption.filter.selectionType: #RANGE
      @UI.hidden: true
      MeterReadingStatus,
      @UI.lineItem:       [{ position: 60 }]
      @UI.identification: [{ position: 60 }]
      MeterReadingStatusText,
      @Consumption.filter.selectionType: #RANGE
      @UI.lineItem:       [{ position: 70 }]
      @UI.identification: [{ position: 70 }]
      MeterReadingSource,
      @UI.lineItem:       [{ position: 80 }]
      @UI.identification: [{ position: 80 }]
      Remark,
      @Consumption.filter.selectionType: #RANGE
      @UI.lineItem:       [{ position: 90 }]
      @UI.identification: [{ position: 90 }]
      CreatedByUser,
      @Consumption.filter.selectionType: #RANGE
      @UI.lineItem:       [{ position: 100 }]
      @UI.identification: [{ position: 100 }]
      CreatedAtDate,
      @UI.lineItem:       [{ position: 110 }]
      @UI.identification: [{ position: 110 }]
      CreatedAtTime,
      @Consumption.filter.selectionType: #RANGE
      @UI.lineItem:       [{ position: 120 }]
      @UI.identification: [{ position: 120 }]
      LastChangedByUser,
      @Consumption.filter.selectionType: #RANGE
      @UI.lineItem:       [{ position: 130 }]
      @UI.identification: [{ position: 130 }]
      LastChangedAtDate,
      @UI.lineItem:       [{ position: 140 }]
      @UI.identification: [{ position: 140 }]
      LastChangedAtTime
}
