CLASS lsc_zi_demo_meterreadingdocs DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.
ENDCLASS.

CLASS lsc_zi_demo_meterreadingdocs IMPLEMENTATION.
  METHOD save_modified.
    " In the real business case this an unmanaged scenario
    " using the Function Module BAPI_MTRREADDOC_UPLOAD
    " Unfortunately this Function Module commits to the DB in the end
    " and this can not be controlled by a flag, as is the case for man other BAPIs.
    " Another example that has the same issues, is BAPI_USER_CREATE.
    " Therefore we used an aRFC call as a workaround.
    " This is not a clean solution and should be avoided, if possible.

*    CALL FUNCTION 'BAPI_MTRREADDOC_UPLOAD'
*      STARTING NEW TASK 'MTRREADDOC_UPLOAD'
*      CALLING task_receive ON END OF TASK
*      TABLES
*        meterreadingresults = mr_read_insert
*        return              = bapireturn.
*
*    WAIT FOR ASYNCHRONOUS TASKS UNTIL bapireturn IS NOT INITIAL UP TO 30 SECONDS.
  ENDMETHOD.
ENDCLASS.


CLASS lhc_MeterReadingDocument DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    DATA db_access TYPE REF TO zif_demo_meter_reading_db.
    DATA model TYPE REF TO zif_demo_meter_reading_model.
    DATA utility TYPE REF TO zif_rap_utility.

    METHODS initialize.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Document RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Document RESULT result.

    METHODS early_numbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Document.

    METHODS set_status FOR DETERMINE ON SAVE
      IMPORTING keys FOR Document~SetStatus.
ENDCLASS.

