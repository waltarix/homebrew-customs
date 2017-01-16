require "language/go"

class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.16.1.tar.gz"
  sha256 "f8a05e9e72f6e2b87bec63809843afa77fd89067722407f6f9a86299c6215fce"
  head "https://github.com/junegunn/fzf.git"

  bottle do
    sha256 "6522e26e982f91cadb5b35cffc0e8a7b50f44404ff09f11170ca988ac8c3b573" => :sierra
    sha256 "a75f5ff839206c4c3c3986657f31245821e17d3955014a38187f7867cc8bb3d4" => :el_capitan
    sha256 "337ba7152491e08358fd12d475f7b328c24a36348bff7275fdb59ad5032240e1" => :yosemite
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
        :revision => "63c378b851290989b19ca955468386485f118c65"
  end

  go_resource "github.com/junegunn/go-shellwords" do
    url "https://github.com/junegunn/go-shellwords.git",
        :revision => "35d512af75e283aae4ca1fc3d44b159ed66189a4"
  end

  go_resource "golang.org/x/crypto" do
    url "https://go.googlesource.com/crypto.git",
        :revision => "abc5fa7ad02123a41f02bf1391c9760f7586e608"
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
diff --git a/src/terminal.go b/src/terminal.go
index 2378984..355a82e 100644
--- a/src/terminal.go
+++ b/src/terminal.go
@@ -584,7 +584,7 @@ func (t *Terminal) placeCursor() {
 func (t *Terminal) printPrompt() {
 	t.move(0, 0, true)
 	t.window.CPrint(tui.ColPrompt, t.strong, t.prompt)
-	t.window.CPrint(tui.ColNormal, t.strong, string(t.input))
+	t.window.CPrint(tui.ColNormal, tui.AttrRegular, string(t.input))
 }
 
 func (t *Terminal) printInfo() {
@@ -704,7 +704,7 @@ func (t *Terminal) printItem(result *Result, line int, i int, current bool) {
 		} else {
 			t.window.CPrint(tui.ColCurrent, t.strong, " ")
 		}
-		newLine.width = t.printHighlighted(result, t.strong, tui.ColCurrent, tui.ColCurrentMatch, true, true)
+		newLine.width = t.printHighlighted(result, tui.AttrRegular, tui.ColCurrent, tui.ColCurrentMatch, true, true)
 	} else {
 		if selected {
 			t.window.CPrint(tui.ColSelected, t.strong, ">")
@@ -792,7 +792,7 @@ func (t *Terminal) printHighlighted(result *Result, attr tui.Attr, col1 tui.Colo
 		maxe = util.Max(maxe, int(offset[1]))
 	}
 
-	offsets := result.colorOffsets(charOffsets, t.theme, col2, attr, current)
+	offsets := result.colorOffsets(charOffsets, t.theme, col2, tui.Bold, current)
 	maxWidth := t.window.Width() - 3
 	maxe = util.Constrain(maxe+util.Min(maxWidth/2-2, t.hscrollOff), 0, len(text))
 	displayWidth := t.displayWidthWithLimit(text, 0, maxWidth)
