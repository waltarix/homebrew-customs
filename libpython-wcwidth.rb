class LibpythonWcwidth < Formula
  desc "Pretty-print tabular data in Python"
  homepage "https://pypi.org/project/tabulate/"
  url "https://github.com/waltarix/python-wcwidth/archive/0.2.5-custom.tar.gz"
  sha256 "428f0217bd9c56fa3905ae34f4ac42b073273668342a2d203ed4f895b4442237"
  license "MIT"

  depends_on "python@3.10" => [:build, :test]
  depends_on "python@3.9" => [:build, :test]

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.match?(/python@\d\.\d+/) }
        .map(&:opt_bin)
        .map { |bin| bin/"python3" }
  end

  def install
    pythons.each do |python|
      site_packages = Language::Python.site_packages(python)

      system python, *Language::Python.setup_install_args(prefix), "--install-lib=#{libexec/site_packages}"

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
