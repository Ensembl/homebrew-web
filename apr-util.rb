class AprUtil < Formula
  desc "Companion library to apr, the Apache Portable Runtime library"
  homepage "https://apr.apache.org/"
  url "http://archive.apache.org/dist/apr/apr-util-1.6.0.tar.bz2"
  sha256 "8474c93fa74b56ac6ca87449abe3e155723d5f534727f3f33283f6631a48ca4c"
  revision 1

  keg_only :provided_by_macos, "Apple's CLT package contains apr"

  depends_on "ensembl/web/apr"
  depends_on "ensembl/web/openssl"
  depends_on "mawk"
  depends_on "postgresql" => :optional
  depends_on "mysql" => :optional
  depends_on "freetds" => :optional
  depends_on "unixodbc" => :optional
  depends_on "sqlite" => :optional
  depends_on "openldap" => :optional
  unless OS.mac?
    depends_on "expat"
    depends_on "util-linux" # for libuuid
  end

  def install
    # Stick it in libexec otherwise it pollutes lib with a .exp file.
    args = %W[
      --prefix=#{libexec}
      --with-apr=#{Formula["apr"].opt_prefix}
      --with-openssl=#{Formula["openssl"].opt_prefix}
      --with-crypto
    ]

    args << "--with-pgsql=#{Formula["postgresql"].opt_prefix}" if build.with? "postgresql"
    args << "--with-mysql=#{Formula["mysql"].opt_prefix}" if build.with? "mysql"
    args << "--with-freetds=#{Formula["freetds"].opt_prefix}" if build.with? "freetds"
    if build.with? "unixodbc"
      args << "--with-odbc=#{Formula["unixodbc"].opt_prefix}"
    else
      system "which", "odbc_config"
      if $?.success?
        odbc_config_inc = `odbc_config --include-prefix`
        odbc_config_lib = `odbc_config --lib-prefix`
        args << "--with-odbc"
        args << "--with-odbc-include=#{odbc_config_inc}"
        args << "--with-odbc=#{odbc_config_lib}"
      end
    end

    if build.with? "openldap"
      args << "--with-ldap"
      args << "--with-ldap-lib=#{Formula["openldap"].opt_lib}"
      args << "--with-ldap-include=#{Formula["openldap"].opt_include}"
    end

    system "./configure", *args
    system "make"
    system "make", "install"
    bin.install_symlink Dir["#{libexec}/bin/*"]
    lib.install_symlink Dir["#{libexec}/lib/*.so*"] unless OS.mac?

    rm Dir[libexec/"lib/*.la"]
    rm Dir[libexec/"lib/apr-util-1/*.la"]

    # No need for this to point to the versioned path.
    inreplace libexec/"bin/apu-1-config", libexec, opt_libexec
  end

  test do
    assert_match opt_libexec.to_s, shell_output("#{bin}/apu-1-config --prefix")
  end
end
