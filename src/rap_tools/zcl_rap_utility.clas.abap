CLASS zcl_rap_utility DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_rap_utility.

    ALIASES cds_mapping_table FOR zif_rap_utility~cds_mapping_table.
    ALIASES cds_entity_fields FOR zif_rap_utility~cds_entity_fields.
    ALIASES get_mapping_for_cds_entity FOR zif_rap_utility~get_mapping_for_cds_entity.
    ALIASES convert_message_to_bapireturn FOR zif_rap_utility~convert_message_to_bapireturn.

  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS load_behaviour_definition
      IMPORTING i_behaviour_definition TYPE abp_entity_name
                i_update               TYPE abap_bool default abap_true
      EXPORTING e_cds_mapping_table    TYPE cds_mapping_table
                e_read_only_fields     TYPE cds_entity_fields
      RAISING   zcx_rap_exception.

    METHODS get_read_only_fields
      IMPORTING i_behaviour_definition    TYPE abp_entity_name
                i_cds_entity              TYPE abp_entity_name
                i_update                  TYPE abap_bool default abap_true
      RETURNING VALUE(r_read_only_fields) TYPE cds_entity_fields
      RAISING   zcx_rap_exception.
ENDCLASS.



CLASS ZCL_RAP_UTILITY IMPLEMENTATION.


  METHOD zif_rap_utility~get_mappings_for_behaviour.
    load_behaviour_definition(
      EXPORTING
        i_behaviour_definition = i_behaviour_definition
      IMPORTING
        e_cds_mapping_table    = r_cds_mapping_table ).
  ENDMETHOD.


  METHOD zif_rap_utility~get_mapping_for_cds_entity.
    load_behaviour_definition(
      EXPORTING
        i_behaviour_definition = i_behaviour_definition
      IMPORTING
        e_cds_mapping_table    = DATA(cds_mapping_table) ).

    r_cds_mapping = cds_mapping_table[ cds_entity = to_upper( i_cds_entity ) ].
  ENDMETHOD.


  METHOD get_read_only_fields.
    load_behaviour_definition(
      EXPORTING
        i_behaviour_definition = i_behaviour_definition
        i_update               = i_update
      IMPORTING
        e_read_only_fields     = r_read_only_fields ).

    DELETE r_read_only_fields WHERE entity_name <> to_upper( i_cds_entity ).
  ENDMETHOD.


  METHOD load_behaviour_definition.
    " Load Behavior Definition as in CL_API_EXTRACTOR_BDEF, LCL_BDEF
    DATA head               TYPE cl_abap_behv_load=>t_head.
    DATA entities           TYPE cl_abap_behv_load=>tt_entity.
    DATA associations       TYPE cl_abap_behv_load=>tt_assoc.
    DATA actions            TYPE cl_abap_behv_load=>tt_action.
    DATA relations          TYPE cl_abap_behv_load=>tt_relat.
    DATA utc_timestamp      TYPE cl_abap_behv_load=>t_timestamp.
    DATA features           TYPE cl_abap_behv_load=>tt_feature.
    DATA detvals            TYPE cl_abap_behv_load=>tt_detval.
    DATA detvals_dvm        TYPE cl_abap_behv_load=>tt_detval_dvm.
    DATA determine_actions  TYPE cl_abap_behv_load=>tt_determine_action.
    DATA extension_elements TYPE cl_abap_behv_load=>tt_extension_element.
    DATA root_entity_name   TYPE abp_root_entity_name.
    DATA has_syntax_error   TYPE abap_bool.

    DATA(entity_name) = CONV abp_entity_name( to_upper( i_behaviour_definition ) ).

    DATA(result) =
      cl_abap_behv_load=>get_load( EXPORTING entity                      = entity_name
                                             all                         = 'E'
                                             check_syntax                = 'X'
                                             ignore_dynamic_switchstates = 'X'
                                   IMPORTING head                        = head
                                             entities                    = entities
                                             associations                = associations
                                             actions                     = actions
                                             relations                   = relations
                                             utc_timestamp               = utc_timestamp
                                             features                    = features
                                             detvals                     = detvals
                                             detvals_dvm                 = detvals_dvm
                                             determine_actions           = determine_actions
                                             extension_elements          = extension_elements
                                   CHANGING  root_entity                 = root_entity_name ).

    CASE result.
      WHEN cl_abap_behv_load=>ok.
        " OK
      WHEN cl_abap_behv_load=>syntax_error.
        has_syntax_error = abap_true.

      WHEN OTHERS.
        " TODO: Error Message
        RAISE EXCEPTION NEW zcx_rap_exception( ).

