class Perl < Formula
  desc "Highly capable, feature-rich programming language"
  homepage "https://www.perl.org/"
  url "https://www.cpan.org/src/5.0/perl-5.26.2.tar.xz"
  sha256 "0f8c0fb1b0db4681adb75c3ba0dd77a0472b1b359b9e80efd79fc27b4352132c"
  head "https://perl5.git.perl.org/perl.git", :branch => "blead"
  revision 2 unless OS.mac?

  bottle do
    sha256 "30317077ce9e42f30f9d4c875339ee5ade289cb8de08ddb55953803a52560aec" => :high_sierra
    sha256 "4aa888c405e50b43f0fd0191a84c509b3d4403dc02c9631085842f9ed98ed2a6" => :sierra
    sha256 "c87180da0272ae59e35e39733a5912d490bb5833de7b1600bdeee369a576806a" => :el_capitan
    sha256 "4a0add0701c0cad733cd7c32f1e2322de14e0cad18837fe6c0454704c3bf05b2" => :x86_64_linux
  end

  option "with-dtrace", "Build with DTrace probes"
  option "without-test", "Skip running the build test suite"

  unless OS.mac?
    depends_on "gdbm"
    depends_on "berkeley-db"

    # required for XML::Parser
    depends_on "expat"
  end

  # Prevent site_perl directories from being removed
  skip_clean "lib/perl5/site_perl"

  def install
    if MacOS.version == :el_capitan && MacOS::Xcode.installed? && MacOS::Xcode.version >= "8.0"
      %w[cpan/IPC-Cmd/lib/IPC/Cmd.pm dist/Time-HiRes/Changes
         dist/Time-HiRes/HiRes.pm dist/Time-HiRes/HiRes.xs
         dist/Time-HiRes/Makefile.PL dist/Time-HiRes/fallback/const-c.inc
         dist/Time-HiRes/t/clock.t pod/perl588delta.pod
         pod/perlperf.pod].each do |f|
        inreplace f do |s|
          s.gsub! "clock_gettime", "perl_clock_gettime"
          s.gsub! "clock_getres", "perl_clock_getres", false
        end
      end
    end

    args = %W[
      -des
      -Dprefix=#{prefix}
      -Dprivlib=#{lib}/perl5/#{version}
      -Dsitelib=#{lib}/perl5/site_perl/#{version}
      -Dotherlibdirs=#{HOMEBREW_PREFIX}/lib/perl5/site_perl/#{version}
      -Dperlpath=#{opt_bin}/perl
      -Dstartperl=#!#{opt_bin}/perl
      -Dman1dir=#{man1}
      -Dman3dir=#{man3}
      -Duseshrplib
      -Duselargefiles
      -Dusethreads
    ]

    args << "-Dusedtrace" if build.with? "dtrace"
    args << "-Dusedevel" if build.head?
    # Fix for https://github.com/Linuxbrew/homebrew-core/issues/405
    args << "-Dlocincpth=#{HOMEBREW_PREFIX}/include" if OS.linux?

    system "./Configure", *args
    system "make"

    # OS X El Capitan's SIP feature prevents DYLD_LIBRARY_PATH from being
    # passed to child processes, which causes the make test step to fail.
    # https://rt.perl.org/Ticket/Display.html?id=126706
    # https://github.com/Homebrew/legacy-homebrew/issues/41716
    # On Linux (in travis / docker container), the op/getppid.t fails too, disable the tests:
    # https://rt.perl.org/Public/Bug/Display.html?id=130143
    if OS.mac? && MacOS.version < :el_capitan
      system "make", "test" if build.with? "test"
    end

    system "make", "install"

    # expose libperl.so to ensure we aren't using a brewed executable
    # but a system library
    if OS.linux?
      perl_core = Pathname.new(`#{bin/"perl"} -MConfig -e 'print $Config{archlib}'`)+"CORE"
      lib.install_symlink perl_core/"libperl.so"
    end
  end

  def post_install
    # CPAN modules installed via the system package manager will not be visible to
    # brewed Perl. As a temporary measure, install critical CPAN modules to ensure
    # they are available. See https://github.com/Linuxbrew/homebrew-core/pull/1064
    unless OS.mac?
      ENV.with_build_environment do
        ENV["PERL_MM_USE_DEFAULT"] = "1"
        system bin/"cpan", "-i", "XML::Parser"
        system bin/"cpan", "-i", "XML::SAX"
      end
    end
  end

  def caveats; <<~EOS
    By default non-brewed cpan modules are installed to the Cellar. If you wish
    for your modules to persist across updates we recommend using `local::lib`.

    You can set that up like this:
      PERL_MM_OPT="INSTALL_BASE=$HOME/perl5" cpan local::lib
      echo 'eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib=$HOME/perl5)"' >> #{shell_profile}
  EOS
  end

  test do
    (testpath/"test.pl").write "print 'Perl is not an acronym, but JAPH is a Perl acronym!';"
    system "#{bin}/perl", "test.pl"
  end
end
