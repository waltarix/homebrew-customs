require "language/go"

class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.15.4.tar.gz"
  sha256 "9e5a5e4c929df8172afde9dd9cb7bbefdae8f98fc4a24d40696ccb3da1483261"
  head "https://github.com/junegunn/fzf.git"
  revision 2

  bottle do
    cellar :any_skip_relocation
    sha256 "ed162fdedea0fb569c461d919e534f788cb1817686e2d9f17e0715e894725fc3" => :sierra
    sha256 "cf39542431519da33f09efc54e8aa68196a7757c5e4ad7cff333d0c5cef45087" => :el_capitan
    sha256 "9db881faf4d81dac5e0ffe5bacfbdbec8436c0bd3ab932ec32ced078e15a65a3" => :yosemite
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
index 700e667..806b772 100644
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
index e07eb3c..02ed7bc 100644
--- a/src/terminal.go
+++ b/src/terminal.go
@@ -530,7 +530,7 @@ func (t *Terminal) placeCursor() {
 func (t *Terminal) printPrompt() {
 	t.move(0, 0, true)
 	t.window.CPrint(C.ColPrompt, C.Bold, t.prompt)
-	t.window.CPrint(C.ColNormal, C.Bold, string(t.input))
+	t.window.CPrint(C.ColNormal, C.Normal, string(t.input))
 }
 
 func (t *Terminal) printInfo() {
@@ -630,7 +630,7 @@ func (t *Terminal) printItem(result *Result, i int, current bool) {
 		} else {
 			t.window.CPrint(C.ColCurrent, C.Bold, " ")
 		}
-		t.printHighlighted(result, C.Bold, C.ColCurrent, C.ColCurrentMatch, true)
+		t.printHighlighted(result, C.Normal, C.ColCurrent, C.ColCurrentMatch, true)
 	} else {
 		if selected {
 			t.window.CPrint(C.ColSelected, C.Bold, ">")
@@ -718,7 +718,7 @@ func (t *Terminal) printHighlighted(result *Result, attr C.Attr, col1 int, col2
 		maxe = util.Max(maxe, int(offset[1]))
 	}
 
-	offsets := result.colorOffsets(charOffsets, col2, attr, current)
+	offsets := result.colorOffsets(charOffsets, col2, C.Bold, current)
 	maxWidth := t.window.Width - 3
 	maxe = util.Constrain(maxe+util.Min(maxWidth/2-2, t.hscrollOff), 0, len(text))
 	if overflow(text, maxWidth) {
