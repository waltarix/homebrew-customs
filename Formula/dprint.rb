class Dprint < Formula
  desc "Pluggable and configurable code formatting platform written in Rust"
  homepage "https://dprint.dev/"
  "0.40.0".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/dprint/releases/download/#{v}-custom/dprint-#{v}-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "60cb06f5abf692d8b3ef895138c9c8189852c9129b1449e27b2076867bb9ddc3"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/dprint/releases/download/#{v}-custom/dprint-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "cb9412918ac89285940168c22f85d2bb7de5a312637d9aa1beee670ed16bc1e5"
      else
        url "https://github.com/waltarix/dprint/releases/download/#{v}-custom/dprint-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "6bef1e55eedeac33c734dea6174db1e66916643b62bb3bf32de6f8f33fb25eaf"
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
