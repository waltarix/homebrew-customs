class LibtreeSitter < Formula
  desc "Parser generator tool and incremental parsing library"
  homepage "https://tree-sitter.github.io/"
  url "https://github.com/tree-sitter/tree-sitter/archive/refs/tags/v0.25.6.tar.gz"
  sha256 "ac6ed919c6d849e8553e246d5cd3fa22661f6c7b6497299264af433f3629957c"
  license "MIT"
  head "https://github.com/tree-sitter/tree-sitter.git", branch: "master"

  conflicts_with "tree-sitter", because: "both install a `tree-sitter` binary"

  resource "binary" do
    "0.25.6".tap do |v|
      if OS.linux?
        url "https://github.com/tree-sitter/tree-sitter/releases/download/v#{v}/tree-sitter-linux-x64.gz"
        sha256 "c300ea9f2ca368186ce1308793aaad650c3f6db78225257cbb5be961aeff4038"
      else
        if Hardware::CPU.arm?
          url "https://github.com/tree-sitter/tree-sitter/releases/download/v#{v}/tree-sitter-macos-arm64.gz"
          sha256 "4e6a8892b4b67eff13fc125ba8fc552d75ce02c1ed24bb634d3eb15f2d315356"
        else
          url "https://github.com/tree-sitter/tree-sitter/releases/download/v#{v}/tree-sitter-macos-x64.gz"
          sha256 "b8fccb0e74dca7ad8e403acb0992e983d20e89ad2e2e14245a1443b76ed52025"
        end
      end
    end
  end

  def install
    resource("binary").tap do |res|
      res.stage do
        Open3.popen3("gzip", "-dc", res.cached_download) do |_, stdout, _|
          (bin/"tree-sitter").tap do |f|
            f.write(stdout.read)
            chmod 0755, f
            system "strip", "-s", f
          end
        end
      end
    end

    ENV["HOMEBREW_OPTIMIZATION_LEVEL"] = "O3"
    ENV.append "CFLAGS", "-flto"
    ENV.append "CFLAGS", "-ffat-lto-objects"
    ENV.append "LDFLAGS", "-Wl,-s"

    system "make", "install", "AMALGAMATED=1", "PREFIX=#{prefix}"
  end

  test do
    (testpath/"test_program.c").write <<~C
      #include <stdio.h>
      #include <string.h>
      #include <tree_sitter/api.h>
      int main(int argc, char* argv[]) {
        TSParser *parser = ts_parser_new();
        if (parser == NULL) {
          return 1;
        }
        // Because we have no language libraries installed, we cannot
        // actually parse a string successfully. But, we can verify
        // that it can at least be attempted.
        const char *source_code = "empty";
        TSTree *tree = ts_parser_parse_string(
          parser,
          NULL,
          source_code,
          strlen(source_code)
        );
        if (tree == NULL) {
          printf("tree creation failed");
        }
        ts_tree_delete(tree);
        ts_parser_delete(parser);
        return 0;
      }
    C
    system ENV.cc, "test_program.c", "-L#{lib}", "-ltree-sitter", "-o", "test_program"
    assert_equal "tree creation failed", shell_output("./test_program")
  end
end
