class LibpythonWcwidth < Formula
  desc "Pretty-print tabular data in Python"
  homepage "https://pypi.org/project/tabulate/"
  url "https://github.com/waltarix/python-wcwidth/archive/0.2.8-custom-r1.tar.gz"
  version "0.2.8"
  sha256 "59ac8d05e43a2721511f64aa92d3c9cb7b92109740191f5e6712314ca877cd95"
  license "MIT"
  revision 1

  depends_on "python@3.10" => [:build, :test]
  depends_on "python@3.11" => [:build, :test]
  depends_on "python@3.12" => [:build, :test]

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.match?(/^python@\d\.\d+$/) }
        .sort_by(&:version)
        .map { |f| f.opt_libexec/"bin/python" }
  end

  def install
    pythons.each do |python|
      system python, "-m", "pip", "install", "--prefix=#{prefix}", "--no-deps", "."
    end
  end

  test do
    script = <<~EOS
      from wcwidth import wcswidth
      print([wcswidth('☆'), wcswidth('🇫🇮'), wcswidth('├┼┤')])
    EOS
    pythons.each do |python|
      assert_equal "[2, 2, 3]\n", pipe_output(python, script, 0)
    end
  end
end
