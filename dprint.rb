class Dprint < Formula
  desc "Pluggable and configurable code formatting platform written in Rust"
  homepage "https://dprint.dev/"
  if OS.linux?
    url "https://github.com/waltarix/dprint/releases/download/0.34.0-custom/dprint-0.34.0-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "ac97d921cd22a8bae934e844a6ea5edd9cce502df41bd0ae859ac79b79131680"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/dprint/releases/download/0.34.0-custom/dprint-0.34.0-aarch64-apple-darwin.tar.xz"
      sha256 "aa845677796f5a5367737bf7448215917bc0a949c2828cf8cc6a8186efdfe0dc"
    else
      url "https://github.com/waltarix/dprint/releases/download/0.34.0-custom/dprint-0.34.0-x86_64-apple-darwin.tar.xz"
      sha256 "88efcb716bdf2e840d41b7d95370526cda3b587c429c8d049423a3fc2c4e8d25"
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
