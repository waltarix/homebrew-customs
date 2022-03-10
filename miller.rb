class Miller < Formula
  desc "Like sed, awk, cut, join & sort for name-indexed data such as CSV"
  homepage "https://github.com/johnkerl/miller"
  if OS.linux?
    url "https://github.com/waltarix/miller/releases/download/v6.1.0-custom/mlr-6.1.0-linux_amd64.tar.xz"
    sha256 "7b69b70ab90627649fbf66ba462c4d6d3e568c7a1277d50ed5eccef7108eb69a"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/miller/releases/download/v6.1.0-custom/mlr-6.1.0-darwin_arm64.tar.xz"
      sha256 "fb88227ad2ae1db86cb3f046ee3ed70d5f91650d00b50a347de1413148ac7f67"
    else
      url "https://github.com/waltarix/miller/releases/download/v6.1.0-custom/mlr-6.1.0-darwin_amd64.tar.xz"
      sha256 "49b3138ad87763e152dab68b1ee1a37d2cf6e10fcff008bc7596a9baacba7648"
    end
  end
  version "6.1.0"
  license "BSD-2-Clause"

  def install
    bin.install "mlr"
    man1.install "mlr.1"
  end

  test do
    (testpath/"test.csv").write <<~EOS
      one,two,three
      …,……,………
      ...,......,.........
    EOS
    result = <<~EOS
      ╭─────┬────────┬───────────╮
      │ one │ two    │ three     │
      ├─────┼────────┼───────────┤
      │ …  │ ……   │ ………    │
      │ ... │ ...... │ ......... │
      ╰─────┴────────┴───────────╯
    EOS
    output = pipe_output("#{bin}/mlr --c2p --barred cat test.csv")
    assert_equal result, output
  end
end
