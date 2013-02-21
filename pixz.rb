require 'formula'

class Pixz < Formula
  homepage 'https://github.com/vasi/pixz'
  url 'http://downloads.sourceforge.net/pixz/pixz-1.0.2.tgz'
  version '1.0.2'
  sha1 '953b2b55504ba349f1e7e47bdfcd4165ba206827'

  option 'without-man-pages', 'Build without manpages'

  depends_on 'xz'
  depends_on 'libarchive'
  depends_on 'asciidoc' => :build unless build.include? 'without-man-pages'

  def install
    system 'make'
    bin.install 'pixz'

    unless build.include? 'without-man-pages'
      ENV['XML_CATALOG_FILES'] = "#{HOMEBREW_PREFIX}/etc/xml/catalog"
      system 'make pixz.1'
      man1.install gzip('pixz.1')
    end
  end

  def test
    system "#{bin}/pixz", "-i", "#{bin}/pixz", "-o", "/dev/null"
  end
end
