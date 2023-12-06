FUNCTION-POOL zdemo_meter_reading_rfc.

DATA adapter TYPE REF TO zif_demo_meter_reading_rfc.
DATA utility TYPE REF TO zif_rap_utility.

LOAD-OF-PROGRAM.
  utility = NEW zcl_rap_utility( ).
  adapter = NEW zcl_demo_meter_reading_rfc( ).
