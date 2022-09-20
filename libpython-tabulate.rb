class LibpythonTabulate < Formula
  desc "Pretty-print tabular data in Python"
  homepage "https://pypi.org/project/tabulate/"
  url "https://github.com/waltarix/python-tabulate/archive/v0.8.10-custom-r1.tar.gz"
  sha256 "a8fd8689cb647fce7927ea9cc1c62b23020cb34d935179663fb4fcb6e04b21cd"
  license "MIT"
  revision 2

  depends_on "python@3.10" => [:build, :test]
  depends_on "python@3.9" => [:build, :test]
  depends_on "waltarix/customs/libpython-wcwidth"

  livecheck do
    formula "python-tabulate"
  end

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.match?(/python@\d\.\d+/) }
        .map(&:opt_bin)
        .map { |bin| bin/"python3" }
  end

  def install
    pythons.each do |python|
      system python, *Language::Python.setup_install_args(prefix),
                     "--install-lib=#{prefix/Language::Python.site_packages(python)}"
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
