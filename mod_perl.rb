class ModPerl < Formula

  desc 'Apache Perl mod'
  homepage 'https://perl.apache.org/'
  url 'http://www-eu.apache.org/dist/perl/mod_perl-2.0.10.tar.gz'
  sha256 'd1cf83ed4ea3a9dfceaa6d9662ff645177090749881093051020bf42f9872b64'

  option "with-httpd24", "Use Apache2.2 to bind against"
  if build.with?("httpd24")
    depends_on 'ensembl/web/httpd24'
  else
    depends_on 'ensembl/web/httpd22'
  end
  depends_on 'apr'

  def install
    if build.with?("httpd24")
      httpd = Formula['ensembl/web/httpd24']
    else
      httpd = Formula['ensembl/web/httpd22']
    end
    apr = Formula['apr']
    inreplace 'src/modules/perl/modperl_common_util.h', '#define MP_INLINE APR_INLINE', '#define MP_INLINE'
    system 'perl', 'Makefile.PL', "MP_APXS=#{httpd.bin}/apxs", "MP_APR_CONFIG=#{apr.bin}/apr-1-config"
    system 'make'
    
    # Install .so into libexec and symlink into apache
    libexec.install 'src/modules/perl/mod_perl.so'
    source_so = Pathname.new libexec+'mod_perl.so'
    target_so = Pathname.new httpd.libexec+'mod_perl.so'
    if target_so.exist?
      target_so.unlink
    end
    httpd.libexec.install_symlink source_so
    # Finish installing modperl's Perl libs
    system 'make', 'install'

    if build.with?("httpd24")
      httpd_conf = "#{etc}/apache2/2.4/httpd.conf"
    else
      httpd_conf = "#{etc}/apache2/2.2/httpd.conf"
    end
    contents = File.new(httpd_conf).read
    if contents !~ /mod_perl\.so/ then
      inreplace httpd_conf, "LoadModule rewrite_module libexec/mod_rewrite.so", "LoadModule rewrite_module libexec/mod_rewrite.so\nLoadModule perl_module libexec/mod_perl.so"
    end
  end

end
