class UnzipIconv < Formula
  desc "Extraction utility for .zip compressed archives"
  homepage "http://www.info-zip.org/pub/infozip/UnZip.html"
  url "https://downloads.sourceforge.net/project/infozip/UnZip%206.x%20%28latest%29/UnZip%206.0/unzip60.tar.gz"
  version "6.0"
  sha256 "036d96991646d0449ed0aa952e4fbe21b476ce994abc276e49d30e686708bd37"
  revision 2

  [
    { url: "https://bugzilla.redhat.com/attachment.cgi?id=990132",
      sha256: "1333a0d14e8f59c3a114764bf008ae489d386fd561130a60c1c7f2f4c9386b9b" },
    { url: "https://bugzilla.redhat.com/attachment.cgi?id=969621",
      sha256: "1a1390390402e674ef7b143705ade0e9aa082131bb9686e95fb7985310def885",
      strip: 0 },
    { url: "https://bugzilla.redhat.com/attachment.cgi?id=969625",
      sha256: "04e72b17f46bc320fff871f2b99f48dca17befceac83a7caca719bc20dae6268",
      strip: 0 },
    { url: "https://bugzilla.redhat.com/attachment.cgi?id=990649",
      sha256: "c9a863e570bdaf2637c43bf1bba3d97808a1b0504d85418f6a8550ac286788f2" },
    { url: "https://projects.archlinux.org/svntogit/packages.git/plain/trunk/overflow-fsize.patch?h=packages/unzip&id=15e9a8c67463aaf62a718c6e74b1c972de654346",
      sha256: "e2a10fa494c39fb3f311d0f2d7db775bdecbc8d5b9d298c7bd035ace1f1713d5" },
    { url: "http://www.conostix.com/pub/adv/06-unzip60-alt-iconv-utf8_CVE-2015-1315.patch",
      sha256: "e64c9ddb38c2e7d08bdb80c597f32ee960e18fbe8cb982e444b1ece03ac95cec" },
    { url: "https://bugzilla.redhat.com/attachment.cgi?id=1073339",
      sha256: "fc6d36383ba9ca35e888912e5f8fd5178ae7e987c78a25816c2c0b60c3b377ba" },
    { url: "https://aur.archlinux.org/cgit/aur.git/snapshot/unzip-iconv.tar.gz",
      sha256: "69fca31a1df97befb3d2e047b034d2308089c30fdd57e5eda1f03833888b6759",
      apply: ["CVE-2015-7696+CVE-2015-7697_pt2.patch"] },
  ].each do |resource|
    patch "p#{resource[:strip] || 1}".to_sym do
      url resource[:url]
      sha256 resource[:sha256]
      apply *Array(resource[:apply]) if resource[:apply]
    end
  end

  def install
    system "make", "LFLAGS1=-liconv", "-f", "unix/Makefile",
      "CC=#{ENV.cc}",
      "LOC=-DLARGE_FILE_SUPPORT",
      "D_USE_BZ2=-DUSE_BZIP2",
      "L_BZ2=-lbz2",
      "macosx"
    system "make", "prefix=#{prefix}", "MANDIR=#{man1}", "install"

    [bin, man1].each do |path|
      path.children.each do |f|
        f.rename path/"i#{f.basename}"
      end
    end
  end

  def caveats; <<-EOS.undent
    All commands have been installed with the prefix 'i'.
    EOS
  end

  test do
    system "#{bin}/iunzip", "--help"
  end
end
