class Pspg < Formula
  desc "Unix pager optimized for psql"
  homepage "https://github.com/okbob/pspg"
  url "https://github.com/okbob/pspg/archive/refs/tags/5.8.14.tar.gz"
  sha256 "9ff44945fdf08b99468808ff67c903f62205583743b6b45921dc6b366aa5e243"
  license "BSD-2-Clause"
  head "https://github.com/okbob/pspg.git", branch: "master"

  depends_on "pkgconf" => :build
  depends_on "libpq"
  depends_on "ncurses"
  depends_on "readline"

  resource "wcwidth9.h" do
    url "https://github.com/waltarix/localedata/releases/download/17.0.0/wcwidth9.h"
    sha256 "ea17af165beb85568f60bc68fc358972d442ffd3bdc73a9a8d8e5659216da86c"
  end

  patch :DATA if OS.mac?

  def install
    ENV["HOMEBREW_OPTIMIZATION_LEVEL"] = "O3"
    flag_key = OS.mac? ? "LTO_FLAGS" : "CFLAGS"
    ENV.append flag_key, "-flto"
    ENV.append flag_key, "-ffat-lto-objects"
    ENV.append "LDFLAGS", "-Wl,-s"

    resource("wcwidth9.h").stage(buildpath/"src")
    inreplace "src/unicode.c", /(?<=^#include <string\.h>)/, %(\n#include "wcwidth9.h")
    inreplace "src/unicode.c", /(?<=return )ucs_wcwidth/, "wcwidth9"

    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}",
                          "--with-ncursesw"
    system "make", "install"

    if OS.mac?
      (libexec/"bin").install bin/"pspg"

      system "make", "-f", "Makefile.interpose"
      (libexec/"lib").install "libwcwidth_interpose.dylib"
      (bin/"pspg").write_env_script libexec/"bin/pspg",
                                    DYLD_INSERT_LIBRARIES: libexec/"lib/libwcwidth_interpose.dylib"
    end
  end

  def caveats
    <<~EOS
      Add the following line to your psql profile (e.g. ~/.psqlrc)
        \\setenv PAGER pspg
        \\pset border 2
        \\pset linestyle unicode
    EOS
  end

  test do
    assert_match "pspg-#{version}", shell_output("#{bin}/pspg --version")
  end
end

