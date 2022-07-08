class Miller < Formula
  desc "Like sed, awk, cut, join & sort for name-indexed data such as CSV"
  homepage "https://github.com/johnkerl/miller"
  if OS.linux?
    url "https://github.com/waltarix/miller/releases/download/v6.3.0-custom/mlr-6.3.0-linux_amd64.tar.xz"
    sha256 "e0707bb06b4778e922f5a89641f156081b02f94414a1ab85555e46e0f69ac21a"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/miller/releases/download/v6.3.0-custom/mlr-6.3.0-darwin_arm64.tar.xz"
      sha256 "881ca2b1654ccb8c911dc792d4026bb0094fffdc68b1ac98253507bcecf4af53"
    else
      url "https://github.com/waltarix/miller/releases/download/v6.3.0-custom/mlr-6.3.0-darwin_amd64.tar.xz"
      sha256 "b5ffc00ba98bbd5a2fc8f66a0fa8cadc31ff498e09a87d231ad525328dfa983f"
    end
  end
  version "6.3.0"
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
