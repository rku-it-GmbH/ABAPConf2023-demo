CLASS zcl_demo_meter_reading_db DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_demo_meter_reading_db.

    ALIASES is_date_interval_valid FOR zif_demo_meter_reading_db~is_date_interval_valid.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_DEMO_METER_READING_DB IMPLEMENTATION.


  METHOD zif_demo_meter_reading_db~exists_business_partner.
    SELECT SINGLE @abap_true FROM but000
     WHERE partner = @i_business_partner
      INTO @r_exists.
  ENDMETHOD.


  METHOD zif_demo_meter_reading_db~exists_connection_object.
    SELECT SINGLE @abap_true FROM iflot
     WHERE tplnr = @i_connection_object
      INTO @r_exists.
  ENDMETHOD.


  METHOD zif_demo_meter_reading_db~exists_contract_account.
    SELECT SINGLE @abap_true FROM fkkvkp
     WHERE vkont = @i_contract_account
      INTO @r_exists.
  ENDMETHOD.


  METHOD zif_demo_meter_reading_db~exists_equipment.
    SELECT SINGLE @abap_true FROM equi
     WHERE equnr = @i_equipment
      INTO @r_exists.
  ENDMETHOD.


  METHOD zif_demo_meter_reading_db~is_date_interval_valid.
    IF i_date_from IS INITIAL OR i_date_to IS INITIAL.
      r_is_valid = abap_false.
      RETURN.
    ENDIF.

    IF i_date_from > i_date_to.
      r_is_valid = abap_false.
      RETURN.
    ENDIF.

    CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
      EXPORTING
        date   = i_date_from
      EXCEPTIONS
        OTHERS = 1.
    IF sy-subrc <> 0.
      r_is_valid = abap_false.
      RETURN.
    ENDIF.

    CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
      EXPORTING
        date   = i_date_to
      EXCEPTIONS
        OTHERS = 1.
    IF sy-subrc <> 0.
      r_is_valid = abap_false.
      RETURN.
    ENDIF.

    r_is_valid = abap_true.
  ENDMETHOD.


  METHOD zif_demo_meter_reading_db~is_equipment_available.
    SELECT contract, contract_start_date, contract_end_date
      FROM zdmo_contracts
     WHERE contract            <> @i_contract
       AND equipment            = @i_equipment
       AND contract_start_date <= @i_date_to
       AND contract_end_date   >= @i_date_from
      INTO TABLE @DATA(overlapping_contracts).

    r_is_available = xsdbool( lines( overlapping_contracts ) = 0 ).
  ENDMETHOD.


  METHOD zif_demo_meter_reading_db~get_readings_for_equipment.
    IF is_date_interval_valid( i_date_from = i_date_from
                               i_date_to   = i_date_to ).
      SELECT * FROM ZI_Demo_MeterReadingDocuments
       WHERE Equipment         = @i_equipment
         AND MeterReadingDate >= @i_date_from
         AND MeterReadingDate <= @i_date_to
        INTO CORRESPONDING FIELDS OF TABLE @r_meter_reading_documents.
    ELSE.
      SELECT * FROM ZI_Demo_MeterReadingDocuments
       WHERE Equipment = @i_equipment
        INTO CORRESPONDING FIELDS OF TABLE @r_meter_reading_documents.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
