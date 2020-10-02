class Vivid < Formula
  desc "Generator for LS_COLORS with support for multiple color themes"
  homepage "https://github.com/sharkdp/vivid"
  if OS.linux?
    url "https://github.com/sharkdp/vivid/releases/download/v0.6.0/vivid-v0.6.0-x86_64-unknown-linux-musl.tar.gz"
    sha256 "cdd8c196516606b69e06a75cf8d6611515757f732c00abdb044c6d2c9797b5f6"
  else
    url "https://github.com/sharkdp/vivid/releases/download/v0.6.0/vivid-v0.6.0-x86_64-apple-darwin.tar.gz"
    sha256 "2416526d44f256097f20fced8d7a343a52e315167d0cfd128378a9c45bc4679e"
  end
  license any_of: ["MIT", "Apache-2.0"]

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
    assert_includes shell_output("#{bin}/vivid preview molokai"), "archives.images: \e[4;38;2;249;38;114m*.bin\e[0m\n"
  end
end
