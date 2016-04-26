class WcwidthCjk < Formula
  homepage 'https://github.com/fumiyas/wcwidth-cjk'
  url 'https://github.com/fumiyas/wcwidth-cjk.git'
  version '0.1'

  depends_on 'libtool' => :build
  depends_on 'automake' => :build
  depends_on 'autoconf' => :build

  def install
    system "autoreconf", "-vfi"

    system "./configure", "--prefix=#{prefix}"

    system "make"
    system "make", "install"
  end
end
