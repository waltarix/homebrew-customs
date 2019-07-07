class Hexyl < Formula
  desc "Command-line hex viewer"
  homepage "https://github.com/sharkdp/hexyl"
  url "https://github.com/sharkdp/hexyl/archive/v0.5.1.tar.gz"
  sha256 "9c12bc6377d1efedc4a1731547448f7eb6ed17ee1c267aad9a35995b42091163"

  bottle do
    root_url "https://gist.githubusercontent.com/waltarix/eacc34005669406dca03b51ff6af2617/raw/983a779dc43a4cb55eb322e8766b24515598870e"
    cellar :any_skip_relocation
    sha256 "2f7f792960f2ee0cc84bb42f73560452374b3ebcf7949dcb2119d01e12ac025d" => :mojave
    sha256 "2f7f792960f2ee0cc84bb42f73560452374b3ebcf7949dcb2119d01e12ac025d" => :high_sierra
  end

  depends_on "rustup-init" => :build

  patch :DATA

  def install
    Pathname.new(`eval echo ~$USER`.chomp).tap do |user_home|
      ENV.prepend_path "PATH", user_home/".cargo/bin"
      ENV["RUSTUP_HOME"] = user_home/".rustup"
    end

    system "cargo", "install", "--root", prefix, "--path", "."
  end

  test do
    pdf = test_fixtures("test.pdf")
    output = shell_output("#{bin}/hexyl -n 100 #{pdf}")
    assert_match "00000000", output
  end
end

__END__
diff --git a/src/main.rs b/src/main.rs
index ecfa444..b974230 100644
--- a/src/main.rs
+++ b/src/main.rs
@@ -77,8 +77,8 @@ impl Byte {
             AsciiPrintable => self.0 as char,
             AsciiWhitespace if self.0 == 0x20 => ' ',
             AsciiWhitespace => '_',
-            AsciiOther => '•',
-            NonAscii => '×',
+            AsciiOther => '✳',
+            NonAscii => '✖',
         }
     }
 }
