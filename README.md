## `zig-http-benchmarks` ⚡

Read the blog post: [**Zig Bits 0x4**](https://blog.orhun.dev/zig-bits-04/)

This repository contains a HTTP server/client implementation using Zig's standard library and benchmarks for comparing the client's performance with implementations in other programming languages such as Rust and Go.

### Prerequisites

- Zig (`>=0.11`), Rust/Cargo, Go, Python
- [Hyperfine](https://github.com/sharkdp/hyperfine) (for benchmarking)

### Benchmarking

To run the benchmarks:

```sh
chmod +x bench.sh
./bench.sh
```

The result will be saved to `benchmarks.md` and `benchmarks.json`.

```
rust-ureq ran
    1.18 ± 0.22 times faster than rust-hyper
    1.30 ± 0.27 times faster than rust-reqwest
    1.74 ± 0.38 times faster than go-http-client
    1.92 ± 0.40 times faster than rust-attohttpc
    2.17 ± 0.63 times faster than zig-http-client
    4.25 ± 0.73 times faster than curl
   10.31 ± 1.47 times faster than python-http-client
```

| Command              |    Mean [ms] | Min [ms] | Max [ms] |     Relative |
| :------------------- | -----------: | -------: | -------: | -----------: |
| `curl`               | 295.2 ± 29.3 |    248.6 |    367.9 |  4.25 ± 0.73 |
| `zig-http-client`    | 150.9 ± 38.1 |     98.5 |    250.2 |  2.17 ± 0.63 |
| `rust-attohttpc`     | 133.4 ± 20.6 |    101.1 |    174.7 |  1.92 ± 0.40 |
| `rust-hyper`         |  82.1 ± 10.1 |     65.7 |    106.0 |  1.18 ± 0.22 |
| `rust-reqwest`       |  90.0 ± 14.0 |     67.8 |    126.0 |  1.30 ± 0.27 |
| `rust-ureq`          |   69.5 ± 9.6 |     55.3 |     92.9 |         1.00 |
| `go-http-client`     | 120.8 ± 20.0 |     84.6 |    171.6 |  1.74 ± 0.38 |
| `python-http-client` | 716.5 ± 22.0 |    665.9 |    765.7 | 10.31 ± 1.47 |

### Plotting

Use the [JSON data](https://github.com/sharkdp/hyperfine#json) along with the [scripts](https://github.com/sharkdp/hyperfine/tree/master/scripts) from the `hyperfine` examples to plot data using [`matplotlib`](https://matplotlib.org/). For example:

```sh
git clone --depth 1 https://github.com/sharkdp/hyperfine
python hyperfine/scripts/plot_whisker.py benchmarks.json
```

![plot_whisker](https://user-images.githubusercontent.com/24392180/257202869-bdc1dbf7-c4f8-4842-96c2-d9bab79cebed.jpg)

### License

<sup>
Licensed under <a href="LICENSE">The MIT License</a>.
</sup>
