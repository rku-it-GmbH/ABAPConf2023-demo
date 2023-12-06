INTERFACE zif_demo_meter_reading_rfc PUBLIC.

  METHODS upload_meter_reading_mass
    IMPORTING i_meter_reading_uploads TYPE zif_demo_meter_reading_types=>create_upload_table
    RAISING   zcx_rap_exception.

ENDINTERFACE.
