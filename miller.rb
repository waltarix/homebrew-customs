class Miller < Formula
  desc "Like sed, awk, cut, join & sort for name-indexed data such as CSV"
  homepage "https://github.com/johnkerl/miller"
  if OS.linux?
    url "https://github.com/waltarix/miller/releases/download/v6.5.0-custom/mlr-6.5.0-linux_amd64.tar.xz"
    sha256 "34e3349e37e63e2d385ccaa770dbf22402221d641862dd6611024a1e0a532161"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/miller/releases/download/v6.5.0-custom/mlr-6.5.0-darwin_arm64.tar.xz"
      sha256 "ed03d377cc8b5ce8aa4115ea9680346dd77b05469092fa867aa7fe1bf7a0717a"
    else
      url "https://github.com/waltarix/miller/releases/download/v6.5.0-custom/mlr-6.5.0-darwin_amd64.tar.xz"
      sha256 "251d32ac78c0a14bc7225cff72f762b41e9e76868c7f679cde46ec7cc48be9bc"
    end
  end
  version "6.5.0"
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
