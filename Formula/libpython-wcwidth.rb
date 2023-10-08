class LibpythonWcwidth < Formula
  desc "Pretty-print tabular data in Python"
  homepage "https://pypi.org/project/tabulate/"
  url "https://github.com/waltarix/python-wcwidth/archive/0.2.6-custom.tar.gz"
  version "0.2.6"
  sha256 "b094248eaf5203d5b1e98e58a2d4b70c8c46529ea6149d0f301415e03444f36b"
  license "MIT"

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
