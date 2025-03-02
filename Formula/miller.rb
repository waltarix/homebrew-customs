class Miller < Formula
  desc "Like sed, awk, cut, join & sort for name-indexed data such as CSV"
  homepage "https://github.com/johnkerl/miller"
  "6.13.0".tap do |v|
    if OS.linux?
      if Hardware::CPU.flags.grep(/\Aavx512/).size.zero?
        url "https://github.com/waltarix/miller/releases/download/v#{v}-custom/mlr-#{v}-linux_amd64_v2.tar.xz"
        sha256 "963640cd2a4c0c9610bf232694a4c86f05d392c4a6a61a31d854c407964f6dd7"
      else
        url "https://github.com/waltarix/miller/releases/download/v#{v}-custom/mlr-#{v}-linux_amd64_v4.tar.xz"
        sha256 "4415a788fd318852f2882ba8a70c18d090e298e47a5f29adce6d3e0751e34857"
      end
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/miller/releases/download/v#{v}-custom/mlr-#{v}-darwin_arm64.tar.xz"
        sha256 "cbbaedd906850d8ea983c6175b1e227174cbace5f0aa12f90e428e4b5f27022b"
      else
        url "https://github.com/waltarix/miller/releases/download/v#{v}-custom/mlr-#{v}-darwin_amd64_v3.tar.xz"
        sha256 "3d384d93f3f2138b813cf2f109a457d348c2b1c799030f44cc7c2977838d55ec"
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
