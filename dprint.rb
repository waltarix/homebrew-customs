class Dprint < Formula
  desc "Pluggable and configurable code formatting platform written in Rust"
  homepage "https://dprint.dev/"
  if OS.linux?
    url "https://github.com/waltarix/dprint/releases/download/0.32.2-custom/dprint-0.32.2-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "2adc23afc57f3fee40a828c358928bf5b72ac75e0686eff01129fffc9dbca344"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/dprint/releases/download/0.32.2-custom/dprint-0.32.2-aarch64-apple-darwin.tar.xz"
      sha256 "182e8f8e106c0956bc375a026f9707c59a50aace9a9ddf54da8d9efccb7b5f7a"
    else
      url "https://github.com/waltarix/dprint/releases/download/0.32.2-custom/dprint-0.32.2-x86_64-apple-darwin.tar.xz"
      sha256 "9984b766f0ef2ced60cde97e333516b5c62011958aae6ce809dd95675b5de348"
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
