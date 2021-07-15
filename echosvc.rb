# Pass without all the horrible dependencies.
class Echosvc < Formula
  desc "echo service (port 7)"
  homepage ""
  url "https://github.com/Ensembl/echosvc/archive/master.tar.gz"
  sha256 "e0a2aa20c420c0b9afc5dcfb91c0542af5b75ad3ff3a453498d278689082833e"
  version "0.0"

  def install
    system "gcc", "echosvc.c", "-o", "echosvc"
    system "cp", "echosvc", "#{prefix}/echosvc"
    bin.install_symlink Dir["#{prefix}/echosvc"]
  end

  test do
    system "false"
  end
end

