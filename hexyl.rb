class Hexyl < Formula
  desc "Command-line hex viewer"
  homepage "https://github.com/sharkdp/hexyl"
  if OS.linux?
    url "https://github.com/waltarix/hexyl/releases/download/v0.7.0-custom/hexyl-0.7.0-linux.tar.xz"
    sha256 "f6f90fadb3b300d2c8d23f2d122f2a9eeb269512193413c2816785ebb038a30c"
  else
    url "https://github.com/waltarix/hexyl/releases/download/v0.7.0-custom/hexyl-0.7.0-darwin.tar.xz"
    sha256 "19db60331c199c5176d1bcfc4cb5fc256fd670730b1a5dfff29cd39cb4fb9660"
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
