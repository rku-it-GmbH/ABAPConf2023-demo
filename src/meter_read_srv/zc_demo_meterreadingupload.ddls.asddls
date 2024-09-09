@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ABAPConf 2023 Demo: Upload'
@VDM.viewType: #CONSUMPTION
@UI.headerInfo: { typeName: 'Erfasster Zählerstand',
                  typeNamePlural: 'Erfasste Zählerstände',
                  title: { type: #STANDARD,
                           value: 'MeterReadingUploadUUID' } }

define root view entity ZC_Demo_MeterReadingUpload
  provider contract transactional_query
  as projection on ZI_Demo_MeterReadingUpload
{
      @UI.facet: [{ type: #COLLECTION,
                    label: 'Übersicht',
                    id: 'overview' },

                  { type: #IDENTIFICATION_REFERENCE,
                    label: 'Details',
                    id: 'identification',
                    parentId: 'overview',
                    position: 10 }]

      @UI.hidden: true
//      @UI.lineItem:       [{ type: #FOR_ACTION, dataAction: 'ProcessMeterReading', label: 'Verbuchen' }]
//      @UI.identification: [{ type: #FOR_ACTION, dataAction: 'ProcessMeterReading', label: 'Verbuchen' }]
  key MeterReadingUploadUUID,
      @Consumption.filter.selectionType: #RANGE
      @UI.lineItem:       [{ position: 10 }]
      @UI.identification: [{ position: 10 }]
      MeterReadingDocumentId,
      @Consumption.filter.selectionType: #RANGE
      @UI.lineItem:       [{ position: 110 }] //, type: #WITH_INTENT_BASED_NAVIGATION, semanticObject: 'ConnectionObject', semanticObjectAction: 'Display' }]
      @UI.identification: [{ position: 110 }] //, type: #WITH_INTENT_BASED_NAVIGATION, semanticObject: 'ConnectionObject', semanticObjectAction: 'Display' }]
      ConnectionObject,
      @Consumption.filter.selectionType: #RANGE
      @UI.lineItem:       [{ position: 100 }] //, type: #WITH_INTENT_BASED_NAVIGATION, semanticObject: 'Equipment', semanticObjectAction: 'Display' }]
      @UI.identification: [{ position: 100 }] //, type: #WITH_INTENT_BASED_NAVIGATION, semanticObject: 'Equipment', semanticObjectAction: 'Display' }]
      Equipment,
      @Consumption.filter.selectionType: #RANGE
      @UI.lineItem:       [{ position: 50 }] //, type: #WITH_INTENT_BASED_NAVIGATION, semanticObject: 'Device', semanticObjectAction: 'Display' }]
      @UI.identification: [{ position: 50 }] //, type: #WITH_INTENT_BASED_NAVIGATION, semanticObject: 'Device', semanticObjectAction: 'Display' }]
      SerialNumber,
      @Consumption.filter.selectionType: #RANGE
      @UI.lineItem:       [{ position: 60 }]
      @UI.identification: [{ position: 60 }]
      MeterReadingDate,
      @UI.lineItem:       [{ position: 70 }]
      @UI.identification: [{ position: 70 }]
      MeterReadingResult,
      @UI.lineItem:       [{ position: 80 }]
      @UI.identification: [{ position: 80 }]
      MeterReadingUnit,
      @Consumption.filter.selectionType: #RANGE
      @UI.lineItem:       [{ position: 90 }]
      @UI.identification: [{ position: 90 }]
      MeterReadingSource,
      @Consumption.filter.selectionType: #RANGE
      @UI.lineItem:       [{ position: 20 }]
      @UI.identification: [{ position: 20 }]
      Contract,
      @Consumption.filter.selectionType: #RANGE
      @UI.lineItem:       [{ position: 30 }] //, type: #WITH_INTENT_BASED_NAVIGATION, semanticObject: 'ContractAccount', semanticObjectAction: 'Display' }]
      @UI.identification: [{ position: 30 }] //, type: #WITH_INTENT_BASED_NAVIGATION, semanticObject: 'ContractAccount', semanticObjectAction: 'Display' }]
      ContractAccount,
      @Consumption.filter.selectionType: #RANGE
      @UI.lineItem:       [{ position: 40 }] //, type: #WITH_INTENT_BASED_NAVIGATION, semanticObject: 'BusinessPartner', semanticObjectAction: 'Display' }]
      @UI.identification: [{ position: 40 }] //, type: #WITH_INTENT_BASED_NAVIGATION, semanticObject: 'BusinessPartner', semanticObjectAction: 'Display' }]
      BusinessPartner,
      @UI.lineItem:       [{ position: 120 }]
      @UI.identification: [{ position: 120 }]
      FirstName,
      @UI.lineItem:       [{ position: 130 }]
      @UI.identification: [{ position: 130 }]
      LastName,
      @UI.lineItem:       [{ position: 140 }]
      @UI.identification: [{ position: 140 }]
      Street,
      @UI.lineItem:       [{ position: 150 }]
      @UI.identification: [{ position: 150 }]
      HouseNumber,
      @UI.lineItem:       [{ position: 160 }]
      @UI.identification: [{ position: 160 }]
      HouseNumberSupplement,
      @UI.lineItem:       [{ position: 170 }]
      @UI.identification: [{ position: 170 }]
      PostCode,
      @UI.lineItem:       [{ position: 180 }]
      @UI.identification: [{ position: 180 }]
      City,
      @UI.lineItem:       [{ position: 190 }, { type: #FOR_ACTION, dataAction: 'setRemark',label: 'Bemerkung erfassen' }]
      @UI.identification: [{ position: 190 }, { type: #FOR_ACTION, dataAction: 'setRemark',label: 'Bemerkung erfassen' }]
      Remark,
      @Consumption.filter.selectionType: #RANGE
      @UI.hidden: true
      UploadStatus,
      @UI.lineItem:       [{ position: 200, criticality: 'UploadStatusCriticality', criticalityRepresentation: #WITH_ICON }]
      @UI.identification: [{ position: 200, criticality: 'UploadStatusCriticality', criticalityRepresentation: #WITH_ICON }]
      UploadStatusText,
      @UI.hidden: true
      UploadStatusCriticality,
      @Consumption.filter.selectionType: #RANGE
      @UI.lineItem:       [{ position: 210 }]
      @UI.identification: [{ position: 210 }]
      CreatedByUser,
      @Consumption.filter.selectionType: #RANGE
      @UI.lineItem:       [{ position: 220 }]
      @UI.identification: [{ position: 220 }]
      CreatedAtTimestamp,
      @Consumption.filter.selectionType: #RANGE
      @UI.lineItem:       [{ position: 230 }]
      @UI.identification: [{ position: 230 }]
      LastChangedByUser,
      @Consumption.filter.selectionType: #RANGE
      @UI.lineItem:       [{ position: 240 }]
      @UI.identification: [{ position: 240 }]
      LastChangedAtTimestamp,
      @UI.hidden: true
      LocInstChangedByUser,
      @UI.hidden: true
      LocInstChangedAtTimestamp
}
