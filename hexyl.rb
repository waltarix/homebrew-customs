class Hexyl < Formula
  desc "Command-line hex viewer"
  homepage "https://github.com/sharkdp/hexyl"
  url "https://github.com/sharkdp/hexyl/archive/v0.7.0.tar.gz"
  sha256 "92aa86fc2b482d2d7abf07565ea3587767a9beb9135a307aadeba61cc84f4b34"

  bottle do
    root_url "https://gist.githubusercontent.com/waltarix/eacc34005669406dca03b51ff6af2617/raw/64fcae039fa401bd7cb66a1094ae847d7477a78f"
    cellar :any_skip_relocation
    sha256 "cb431f80f345c0cc67a29311954fa85f6573830e734c7c372eedd6e30dee0b53" => :catalina
    sha256 "cb431f80f345c0cc67a29311954fa85f6573830e734c7c372eedd6e30dee0b53" => :mojave
    sha256 "cb431f80f345c0cc67a29311954fa85f6573830e734c7c372eedd6e30dee0b53" => :high_sierra
  end

  depends_on "rustup-init" => :build

  patch :DATA

  def install
    Pathname.new(`eval echo ~$USER`.chomp).tap do |user_home|
      ENV.prepend_path "PATH", user_home/".cargo/bin"
      ENV["RUSTUP_HOME"] = user_home/".rustup"
    end

    system "cargo", "install", "--locked", "--root", prefix, "--path", "."
  end

  test do
    pdf = test_fixtures("test.pdf")
    output = shell_output("#{bin}/hexyl -n 100 #{pdf}")
    assert_match "00000000", output
  end
end

__END__
diff --git a/src/lib.rs b/src/lib.rs
index 08fd4d8..528b153 100644
--- a/src/lib.rs
+++ b/src/lib.rs
@@ -65,8 +65,8 @@ impl Byte {
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
