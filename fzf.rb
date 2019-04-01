class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.18.0.tar.gz"
  sha256 "5406d181785ea17b007544082b972ae004b62fb19cdb41f25e265ea3cc8c2d9d"
  head "https://github.com/junegunn/fzf.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "0f77b9b22f32f76493cdac585106b01502c6583908e0b7b6ea70ab023b5c1c2e" => :mojave
    sha256 "6f457b819868a5515d2154eae02eb8fdbc154a1815e96729ed62f68395672f38" => :high_sierra
    sha256 "4e352d29fefafd0c7af1c98ebf97276afbf4df844444aa98e4e1fa32d338e281" => :sierra
  end

  depends_on "go" => :build

  def pour_bottle?
    false
  end

  patch :DATA

  def install
    gopath = buildpath/"go_cache"
    ENV["GOPATH"] = gopath
    system "go", "mod", "tidy"
    runewidth_dir = gopath/"pkg/mod/github.com/mattn/go-runewidth@v0.0.0-20170201023540-14207d285c6c"
    chmod 0755, runewidth_dir
    inreplace runewidth_dir/"runewidth.go", "{0x2580, 0x258F}, ", ""

    system "go", "build", "-o", bin/"fzf", "-ldflags", "-X main.revision=brew"

    prefix.install "install", "uninstall"
    (prefix/"shell").install %w[bash zsh fish].map { |s| "shell/key-bindings.#{s}" }
    (prefix/"shell").install %w[bash zsh].map { |s| "shell/completion.#{s}" }
    (prefix/"plugin").install "plugin/fzf.vim"
    man1.install "man/man1/fzf.1", "man/man1/fzf-tmux.1"
    bin.install "bin/fzf-tmux"
  end

  def caveats; <<~EOS
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
index 289d83a..6b7a8c5 100644
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
index 06623b2..64bce18 100644
--- a/src/terminal.go
+++ b/src/terminal.go
@@ -707,8 +707,8 @@ func (t *Terminal) printPrompt() {
 	t.window.CPrint(tui.ColPrompt, t.strong, t.prompt)
 
 	before, after := t.updatePromptOffset()
-	t.window.CPrint(tui.ColNormal, t.strong, string(before))
-	t.window.CPrint(tui.ColNormal, t.strong, string(after))
+	t.window.CPrint(tui.ColNormal, tui.AttrRegular, string(before))
+	t.window.CPrint(tui.ColNormal, tui.AttrRegular, string(after))
 }
 
 func (t *Terminal) printInfo() {
@@ -845,7 +845,7 @@ func (t *Terminal) printItem(result Result, line int, i int, current bool) {
 		} else {
 			t.window.CPrint(tui.ColCurrentSelected, t.strong, " ")
 		}
-		newLine.width = t.printHighlighted(result, t.strong, tui.ColCurrent, tui.ColCurrentMatch, true, true)
+		newLine.width = t.printHighlighted(result, tui.AttrRegular, tui.ColCurrent, tui.ColCurrentMatch, true, true)
 	} else {
 		t.window.CPrint(tui.ColCursor, t.strong, label)
 		if selected {
