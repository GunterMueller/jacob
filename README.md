# JACOB

(Just A Compiler for OBeron-2)
Version 0.2
5/31/98
        
## Introduction

This is the second public release of our Oberon-2 compiler Jacob. Jacob (as
the name says ;-) is a stand-alone Oberon-2 compiler under Linux. It compiles a
single Oberon-2 module together with its imported modules and links all the
stuff together to an executable program whose name is the module name.

As the practical result of our diploma thesis, Jacob owes its existance from
the use of compiler generating tools: The front-end was generated with the
Compiler Construction Tool Box "Cocktail" (Version 9209) of Dr. J. Grosch. In
particular the tools Rex, Lalr, Puma, Ast and Ag were used. For the back-end we
used Beg (Version 1.75) of H. Emmelmann to produce GNU assembler code.

There is still a lot of debug code in Jacob so the execution speed is not
optimal. The various command-line options allows tracing of the compile phase
and looking at intermediate results which are often hidden within a compiler.

## Features

* Jacob implements the full Oberon-2 language as reported in "The
  Programming Language Oberon-2" (March 1995).
* External modules allow to write library modules in other Languages.
* Instead of an explicit dispose function a garbage collector is implemented
  using a mark-and-sweep algorithm.
* Command-line options for enabling and disabling NIL, index, range 
  and assertion checks.

## Implementation extensions/restrictions

* The underscore character is legal in identifiers.
* The maximum length of identifiers is 255.
* Procedures can be nested up to a maximum of 30.
* A type extension hierarchy can have a maximum depth of 8.
* The difference between the smallest and the largest case label may not be
  greater than 4096.
* SYSTEM.NEW is only valid for pointers which base type doesn't contain any
  pointer.

##Disclaimer

This software package is FREE, so you can do with it whatever is in your mind, 
BUT: whatever you do with this package, YOU are responsible and you do it ON
YOUR OWN RISK. This simply means we disclaim warranties of any kind.

Because of the early version of Jacob it is definitely possible that there are
bugs in the implementation. If you find one (or several) don't despair. Please
let us know about it (see section Bug Report below).

## Requirements

Jacob only requires the GNU assembler as. We use version 2.7
(i586-unknown-linux).

## Installation

Un-tar the package wherever you want (/usr is recommended).
This will result in the subdirectory tree:

> jacob
> jacob/lib
> jacob/sys
> jacob/test
   
If you decide to use a home directory other than /usr
you have to edit the script files oc and sys/oc.linker and
to adjust the directory specifications in these scripts.

Copy, move or link the script oc into a directory which is included
by your PATH environment variable.

To test your installation change the current work directory to 
jacob/test, compile the Test module by "oc Test". This will also
generate the object files of the library modules, if you have
write permissions to jacob/lib.

## Invocation

By typing jacob -h you get the usual description of the usage with a short
explanation of the available command-line options. 

Assembler and object files are written into the directory which
contains the source file.

## Library Modules

We have (up to now) implemented a (very) quick'n'dirty set of library modules. 
These are:

* Out      : output of some basic types
* Storage  : heap and garbage collector functions
* SysLib   : interface to the linux os
* RawFiles : basic file i/o
* Lib      : command-line arguments, random numbers and others
* Str      : string Handling

A more detailed description can be found at the end of this file.

## Bug Report

If you find an error in the implementation or you have comments regarding
Jacob, PLEASE send it to us. Help us to improve Jacob by sending e-mail to the
following address:
    
     sepp@cs.tu-berlin.de

It is useful to send a small example program which shows the bug.

## Future Work

As future work we plan:

* A hand-written front-end which is implemented using Jacob itself
* More sufficient library modules
* The use of symbol files to speed up the import stage
* An improved memory management especially a faster mark algorithm

## Changes from Version 0.1.1 to 0.2

* Scanner recognizes an identifier with a length greater 255 and
  emits an appropriate error message instead of dumping its core.
* Fixed this bug in the code generator which caused the message
  "Str.s:1104: Error: register does not match opcode suffix"
  when compiling lib/Str.ob2.
* source code is also available. 

## Changes from Version 0.1 to 0.1.1

## Changes from Version 0 to 0.1

* Jacob runs now as ELF executable and produces ELF output.
  * External modules (former "foreign" modules):
  * Changed syntax (with respect to the Oakwood Guidelines):
 
    <pre>
        Module      = MODULE ident ';' 
                      [ImportList] 
                      DeclSeq 
                      [BEGIN StatementSeq] END ident 
                    | XModule .
        ...
        XModule     = MODULE ident EXTERNAL '[' string ']' ';' 
                      [ImportList] 
                      XDeclSeq 
                      END ident '.' .
        XDeclSeq    = { CONST     {ConstDecl ';'} 
                      | TYPE      {TypeDecl  ';'} 
                      | VAR       {VarDecl   ';'}
                      | PROCEDURE IdentDef [XFormalPars] ';' 
                      } .
        XFormalPars = '(' [XFPSections] ')' [':' Qualident] .
        XFPSections = FPSection {';' FPSection} [';' '..'] .
     </pre>
 
     External modules are identified by the keyword EXTERNAL following the
     module's name. The following bracket-enclosed string will be passed
     unchanged to the linker.
     
     Constants, types, variables and procedures may be declared in any order.
     This allows grouping of types and functions which belong together,
     e.g. for writing interfaces for large libraries. Type-bound procedures
     aren't allowed.
     
     A procedure declaration consists only of the procedure header. The last
     formal parameter of a non-empty formal parameter list may be '..', in
     which case any non-empty actual parameter list starting at the 
     corresponding position is legal. 
   
  * Changed parameter passing mechanisms for external procedures:
    * No hidden parameters (type tags, array lengths) will be passed.
    * The following "objects" will be passed according the kind/type of
      the formal/actual parameter ('..' is treated like an open-array
      value parameter):
<pre>
formal parameter     | actual parameter         | passed object
===================================================================
variable parameter   | any                      | address of actual 
                     |                          | parameter
-------------------------------------------------------------------
non-open-array value | any                      | value of actual
parameter            |                          | parameter
-------------------------------------------------------------------
open-array value     | character constant;      | address of actual
parameter            | string constant; array   | parameter
-------------------------------------------------------------------
open-array value     | SYSTEM.BYTE; SYSTEM.PTR; | value of actual
parameter            | BOOLEAN; CHAR variable;  | parameter
                     | SET; integer type; real  |
                     | type; NIL; pointer,      |
                     | procedure or record type |
-------------------------------------------------------------------
..                   | character constant;      | address of actual
                     | string constant; array   | parameter
-------------------------------------------------------------------
..                   | SYSTEM.BYTE; SYSTEM.PTR; | value of actual
                     | BOOLEAN; CHAR variable;  | parameter
                     | SET; integer type; real  |
                     | type; NIL; pointer,      |
                     | procedure or record type |
---------------------+--------------------------+------------------
</pre>
 
  * External variables declarable and accessible.
  * There are no type descriptors for records.
  * If external procedures are assigned to procedure variables, the
    programmer should exactly know what (s)he's doing...
* Code improvements:
  * Displays in stack frames are more compact.
  * Jump optimization (not only) for boolean short-circuit.
* Improved memory handling at compile-time.
* New command line options.
* Various bug fixes:
  * Comparison of two function results with a real type.
  * Recompilation if a indirectly imported module is younger than
    the client module.
  * A SYSTEM.VAL at a variable parameter position gets now coded correctly.
  * ...
* Library modules:
  * argc, argv, env and errno now directly accessible through module SysLib.
