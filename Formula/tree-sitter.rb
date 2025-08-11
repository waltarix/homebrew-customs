class TreeSitter < Formula
  desc "Parser generator tool and incremental parsing library"
  homepage "https://tree-sitter.github.io/"
  url "https://github.com/tree-sitter/tree-sitter/archive/refs/tags/v0.25.8.tar.gz"
  sha256 "178b575244d967f4920a4642408dc4edf6de96948d37d7f06e5b78acee9c0b4e"
  license "MIT"
  revision 1
  head "https://github.com/tree-sitter/tree-sitter.git", branch: "master"

  depends_on "tree-sitter-cli" if OS.mac?

  if OS.linux?
    resource "binary" do
      "0.25.8".tap do |v|
        url "https://github.com/tree-sitter/tree-sitter/releases/download/v#{v}/tree-sitter-linux-x64.gz"
        sha256 "c9d46697e3e5ae6900a39ad4483667d2ba14c8ffb12c3f863bcf82a9564ee19f"
      end
    end
  end

  def install
    if OS.linux?
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
    end

    ENV["HOMEBREW_OPTIMIZATION_LEVEL"] = "O3"
    flag_key = OS.mac? ? "LTO_FLAGS" : "CFLAGS"
    ENV.append flag_key, "-flto"
    ENV.append flag_key, "-ffat-lto-objects"
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
