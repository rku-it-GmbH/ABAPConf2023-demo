CLASS lhc_Upload DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    DATA db_access TYPE REF TO zif_demo_meter_reading_db.
    DATA model TYPE REF TO zif_demo_meter_reading_model.
    DATA utility TYPE REF TO zif_rap_utility.

    METHODS initialize.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Upload RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Upload RESULT result.

    METHODS identify_business_partner FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Upload~IdentifyBusinessPartner.

    METHODS identify_contract_account FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Upload~IdentifyContractAccount.

    METHODS identify_connection_object FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Upload~IdentifyConnectionObject.

    METHODS identify_equipment FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Upload~IdentifyEquipment.

    METHODS identify_contract FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Upload~IdentifyContract.

    METHODS set_status FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Upload~SetStatus.

    METHODS process_meter_reading FOR MODIFY
      IMPORTING keys FOR ACTION Upload~ProcessMeterReading.

    METHODS set_remark FOR MODIFY
      IMPORTING keys FOR ACTION Upload~setRemark RESULT result.
ENDCLASS.

CLASS lhc_Upload IMPLEMENTATION.

  METHOD initialize.
    db_access = NEW zcl_demo_meter_reading_db( ).
    model     = NEW zcl_demo_meter_reading_model( ).
    utility   = NEW zcl_rap_utility( ).
  ENDMETHOD.

  METHOD get_global_authorizations.
    initialize( ).

    IF requested_authorizations-%create = if_abap_behv=>mk-on.
      TRY.
          utility->check_authority( i_root_entity_name = 'ZI_DEMO_METERREADINGUPLOAD'
                                    i_entity_name      = 'ZI_DEMO_METERREADINGUPLOAD'
                                    i_operation        = 'C'  ).

          result-%create = if_abap_behv=>auth-allowed.
        CATCH zcx_rap_exception.
          result-%create = if_abap_behv=>auth-unauthorized.
      ENDTRY.
    ENDIF.

    IF requested_authorizations-%update = if_abap_behv=>mk-on.
      TRY.
          utility->check_authority( i_root_entity_name = 'ZI_DEMO_METERREADINGUPLOAD'
                                    i_entity_name      = 'ZI_DEMO_METERREADINGUPLOAD'
                                    i_operation        = 'U'  ).

          result-%update = if_abap_behv=>auth-allowed.
        CATCH zcx_rap_exception.
          result-%update = if_abap_behv=>auth-unauthorized.
      ENDTRY.
    ENDIF.

    IF requested_authorizations-%delete = if_abap_behv=>mk-on.
      TRY.
          utility->check_authority( i_root_entity_name = 'ZI_DEMO_METERREADINGUPLOAD'
                                    i_entity_name      = 'ZI_DEMO_METERREADINGUPLOAD'
                                    i_operation        = 'D'  ).

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
            utility->check_authority( i_root_entity_name = 'ZI_DEMO_METERREADINGUPLOAD'
                                      i_entity_name      = 'ZI_DEMO_METERREADINGUPLOAD'
                                      i_operation        = 'U'  ).

            <result>-%update = if_abap_behv=>auth-allowed.
          CATCH zcx_rap_exception.
            <result>-%update = if_abap_behv=>auth-unauthorized.
        ENDTRY.
      ENDIF.

      IF requested_authorizations-%delete = if_abap_behv=>mk-on.
        TRY.
            utility->check_authority( i_root_entity_name = 'ZI_DEMO_METERREADINGUPLOAD'
                                      i_entity_name      = 'ZI_DEMO_METERREADINGUPLOAD'
                                      i_operation        = 'D'  ).

            <result>-%delete = if_abap_behv=>auth-allowed.
          CATCH zcx_rap_exception.
            <result>-%delete = if_abap_behv=>auth-unauthorized.
        ENDTRY.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD identify_business_partner.
    initialize( ).

    " read data from buffer
    DATA uploads TYPE zif_demo_meter_reading_types=>read_upload_table.
    READ ENTITY IN LOCAL MODE zi_demo_meterreadingupload FROM VALUE #(
        FOR key IN keys
        ( %key-MeterReadingUploadUUID = key-MeterReadingUploadUUID
          %control                    = VALUE #(
              MeterReadingUploadUUID = if_abap_behv=>mk-on
              MeterReadingDocumentId = if_abap_behv=>mk-on
              BusinessPartner        = if_abap_behv=>mk-on
              ContractAccount        = if_abap_behv=>mk-on
              Contract               = if_abap_behv=>mk-on
              FirstName              = if_abap_behv=>mk-on
              LastName               = if_abap_behv=>mk-on
              Street                 = if_abap_behv=>mk-on
              HouseNumber            = if_abap_behv=>mk-on
              HouseNumberSupplement  = if_abap_behv=>mk-on
              PostCode               = if_abap_behv=>mk-on
              City                   = if_abap_behv=>mk-on                                                  ) ) )
         RESULT uploads
         REPORTED DATA(read_reported).

    " propagate messages
    LOOP AT read_reported-upload INTO DATA(read_reported_upload).
      INSERT CORRESPONDING #( read_reported_upload ) INTO TABLE reported-upload.
    ENDLOOP.

    " identify business partner
    DATA(update_uploads) = VALUE zif_demo_meter_reading_types=>update_upload_table( ).
    LOOP AT uploads INTO DATA(upload).
      TRY.
          " Identify Business Partner and add entry to update table (happy path)
          DATA(update_upload) = CORRESPONDING zif_demo_meter_reading_types=>update_upload( upload ).
          DATA(business_partner) = model->identify_business_partner( CORRESPONDING #( upload ) ).

          " This is necessary to avoid an infinite loop by recursive calls of the determinations
          IF business_partner <> upload-BusinessPartner.
            update_upload-BusinessPartner = business_partner.
            update_upload-%control-BusinessPartner = if_abap_behv=>mk-on.
            INSERT update_upload INTO TABLE update_uploads.
          ENDIF.

        CATCH zcx_rap_exception INTO DATA(exception).
          " add error message to REPORTED
          INSERT CORRESPONDING #( upload ) INTO TABLE reported-upload ASSIGNING FIELD-SYMBOL(<reported_upload>).
          <reported_upload>-%msg = exception.
      ENDTRY.
    ENDLOOP.

    " modify buffer
    MODIFY ENTITY IN LOCAL MODE zi_demo_meterreadingupload
           UPDATE FROM update_uploads
           REPORTED DATA(update_reported).

    " propagate messages
    LOOP AT update_reported-upload INTO DATA(update_reported_upload).
      INSERT CORRESPONDING #( update_reported_upload ) INTO TABLE reported-upload.
    ENDLOOP.
  ENDMETHOD.

  METHOD identify_contract_account.
    initialize( ).

    " read data from buffer
    DATA uploads TYPE zif_demo_meter_reading_types=>read_upload_table.
    READ ENTITY IN LOCAL MODE zi_demo_meterreadingupload FROM VALUE #(
        FOR key IN keys
        ( %key-MeterReadingUploadUUID = key-MeterReadingUploadUUID
          %control                    = VALUE #(
              MeterReadingUploadUUID = if_abap_behv=>mk-on
              MeterReadingDocumentId = if_abap_behv=>mk-on
              BusinessPartner        = if_abap_behv=>mk-on
              ContractAccount        = if_abap_behv=>mk-on
              Contract               = if_abap_behv=>mk-on
              ConnectionObject       = if_abap_behv=>mk-on
              Street                 = if_abap_behv=>mk-on
              HouseNumber            = if_abap_behv=>mk-on
              HouseNumberSupplement  = if_abap_behv=>mk-on
              PostCode               = if_abap_behv=>mk-on
              City                   = if_abap_behv=>mk-on                                                  ) ) )
         RESULT uploads
         REPORTED DATA(read_reported).

    " propagate messages
    LOOP AT read_reported-upload INTO DATA(read_reported_upload).
      INSERT CORRESPONDING #( read_reported_upload ) INTO TABLE reported-upload.
    ENDLOOP.

    " identify contract account
    DATA(update_uploads) = VALUE zif_demo_meter_reading_types=>update_upload_table( ).
    LOOP AT uploads INTO DATA(upload).
      TRY.
          " Identify Contract Account and add entry to update table (happy path)
          DATA(update_upload) = CORRESPONDING zif_demo_meter_reading_types=>update_upload( upload ).
          DATA(contract_account) = model->identify_contract_account( CORRESPONDING #( upload ) ).

          " This is necessary to avoid an infinite loop by recursive calls of the determinations
          IF contract_account <> upload-ContractAccount.
            update_upload-ContractAccount = contract_account.
            update_upload-%control-ContractAccount = if_abap_behv=>mk-on.
            INSERT update_upload INTO TABLE update_uploads.
          ENDIF.

        CATCH zcx_rap_exception INTO DATA(exception).
          " add error message to REPORTED
          INSERT CORRESPONDING #( upload ) INTO TABLE reported-upload ASSIGNING FIELD-SYMBOL(<reported_upload>).
          <reported_upload>-%msg = exception.
      ENDTRY.
    ENDLOOP.

    " modify buffer
    MODIFY ENTITY IN LOCAL MODE zi_demo_meterreadingupload
           UPDATE FROM update_uploads
           REPORTED DATA(update_reported).

    " propagate messages
    LOOP AT update_reported-upload INTO DATA(update_reported_upload).
      INSERT CORRESPONDING #( update_reported_upload ) INTO TABLE reported-upload.
    ENDLOOP.
  ENDMETHOD.

  METHOD identify_contract.
    initialize( ).

    " read data from buffer
    DATA uploads TYPE zif_demo_meter_reading_types=>read_upload_table.
    READ ENTITY IN LOCAL MODE zi_demo_meterreadingupload FROM VALUE #(
        FOR key IN keys
        ( %key-MeterReadingUploadUUID = key-MeterReadingUploadUUID
          %control                    = VALUE #(
              MeterReadingUploadUUID = if_abap_behv=>mk-on
              MeterReadingDocumentId = if_abap_behv=>mk-on
              MeterReadingDate       = if_abap_behv=>mk-on
              BusinessPartner        = if_abap_behv=>mk-on
              ContractAccount        = if_abap_behv=>mk-on
              Contract               = if_abap_behv=>mk-on
              Equipment              = if_abap_behv=>mk-on ) ) )
         RESULT uploads
         REPORTED DATA(read_reported).

    " propagate messages
    LOOP AT read_reported-upload INTO DATA(read_reported_upload).
      INSERT CORRESPONDING #( read_reported_upload ) INTO TABLE reported-upload.
    ENDLOOP.

    " identify contract
    DATA(update_uploads) = VALUE zif_demo_meter_reading_types=>update_upload_table( ).
    LOOP AT uploads INTO DATA(upload).
      TRY.
          " Identify Contract and add entry to update table (happy path)
          DATA(update_upload) = CORRESPONDING zif_demo_meter_reading_types=>update_upload( upload ).
          DATA(contract) = model->identify_contract( CORRESPONDING #( upload ) ).

          " This is necessary to avoid an infinite loop by recursive calls of the determinations
          IF contract <> upload-Contract.
            update_upload-Contract = contract.
            update_upload-%control-Contract = if_abap_behv=>mk-on.
            INSERT update_upload INTO TABLE update_uploads.
          ENDIF.

        CATCH zcx_rap_exception INTO DATA(exception).
          " add error message to REPORTED
          INSERT CORRESPONDING #( upload ) INTO TABLE reported-upload ASSIGNING FIELD-SYMBOL(<reported_upload>).
          <reported_upload>-%msg = exception.
      ENDTRY.
    ENDLOOP.

    " modify buffer
    MODIFY ENTITY IN LOCAL MODE zi_demo_meterreadingupload
           UPDATE FROM update_uploads
           REPORTED DATA(update_reported).

    " propagate messages
    LOOP AT update_reported-upload INTO DATA(update_reported_upload).
      INSERT CORRESPONDING #( update_reported_upload ) INTO TABLE reported-upload.
    ENDLOOP.
  ENDMETHOD.

  METHOD identify_connection_object.
    initialize( ).

    " read data from buffer
    DATA uploads TYPE zif_demo_meter_reading_types=>read_upload_table.
    READ ENTITY IN LOCAL MODE zi_demo_meterreadingupload FROM VALUE #(
        FOR key IN keys
        ( %key-MeterReadingUploadUUID = key-MeterReadingUploadUUID
          %control                    = VALUE #(
              MeterReadingUploadUUID = if_abap_behv=>mk-on
              MeterReadingDocumentId = if_abap_behv=>mk-on
              ConnectionObject       = if_abap_behv=>mk-on
              Street                 = if_abap_behv=>mk-on
              HouseNumber            = if_abap_behv=>mk-on
              HouseNumberSupplement  = if_abap_behv=>mk-on
              PostCode               = if_abap_behv=>mk-on
              City                   = if_abap_behv=>mk-on                                                  ) ) )
         RESULT uploads
         REPORTED DATA(read_reported).

    " propagate messages
    LOOP AT read_reported-upload INTO DATA(read_reported_upload).
      INSERT CORRESPONDING #( read_reported_upload ) INTO TABLE reported-upload.
    ENDLOOP.

    " identify connection object
    DATA(update_uploads) = VALUE zif_demo_meter_reading_types=>update_upload_table( ).
    LOOP AT uploads INTO DATA(upload).
      TRY.
          " Identify Connection Object and add entry to update table (happy path)
          DATA(update_upload) = CORRESPONDING zif_demo_meter_reading_types=>update_upload( upload ).
          DATA(connection_object) = model->identify_connection_object( CORRESPONDING #( upload ) ).

          " This is necessary to avoid an infinite loop by recursive calls of the determinations
          IF connection_object <> upload-ConnectionObject.
            update_upload-ConnectionObject =  connection_object.
            update_upload-%control-ConnectionObject = if_abap_behv=>mk-on.
            INSERT update_upload INTO TABLE update_uploads.
          ENDIF.

        CATCH zcx_rap_exception INTO DATA(exception).
          " add error message to REPORTED
          INSERT CORRESPONDING #( upload ) INTO TABLE reported-upload ASSIGNING FIELD-SYMBOL(<reported_upload>).
          <reported_upload>-%msg = exception.
      ENDTRY.
    ENDLOOP.

    " modify buffer
    MODIFY ENTITY IN LOCAL MODE zi_demo_meterreadingupload
           UPDATE FROM update_uploads
           REPORTED DATA(update_reported).

    " propagate messages
    LOOP AT update_reported-upload INTO DATA(update_reported_upload).
      INSERT CORRESPONDING #( update_reported_upload ) INTO TABLE reported-upload.
    ENDLOOP.
  ENDMETHOD.

  METHOD identify_equipment.
    initialize( ).

    " read data from buffer
    DATA uploads TYPE zif_demo_meter_reading_types=>read_upload_table.
    READ ENTITY IN LOCAL MODE zi_demo_meterreadingupload FROM VALUE #(
        FOR key IN keys
        ( %key-MeterReadingUploadUUID = key-MeterReadingUploadUUID
          %control                    = VALUE #(
              MeterReadingUploadUUID = if_abap_behv=>mk-on
              MeterReadingDocumentId = if_abap_behv=>mk-on
              BusinessPartner        = if_abap_behv=>mk-on
              ContractAccount        = if_abap_behv=>mk-on
              Contract               = if_abap_behv=>mk-on
              Equipment              = if_abap_behv=>mk-on
              SerialNumber           = if_abap_behv=>mk-on                                                ) ) )
         RESULT uploads
         REPORTED DATA(read_reported).

    " propagate messages
    LOOP AT read_reported-upload INTO DATA(read_reported_upload).
      INSERT CORRESPONDING #( read_reported_upload ) INTO TABLE reported-upload.
    ENDLOOP.

    " identify equipment
    DATA(update_uploads) = VALUE zif_demo_meter_reading_types=>update_upload_table( ).
    LOOP AT uploads INTO DATA(upload).
      TRY.
          " Identify Equipment and add entry to update table (happy path)
          DATA(update_upload) = CORRESPONDING zif_demo_meter_reading_types=>update_upload( upload ).
          DATA(equipment) = model->identify_equipment( CORRESPONDING #( upload ) ).

          " This is necessary to avoid an infinite loop by recursive calls of the determinations
          IF equipment <> upload-Equipment.
            update_upload-Equipment = equipment.
            update_upload-%control-Equipment = if_abap_behv=>mk-on.
            INSERT update_upload INTO TABLE update_uploads.
          ENDIF.

        CATCH zcx_rap_exception INTO DATA(exception).
          " add error message to REPORTED
          INSERT CORRESPONDING #( upload ) INTO TABLE reported-upload ASSIGNING FIELD-SYMBOL(<reported_upload>).
          <reported_upload>-%msg = exception.
      ENDTRY.
    ENDLOOP.

    " modify buffer
    MODIFY ENTITY IN LOCAL MODE zi_demo_meterreadingupload
           UPDATE FROM update_uploads
           REPORTED DATA(update_reported).

    " propagate messages
    LOOP AT update_reported-upload INTO DATA(update_reported_upload).
      INSERT CORRESPONDING #( update_reported_upload ) INTO TABLE reported-upload.
    ENDLOOP.
  ENDMETHOD.

  METHOD set_status.
    initialize( ).

    " read data from buffer
    DATA uploads TYPE zif_demo_meter_reading_types=>read_upload_table.
    READ ENTITY IN LOCAL MODE zi_demo_meterreadingupload FROM VALUE #(
        FOR key IN keys
        ( %key-MeterReadingUploadUUID = key-MeterReadingUploadUUID
          %control                    = VALUE #(
              MeterReadingUploadUUID = if_abap_behv=>mk-on
              MeterReadingDocumentId = if_abap_behv=>mk-on
              MeterReadingDate       = if_abap_behv=>mk-on
              MeterReadingResult     = if_abap_behv=>mk-on
              MeterReadingUnit       = if_abap_behv=>mk-on
              BusinessPartner        = if_abap_behv=>mk-on
              ContractAccount        = if_abap_behv=>mk-on
              Contract               = if_abap_behv=>mk-on
              ConnectionObject       = if_abap_behv=>mk-on
              Equipment              = if_abap_behv=>mk-on
              UploadStatus           = if_abap_behv=>mk-on ) ) )
         RESULT uploads
         REPORTED DATA(read_reported).

    " propagate messages
    LOOP AT read_reported-upload INTO DATA(read_reported_upload).
      INSERT CORRESPONDING #( read_reported_upload ) INTO TABLE reported-upload.
    ENDLOOP.

    " determine new status
    DATA(update_uploads) = VALUE zif_demo_meter_reading_types=>update_upload_table( ).
    LOOP AT uploads INTO DATA(upload).
      TRY.
          " Determine Status and add entry to update table (happy path)
          DATA(update_upload) = CORRESPONDING zif_demo_meter_reading_types=>update_upload( upload ).
          DATA(upload_status) = model->determine_upload_status( CORRESPONDING #( upload ) ).

          " This is necessary to avoid an infinite loop by recursive calls of the determinations
          IF upload_status <> upload-UploadStatus.
            update_upload-UploadStatus = upload_status.
            update_upload-%control-UploadStatus = if_abap_behv=>mk-on.
            INSERT update_upload INTO TABLE update_uploads.
          ENDIF.

        CATCH zcx_rap_exception INTO DATA(exception).
          " add error message to REPORTED
          INSERT CORRESPONDING #( upload ) INTO TABLE reported-upload ASSIGNING FIELD-SYMBOL(<reported_upload>).
          <reported_upload>-%msg = exception.
      ENDTRY.
    ENDLOOP.

    " modify buffer
    MODIFY ENTITY IN LOCAL MODE zi_demo_meterreadingupload
           UPDATE FROM update_uploads
           REPORTED DATA(update_reported).

    " propagate messages
    LOOP AT update_reported-upload INTO DATA(update_reported_upload).
      INSERT CORRESPONDING #( update_reported_upload ) INTO TABLE reported-upload.
    ENDLOOP.
  ENDMETHOD.

  METHOD process_meter_reading.
    initialize( ).

    " read data from buffer
    DATA uploads TYPE zif_demo_meter_reading_types=>read_upload_table.
    READ ENTITY IN LOCAL MODE zi_demo_meterreadingupload FROM VALUE #(
        FOR key IN keys
        ( %key-MeterReadingUploadUUID = key-MeterReadingUploadUUID
          %control                    = VALUE #(
              MeterReadingUploadUUID  = if_abap_behv=>mk-on
              MeterReadingDocumentId  = if_abap_behv=>mk-on ) ) )
         RESULT uploads
         REPORTED DATA(read_reported).

    " propagate messages
    LOOP AT read_reported-upload INTO DATA(read_reported_upload).
      INSERT CORRESPONDING #( read_reported_upload ) INTO TABLE reported-upload.
    ENDLOOP.

    LOOP AT uploads INTO DATA(upload).
      TRY.
          " Check if the entry was already processed
          IF upload-MeterReadingDocumentId IS NOT INITIAL.
            CONTINUE.
          ENDIF.

          " Some ABAP statements like COMMIT WORK are not allowed within actions
          " Therefore we need to implement them in a way that we can control,
          " whether a COMMIT is executed or not
          model->start_processing( i_upload_uuid = upload-MeterReadingUploadUUID
                                   i_commit      = abap_false ).

        CATCH zcx_rap_exception INTO DATA(exception).
          INSERT CORRESPONDING #( upload ) INTO TABLE failed-upload.
          INSERT CORRESPONDING #( upload ) INTO TABLE reported-upload ASSIGNING FIELD-SYMBOL(<reported_upload>).
          <reported_upload>-%msg = exception.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD set_remark.
    initialize( ).

    " read data from buffer
    DATA uploads TYPE zif_demo_meter_reading_types=>read_upload_table.
    READ ENTITY IN LOCAL MODE zi_demo_meterreadingupload FROM VALUE #(
        FOR x_key IN keys
        ( %key-MeterReadingUploadUUID = x_key-MeterReadingUploadUUID
          %control                    = VALUE #(
              MeterReadingUploadUUID  = if_abap_behv=>mk-on
              MeterReadingDocumentId  = if_abap_behv=>mk-on ) ) )
         RESULT uploads
         REPORTED DATA(read_reported).

    " propagate messages
    LOOP AT read_reported-upload INTO DATA(read_reported_upload).
      INSERT CORRESPONDING #( read_reported_upload ) INTO TABLE reported-upload.
    ENDLOOP.

    DATA(update_uploads) = VALUE zif_demo_meter_reading_types=>update_upload_table( ).
    LOOP AT uploads INTO DATA(upload).
      DATA(key) = keys[ KEY entity %tky = upload-%tky ].

      " Determine Status and add entry to update table (happy path)
      DATA(update_upload) = CORRESPONDING zif_demo_meter_reading_types=>update_upload( upload ).

      IF upload-Remark <> key-%param-Remark.
        update_upload-Remark = key-%param-Remark.
        update_upload-%control-Remark = if_abap_behv=>mk-on.
        INSERT update_upload INTO TABLE update_uploads.
      ENDIF.

      INSERT VALUE #( %cid_ref = key-%cid_ref
                      %key     = CORRESPONDING #( key    )
                      %param   = CORRESPONDING #( upload ) ) INTO TABLE result.
    ENDLOOP.

    " modify buffer
    MODIFY ENTITY IN LOCAL MODE zi_demo_meterreadingupload
           UPDATE FROM update_uploads
           REPORTED DATA(update_reported).

    " propagate messages
    LOOP AT update_reported-upload INTO DATA(update_reported_upload).
      INSERT CORRESPONDING #( update_reported_upload ) INTO TABLE reported-upload.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.


