class Dprint < Formula
  desc "Pluggable and configurable code formatting platform written in Rust"
  homepage "https://dprint.dev/"
  ["0.47.2", 1].tap do |(v, r)|
    rev = r ? "-r#{r}" : ""
    if OS.linux?
      url "https://github.com/waltarix/dprint/releases/download/#{v}-custom#{rev}/dprint-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "e20c24750e26f3b63278961fd39fa643225921c295b9c5694df62e8881022ab9"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/dprint/releases/download/#{v}-custom#{rev}/dprint-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "4d78210769330dfdc17eeb361a12308a4734990e55f0eb445ccb6047e73bd9c6"
      else
        url "https://github.com/waltarix/dprint/releases/download/#{v}-custom#{rev}/dprint-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "d082de05a3c38535c13f1e34888e940b9b1d866de352599e739ad839926dd41d"
      end
    end
    revision r if r
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
