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

      @Consumption.filter.selectionType: #RANGE
      @UI.lineItem:       [{ position: 10 }]
      @UI.identification: [{ position: 10 }]
  key Contract,
      @Consumption.filter.selectionType: #RANGE
      @UI.lineItem:       [{ position: 20, type: #WITH_INTENT_BASED_NAVIGATION, semanticObject: 'ContractAccount', semanticObjectAction: 'Display' }]
      @UI.identification: [{ position: 20, type: #WITH_INTENT_BASED_NAVIGATION, semanticObject: 'ContractAccount', semanticObjectAction: 'Display' }]
      ContractAccount,
      @Consumption.filter.selectionType: #RANGE
      @UI.lineItem:       [{ position: 30, type: #WITH_INTENT_BASED_NAVIGATION, semanticObject: 'BusinessPartner', semanticObjectAction: 'Display' }]
      @UI.identification: [{ position: 30, type: #WITH_INTENT_BASED_NAVIGATION, semanticObject: 'BusinessPartner', semanticObjectAction: 'Display' }]
      BusinessPartner,
      @Consumption.filter.selectionType: #RANGE
      @UI.lineItem:       [{ position: 40, type: #WITH_INTENT_BASED_NAVIGATION, semanticObject: 'ConnectionObject', semanticObjectAction: 'Display' }]
      @UI.identification: [{ position: 40, type: #WITH_INTENT_BASED_NAVIGATION, semanticObject: 'ConnectionObject', semanticObjectAction: 'Display' }]
      ConnectionObject,
      @Consumption.filter.selectionType: #RANGE
      @UI.lineItem:       [{ position: 50, type: #WITH_INTENT_BASED_NAVIGATION, semanticObject: 'Equipment', semanticObjectAction: 'Display' }]
      @UI.identification: [{ position: 50, type: #WITH_INTENT_BASED_NAVIGATION, semanticObject: 'Equipment', semanticObjectAction: 'Display' }]
      Equipment,
      @Consumption.filter.selectionType: #RANGE
      @UI.lineItem:       [{ position: 60 }]
      @UI.identification: [{ position: 60 }]
      ContractStartDate,
      @Consumption.filter.selectionType: #RANGE
      @UI.lineItem:       [{ position: 70 }]
      @UI.identification: [{ position: 70 }]
      ContractEndDate,
      @Consumption.filter.selectionType: #RANGE
      @UI.lineItem:       [{ position: 80 }]
      @UI.identification: [{ position: 80 }]
      CreatedByUser,
      @Consumption.filter.selectionType: #RANGE
      @UI.lineItem:       [{ position: 90 }]
      @UI.identification: [{ position: 90 }]
      CreatedAtDate,
      @UI.lineItem:       [{ position: 100 }]
      @UI.identification: [{ position: 100 }]
      CreatedAtTime,
      @Consumption.filter.selectionType: #RANGE
      @UI.lineItem:       [{ position: 110 }]
      @UI.identification: [{ position: 110 }]
      LastChangedByUser,
      @Consumption.filter.selectionType: #RANGE
      @UI.lineItem:       [{ position: 120 }]
      @UI.identification: [{ position: 120 }]
      LastChangedAtDate,
      @UI.lineItem:       [{ position: 130 }]
      @UI.identification: [{ position: 130 }]
      LastChangedAtTime,
      // Associations
      _Documents : redirected to ZC_Demo_MeterReadingDocuments
}
