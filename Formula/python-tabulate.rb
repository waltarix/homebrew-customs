class PythonTabulate < Formula
  include Language::Python::Virtualenv

  desc "Pretty-print tabular data in Python"
  homepage "https://github.com/astanin/python-tabulate"
  url "https://github.com/waltarix/python-tabulate/releases/download/v0.9.0-custom-r2/tabulate-0.9.0.tar.gz"
  sha256 "f5c8bc48780a17933e60b042b0919f2b0c90c187413b1299cdabdebf4326b3fe"
  license "MIT"
  revision 2

  depends_on "python@3.13"
  depends_on "waltarix/customs/python-wcwidth"

  def install
    virtualenv_install_with_resources
  end

  test do
    (testpath/"in.txt").write <<~EOS
      one,two,three
      …,……,………
      ...,......,.........
    EOS

    (testpath/"out.txt").write <<~EOS
      ╭─────┬────────┬───────────╮
      │ one │ two    │ three     │
      ├─────┼────────┼───────────┤
      │ …  │ ……   │ ………    │
      │ ... │ ...... │ ......... │
      ╰─────┴────────┴───────────╯
    EOS

    assert_equal (testpath/"out.txt").read,
      shell_output("#{bin}/tabulate -s, -1 -g0 -f rounded_outline #{testpath}/in.txt")
  end
end