CLASS lsc_ZI_DEMO_METERREADINGUPLOAD DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.
ENDCLASS.


CLASS lsc_ZI_DEMO_METERREADINGUPLOAD IMPLEMENTATION.
  METHOD save_modified.
    DATA exception TYPE REF TO zcx_rap_exception.

    " Raise Event 'Data changed' for all created entries to trigger processing
    LOOP AT create-upload INTO DATA(created_upload).
      " This is to avoid an infinite loop by repeated raising of this event
      " ( The event receiver also modifies this entity to save the ID after creation! )
      IF created_upload-MeterReadingDocumentId IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      TRY.
          zcl_demo_meter_reading_upl_wf=>raise_data_changed( i_upload_uuid = created_upload-MeterReadingUploadUUID ).

        CATCH zcx_rap_exception INTO exception.
          INSERT VALUE #( %key    = created_upload-%key
                          %create = if_abap_behv=>mk-on
                          %msg    = exception ) INTO TABLE reported-upload.
      ENDTRY.
    ENDLOOP.

    " Raise Event 'Data changed' for all updated entries to trigger processing
    LOOP AT update-upload INTO DATA(updated_upload).
      " This is to avoid an infinite loop by repeated raising of this event
      " ( The event receiver also modifies this entity to save the ID after creation! )
      IF updated_upload-MeterReadingDocumentId IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      TRY.
          zcl_demo_meter_reading_upl_wf=>raise_data_changed( i_upload_uuid = updated_upload-MeterReadingUploadUUID ).

        CATCH zcx_rap_exception INTO exception.
          INSERT VALUE #( %key    = updated_upload-%key
                          %update = if_abap_behv=>mk-on
                          %msg    = exception ) INTO TABLE reported-upload.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
