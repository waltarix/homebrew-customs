class Envsubst < Formula
  desc "Substitutes environment variables in shell format strings"
  homepage "https://www.gnu.org/software/gettext/"
  url "file:///dev/null"
  version "0.19.8.1"
  sha256 "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

  depends_on "gettext"

  def install
    cp Formula["gettext"].opt_bin/"envsubst", "."
    bin.install "envsubst"
  end

  test do
    system bin/"envsubst", "--version"
  end
end
