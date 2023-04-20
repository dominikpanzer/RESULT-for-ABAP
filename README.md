# RESULT for ABAP

Hi! "RESULT for ABAP" is - surprise, surprise - an ABAP implementation of the Result-Pattern. It's a way to solve a common problem: a method-call can be successful or it can fail and the caller needs to know.  Result indicates if the operation was successful or failed without the usage of exceptions. It is a quite common pattern in functional languages.

## Why use RESULT for ABAP instead of Exceptions
* Exceptions are actually only for... well, exceptional cases, like DB errors, locks etc. not for "domain errors" like validations etc.
* Exception are often being used as a fancy form of the GOTO-statement. You often don't know where they will be catched. If they get catched at all.
* Exceptions lead to hard to read code for example when many different exceptions have to be catched.
* Exceptions sometimes are not really helpful, because people tend to wrap all code intro a TRY...CATCH-block for CX_ROOT.
* Exceptions tend to return only one error, but what if you have multiple errors?
* Often command-methods just return a value like "OK" which is true or false. But no additional error values.
* Often query-methods just return the result of a query and when the result is empty, then this represents an error. But what was the reason for the error?
* Other methods export two values: the actual value and an optional error message. But now you can only use EXPORTING and not RETURNING, because there are two parameters. This leads to hard to read code. Ideally a method should only return one value.
* You could use a structure (value, error_message) to solve that problem. RESULT for ABAP is a comfortable object oriented way of doing this - a standardized solution. 🦖


## Okay, show me an example
### Creating successful results
```
* create a result which represents a success
DATA(result) = zcl_result=>ok( ).
* another one with additional information, i.e. the key of an object you created or the object itself
DATA(result) = zcl_result=>ok( 100040340 ).
```
### Creating failures
```
* create a result which indicates a failure
DATA(result) = zcl_result=>fail( ).
* with an error message
DATA(result) = zcl_result=>fail('a wild errror occurred').
```
### Usage of a result in a method
Use the RESULT as a RETURNING parameter:
```
METHOD do_something IMPORTING partner TYPE bu_partner
                    RETURNING VALUE(result) TYPE REF TO zcl_result.
                    
...

METHOD do_something.
* 100s of lines of arcane logic

* hooray, no problems at all
result = zcl_result=>ok( 100040340 ).
ENDMETHOD.
```
### Process a RESULT
Use the RESULT-object for flow control as you like:
```
* call a method which returns a result
DATA new_partner TYPE bu_partner.
DATA(result) = do_something( partner ).

* guarding
IF result.is_failure( ).
DATA(error_message) = result.get_error_message( ).
* log / error for webservice
EXIT.
ENDIF.

new_partner = result.get_value( )->*.
* do something with partner, i.e. persistence
```

## Test List
I like to create a simple [acceptance test list](https://agiledojo.de/2018-12-16-tdd-testlist/) before I start coding. It my todo-list. Often it is domain-centric, this one is quite technical.

|Test|
|----|
:white_check_mark: first release somehow seems to works
:white_check_mark: when `FAIL_IF` gets called with an optional error message "a wild error occured", the error message gets stored when the RESULT is a failure
:white_check_mark: when `FAIL_IF` has been called with an optional error message "a wild error occurred", `GET_ERROR_MESSAGE` will return "a wild error occurred" when the RESULT is a failure
:white_check_mark: when `FAIL_IF` has been called with an optional error message "a wild error occurred", `GET_ERROR_MESSAGE` will return an exception, when the RESULT is OK
:white_check_mark: when `OK_IF` gets called with an optional error message "a wild error occured", the error message gets stored when the RESULT is a failure
:white_check_mark: when `OK_IF` has been called with an optional error message "a wild error occurred", `GET_ERROR_MESSAGE` will return "a wild error occurred" when the RESULT is a failure
:white_check_mark: when `OK_IF` has been called with an optional error message "a wild error occurred", `GET_ERROR_MESSAGE` will return an exception, when the RESULT is OK
:white_check_mark: when `OK_IF` has been called with an optional error message "a wild error occurred", `GET_VALUE` a initial value when the RESULT is OK
:black_square_button: when the method `WITH_METADATA( key = "name" value = "David Hasselhoff" )` gets called once, the Metadata gets stored
:black_square_button: when the method `GET_ALL_METADATA( )` gets called after `WITH_METADATA( key = "name" value = "David Hasselhoff" )`, it returns a table with one entry `(name, David Hasselhoff)`
:black_square_button: when the method `GET_METADATA( name )` gets called after `WITH_METADATA( key = "name" value = "David Hasselhoff" )`, it returns a single entry (name, David Hasselhoff)
:black_square_button: when the method `GET_ALL_METADATA( )` gets called without `WITH_METDATA` being called before, it returns an initial table
:black_square_button: when the method `GET_METADATA( date )` gets called after `WITH_METADATA( key = "name" value = "David Hasselhoff" )`, it returns an initial value
:black_square_button: when the method `WITH_METADATA( key = "name" value = "David Hasselhoff" )` is called with the same key twice, no duplicates get stored and it throws
:black_square_button: when the method `WITH_METADATA` is called with an initial key value the methods throws
:black_square_button: when the method `WITH_METADATA` is called twice with different keys `( key = "name" value = "David Hasselhoff" ) ( key = "name2" value = "David Hasselhoff" )`, both values get stored
:black_square_button: when the method `WITH_METADATA( key = "name" value = value )` and value is not convertible into a string (struc, table, object) it throws
:black_square_button: when `COMBINE_WITH_ONE` gets called with two failues, both error messages get stored
:black_square_button: when `COMBINE_WITH_MULTIPLE` gets called with tow failures, both error messages get stored
:black_square_button: when `GET_ERROR_MESSAGES` gets called for an FAILURE with two error messages, it returns  two error messages
:black_square_button: `GET_ERROR_MESSAGE` is obsolete when `GET_ERROR_MESSAGES` works fine
:black_square_button: when `WITH_ERROR_MESSAGE( 'pi equals 3' )` gets called on a FAILURE, the message will be added to the list of error messages and can bei retrieved with `GET_ERROR_MESSAGES`
:black_square_button: when `WITH_ERROR_MESSAGE( 'pi equals 3' )` gets called on a OK result it throws

## How to install RESULT for ABAP
You can copy and paste the sourcecode into your system or simply clone this repository with [ABAPGit](https://abapgit.org/). 

## How to support

PRs are welcome!

Greetings, 
Dominik

follow me on [Twittter](https://twitter.com/PanzerDominik) or [Mastodon](https://sw-development-is.social/web/@PanzerDominik)


