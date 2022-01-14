class PythonTabulate < Formula
  desc "Pretty-print tabular data in Python"
  homepage "https://pypi.org/project/tabulate/"
  url "https://github.com/waltarix/python-tabulate/archive/v0.8.9-custom.tar.gz"
  sha256 "626de0d35880cdb744e033bad2b79139166324bec4c8a9571d50025d363d5428"
  license "MIT"
  revision 1

  depends_on "python@3.9"

  resource "wcwidth" do
    url "https://github.com/waltarix/python-wcwidth/archive/0.2.5-custom.tar.gz"
    sha256 "428f0217bd9c56fa3905ae34f4ac42b073273668342a2d203ed4f895b4442237"
  end

  def install
    python_bin = Formula["python@3.9"].opt_bin/"python3"
    vendor = libexec/"vendor"
    vendor_lib = vendor/"lib"

    resource("wcwidth").stage do
      system python_bin, *Language::Python.setup_install_args(vendor)
    end
    system python_bin, *Language::Python.setup_install_args(prefix)

    xy = Language::Python.major_minor_version python_bin
    site_packages = "python#{xy}/site-packages"
    (lib/site_packages/"homebrew-tabulate.pth").write <<~EOS
      import sys; sys.path.insert(0, '#{vendor_lib/site_packages}')
    EOS
  end

  test do
    input = <<~EOS
      one,two,three
      …,……,………
      ...,......,.........
    EOS
    expected_output = <<~EOS
      ╭───────┬────────┬───────────╮
      │ one   │ two    │ three     │
      ├───────┼────────┼───────────┤
      │ …    │ ……   │ ………    │
      │ ...   │ ...... │ ......... │
      ╰───────┴────────┴───────────╯
    EOS
    assert_equal expected_output, pipe_output("#{bin}/tabulate -s, -1 -f fancy_outline_rounded", input)

    system Formula["python@3.9"].opt_bin/"python3", "-c", "from tabulate import tabulate"
  end
end
