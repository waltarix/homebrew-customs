require "language/go"

class Fzf < Formula
  desc "Command-line fuzzy finder written in Go"
  homepage "https://github.com/junegunn/fzf"
  url "https://github.com/junegunn/fzf/archive/0.12.2.tar.gz"
  sha256 "f2095c1c076774a9a9913b0517f562205785c8b105570a5a719cf0ac8d604368"
  head "https://github.com/junegunn/fzf.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "c3dc9a9a3b80d8223b4d28837b91f0530694be19569d5ce4942a86b787e2dc90" => :el_capitan
    sha256 "06c9dd92f10c1032957c2ca881bd05edf63f36a6e85fb97b5bfe68ab04f7c4b8" => :yosemite
    sha256 "99fed60f204b4a49425f3fdc613927e9630d0faaeb18a5ea6e44b4943a89369c" => :mavericks
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
index 764459f..9446d79 100644
--- a/src/terminal.go
+++ b/src/terminal.go
@@ -402,7 +402,7 @@ func (t *Terminal) placeCursor() {
 func (t *Terminal) printPrompt() {
 	t.move(0, 0, true)
 	C.CPrint(C.ColPrompt, true, t.prompt)
-	C.CPrint(C.ColNormal, true, string(t.input))
+	C.CPrint(C.ColNormal, false, string(t.input))
 }
 
 func (t *Terminal) printInfo() {
@@ -497,7 +497,7 @@ func (t *Terminal) printItem(item *Item, current bool) {
 		} else {
 			C.CPrint(C.ColCurrent, true, " ")
 		}
-		t.printHighlighted(item, true, C.ColCurrent, C.ColCurrentMatch, true)
+		t.printHighlighted(item, false, C.ColCurrent, C.ColCurrentMatch, true)
 	} else {
 		C.CPrint(C.ColCursor, true, " ")
 		if selected {
@@ -556,7 +556,7 @@ func (t *Terminal) printHighlighted(item *Item, bold bool, col1 int, col2 int, c
 	// Overflow
 	text := make([]rune, len(item.text))
 	copy(text, item.text)
-	offsets := item.colorOffsets(col2, bold, current)
+	offsets := item.colorOffsets(col2, true, current)
 	maxWidth := C.MaxX() - 3 - t.marginInt[1] - t.marginInt[3]
 	fullWidth := displayWidth(text)
 	if fullWidth > maxWidth {
