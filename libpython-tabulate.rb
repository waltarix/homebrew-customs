class LibpythonTabulate < Formula
  desc "Pretty-print tabular data in Python"
  homepage "https://pypi.org/project/tabulate/"
  url "https://github.com/waltarix/python-tabulate/archive/v0.8.10-custom.tar.gz"
  sha256 "e5f98e5c969236aa5c8b215045b6a456b88cf064adda1ebec82a6a55791f6f77"
  license "MIT"

  depends_on "python@3.10" => [:build, :test]
  depends_on "python@3.9" => [:build, :test]
  depends_on "waltarix/customs/libpython-wcwidth"

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
