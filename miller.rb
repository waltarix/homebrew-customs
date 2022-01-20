class Miller < Formula
  desc "Like sed, awk, cut, join & sort for name-indexed data such as CSV"
  homepage "https://github.com/johnkerl/miller"
  if OS.linux?
    url "https://github.com/waltarix/miller/releases/download/v6.0.0-custom-r1/mlr-6.0.0-linux_amd64.tar.xz"
    sha256 "d565677c5b016dce89afdc9d61c58327f39695634156f098a32a42f782b24b38"
  else
    if Hardware::CPU.arm?
      url "https://github.com/waltarix/miller/releases/download/v6.0.0-custom-r1/mlr-6.0.0-darwin_arm64.tar.xz"
      sha256 "2cc5e0ca10825b9972e7c608fd61264bb3c3d6f627cdc61f7d2e544c7f61fd15"
    else
      url "https://github.com/waltarix/miller/releases/download/v6.0.0-custom-r1/mlr-6.0.0-darwin_amd64.tar.xz"
      sha256 "3fa5fea57b2af50358eb45fc5ea8d5ac5492ceaf1f539606beed04ab25cef8b2"
    end
  end
  version "6.0.0"
  license "BSD-2-Clause"
  revision 1

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
    ENV["LC_ALL"] = "en_US.UTF-8"
    assert_equal result, pipe_output("#{bin}/mlr --c2p --barred cat test.csv")
  end
end
