class Dprint < Formula
  desc "Pluggable and configurable code formatting platform written in Rust"
  homepage "https://dprint.dev/"
  if OS.linux?
    url "https://github.com/waltarix/dprint/releases/download/0.35.3-custom/dprint-0.35.3-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "92a0cf24fc0ec7507b138d79b6aea1d217fb3214c08eaab9a8429b534019b197"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/dprint/releases/download/0.35.3-custom/dprint-0.35.3-aarch64-apple-darwin.tar.xz"
      sha256 "d60bb10007ce76d3f49972b2fbf27393b0cd2eea0d50f3775701781889f01d79"
    else
      url "https://github.com/waltarix/dprint/releases/download/0.35.3-custom/dprint-0.35.3-x86_64-apple-darwin.tar.xz"
      sha256 "32ac781745aa712af584cec9357bdcdbeedd93080daf99d0142c12701e037c79"
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
