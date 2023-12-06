CLASS zcx_rap_exception DEFINITION PUBLIC INHERITING FROM cx_static_check CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_abap_behv_message.
    INTERFACES if_t100_dyn_msg.
    INTERFACES if_t100_message.

    DATA bapi_return_table TYPE bapirettab.

    METHODS constructor
      IMPORTING textid            LIKE if_t100_message=>t100key OPTIONAL
                !previous         LIKE previous                 OPTIONAL
                bapi_return_table TYPE bapirettab               OPTIONAL.

    METHODS convert_to_bapi_return
      RETURNING VALUE(r_bapi_return_table) TYPE bapirettab.

  PROTECTED SECTION.
  PRIVATE SECTION.
    ALIASES default_textid FOR if_t100_message~default_textid.
    ALIASES msgty          FOR if_t100_dyn_msg~msgty.
    ALIASES msgv1          FOR if_t100_dyn_msg~msgv1.
    ALIASES msgv2          FOR if_t100_dyn_msg~msgv2.
    ALIASES msgv3          FOR if_t100_dyn_msg~msgv3.
    ALIASES msgv4          FOR if_t100_dyn_msg~msgv4.
    ALIASES t100key        FOR if_t100_message~t100key.
    ALIASES severity       FOR if_abap_behv_message~m_severity.

    METHODS set_severity
      RETURNING VALUE(r_severity) TYPE if_abap_behv_message=>t_severity.
ENDCLASS.



CLASS zcx_rap_exception IMPLEMENTATION.
  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor( previous = previous ).
    me->bapi_return_table = bapi_return_table.

    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.

    severity = set_severity( ).
  ENDMETHOD.

  METHOD convert_to_bapi_return.
    IF bapi_return_table IS NOT INITIAL.
      r_bapi_return_table = bapi_return_table.
    ELSE.
      r_bapi_return_table = VALUE #( (
        id         = t100key-msgid
        number     = t100key-msgno
        type       = msgty
        message_v1 = msgv1
        message_v2 = msgv2
        message_v3 = msgv3
        message_v4 = msgv4 ) ).
    ENDIF.
  ENDMETHOD.

  METHOD set_severity.
    r_severity = SWITCH #( msgty
                           WHEN 'I' THEN if_abap_behv_message=>severity-information
                           WHEN 'S' THEN if_abap_behv_message=>severity-success
                           WHEN 'W' THEN if_abap_behv_message=>severity-warning
                           WHEN 'E' THEN if_abap_behv_message=>severity-error
                           WHEN 'A' THEN if_abap_behv_message=>severity-error
                           WHEN 'X' THEN if_abap_behv_message=>severity-error
                           ELSE          if_abap_behv_message=>severity-none ).
  ENDMETHOD.
ENDCLASS.
