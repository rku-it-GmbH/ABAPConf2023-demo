CLASS zcl_demo_meter_reading_model DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_demo_meter_reading_model.

    ALIASES identify_connection_object FOR zif_demo_meter_reading_model~identify_connection_object.
    ALIASES check_upload_consistency   FOR zif_demo_meter_reading_model~check_upload_consistency.

    METHODS constructor.

  PRIVATE SECTION.
    DATA db_access TYPE REF TO zif_demo_meter_reading_db.
    DATA utility   TYPE REF TO zif_rap_utility.
ENDCLASS.



CLASS ZCL_DEMO_METER_READING_MODEL IMPLEMENTATION.


  METHOD constructor.
    db_access = NEW zcl_demo_meter_reading_db( ).
    utility   = NEW zcl_rap_utility( ).
  ENDMETHOD.


  METHOD zif_demo_meter_reading_model~determine_status.
    DATA(document) = i_meter_reading_document.

    IF document-MeterReadingUnit IS INITIAL AND document-MeterReadingResult IS INITIAL.
      r_status = zif_demo_meter_reading_types=>status-order_created.
    ELSE.
      r_status = zif_demo_meter_reading_types=>status-plausible.
    ENDIF.

    LOOP AT db_access->get_readings_for_equipment( document-Equipment ) INTO DATA(other_document)
         WHERE MeterReadingStatus = CONV zdmo_meter_reading_status( zif_demo_meter_reading_types=>status-plausible ).
      " plausibility check
      IF    document-MeterReadingUnit <> other_document-MeterReadingUnit
         OR (     document-MeterReadingDate   < other_document-MeterReadingDate
              AND document-MeterReadingResult > other_document-MeterReadingResult )
         OR (     document-MeterReadingDate   > other_document-MeterReadingDate
              AND document-MeterReadingResult < other_document-MeterReadingResult ).
        r_status = zif_demo_meter_reading_types=>status-not_plausible.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD zif_demo_meter_reading_model~identify_business_partner.
    IF i_meter_reading_upload-BusinessPartner IS NOT INITIAL.
      r_business_partner = i_meter_reading_upload-BusinessPartner.
      RETURN.
    ENDIF.

    IF i_meter_reading_upload-Contract IS NOT INITIAL.
      SELECT SINGLE BusinessPartner FROM ZI_Demo_Contracts
       WHERE Contract = @i_meter_reading_upload-Contract
        INTO @r_business_partner.
      IF sy-subrc = 0.
        RETURN.
      ENDIF.
    ENDIF.

    IF i_meter_reading_upload-ContractAccount IS NOT INITIAL.
      SELECT SINGLE BusinessPartner FROM I_ContractAccountPartner
       WHERE ContractAccount = @i_meter_reading_upload-ContractAccount
        INTO @r_business_partner.
      IF sy-subrc = 0.
        RETURN.
      ENDIF.
    ENDIF.

    " Search Business Partner by Address
    DATA address_data  TYPE bapibus1006_addr_search.
    DATA central_data  TYPE bapibus1006_central_search.
    DATA search_result TYPE STANDARD TABLE OF bapibus1006_bp_addr WITH EMPTY KEY.
    DATA return        TYPE STANDARD TABLE OF bapiret2 WITH EMPTY KEY.

    address_data = VALUE #( city1      = i_meter_reading_upload-City
                            postl_cod1 = i_meter_reading_upload-PostCode
                            street     = i_meter_reading_upload-Street
                            house_no   = i_meter_reading_upload-HouseNumber
                            house_no2  = i_meter_reading_upload-HouseNumberSupplement ).

    central_data = VALUE #( mc_name1 = to_upper( i_meter_reading_upload-LastName  )
                            mc_name2 = to_upper( i_meter_reading_upload-FirstName ) ).

    CALL FUNCTION 'BAPI_BUPA_SEARCH_2'
      EXPORTING
        addressdata  = address_data
        centraldata  = central_data
      TABLES
        searchresult = search_result
        return       = return.

    " Propagate BAPI Return Errors
    LOOP AT return TRANSPORTING NO FIELDS WHERE type CA 'AEX'.
      RAISE EXCEPTION NEW zcx_rap_exception( bapi_return_table = CORRESPONDING #( return[] ) ).
    ENDLOOP.

    CASE lines( search_result ).
      WHEN 1.
        r_business_partner = search_result[ 1 ]-partner.
      WHEN 0.
        RAISE EXCEPTION TYPE zcx_rap_exception MESSAGE e006(zdmo_meter_read_srv).
      WHEN OTHERS.
        RAISE EXCEPTION TYPE zcx_rap_exception MESSAGE e007(zdmo_meter_read_srv).
    ENDCASE.
  ENDMETHOD.


  METHOD zif_demo_meter_reading_model~identify_connection_object.
    IF i_meter_reading_upload-ConnectionObject IS NOT INITIAL.
      r_connection_object = i_meter_reading_upload-ConnectionObject.
      RETURN.
    ENDIF.

    IF i_meter_reading_upload-Contract IS NOT INITIAL.
      SELECT SINGLE ConnectionObject FROM ZI_Demo_Contracts
       WHERE Contract = @i_meter_reading_upload-Contract
        INTO @r_connection_object.
      IF sy-subrc = 0.
        RETURN.
      ENDIF.
    ENDIF.

    " Search Connection Object by Address
    DATA search_for     TYPE addr1_find.
    DATA address_groups TYPE STANDARD TABLE OF adagroups WITH EMPTY KEY.
    DATA search_result  TYPE STANDARD TABLE OF addr1_val WITH EMPTY KEY.
    DATA error_table    TYPE STANDARD TABLE OF addr_error WITH EMPTY KEY.

    address_groups = VALUE #( ( addr_group = 'PM01' ) ).

    search_for = VALUE #( street_lng = i_meter_reading_upload-Street
                          house_num1 = i_meter_reading_upload-HouseNumber
                          house_num2 = i_meter_reading_upload-HouseNumberSupplement
                          post_code1 = i_meter_reading_upload-PostCode
                          city1_lng  = i_meter_reading_upload-City ).

    CALL FUNCTION 'ADDR_SEARCH'
      EXPORTING
        search_in_all_groups = abap_false
        search_for           = search_for
      TABLES
        address_groups       = address_groups
        search_result        = search_result
        error_table          = error_table
      EXCEPTIONS
        OTHERS               = 1.
    IF sy-subrc <> 0.
      " TODO: Error Handling, map ADDR_ERROR to BAPI Return
    ENDIF.

    DATA(functional_location_category) = CONV fltyp( 'A' ). " A = Anschlussobjekt
    SELECT FunctionalLocation FROM I_FunctionalLocationData
       FOR ALL ENTRIES IN @search_result
     WHERE AddressID                  = @search_result-addrnumber
       AND FunctionalLocationCategory = @functional_location_category
      INTO TABLE @DATA(functional_locations).

    " Unfortunately, the CDS View I_FunctionalLocationData proved to be unreliable
    " Therefore, this selection is added as a fallback
    IF sy-subrc <> 0.
      SELECT iflot~tplnr AS FunctionalLocation
        FROM iflot JOIN iloa ON iflot~iloan = iloa~iloan
         FOR ALL ENTRIES IN @search_result
       WHERE iloa~adrnr  = @search_result-addrnumber
         AND iflot~fltyp = @functional_location_category
        INTO TABLE @functional_locations.
    ENDIF.

    CASE lines( functional_locations ).
      WHEN 1.
        r_connection_object = functional_locations[ 1 ]-FunctionalLocation.
      WHEN 0.
        RAISE EXCEPTION TYPE zcx_rap_exception MESSAGE e008(zdmo_meter_read_srv).
      WHEN OTHERS.
        RAISE EXCEPTION TYPE zcx_rap_exception MESSAGE e009(zdmo_meter_read_srv).
    ENDCASE.
  ENDMETHOD.


  METHOD zif_demo_meter_reading_model~identify_contract_account.
    IF i_meter_reading_upload-ContractAccount IS NOT INITIAL.
      r_contract_account = i_meter_reading_upload-ContractAccount.
      RETURN.
    ENDIF.

    IF i_meter_reading_upload-Contract IS NOT INITIAL.
      SELECT SINGLE ContractAccount FROM ZI_Demo_Contracts
       WHERE Contract = @i_meter_reading_upload-Contract
        INTO @r_contract_account.
      IF sy-subrc = 0.
        RETURN.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD zif_demo_meter_reading_model~identify_contract.
    IF i_meter_reading_upload-Contract IS NOT INITIAL.
      r_contract = i_meter_reading_upload-Contract.
      RETURN.
    ENDIF.

    IF    i_meter_reading_upload-Equipment        IS INITIAL
       OR i_meter_reading_upload-MeterReadingDate IS INITIAL.
      RETURN.
    ENDIF.

    SELECT SINGLE Contract FROM ZI_Demo_Contracts
     WHERE Equipment          = @i_meter_reading_upload-Equipment
       AND ContractStartDate <= @i_meter_reading_upload-MeterReadingDate
       AND ContractEndDate   >= @i_meter_reading_upload-MeterReadingDate
      INTO @r_contract.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_rap_exception
            MESSAGE e014(zdmo_meter_read_srv)
            WITH i_meter_reading_upload-Equipment i_meter_reading_upload-MeterReadingDate.
    ENDIF.
  ENDMETHOD.


  METHOD zif_demo_meter_reading_model~identify_equipment.
    IF i_meter_reading_upload-Equipment IS NOT INITIAL.
      r_equipment = i_meter_reading_upload-Equipment.
      RETURN.
    ENDIF.

    SELECT Equipment FROM I_Equipment
     WHERE SerialNumber = @i_meter_reading_upload-SerialNumber
      INTO TABLE @DATA(equipments).

    CASE lines( equipments ).
      WHEN 1.
        r_equipment = equipments[ 1 ]-equipment.
      WHEN 0.
        RAISE EXCEPTION TYPE zcx_rap_exception MESSAGE e010(zdmo_meter_read_srv).
      WHEN OTHERS.
        RAISE EXCEPTION TYPE zcx_rap_exception MESSAGE e011(zdmo_meter_read_srv).
    ENDCASE.
  ENDMETHOD.


  METHOD zif_demo_meter_reading_model~start_processing.
    " TODO: Use Adapter?
    DATA key TYPE STRUCTURE FOR READ IMPORT zi_demo_meterreadingupload\\Upload.

    " Read Upload Data
    key = VALUE #( MeterReadingUploadUUID = i_upload_uuid
                   %control               = VALUE #( MeterReadingDocumentId = if_abap_behv=>mk-on
                                                     MeterReadingDate       = if_abap_behv=>mk-on
                                                     MeterReadingResult     = if_abap_behv=>mk-on
                                                     MeterReadingUnit       = if_abap_behv=>mk-on
                                                     MeterReadingSource     = if_abap_behv=>mk-on
                                                     Contract               = if_abap_behv=>mk-on
                                                     ContractAccount        = if_abap_behv=>mk-on
                                                     BusinessPartner        = if_abap_behv=>mk-on
                                                     ConnectionObject       = if_abap_behv=>mk-on
                                                     Equipment              = if_abap_behv=>mk-on ) ).

    READ ENTITY zi_demo_meterreadingupload
         FROM VALUE #( ( key ) )
         RESULT DATA(uploads)
         REPORTED DATA(read_reported).

    " Raise Exception, if not found
    IF read_reported IS NOT INITIAL.
      IF i_commit = abap_true.
        ROLLBACK ENTITIES.
      ENDIF.

      RAISE EXCEPTION NEW zcx_rap_exception( bapi_return_table = utility->convert_reported_to_bapireturn( read_reported ) ).
    ENDIF.

    " Table has no lines or a single line
    LOOP AT uploads INTO DATA(upload).
      " Only support mode 'Create' for now
      IF upload-MeterReadingDocumentId IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      " Check data consistency
      check_upload_consistency( CORRESPONDING #( upload ) ).

      TRY.
          " Use Upload UUID as CID; not necessary in this case,
          " but very useful, if we also created by association
          cl_system_uuid=>convert_uuid_x16_static( EXPORTING uuid     = upload-MeterReadingUploadUUID
                                                   IMPORTING uuid_c32 = DATA(uuid_c32) ).

        CATCH cx_uuid_error.
          CLEAR uuid_c32.
      ENDTRY.

      " Create new Meter Reading Document
      DATA(create_document) = VALUE zif_demo_meter_reading_types=>create_document(
                                        %cid     = uuid_c32
                                        %data    = CORRESPONDING #( upload-%data )
                                        %control = CORRESPONDING #( key-%control EXCEPT MeterReadingDocumentId ) ).

      MODIFY ENTITY zi_demo_meterreadingdocuments
             CREATE FROM VALUE #( ( create_document ) )
             MAPPED DATA(create_mapped)
             FAILED DATA(create_failed)
             REPORTED DATA(create_reported).

      " Raise Exception, if failed
      IF create_failed IS NOT INITIAL.
        IF i_commit = abap_true.
          ROLLBACK ENTITIES.
        ENDIF.

        RAISE EXCEPTION NEW zcx_rap_exception( bapi_return_table = utility->convert_reported_to_bapireturn( create_reported ) ).
      ENDIF.

      " Write new Document ID to Upload data
      READ TABLE create_mapped-document INTO DATA(created_document)
           WITH KEY %cid = uuid_c32.
      IF sy-subrc = 0.
        upload-MeterReadingDocumentId = created_document-MeterReadingDocumentId.
      ENDIF.

      MODIFY ENTITY zi_demo_meterreadingupload
             UPDATE FROM VALUE #( ( MeterReadingUploadUUID          = upload-MeterReadingUploadUUID
                                    MeterReadingDocumentId          = upload-MeterReadingDocumentId
                                    %control-MeterReadingDocumentId = if_abap_behv=>mk-on ) )
             FAILED DATA(update_failed)
             REPORTED DATA(update_reported).

      " Raise Exception, if failed
      IF update_failed IS NOT INITIAL.
        IF i_commit = abap_true.
          ROLLBACK ENTITIES.
        ENDIF.

        RAISE EXCEPTION NEW zcx_rap_exception( bapi_return_table = utility->convert_reported_to_bapireturn( update_reported ) ).
      ENDIF.

      IF i_commit = abap_true.
        " Commit created Document
        COMMIT ENTITIES
               RESPONSE OF zi_demo_meterreadingdocuments
               FAILED DATA(commit_create_failed)
               REPORTED DATA(commit_create_reported).

        " Raise Exception, if failed
        IF commit_create_failed IS NOT INITIAL.
          ROLLBACK ENTITIES.
          RAISE EXCEPTION NEW zcx_rap_exception( bapi_return_table = utility->convert_reported_to_bapireturn( commit_create_reported ) ).
        ENDIF.

        " Commit updated Upload data
        COMMIT ENTITIES
               RESPONSE OF zi_demo_meterreadingupload
               FAILED DATA(commit_update_failed)
               REPORTED DATA(commit_update_reported).

        " Raise Exception, if failed
        IF commit_update_failed IS NOT INITIAL.
          ROLLBACK ENTITIES.
          RAISE EXCEPTION NEW zcx_rap_exception( bapi_return_table = utility->convert_reported_to_bapireturn( commit_update_reported ) ).
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD zif_demo_meter_reading_model~check_upload_consistency.
    " Consistency Check:
    " - Contract given
    " - Contract Account given
    " - Business Partner given
    " - Connection Object given
    " - Equipment given
    " - Date given
    " - Valid entry exists in ZI_Demo_Contracts
    " - No Meter Reading on them same day

    IF    i_meter_reading_upload-Contract         IS INITIAL
       OR i_meter_reading_upload-ContractAccount  IS INITIAL
       OR i_meter_reading_upload-BusinessPartner  IS INITIAL
       OR i_meter_reading_upload-ConnectionObject IS INITIAL
       OR i_meter_reading_upload-Equipment        IS INITIAL
       OR i_meter_reading_upload-MeterReadingDate IS INITIAL.

      RAISE EXCEPTION TYPE zcx_rap_exception MESSAGE e013(zdmo_meter_read_srv).
    ENDIF.

    SELECT SINGLE @abap_true FROM ZI_Demo_Contracts
     WHERE Contract           = @i_meter_reading_upload-Contract
       AND ContractAccount    = @i_meter_reading_upload-ContractAccount
       AND BusinessPartner    = @i_meter_reading_upload-BusinessPartner
       AND ConnectionObject   = @i_meter_reading_upload-ConnectionObject
       AND Equipment          = @i_meter_reading_upload-Equipment
       AND ContractStartDate <= @i_meter_reading_upload-MeterReadingDate
       AND ContractEndDate   >= @i_meter_reading_upload-MeterReadingDate
      INTO @DATA(valid_contract_found).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_rap_exception MESSAGE e012(zdmo_meter_read_srv).
    ENDIF.

    SELECT SINGLE @abap_true FROM ZI_Demo_MeterReadingDocuments
     WHERE Equipment        = @i_meter_reading_upload-Equipment
       AND MeterReadingDate = @i_meter_reading_upload-MeterReadingDate
      INTO @DATA(meter_reading_exists).
    IF meter_reading_exists = abap_true.
      RAISE EXCEPTION TYPE zcx_rap_exception MESSAGE e015(zdmo_meter_read_srv)
            WITH i_meter_reading_upload-Equipment i_meter_reading_upload-MeterReadingDate.
    ENDIF.
  ENDMETHOD.


  METHOD zif_demo_meter_reading_model~determine_upload_status.
    IF i_meter_reading_upload-MeterReadingDocumentId IS NOT INITIAL.
      r_upload_status = zif_demo_meter_reading_types=>upload_status-saved.
      RETURN.
    ENDIF.

    IF    i_meter_reading_upload-Contract           IS INITIAL
       OR i_meter_reading_upload-ContractAccount    IS INITIAL
       OR i_meter_reading_upload-BusinessPartner    IS INITIAL
       OR i_meter_reading_upload-ConnectionObject   IS INITIAL
       OR i_meter_reading_upload-Equipment          IS INITIAL
       OR i_meter_reading_upload-MeterReadingDate   IS INITIAL
       OR i_meter_reading_upload-MeterReadingResult IS INITIAL
       OR i_meter_reading_upload-MeterReadingUnit   IS INITIAL.
      r_upload_status = zif_demo_meter_reading_types=>upload_status-incomplete.
    ELSE.
      TRY.
          check_upload_consistency( i_meter_reading_upload ).
          r_upload_status = zif_demo_meter_reading_types=>upload_status-complete.
        CATCH zcx_rap_exception.
          r_upload_status = zif_demo_meter_reading_types=>upload_status-erroneous.
      ENDTRY.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
