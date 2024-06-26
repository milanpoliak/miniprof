# Zig Miniprof

Minimalistic profiler tool for Zig.

## How to use

### Install

1. Add Miniprof to `build.zig.zon` dependencies

```shell
zig fetch --save https://github.com/milanpoliak/miniprof/archive/refs/tags/v0.1.1.tar.gz
```

2. Add Miniprof to `build.zig`

```zig
const miniprof = b.dependency("miniprof", .{
    .target = target,
    .optimize = optimize,
});

exe.root_module.addImport("miniprof", miniprof.module("miniprof"));
```

### Run

```zig
// Import Miniprof
const profiler = @import("miniprof");
const OpenBlock = profiler.OpenBlock;

const allocator = std.testing.allocator;

// Setup global profiler...
try profiler.setupGlobalProfiler(allocator, 64); // Profilers have capacity, but they use std.ArrayList and can grow when needed
var block = OpenBlock("A block");
defer block.close();

// ... or create a custom instance (e.g. if you need independent profiles for different code paths) 
var prof = try profiler.Profiler.init(allocator, 64);
var block = profiler.OpenBlockWithProfiler("A block", &prof);
defer block.close();

// ... do stuff

// Print results in a table (or use profiler.blocks directly to report it in other formats)
try profiler.writeTable(profiler.GlobalProfiler, std.io.getStdOut().writer(), allocator)
```

Example table output

```text
Block           Exclusive time  % of total time  Total time  Hits    
---------------------------------------------------------------------
a block         11283703        0.24             9561689374  2       
another block   4661619021      97.51            4769561005  290875 
```

### Disabling profiler

For release builds, or any other situations you want the profiler to be disabled
simply import the `disabled` module in your `build.zig`.
The `disabled` module exposes all functions with the same signatures, but empty bodies.

```zig
exe.root_module.addImport("miniprof", miniprof.module("disabled"));
```

### Known limitations

- Multiple blocks with the same name will be treated as a single block 