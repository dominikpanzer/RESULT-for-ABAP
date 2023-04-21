CLASS result_tests DEFINITION DEFERRED.
CLASS zcl_result DEFINITION LOCAL FRIENDS result_tests.
CLASS result_tests DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PUBLIC SECTION.


  PRIVATE SECTION.
    DATA error_message TYPE string VALUE 'A wild error occurred!'.
    METHODS create_ok_result FOR TESTING.
    METHODS create_ok_result_check_failed FOR TESTING.
    METHODS create_failed_result FOR TESTING.
    METHODS create_failed_result_check_ok FOR TESTING.
    METHODS ok_result_with_value FOR TESTING.
    METHODS failed_result_with_error FOR TESTING.
    METHODS combine_with_one_all_are_ok FOR TESTING.
    METHODS combine_multiple_all_are_ok FOR TESTING.
    METHODS combine_with_one_and_one_faild FOR TESTING RAISING cx_static_check.
    METHODS combine_with_one_and_all_faild FOR TESTING RAISING cx_static_check.
    METHODS cant_access_error_when_ok FOR TESTING RAISING cx_static_check.
    METHODS combine_multiple_all_failed FOR TESTING RAISING cx_static_check.
    METHODS combine_multiple_one_failed FOR TESTING RAISING cx_static_check.
    METHODS cant_access_value_when_failure FOR TESTING RAISING cx_static_check.
    METHODS combine_multiple_no_entries FOR TESTING RAISING cx_static_check.
    METHODS fail_if_true FOR TESTING RAISING cx_static_check.
    METHODS not_failure_if_false FOR TESTING RAISING cx_static_check.
    METHODS ok_if_true FOR TESTING RAISING cx_static_check.
    METHODS not_ok_if_false FOR TESTING RAISING cx_static_check.
    METHODS ok_result_with_object_as_value FOR TESTING RAISING cx_static_check.
    METHODS ok_result_with_table_as_value FOR TESTING RAISING cx_static_check.
    METHODS combine_multiple_two_failed FOR TESTING RAISING cx_static_check.
    METHODS fail_if_saves_error_message FOR TESTING RAISING cx_static_check.
    METHODS fail_if_returns_error_message FOR TESTING RAISING cx_static_check.
    METHODS fail_if_is_ok_throws_value FOR TESTING RAISING cx_static_check.
    METHODS ok_if_saves_error_message FOR TESTING RAISING cx_static_check.
    METHODS ok_if_is_failure_throws_error FOR TESTING RAISING cx_static_check.
    METHODS ok_if_returns_initial_value FOR TESTING RAISING cx_static_check.
    METHODS metadata_string_can_be_stored FOR TESTING RAISING cx_static_check.
    METHODS all_metadata_can_be_read FOR TESTING RAISING cx_static_check.
    METHODS this_returns_true RETURNING VALUE(result) TYPE abap_boolean.
    METHODS this_returns_false RETURNING VALUE(result) TYPE abap_boolean.

ENDCLASS.


