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
    METHODS combine_ok_and_failure FOR TESTING.
    METHODS combine_two_failures FOR TESTING.
    METHODS cant_access_error_when_ok FOR TESTING.
    METHODS combine_multiple_all_failed FOR TESTING.
    METHODS combine_multiple_one_failed FOR TESTING.
    METHODS cant_access_value_when_failure FOR TESTING.
    METHODS combine_multiple_no_entries FOR TESTING.
    METHODS fail_if_true FOR TESTING.
    METHODS not_failure_if_false FOR TESTING.
    METHODS ok_if_true FOR TESTING.
    METHODS not_ok_if_false FOR TESTING.
    METHODS ok_result_with_object_as_value FOR TESTING.
    METHODS ok_result_with_table_as_value FOR TESTING.
    METHODS combine_multiple_two_failed FOR TESTING.

    METHODS fail_if_returns_error_message FOR TESTING.
    METHODS fail_if_is_ok_throws_value FOR TESTING.
    METHODS ok_if_saves_error_message FOR TESTING.
    METHODS ok_if_is_failure_throws_error FOR TESTING.
    METHODS ok_if_returns_initial_value FOR TESTING.

    METHODS all_metadata_can_be_read FOR TESTING.
    METHODS one_metadata_entry_can_be_read FOR TESTING.
    METHODS initial_metadata_table FOR TESTING.
    METHODS metadata_key_not_found FOR TESTING.
    METHODS no_duplicate_metadata_allowed FOR TESTING.
    METHODS metadata_with_empty_key FOR TESTING.
    METHODS more_than_one_metadata_entry FOR TESTING.
    METHODS metadata_can_handle_structures FOR TESTING.
    METHODS failures_two_errormsgs_stored FOR TESTING.
    METHODS combine_8_ok_and_failues FOR TESTING.
    METHODS retrieve_2_error_messages FOR TESTING.
    METHODS has_multiple_works_for_2 FOR TESTING.
    METHODS has_multiple_works_for_1 FOR TESTING.
    METHODS has_multiple_works_for_0 FOR TESTING.
    METHODS has_multiple_throws_for_ok FOR TESTING.
    METHODS get_error_msg_throws_for_ok FOR TESTING.
    METHODS with_error_message_initial FOR TESTING.
    METHODS with_error_message_on_failure FOR TESTING.
    METHODS with_error_message_on_ok FOR TESTING.
    METHODS get_error_msgs_throws_for_ok FOR TESTING.

    METHODS this_returns_true RETURNING VALUE(result) TYPE abap_bool.
    METHODS this_returns_false RETURNING VALUE(result) TYPE abap_bool.

ENDCLASS.


CLASS result_tests IMPLEMENTATION.

  METHOD create_ok_result.
    DATA(result) = zcl_result=>ok( ).

    DATA(is_result_ok) = result->is_ok( ).

    cl_abap_unit_assert=>assert_equals( msg = 'Not OK, but it should be ok' exp = abap_true act = is_result_ok ).
  ENDMETHOD.

  METHOD create_ok_result_check_failed.
    DATA(result) = zcl_result=>ok( ).

    DATA(is_result_ok) = result->is_failure( ).

    cl_abap_unit_assert=>assert_equals( msg = 'Failed, but it should be ok' exp = abap_false act = is_result_ok ).
  ENDMETHOD.

  METHOD create_failed_result.
    DATA(result) = zcl_result=>fail( ).

    DATA(is_result_a_failure) = result->is_failure( ).

    cl_abap_unit_assert=>assert_equals( msg = 'Not failed, but it should be failed' exp = abap_true act = is_result_a_failure ).
  ENDMETHOD.

  METHOD create_failed_result_check_ok.
    DATA(result) = zcl_result=>fail( ).

    DATA(is_result_ok) = result->is_ok( ).

    cl_abap_unit_assert=>assert_equals( msg = 'ok, but it should be failed' exp = abap_false act = is_result_ok ).
  ENDMETHOD.

  METHOD ok_result_with_value.
* can save a value of a simple data type like char
    DATA id_of_created_object TYPE char10 VALUE '0815'.

    DATA(result) = zcl_result=>ok( id_of_created_object ).
    DATA(temporary_value) = result->get_value( ).
    DATA(value) = CAST char10( temporary_value ).

    cl_abap_unit_assert=>assert_equals( msg = 'Couldnt access value' exp = id_of_created_object act = value->* ).
  ENDMETHOD.

  METHOD ok_result_with_object_as_value.
