#!/usr/bin/env bash

cpwd="$(pwd)"
required_bins=('zig' 'cargo' 'go' 'python' 'hyperfine')
zig_bins=('zig-http-server' 'zig-http-client')
rust_bins=('rust-hyper' 'rust-reqwest' 'rust-ureq')
go_bins=('go-http-client')
python_bins=('python-http-client')

for required_bin in "${required_bins[@]}"; do
  if ! command -v "${required_bin}" &>/dev/null; then
    echo "$required_bin is not installed!"
    exit 1
  fi
done

for zig_bin in "${zig_bins[@]}"; do
  echo "Building ${zig_bin}..."
  cd "${cpwd}/${zig_bin}" || exit
  zig build -Doptimize=ReleaseFast
done

for rust_bin in "${rust_bins[@]}"; do
  echo "Building ${rust_bin}..."
  cargo build --release --manifest-path "${cpwd}/${rust_bin}/Cargo.toml"
done

for go_bin in "${go_bins[@]}"; do
  echo "Building ${go_bin}..."
  cd "${cpwd}/${go_bin}" || exit
  go build "${go_bin}.go"
done

cd "${cpwd}" || exit
server_bin="${zig_bins[0]}"
echo "Running the server..."
"${cpwd}/${server_bin}/zig-out/bin/${server_bin}" &
SERVER_PID=$!
trap 'kill -9 $SERVER_PID' SIGINT SIGTERM

args=(
  "--warmup" "5"
  "-N"
  "--command-name" "zig-http-client"
  "--command-name" "curl"
  "--command-name" "rust-hyper"
  "--command-name" "rust-reqwest"
  "--command-name" "rust-ureq"
  "--command-name" "go-http-client"
  "--command-name" "python-http-client"
)

commands=(
  "${cpwd}/${zig_bins[1]}/zig-out/bin/${zig_bins[1]}"
  "curl http://127.0.0.1:8000/get"
)

for rust_bin in "${rust_bins[@]}"; do
  commands+=("${cpwd}/${rust_bin}/target/release/${rust_bin}")
done

for go_bin in "${go_bins[@]}"; do
  commands+=("${cpwd}/${go_bin}/${go_bin}")
done

for python_bin in "${python_bins[@]}"; do
  commands+=("python ${cpwd}/${python_bin}/${python_bin}.py")
done

hyperfine "${args[@]}" "${commands[@]}" --export-json benchmarks.json --export-markdown benchmarks.md
sed -i "s|$cpwd\/||g" benchmarks.*

kill -9 "$SERVER_PID"
