CLASS zcl_demo_meter_reading_upl_wf DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES bi_object.
    INTERFACES bi_persistent.
    INTERFACES if_workflow.

    "! called in RAP action StartProcessing to enable asynchronous processing
    EVENTS ready_for_processing.
    EVENTS data_changed.

    "! called in RAP action StartProcessing to enable asynchronous processing
    "! @parameter i_upload_uuid     | Upload UUID to be processed
    "! @parameter i_in_update_task  | Process in update task
    "! @raising   zcx_rap_exception | Exception occurred
    CLASS-METHODS raise_ready_for_processing
      IMPORTING i_upload_uuid    TYPE sysuuid_x16
                i_in_update_task TYPE abap_bool DEFAULT abap_true
      RAISING   zcx_rap_exception.

    "! called in RAP additional save to enable asynchronous processing
    "! @parameter i_upload_uuid     | Upload UUID to be processed
    "! @parameter i_in_update_task  | Process in update task
    "! @raising   zcx_rap_exception | Exception occurred
    CLASS-METHODS raise_data_changed
      IMPORTING i_upload_uuid    TYPE sysuuid_x16
                i_in_update_task TYPE abap_bool DEFAULT abap_true
      RAISING   zcx_rap_exception.

    METHODS constructor
      IMPORTING i_upload_uuid TYPE sysuuid_x16.

  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF instance_ref,
        lpor   TYPE sibflpor,
        object TYPE REF TO bi_persistent,
      END OF instance_ref.
    TYPES instance_refs TYPE HASHED TABLE OF instance_ref WITH UNIQUE KEY lpor.

    CLASS-DATA instances TYPE instance_refs.

    DATA lpor TYPE sibflpor.

    CLASS-METHODS uuid_to_lpor
      IMPORTING i_upload_uuid TYPE sysuuid_x16
      RETURNING VALUE(r_lpor) TYPE sibflpor.

    CLASS-METHODS lpor_to_uuid
      IMPORTING i_lpor               TYPE sibflpor
      RETURNING VALUE(r_upload_uuid) TYPE sysuuid_x16.
ENDCLASS.



CLASS ZCL_DEMO_METER_READING_UPL_WF IMPLEMENTATION.


  METHOD uuid_to_lpor.
    cl_system_uuid=>convert_uuid_x16_static( EXPORTING uuid     = i_upload_uuid
                                             IMPORTING uuid_c32 = DATA(uuid_c32) ).

    r_lpor-catid  = 'CL'.
    r_lpor-typeid = 'ZCL_DEMO_METER_READING_UPL_WF'.
    r_lpor-instid = uuid_c32.
  ENDMETHOD.


  METHOD bi_persistent~lpor.
    result = lpor.
  ENDMETHOD.


  METHOD bi_object~default_attribute_value.
    " ...
  ENDMETHOD.


  METHOD bi_persistent~refresh.
    " ...
  ENDMETHOD.


  METHOD raise_data_changed.
    TRY.
        " WF Instance ID needs to be character type
        cl_system_uuid=>convert_uuid_x16_static( EXPORTING uuid     = i_upload_uuid
                                                 IMPORTING uuid_c32 = DATA(objkey) ).

        CASE i_in_update_task.
          WHEN abap_false.
            cl_swf_evt_event=>raise( im_objcateg = cl_swf_evt_event=>mc_objcateg_cl
                                     im_objtype  = 'ZCL_DEMO_METER_READING_UPL_WF'
                                     im_event    = 'DATA_CHANGED'
                                     im_objkey   = objkey ).

          WHEN abap_true.
            cl_swf_evt_event=>raise_in_update_task( im_objcateg = cl_swf_evt_event=>mc_objcateg_cl
                                                    im_objtype  = 'ZCL_DEMO_METER_READING_UPL_WF'
                                                    im_event    = 'DATA_CHANGED'
                                                    im_objkey   = objkey ).
        ENDCASE.

      CATCH cx_uuid_error cx_swf_ifs_exception INTO DATA(previous).
        RAISE EXCEPTION NEW zcx_rap_exception( previous = previous ).
    ENDTRY.
  ENDMETHOD.


  METHOD raise_ready_for_processing.
    TRY.
        " WF Instance ID needs to be character type
        cl_system_uuid=>convert_uuid_x16_static( EXPORTING uuid     = i_upload_uuid
                                                 IMPORTING uuid_c32 = DATA(objkey) ).

        CASE i_in_update_task.
          WHEN abap_false.
            cl_swf_evt_event=>raise( im_objcateg = cl_swf_evt_event=>mc_objcateg_cl
                                     im_objtype  = 'ZCL_DEMO_METER_READING_UPL_WF'
                                     im_event    = 'READY_FOR_PROCESSING'
                                     im_objkey   = objkey ).

          WHEN abap_true.
            cl_swf_evt_event=>raise_in_update_task( im_objcateg = cl_swf_evt_event=>mc_objcateg_cl
                                                    im_objtype  = 'ZCL_DEMO_METER_READING_UPL_WF'
                                                    im_event    = 'READY_FOR_PROCESSING'
                                                    im_objkey   = objkey ).
        ENDCASE.

      CATCH cx_uuid_error cx_swf_ifs_exception INTO DATA(previous).
        RAISE EXCEPTION NEW zcx_rap_exception( previous = previous ).
    ENDTRY.
  ENDMETHOD.


  METHOD constructor.
    lpor = uuid_to_lpor( i_upload_uuid ).
  ENDMETHOD.


  METHOD bi_object~execute_default_method.
    " ...
  ENDMETHOD.


  METHOD bi_object~release.
    " ...
  ENDMETHOD.


  METHOD lpor_to_uuid.
    DATA(uuid_c32) = CONV sysuuid_c32( i_lpor-instid ).
    cl_system_uuid=>convert_uuid_c32_static( EXPORTING uuid     = uuid_c32
                                             IMPORTING uuid_x16 = r_upload_uuid ).
  ENDMETHOD.


  METHOD bi_persistent~find_by_lpor.
    TRY.
        result = instances[ lpor = lpor ]-object.
      CATCH cx_sy_itab_line_not_found.
        result = NEW zcl_demo_meter_reading_upl_wf( lpor_to_uuid( lpor ) ).
        INSERT VALUE #( lpor = lpor object = result ) INTO TABLE instances.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
