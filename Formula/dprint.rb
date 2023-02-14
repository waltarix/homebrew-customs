class Dprint < Formula
  desc "Pluggable and configurable code formatting platform written in Rust"
  homepage "https://dprint.dev/"
  if OS.linux?
    url "https://github.com/waltarix/dprint/releases/download/0.34.5-custom-r1/dprint-0.34.5-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "02d4d9fcab516cc6dc71c9255826a073e1e11ea7c50dc60ee89530802346de34"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/dprint/releases/download/0.34.5-custom-r1/dprint-0.34.5-aarch64-apple-darwin.tar.xz"
      sha256 "4ae3dedb5def62f92d2ca9f69295f066317f8f301852c2dd93dbc584481b5c77"
    else
      url "https://github.com/waltarix/dprint/releases/download/0.34.5-custom-r1/dprint-0.34.5-x86_64-apple-darwin.tar.xz"
      sha256 "035e66583f7de65300c3597bf37ff8986d02d57de1a2016033c2a33a358eb7f2"
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
