class PythonTabulate < Formula
  desc "Pretty-print tabular data in Python"
  homepage "https://pypi.org/project/tabulate/"
  url "https://files.pythonhosted.org/packages/ae/3d/9d7576d94007eaf3bb685acbaaec66ff4cdeb0b18f1bf1f17edbeebffb0a/tabulate-0.8.9.tar.gz"
  sha256 "eb1d13f25760052e8931f2ef80aaf6045a6cceb47514db8beab24cded16f13a7"
  license "MIT"

  depends_on "python@3.9"

  resource "wcwidth" do
    url "https://github.com/waltarix/python-wcwidth/archive/refs/tags/0.2.5-custom.tar.gz"
    sha256 "428f0217bd9c56fa3905ae34f4ac42b073273668342a2d203ed4f895b4442237"
  end

  def install
    python_bin = Formula["python@3.9"].opt_bin/"python3"

    xy = Language::Python.major_minor_version python_bin
    vendor_site_packages = libexec/"vendor/lib/python#{xy}/site-packages"
    ENV.prepend_create_path "PYTHONPATH", vendor_site_packages

    resource("wcwidth").stage do
      system python_bin, *Language::Python.setup_install_args(libexec/"vendor")
    end

    system python_bin, *Language::Python.setup_install_args(prefix)

    bin.env_script_all_files(libexec/"bin", PYTHONPATH: ENV["PYTHONPATH"])

    (prefix/"lib/python#{xy}/site-packages/homebrew-tabulate.pth").write <<~EOS
      import sys; sys.path.insert(0, '#{vendor_site_packages}')
    EOS
  end

  test do
    input = <<~EOS
      one,two,three
      …,……,………
      ...,......,.........
    EOS
    expected_output = <<~EOS
      ╒═════╤════════╤═══════════╕
      │ one │ two    │ three     │
      ├─────┼────────┼───────────┤
      │ …  │ ……   │ ………    │
      ├─────┼────────┼───────────┤
      │ ... │ ...... │ ......... │
      ╘═════╧════════╧═══════════╛
    EOS
    assert_equal expected_output, pipe_output("#{bin}/tabulate -s, -f fancy_grid", input)

    system Formula["python@3.9"].opt_bin/"python3", "-c", "from tabulate import tabulate"
  end
end
