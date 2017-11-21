class Glibc < Formula
  desc "FSF/GNU ld, ar, readelf, etc. for native development"
  homepage "https://www.gnu.org/software/binutils/binutils.html"
  url "https://ftp.gnu.org/gnu/glibc/glibc-2.25.tar.gz"

  def install
    ENV["CC"] = 'gcc'
    ENV["CXX"] = 'g++'
    ENV.prepend_path "PATH","/nfs/public/release/ensweb-software/sharedsw/bootstrap/bin"
    mkdir "build" do 
      system "../configure", "--prefix=#{prefix}",
                            "--infodir=#{info}",
                            "--mandir=#{man}","--x=x",
                            "--with-headers=/nfs/public/release/ensweb-software/sharedsw/bootstrap/include"
      system "make"
      system "patchelf", "--remove-rpath", "elf/ld-linux-x86-64.so.2"
      system "make", "install"
      prefix.install_symlink "lib" => "lib64"
    end
  end

end
