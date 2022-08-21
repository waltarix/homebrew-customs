class Miller < Formula
  desc "Like sed, awk, cut, join & sort for name-indexed data such as CSV"
  homepage "https://github.com/johnkerl/miller"
  if OS.linux?
    url "https://github.com/waltarix/miller/releases/download/v6.4.0-custom/mlr-6.4.0-linux_amd64.tar.xz"
    sha256 "a3f2afed9f01d8c8a230dc87257628e3e11c7f8e1f4c631b2a0d9f1c6565aa98"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/miller/releases/download/v6.4.0-custom/mlr-6.4.0-darwin_arm64.tar.xz"
      sha256 "4c41f36d2ca6246a5e5751b2f807a28591f26f51f861ee05a61bf6a9ffd5e71d"
    else
      url "https://github.com/waltarix/miller/releases/download/v6.4.0-custom/mlr-6.4.0-darwin_amd64.tar.xz"
      sha256 "38ac6315ee2a8bf3d5d2a3965709c1333fb3165922f07cfd9ace2f3dee24cdb6"
    end
  end
  version "6.4.0"
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
