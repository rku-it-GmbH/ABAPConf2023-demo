CLASS zcl_demo_meter_reading_rfc DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_demo_meter_reading_rfc.

    METHODS constructor.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA utility TYPE REF TO zif_rap_utility.

    METHODS upload_meter_reading
      IMPORTING i_meter_reading_upload TYPE zif_demo_meter_reading_types=>create_upload
      RAISING   zcx_rap_exception.
ENDCLASS.



CLASS ZCL_DEMO_METER_READING_RFC IMPLEMENTATION.


  METHOD constructor.
    utility = NEW zcl_rap_utility( ).
  ENDMETHOD.


  METHOD zif_demo_meter_reading_rfc~upload_meter_reading_mass.
    DATA bapi_return_table TYPE bapirettab.

    " upload every entry in its own LUW
    LOOP AT i_meter_reading_uploads INTO DATA(meter_reading_upload).
      TRY.
          upload_meter_reading( meter_reading_upload ).
        CATCH zcx_rap_exception INTO DATA(exception).
          INSERT LINES OF exception->convert_to_bapi_return( ) INTO TABLE bapi_return_table.
      ENDTRY.
    ENDLOOP.

    IF bapi_return_table IS NOT INITIAL.
      RAISE EXCEPTION NEW zcx_rap_exception( bapi_return_table = bapi_return_table ).
    ENDIF.
  ENDMETHOD.


  METHOD upload_meter_reading.
    DATA(create_upload_table) = VALUE zif_demo_meter_reading_types=>create_upload_table( ( i_meter_reading_upload ) ).

    " write new entity to buffer
    MODIFY ENTITIES OF zi_demo_meterreadingupload
           ENTITY Upload CREATE AUTO FILL CID WITH create_upload_table
           FAILED   DATA(modify_failed)
           REPORTED DATA(modify_reported).

    " raise exception in case of failure
    IF modify_failed IS NOT INITIAL.
      ROLLBACK ENTITIES.
      RAISE EXCEPTION NEW zcx_rap_exception( bapi_return_table = utility->convert_reported_to_bapireturn( modify_reported ) ).
    ENDIF.

    " commit buffer to DB
    COMMIT ENTITIES RESPONSE OF zi_demo_meterreadingupload
           FAILED   DATA(commit_failed)
           REPORTED DATA(commit_reported).

    " raise exception in case of failure
    IF commit_failed IS NOT INITIAL.
      ROLLBACK ENTITIES.
      RAISE EXCEPTION NEW zcx_rap_exception( bapi_return_table = utility->convert_reported_to_bapireturn( commit_reported ) ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