__END__
diff --git a/Makefile.interpose b/Makefile.interpose
new file mode 100644
index 0000000..84f94a0
--- /dev/null
+++ b/Makefile.interpose
@@ -0,0 +1,135 @@
+# Makefile for wcwidth interposition library
+# This library can be used to override wcwidth() calls in ncurses applications
+#
+# Build:
+#   make -f Makefile.interpose
+#
+# Usage:
+#   DYLD_INSERT_LIBRARIES=./libwcwidth_interpose.dylib your_program
+#
+# Example with pspg:
+#   DYLD_INSERT_LIBRARIES=./libwcwidth_interpose.dylib ./pspg
+
+# Compiler
+CC ?= clang
+
+# Library name
+LIBNAME = libwcwidth_interpose.dylib
+
+# Source files
+SRC = wcwidth_interpose.c
+
+# Compiler flags
+CFLAGS = -Wall -Wextra -O2 -I.
+
+# Dynamic library flags for macOS
+# Support both arm64 (Apple Silicon) and x86_64 (Intel)
+LDFLAGS = -dynamiclib
+ARCH_FLAGS = -arch arm64 -arch x86_64
+
+# Detect architecture and adjust if needed
+UNAME_M := $(shell uname -m)
+ifeq ($(UNAME_M),arm64)
+    ARCH_FLAGS = -arch arm64
+endif
+ifeq ($(UNAME_M),x86_64)
+    ARCH_FLAGS = -arch x86_64
+endif
+
+# Default target
+all: $(LIBNAME)
+
+# Build the dynamic library
+$(LIBNAME): $(SRC)
+	@echo "Building wcwidth interposition library for macOS..."
+	$(CC) $(CFLAGS) $(ARCH_FLAGS) $(LDFLAGS) -o $(LIBNAME) $(SRC)
+	@echo "Done! Library created: $(LIBNAME)"
+	@echo ""
+	@echo "Usage:"
+	@echo "  DYLD_INSERT_LIBRARIES=./$(LIBNAME) your_program"
+	@echo ""
+	@echo "Example with pspg:"
+	@echo "  DYLD_INSERT_LIBRARIES=./$(LIBNAME) ./pspg"
+	@echo ""
+	@echo "Debug mode:"
+	@echo "  DYLD_PRINT_INTERPOSING=1 DYLD_INSERT_LIBRARIES=./$(LIBNAME) ./pspg"
+
+# Universal binary (both architectures)
+universal: $(SRC)
+	@echo "Building universal binary (arm64 + x86_64)..."
+	$(CC) $(CFLAGS) -arch arm64 -arch x86_64 $(LDFLAGS) -o $(LIBNAME) $(SRC)
+	@echo "Done! Universal library created: $(LIBNAME)"
+	@file $(LIBNAME)
+
+# Debug build with symbols
+debug: CFLAGS += -g -DDEBUG
+debug: $(LIBNAME)
+
+# Clean build artifacts
+clean:
+	rm -f $(LIBNAME) *.o
+
+# Install (copy to /usr/local/lib)
+install: $(LIBNAME)
+	@echo "Installing $(LIBNAME) to /usr/local/lib..."
+	@sudo cp $(LIBNAME) /usr/local/lib/
+	@echo "Installed successfully"
+
+# Uninstall
+uninstall:
+	@echo "Removing $(LIBNAME) from /usr/local/lib..."
+	@sudo rm -f /usr/local/lib/$(LIBNAME)
+	@echo "Uninstalled successfully"
+
+# Test with pspg
+test: $(LIBNAME)
+	@echo "Testing with pspg..."
+	@if [ -f ./pspg ]; then \
+		echo "Running: DYLD_INSERT_LIBRARIES=./$(LIBNAME) echo 'Test' | ./pspg"; \
+		echo "Test" | DYLD_INSERT_LIBRARIES=./$(LIBNAME) ./pspg; \
+	else \
+		echo "Error: pspg not found. Build pspg first with 'make'"; \
+		exit 1; \
+	fi
+
+# Test with debug output
+test-debug: $(LIBNAME)
+	@echo "Testing with debug output..."
+	@if [ -f ./pspg ]; then \
+		echo "Running: DYLD_PRINT_INTERPOSING=1 DYLD_INSERT_LIBRARIES=./$(LIBNAME) echo 'Test' | ./pspg"; \
+		echo "Test" | DYLD_PRINT_INTERPOSING=1 DYLD_INSERT_LIBRARIES=./$(LIBNAME) ./pspg; \
+	else \
+		echo "Error: pspg not found. Build pspg first with 'make'"; \
+		exit 1; \
+	fi
+
+# Show library information
+info: $(LIBNAME)
+	@echo "Library information:"
+	@file $(LIBNAME)
+	@echo ""
+	@echo "Symbols:"
+	@nm -g $(LIBNAME) | grep -E 'replacement_wcwidth|replacement_mk_wcwidth|_interpose'
+	@echo ""
+	@echo "Architecture:"
+	@lipo -info $(LIBNAME)
+
+# Help
+help:
+	@echo "wcwidth interposition library - Makefile targets:"
+	@echo ""
+	@echo "  make -f Makefile.interpose          - Build the library for current architecture"
+	@echo "  make -f Makefile.interpose universal - Build universal binary (arm64 + x86_64)"
+	@echo "  make -f Makefile.interpose debug     - Build with debug symbols"
+	@echo "  make -f Makefile.interpose test      - Test with pspg"
+	@echo "  make -f Makefile.interpose test-debug- Test with DYLD debug output"
+	@echo "  make -f Makefile.interpose info      - Show library information"
+	@echo "  make -f Makefile.interpose install   - Install to /usr/local/lib"
+	@echo "  make -f Makefile.interpose uninstall - Uninstall from /usr/local/lib"
+	@echo "  make -f Makefile.interpose clean     - Remove build artifacts"
+	@echo "  make -f Makefile.interpose help      - Show this help"
+	@echo ""
+	@echo "Usage after building:"
+	@echo "  DYLD_INSERT_LIBRARIES=./$(LIBNAME) your_program"
+
+.PHONY: all universal debug clean install uninstall test test-debug info help
diff --git a/wcwidth_interpose.c b/wcwidth_interpose.c
new file mode 100644
index 0000000..c0973a9
--- /dev/null
+++ b/wcwidth_interpose.c
@@ -0,0 +1,69 @@
+/*
+ * wcwidth_interpose.c
+ *
+ * Dynamic library interposition wrapper for wcwidth() function on macOS.
+ * This library replaces system wcwidth() calls with pspg's custom wcwidth9
+ * implementation, ensuring consistent character width calculation across
+ * all applications, including ncurses-based programs.
+ *
+ * Usage:
+ *   DYLD_INSERT_LIBRARIES=./libwcwidth_interpose.dylib your_program
+ *
+ * Build:
+ *   make libwcwidth_interpose.dylib
+ *
+ * License: Same as pspg
+ */
+
+#include <wchar.h>
+#include <stddef.h>
+
+/* Include pspg's wcwidth9 implementation */
+#include "src/wcwidth9.h"
+
+/*
+ * Replacement wcwidth function
+ * This will intercept all wcwidth() calls system-wide
+ */
+int
+replacement_wcwidth(wchar_t ucs)
+{
+	return wcwidth9((int)ucs);
+}
+
+/*
+ * Replacement mk_wcwidth function
+ * ncurses may use this internal function name
+ */
+int
+replacement_mk_wcwidth(wchar_t ucs)
+{
+	return wcwidth9((int)ucs);
+}
+
+/*
+ * DYLD_INTERPOSE macro for macOS dynamic library interposition
+ * This places function replacement entries in the __DATA,__interpose section
+ */
+#define DYLD_INTERPOSE(_replacement, _replacee) \
+	__attribute__((used)) static struct { \
+		const void* replacement; \
+		const void* replacee; \
+	} _interpose_##_replacee __attribute__ ((section("__DATA,__interpose"))) = { \
+		(const void*)(unsigned long)&_replacement, \
+		(const void*)(unsigned long)&_replacee \
+	};
+
+/*
+ * Interpose both wcwidth and mk_wcwidth
+ * This ensures all possible ncurses internal calls are intercepted
+ */
+DYLD_INTERPOSE(replacement_wcwidth, wcwidth)
+
+/*
+ * Note: mk_wcwidth may not exist in all ncurses versions
+ * The linker will only use this if the symbol exists
+ */
+#ifdef MK_WCWIDTH_EXISTS
+DYLD_INTERPOSE(replacement_mk_wcwidth, mk_wcwidth)
+#endif
