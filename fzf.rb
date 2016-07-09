require "language/go"

class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.13.2.tar.gz"
  sha256 "063c2e0e23944acead08e90a33ebce0d5d1c05b168571f56800b3b2ddf7c5ee9"
  head "https://github.com/junegunn/fzf.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "16df1a31d5e30a505ff67729597b0a0bfa6218b8fdc3a7ac6a3bcbe0d11486ed" => :el_capitan
    sha256 "77aadf34a0f4724dad5e6fcf91c9e863e859e4cf3f9c063c601d1b0bed4d67f4" => :yosemite
    sha256 "b2c75a7bae7781d33624e442561ff9203212e202cfa0c6694d8ff921db78ba2e" => :mavericks
  end

  def pour_bottle?
    false
  end

  patch :DATA

  depends_on "go" => :build

  go_resource "github.com/junegunn/go-shellwords" do
    url "https://github.com/junegunn/go-shellwords.git",
      :revision => "35d512af75e283aae4ca1fc3d44b159ed66189a4"
  end

  go_resource "github.com/junegunn/go-runewidth" do
    url "https://github.com/junegunn/go-runewidth.git",
      :revision => "63c378b851290989b19ca955468386485f118c65"
  end

  def install
    ENV["GOPATH"] = buildpath
    mkdir_p buildpath/"src/github.com/junegunn"
    ln_s buildpath, buildpath/"src/github.com/junegunn/fzf"
    Language::Go.stage_deps resources, buildpath/"src"

    cd buildpath/"src/fzf" do
      system "go", "build"
      bin.install "fzf"
    end

    prefix.install %w[install uninstall LICENSE]
    (prefix/"shell").install %w[bash zsh fish].map { |s| "shell/key-bindings.#{s}" }
    (prefix/"shell").install %w[bash zsh].map { |s| "shell/completion.#{s}" }
    (prefix/"plugin").install "plugin/fzf.vim"
    man1.install "man/man1/fzf.1"
    bin.install "bin/fzf-tmux"
  end

  def caveats; <<-EOS.undent
    To install useful keybindings and fuzzy completion:
      #{opt_prefix}/install

    To use fzf in Vim, add the following line to your .vimrc:
      set rtp+=#{opt_prefix}
    EOS
  end

  test do
    (testpath/"list").write %w[hello world].join($/)
    assert_equal "world", shell_output("cat #{testpath}/list | #{bin}/fzf -f wld").chomp
  end
end

__END__
diff --git a/src/terminal.go b/src/terminal.go
index ce10ee7..602aad7 100644
--- a/src/terminal.go
+++ b/src/terminal.go
@@ -504,7 +504,7 @@ func (t *Terminal) placeCursor() {
 func (t *Terminal) printPrompt() {
 	t.move(0, 0, true)
 	t.window.CPrint(C.ColPrompt, true, t.prompt)
-	t.window.CPrint(C.ColNormal, true, string(t.input))
+	t.window.CPrint(C.ColNormal, false, string(t.input))
 }
 
 func (t *Terminal) printInfo() {
@@ -604,7 +604,7 @@ func (t *Terminal) printItem(item *Item, i int, current bool) {
 		} else {
 			t.window.CPrint(C.ColCurrent, true, " ")
 		}
-		t.printHighlighted(item, true, C.ColCurrent, C.ColCurrentMatch, true)
+		t.printHighlighted(item, false, C.ColCurrent, C.ColCurrentMatch, true)
 	} else {
 		if selected {
 			t.window.CPrint(C.ColSelected, true, ">")
@@ -660,7 +660,7 @@ func (t *Terminal) printHighlighted(item *Item, bold bool, col1 int, col2 int, c
 	// Overflow
 	text := make([]rune, len(item.text))
 	copy(text, item.text)
-	offsets := item.colorOffsets(col2, bold, current)
+	offsets := item.colorOffsets(col2, true, current)
 	maxWidth := t.window.Width - 3
 	maxe = util.Constrain(maxe+util.Min(maxWidth/2-2, t.hscrollOff), 0, len(text))
 	fullWidth := displayWidth(text)
