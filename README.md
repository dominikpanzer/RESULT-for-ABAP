# RESULT for ABAP

Hi! "RESULT for ABAP" is - surprise, surprise - an ABAP implementation of the Result-Pattern. It's a way to solve a common problem: a method-call can be successful or it can fail and the caller needs to know.  Result indicates if the operation was successful or failed without the usage of exceptions. It is a quite common pattern in functional languages.

## Why use RESULT for ABAP instead of Exceptions
* Exceptions are actually only for... well, exceptional cases, like DB errors, locks etc. not for "domain errors" like validations et.
* Exception are often being used as a fancy form of the GOTO-statement. You often don't know where they will be catched. If they get catched at all.
* Exceptions lead to hard to read code for example when many different exceptions have to be catched.
* Exceptions sometimes are not really helpful, because people tend to wrap all code intro a TRY...CATCH-block for CX_ROOT.

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
result = zcl_result=>ok( ).
ENDMETHOD.
```
### Process a RESULT
Use the RESULT-object for flow control as you like:
```
* call a method which returns a result
DATA(result) = do_something( partner ).

IF result.

endif.

```

## How to install RESULT for ABAP
You can copy and paste the sourcecode into your system or simply clone this repository with [ABAPGit](https://abapgit.org/). 


Enjoy! PRs are welcome.

Greetings, 
Dominik

follow me on [Twittter](https://twitter.com/PanzerDominik) or [Mastodon](https://sw-development-is.social/web/@PanzerDominik)


