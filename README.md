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
    2.75 ± 1.88 times faster than rust-ureq
    3.44 ± 2.49 times faster than rust-hyper
    9.16 ± 6.13 times faster than go-http-client
   11.52 ± 6.02 times faster than curl
   43.41 ± 20.09 times faster than rust-reqwest
  248.53 ± 109.23 times faster than python-http-client
```

| Command              |    Mean [ms] | Min [ms] | Max [ms] |        Relative |
| :------------------- | -----------: | -------: | -------: | --------------: |
| `zig-http-client`    |    0.5 ± 0.2 |      0.3 |      3.7 |            1.00 |
| `curl`               |    5.5 ± 1.6 |      3.5 |     13.1 |    11.52 ± 6.02 |
| `rust-hyper`         |    1.6 ± 1.0 |      0.7 |      7.9 |     3.44 ± 2.49 |
| `rust-reqwest`       |   20.6 ± 3.7 |     14.7 |     34.1 |   43.41 ± 20.09 |
| `rust-ureq`          |    1.3 ± 0.7 |      0.6 |      5.7 |     2.75 ± 1.88 |
| `go-http-client`     |    4.3 ± 2.2 |      2.2 |     17.6 |     9.16 ± 6.13 |
| `python-http-client` | 117.7 ± 12.3 |     98.2 |    138.7 | 248.53 ± 109.23 |

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
