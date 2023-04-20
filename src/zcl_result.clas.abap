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
                                        zcx_result_is_no_failure.
    METHODS combine_with_one IMPORTING other_result           TYPE REF TO zcl_result
                             RETURNING VALUE(combined_result) TYPE REF TO zcl_result.
    METHODS combine_with_multiple IMPORTING results                TYPE ty_results
                                  RETURNING VALUE(combined_result) TYPE REF TO zcl_result.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA error_message TYPE string.
    DATA value TYPE REF TO data.
    DATA result_is_ok TYPE abap_boolean.
    DATA result_is_failure TYPE abap_boolean.
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
    me->error_message = error_message.
  ENDMETHOD.


  METHOD fail.
    result = NEW zcl_result( is_ok = abap_false
                             value = space
                             error_message = error_message ).
  ENDMETHOD.


  METHOD combine_with_one.
    IF both_results_are_okay( other_result ).
      combined_result = NEW zcl_result( is_ok = abap_true
                                        value = space
                                        error_message = space ).
      EXIT.
    ENDIF.

    IF is_failure( ).
      combined_result = me.
    ELSE.
      combined_result = other_result.
    ENDIF.
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
      IF it_is_the_first_combination( ) = abap_true.
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
    value = me->value.
  ENDMETHOD.

  METHOD get_error_message.
    IF is_ok( ).
      RAISE EXCEPTION TYPE zcx_result_is_no_failure.
    ENDIF.

    error_message = me->error_message.
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

ENDCLASS.
