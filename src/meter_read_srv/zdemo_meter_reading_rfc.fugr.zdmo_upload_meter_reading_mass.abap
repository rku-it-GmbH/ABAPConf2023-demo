FUNCTION zdmo_upload_meter_reading_mass.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_METER_READING_UPLOADS) TYPE  ZDMO_MR_UPLOAD_TABLE
*"  EXPORTING
*"     VALUE(R_BAPI_RETURN) TYPE  BAPIRETTAB
*"----------------------------------------------------------------------
  TRY.
      " Map the imported DB Data to CDS entity data
      DATA(meter_reading_uploads) = VALUE zif_demo_meter_reading_types=>create_upload_table( ).
      utility->map_db_table_to_cds_entity(
        EXPORTING
          i_behaviour_definition = 'zi_demo_meterreadingupload'
          i_cds_entity           = 'ZI_Demo_MeterReadingUpload'
          i_update               = abap_false
          i_db_table_data        = i_meter_reading_uploads
        CHANGING
          c_cds_entity_data      = meter_reading_uploads ).

      " Import data via adapter
      adapter->upload_meter_reading_mass( meter_reading_uploads ).

    CATCH zcx_rap_exception INTO DATA(exception).
      r_bapi_return = exception->convert_to_bapi_return( ).
  ENDTRY.
ENDFUNCTION.
