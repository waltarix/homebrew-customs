require "language/go"

class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.15.5.tar.gz"
  sha256 "b9d3f6e56f538079ac1237c4d2ec260cbe6ad0cea1c214588187447ec3e44607"
  head "https://github.com/junegunn/fzf.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "18816c5565e187b7df3b1b8fea407398f042a34a9792b1889328ab14d48b3b78" => :sierra
    sha256 "1106c94fb17b606ff372e4fe105570ae39c7cd8eb84cf94daa3343f2aa5063ed" => :el_capitan
    sha256 "6ba3b315d3ecf180102138b4863a4386a6968da83ae496a008a9d25770c612e4" => :yosemite
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
    man1.install "man/man1/fzf.1", "man/man1/fzf-tmux.1"
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
diff --git a/src/curses/curses.go b/src/curses/curses.go
index 638a862..724b51b 100644
--- a/src/curses/curses.go
+++ b/src/curses/curses.go
@@ -24,6 +24,7 @@ import (
 )
 
 const (
+	Normal    = C.A_NORMAL
 	Bold      = C.A_BOLD
 	Dim       = C.A_DIM
 	Blink     = C.A_BLINK
diff --git a/src/terminal.go b/src/terminal.go
index 2abe62e..033d328 100644
--- a/src/terminal.go
+++ b/src/terminal.go
@@ -532,7 +532,7 @@ func (t *Terminal) placeCursor() {
 func (t *Terminal) printPrompt() {
 	t.move(0, 0, true)
 	t.window.CPrint(C.ColPrompt, C.Bold, t.prompt)
-	t.window.CPrint(C.ColNormal, C.Bold, string(t.input))
+	t.window.CPrint(C.ColNormal, C.Normal, string(t.input))
 }
 
 func (t *Terminal) printInfo() {
@@ -632,7 +632,7 @@ func (t *Terminal) printItem(result *Result, i int, current bool) {
 		} else {
 			t.window.CPrint(C.ColCurrent, C.Bold, " ")
 		}
-		t.printHighlighted(result, C.Bold, C.ColCurrent, C.ColCurrentMatch, true)
+		t.printHighlighted(result, C.Normal, C.ColCurrent, C.ColCurrentMatch, true)
 	} else {
 		if selected {
 			t.window.CPrint(C.ColSelected, C.Bold, ">")
@@ -720,7 +720,7 @@ func (t *Terminal) printHighlighted(result *Result, attr C.Attr, col1 int, col2
 		maxe = util.Max(maxe, int(offset[1]))
 	}
 
-	offsets := result.colorOffsets(charOffsets, t.theme, col2, attr, current)
+	offsets := result.colorOffsets(charOffsets, t.theme, col2, C.Bold, current)
 	maxWidth := t.window.Width - 3
 	maxe = util.Constrain(maxe+util.Min(maxWidth/2-2, t.hscrollOff), 0, len(text))
 	if overflow(text, maxWidth) {
