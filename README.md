position_independent_code_vic20
===============================

Examples of 6502 _Position Independent Code_ on the VIC-20 from the article [Position Independent Code (6502) on the Commodore VIC-20](https://techtinkering.com/articles/position-independent-code-6502-on-the-commodore-vic-20/).  Please see this article for information about how they work.

The programs' 6502 assembly source code, written for the [XA](https://www.floodgap.com/retrotech/xa/) assembler is in _src/_ and the resulting _.prg_ files are in _bin/_

## pic_basic_stub

Position independent code using jump tables and data tables to obtain position independence.  This code is prefixed with a Basic stub so that it can be easily loaded and hence an absolute address for a point in the code can be determined by querying the start of tokenized Basic.


## pic_getpc

As above, but without a basic stub.  This code uses a `getpc` routine to obtain an absolute address for a point in the code.  It is assembled for address 4611, which should allow it to work for any memory configuration.  However, this address can be changed and the code will still remain position independent.  To run it use the following:

``` basic
LOAD "*",8,1
SYS 4611
```

## self_modify_basic_stub

This example self-modifies the code by shifting offsets in code by the start of tokenized Basic to modify offsets for absolute addresses.

# Licence

<p xmlns:dct="http://purl.org/dc/terms/">
  <a rel="license"
     href="http://creativecommons.org/publicdomain/zero/1.0/">
    <img src="https://licensebuttons.net/p/zero/1.0/88x31.png" style="border-style: none;" alt="CC0" />
  </a>
  <br />
  To the extent possible under law,
  <a rel="dct:publisher"
     href="https://lawrencewoodman.github.io">
    <span property="dct:title">Lawrence Woodman</span></a>
  has waived all copyright and related or neighboring rights to
  this work.
</p>
