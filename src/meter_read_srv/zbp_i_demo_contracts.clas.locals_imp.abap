CLASS lhc_Contract DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    DATA db_access TYPE REF TO zif_demo_meter_reading_db.
    DATA utility TYPE REF TO zif_rap_utility.

    METHODS initialize.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
       IMPORTING REQUEST requested_authorizations FOR Contract RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Contract RESULT result.

    METHODS early_numbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Contract.

    METHODS exists_business_partner FOR VALIDATE ON SAVE
      IMPORTING keys FOR Contract~ExistsBusinessPartner.

    METHODS exists_connection_object FOR VALIDATE ON SAVE
      IMPORTING keys FOR Contract~ExistsConnectionObject.

    METHODS exists_contract_account FOR VALIDATE ON SAVE
      IMPORTING keys FOR Contract~ExistsContractAccount.

    METHODS exists_equipment FOR VALIDATE ON SAVE
      IMPORTING keys FOR Contract~ExistsEquipment.

    METHODS is_date_interval_valid FOR VALIDATE ON SAVE
      IMPORTING keys FOR Contract~IsDateIntervalValid.

    METHODS is_equipment_available FOR VALIDATE ON SAVE
      IMPORTING keys FOR Contract~IsEquipmentAvailable.
ENDCLASS.