CLASS lhc_MeterReadingDocument IMPLEMENTATION.
  METHOD initialize.
    db_access = NEW zcl_demo_meter_reading_db( ).
    model = NEW zcl_demo_meter_reading_model( ).
    utility = NEW zcl_rap_utility( ).
  ENDMETHOD.

  METHOD get_global_authorizations.
    initialize( ).

    IF requested_authorizations-%create = if_abap_behv=>mk-on.
      TRY.
          utility->check_authority( i_root_entity_name = 'ZI_DEMO_METERREADINGDOCUMENTS'
                                    i_entity_name      = 'ZI_DEMO_METERREADINGDOCUMENTS'
                                    i_operation        = 'C' ).

          result-%create = if_abap_behv=>auth-allowed.
        CATCH zcx_rap_exception.
          result-%create = if_abap_behv=>auth-unauthorized.
      ENDTRY.
    ENDIF.

    IF requested_authorizations-%update = if_abap_behv=>mk-on.
      TRY.
          utility->check_authority( i_root_entity_name = 'ZI_DEMO_METERREADINGDOCUMENTS'
                                    i_entity_name      = 'ZI_DEMO_METERREADINGDOCUMENTS'
                                    i_operation        = 'U' ).

          result-%update = if_abap_behv=>auth-allowed.
        CATCH zcx_rap_exception.
          result-%update = if_abap_behv=>auth-unauthorized.
      ENDTRY.
    ENDIF.

    IF requested_authorizations-%delete = if_abap_behv=>mk-on.
      TRY.
          utility->check_authority( i_root_entity_name = 'ZI_DEMO_METERREADINGDOCUMENTS'
                                    i_entity_name      = 'ZI_DEMO_METERREADINGDOCUMENTS'
                                    i_operation        = 'D' ).

          result-%delete = if_abap_behv=>auth-allowed.
        CATCH zcx_rap_exception.
          result-%delete = if_abap_behv=>auth-unauthorized.
      ENDTRY.
    ENDIF.
  ENDMETHOD.

  METHOD get_instance_authorizations.
    initialize( ).

    LOOP AT keys INTO DATA(key).
      INSERT CORRESPONDING #( key ) INTO TABLE result ASSIGNING FIELD-SYMBOL(<result>).

      IF requested_authorizations-%update = if_abap_behv=>mk-on.
        TRY.
            utility->check_authority( i_root_entity_name = 'ZI_DEMO_METERREADINGDOCUMENTS'
                                      i_entity_name      = 'ZI_DEMO_METERREADINGDOCUMENTS'
                                      i_operation        = 'U' ).

            <result>-%update = if_abap_behv=>auth-allowed.
          CATCH zcx_rap_exception.
            <result>-%update = if_abap_behv=>auth-unauthorized.
        ENDTRY.
      ENDIF.

      IF requested_authorizations-%delete = if_abap_behv=>mk-on.
        TRY.
            utility->check_authority( i_root_entity_name = 'ZI_DEMO_METERREADINGDOCUMENTS'
                                      i_entity_name      = 'ZI_DEMO_METERREADINGDOCUMENTS'
                                      i_operation        = 'D' ).

            <result>-%delete = if_abap_behv=>auth-allowed.
          CATCH zcx_rap_exception.
            <result>-%delete = if_abap_behv=>auth-unauthorized.
        ENDTRY.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD early_numbering_create.
    initialize( ).

    LOOP AT entities INTO DATA(entity).
      TRY.
          DATA new_mrdoc_id TYPE zdmo_meter_reading_document_id.
          CALL FUNCTION 'NUMBER_GET_NEXT'
            EXPORTING
              nr_range_nr = '01'
              object      = 'ZDMO_MRDOC'
            IMPORTING
              number      = new_mrdoc_id
            EXCEPTIONS
              OTHERS      = 1.
          IF sy-subrc <> 0.
            RAISE EXCEPTION TYPE zcx_rap_exception
                  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.

          " New ID found: Add to MAPPED
          INSERT VALUE #( %cid = entity-%cid MeterReadingDocumentId = new_mrdoc_id ) INTO TABLE mapped-document.

        CATCH zcx_rap_exception INTO DATA(exception).
          " Error in ID creation: Add to FAILED and REPORTED
          INSERT VALUE #( %cid = entity-%cid ) INTO TABLE failed-document.
          INSERT VALUE #( %cid = entity-%cid %msg = exception ) INTO TABLE reported-document.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD set_status.
    initialize( ).

    " read data from buffer
    DATA documents TYPE zif_demo_meter_reading_types=>read_document_table.
    READ ENTITY IN LOCAL MODE zi_demo_meterreadingdocuments FROM VALUE #(
        FOR key IN keys
        ( %key-MeterReadingDocumentId = key-MeterReadingDocumentId
          %control                    = VALUE #( MeterReadingDocumentId = if_abap_behv=>mk-on
                                                 MeterReadingDate       = if_abap_behv=>mk-on
                                                 MeterReadingResult     = if_abap_behv=>mk-on
                                                 MeterReadingUnit       = if_abap_behv=>mk-on
                                                 Equipment              = if_abap_behv=>mk-on ) ) )
         RESULT documents
         REPORTED DATA(read_reported).

    " propagate messages
    LOOP AT read_reported-document INTO DATA(read_reported_document).
      INSERT CORRESPONDING #( read_reported_document ) INTO TABLE reported-document.
    ENDLOOP.

    " set new status
    DATA update_documents TYPE zif_demo_meter_reading_types=>update_document_table.
    LOOP AT documents INTO DATA(document).
      TRY.
          DATA update_document TYPE zif_demo_meter_reading_types=>update_document.
          update_document = CORRESPONDING #( document ).
          DATA(meter_reading_status) = model->determine_status( CORRESPONDING #( document ) ).

          IF update_document-MeterReadingStatus <> meter_reading_status.
            update_document-MeterReadingStatus = meter_reading_status.
            update_document-%control-MeterReadingStatus = if_abap_behv=>mk-on.
            INSERT update_document INTO TABLE update_documents.
          ENDIF.

        CATCH zcx_rap_exception INTO DATA(exception).
          " add error message to REPORTED
          INSERT CORRESPONDING #( document ) INTO TABLE reported-document ASSIGNING FIELD-SYMBOL(<reported_document>).
          <reported_document>-%msg = exception.
      ENDTRY.
    ENDLOOP.

    " modify buffer
    MODIFY ENTITY IN LOCAL MODE zi_demo_meterreadingdocuments
           UPDATE FROM update_documents
           REPORTED DATA(update_reported).

    " propagate messages
    LOOP AT update_reported-document INTO DATA(update_reported_document).
      INSERT CORRESPONDING #( update_reported_document ) INTO TABLE reported-document.
    ENDLOOP.
  ENDMETHOD.



ENDCLASS.
