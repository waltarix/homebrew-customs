class PythonTabulate < Formula
  desc "Pretty-print tabular data in Python"
  homepage "https://pypi.org/project/tabulate/"
  url "https://github.com/waltarix/python-tabulate/archive/v0.8.9-custom-r3.tar.gz"
  sha256 "0eba14b1f8f0a2eb4b5f6da49d9e93d208fc66aff43ec80e81a6faccdc1600a0"
  version "0.8.9"
  license "MIT"
  revision 4

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
      ╭─────┬────────┬───────────╮
      │ one │ two    │ three     │
      ├─────┼────────┼───────────┤
      │ …  │ ……   │ ………    │
      │ ... │ ...... │ ......... │
      ╰─────┴────────┴───────────╯
    EOS
    assert_equal expected_output, pipe_output("#{bin}/tabulate -s, -1 -g0 -f fancy_outline_rounded", input)

    system Formula["python@3.9"].opt_bin/"python3", "-c", "from tabulate import tabulate"
  end
end
