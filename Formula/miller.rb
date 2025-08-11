class Miller < Formula
  desc "Like sed, awk, cut, join & sort for name-indexed data such as CSV"
  homepage "https://github.com/johnkerl/miller"
  "6.14.0".tap do |v|
    if OS.linux?
      if Hardware::CPU.flags.grep(/\Aavx512/).size.zero?
        url "https://github.com/waltarix/miller/releases/download/v#{v}-custom/mlr-#{v}-linux_amd64_v2.tar.xz"
        sha256 "754cfec52e74348ad7ba09dd123dcc1a7331914d2bca55069b8ef516dfb849e9"
      else
        url "https://github.com/waltarix/miller/releases/download/v#{v}-custom/mlr-#{v}-linux_amd64_v4.tar.xz"
        sha256 "34dde84506d35119ffd9e46d639fb6b86c76053316d5222581d5467e2ada1f37"
      end
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/miller/releases/download/v#{v}-custom/mlr-#{v}-darwin_arm64.tar.xz"
        sha256 "21181dff380db77dc744ae55b5578cda925a56cf15c747ba4223c37ca5f2a5a5"
      else
        url "https://github.com/waltarix/miller/releases/download/v#{v}-custom/mlr-#{v}-darwin_amd64_v3.tar.xz"
        sha256 "63f67c5653757615e5f73159a935efdc6efc75ccc9deb8adec459521ca3641f6"
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
    (testpath/"test.csv").write <<~CSV
      one,two,three
      …,……,………
      ...,......,.........
    CSV
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
