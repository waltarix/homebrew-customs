class Dprint < Formula
  desc "Pluggable and configurable code formatting platform written in Rust"
  homepage "https://dprint.dev/"
  "0.39.0".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/dprint/releases/download/#{v}-custom/dprint-#{v}-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "6c96ba54ddcd1dbe5e4e094f354ea2d93648e86e259302844c5bb02dfefa3027"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/dprint/releases/download/#{v}-custom/dprint-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "54dabdcd072a241a28e66cbbd3c9caeddc6a2b013e8fe8c3843d185332da8574"
      else
        url "https://github.com/waltarix/dprint/releases/download/#{v}-custom/dprint-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "e9393e6aee1b9451db679859dc8caf2bdbc0170e7310f8fb632f2adc53b2e4b3"
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
