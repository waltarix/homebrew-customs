require 'formula'

def pkg_name; 'GrowlNotify.pkg'; end
def bin_payload; 'growlnotify.pkg/Payload'; end
def man_payload; 'growlnotify-1.pkg/Payload'; end

class GrowlnotifyPkgDownloadStrategy < CurlDownloadStrategy
  def stage
    safe_system '/usr/bin/unzip', @tarball_path
    safe_system '/usr/bin/xar', '-xf', pkg_name, bin_payload
    safe_system '/usr/bin/xar', '-xf', pkg_name, man_payload

    # extract
    system "cat #{bin_payload} | gzip -d - | cpio -id" # => growlnotify
    system "cat #{man_payload} | gzip -d - | cpio -id" # => growlnotify.1

    chdir
  end
end

class Growlnotify < Formula
  url 'http://growl.cachefly.net/GrowlNotify-2.0.zip', :using => GrowlnotifyPkgDownloadStrategy
  sha1 'efd54dec2623f57fcbbba54050206d70bc7746dd'
  version '2.0'
  homepage 'http://growl.info/extras.php'

  def install
    bin.install 'growlnotify'
    man1.install gzip('growlnotify.1')
  end
end
