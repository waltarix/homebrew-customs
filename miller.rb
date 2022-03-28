class Miller < Formula
  desc "Like sed, awk, cut, join & sort for name-indexed data such as CSV"
  homepage "https://github.com/johnkerl/miller"
  if OS.linux?
    url "https://github.com/waltarix/miller/releases/download/v6.2.0-custom/mlr-6.2.0-linux_amd64.tar.xz"
    sha256 "b8fe5b3620e1fa2a1ae9820ed664e1422b1a68c31d076aef2d5d8f0b5a542be3"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/miller/releases/download/v6.2.0-custom/mlr-6.2.0-darwin_arm64.tar.xz"
      sha256 "3c6991d20ca4049c58c269c83983c28770c745320f21a08d666ce772b986811d"
    else
      url "https://github.com/waltarix/miller/releases/download/v6.2.0-custom/mlr-6.2.0-darwin_amd64.tar.xz"
      sha256 "72feb45559ad472dee2e8c4afb78f34595ae76b01e4760146569a309ab70c457"
    end
  end
  version "6.2.0"
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
