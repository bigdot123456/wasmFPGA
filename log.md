# 2017-03-01

`-I` option of `iverilog` allow to define include folders. It allow to be
separated from the argument although manual page seems to say other thing.

`iverilog` generate "executable" script files for the `vvp` command that's the
one that effectively run the simulation, so probably there could be an option to
define some devices (like a serial port) and interactuate with it.

# 2017-03-02

Since `Makefile` instructions are executed verbatin, you can use shell comments
to print some text to `stdout`.

# 2017-03-03

Verilog `vcc` is the command with the simulation runtime. Its `-N` flag makes
the simulation to exit when invoking the `$stop` command with `1` as error code.

Icarus Verilog support `__FILE__` and `__LINE__` statements (http://stackoverflow.com/a/12953585/586382).
There's a test suite at https://github.com/steveicarus/ivtest

# 2017-03-05

FPUs implemented in Verilog:
- https://opencores.org/project,fpu
- https://github.com/dawsonjon/fpu

[Chips: design components in C, design FPGAs in Python](http://dawsonjon.github.io/Chips-2.0/home/index.html)

# 2017-03-07

`-y` option of `iverilog` allow to define library folders, to search for modules
that otherwise it would error as not found.

# 2017-03-09

`-g2005-sv` flag enable support for SystemVerilog

To make `-y` option to work, modules has to have the same name and
capitalization that the filename of the file that host them.

Icarus Verilog is forcing to define registers as input and output of modules,
so it's needed two tick to access ROM data, one to define address and another to
read it. It must to be a solution for that, maybe using combinational logic.
Seems the `logic` type autodetect if should be a `wire` or a `reg`.

# 2017-03-11

Stack operation at the end of the pipeline are processed while the opcode of the
next instruction is being fetch to earn some CPU cycles.

[WebAssembly Explorer](http://mbebenita.github.io/WasmExplorer/)
[WasmFiddle](https://wasdk.github.io/WasmFiddle/?)

# 2017-03-12

It's needed to decide what to do when fetching extra bytes from ROM beyond its
actual size. Error, zeros, or unset bits?

# 2017-03-13

To identify the end of a WebAssembly module, we'll use at its end a custom empty
section. This means that just two zero bytes will be appended, and we'll get the
same effect when reading from a previously zeroed memory. When loading from a
serial line we could use other methods to identify module EOL.

Sync `=` asignation can be used when the asigned data will be used on the same
cycle, async `<=` asignation is not warranted when it will be done during that
cycle.

# 2017-03-15

Max length of inmediate values is 10 bytes (`i64.const` and `memory_immediate`,
made of two `varuint32` fields). `br_table` has a variable length inmediate with
the fields `target_count`, `target_table` (variable 0-n) and `default_target`,
so just 5 or 10 bytes would be enought.

[Machine Learning in FPGAs](http://cadlab.cs.ucla.edu/~cong/slides/HALO15_keynote.pdf)

# 2017-03-16

[WebAssembly S-expressions](https://developer.mozilla.org/en-US/docs/WebAssembly/Understanding_the_text_format)

# 2017-03-23

[FPGAs documentation and projects](http://www.fpga4fun.com)
[Arcade machines implemented on FPGAs](http://www.fpgaarcade.com/)

# 2017-03-24

On Travis-CI, Ubuntu `precise` is used by default. To use a newer one set
`dist: trusty` on the `.travis.yml` file, and later add a `sourceline` for the
origin:

```yaml
language: verilog
dist: trusty
addons:
  apt:
    sources:
    - sourceline: 'deb http://es.archive.ubuntu.com/ubuntu/ yakkety main universe'
    packages:
    - iverilog
script: make test
```

Alternatively you can use another distro like `dist: yakkety`, but since it
doesn't has oficial support by Travis team, it will run containerized in Docker.
In that case, it's needed to add `sudo: false` too to be able to install `apt`
packages, but I was unsuccessfull doing so.

For function calling, since we need to put the arguments on the SuperStack we
have two alternatives:

1. raise the underflow limit over the arguments, having an empty stack and
   fetching the values with negative indexes (counting them from the signature)
   so they get protected of excesive dropping, and when returning do the reset
   under the arguments and set the result there
2. set the underflow limit under the arguments, having them on the stack and
   access with positive indexes (arg 0 is index 0 on stack) and returning would
   be just a reset and set the result value, but this would allow to overwrite
   the arguments by badly designed code...

# 2017-03-27

[covered](http://covered.sourceforge.net/)
[In detail info](http://www.testbench.in/TB_24_ABOUT_CODE_COVERAGE.html) about
what means to do code coverage on Verilog and Hardware Definition Languages.

> "VERIFICATION IS NOT COMPLETED EVEN AFTER 100% CODE COVERAGE"

```sh
covered score -t SuperStack_tb -v test/SuperStack_tb.v -vcd build/SuperStack_tb.vcd -I src/ -I test/
```

# 2017-03-28

https://dspace.mit.edu/bitstream/handle/1721.1/91829/894228451-MIT.pdf

For loops and conditionals, we could use a hash table being the instruction
address the key and the value being the destination address, or modify the code
and add custom explicit `jmp` or `goto` instructions.

`block`s loop forever? https://github.com/WebAssembly/design/issues/261
https://github.com/WebAssembly/design/issues/261#issuecomment-128989537

# 2017-03-29

Infinite loops and branch backwards can be implemented with current functions
mechanism, since we already know where they are generated.

Branch forwards (`if`s, `br`s) could be implemented with a pre-scanned table of
key-values, with addresses pointing to their forward labels (`else`, `end`...).
Since addresses are incremental and static, they can be check in order so no
need to look-up for them, just having a pointer to the next one that needs to be
checked against for based on the current Program Counter. Problems would arise
when PC move backwards (a `loop` or a function call, for example), so pointer
would need to be searched again. This can be done asyncronous and/or in parallel
to regular execution, but maybe would need a flag to set it's not yet ready to
stop execution in case a conditional is find again until it can be evaluated.

`if` conditionals just only need two `jmp`, one to the address after `else`, and
one from `else` to the address after `end`.

Verilog support loops, so it could be possible to do an async checker to look on
a map for the instruction address and its destination.

# 2017-03-30

Floating point operations are `eq`, `ne`, `lt`, `gt`, `le`, `ge`, `abs`, `neg`,
`ceil`, `floor`, `trunc`, `nearest`, `sqrt`, `add`, `sub`, `mul`, `div`, `min`,
`max` and `copysign`, both for 32 and 64 bits.
Floating point conversions are `float2int` and `int2float` both signed and
unsigned, and 32-to-64 and 64-to-32.

# 2017-04-02

Can be branch out of `if` blocks? And from functions?

[Destructure a wire using binding](http://electronics.stackexchange.com/a/49669)

GtkWave allow to disable initial splash setting it on a RC file with the
`splash_disable` option. It uses negated logic.

```sh
npm access grant read-write nodeos:developers nodeos-barebones
```

# 2017-04-03

`cpu` can have an `op` input to define what to do, controled by `wasmachine`.
Ops can be to set the PC to the `start` function or read from the stack the
values of a multi-valued return function.

Loader would have two main tasks, as a decoder of LEB128 values on the module
structure and organice its elements for easy and fast access, and generation of
the jump-forward tables. While doing that tasks it will enable the cpu reset
line so it doesn't execute instructions.

The need of a wasted cycle is because we are using clock signals on the ROM and
the stacks, so their operation doesn't start until the next tick. Since ROM is
just read-only it would be possible to remove that requeriment and make it just
combinational (and maybe for RAM too for read operations), but for stack will be
more difficult due to so much control logic they have inside, specially
SuperStack.

# 2017-04-04

[Associative arrays in SystemVerilog](http://vlsi.pro/system-verilog-associative-arrays/)

Associative arrays `key_type` [can be defined with `typedef`](http://www.testbench.in/SV_12_ASSOCIATIVE_ARRAYS.html):

```verilog
typedef bit signed [4:1] Nibble;
int array_name [ Nibble ]; // Signed packed array
```

[Online Verilog simulator](https://www.edaplayground.com/x/2Qn)

# 2017-04-05

Branches can be done using a "extended" version of WebAssembly where block
opcodes accept a second argument with the end address of the block, so it have
the performance advantages of the ad-hoc `jmp` opcode but using less memory and
without the exploit security issue. `if` conditionals would need a third
argument with the address of the `else` block so it can jump there; in case it's
no available it could be zero or the address of the end of the `if` block, but
in both cases it must be checked to don't create a call stack slice.

`return` can be invoked from inside some nested blocks, so it will be needed a
third stack to store the slice where they are defined and by-pass them.

`br_table` also requires "extended" WebAssembly, by decoding the LEB128 values
of the table entries. This way they can be accessed directly by their offset.

# 2017-04-06

https://github.com/WebAssembly/design/issues/1034

# 2017-04-08

Function arguments and local variables live in the same memory space, accessing
them with the `get_local()` and `set_local()` functions, being local variables
after function arguments. Since we are storing function arguments on the stack
itself and protected by `underflow_limit`, a simple (but maybe performance
suboptimal) solution would be add local variables there when calling the
`set_local()` function, moving up all the current stack slices. This way, when
returning the function call, the local variables will dissapear the same way it
happens with the function arguments.

It's possible to assign data to an array selection, but needs to be double
packet (bi-dimensional) instead of an array of registers. Selection range needs
to be constant. Alternative is to use a `loop` for.

# 2017-04-10

Local variables are at function level, so they need to be stored at the blocks
stack.

Function call arguments are set as stack values, so instead of copy them to the
local function variables, it could be check based on the number of arguments of
the function itself if they must be accessed from the stack or from the local
variables storage.

Loader will not have direct access to the CPU. Instead, a Controller module will
keep the CPU reset line enabled while not executing a function. Controller will
have a queue of user requests or events to feed the CPU. It will also monitor
the loader until a (new) module gets loaded and add itself a request to exec the
`start` function in case one is defined in the module.

# 2017-04-12

https://github.com/WebAssembly/design/issues/1037

# 2017-04-15

`br_table` could be optimized by replacing the labels by their actual (relative)
address, since they can't bypass function calls.
Function calls could be optimized by inlining the function metadata instead of
needing to search it on the functions table.

We need to move branches code to independent module and import it, both for
clean-up and removal of duplicated code, and easier maintenance and testing.
Easiest one would be just to import them in place, but it's not a real module...

We are using absolute addresses since they will be inlined "on the fly" to their
actual locations and this prevent us of needed to calculate the actual address
on runtime and we don't need Position Independent Code (PIC), but maybe it would
make sense to use relative addresses instead, not only for easier debugging but
also to allow to directly eXecute-in-Place (XiP) extended WebAssembly code, both
from storage and/or ROM.

https://github.com/steveicarus/iverilog/issues/155

# 2017-05-16

Since we are already using our own instructions set (extended WebAssembly), we
could go all down the road and fully define the opcode and/or instructions
format to optimice decoding, replacing the big `case` statement by a small
combinational circuit by using prefixes in the opcode format, or also split the
decoding in several parallel `always` processes, checking and executing just
only the one that matches.

# 2017-04-17

http://www.xess.com/shop/product/xula-200/

# 2017-04-20

Olimex board has a SRAM of 10ns time access, and a clock tick of 100MHz. This is
on purposse so the clock period is the same as the SRAM time access, so it can
be read and written sync'ed in a single tick. General CPU clock will need to be
divided and slowered, but a memory controller would be running at the RAM speed
to fetch and buffer the data.

WASD acronim is still not related to WebAssembly in any known way, and are the
keyboard letters used for games in 90's. Cool for the WebAssembly Extended
format or for a videogames console :-P

# 2017-04-21

MemoryController can have queued requests, but changuing from read to write will
need a missed tick to allow to read the data and don't overwrite it.

When not operating on the memory, disable the `chip select` line to allow it to
enter on energy saving mode.

# 2017-04-22

https://github.com/knielsen/ice40_viewer
https://github.com/drom/icedrom

https://www.reddit.com/r/yosys/comments/4g5mvm/find_path_between_two_regs/

# 2017-04-23

`for` loops with non-constant limits are not sintetizable since they are
un-rolled, so we can't zeroed stack slices for functions initialization. One
alternative would be to set explicitly the zeroes on extended WebAssembly as if
they were function arguments, but this would increase a lot the usage of program
RAM. Another alternatives would be to not zeroed fields, but this goes against
the specification, and use a bitmap of setted slices would complicate things a
bit and also it would be needed someway to set them too...

Timing the stack shows it uses almost all the logic blocks instead of memory
ones and also is very slow (49MHz), so it needs to find how to use BRAM. Also a
simple clock divisor is someone slow (456MHz), so maybe it's a limitation of the
FPGA or the toolchain itself...

# 2017-04-24

ICE40 BRAMs can be directly invoked, but also they should be already sintetized
automatically...

Reset of adjacent registers in a registers array would be done with several
parallel resets created using `for`, each one for a group of size power of two,
and later using ones or others based on the zeroes and ones of the register
holding the number of registers to be resetted. Base address for each one of the
blocks would need to be set independently and in cascade. Problem with that,
that this can't be used for RAM memory, so another solution would need to be
found... :-/

Develop tool to show source code lines describing the critical path, so it can
be optimized. It can be an automation of instructions found at
https://www.reddit.com/r/yosys/comments/4g5mvm/find_path_between_two_regs/d2gcetp/

https://www.reddit.com/r/yosys/comments/61z3e7/liberty_libraries/

https://github.com/cliffordwolf/yosys/issues/335

# 2017-04-25

[Signed comparison in Verilog](http://excamera.com/sphinx/fpga-verilog-sign.html)

http://icoboard.org/

Data probably would need to be padded on BRAMs for faster access if it's not
already done by the compiler itself...

Singed operations need that BOTH operators are signed.

# 2017-04-26

If we consider that both call and block stacks could have the same depth, then
they could be joined in a single stack similar to how databases tables are
"normalized", earning some BRAM memory by not duplicating the fields needed to
manage the operators stack.

Pipelined designs are implemented using several `always` statements in parallel,
one for each of the stages, and using registers to pass the values to the next
ones and control if workflow should be stopped.

Of all the possible optimizations, probably the best one is to define and use
our own opcodes format, using fixed prefixes for similar operations. This would
allow to don't need to decode the full opcode previously to process them but
instead simply check the type of the operation and delegate it to its specific
component, that being simpler would also make it easier to test and optimice.
Drawback would be that opcodes would not be so much packed and need to use
several bytes for their identifier.

Another possible optimization would be to fully decode the LEB128 fields, this
would waste more RAM memory (except on the cases of big numbers, where it would
be reduced) but would earn some logic levels and make some paths shorter.

http://www.chunder.com/ozinferno/
https://en.wikipedia.org/wiki/Stack_machine#Able_to_use_Out-of-Order_Execution
[Treegraph-based Instruction Scheduling for Stack-based Virtual Machines](http://www.sciencedirect.com/science/article/pii/S1571066111001538)

# 2017-04-27

CPU could be pipelined by adding guards to access to the elements that would
need several cycles, like the stack or memory or FPU, so pipeline gets stalled
until they get available. For elements with a constant delay, this could be
implemented with a counter decreased each cycle like POSIX semaphores, and for
non constant ones then it would be a flag. Obviously, if we manage to make
memory and/or stack to work in a single cycle, the guard would not be needed.
The FPU would need to stall the full CPU until it gets finished since it needs
to write to the stack, but maybe it would be possible to use the same stack
guard. All the operations would be pipelined (also return from blocks and
functions) except the ones that change the Program Counter, that would need to
cancel the next operations and the memory buffer.

Outputs of ROM and stacks could be in some cases combinational, leading to fetch
then in the next cycle after writting (don't need for an extra one to fetch the
data) and also to shorter paths.

Async asignations are being done when going out of the `always` block.

Warning: Replacing memory \stack with list of registers. See src/SuperStack.v:47, src/SuperStack.v:97

```verilog
out <= stack[index-1];
stack[index] = data;
```

https://www.reddit.com/r/yosys/comments/2kgfdr/incorrect_synthesis_results_for_multiport/cln0vnm/

http://www.sunburst-design.com/papers/CummingsSNUG2000SJ_NBA_rev1_2.pdf

# 2017-04-28

Stacks status would be splitted in two fields, status and error. This way would
allow to simplify and speed up its code by not needing blocking assignments and
use instead constant ones and/or several `always` blocks, but at the same time
would allow a better identification of when an actual error has occured. Output
of stack values and for `UNDERFLOW_GET` would also splitted instead of reused,
leading to better isolation and also allow to do the same improvements too.

# 2017-04-29

By disabling the filling of zeroes we improve performance more than twice (25-60
MHz) almost up to the regular stack (70 MHz). Alternatives would be to do the
zeroed in parallel by preserving someway the base address for each group, or
using a bitmap of the setted variables on each call slice, or do the zeroed in
several cycles by using a requests queue.

When using blocking assigment and reuse of `index` on stack `POP` the frequency
was up to 78.72 MHz, while using nonblocking and duplicated code it lowered down
to 75.08 MHz. On the other hand, using nonblocking assigment and another
`always` block it raised up to 80.23 MHz. All of them simulating for HX8k.

# 2017-04-30

CPU synth speed (hx8k):

HAS_FPU | HAS_RAM | USE_64B
=============================
No      | No      | No      | 54.17 MHz
No      | No      | Yes     | Failed
Yes     | No      | No      | 54.17 MHz
Yes     | Yes     | Yes     | Failed

In the successful cases, the longest path has 6 logic levels and it's related to
decodification of LEB128 i64 values (i0[7] -> o[24]).

In the cases where it failed, it lasted several minutes versus the few seconds
it lasted in the other cases, and it was when executing `berkeley-abc` with the
next output:

```
Running ABC command: berkeley-abc -s -f <abc-temp-dir>/abc.script 2>&1
ABC: ABC command line: "source <abc-temp-dir>/abc.script".
ABC:
ABC: + read_blif <abc-temp-dir>/input.blif
ABC: + read_lut <abc-temp-dir>/lutdefs.txt
ABC: + strash
ABC: + dc2
ABC: + scorr
ABC: Warning: The network is combinational (run "fraig" or "fraig_sweep").
ABC: + ifraig
ABC: + retime -o
ABC: + strash
ABC: + dch -f
ABC: + if
ABC: + mfs
ABC: + lutpack
ABC: berkeley-abc: src/opt/lpk/lpkCore.c:471: Lpk_ResynthesizeNodeNew: Assertion `Abc_ObjLevel(pObjNew) <= Required' failed.
ABC: Aborted (core dumped)
ERROR: ABC: execution of command "berkeley-abc -s -f /tmp/yosys-abc-PzfHLu/abc.script 2>&1" failed: return code 134.
```

Seems it's related to the long paths needed for the synthetization of a 64 bits
divisor, that `berkeley-abc` is not able to fully manage so long paths.

https://github.com/WebAssembly/design/issues/1050

https://github.com/kanaka/wac

# 2017-05-01

[Update BRAM without regenerate net list](http://stackoverflow.com/a/36858486/586382)

According to http://stackoverflow.com/a/41509289/586382, seems that the BRAM
inference just only replace an array of registers and their manipulation with
its equivalent code using the correct simulation model just like a preprocessor,
there's no magic or configuration involved and both are interchangeable.

http://stackoverflow.com/questions/41499494/how-can-i-use-ice40-4k-block-ram-in-512x8-read-mode-with-icestorm?rq=1#comment74479435_41509289

# 2017-05-04

Iverilog `-P<module>.<parameter>=<value>` allow to set parameters from command
line.

`==` compares only `0`'s and `1`'s, giving undefined if any bit is `x` or `z`.
`===` compares also the `x` and `z` bits.
