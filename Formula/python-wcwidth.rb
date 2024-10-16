class PythonWcwidth < Formula
  desc "Python library that measures the width of unicode strings rendered to a terminal"
  homepage "https://github.com/jquast/wcwidth"
  url "https://github.com/waltarix/python-wcwidth/archive/0.2.13-custom.tar.gz"
  version "0.2.13"
  sha256 "62c676a02b9da3afc704b5409f5d5006f8fa9d7ea12dc9ac6308cac67fb3337c"
  license "MIT"
  revision 1

  depends_on "python@3.13"

  def python3
    "python3.13"
  end

  def install
    system python3, "-m", "pip", "install", *std_pip_args(build_isolation: true), "."
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
