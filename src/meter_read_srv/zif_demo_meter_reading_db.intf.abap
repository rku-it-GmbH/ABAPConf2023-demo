INTERFACE zif_demo_meter_reading_db PUBLIC.

  METHODS exists_business_partner
    IMPORTING i_business_partner TYPE bu_partner
    RETURNING VALUE(r_exists)    TYPE abap_bool.

  METHODS exists_connection_object
    IMPORTING i_connection_object TYPE zdmo_connection_object
    RETURNING VALUE(r_exists)     TYPE abap_bool.

  METHODS exists_contract_account
    IMPORTING i_contract_account TYPE vkont_kk
    RETURNING VALUE(r_exists)    TYPE abap_bool.

  METHODS exists_equipment
    IMPORTING i_equipment     TYPE equnr
    RETURNING VALUE(r_exists) TYPE abap_bool.

  METHODS is_date_interval_valid
    IMPORTING i_date_from       TYPE date_from
              i_date_to         TYPE date_to
    RETURNING VALUE(r_is_valid) TYPE abap_bool.

  METHODS is_equipment_available
    IMPORTING i_contract            TYPE zdmo_contract
              i_equipment           TYPE equnr
              i_date_from           TYPE date_from
              i_date_to             TYPE date_to
    RETURNING VALUE(r_is_available) TYPE abap_bool.

  METHODS get_readings_for_equipment
    IMPORTING i_equipment                      TYPE equnr
              i_date_from                      TYPE date_from OPTIONAL
              i_date_to                        TYPE date_to   OPTIONAL
    RETURNING VALUE(r_meter_reading_documents) TYPE zif_demo_meter_reading_types=>meter_reading_document_table.

ENDINTERFACE.
