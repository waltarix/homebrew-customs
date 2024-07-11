class PythonTabulate < Formula
  desc "Pretty-print tabular data in Python"
  homepage "https://github.com/astanin/python-tabulate"
  url "https://github.com/waltarix/python-tabulate/releases/download/v0.9.0-custom-r2/tabulate-0.9.0.tar.gz"
  sha256 "f5c8bc48780a17933e60b042b0919f2b0c90c187413b1299cdabdebf4326b3fe"
  license "MIT"
  revision 1

  depends_on "python-setuptools" => :build
  depends_on "python@3.11" => [:build, :test]
  depends_on "python@3.12" => [:build, :test] # FIXME: should be runtime dependency
  depends_on "waltarix/customs/python-wcwidth"

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.match?(/^python@\d\.\d+$/) }
        .sort_by(&:version)
  end

  def install
    pythons.each do |python|
      python_exe = python.opt_libexec/"bin/python"
      system python_exe, "-m", "pip", "install", *std_pip_args, "."
    end
  end

  test do
    pythons.each do |python|
      python_exe = python.opt_libexec/"bin/python"
      system python_exe, "-c", "from tabulate import tabulate"
    end

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
