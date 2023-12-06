INTERFACE zif_demo_meter_reading_types PUBLIC.

  TYPES: BEGIN OF ENUM mr_upload_status STRUCTURE upload_status
           BASE TYPE zdmo_mr_upload_status,
           initial    VALUE IS INITIAL,
           incomplete VALUE 'I',
           complete   VALUE 'C',
           saved      VALUE 'S',
           erroneous  VALUE 'E',
         END OF ENUM mr_upload_status STRUCTURE upload_status.

  TYPES: BEGIN OF ENUM meter_reading_status STRUCTURE status
           BASE TYPE zdmo_meter_reading_status,
           undefined     VALUE IS INITIAL,
           order_created VALUE '0',
           plausible     VALUE '1',
           not_plausible VALUE '2',
         END OF ENUM meter_reading_status STRUCTURE status.

  " Table Types for CDS view entities
  TYPES meter_reading_document_table TYPE STANDARD TABLE OF ZI_Demo_MeterReadingDocuments WITH EMPTY KEY.
  TYPES meter_reading_upload_table   TYPE STANDARD TABLE OF ZI_Demo_MeterReadingUpload WITH EMPTY KEY.

  " Table Types for Standard Operations
  TYPES create_contract_table        TYPE TABLE FOR CREATE zi_demo_contracts\\Contract.
  TYPES read_contract_table          TYPE TABLE FOR READ RESULT zi_demo_contracts\\Contract.
  TYPES update_contract_table        TYPE TABLE FOR UPDATE zi_demo_contracts\\Contract.
  TYPES create_document_table        TYPE TABLE FOR CREATE zi_demo_meterreadingdocuments\\Document.
  TYPES read_document_table          TYPE TABLE FOR READ RESULT zi_demo_meterreadingdocuments\\Document.
  TYPES update_document_table        TYPE TABLE FOR UPDATE zi_demo_meterreadingdocuments\\Document.
  TYPES create_upload_table          TYPE TABLE FOR CREATE zi_demo_meterreadingupload\\Upload.
  TYPES read_upload_table            TYPE TABLE FOR READ RESULT zi_demo_meterreadingupload\\Upload.
  TYPES update_upload_table          TYPE TABLE FOR UPDATE zi_demo_meterreadingupload\\Upload.

  " Line Types for Standard Operations
  TYPES create_contract              TYPE STRUCTURE FOR CREATE zi_demo_contracts\\Contract.
  TYPES read_contract                TYPE STRUCTURE FOR READ RESULT zi_demo_contracts\\Contract.
  TYPES update_contract              TYPE STRUCTURE FOR UPDATE zi_demo_contracts\\Contract.
  TYPES create_document              TYPE STRUCTURE FOR CREATE zi_demo_meterreadingdocuments\\Document.
  TYPES read_document                TYPE STRUCTURE FOR READ RESULT zi_demo_meterreadingdocuments\\Document.
  TYPES update_document              TYPE STRUCTURE FOR UPDATE zi_demo_meterreadingdocuments\\Document.
  TYPES create_upload                TYPE STRUCTURE FOR CREATE zi_demo_meterreadingupload\\Upload.
  TYPES read_upload                  TYPE STRUCTURE FOR READ RESULT zi_demo_meterreadingupload\\Upload.
  TYPES update_upload                TYPE STRUCTURE FOR UPDATE zi_demo_meterreadingupload\\Upload.
ENDINTERFACE.
