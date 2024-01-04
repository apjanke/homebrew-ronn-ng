class RonnNgPrerelease < Formula
  desc "Build man pages from Markdown (prerelease version)"
  homepage "https://github.com/apjanke/ronn-ng"
  url "https://github.com/apjanke/ronn-ng/archive/refs/tags/v0.10.1.pre4.tar.gz"
  sha256 "0ebde28f469fee5e2a5b2ebdb915aea46052e2495581d8b4754071bbcad0bb99"

  conflicts_with "ronn", because: "provides the same command"
  conflicts_with "ronn-ng", because: "prerelease version of same thing"

  # Needs Ruby >= 2.7; macOS system Ruby is 2.6 as of macOS 14
  depends_on "ruby"

  resource "mustache" do
    url "https://rubygems.org/gems/mustache-1.1.1.gem"
    sha256 "90891fdd50b53919ca334c8c1031eada1215e78d226d5795e523d6123a2717d0"
  end

  # Required by nokogiri at build time
  resource "mini_portile2" do
    url "https://rubygems.org/gems/mini_portile2-2.8.2.gem"
    sha256 "46b2d244cc6ff01a89bf61274690c09fdbdca47a84ae9eac39039e81231aee7c"
  end

  resource "nokogiri" do
    url "https://rubygems.org/gems/nokogiri-1.16.0.gem"
    sha256 "341388184e975d091e6e38ce3f3b3388bfb7e4ac3d790efd8e39124844040bd1"
  end

  resource "kramdown" do
    url "https://rubygems.org/gems/kramdown-2.4.0.gem"
    sha256 "b62e5bcbd6ea20c7a6730ebbb2a107237856e14f29cebf5b10c876cc1a2481c5"
  end

  resource "kramdown-parser-gfm" do
    url "https://rubygems.org/gems/kramdown-parser-gfm-1.1.0.gem"
    sha256 "fb39745516427d2988543bf01fc4cf0ab1149476382393e0e9c48592f6581729"
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
