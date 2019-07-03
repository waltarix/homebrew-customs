class Hexyl < Formula
  desc "Command-line hex viewer"
  homepage "https://github.com/sharkdp/hexyl"
  url "https://github.com/sharkdp/hexyl/archive/v0.5.1.tar.gz"
  sha256 "9c12bc6377d1efedc4a1731547448f7eb6ed17ee1c267aad9a35995b42091163"

  bottle do
    cellar :any_skip_relocation
    sha256 "2ea951a75e72e97075b3d4db45edbfc6cbb27b67c4655fcd1483ce6ad2c4165d" => :mojave
    sha256 "52d0981ef2edc478f11e8c66a959f2868c0ee7e20a3178064ec289dfaa71e397" => :high_sierra
    sha256 "688108b44f0fb529f1085a1e7416d445b6b6c12885a9a941727c950233f8b6eb" => :sierra
  end

  depends_on "rust" => :build

  def pour_bottle?
    false
  end

  patch :DATA

  def install
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
