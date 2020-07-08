class Choose < Formula
  desc "Human-friendly and fast alternative to cut and (sometimes) awk"
  homepage "https://github.com/theryangeary/choose"
  if OS.linux?
    url "https://github.com/waltarix/choose/releases/download/v1.3.0-custom/choose-1.3.0-linux.tar.xz"
    sha256 "45976485e06fdb663d51fd4ac291a960e61f905833ddabb48770e0bce3937b89"
  else
    url "https://github.com/waltarix/choose/releases/download/v1.3.0-custom/choose-1.3.0-darwin.tar.xz"
    sha256 "d408ba7f3d9141cc028294a914b801a198e1359245c921a03eb11ce7b0ceab50"
  end

  bottle :unneeded

  conflicts_with "choose-gui", :because => "both install a `choose` binary"
  conflicts_with "choose-rust", :because => "both install a `choose` binary"

  def install
    bin.install "choose"
  end

  test do
    input = "foo,  foobar,bar, baz"
    assert_equal "foobar bar", pipe_output("#{bin}/choose -f ',\\s*' 2:3", input).strip
  end
end
