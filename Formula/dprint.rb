class Dprint < Formula
  desc "Pluggable and configurable code formatting platform written in Rust"
  homepage "https://dprint.dev/"
  ["0.49.1", nil].tap do |(v, r)|
    rev = r ? "-r#{r}" : ""
    if OS.linux?
      url "https://github.com/waltarix/dprint/releases/download/#{v}-custom#{rev}/dprint-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "1fd237facbe304804af8ab7d3afb7b5a162fef9348041248b05b6c8a1a23f24e"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/dprint/releases/download/#{v}-custom#{rev}/dprint-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "a19c0f7e8cc7cea6622d463b2cdb6682eb7f46f9055b5ec02357e73affe5be19"
      else
        url "https://github.com/waltarix/dprint/releases/download/#{v}-custom#{rev}/dprint-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "4a086884884976b90ad544373a75b64ac7badd82789e7612e3eb6e7418e5762d"
      end
    end
    revision r if r
  end
  license "MIT"
  head "https://github.com/dprint/dprint.git", branch: "main"

  def install
    bin.install "dprint"
  end

  test do
    (testpath/"dprint.json").write <<~JSON
      {
        "$schema": "https://dprint.dev/schemas/v0.json",
        "projectType": "openSource",
        "incremental": true,
        "typescript": {
        },
        "json": {
        },
        "markdown": {
        },
        "rustfmt": {
        },
        "includes": ["**/*.{ts,tsx,js,jsx,json,md,rs}"],
        "excludes": [
          "**/node_modules",
          "**/*-lock.json",
          "**/target"
        ],
        "plugins": [
          "https://plugins.dprint.dev/typescript-0.44.1.wasm",
          "https://plugins.dprint.dev/json-0.7.2.wasm",
          "https://plugins.dprint.dev/markdown-0.4.3.wasm",
          "https://plugins.dprint.dev/rustfmt-0.3.0.wasm"
        ]
      }
    JSON

    (testpath/"test.js").write("const arr = [1,2];")
    system bin/"dprint", "fmt", testpath/"test.js"
    assert_match "const arr = [1, 2];", File.read(testpath/"test.js")

    assert_match "dprint #{version}", shell_output("#{bin}/dprint --version")
  end
end
