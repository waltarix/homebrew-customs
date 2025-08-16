class Miller < Formula
  desc "Like sed, awk, cut, join & sort for name-indexed data such as CSV"
  homepage "https://github.com/johnkerl/miller"
  "6.15.0".tap do |v|
    if OS.linux?
      if Hardware::CPU.flags.grep(/\Aavx512/).size.zero?
        url "https://github.com/waltarix/miller/releases/download/v#{v}-custom/mlr-#{v}-linux_amd64_v2.tar.xz"
        sha256 "1130886a083340a96c0701697c69ad2c9db2aa1b506811f4479736f98f236eda"
      else
        url "https://github.com/waltarix/miller/releases/download/v#{v}-custom/mlr-#{v}-linux_amd64_v4.tar.xz"
        sha256 "1c26b1e4f00b86c6889d64e595964beb6ffadb2d03ece0817be34b08a3468770"
      end
    else
      if Hardware::CPU.arm?
        url "https://github.com/waltarix/miller/releases/download/v#{v}-custom/mlr-#{v}-darwin_arm64.tar.xz"
        sha256 "db6c3a72b563e6aeb96fe0cdbede2cc10dbc53ceb18feede947e2ff8e4ab38c1"
      else
        url "https://github.com/waltarix/miller/releases/download/v#{v}-custom/mlr-#{v}-darwin_amd64_v3.tar.xz"
        sha256 "8692503afa0c92093229e385f13905b41dec03b7b2ce1cdfb4c5bef16748dfa5"
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