* can save a value with a complex data type like object reference
    DATA random_object_reference TYPE REF TO zcl_result.
    DATA temporary_value TYPE REF TO data.
    FIELD-SYMBOLS <value> TYPE REF TO zcl_result.

    random_object_reference = zcl_result=>ok( ).
    DATA(result) = zcl_result=>ok( random_object_reference ).

    temporary_value = result->get_value( ).

    ASSIGN temporary_value->* TO <value>.
    cl_abap_unit_assert=>assert_equals( msg = 'Couldnt access value' exp = random_object_reference act = <value> ).
  ENDMETHOD.

  METHOD failed_result_with_error.
    DATA(result) = zcl_result=>fail( error_message ).

    cl_abap_unit_assert=>assert_equals( msg = 'error message not correct' exp = error_message act = result->get_error_message( ) ).
  ENDMETHOD.

  METHOD combine_with_one_all_are_ok.
* combining two RESULTs which are OK leads to a OK-RESULT
    DATA(result_one) = zcl_result=>ok( ).
    DATA(result_two) = zcl_result=>ok( ).

    DATA(final_result) = result_one->combine_with( result_two ).

    cl_abap_unit_assert=>assert_equals( msg = 'Not OK, but it should be ok' exp = abap_true act = final_result->is_ok( ) ).
  ENDMETHOD.

  METHOD combine_multiple_all_are_ok.
    DATA results TYPE zcl_result=>results_type.

    DATA(result_one) = zcl_result=>ok( ).
    DATA(result_two) = zcl_result=>ok( ).
    DATA(result_three) = zcl_result=>ok( ).
    DATA(result_four) = zcl_result=>ok( ).
    results = VALUE #( ( result_two ) ( result_three ) ( result_four ) ).

    DATA(final_result) = result_one->combine_with_these( results ).

    cl_abap_unit_assert=>assert_equals( msg = 'Not OK, but it should be ok' exp = abap_true act = final_result->is_ok( ) ).
  ENDMETHOD.

  METHOD combine_ok_and_failure.