CLASS lhc_Contract IMPLEMENTATION.
  METHOD initialize.
    db_access = NEW zcl_demo_meter_reading_db( ).
    utility = NEW zcl_rap_utility( ).
  ENDMETHOD.

  METHOD get_global_authorizations.
    initialize( ).

    IF requested_authorizations-%create = if_abap_behv=>mk-on.
      TRY.
          utility->check_authority( i_root_entity_name = 'ZI_DEMO_CONTRACTS'
                                    i_entity_name      = 'ZI_DEMO_CONTRACTS'
                                    i_operation        = 'C' ).

          result-%create = if_abap_behv=>auth-allowed.
        CATCH zcx_rap_exception.
          result-%create = if_abap_behv=>auth-unauthorized.
      ENDTRY.
    ENDIF.

    IF requested_authorizations-%update = if_abap_behv=>mk-on.
      TRY.
          utility->check_authority( i_root_entity_name = 'ZI_DEMO_CONTRACTS'
                                    i_entity_name      = 'ZI_DEMO_CONTRACTS'
                                    i_operation        = 'U' ).

          result-%update = if_abap_behv=>auth-allowed.
        CATCH zcx_rap_exception.
          result-%update = if_abap_behv=>auth-unauthorized.
      ENDTRY.
    ENDIF.

    IF requested_authorizations-%delete = if_abap_behv=>mk-on.
      TRY.
          utility->check_authority( i_root_entity_name = 'ZI_DEMO_CONTRACTS'
                                    i_entity_name      = 'ZI_DEMO_CONTRACTS'
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
            utility->check_authority( i_root_entity_name = 'ZI_DEMO_CONTRACTS'
                                      i_entity_name      = 'ZI_DEMO_CONTRACTS'
                                      i_operation        = 'U' ).

            <result>-%update = if_abap_behv=>auth-allowed.
          CATCH zcx_rap_exception.
            <result>-%update = if_abap_behv=>auth-unauthorized.
        ENDTRY.
      ENDIF.

      IF requested_authorizations-%delete = if_abap_behv=>mk-on.
        TRY.
            utility->check_authority( i_root_entity_name = 'ZI_DEMO_CONTRACTS'
                                      i_entity_name      = 'ZI_DEMO_CONTRACTS'
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
          DATA new_contract TYPE zdmo_contract.
          CALL FUNCTION 'NUMBER_GET_NEXT'
            EXPORTING
              nr_range_nr = '01'
              object      = 'ZDMO_CONTR'
            IMPORTING
              number      = new_contract
            EXCEPTIONS
              OTHERS      = 1.
          IF sy-subrc <> 0.
            RAISE EXCEPTION TYPE zcx_rap_exception
                  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.

          " New ID found: Add to MAPPED
          INSERT VALUE #( %cid = entity-%cid contract = new_contract ) INTO TABLE mapped-contract.

        CATCH zcx_rap_exception INTO DATA(exception).
          " Error in ID creation: Add to FAILED and REPORTED
          INSERT VALUE #( %cid = entity-%cid ) INTO TABLE failed-contract.
          INSERT VALUE #( %cid = entity-%cid %msg = exception ) INTO TABLE reported-contract.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD exists_business_partner.
    initialize( ).

    DATA contracts TYPE zif_demo_meter_reading_types=>read_contract_table.
    READ ENTITY IN LOCAL MODE zi_demo_contracts FROM VALUE #(
        FOR key IN keys
        ( %key-Contract = key-Contract
          %control      = VALUE #( Contract        = if_abap_behv=>mk-on
                                   BusinessPartner = if_abap_behv=>mk-on ) ) )
         RESULT contracts
         FAILED DATA(read_failed).

    LOOP AT read_failed-contract INTO DATA(read_failed_contract).
      INSERT CORRESPONDING #( read_failed_contract ) INTO TABLE failed-contract.
    ENDLOOP.

    LOOP AT contracts INTO DATA(contract).
      TRY.
          IF NOT db_access->exists_business_partner( contract-BusinessPartner ).
            RAISE EXCEPTION TYPE zcx_rap_exception
                  MESSAGE e000(zdmo_meter_read_srv) WITH contract-BusinessPartner.
          ENDIF.

        CATCH zcx_rap_exception INTO DATA(exception).
          INSERT VALUE #( Contract = contract-Contract ) INTO TABLE failed-contract.
          INSERT VALUE #( Contract = contract-Contract %msg = exception ) INTO TABLE reported-contract.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD exists_connection_object.
    initialize( ).

    DATA contracts TYPE zif_demo_meter_reading_types=>read_contract_table.
    READ ENTITY IN LOCAL MODE zi_demo_contracts FROM VALUE #(
        FOR key IN keys
        ( %key-Contract = key-Contract
          %control      = VALUE #( Contract         = if_abap_behv=>mk-on
                                   ConnectionObject = if_abap_behv=>mk-on ) ) )
         RESULT contracts
         FAILED DATA(read_failed).

    LOOP AT read_failed-contract INTO DATA(read_failed_contract).
      INSERT CORRESPONDING #( read_failed_contract ) INTO TABLE failed-contract.
    ENDLOOP.

    LOOP AT contracts INTO DATA(contract).
      TRY.
          IF NOT db_access->exists_connection_object( contract-ConnectionObject ).
            RAISE EXCEPTION TYPE zcx_rap_exception
                  MESSAGE e001(zdmo_meter_read_srv) WITH contract-ConnectionObject.
          ENDIF.

        CATCH zcx_rap_exception INTO DATA(exception).
          INSERT VALUE #( Contract = contract-Contract ) INTO TABLE failed-contract.
          INSERT VALUE #( Contract = contract-Contract %msg = exception ) INTO TABLE reported-contract.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD exists_contract_account.
    initialize( ).

    DATA contracts TYPE zif_demo_meter_reading_types=>read_contract_table.
    READ ENTITY IN LOCAL MODE zi_demo_contracts FROM VALUE #(
        FOR key IN keys
        ( %key-Contract = key-Contract
          %control      = VALUE #( Contract        = if_abap_behv=>mk-on
                                   ContractAccount = if_abap_behv=>mk-on ) ) )
         RESULT contracts
         FAILED DATA(read_failed).

    LOOP AT read_failed-contract INTO DATA(read_failed_contract).
      INSERT CORRESPONDING #( read_failed_contract ) INTO TABLE failed-contract.
    ENDLOOP.

    LOOP AT contracts INTO DATA(contract).
      TRY.
          IF NOT db_access->exists_contract_account( contract-ContractAccount ).
            RAISE EXCEPTION TYPE zcx_rap_exception
                  MESSAGE e002(zdmo_meter_read_srv) WITH contract-ContractAccount.
          ENDIF.

        CATCH zcx_rap_exception INTO DATA(exception).
          INSERT VALUE #( Contract = contract-Contract ) INTO TABLE failed-contract.
          INSERT VALUE #( Contract = contract-Contract %msg = exception ) INTO TABLE reported-contract.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD exists_equipment.
    initialize( ).

    DATA contracts TYPE zif_demo_meter_reading_types=>read_contract_table.
    READ ENTITY IN LOCAL MODE zi_demo_contracts FROM VALUE #(
        FOR key IN keys
        ( %key-Contract = key-Contract
          %control      = VALUE #( Contract  = if_abap_behv=>mk-on
                                   Equipment = if_abap_behv=>mk-on ) ) )
         RESULT contracts
         FAILED DATA(read_failed).

    LOOP AT read_failed-contract INTO DATA(read_failed_contract).
      INSERT CORRESPONDING #( read_failed_contract ) INTO TABLE failed-contract.
    ENDLOOP.

    LOOP AT contracts INTO DATA(contract).
      TRY.
          IF NOT db_access->exists_equipment( contract-Equipment ).
            RAISE EXCEPTION TYPE zcx_rap_exception
                  MESSAGE e003(zdmo_meter_read_srv) WITH contract-Equipment.
          ENDIF.

        CATCH zcx_rap_exception INTO DATA(exception).
          INSERT VALUE #( Contract = contract-Contract ) INTO TABLE failed-contract.
          INSERT VALUE #( Contract = contract-Contract %msg = exception ) INTO TABLE reported-contract.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_date_interval_valid.
    initialize( ).

    DATA contracts TYPE zif_demo_meter_reading_types=>read_contract_table.
    READ ENTITY IN LOCAL MODE zi_demo_contracts FROM VALUE #(
        FOR key IN keys
        ( %key-Contract = key-Contract
          %control      = VALUE #( Contract          = if_abap_behv=>mk-on
                                   ContractStartDate = if_abap_behv=>mk-on
                                   ContractEndDate   = if_abap_behv=>mk-on ) ) )
         RESULT contracts
         FAILED DATA(read_failed).

    LOOP AT read_failed-contract INTO DATA(read_failed_contract).
      INSERT CORRESPONDING #( read_failed_contract ) INTO TABLE failed-contract.
    ENDLOOP.

    LOOP AT contracts INTO DATA(contract).
      TRY.
          IF NOT db_access->is_date_interval_valid( i_date_from = contract-ContractStartDate
                                                    i_date_to   = contract-ContractEndDate ).

            RAISE EXCEPTION TYPE zcx_rap_exception
                  MESSAGE e004(zdmo_meter_read_srv) WITH contract-ContractStartDate contract-ContractEndDate.
          ENDIF.

        CATCH zcx_rap_exception INTO DATA(exception).
          INSERT VALUE #( Contract = contract-Contract ) INTO TABLE failed-contract.
          INSERT VALUE #( Contract = contract-Contract %msg = exception ) INTO TABLE reported-contract.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_equipment_available.
    initialize( ).

    DATA contracts TYPE zif_demo_meter_reading_types=>read_contract_table.
    READ ENTITY IN LOCAL MODE zi_demo_contracts FROM VALUE #(
        FOR key IN keys
        ( %key-Contract = key-Contract
          %control      = VALUE #( Contract          = if_abap_behv=>mk-on
                                   Equipment         = if_abap_behv=>mk-on
                                   ContractStartDate = if_abap_behv=>mk-on
                                   ContractEndDate   = if_abap_behv=>mk-on ) ) )
         RESULT contracts
         FAILED DATA(read_failed).

    LOOP AT read_failed-contract INTO DATA(read_failed_contract).
      INSERT CORRESPONDING #( read_failed_contract ) INTO TABLE failed-contract.
    ENDLOOP.

    LOOP AT contracts INTO DATA(contract).
      TRY.
          IF NOT db_access->is_equipment_available( i_contract  = contract-Contract
                                                    i_equipment = contract-Equipment
                                                    i_date_from = contract-ContractStartDate
                                                    i_date_to   = contract-ContractEndDate ).

            RAISE EXCEPTION TYPE zcx_rap_exception
                  MESSAGE e005(zdmo_meter_read_srv) WITH contract-Equipment contract-ContractStartDate contract-ContractEndDate.
          ENDIF.

        CATCH zcx_rap_exception INTO DATA(exception).
          INSERT VALUE #( Contract = contract-Contract ) INTO TABLE failed-contract.
          INSERT VALUE #( Contract = contract-Contract %msg = exception ) INTO TABLE reported-contract.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
