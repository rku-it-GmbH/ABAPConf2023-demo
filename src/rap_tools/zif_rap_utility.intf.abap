INTERFACE zif_rap_utility PUBLIC.

  TYPES:
    "! Mapping between CDS entity and Database Table
    BEGIN OF cds_mapping,
      cds_entity    TYPE abp_entity_name,
      db_table      TYPE tabname,
      mapping_table TYPE cl_abap_behvdescr=>tt_component_map,
    END OF cds_mapping.

  "! Mappings between CDS entities and Database Tables
  TYPES cds_mapping_table TYPE STANDARD TABLE OF cds_mapping WITH EMPTY KEY.

  TYPES:
    "! Field of a CDS entity
    BEGIN OF cds_entity_field,
      entity_name  TYPE abp_entity_name,
      element_name TYPE abp_element_name,
    END OF cds_entity_field.

  "! Fields of a CDS entity
  TYPES cds_entity_fields TYPE HASHED TABLE OF cds_entity_field WITH UNIQUE KEY entity_name element_name.

  "! Check authority for a RAP operation
  "! @parameter i_root_entity_name | Root entity / Behavior definition
  "! @parameter i_entity_name      | CDS entity
  "! @parameter i_operation        | Operation
  "! @parameter i_association_name | CDS association
  "! @parameter i_action_name      | RAP action
  "! @raising   zcx_rap_exception  | User is not authorized
  METHODS check_authority
    IMPORTING i_root_entity_name TYPE abp_root_entity_name
              i_entity_name      TYPE abp_entity_name
              i_operation        TYPE abp_behv_op
              i_association_name TYPE abp_association_name OPTIONAL
              i_action_name      TYPE abp_action_name      OPTIONAL
    RAISING   zcx_rap_exception.

  "! Reads mappings for all entities of a Behavior Definition
  "! @parameter i_behaviour_definition | Behavior Definition
  "! @parameter r_cds_mapping_table    | Mappings between CDS entities and Database Tables
  "! @raising   zcx_rap_exception      | Exception occurred
  METHODS get_mappings_for_behaviour
    IMPORTING i_behaviour_definition     TYPE abp_entity_name
    RETURNING VALUE(r_cds_mapping_table) TYPE cds_mapping_table
    RAISING   zcx_rap_exception.

  "! Reads mapping for a specific CDS entity of a Behavior Definition
  "! @parameter i_behaviour_definition | Behavior Definition
  "! @parameter i_cds_entity           | CDS entity
  "! @parameter r_cds_mapping          | Mapping between CDS entity and Database Table
  "! @raising   zcx_rap_exception      | Exception occurred
  METHODS get_mapping_for_cds_entity
    IMPORTING i_behaviour_definition TYPE abp_entity_name
              i_cds_entity           TYPE abp_entity_name
    RETURNING VALUE(r_cds_mapping)   TYPE cds_mapping
    RAISING   zcx_rap_exception.

  "! Maps from the Database Table structure to the CDS entity structure
  "! @parameter i_behaviour_definition | Behavior Definition
  "! @parameter i_cds_entity           | CDS entity
  "! @parameter i_update               | set %control for update (not create)
  "! @parameter i_db_table_data        | Database Table data
  "! @parameter c_cds_entity_data      | CDS entity data
  "! @raising   zcx_rap_exception      | Exception occurred
  METHODS map_db_table_to_cds_entity
    IMPORTING i_behaviour_definition TYPE abp_entity_name
              i_cds_entity           TYPE abp_entity_name
              i_update               TYPE abap_bool DEFAULT abap_true
              i_db_table_data        TYPE STANDARD TABLE
    CHANGING  c_cds_entity_data      TYPE STANDARD TABLE
    RAISING   zcx_rap_exception.

  "! Maps from the CDS entity structure to the Database Table structure
  "! @parameter i_behaviour_definition | Behavior Definition
  "! @parameter i_cds_entity           | CDS entity
  "! @parameter i_cds_entity_data      | CDS entity data
  "! @parameter c_db_table_data        | Database Table data
  "! @raising   zcx_rap_exception      | Exception occurred
  METHODS map_cds_entity_to_db_table
    IMPORTING i_behaviour_definition TYPE abp_entity_name
              i_cds_entity           TYPE abp_entity_name
              i_cds_entity_data      TYPE STANDARD TABLE
    CHANGING  c_db_table_data        TYPE STANDARD TABLE
    RAISING   zcx_rap_exception.

  "! Converts a derived type of type response for reported (early/late)
  "! to BAPI return table by collecting all messages
  "! @parameter i_reported          | REPORTED structure
  "! @parameter r_bapi_return_table | BAPI return table
  METHODS convert_reported_to_bapireturn
    IMPORTING i_reported                 TYPE data
    RETURNING VALUE(r_bapi_return_table) TYPE bapirettab.

  "! Converts a message raised by a behavior implementation
  "! to a BAPI return message
  "! @parameter i_message     | Message from Behavior
  "! @parameter r_bapi_return | BAPI return message
  METHODS convert_message_to_bapireturn
    IMPORTING i_message            TYPE REF TO if_abap_behv_message
    RETURNING VALUE(r_bapi_return) TYPE bapiret2.

ENDINTERFACE.
