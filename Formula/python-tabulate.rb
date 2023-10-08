class PythonTabulate < Formula
  desc "Pretty-print tabular data in Python"
  homepage "https://github.com/astanin/python-tabulate"
  url "https://github.com/waltarix/python-tabulate/releases/download/v0.9.0-custom-r1/tabulate-0.9.0.tar.gz"
  sha256 "729256af87086e35d830cb033a072ced1ad835b40cc7a6ca92200f40379d267d"
  license "MIT"

  depends_on "python@3.10" => [:build, :test]
  depends_on "python@3.11" => [:build, :test]
  depends_on "python@3.12" => [:build, :test]
  depends_on "waltarix/customs/libpython-wcwidth"

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.match?(/^python@\d\.\d+$/) }
        .sort_by(&:version)
        .map { |f| f.opt_libexec/"bin/python" }
  end

  def install
    inreplace "pyproject.toml", /^dynamic .+$/, "version = \"#{version}\""

    pythons.each do |python|
      system python, "-m", "pip", "install", "--prefix=#{prefix}", "--no-deps", "."
    end
  end

  test do
    pythons.each do |python|
      system python, "-c", "from tabulate import tabulate"
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
