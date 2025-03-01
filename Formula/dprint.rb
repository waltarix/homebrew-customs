class Dprint < Formula
  desc "Pluggable and configurable code formatting platform written in Rust"
  homepage "https://dprint.dev/"
  ["0.49.0", nil].tap do |(v, r)|
    rev = r ? "-r#{r}" : ""
    if OS.linux?
      url "https://github.com/waltarix/dprint/releases/download/#{v}-custom#{rev}/dprint-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "46e71c29d8b8a90be74f4ea3420d868edbb868519a85112e647de013cf4e594f"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/dprint/releases/download/#{v}-custom#{rev}/dprint-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "ac9bcb681c9a663fdd7261dbea93a8240f3e8788abf83ba9ed0c09159682a836"
      else
        url "https://github.com/waltarix/dprint/releases/download/#{v}-custom#{rev}/dprint-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "792af42de8dccfa52eee2b23026cdb908b7a9153e09d255f96711cad4bb5c21a"
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
    (testpath/"dprint.json").write <<~JSON
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
    JSON

    (testpath/"test.js").write("const arr = [1,2];")
    system bin/"dprint", "fmt", testpath/"test.js"
    assert_match "const arr = [1, 2];", File.read(testpath/"test.js")

    assert_match "dprint #{version}", shell_output("#{bin}/dprint --version")
  end
end
