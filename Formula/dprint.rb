class Dprint < Formula
  desc "Pluggable and configurable code formatting platform written in Rust"
  homepage "https://dprint.dev/"
  "0.35.4".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/dprint/releases/download/#{v}-custom/dprint-#{v}-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "ad31376aad59e85f54a97e3532999aa76883971fcea7e87367cd1076feac065b"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/dprint/releases/download/#{v}-custom/dprint-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "075788818c467faf2381d84d10435e5a183307f4fe4f3fc2152dca7eebad7eaf"
      else
        url "https://github.com/waltarix/dprint/releases/download/#{v}-custom/dprint-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "3aa2663f8070f489bb41f4c128be20e9b6aa15df3027789ae6e6199aa6deb349"
      end
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
