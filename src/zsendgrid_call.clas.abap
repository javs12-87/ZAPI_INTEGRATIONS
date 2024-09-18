CLASS zsendgrid_call DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES :
      BEGIN OF email_struct,
        email TYPE string,
      END OF email_struct.

    TYPES :
      BEGIN OF to_struct,
        to TYPE Table of email_struct with default key,
      END OF to_struct.

    TYPES :
      BEGIN OF content_struct,
        type  TYPE string,
        value TYPE string,
      END OF content_struct.

    TYPES :
      BEGIN OF api_struct,
        personalizations type table of to_struct with DEFAULT KEY,
        from             TYPE email_struct,
        subject          TYPE string,
        content          TYPE table of content_struct with default key,
      END OF api_struct."

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZSENDGRID_CALL IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.


    DATA(ls_email) = VALUE email_struct( email = 'jorge.baltazar@sap.com' ).
    Data: test1 type table of email_struct.

    append value #( email = 'jorge.baltazar@sap.com' ) to test1.

    DATA(ls_to) = VALUE to_struct( to = test1 ).

    Data: test2 type table of to_struct.
    append value #( to = test1 ) to test2.

    DATA: test3 type table of content_struct.
    DATA(ls_content) = VALUE content_struct( type = 'application/json'
                                             value = 'test' ).
    append ls_content to test3.

    DATA(ls_body) = VALUE api_struct( personalizations = test2
                                      from = ls_email
                                      subject = 'Test email'
                                      content = test3 ).

    DATA(lrf_descr) = cl_abap_typedescr=>describe_by_data( ls_body ).
    DATA(lv_json) = /ui2/cl_json=>serialize( data = ls_body compress = abap_true pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).
    out->write( lv_json ).

    " Create HTTP client; send request
    TRY.
        DATA(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
                                 comm_scenario  = 'ZAPI_SENDGRID_COMM'
                                 service_id     = 'ZAPI_SENDGRID_REST'

                               ).

        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( i_destination = lo_destination ).
        DATA(lo_request) = lo_http_client->get_http_request( ).


*      DATA(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>get ).
*      DATA(lv_json_results) = lo_response->get_text( ).

        "adding headers
        lo_request->set_header_fields( VALUE #(
                                                        (  name = 'Authorization' value = 'Bearer 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' )
                                                        (  name = 'Accept' value = 'application/json' )
                                                        (  name = 'Content-Type' value = 'application/json' )
                                                        ) ).


        lo_request->append_text(
          EXPORTING
            data   = lv_json
        ).

        "set request method and execute request
        DATA(lo_web_http_response) = lo_http_client->execute( if_web_http_client=>post ).
        DATA(lv_response) = lo_web_http_response->get_text( ).

        out->write( lv_response ).

      CATCH cx_root INTO DATA(lx_exception).
        out->write( lx_exception->get_text( ) ).
    ENDTRY.


  ENDMETHOD.
ENDCLASS.
