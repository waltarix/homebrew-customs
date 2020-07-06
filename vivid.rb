class Vivid < Formula
  desc "Generator for LS_COLORS with support for multiple color themes"
  homepage "https://github.com/sharkdp/vivid"
  if OS.linux?
    url "https://github.com/sharkdp/vivid/releases/download/v0.5.0/vivid-v0.5.0-x86_64-unknown-linux-musl.tar.gz"
    sha256 "c287833452183c5d54e1424cfd92a98d61274130126892c4ef80758bc48c2d31"
  else
    url "https://github.com/sharkdp/vivid/releases/download/v0.5.0/vivid-v0.5.0-x86_64-apple-darwin.tar.gz"
    sha256 "c9664aea84caa7ad07a74d01aded1465e3553ecdfdd49da546a5b86b76495f9f"
  end

  bottle :unneeded

  def install
    bin.install "vivid"
    share.install "share/vivid"
  end

  def caveats
    <<~EOS
      To use the vivid by default:
        mkdir -p ~/.config
        cp -r #{share}/vivid ~/.config
    EOS
  end

  test do
    output = shell_output("#{bin}/vivid -V")
    assert_match "vivid #{version}", output
  end
end
