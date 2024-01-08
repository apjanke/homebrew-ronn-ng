class RonnNg < Formula
  desc "Build man pages from Markdown"
  homepage "https://github.com/apjanke/ronn-ng"
  url "https://github.com/apjanke/ronn-ng/archive/v0.10.1.tar.gz"
  sha256 "180f18015ce01be1d10c24e13414134363d56f9efb741fda460358bb67d96684"
  head "https://github.com/apjanke/ronn-ng.git"

  conflicts_with "ronn", because: "provides the same command"
  conflicts_with "ronn-ng-prerelease", because: "that's a prerelease version of same thing"

  # Nokogiri 1.9 requires a newer Ruby
  depends_on "ruby"

  resource "kramdown" do
    url "https://rubygems.org/gems/kramdown-2.4.0.gem"
    sha256 "b62e5bcbd6ea20c7a6730ebbb2a107237856e14f29cebf5b10c876cc1a2481c5"
  end

  resource "kramdown-parser-gfm" do
    url "https://rubygems.org/downloads/kramdown-parser-gfm-1.1.0.gem"
    sha256 "fb39745516427d2988543bf01fc4cf0ab1149476382393e0e9c48592f6581729"
  end

  # Required by nokogiri at build time
  resource "mini_portile2" do
    url "https://rubygems.org/gems/mini_portile2-2.8.2.gem"
    sha256 "46b2d244cc6ff01a89bf61274690c09fdbdca47a84ae9eac39039e81231aee7c"
  end

  resource "nokogiri" do
    url "https://rubygems.org/downloads/nokogiri-1.15.5-arm64-darwin.gem"
    sha256 "4d7b15d53c0397d131376a19875aa97dd1c8b404c2c03bd2171f9b77e9592d40"
  end

  resource "mustache" do
    url "https://rubygems.org/gems/mustache-1.1.1.gem"
    sha256 "90891fdd50b53919ca334c8c1031eada1215e78d226d5795e523d6123a2717d0"
  end


  def install
    ENV["GEM_HOME"] = libexec

    (lib/"ronn-ng/vendor").mkpath
    resources.each do |r|
      r.verify_download_integrity(r.fetch)
      system("gem", "install", r.cached_download, "--no-document", "--ignore-dependencies",
             "--install-dir", libexec)
    end

    if build.head?
      d = Dir['ronn-ng-*.gem']
      gem_file = d[0]
    else
      gem_file = "ronn-ng-#{version}.gem"
    end
    system "gem", "build", "ronn-ng.gemspec"
    system "gem", "install", "--ignore-dependencies", gem_file

    bin.install libexec/"bin/ronn"
    bin.env_script_all_files(libexec/"bin", :GEM_HOME => ENV["GEM_HOME"])

    bash_completion.install "completion/bash/ronn"
    zsh_completion.install "completion/zsh/_ronn"
    man1.install Dir["man/*.1"]
    man7.install Dir["man/*.7"]
  end

  test do
    (testpath/"test.ronn").write <<~EOS
    helloworld
    ==========

    Hello, world!
    EOS

    assert_match /^Hello, world/, shell_output("#{bin}/ronn --roff --pipe test.ronn")
  end
end
