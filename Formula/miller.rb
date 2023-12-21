class Miller < Formula
  desc "Like sed, awk, cut, join & sort for name-indexed data such as CSV"
  homepage "https://github.com/johnkerl/miller"
  "6.10.0".tap do |v|
    if OS.linux?
      url "https://github.com/waltarix/miller/releases/download/v#{v}-custom/mlr-#{v}-linux_amd64.tar.xz"
      sha256 "4926ba5b4492909b9a81ca6275f641b4b88611241715b7122782a769e679d562"
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/miller/releases/download/v#{v}-custom/mlr-#{v}-darwin_arm64.tar.xz"
        sha256 "598ac0101e1c3b04e88af0f0c1a8205b0c4a8c999b2bcd230269bbf6746af239"
      else
        url "https://github.com/waltarix/miller/releases/download/v#{v}-custom/mlr-#{v}-darwin_amd64.tar.xz"
        sha256 "e54d13a5e2b4d85ffd462078d615669c6262ae432a2b8e67368cabe961547089"
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
