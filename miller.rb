class Miller < Formula
  desc "Like sed, awk, cut, join & sort for name-indexed data such as CSV"
  homepage "https://github.com/johnkerl/miller"
  if OS.linux?
    url "https://github.com/waltarix/miller/releases/download/v6.0.0-custom/mlr-6.0.0-linux_amd64.tar.xz"
    sha256 "1d02565d551606054f63a756a25220521f9be4dd525a2f8b4e2b57d5314aa7d2"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/miller/releases/download/v6.0.0-custom/mlr-6.0.0-darwin_arm64.tar.xz"
      sha256 "78fe26b578fd2a6b42dc1b3d50330d9353ef39907634b2971ccbe54919d1e5cc"
    else
      url "https://github.com/waltarix/miller/releases/download/v6.0.0-custom/mlr-6.0.0-darwin_amd64.tar.xz"
      sha256 "411bba6ba03c236ef8ff62da0557696a217f7c6701789429a76bdf1e553eb699"
    end
  end
  version "6.0.0"
  license "BSD-2-Clause"

  def install
    bin.install "mlr"
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
    ENV["LC_ALL"] = "en_US.UTF-8"
    assert_equal result, pipe_output("#{bin}/mlr --c2p --barred cat test.csv")
  end
end
