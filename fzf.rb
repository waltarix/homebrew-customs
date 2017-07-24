class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.16.10.tar.gz"
  sha256 "a6b9d8abcba4239d30201cc7911e9c305a5cd750081ce5cd389f8e7425f4dc93"
  head "https://github.com/junegunn/fzf.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "21870f3a4c2a05bc4d2ea1df7d6a6df7617bd04d9265a7693c926b557ebfab16" => :sierra
    sha256 "0e85372474f88cbc8fc09972891267c5bb63ccf96392ae15451ba585571de1c0" => :el_capitan
    sha256 "110922fde8fb9de4adaf4591ce2aa50e8c98691590694af5fc08f18515adc166" => :yosemite
  end

  depends_on "glide" => :build
  depends_on "go" => :build

  def pour_bottle?
    false
  end

  patch :DATA

  def install
    ENV["GLIDE_HOME"] = buildpath/"glide_home"
    ENV["GOPATH"] = buildpath
    (buildpath/"src/github.com/junegunn").mkpath
    ln_s buildpath, buildpath/"src/github.com/junegunn/fzf"
    system "glide", "install"

    inreplace buildpath/"vendor/github.com/mattn/go-runewidth/runewidth.go",
      "{0x2580, 0x258F}, ", ""

    system "go", "build", "-o", bin/"fzf", "-ldflags", "-X main.revision=brew"

    prefix.install "install", "uninstall"
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
    (testpath/"list").write %w[hello world].join($INPUT_RECORD_SEPARATOR)
    assert_equal "world", shell_output("cat #{testpath}/list | #{bin}/fzf -f wld").chomp
  end
end

__END__
diff --git a/src/result.go b/src/result.go
index 2df101b..038d311 100644
--- a/src/result.go
+++ b/src/result.go
@@ -95,7 +95,7 @@ func (result *Result) colorOffsets(matchOffsets []Offset, theme *tui.ColorTheme,
 	if len(itemColors) == 0 {
 		var offsets []colorOffset
 		for _, off := range matchOffsets {
-			offsets = append(offsets, colorOffset{offset: [2]int32{off[0], off[1]}, color: color, attr: attr})
+			offsets = append(offsets, colorOffset{offset: [2]int32{off[0], off[1]}, color: color, attr: attr | tui.Bold})
 		}
 		return offsets
 	}
@@ -139,7 +139,7 @@ func (result *Result) colorOffsets(matchOffsets []Offset, theme *tui.ColorTheme,
 		if curr != 0 && idx > start {
 			if curr == -1 {
 				colors = append(colors, colorOffset{
-					offset: [2]int32{int32(start), int32(idx)}, color: color, attr: attr})
+					offset: [2]int32{int32(start), int32(idx)}, color: color, attr: attr | tui.Bold})
 			} else {
 				ansi := itemColors[curr-1]
 				fg := ansi.color.fg
diff --git a/src/terminal.go b/src/terminal.go
index d6d2155..cfef7af 100644
--- a/src/terminal.go
+++ b/src/terminal.go
@@ -645,7 +645,7 @@ func (t *Terminal) placeCursor() {
 func (t *Terminal) printPrompt() {
 	t.move(0, 0, true)
 	t.window.CPrint(tui.ColPrompt, t.strong, t.prompt)
-	t.window.CPrint(tui.ColNormal, t.strong, string(t.input))
+	t.window.CPrint(tui.ColNormal, tui.AttrRegular, string(t.input))
 }
 
 func (t *Terminal) printInfo() {
@@ -779,7 +779,7 @@ func (t *Terminal) printItem(result Result, line int, i int, current bool) {
 		} else {
 			t.window.CPrint(tui.ColCurrent, t.strong, " ")
 		}
-		newLine.width = t.printHighlighted(result, t.strong, tui.ColCurrent, tui.ColCurrentMatch, true, true)
+		newLine.width = t.printHighlighted(result, tui.AttrRegular, tui.ColCurrent, tui.ColCurrentMatch, true, true)
 	} else {
 		if selected {
 			t.window.CPrint(tui.ColSelected, t.strong, ">")
diff --git a/src/tui/light.go b/src/tui/light.go
index a7d12f3..72b9428 100644
--- a/src/tui/light.go
+++ b/src/tui/light.go
@@ -649,22 +649,22 @@ func (w *LightWindow) drawBorder() {
 
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
