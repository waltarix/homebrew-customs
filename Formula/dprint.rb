class Dprint < Formula
  desc "Pluggable and configurable code formatting platform written in Rust"
  homepage "https://dprint.dev/"
  "0.45.0".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/dprint/releases/download/#{v}-custom/dprint-#{v}-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "9ebaeaeea2a9ff439bcdba49c6df50cde08b2a3b9d9f1fe0bdb143e0043038bb"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/dprint/releases/download/#{v}-custom/dprint-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "694e984ae8a768bdcca943bdbdb663a3d830211db539e4f87a5c5b5e2734da59"
      else
        url "https://github.com/waltarix/dprint/releases/download/#{v}-custom/dprint-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "33cc53b6ce4f6acb61924cfa6a9e5734b2be53a0e4797594a40d5b672e99c19e"
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
