require "language/go"

class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.16.7.tar.gz"
  sha256 "9676664e02393d19dd0f0a1ae4cf5d20e3fffcba666a0cffc40ff6c590c67760"
  head "https://github.com/junegunn/fzf.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "2f259ed32511d67e38a21b589ce65f306d9dfca4713fe3363af9808a8c4cdf11" => :sierra
    sha256 "3a9cf16aeb4cfda77b45fe55057267420e8b39cb5155138dce71bc62106b8ab8" => :el_capitan
    sha256 "364aecd801beeee28cae20d017b1081e2ef3f15b289c42fda4b71cc30ef34890" => :yosemite
  end

  def pour_bottle?
    false
  end

  patch :DATA

  depends_on "go" => :build

  go_resource "github.com/junegunn/go-isatty" do
    url "https://github.com/junegunn/go-isatty.git",
        :revision => "66b8e73f3f5cda9f96b69efd03dd3d7fc4a5cdb8"
  end

  go_resource "github.com/junegunn/go-runewidth" do
    url "https://github.com/junegunn/go-runewidth.git",
        :revision => "14207d285c6c197daabb5c9793d63e7af9ab2d50"
  end

  go_resource "github.com/junegunn/go-shellwords" do
    url "https://github.com/junegunn/go-shellwords.git",
        :revision => "33bd8f1ebe16d6e5eb688cc885749a63059e9167"
  end

  go_resource "golang.org/x/crypto" do
    url "https://go.googlesource.com/crypto.git",
        :revision => "453249f01cfeb54c3d549ddb75ff152ca243f9d8"
  end

  def install
    ENV["GOPATH"] = buildpath
    mkdir_p buildpath/"src/github.com/junegunn"
    ln_s buildpath, buildpath/"src/github.com/junegunn/fzf"
    Language::Go.stage_deps resources, buildpath/"src"

    inreplace buildpath/"src/github.com/junegunn/go-runewidth/runewidth.go",
      "{0x2580, 0x258F}, ", ""

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
diff --git a/src/result.go b/src/result.go
index e071a9e..23ef4f8 100644
--- a/src/result.go
+++ b/src/result.go
@@ -101,7 +101,7 @@ func (result *Result) colorOffsets(matchOffsets []Offset, theme *tui.ColorTheme,
 	if len(itemColors) == 0 {
 		var offsets []colorOffset
 		for _, off := range matchOffsets {
-			offsets = append(offsets, colorOffset{offset: [2]int32{off[0], off[1]}, color: color, attr: attr})
+			offsets = append(offsets, colorOffset{offset: [2]int32{off[0], off[1]}, color: color, attr: attr | tui.Bold})
 		}
 		return offsets
 	}
@@ -145,7 +145,7 @@ func (result *Result) colorOffsets(matchOffsets []Offset, theme *tui.ColorTheme,
 		if curr != 0 && idx > start {
 			if curr == -1 {
 				colors = append(colors, colorOffset{
-					offset: [2]int32{int32(start), int32(idx)}, color: color, attr: attr})
+					offset: [2]int32{int32(start), int32(idx)}, color: color, attr: attr | tui.Bold})
 			} else {
 				ansi := itemColors[curr-1]
 				fg := ansi.color.fg
diff --git a/src/terminal.go b/src/terminal.go
index 5aab6cd..0f33907 100644
--- a/src/terminal.go
+++ b/src/terminal.go
@@ -638,7 +638,7 @@ func (t *Terminal) placeCursor() {
 func (t *Terminal) printPrompt() {
 	t.move(0, 0, true)
 	t.window.CPrint(tui.ColPrompt, t.strong, t.prompt)
-	t.window.CPrint(tui.ColNormal, t.strong, string(t.input))
+	t.window.CPrint(tui.ColNormal, tui.AttrRegular, string(t.input))
 }
 
 func (t *Terminal) printInfo() {
@@ -769,7 +769,7 @@ func (t *Terminal) printItem(result *Result, line int, i int, current bool) {
 		} else {
 			t.window.CPrint(tui.ColCurrent, t.strong, " ")
 		}
-		newLine.width = t.printHighlighted(result, t.strong, tui.ColCurrent, tui.ColCurrentMatch, true, true)
+		newLine.width = t.printHighlighted(result, tui.AttrRegular, tui.ColCurrent, tui.ColCurrentMatch, true, true)
 	} else {
 		if selected {
 			t.window.CPrint(tui.ColSelected, t.strong, ">")
diff --git a/src/tui/light.go b/src/tui/light.go
index be6950c..ba465fa 100644
--- a/src/tui/light.go
+++ b/src/tui/light.go
@@ -640,22 +640,22 @@ func (w *LightWindow) drawBorder() {
 
 func (w *LightWindow) drawBorderHorizontal() {
 	w.Move(0, 0)
-	w.CPrint(ColBorder, AttrRegular, repeat("─", w.width))
+	w.CPrint(ColBorder, AttrRegular, repeat("-", w.width))
 	w.Move(w.height-1, 0)
-	w.CPrint(ColBorder, AttrRegular, repeat("─", w.width))
+	w.CPrint(ColBorder, AttrRegular, repeat("-", w.width))
 }
 
 func (w *LightWindow) drawBorderAround() {
 	w.Move(0, 0)
-	w.CPrint(ColBorder, AttrRegular, "┌"+repeat("─", w.width-2)+"┐")
+	w.CPrint(ColBorder, AttrRegular, "+"+repeat("-", w.width-2)+"+")
 	for y := 1; y < w.height-1; y++ {
 		w.Move(y, 0)
-		w.CPrint(ColBorder, AttrRegular, "│")
+		w.CPrint(ColBorder, AttrRegular, "|")
 		w.cprint2(colDefault, w.bg, AttrRegular, repeat(" ", w.width-2))
-		w.CPrint(ColBorder, AttrRegular, "│")
+		w.CPrint(ColBorder, AttrRegular, "|")
 	}
 	w.Move(w.height-1, 0)
-	w.CPrint(ColBorder, AttrRegular, "└"+repeat("─", w.width-2)+"┘")
+	w.CPrint(ColBorder, AttrRegular, "+"+repeat("-", w.width-2)+"+")
 }
 
 func (w *LightWindow) csi(code string) {
