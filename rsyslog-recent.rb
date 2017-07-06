class RsyslogRecent < Formula
  desc "Enhanced, multi-threaded syslogd (more recent)"
  homepage "http://www.rsyslog.com"
  url "http://www.rsyslog.com/files/download/rsyslog/rsyslog-8.28.0.tar.gz"

  depends_on "pkg-config" => :build
  depends_on "libestr"
  depends_on "json-c"
  depends_on "libfastjson"
  depends_on "liblogging"
  depends_on "zlib" unless OS.mac?

#  patch :DATA

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --enable-imfile
      --enable-usertools
      --enable-diagtools
      --enable-relp
      --enable-cached-man-pages
      --disable-uuid
      --disable-libgcrypt
    ]

    system "./configure", *args
    system "make"
    system "make", "install"
  end
end

__END__
diff --git i/grammar/parserif.h w/grammar/parserif.h
index aa271ec..03c4db9 100644
--- i/grammar/parserif.h
+++ w/grammar/parserif.h
@@ -3,7 +3,7 @@
 #include "rainerscript.h"
 int cnfSetLexFile(char*);
 int yyparse();
-char *cnfcurrfn;
+extern char *cnfcurrfn;
 void dbgprintf(char *fmt, ...) __attribute__((format(printf, 1, 2)));
 void parser_errmsg(char *fmt, ...) __attribute__((format(printf, 1, 2)));
 void tellLexEndParsing(void);
