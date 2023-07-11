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
zig-http-client ran
    2.23 ± 1.04 times faster than rust-ureq
    4.16 ± 1.96 times faster than rust-hyper
    6.41 ± 3.28 times faster than go-http-client
   12.00 ± 5.53 times faster than curl
   30.84 ± 11.16 times faster than rust-reqwest
  223.89 ± 78.12 times faster than python-http-client
```

| Command              |    Mean [ms] | Min [ms] | Max [ms] |       Relative |
| :------------------- | -----------: | -------: | -------: | -------------: |
| `zig-http-client`    |    0.5 ± 0.2 |      0.3 |      1.8 |           1.00 |
| `curl`               |    6.4 ± 2.0 |      3.5 |     10.7 |   12.00 ± 5.53 |
| `rust-hyper`         |    2.2 ± 0.7 |      1.4 |      8.3 |    4.16 ± 1.96 |
| `rust-reqwest`       |   16.4 ± 2.3 |     14.0 |     35.3 |  30.84 ± 11.16 |
| `rust-ureq`          |    1.2 ± 0.4 |      0.6 |      3.1 |    2.23 ± 1.04 |
| `go-http-client`     |    3.4 ± 1.3 |      2.1 |     11.2 |    6.41 ± 3.28 |
| `python-http-client` | 118.9 ± 12.1 |     97.4 |    132.9 | 223.89 ± 78.12 |

### Plotting

Use the [JSON data](https://github.com/sharkdp/hyperfine#json) along with the [scripts](https://github.com/sharkdp/hyperfine/tree/master/scripts) from the `hyperfine` examples to plot data using [`matplotlib`](https://matplotlib.org/). For example:

```sh
git clone --depth 1 https://github.com/sharkdp/hyperfine
python hyperfine/scripts/plot_whisker.py benchmarks.json
```

![plot_whisker](https://user-images.githubusercontent.com/24392180/250958779-3c9b78ce-c5f2-45fa-bb8f-278fb076eb37.jpg)

### License

<sup>
Licensed under <a href="LICENSE">The MIT License</a>.
</sup>
