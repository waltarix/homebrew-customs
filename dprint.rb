class Dprint < Formula
  desc "Pluggable and configurable code formatting platform written in Rust"
  homepage "https://dprint.dev/"
  if OS.linux?
    url "https://github.com/waltarix/dprint/releases/download/0.34.4-custom/dprint-0.34.4-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "cc9c373af6ea81c26aadbcfd08e58f9bb77bfbf60b7b4f0035d4db252ff0534f"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/dprint/releases/download/0.34.4-custom/dprint-0.34.4-aarch64-apple-darwin.tar.xz"
      sha256 "d72ffd9576c2f101d4d1ba6b300b635c1b9ba3dfa3ff042c5df5e806218c3305"
    else
      url "https://github.com/waltarix/dprint/releases/download/0.34.4-custom/dprint-0.34.4-x86_64-apple-darwin.tar.xz"
      sha256 "12f90087377fffa28844fc39a3bd3532003d72e49d1e2b66b0d9e51955a0c979"
    end
  end
  license "MIT"
  head "https://github.com/dprint/dprint.git", branch: "main"

  def install
    bin.install "dprint"
  end

  test do
    (testpath/"dprint.json").write <<~EOS
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
    EOS

    (testpath/"test.js").write("const arr = [1,2];")
    system bin/"dprint", "fmt", testpath/"test.js"
    assert_match "const arr = [1, 2];", File.read(testpath/"test.js")

    assert_match "dprint #{version}", shell_output("#{bin}/dprint --version")
  end
end
