class PythonTabulate < Formula
  desc "Pretty-print tabular data in Python"
  homepage "https://pypi.org/project/tabulate/"
  url "https://github.com/waltarix/python-tabulate/archive/v0.8.10-custom.tar.gz"
  sha256 "e5f98e5c969236aa5c8b215045b6a456b88cf064adda1ebec82a6a55791f6f77"
  license "MIT"

  depends_on "python@3.9"
  depends_on "waltarix/customs/libpython-tabulate"

  def install
    # Install the binary only, the lib part is provided by libpython-tabulate
    system "python3", "setup.py", "--no-user-cfg", "install_scripts", "--install-dir=#{bin}", "--skip-build"
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
