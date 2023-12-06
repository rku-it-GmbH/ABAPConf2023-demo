INTERFACE zif_demo_meter_reading_model PUBLIC.

  METHODS determine_status
    IMPORTING i_meter_reading_document TYPE ZI_Demo_MeterReadingDocuments
    RETURNING VALUE(r_status)          TYPE zdmo_meter_reading_status
    RAISING   zcx_rap_exception.

  METHODS identify_business_partner
    IMPORTING i_meter_reading_upload    TYPE ZI_Demo_MeterReadingUpload
    RETURNING VALUE(r_business_partner) TYPE bu_partner
    RAISING   zcx_rap_exception.

  METHODS identify_contract_account
    IMPORTING i_meter_reading_upload    TYPE ZI_Demo_MeterReadingUpload
    RETURNING VALUE(r_contract_account) TYPE vkont_kk
    RAISING   zcx_rap_exception.

  METHODS identify_contract
    IMPORTING i_meter_reading_upload TYPE ZI_Demo_MeterReadingUpload
    RETURNING VALUE(r_contract)      TYPE zdmo_contract
    RAISING   zcx_rap_exception.

  METHODS identify_connection_object
    IMPORTING i_meter_reading_upload     TYPE ZI_Demo_MeterReadingUpload
    RETURNING VALUE(r_connection_object) TYPE tplnr
    RAISING   zcx_rap_exception.

  METHODS identify_equipment
    IMPORTING i_meter_reading_upload TYPE ZI_Demo_MeterReadingUpload
    RETURNING VALUE(r_equipment)     TYPE equnr
    RAISING   zcx_rap_exception.

  METHODS determine_upload_status
    IMPORTING i_meter_reading_upload TYPE ZI_Demo_MeterReadingUpload
    RETURNING VALUE(r_upload_status) TYPE zdmo_mr_upload_status
    RAISING   zcx_rap_exception.

  METHODS check_upload_consistency
    IMPORTING i_meter_reading_upload TYPE ZI_Demo_MeterReadingUpload
    RAISING   zcx_rap_exception.

  METHODS start_processing
    IMPORTING i_upload_uuid TYPE sysuuid_x16
              i_commit      TYPE abap_bool DEFAULT abap_true
    RAISING   zcx_rap_exception.

ENDINTERFACE.
