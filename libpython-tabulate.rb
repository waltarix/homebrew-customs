class LibpythonTabulate < Formula
  desc "Pretty-print tabular data in Python"
  homepage "https://pypi.org/project/tabulate/"
  url "https://github.com/waltarix/python-tabulate/archive/v0.9.0-custom.tar.gz"
  sha256 "18b93ff6c2734e7fb5fdeccee5c896d0d0567ed93cc3720f679ed9f699c47d3d"
  license "MIT"
  revision 1

  livecheck do
    formula "python-tabulate"
  end

  depends_on "python@3.10" => [:build, :test]
  depends_on "python@3.11" => [:build, :test]
  depends_on "python@3.9" => [:build, :test]
  depends_on "waltarix/customs/libpython-wcwidth"

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.match?(/^python@\d\.\d+$/) }
        .map { |f| f.opt_libexec/"bin/python" }
  end

  def install
    (buildpath/"setup.py").write <<~EOS
      import setuptools

      if __name__ == "__main__":
          setuptools.setup()
    EOS
    inreplace "pyproject.toml", /^dynamic .+$/, "version = \"#{version}\""

    pythons.each do |python|
      system python, *Language::Python.setup_install_args(prefix, python)
    end

    # Remove bin folder, use tabulate from the python-tabulate formula instead.
    # This is necessary to keep all the Python versions as build/test
    # dependencies only for the libpython-tabulate
    rm_rf prefix/"bin"
  end

  test do
    pythons.each do |python|
      system python, "-c", "from tabulate import tabulate"
    end
  end
end
