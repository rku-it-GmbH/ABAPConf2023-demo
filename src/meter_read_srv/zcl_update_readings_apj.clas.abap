CLASS zcl_update_readings_apj DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_apj_rt_exec_object.
    INTERFACES if_apj_dt_exec_object.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_update_readings_apj IMPLEMENTATION.
  METHOD if_apj_rt_exec_object~execute.
  ENDMETHOD.

  METHOD if_apj_dt_exec_object~get_parameters.
  ENDMETHOD.
ENDCLASS.
