class Miller < Formula
  desc "Like sed, awk, cut, join & sort for name-indexed data such as CSV"
  homepage "https://github.com/johnkerl/miller"
  "6.9.0".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/miller/releases/download/v#{v}-custom/mlr-#{v}-linux_amd64.tar.xz"
      sha256 "9a8eeaaaf2ea7436d133f3730d86f15e599e93682ff5c26fa9643490a3acf9b1"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/miller/releases/download/v#{v}-custom/mlr-#{v}-darwin_arm64.tar.xz"
        sha256 "3fe65775cf4f8387887a6a7d58886ab130d49c69bf07e09eba921e6348a3c060"
      else
        url "https://github.com/waltarix/miller/releases/download/v#{v}-custom/mlr-#{v}-darwin_amd64.tar.xz"
        sha256 "ec501a5d1635f1c6b84ae46756bcc72df2ba34e7f7d0542741ae13755a966c22"
      end
    end
    version v
  end
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
