class ModPerl < Formula

  desc 'Apache Perl mod'
  homepage 'https://perl.apache.org/'
  url 'http://www-eu.apache.org/dist/perl/mod_perl-2.0.10.tar.gz'
  sha256 'd1cf83ed4ea3a9dfceaa6d9662ff645177090749881093051020bf42f9872b64'

  depends_on 'ensembl/web/httpd24'
  depends_on 'apr'

  def install
    httpd = Formula['ensembl/web/httpd24']
    apr = Formula['apr']
    system 'perl', 'Makefile.PL', "MP_APXS=#{httpd.bin}/apxs", "MP_APR_CONFIG=#{apr.bin}/bin/apr-1-config"
    system 'make'
    libexec.install 'src/modules/perl/mod_perl.so'
    httpd.libexec.install_symlink (libexec+'mod_perl.so')
  end

end
