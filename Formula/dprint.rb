class Dprint < Formula
  desc "Pluggable and configurable code formatting platform written in Rust"
  homepage "https://dprint.dev/"
  if OS.linux?
    url "https://github.com/waltarix/dprint/releases/download/0.35.0-custom/dprint-0.35.0-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "5640d8686ddffbdf62ad88e61b1e06626be37022d2a17e833737ccaff6df65b4"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/dprint/releases/download/0.35.0-custom/dprint-0.35.0-aarch64-apple-darwin.tar.xz"
      sha256 "0515d88d53dd1c569f9f1de98be6e090e78ab045ca40424b792b32dd81fc8526"
    else
      url "https://github.com/waltarix/dprint/releases/download/0.35.0-custom/dprint-0.35.0-x86_64-apple-darwin.tar.xz"
      sha256 "5910c9a73fb976f9e99de52ef53cbf9894623c5898b1e8e1d929eccda8a8dddd"
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
