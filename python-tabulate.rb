class PythonTabulate < Formula
  desc "Pretty-print tabular data in Python"
  homepage "https://pypi.org/project/tabulate/"
  url "https://github.com/waltarix/python-tabulate/archive/v0.8.10-custom-r1.tar.gz"
  version "0.8.10"
  sha256 "a8fd8689cb647fce7927ea9cc1c62b23020cb34d935179663fb4fcb6e04b21cd"
  license "MIT"
  revision 3

  depends_on "python@3.11"
  depends_on "waltarix/customs/libpython-tabulate"

  def install
    # Install the binary only, the lib part is provided by libpython-tabulate
    system "python3.11", "setup.py", "--no-user-cfg", "install_scripts", "--install-dir=#{bin}", "--skip-build"
  end

  test do
    input = <<~EOS
      one,two,three
      …,……,………
      ...,......,.........
    EOS
    expected_output = <<~EOS
      ╭─────┬────────┬───────────╮
      │ one │ two    │ three     │
      ├─────┼────────┼───────────┤
      │ …  │ ……   │ ………    │
      │ ... │ ...... │ ......... │
      ╰─────┴────────┴───────────╯
    EOS
    assert_equal expected_output, pipe_output("#{bin}/tabulate -s, -1 -g0 -f fancy_outline_rounded", input)
  end
end
