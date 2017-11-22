class Glibc < Formula
  desc "FSF/GNU ld, ar, readelf, etc. for native development"
  homepage "https://www.gnu.org/software/binutils/binutils.html"
  url "https://ftp.gnu.org/gnu/glibc/glibc-2.25.tar.gz"

  def install
    ENV["CC"] = 'gcc'
    ENV["CXX"] = 'g++'
    ENV.prepend_path "PATH","#{HOMEBREW_PREFIX}/../../bootstrap/bin"
    rm File.join(HOMEBREW_PREFIX,'/include/scsi'), :force => true
    mkdir "build" do
      system "../configure", "--prefix=#{HOMEBREW_PREFIX}",
                            "--infodir=#{info}",
                            "--mandir=#{man}",
                            "--with-headers=#{HOMEBREW_PREFIX}/include"
      system "make"
      system "patchelf", "--remove-rpath", "elf/ld-linux-x86-64.so.2"
      system "make", "install"
      prefix.install_symlink "lib" => "lib64"
    end
  end

end
