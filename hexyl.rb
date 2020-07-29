class Hexyl < Formula
  desc "Command-line hex viewer"
  homepage "https://github.com/sharkdp/hexyl"
  if OS.linux?
    url "https://github.com/waltarix/hexyl/releases/download/v0.8.0-custom/hexyl-0.8.0-linux.tar.xz"
    sha256 "5ce7467a76ed05785af2f66aa465fe7d7ae05d21fef637099f577442cb6561a1"
  else
    url "https://github.com/waltarix/hexyl/releases/download/v0.8.0-custom/hexyl-0.8.0-darwin.tar.xz"
    sha256 "2693202c2f72597c8e0769762613ed0c1162ca7eb77d20013635c6ac293d3310"
  end
  license "Apache-2.0"

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