CLASS result_tests IMPLEMENTATION.

  METHOD create_ok_result.
    DATA(result) = zcl_result=>ok( ).

    cl_abap_unit_assert=>assert_equals( msg = 'Not OK, but it should be ok' exp = abap_true act = result->is_ok( ) ).
  ENDMETHOD.

  METHOD create_ok_result_check_failed.
    DATA(result) = zcl_result=>ok( ).

    cl_abap_unit_assert=>assert_equals( msg = 'Failed, but it should be ok' exp = abap_false act = result->is_failure( ) ).
  ENDMETHOD.

  METHOD create_failed_result.
    DATA(result) = zcl_result=>fail( ).

    cl_abap_unit_assert=>assert_equals( msg = 'Not failed, but it should be failed' exp = abap_true act = result->is_failure( ) ).
  ENDMETHOD.

  METHOD create_failed_result_check_ok.
    DATA(result) = zcl_result=>fail( ).

    cl_abap_unit_assert=>assert_equals( msg = 'ok, but it should be failed' exp = abap_false act = result->is_ok( ) ).
  ENDMETHOD.

  METHOD ok_result_with_value.
    DATA(id_of_created_object) = '103535353'.
    DATA value LIKE id_of_created_object.

    DATA(result) = zcl_result=>ok( id_of_created_object ).
    DATA(temporary_value) = result->get_value( ).
    value = temporary_value->*.

    cl_abap_unit_assert=>assert_equals( msg = 'Couldnt access value' exp = id_of_created_object act = value ).
  ENDMETHOD.

  METHOD ok_result_with_object_as_value.
    DATA(random_object_reference) = zcl_result=>ok( ).
    DATA value TYPE REF TO zcl_result.

    DATA(result) = zcl_result=>ok( random_object_reference ).
    DATA(temporary_value) = result->get_value( ).
    value = temporary_value->*.

    cl_abap_unit_assert=>assert_equals( msg = 'Couldnt access value' exp = random_object_reference act = value ).
  ENDMETHOD.

  METHOD failed_result_with_error.
    DATA(result) = zcl_result=>fail( error_message ).

    cl_abap_unit_assert=>assert_equals( msg = 'error message not correct' exp = error_message act = result->get_error_message( ) ).
  ENDMETHOD.

  METHOD combine_with_one_all_are_ok.
    DATA(result_one) = zcl_result=>ok( ).
    DATA(result_two) = zcl_result=>ok( ).

    DATA(final_result) = result_one->combine_with_one( result_two ).

    cl_abap_unit_assert=>assert_equals( msg = 'Not OK, but it should be ok' exp = abap_true act = final_result->is_ok( ) ).
  ENDMETHOD.

  METHOD combine_multiple_all_are_ok.
    DATA results TYPE zcl_result=>ty_results.

    DATA(result_one) = zcl_result=>ok( ).
    DATA(result_two) = zcl_result=>ok( ).
    DATA(result_three) = zcl_result=>ok( ).
    APPEND result_two TO results.
    APPEND result_three TO results.

    DATA(final_result) = result_one->combine_with_multiple( results ).

    cl_abap_unit_assert=>assert_equals( msg = 'Not OK, but it should be ok' exp = abap_true act = final_result->is_ok( ) ).
  ENDMETHOD.

  METHOD combine_with_one_and_one_faild.
    DATA(result_one) = zcl_result=>ok( ).
    DATA(result_two) = zcl_result=>fail( error_message ).

    DATA(final_result) = result_one->combine_with_one( result_two ).

    cl_abap_unit_assert=>assert_equals( msg = 'OK but it should be not OK' exp = abap_false act = final_result->is_ok( ) ).
    cl_abap_unit_assert=>assert_equals( msg = 'Errormessage not correct' exp = error_message act = final_result->get_error_message( ) ).
  ENDMETHOD.

  METHOD combine_with_one_and_all_faild.
    DATA(result_one) = zcl_result=>fail( error_message ).
    DATA(result_two) = zcl_result=>fail( error_message ).

    DATA(final_result) = result_one->combine_with_one( result_two ).

    cl_abap_unit_assert=>assert_equals( msg = 'OK but it should be not OK' exp = abap_false act = final_result->is_ok( ) ).
    cl_abap_unit_assert=>assert_equals( msg = 'Errormessage not correct' exp = error_message act = final_result->get_error_message( ) ).
  ENDMETHOD.

  METHOD cant_access_error_when_ok.
    TRY.
        DATA(result) = zcl_result=>ok( ).
        result->get_error_message( ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_result_is_no_failure INTO DATA(result_is_no_failure).
        cl_abap_unit_assert=>assert_bound( result_is_no_failure ).
    ENDTRY.
  ENDMETHOD.

  METHOD cant_access_value_when_failure.
    TRY.
        DATA(result) = zcl_result=>fail( error_message ).
        result->get_value( ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_result_is_not_ok INTO DATA(result_is_not_ok).
        cl_abap_unit_assert=>assert_bound( result_is_not_ok ).
    ENDTRY.
  ENDMETHOD.

  METHOD combine_multiple_all_failed.
    DATA results TYPE zcl_result=>ty_results.

* arrange
    DATA(result_one) = zcl_result=>fail( error_message ).
    DATA(result_two) = zcl_result=>fail( 'no' ).
    DATA(result_three) = zcl_result=>fail( 'argh' ).

    APPEND result_two TO results.
    APPEND result_three TO results.

* act
    DATA(final_result) = result_one->combine_with_multiple( results ).

* assert
    cl_abap_unit_assert=>assert_equals( msg = 'OK, but it should be not OK' exp = abap_true act = final_result->is_failure( ) ).
  ENDMETHOD.

  METHOD combine_multiple_one_failed.
    DATA results TYPE zcl_result=>ty_results.

* arrange
    DATA(result_one) = zcl_result=>ok( ).
    DATA(result_two) = zcl_result=>fail( error_message ).
    DATA(result_three) = zcl_result=>ok( ).

    APPEND result_two TO results.
    APPEND result_three TO results.

* act
    DATA(final_result) = result_one->combine_with_multiple( results ).

* assert
    cl_abap_unit_assert=>assert_equals( msg = 'OK, but it should be not OK' exp = abap_true act = final_result->is_failure( ) ).
  ENDMETHOD.

  METHOD combine_multiple_no_entries.
    DATA results TYPE zcl_result=>ty_results.

    DATA(result_one) = zcl_result=>fail( error_message ).

    DATA(final_result) = result_one->combine_with_multiple( results ).

    cl_abap_unit_assert=>assert_equals( msg = 'OK, but it should be not OK' exp = abap_true act = final_result->is_failure( ) ).
  ENDMETHOD.

  METHOD fail_if_true.
    DATA(result) = zcl_result=>fail_if( this_returns_true( ) ).

    cl_abap_unit_assert=>assert_equals( msg = 'OK, but it should be not OK' exp = abap_true act = result->is_failure( ) ).
  ENDMETHOD.

  METHOD not_failure_if_false.
* fails only if parameter is true
    DATA(result) = zcl_result=>fail_if( this_returns_false( ) ).

    cl_abap_unit_assert=>assert_equals( msg = 'not OK, but it should be OK' exp = abap_true act = result->is_ok( ) ).
  ENDMETHOD.

  METHOD ok_if_true.
    DATA(result) = zcl_result=>ok_if( this_returns_true( ) ).

    cl_abap_unit_assert=>assert_equals( msg = 'OK, but it should be not OK' exp = abap_true act = result->is_ok( ) ).
  ENDMETHOD.

  METHOD not_ok_if_false.
* ok only if parameter is true
    DATA(result) = zcl_result=>ok_if( this_returns_false( ) ).

    cl_abap_unit_assert=>assert_equals( msg = 'OK, but it should be not OK' exp = abap_false act = result->is_ok( ) ).
  ENDMETHOD.

  METHOD combine_multiple_two_failed.
    DATA results TYPE zcl_result=>ty_results.

* arrange
    DATA(result_one) = zcl_result=>ok( ).
    DATA(result_two) = zcl_result=>fail( error_message ).
    DATA(result_three) = zcl_result=>fail( error_message ).

    results = VALUE #( ( result_two ) ( result_three ) ).

* act
    DATA(final_result) = result_one->combine_with_multiple( results ).

* assert
    cl_abap_unit_assert=>assert_equals( msg = 'OK, but it should be not OK' exp = abap_true act = final_result->is_failure( ) ).
  ENDMETHOD.

  METHOD fail_if_saves_error_message.
    DATA(result) = zcl_result=>fail_if( this_is_true = this_returns_true( ) error_message = error_message ).

    cl_abap_unit_assert=>assert_equals( msg = 'didnt store error_message' exp = error_message act = result->error_message ).
  ENDMETHOD.

  METHOD fail_if_returns_error_message.
    DATA(result) = zcl_result=>fail_if( this_is_true = this_returns_true( ) error_message = error_message ).

    cl_abap_unit_assert=>assert_equals( msg = 'unable to get error_message' exp = error_message act = result->get_error_message( ) ).
  ENDMETHOD.

  METHOD fail_if_is_ok_throws_value.
    TRY.
        DATA(result) = zcl_result=>fail_if( this_is_true = this_returns_false( ) error_message = error_message ).
        result->get_error_message( ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_result_is_no_failure INTO DATA(result_is_no_failure).
        cl_abap_unit_assert=>assert_bound( result_is_no_failure ).
    ENDTRY.
  ENDMETHOD.

  METHOD ok_if_saves_error_message.
    DATA(result) = zcl_result=>ok_if( this_is_true = this_returns_false( ) error_message = error_message ).

    cl_abap_unit_assert=>assert_equals( msg = 'didnt store error_message' exp = error_message act = result->get_error_message( ) ).
  ENDMETHOD.

  METHOD ok_if_is_failure_throws_error.
    TRY.
        DATA(result) = zcl_result=>ok_if( this_is_true = this_returns_true( ) error_message = error_message ).
        result->get_error_message( ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_result_is_no_failure INTO DATA(result_is_no_failure).
        cl_abap_unit_assert=>assert_bound( result_is_no_failure ).
    ENDTRY.
  ENDMETHOD.

  METHOD ok_if_returns_initial_value.
    DATA value TYPE char1.

    DATA(result) = zcl_result=>ok_if( this_is_true = this_returns_true( ) ).
    DATA(temporary_value) = result->get_value( ).
    value = temporary_value->*.

    cl_abap_unit_assert=>assert_initial( value ).
  ENDMETHOD.

  METHOD ok_result_with_table_as_value.
* arrange
    DATA value TYPE TABLE OF char10.
    DATA a_random_table TYPE TABLE OF char10.

    a_random_table = VALUE #( ( 'one' ) ( 'two' ) ( 'three' ) ).

* Act
    DATA(result) = zcl_result=>ok( a_random_table ).
    DATA(temporary_value) = result->get_value( ).
    value = temporary_value->*.

* assert
    DATA(number_of_entries) = lines( value ).
    cl_abap_unit_assert=>assert_equals( msg = 'Couldnt access value' exp = 3 act = number_of_entries ).
  ENDMETHOD.

  METHOD metadata_string_can_be_stored.
    DATA(result) = zcl_result=>ok( )->with_metadata( key = 'name' value = 'David Hasselhoff' ).

    DATA(number_of_entries) = lines( result->metadata ).
    cl_abap_unit_assert=>assert_equals( msg = 'Metdata not stored' exp = 1 act = number_of_entries ).
  ENDMETHOD.

  METHOD all_metadata_can_be_read.
    DATA(result) = zcl_result=>ok( )->with_metadata( key = 'name' value = 'David Hasselhoff' ).
    DATA(metadata) = result->get_all_metadata( ).

    DATA(number_of_entries) = lines( metadata ).
    cl_abap_unit_assert=>assert_equals( msg = 'Metdata not stored' exp = 1 act = number_of_entries ).
  ENDMETHOD.

  METHOD this_returns_true.
    result = abap_true.
  ENDMETHOD.

  METHOD this_returns_false.
    result = abap_false.
  ENDMETHOD.
ENDCLASS.
