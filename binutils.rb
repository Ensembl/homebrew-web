class Binutils < Formula
  desc "FSF/GNU ld, ar, readelf, etc. for native development"
  homepage "https://www.gnu.org/software/binutils/binutils.html"
  url "https://ftp.gnu.org/gnu/binutils/binutils-2.28.tar.gz"
  mirror "https://ftpmirror.gnu.org/binutils/binutils-2.28.tar.gz"
  sha256 "cd717966fc761d840d451dbd58d44e1e5b92949d2073d75b73fccb476d772fcf"

  bottle do
    cellar :any if OS.linux?
    rebuild 1
    sha256 "ccacdbe617addcb6f41c2fba544077987ecd2dca62cf6c7884b0bfc639f99d45" => :sierra
    sha256 "7674e8693c4af0a738c721bbb530e432f5258d516a780c109c5d1ce0458e0de3" => :el_capitan
    sha256 "1b48a19196ea84d7c2d0fcfc933967b9d1596dd5f30935948ee0d5baaa9f6f65" => :yosemite
    sha256 "77a433a64a86f48bbb0092f0fe505dc87f37edba6d39c1c0816156a92e29f545" => :x86_64_linux
  end

  # No --default-names option as it interferes with Homebrew builds.
  option "with-default-names", "Do not prepend 'g' to the binary" if OS.linux?
  option "without-gold", "Do not build the gold linker" if OS.linux?

  depends_on "zlib" => :recommended unless OS.mac?

  def install
    ENV["CC"] = 'gcc'
    ENV["CXX"] = 'g++'
    ENV.prepend_path "PATH","/nfs/public/release/ensweb-software/sharedsw/bootstrap/bin"
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--enable-deterministic-archives",
                          "--prefix=#{prefix}",
                          "--infodir=#{info}",
                          "--mandir=#{man}",
                          "--disable-werror"
    system "make"
    system "make", "install"

    # Reduce the size of the bottle.
    system "strip", *Dir[bin/"*", lib/"*.a"] unless OS.mac?
  end

  test do
    size = build.with?("default-names") ? "size" : "gsize"
    assert_match "text", shell_output("#{bin}/#{size} #{bin}/#{size}")
  end
