class Apr < Formula
  desc "Apache Portable Runtime library"
  homepage "https://apr.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=apr/apr-1.6.2.tar.bz2"
  sha256 "09109cea377bab0028bba19a92b5b0e89603df9eab05c0f7dbd4dd83d48dcebd"
  revision 1

  bottle do
    cellar :any
    sha256 "64527b35f69f53202253676c3727411fa3fb3a0ae1b71ca266c62d2a87faf3bd" => :high_sierra
    sha256 "5a0ef0c7992eaa6fc1ac332f72cdaebfb5fc0e9fd70a00606fc72e3a5c9d0afb" => :sierra
    sha256 "b5b9ef99e199a850bc0485fec5968ada7dece9d107df3af0014ecb7245cf5f68" => :el_capitan
    sha256 "cca4cfe47cf5e2f504c2bba59ddb991211b4ed778b2cadda74ea418305a5d942" => :yosemite
    sha256 "fde87cb48e98a8037fcb208867e04e3dd76a7f3e5361787450d0c1b2b773233b" => :x86_64_linux
  end

  keg_only :provided_by_osx, "Apple's CLT package contains apr"

  depends_on "util-linux" => :recommended if OS.linux? # for libuuid

  def install
    ENV["SED"] = "sed" # prevent libtool from hardcoding sed path from superenv

    # https://bz.apache.org/bugzilla/show_bug.cgi?id=57359
    # The internal libtool throws an enormous strop if we don't do...
    ENV.deparallelize

    if OS.linux? && build.bottle?
      # Prevent hardcoded /usr/bin/gcc-4.8 compiler
      ENV["CC"] = "cc"
    end

    # Stick it in libexec otherwise it pollutes lib with a .exp file.
    system "./configure", "--prefix=#{libexec}"
    system "make", "install"
    bin.install_symlink Dir["#{libexec}/bin/*"]
    lib.install_symlink Dir["#{libexec}/lib/*.so*"] unless OS.mac?

    rm Dir[libexec/"lib/*.la"]

    # No need for this to point to the versioned path.
    inreplace libexec/"bin/apr-1-config", libexec, opt_libexec
  end

  test do
    assert_match opt_libexec.to_s, shell_output("#{bin}/apr-1-config --prefix")
  end
end
