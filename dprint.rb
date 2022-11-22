class Dprint < Formula
  desc "Pluggable and configurable code formatting platform written in Rust"
  homepage "https://dprint.dev/"
  if OS.linux?
    url "https://github.com/waltarix/dprint/releases/download/0.33.0-custom/dprint-0.33.0-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "4e540af00f7fa4a146df70de6eb0f4e4399bb30331ae4e006a3f6a3e11bd0bfd"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/dprint/releases/download/0.33.0-custom/dprint-0.33.0-aarch64-apple-darwin.tar.xz"
      sha256 "4dbe84d69ef39405b445c08ee1d4b0a30b61a4dc035e88139f29dfb3cca8601f"
    else
      url "https://github.com/waltarix/dprint/releases/download/0.33.0-custom/dprint-0.33.0-x86_64-apple-darwin.tar.xz"
      sha256 "7795a00d8b23bb05be93cf360f94d45d431a4ff11b1a91ccffba8ff6783f6e0e"
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
