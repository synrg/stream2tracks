require "rubygems"
require "rubygems/package_task"
require "rdoc/task"

require "rspec"
require "rspec/core/rake_task"
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = %w(--format documentation --colour)
end


task :default => ["spec"]

# This builds the actual gem. For details of what all these options
# mean, and other ones you can add, check the documentation here:
#
#   http://rubygems.org/read/chapter/20
#
spec = Gem::Specification.new do |s|

  s.name              = "stream2tracks"
  s.version           = "0.0.2"
  s.description	      = "Stream ripper and tagger supporting asx, ogg, mp3, flac, etc."
  s.summary           = "Download stream as converted, tagged, renamed tracks; asx input and ogg, mp3, flac, etc. output supported."
  s.author            = "Ben Armstrong"
  s.email             = "synrg@debian.org"
  s.homepage          = "http://github.com/synrg/stream2tracks"

  s.has_rdoc          = true
  s.extra_rdoc_files  = %w(README)
  s.rdoc_options      = %w(--main README)

  s.files             = %w(AUTHORS README TODO COPYING) + Dir.glob("{bin,spec,lib}/**/*")
  s.executables       = FileList["bin/**"].map { |f| File.basename(f) }
  s.require_paths     = ["lib"]
  s.add_dependency 'nokogiri', '~> 1.5'
  s.add_dependency 'progressbar', '~> 0.9'
  s.add_dependency 'sfl', '~> 2.0'
  s.add_dependency 'taglib2', '>= 0.1.3', '< 0.2'

  # If your tests use any gems, include them here
  s.add_development_dependency("rspec")
end

# TODO: Investigate gemcutter; is the 'push' target at bottom sufficient?
# To publish your gem online, install the 'gemcutter' gem; Read more 
# about that here: http://gemcutter.org/pages/gem_docs
Gem::PackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Build the gemspec file #{spec.name}.gemspec"
task :gemspec do
  file = File.dirname(__FILE__) + "/#{spec.name}.gemspec"
  File.open(file, "w") {|f| f << spec.to_ruby }
end

task :package => :gemspec

# Generate documentation
RDoc::Task.new do |rd|
  rd.main = "README"
  rd.rdoc_files.include("README", "lib/**/*.rb")
  rd.rdoc_dir = "rdoc"
end

desc 'Clear out RDoc and generated packages'
task :clean => [:clobber_rdoc, :clobber_package] do
  rm "#{spec.name}.gemspec"
end

desc 'Tag the repository in git with gem version number'
task :tag => [:gemspec, :package] do
  if `git diff --cached`.empty?
    if `git tag`.split("\n").include?("v#{spec.version}")
      raise "Version #{spec.version} has already been released"
    end
    `git add #{File.expand_path("../#{spec.name}.gemspec", __FILE__)}`
    `git commit -m "Released version #{spec.version}"`
    `git tag v#{spec.version}`
    `git push --tags`
    `git push`
  else
    raise "Unstaged changes still waiting to be committed"
  end
end

desc "Tag and publish the gem to rubygems.org"
task :publish => :tag do
  `gem push pkg/#{spec.name}-#{spec.version}.gem`
end
