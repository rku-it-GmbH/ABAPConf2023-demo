CLASS zcl_demo_meter_read_evt_hndlr DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES bi_event_handler_static.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-METHODS lporb_to_uuid
      IMPORTING i_lporb              TYPE sibflporb
      RETURNING VALUE(r_upload_uuid) TYPE sysuuid_x16
      RAISING   cx_uuid_error.
ENDCLASS.



CLASS ZCL_DEMO_METER_READ_EVT_HNDLR IMPLEMENTATION.


  METHOD bi_event_handler_static~on_event.
    CASE event.
      WHEN 'READY_FOR_PROCESSING' OR 'DATA_CHANGED'.
        TRY.
            DATA(upload_uuid) = lporb_to_uuid( sender ).

            DATA model TYPE REF TO zif_demo_meter_reading_model.
            model = NEW zcl_demo_meter_reading_model( ).
            model->start_processing( upload_uuid ).

          CATCH cx_uuid_error zcx_rap_exception INTO DATA(previous).
            RAISE EXCEPTION NEW cx_bo_error( previous = previous ).
        ENDTRY.
    ENDCASE.
  ENDMETHOD.


  METHOD lporb_to_uuid.
    DATA(uuid_c32) = CONV sysuuid_c32( i_lporb-instid ).
    cl_system_uuid=>convert_uuid_c32_static( EXPORTING uuid     = uuid_c32
                                             IMPORTING uuid_x16 = r_upload_uuid ).
  ENDMETHOD.
ENDCLASS.
