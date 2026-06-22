class TreeSitter < Formula
  desc "Parser generator tool and incremental parsing library"
  homepage "https://tree-sitter.github.io/"
  url "https://github.com/tree-sitter/tree-sitter/archive/refs/tags/v0.26.9.tar.gz"
  sha256 "8e14780500933f43d86662fcaa1b0ce99ebe9c220f4680bc929dce09a0e0cfc6"
  license "MIT"
  head "https://github.com/tree-sitter/tree-sitter.git", branch: "master"

  depends_on "tree-sitter-cli" if OS.mac?

  if OS.linux?
    resource "binary" do
      "0.26.9".tap do |v|
        url "https://github.com/tree-sitter/tree-sitter/releases/download/v#{v}/tree-sitter-linux-x64.gz"
        sha256 "9ce82137caa65864e7ca8b869fd391cef88c9bd2a01c4371b9c4dd26c2585efb"
      end
    end
  end

  def install
    ENV["HOMEBREW_OPTIMIZATION_LEVEL"] = "O3"
    flag_key = OS.mac? ? "LTO_FLAGS" : "CFLAGS"
    ENV.append flag_key, "-flto"
    ENV.append flag_key, "-ffat-lto-objects"
    ENV.append "LDFLAGS", "-Wl,-s"

    system "make", "install", "AMALGAMATED=1", "PREFIX=#{prefix}"

    if OS.linux?
      resource("binary").tap do |res|
        res.stage do
          libexec.mkpath
          Open3.popen3("gzip", "-dc", res.cached_download) do |_, stdout, _|
            (libexec/"tree-sitter").tap do |f|
              f.write(stdout.read)
              chmod 0755, f
              system "strip", "-s", f
            end
          end
        end
      end

      library_path = [
        Formula["glibc"].opt_lib,
        Formula["gcc"].opt_lib/"gcc/current",
        HOMEBREW_PREFIX/"lib",
      ].join(":")
      args = %W[
        --library-path
        "#{library_path}"
        "#{libexec/"tree-sitter"}"
      ]
      (bin/"tree-sitter").write_env_script(
        Formula["glibc"].opt_lib/"ld-linux-x86-64.so.2",
        args.join(" "),
        {},
      )
    end
  end

  test do
    if OS.linux?
      assert_equal "tree-sitter #{version}", shell_output("#{bin}/tree-sitter --version").chomp
    end

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
