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
  depends_on 'ensembl/web/apr'
  
  # You can only install to 1 version of Perl because mod_perl.so is compiled to link against one libperl.so
  def run_install(perl_cmd, httpd_formula, apr_formula)
    system perl_cmd, 'Makefile.PL', "MP_APXS=#{httpd_formula.bin}/apxs", "MP_APR_CONFIG=#{apr_formula.bin}/apr-1-config"

    mod_perl_so = libexec/'mod_perl.so'
    httpd_mod_perl_so = httpd_formula.libexec/'mod_perl.so'
    
    # If mod_perl.so already exists in httpd remove it
    if httpd_mod_perl_so.exist?
      ohai "Removing pre-existing mod_perl.so from #{httpd_mod_perl_so}"
      httpd_mod_perl_so.unlink
    end
    system 'make'
    system 'make', 'install'
    
    # Install .so into libexec and symlink back into apache to avoid empty installation
    libexec.install httpd_mod_perl_so
    httpd_formula.libexec.install_symlink mod_perl_so
  end

  def install
    if build.with?("httpd24")
      httpd = Formula['ensembl/web/httpd24']
    else
      httpd = Formula['ensembl/web/httpd22']
    end
    apr = Formula['ensembl/web/apr']
    inreplace 'src/modules/perl/modperl_common_util.h', '#define MP_INLINE APR_INLINE', '#define MP_INLINE'
    
    if ENV.has_key?('PLENV_ROOT')
      perl_cmd = %x{#{ENV['PLENV_ROOT']}/bin/plenv which perl}.chomp
      run_install(perl_cmd, httpd, apr)
    else
      run_install('/usr/bin/perl', httpd, apr)
    end

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
