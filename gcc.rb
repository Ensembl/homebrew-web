class Gcc < Formula
  desc "FSF/GNU ld, ar, readelf, etc. for native development"
  homepage "https://www.gnu.org/software/binutils/binutils.html"
  url "https://ftp.gnu.org/gnu/gcc/gcc-5.4.0/gcc-5.4.0.tar.gz"

  def install
    ENV["CC"] = 'gcc'
    ENV["CXX"] = 'g++'
    ENV.prepend_path "PATH","#{HOMEBREW_PREFIX}/../../bootstrap/bin"
    system "sed", "-i", "-e", "s/ftp:/https:/", "./contrib/download_prerequisites"
    system "./contrib/download_prerequisites"
    mkdir "build" do 
      system "../configure", "--prefix=#{prefix}",
                            "--infodir=#{info}",
                            "--mandir=#{man}",
                            "--disable-multilib","--disable-werror","--enable-languages=c,c++"
      system "make"
      system "make", "install"
      bin.install_symlink "gcc" => "gcc-5"
      bin.install_symlink "g++" => "g++-5" 
    end
  end

end
