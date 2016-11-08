class Httpd24 < Formula
  desc "HTTP server"
  homepage "https://httpd.apache.org/"
  url "https://archive.apache.org/dist/httpd/httpd-2.4.23.tar.bz2"
  sha256 "0c1694b2aad7765896faf92843452ee2555b9591ae10d4f19b245f2adfe85e58"
  revision 2

  bottle do
    sha256 "3cf05ee1dae35c93aadc8c27d32fa88b998af6e7e387420c0b372e38d298b308" => :sierra
    sha256 "41cd39db06ddbbc941e736c0700a9b218899239259eafb900f35f843b5a72cea" => :el_capitan
    sha256 "bf5abcffd2fbfe3b592b21f581a7cff8e17ded70fd2d827dc0bb0fd33fd8af18" => :yosemite
  end

  conflicts_with "homebrew/apache/httpd22", :because => "different versions of the same software"
  conflicts_with "homebrew/apache/httpd24", :because => "different versions of the same software"

  skip_clean :la

  option "with-mpm-worker", "Use the Worker Multi-Processing Module instead of Prefork"
  option "with-mpm-event", "Use the Event Multi-Processing Module instead of Prefork"
  option "with-privileged-ports", "Use the default ports 80 and 443 (which require root privileges), instead of 8080 and 8443"
  option "with-ldap", "Include support for LDAP"
  option "with-http2", "Build and enable the HTTP/2 shared Module"

  depends_on "openssl"
  depends_on "pcre"
  depends_on "zlib"

  if build.with? "ldap"
    depends_on "apr-util" => "with-openldap"
  else
    depends_on "apr-util"
  end

  depends_on "nghttp2" if build.with? "http2"

  if build.with?("mpm-worker") && build.with?("mpm-event")
    raise "Cannot build with both worker and event MPMs, choose one"
  end

  def install    
    # point config files to opt_prefix instead of the version-specific prefix
    inreplace "Makefile.in",
      '#@@ServerRoot@@#$(prefix)#', '#@@ServerRoot@@'"##{opt_prefix}#"

    # fix non-executable files in sbin dir (for brew audit)
    inreplace "support/Makefile.in",
      "$(DESTDIR)$(sbindir)/envvars", "$(DESTDIR)$(sysconfdir)/envvars"
    inreplace "support/Makefile.in",
      "envvars-std $(DESTDIR)$(sbindir);", "envvars-std $(DESTDIR)$(sysconfdir);"
    inreplace "support/apachectl.in",
      "@exp_sbindir@/envvars", "#{etc}/apache2/2.4/envvars"

    # install custom layout
    File.open("config.layout", "a") { |f| f.write(httpd_layout) }

    args = %W[
      --prefix=#{prefix}
      --enable-layout=Homebrew
      --enable-mods-shared=all
      --enable-mpms-shared=all
      --enable-unique-id
      --enable-ssl
      --enable-dav
      --enable-cache
      --enable-logio
      --enable-deflate
      --enable-cgi
      --enable-cgid
      --enable-suexec
      --enable-rewrite
      --with-apr=#{Formula["apr"].opt_prefix}/bin/apr-1-config
      --with-apr-util=#{Formula["apr-util"].opt_prefix}/bin/apu-1-config
      --with-pcre=#{Formula["pcre"].opt_prefix}
      --with-ssl=#{Formula["openssl"].opt_prefix}
      --with-z=#{Formula["zlib"].opt_prefix}
      --libdir=#{HOMEBREW_PREFIX}/lib
    ]

    if build.with? "mpm-worker"
      args << "--with-mpm=worker"
    elsif build.with? "mpm-event"
      args << "--with-mpm=event"
    else
      args << "--with-mpm=prefork"
    end

    if build.with? "privileged-ports"
      args << "--with-port=80" << "--with-sslport=443"
    else
      args << "--with-port=8080" << "--with-sslport=8443"
    end

    if build.with? "http2"
      args << "--enable-http2" << "--with-nghttp2=#{Formula["nghttp2"].opt_prefix}"
    end

    if build.with? "ldap"
      args << "--with-ldap" << "--enable-ldap" << "--enable-authnz-ldap"
    end

    (etc/"apache2/2.4").mkpath

    system "./configure", *args

    system "make"
    system "make", "install"
    (var/"apache2/log").mkpath
    (var/"apache2/run").mkpath
    touch("#{var}/log/apache2/access_log") unless File.exist?("#{var}/log/apache2/access_log")
    touch("#{var}/log/apache2/error_log") unless File.exist?("#{var}/log/apache2/error_log")
  end

  def httpd_layout
    <<-EOS.undent

      <Layout Homebrew>
          prefix:        #{prefix}
          exec_prefix:   ${prefix}
          bindir:        ${exec_prefix}/bin
          sbindir:       ${exec_prefix}/bin
          libdir:        ${exec_prefix}/lib
          libexecdir:    ${exec_prefix}/libexec
          mandir:        #{man}
          infodir:       #{info}
          sysconfdir:    #{etc}/apache2/2.4
          datadir:       #{var}/www
          installbuilddir: ${prefix}/build
          errordir:      ${datadir}/error
          iconsdir:      ${datadir}/icons
          htdocsdir:     ${datadir}/htdocs
          manualdir:     ${datadir}/manual
          cgidir:        #{var}/apache2/cgi-bin
          includedir:    ${prefix}/include/httpd
          localstatedir: #{var}/apache2
          runtimedir:    #{var}/run/apache2
          logfiledir:    #{var}/log/apache2
          proxycachedir: ${localstatedir}/proxy
      </Layout>
    EOS
  end

  test do
    system bin/"httpd", "-v"
  end
end
