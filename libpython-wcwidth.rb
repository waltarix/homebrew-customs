class LibpythonWcwidth < Formula
  desc "Pretty-print tabular data in Python"
  homepage "https://pypi.org/project/tabulate/"
  url "https://github.com/waltarix/python-wcwidth/archive/0.2.5-custom-r1.tar.gz"
  version "0.2.5"
  sha256 "02e2428c74fce44afba1d01161e2f149ed6120fde8eee162bedf8d89a7788383"
  license "MIT"
  revision 1

  depends_on "python@3.10" => [:build, :test]
  depends_on "python@3.9" => [:build, :test]

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.match?(/^python@\d\.\d+$/) }
        .map { |f| f.opt_libexec/"bin/python" }
  end

  def install
    pythons.each do |python|
      site_packages = Language::Python.site_packages(python)

      system python, *Language::Python.setup_install_args(prefix, python), "--install-lib=#{libexec/site_packages}"

      (prefix/site_packages/"homebrew-libpython-wcwidth.pth").write <<~EOS
        import sys; sys.path.insert(0, '#{libexec/site_packages}')
      EOS
    end
  end

  test do
    pythons.each do |python|
      system python, "-c", "import wcwidth"
    end
  end
end
