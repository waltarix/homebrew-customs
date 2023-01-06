class Dprint < Formula
  desc "Pluggable and configurable code formatting platform written in Rust"
  homepage "https://dprint.dev/"
  if OS.linux?
    url "https://github.com/waltarix/dprint/releases/download/0.34.1-custom/dprint-0.34.1-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "98f70337a1c2a522e600e612d35146d6f0b91a4ab62981374568b14584cacb8c"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/dprint/releases/download/0.34.1-custom/dprint-0.34.1-aarch64-apple-darwin.tar.xz"
      sha256 "eca36b1726f0023097c32f857fe98dc4ee493ea074f19529e6871dce9aec52fc"
    else
      url "https://github.com/waltarix/dprint/releases/download/0.34.1-custom/dprint-0.34.1-x86_64-apple-darwin.tar.xz"
      sha256 "63cabc18d65cfe7285343a5fc73a4b27f682d50514cafc754bad46f8cc451af1"
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
