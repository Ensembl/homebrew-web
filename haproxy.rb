class Haproxy < Formula
  desc "Reliable, high performance TCP/HTTP load balancer"
  homepage "https://www.haproxy.org/"
  url "https://www.haproxy.org/download/1.9/src/haproxy-1.9.4.tar.gz"
  sha256 "8483fe12b30256f83d542b3f699e165d8f71bf2dfac8b16bb53716abce4ba74f"

  bottle do
    root_url "https://linuxbrew.bintray.com/bottles"
    cellar :any
    sha256 "005dc544ba30b5eb288ab7582bafb2c1016a4683158ac06f5885b2f63f491526" => :mojave
    sha256 "33ff7981eb28bc40e4771b6a9f6dbe7ac25172c17b5b914009ec3c6e87292a30" => :high_sierra
    sha256 "9fda53095c30ede7977de844002bf646b577e50bce218219a27b0187ac3da4c3" => :sierra
    sha256 "fa54a7413ae5681e7409e6ced83d5e7f70bd05157f37c719d590781c76735413" => :x86_64_linux
  end

  depends_on "openssl"
  depends_on "pcre"
  depends_on "lua" => :optional

  def install
    args = %W[
      TARGET=#{OS.mac? ? "generic" : "linux2628"}
      USE_POLL=1
      USE_PCRE=1
      USE_OPENSSL=1
      USE_THREAD=1
      USE_ZLIB=1
      ADDLIB=-lcrypto
    ]
    args << "USE_KQUEUE=1" if OS.mac?

    if build.with?("lua")
      lua = Formula["lua"]
      args << "USE_LUA=1"
      args << "LUA_LIB=#{lua.opt_lib}"
      args << "LUA_INC=#{lua.opt_include}/lua"
      args << "LUA_LD_FLAGS=-L#{lua.opt_lib}"
    end

    # We build generic since the Makefile.osx doesn't appear to work
    system "make", "CC=#{ENV.cc}", "CFLAGS=#{ENV.cflags}", "LDFLAGS=#{ENV.ldflags}", *args
    man1.install "doc/haproxy.1"
    bin.install "haproxy"
  end

  plist_options :manual => "haproxy -f #{HOMEBREW_PREFIX}/etc/haproxy.cfg"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>KeepAlive</key>
        <true/>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/haproxy</string>
          <string>-f</string>
          <string>#{etc}/haproxy.cfg</string>
        </array>
        <key>StandardErrorPath</key>
        <string>#{var}/log/haproxy.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/haproxy.log</string>
      </dict>
    </plist>
  EOS
  end

  test do
    system bin/"haproxy", "-v"
  end
end