* if two RESULTS get combined and one is a FAILURE, the final result should
* also be a FAILURE
    DATA(result_one) = zcl_result=>ok( ).
    DATA(result_two) = zcl_result=>fail( error_message ).

    DATA(final_result) = result_one->combine_with( result_two ).

    cl_abap_unit_assert=>assert_equals( msg = 'OK but it should be not OK' exp = abap_false act = final_result->is_ok( ) ).
    cl_abap_unit_assert=>assert_equals( msg = 'Errormessage not correct' exp = error_message act = final_result->get_error_message( ) ).
  ENDMETHOD.

  METHOD combine_two_failures.
    DATA(result_one) = zcl_result=>fail( error_message ).
    DATA(result_two) = zcl_result=>fail( error_message ).

    DATA(final_result) = result_one->combine_with( result_two ).

    cl_abap_unit_assert=>assert_equals( msg = 'OK but it should be not OK' exp = abap_false act = final_result->is_ok( ) ).
    cl_abap_unit_assert=>assert_equals( msg = 'Errormessage not correct' exp = error_message act = final_result->get_error_message( ) ).
  ENDMETHOD.

  METHOD cant_access_error_when_ok.
    TRY.
        DATA(result) = zcl_result=>ok( ).
        result->get_error_message( ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_result_is_not_failure INTO DATA(result_is_no_failure).
        cl_abap_unit_assert=>assert_bound( result_is_no_failure ).
    ENDTRY.
  ENDMETHOD.

  METHOD cant_access_value_when_failure.
* FAILUREs don't have any value. needs to be checked with .is_ok( )
* or it throws
    TRY.
        DATA(result) = zcl_result=>fail( error_message ).
        result->get_value( ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_result_is_not_ok INTO DATA(result_is_not_ok).
        cl_abap_unit_assert=>assert_bound( result_is_not_ok ).
    ENDTRY.
  ENDMETHOD.

  METHOD combine_multiple_all_failed.
    DATA results TYPE zcl_result=>results_type.

* arrange
    DATA(result_one) = zcl_result=>fail( error_message ).
    DATA(result_two) = zcl_result=>fail( 'no' ).
    DATA(result_three) = zcl_result=>fail( 'argh' ).
    results = VALUE #( ( result_two ) ( result_three ) ).

* act
    DATA(final_result) = result_one->combine_with_these( results ).

* assert
    cl_abap_unit_assert=>assert_equals( msg = 'OK, but it should be not OK' exp = abap_true act = final_result->is_failure( ) ).
  ENDMETHOD.

  METHOD combine_multiple_one_failed.
    DATA results TYPE zcl_result=>results_type.

* arrange
    DATA(result_one) = zcl_result=>ok( ).
    DATA(result_two) = zcl_result=>fail( error_message ).
    DATA(result_three) = zcl_result=>ok( ).
    results = VALUE #( ( result_two ) ( result_three ) ).

* act
    DATA(final_result) = result_one->combine_with_these( results ).

* assert
    cl_abap_unit_assert=>assert_equals( msg = 'OK, but it should be not OK' exp = abap_true act = final_result->is_failure( ) ).
  ENDMETHOD.

  METHOD combine_multiple_no_entries.
* the results-table is empty, shouldnt change from OK to Failure.
    DATA empty_table TYPE zcl_result=>results_type.

    DATA(result_one) = zcl_result=>ok( ).

    DATA(final_result) = result_one->combine_with_these( empty_table ).

    cl_abap_unit_assert=>assert_equals( msg = 'FAILURE, but should be ok' exp = abap_false act = final_result->is_failure( ) ).
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
    DATA results TYPE zcl_result=>results_type.

* arrange
    DATA(result_one) = zcl_result=>ok( ).
    DATA(result_two) = zcl_result=>fail( error_message ).
    DATA(result_three) = zcl_result=>fail( error_message ).

    results = VALUE #( ( result_two ) ( result_three ) ).

* act
    DATA(final_result) = result_one->combine_with_these( results ).

* assert
    cl_abap_unit_assert=>assert_equals( msg = 'OK, but it should be not OK' exp = abap_true act = final_result->is_failure( ) ).
  ENDMETHOD.

  METHOD fail_if_returns_error_message.
    DATA(result) = zcl_result=>fail_if( this_is_true = this_returns_true( ) error_message = error_message ).

    cl_abap_unit_assert=>assert_equals( msg = 'unable to get error_message' exp = error_message act = result->get_error_message( ) ).
  ENDMETHOD.

  METHOD fail_if_is_ok_throws_value.
* OK RESULTs throw when an error message is requested
    TRY.
        DATA(result) = zcl_result=>fail_if( this_is_true = this_returns_false( ) error_message = error_message ).
        result->get_error_message( ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_result_is_not_failure INTO DATA(result_is_no_failure).
        cl_abap_unit_assert=>assert_bound( result_is_no_failure ).
    ENDTRY.
  ENDMETHOD.

  METHOD ok_if_saves_error_message.
    DATA(result) = zcl_result=>ok_if( this_is_true = this_returns_false( ) error_message = error_message ).

    cl_abap_unit_assert=>assert_equals( msg = 'didnt store error_message' exp = error_message act = result->get_error_message( ) ).
  ENDMETHOD.

  METHOD ok_if_is_failure_throws_error.
* OK RESULTs throw when an error message is requested
    TRY.
        DATA(result) = zcl_result=>ok_if( this_is_true = this_returns_true( ) error_message = error_message ).
        result->get_error_message( ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_result_is_not_failure INTO DATA(result_is_no_failure).
        cl_abap_unit_assert=>assert_bound( result_is_no_failure ).
    ENDTRY.
  ENDMETHOD.

  METHOD ok_if_returns_initial_value.
* OK_IF doesnt support any VALUE, so returns an empty one
    DATA temporary_value TYPE REF TO data.
    FIELD-SYMBOLS <value> TYPE any.
    DATA(result) = zcl_result=>ok_if( this_is_true = this_returns_true( ) ).

    temporary_value = result->get_value( ).

    ASSIGN temporary_value->* TO <value>.
    cl_abap_unit_assert=>assert_initial( <value> ).
  ENDMETHOD.

  METHOD ok_result_with_table_as_value.
* arrange
    DATA random_string TYPE string VALUE '12345'.

    DATA(a_random_table) = VALUE string_table( ( random_string ) ( random_string ) ( random_string ) ).

* Act
    DATA(result) = zcl_result=>ok( a_random_table ).

* assert
    DATA(temporary_value) = result->get_value( ).
    DATA(value) = CAST string_table( temporary_value ).
    DATA(number_of_entries) = lines( value->* ).
    cl_abap_unit_assert=>assert_equals( msg = 'Couldnt access value' exp = 3 act = number_of_entries ).
  ENDMETHOD.

  METHOD all_metadata_can_be_read.
    DATA(result) = zcl_result=>ok( )->with_metadata( key = 'name' value = 'David Hasselhoff' ).
    DATA(metadata) = result->get_all_metadata( ).

    DATA(number_of_entries) = lines( metadata ).
    cl_abap_unit_assert=>assert_equals( msg = 'Metdata could not be received' exp = 1 act = number_of_entries ).
  ENDMETHOD.

  METHOD one_metadata_entry_can_be_read.
    DATA(result) = zcl_result=>ok( )->with_metadata( key = 'name' value = |David Hasselhoff| ).

    DATA(temporary_value) = result->get_metadata( key = 'name' ).

    DATA(value) = CAST string( temporary_value ).
    cl_abap_unit_assert=>assert_equals( msg = 'Metdata entry could not be received' exp = |David Hasselhoff| act = value->* ).
  ENDMETHOD.

  METHOD initial_metadata_table.
    DATA(result) = zcl_result=>ok( ).
    DATA(metadata) = result->get_all_metadata( ).

    DATA(number_of_entries) = lines( metadata ).
    cl_abap_unit_assert=>assert_equals( msg = 'Metdata should be empty' exp = 0 act = number_of_entries ).
  ENDMETHOD.

  METHOD metadata_key_not_found.
* if there is no metadata which has the provided key, the returned value is
* empty
    DATA(result) = zcl_result=>ok( )->with_metadata( key = 'name' value = 'David Hasselhoff' ).
    DATA(value) = result->get_metadata( key = 'date' ).

    cl_abap_unit_assert=>assert_initial( value ).
  ENDMETHOD.

  METHOD no_duplicate_metadata_allowed.
* a metadata key is only allowed once. it has to be unique.
* it just stores it once
    DATA(result) = zcl_result=>ok( )->with_metadata( key = 'name' value = 'David Hasselhoff' ).
    result->with_metadata( key = 'name' value = 'David Hasselhoff' ).
    DATA(metadata) = result->get_all_metadata( ).

    DATA(number_of_entries) = lines( metadata ).
    cl_abap_unit_assert=>assert_equals( msg = 'Metdata has too many lines' exp = 1 act = number_of_entries ).
  ENDMETHOD.

  METHOD metadata_with_empty_key.
* an empty key is a valid key
    DATA(result) = zcl_result=>ok( )->with_metadata( key = '' value = |David Hasselhoff| ).

    DATA(temporary_value) = result->get_metadata( key = '' ).
    DATA(value) = CAST string( temporary_value ).

    cl_abap_unit_assert=>assert_equals( msg = 'Metdata entry could not be received' exp = |David Hasselhoff| act = value->* ).
  ENDMETHOD.

  METHOD more_than_one_metadata_entry.
    DATA(result) = zcl_result=>ok( )->with_metadata( key = 'name' value = 'David Hasselhoff' ).
    result->with_metadata( key = 'best song' value = 'Looking for freedom' ).

    DATA(metadata) = result->get_all_metadata( ).

    DATA(number_of_entries) = lines( metadata ).
    cl_abap_unit_assert=>assert_equals( msg = 'Should have 2 entries' exp = 2 act = number_of_entries ).
  ENDMETHOD.

  METHOD metadata_can_handle_structures.
    DATA(structure) = VALUE zcl_result=>metadata_entry_type( key = 'a' value = REF #( 'random structure' ) ).
    DATA(result) = zcl_result=>ok( )->with_metadata( key = 'a structure' value = structure ).

    DATA(temporary_value) = result->get_metadata( 'a structure' ).
    DATA(value) = CAST zcl_result=>metadata_entry_type( temporary_value ).

    cl_abap_unit_assert=>assert_equals( msg = 'Metadata not stored' exp = structure act = value->* ).
  ENDMETHOD.

  METHOD failures_two_errormsgs_stored.
* arrange
    DATA(result_one) = zcl_result=>fail( error_message ).
    DATA(result_two) = zcl_result=>fail( error_message ).

* act
    DATA(final_result) = result_one->combine_with( result_two ).

* assert
    DATA(number_of_messages) = lines( final_result->error_messages ).
    cl_abap_unit_assert=>assert_equals( msg = 'Doesnt have 2 error messages' exp = 2  act = number_of_messages ).
  ENDMETHOD.

  METHOD combine_8_ok_and_failues.
    DATA results TYPE zcl_result=>results_type.

* arrange
    DATA(result_one) = zcl_result=>ok( ).
    DATA(result_two) = zcl_result=>fail( error_message ).
    DATA(result_three) = zcl_result=>fail( error_message ).
    DATA(result_four) = zcl_result=>ok( ).
    DATA(result_five) = zcl_result=>ok( ).
    DATA(result_six) = zcl_result=>fail( error_message ).
    DATA(result_seven) = zcl_result=>ok( ).
    DATA(result_eight) = zcl_result=>fail( error_message ).

    results = VALUE #( ( result_two ) ( result_three ) ( result_four ) ( result_five )
                       ( result_six ) ( result_seven ) ( result_eight ) ).

* act
    DATA(final_result) = result_one->combine_with_these( results ).

* assert
    DATA(number_of_messages) = lines( final_result->error_messages ).
    cl_abap_unit_assert=>assert_equals( msg = 'Doesnt have 4 error messages' exp = 4  act = number_of_messages ).
    cl_abap_unit_assert=>assert_equals( msg = 'OK, but it should be not OK' exp = abap_true act = final_result->is_failure( ) ).
  ENDMETHOD.

  METHOD retrieve_2_error_messages.
* arrange
    DATA(result_one) = zcl_result=>fail( error_message ).
    DATA(result_two) = zcl_result=>fail( error_message ).
    DATA(final_result) = result_one->combine_with( result_two ).

* act
    DATA(error_messages) = final_result->get_error_messages( ).

* assert
    DATA(number_of_messages) = lines( error_messages ).
    cl_abap_unit_assert=>assert_equals( msg = 'Doesnt have 2 error messages' exp = 2  act = number_of_messages ).
  ENDMETHOD.

  METHOD has_multiple_works_for_2.
* arrange
    DATA(result_one) = zcl_result=>fail( error_message ).
    DATA(result_two) = zcl_result=>fail( error_message ).
    DATA(final_result) = result_one->combine_with( result_two ).

* act
    DATA(has_multiple_error_messages) = final_result->has_multiple_error_messages( ).

* assert
    cl_abap_unit_assert=>assert_equals( msg = 'Should return true' exp = abap_true  act = has_multiple_error_messages ).
  ENDMETHOD.

  METHOD has_multiple_works_for_1.
    DATA(result) = zcl_result=>fail( error_message ).

    DATA(has_multiple_error_messages) = result->has_multiple_error_messages( ).

    cl_abap_unit_assert=>assert_equals( msg = 'Should return true' exp = abap_true  act = has_multiple_error_messages ).
  ENDMETHOD.

  METHOD has_multiple_works_for_0.
    DATA(result) = zcl_result=>fail( ).

    DATA(has_multiple_error_messages) = result->has_multiple_error_messages( ).

    cl_abap_unit_assert=>assert_equals( msg = 'Should return false' exp = abap_false  act = has_multiple_error_messages ).
  ENDMETHOD.

  METHOD has_multiple_throws_for_ok.
    TRY.
        DATA(result) = zcl_result=>ok( ).
        result->has_multiple_error_messages( ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_result_is_not_failure INTO DATA(result_is_no_failure).
        cl_abap_unit_assert=>assert_bound( result_is_no_failure ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_error_msg_throws_for_ok.
    TRY.
        DATA(result) = zcl_result=>ok( ).
        result->get_error_message( ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_result_is_not_failure INTO DATA(result_is_no_failure).
        cl_abap_unit_assert=>assert_bound( result_is_no_failure ).
    ENDTRY.
  ENDMETHOD.

  METHOD get_error_msgs_throws_for_ok.
    TRY.
        DATA(result) = zcl_result=>ok( ).
        result->get_error_messages( ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_result_is_not_failure INTO DATA(result_is_no_failure).
        cl_abap_unit_assert=>assert_bound( result_is_no_failure ).
    ENDTRY.
  ENDMETHOD.

  METHOD with_error_message_initial.
* when parameter is empty it does nothing
    DATA(result) = zcl_result=>fail( )->with_error_message( VALUE #( ) ).

    DATA(error_message) = result->get_error_message( ).

    cl_abap_unit_assert=>assert_initial( error_message ).
  ENDMETHOD.

  METHOD with_error_message_on_failure.
    DATA(result) = zcl_result=>fail( )->with_error_message( error_message ).

    DATA(error) = result->get_error_message( ).


    cl_abap_unit_assert=>assert_equals( msg = 'Should be an error' exp = me->error_message act = error ).
  ENDMETHOD.

  METHOD with_error_message_on_ok.
    DATA(result) = zcl_result=>ok( )->with_error_message( error_message ).

    DATA(number_of_error_messages) = lines( result->error_messages ).

    cl_abap_unit_assert=>assert_equals( msg = 'Should be 0 for every OK-RESULT' exp = 0 act = number_of_error_messages ).
  ENDMETHOD.

  METHOD this_returns_true.
    result = abap_true.
  ENDMETHOD.

  METHOD this_returns_false.
    result = abap_false.
  ENDMETHOD.

ENDCLASS.
