# Benchmark scene specifications

[benchmark-scenes.json](../contracts/benchmark-scenes.json) defines the first
canonical workloads and global performance contract. These are specifications,
not benchmark implementations or results.

Every implemented scene will have:

- deterministic seed and replay stream;
- declared variant coverage;
- reference output or semantic assertions;
- warmup, duration, and sample policy;
- frame reason, CPU, GPU, memory, allocation, resource, and input latency traces;
- exact Zagkit, Zag, OS, device, driver, display, and power metadata;
- cleanup and idle observation periods.

Raw run artifacts live outside source control until reviewed. Published summary
data links to immutable raw evidence. A missing metric stays missing rather than
being encoded as zero. No single screenshot or one-off timing is a result.
