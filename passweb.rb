# Pass without all the horrible dependencies.
class Passweb < Formula
  desc "pass without lots of horrible dependencies."
  homepage ""
  url "https://git.zx2c4.com/password-store/snapshot/password-store-1.7.3.tar.xz"
  sha256 "2b6c65846ebace9a15a118503dcd31b6440949a30d3b5291dfb5b1615b99a3f4"

  depends_on "tree"

  def install
    system  "make", "install", "PREFIX=#{prefix}"
  end

  test do
    system "false"
  end
end

