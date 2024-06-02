# Zig Miniprof

Minimalistic profiler tool for Zig.

## How to use

### Install

1. Add Miniprof to `build.zig.zon` dependencies

Either run `zig fetch --save https://github.com/milanpoliak/miniprof/archive/refs/tags/v0.0.1.tar.gz`

or add it manually

```zig
...
.dependencies = .{
    .miniprof = .{
        .url = "https://github.com/milanpoliak/miniprof/archive/refs/tags/v0.0.1.tar.gz",
        .hash = "...", // TODO:
    },
},
...
```

2. Add Miniprof to `build.zig`

```zig
const zig_bench = b.dependency("miniprof", .{
    .target = target,
    .optimize = optimize,
});

exe.root_module.addImport("miniprof", zig_bench.module("miniprof"));
```

### Run

```zig
// Import Miniprof
const profiler = @import("miniprof");
const OpenBlock = profiler.OpenBlock;

const allocator = std.testing.allocator;

// Setup global profiler...
try profiler.setupGlobalProfiler(allocator, 64);
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

### Known limitations

- Multiple blocks with the same name will be treated as a single block 