*      WHEN cl_abap_behv_load=>root_entity_not_found.
*      WHEN cl_abap_behv_load=>no_load_after_generation.
*      WHEN cl_abap_behv_load=>not_authorized.
*      WHEN cl_abap_behv_load=>transmission_error.
*      WHEN cl_abap_behv_load=>root_without_bdef.
    ENDCASE.

    IF has_syntax_error = abap_true.
      RETURN.
    ENDIF.

    " Collect mappings, if requested
    IF e_cds_mapping_table IS SUPPLIED.
      IF head-impltype = cl_abap_behv_load=>c_impltype_projection.
        " get base BO
        TRY.
            DATA(base_root_entity_name) = relations[ source_entity = root_entity_name kind = cl_abap_behv_load=>c_relation_base ]-target_entity.
            " SAP Standard performs a syntax check for the base BO at this point; omitted for now
          CATCH cx_sy_itab_line_not_found.
            " no projection: BO itself is base BO
            base_root_entity_name = root_entity_name.
        ENDTRY.
      ENDIF.

      LOOP AT entities INTO DATA(entity).
        entity_name = entity-name.

        TRY.
            DATA(base_entity_name) = relations[ source_entity = entity_name kind = cl_abap_behv_load=>c_relation_base ]-target_entity.
          CATCH cx_sy_itab_line_not_found.
            " no projection: BO itself is base BO
            base_entity_name = entity-name.
        ENDTRY.

        " We need up to two mappings here:
        " Projection View -> Interface View -> Database Table
        " Both mappings have to be resolved accordingly
        cl_abap_behvdescr=>get_mappings( EXPORTING p_root_name   = root_entity_name
                                                   p_entity_name = entity_name
                                         IMPORTING partner_table = DATA(mappings) ).

        IF base_root_entity_name <> root_entity_name OR base_entity_name <> entity_name.
          cl_abap_behvdescr=>get_mappings( EXPORTING p_root_name   = base_root_entity_name
                                                     p_entity_name = base_entity_name
                                           IMPORTING partner_table = DATA(base_mappings) ).
        ENDIF.

        INSERT INITIAL LINE INTO TABLE e_cds_mapping_table ASSIGNING FIELD-SYMBOL(<cds_mapping>).
        <cds_mapping>-cds_entity = entity_name.
        <cds_mapping>-db_table   = entity-persist_name.

        IF line_exists( mappings[ partner_name = entity-persist_name ] ).
          <cds_mapping>-mapping_table = mappings[ partner_name = entity-persist_name ]-mapping_table.
        ELSEIF line_exists( base_mappings[ partner_name = entity-persist_name ] ).
          <cds_mapping>-mapping_table = base_mappings[ partner_name = entity-persist_name ]-mapping_table.
        ELSE.
          " TODO: Raise Exception?
        ENDIF.
      ENDLOOP.
    ENDIF.

    " Collect read-only fields, if requested
    IF e_read_only_fields IS SUPPLIED.
      LOOP AT features INTO DATA(feature).
        IF feature-element_kind = cl_abap_behv_load=>c_feature_elem_field.
          IF    feature-static_features O cl_abap_behv_load=>c_feature_sf_read_only
          OR (  feature-static_features O cl_abap_behv_load=>c_feature_sf_read_only_update AND i_update = abap_true ).
            INSERT VALUE #( entity_name  = feature-owner_entity
                            element_name = feature-element )
                   INTO TABLE e_read_only_fields.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.


  METHOD zif_rap_utility~map_cds_entity_to_db_table.
    DATA(cds_mapping) = get_mapping_for_cds_entity( i_behaviour_definition = i_behaviour_definition
                                                    i_cds_entity           = i_cds_entity ).

    LOOP AT i_cds_entity_data ASSIGNING FIELD-SYMBOL(<cds_entity>).
      INSERT INITIAL LINE INTO TABLE c_db_table_data ASSIGNING FIELD-SYMBOL(<db_entry>).

      LOOP AT cds_mapping-mapping_table INTO DATA(mapping_entry).
        ASSIGN COMPONENT mapping_entry-entity_comp  OF STRUCTURE <cds_entity> TO FIELD-SYMBOL(<cds_field>).
        ASSIGN COMPONENT mapping_entry-partner_comp OF STRUCTURE <db_entry>   TO FIELD-SYMBOL(<db_field>).

        IF <cds_field> IS ASSIGNED AND <db_field> IS ASSIGNED.
          <db_field> = <cds_field>.
        ENDIF.

        UNASSIGN: <cds_field>, <db_field>.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.


  METHOD zif_rap_utility~map_db_table_to_cds_entity.
    DATA(cds_mapping) = get_mapping_for_cds_entity( i_behaviour_definition = i_behaviour_definition
                                                    i_cds_entity           = i_cds_entity ).

    DATA(read_only_fields) = get_read_only_fields( i_behaviour_definition = i_behaviour_definition
                                                   i_cds_entity           = i_cds_entity
                                                   i_update               = i_update ).

    LOOP AT i_db_table_data ASSIGNING FIELD-SYMBOL(<db_entry>).
      INSERT INITIAL LINE INTO TABLE c_cds_entity_data ASSIGNING FIELD-SYMBOL(<cds_entity>).
      ASSIGN COMPONENT '%CONTROL' OF STRUCTURE <cds_entity> TO FIELD-SYMBOL(<control>).

      LOOP AT cds_mapping-mapping_table INTO DATA(mapping_entry).
        " This method can map to CDS View structures as well as to RAP derived types
        " %control is only available for the derived types
        ASSIGN COMPONENT mapping_entry-entity_comp  OF STRUCTURE <cds_entity> TO FIELD-SYMBOL(<cds_field>).
        ASSIGN COMPONENT mapping_entry-partner_comp OF STRUCTURE <db_entry>   TO FIELD-SYMBOL(<db_field>).

        IF <control> IS ASSIGNED.
          ASSIGN COMPONENT mapping_entry-entity_comp  OF STRUCTURE <control>    TO FIELD-SYMBOL(<ctrl_field>).
        ENDIF.

        IF <cds_field> IS ASSIGNED AND <db_field> IS ASSIGNED. " AND <ctrl_field> IS ASSIGNED.
          <cds_field> = <db_field>.


          IF <ctrl_field> IS ASSIGNED.
            " check for read-only fields
            IF line_exists( read_only_fields[ element_name = mapping_entry-entity_comp ] ).
              <ctrl_field> = if_abap_behv=>mk-off.
            ELSE.
              <ctrl_field> = if_abap_behv=>mk-on.
            ENDIF.
          ENDIF.
        ENDIF.

        UNASSIGN: <cds_field>, <db_field>, <ctrl_field>.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.


  METHOD zif_rap_utility~convert_reported_to_bapireturn.
    TYPES message_table TYPE STANDARD TABLE OF REF TO if_abap_behv_message.
    FIELD-SYMBOLS <other>   TYPE message_table.
    FIELD-SYMBOLS <message> TYPE REF TO if_abap_behv_message.

    DATA(structure_descriptor) = CAST cl_abap_structdescr(
      cl_abap_typedescr=>describe_by_data( i_reported ) ).

    " Collect all messages from afflicted entities
    LOOP AT structure_descriptor->components INTO DATA(component)
         WHERE name <> '%OTHER'.

      ASSIGN COMPONENT component-name OF STRUCTURE i_reported TO FIELD-SYMBOL(<entity>).
      ASSIGN COMPONENT '%MSG' OF STRUCTURE <entity> TO <message>.
      IF sy-subrc = 0.
        INSERT convert_message_to_bapireturn( <message> ) INTO TABLE r_bapi_return_table.
      ENDIF.
    ENDLOOP.

    " Collect other messages
    ASSIGN COMPONENT '%OTHER' OF STRUCTURE i_reported TO <other>.
    LOOP AT <other> ASSIGNING <message>.
      INSERT convert_message_to_bapireturn( <message> ) INTO TABLE r_bapi_return_table.
    ENDLOOP.
  ENDMETHOD.


  METHOD zif_rap_utility~convert_message_to_bapireturn.
    r_bapi_return = VALUE #(
      id         = i_message->if_t100_message~t100key-msgid
      number     = i_message->if_t100_message~t100key-msgno
      type       = i_message->if_t100_dyn_msg~msgty
      message_v1 = i_message->if_t100_dyn_msg~msgv1
      message_v2 = i_message->if_t100_dyn_msg~msgv2
      message_v3 = i_message->if_t100_dyn_msg~msgv3
      message_v4 = i_message->if_t100_dyn_msg~msgv4
      message    = i_message->if_message~get_text( ) ).

    IF r_bapi_return-type IS INITIAL.
      r_bapi_return-type = SWITCH #( i_message->m_severity
        WHEN if_abap_behv_message=>severity-information THEN 'I'
        WHEN if_abap_behv_message=>severity-success     THEN 'S'
        WHEN if_abap_behv_message=>severity-warning     THEN 'W'
        WHEN if_abap_behv_message=>severity-error       THEN 'E' ).
    ENDIF.
  ENDMETHOD.


  METHOD zif_rap_utility~check_authority.
    IF     i_association_name IS SUPPLIED
       AND i_action_name      IS SUPPLIED.

      AUTHORITY-CHECK OBJECT 'ZABP_BEHV'
                      ID 'ACTVT'      FIELD '16'
                      ID 'ZABP_ROOT'  FIELD i_root_entity_name
                      ID 'ZABP_ENTY'  FIELD i_entity_name
                      ID 'ZABP_OP'    FIELD i_operation
                      ID 'ZABP_ASSOC' FIELD i_association_name
                      ID 'ZABP_ACT'   FIELD i_action_name.

    ELSEIF     i_association_name IS SUPPLIED
           AND i_action_name      IS NOT SUPPLIED.

      AUTHORITY-CHECK OBJECT 'ZABP_BEHV'
                      ID 'ACTVT'      FIELD '16'
                      ID 'ZABP_ROOT'  FIELD i_root_entity_name
                      ID 'ZABP_ENTY'  FIELD i_entity_name
                      ID 'ZABP_OP'    FIELD i_operation
                      ID 'ZABP_ASSOC' FIELD i_association_name.

    ELSEIF     i_association_name IS NOT SUPPLIED
           AND i_action_name      IS SUPPLIED.

      AUTHORITY-CHECK OBJECT 'ZABP_BEHV'
                      ID 'ACTVT'     FIELD '16'
                      ID 'ZABP_ROOT' FIELD i_root_entity_name
                      ID 'ZABP_ENTY' FIELD i_entity_name
                      ID 'ZABP_OP'   FIELD i_operation
                      ID 'ZABP_ACT'  FIELD i_action_name.

    ELSEIF     i_association_name IS NOT SUPPLIED
           AND i_action_name      IS NOT SUPPLIED.

      AUTHORITY-CHECK OBJECT 'ZABP_BEHV'
                      ID 'ACTVT'     FIELD '16'
                      ID 'ZABP_ROOT' FIELD i_root_entity_name
                      ID 'ZABP_ENTY' FIELD i_entity_name
                      ID 'ZABP_OP'   FIELD i_operation.

    ENDIF.
    IF sy-subrc <> 0.
      RAISE EXCEPTION NEW zcx_rap_exception( ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
