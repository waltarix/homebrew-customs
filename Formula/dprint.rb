class Dprint < Formula
  desc "Pluggable and configurable code formatting platform written in Rust"
  homepage "https://dprint.dev/"
  "0.43.2".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/dprint/releases/download/#{v}-custom/dprint-#{v}-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "f243b2c5874137547faddab7ab6c9c5425c09472b0f1a50a84436d7e69150d8f"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/dprint/releases/download/#{v}-custom/dprint-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "3892dd9f260923020d3a06785e7aff54e82c1d54bf7c3178b6a052a7488f1724"
      else
        url "https://github.com/waltarix/dprint/releases/download/#{v}-custom/dprint-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "1f200016b40b242a7ce1da3ff99e74aa44091e09021a8661abc40f9d734527b7"
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
