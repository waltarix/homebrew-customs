class Hexyl < Formula
  desc "Command-line hex viewer"
  homepage "https://github.com/sharkdp/hexyl"
  "0.13.0".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/hexyl/releases/download/v#{v}-custom/hexyl-#{v}-x86_64-unknown-linux-musl.tar.xz"
      sha256 "d3c54763fcb705a2da5dd1168bdaceba8369a3172d1ca878f075d9cbb80e84af"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/hexyl/releases/download/v#{v}-custom/hexyl-#{v}-aarch64-apple-darwin.tar.xz"
        sha256 "7a8c78d2acfc90a041cdac36c2f9f962fc409a5cc9a4894c2c383e1e14dd4bb2"
      else
        url "https://github.com/waltarix/hexyl/releases/download/v#{v}-custom/hexyl-#{v}-x86_64-apple-darwin.tar.xz"
        sha256 "db51fd2466d9f7ef0ea0f313ce8322e6d5c0c816aa608b501533dae922b0b371"
      end
    end
  end
  license any_of: ["Apache-2.0", "MIT"]

  def install
    bin.install "hexyl"
    man1.install "manual/hexyl.1"

    generate_completions_from_executable(bin/"hexyl", "--completion")
  end

  test do
    pdf = test_fixtures("test.pdf")
    output = shell_output("#{bin}/hexyl -n 100 #{pdf}")
    assert_match "00000000", output
  end
end
