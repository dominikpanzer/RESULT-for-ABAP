CLASS zcl_result DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    TYPES: ty_results TYPE TABLE OF REF TO zcl_result.

    CLASS-METHODS ok IMPORTING value         TYPE any OPTIONAL
                     RETURNING VALUE(result) TYPE REF TO zcl_result.
    CLASS-METHODS fail IMPORTING error_message TYPE string OPTIONAL
                       RETURNING VALUE(result) TYPE REF TO zcl_result.

    CLASS-METHODS fail_if
      IMPORTING this_is_true  TYPE abap_boolean
                error_message TYPE string OPTIONAL
      RETURNING
                VALUE(result) TYPE REF TO zcl_result.
    CLASS-METHODS ok_if
      IMPORTING this_is_true  TYPE abap_boolean
                error_message TYPE string OPTIONAL
      RETURNING
                VALUE(result) TYPE REF TO zcl_result.

    METHODS is_failure RETURNING VALUE(is_failure) TYPE abap_boolean.
    METHODS is_ok RETURNING VALUE(is_ok) TYPE abap_boolean.
    METHODS get_value RETURNING VALUE(value) TYPE REF TO data
                      RAISING
                                zcx_result_is_not_ok.
    METHODS get_error_message RETURNING VALUE(error_message) TYPE string
                              RAISING
                                        zcx_result_is_not_failure.
    METHODS combine_with_one IMPORTING other_result           TYPE REF TO zcl_result
                             RETURNING VALUE(combined_result) TYPE REF TO zcl_result.
    METHODS combine_with_multiple IMPORTING results                TYPE ty_results
                                  RETURNING VALUE(combined_result) TYPE REF TO zcl_result.
    METHODS with_metadata
      IMPORTING
                key           TYPE char30
                value         TYPE any
      RETURNING VALUE(result) TYPE REF TO zcl_result.
    METHODS get_all_metadata
      RETURNING
        VALUE(metadata) TYPE ztt_metadata.
    METHODS get_metadata
      IMPORTING
        key          TYPE char30
      RETURNING
        VALUE(value) TYPE REF TO data.
    METHODS get_error_messages
      RETURNING
        VALUE(error_messages) TYPE ztt_error_messages.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA error_messages TYPE ztt_error_messages.
    DATA value TYPE REF TO data.
    DATA result_is_ok TYPE abap_boolean.
    DATA result_is_failure TYPE abap_boolean.
    DATA metadata TYPE ztt_metadata.
    METHODS: constructor IMPORTING is_ok         TYPE abap_boolean
                                   value         TYPE any
                                   error_message TYPE string.
    METHODS   both_results_are_okay IMPORTING result          TYPE REF TO zcl_result
                                    RETURNING VALUE(r_result) TYPE abap_bool.
    METHODS   there_is_nothing_to_combine IMPORTING results       TYPE ty_results
                                          RETURNING VALUE(result) TYPE abap_bool.
    METHODS it_is_the_first_combination  RETURNING VALUE(result) TYPE abap_bool.
ENDCLASS.



CLASS zcl_result IMPLEMENTATION.

  METHOD ok.
    result = NEW zcl_result( is_ok = abap_true
                             value = value
                             error_message = space ).
  ENDMETHOD.

  METHOD constructor.
    result_is_ok = is_ok.
    result_is_failure = xsdbool( is_ok <> abap_true ).
    me->value = REF #( value ).
    CHECK result_is_failure = abap_true.
    APPEND error_message TO error_messages.
  ENDMETHOD.


  METHOD fail.
    result = NEW zcl_result( is_ok = abap_false
                             value = space
                             error_message = error_message ).
  ENDMETHOD.


  METHOD combine_with_one.
    IF both_results_are_okay( other_result ).
      combined_result = zcl_result=>ok( ).
      EXIT.
    ENDIF.

    IF is_failure( ) AND other_result->is_failure( ).
      APPEND other_result->get_error_message( ) TO error_messages.
      combined_result = me.
      EXIT.
    ENDIF.

    IF is_failure( ).
      combined_result = me.
      EXIT.
    ENDIF.
    combined_result = other_result.
  ENDMETHOD.

  METHOD both_results_are_okay.
    r_result = xsdbool( is_ok( ) AND result->is_ok( ) ).
  ENDMETHOD.


  METHOD combine_with_multiple.

    IF there_is_nothing_to_combine( results ).
      combined_result = me.
      EXIT.
    ENDIF.
    LOOP AT results ASSIGNING FIELD-SYMBOL(<result>).
      IF it_is_the_first_combination( ).
        combined_result = combine_with_one( <result> ).
      ELSE.
        combined_result = combined_result->combine_with_one( <result> ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD it_is_the_first_combination.
    result = xsdbool( sy-tabix = 1 ).
  ENDMETHOD.

  METHOD there_is_nothing_to_combine.
    result = xsdbool( lines( results ) = 0 ).
  ENDMETHOD.

  METHOD is_failure.
    is_failure = result_is_failure.
  ENDMETHOD.

  METHOD is_ok.
    is_ok = result_is_ok.
  ENDMETHOD.

  METHOD get_value.
    IF is_failure( ).
      RAISE EXCEPTION TYPE zcx_result_is_not_ok.
    ENDIF.
    IF me->value IS NOT BOUND.
      value = REF #( space ).
    ELSE.
      value = me->value.
    ENDIF.
  ENDMETHOD.

  METHOD get_error_message.
    IF is_ok( ).
      RAISE EXCEPTION TYPE zcx_result_is_not_failure.
    ENDIF.
    CHECK error_messages IS NOT INITIAL.
    error_message = error_messages[ 1 ].
  ENDMETHOD.

  METHOD fail_if.
    IF this_is_true = abap_true.
      result = zcl_result=>fail( error_message ).
    ELSE.
      result = zcl_result=>ok( ).
    ENDIF.
  ENDMETHOD.

  METHOD ok_if.
    result = zcl_result=>fail_if( this_is_true = xsdbool( this_is_true <> abap_true ) error_message = error_message ).
  ENDMETHOD.

  METHOD with_metadata.
    result = me.
    CHECK NOT line_exists( metadata[ key = key ] ).
    metadata = VALUE #( BASE metadata ( key = key value = REF #( value ) ) ).
  ENDMETHOD.

  METHOD get_all_metadata.
    metadata = me->metadata.
  ENDMETHOD.


  METHOD get_metadata.
    value = VALUE #( metadata[ key = key ]-value OPTIONAL ).
  ENDMETHOD.


  METHOD get_error_messages.
    error_messages = me->error_messages.
  ENDMETHOD.

ENDCLASS.
