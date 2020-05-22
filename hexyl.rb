class Hexyl < Formula
  desc "Command-line hex viewer"
  homepage "https://github.com/sharkdp/hexyl"
  if OS.linux?
    url "https://github.com/waltarix/hexyl/releases/download/v0.7.0-custom/hexyl-0.7.0-linux.tar.xz"
    sha256 "ef5653af71e0cd95a56babe9feb8fb59171748e75033ded07ded3f07a787554a"
  else
    url "https://github.com/waltarix/hexyl/releases/download/v0.7.0-custom/hexyl-0.7.0-darwin.tar.xz"
    sha256 "4f90548c251b483498b2e7f242168b9527637eef783702450babfabb29b67b68"
  end

  bottle :unneeded

  def install
    bin.install "hexyl"
  end

  test do
    pdf = test_fixtures("test.pdf")
    output = shell_output("#{bin}/hexyl -n 100 #{pdf}")
    assert_match "00000000", output
  end
end
