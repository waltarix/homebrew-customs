class Hexyl < Formula
  desc "Command-line hex viewer"
  homepage "https://github.com/sharkdp/hexyl"
  if OS.linux?
    url "https://github.com/waltarix/hexyl/releases/download/v0.11.0-custom/hexyl-0.11.0-x86_64-unknown-linux-musl.tar.xz"
    sha256 "26a49663fc1ce97206ffd101f1479491a48d46d0acfaa6c2b2a561482eef67f7"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/hexyl/releases/download/v0.11.0-custom/hexyl-0.11.0-aarch64-apple-darwin.tar.xz"
      sha256 "a8d9d2a259389e5bd882b6e74ac7271f0aac98e2d9b563665bab7c63a6461276"
    else
      url "https://github.com/waltarix/hexyl/releases/download/v0.11.0-custom/hexyl-0.11.0-x86_64-apple-darwin.tar.xz"
      sha256 "668821d0e407588dbcc761f74b8d8c32c8fd755bca7a288159065aeea8eeb75e"
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
