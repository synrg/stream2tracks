# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "stream2tracks"
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ben Armstrong"]
  s.date = "2011-12-31"
  s.description = "Stream ripper and tagger supporting asx, ogg, mp3, flac, etc."
  s.email = "synrg@debian.org"
  s.executables = ["stream2tracks"]
  s.extra_rdoc_files = ["README"]
  s.files = ["AUTHORS", "README", "TODO", "COPYING", "bin/stream2tracks", "spec/stream2tracks/stream_spec.rb", "lib/stream2tracks/process.rb", "lib/stream2tracks/asx_stream.rb", "lib/stream2tracks/cli.rb", "lib/stream2tracks/stream.rb", "lib/stream2tracks/stream_track_ripper.rb", "lib/stream2tracks.rb"]
  s.homepage = "http://github.com/synrg/stream2tracks"
  s.rdoc_options = ["--main", "README"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.11"
  s.summary = "Download stream as converted, tagged, renamed tracks; asx input and ogg, mp3, flac, etc. output supported."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>, ["~> 1.5"])
      s.add_runtime_dependency(%q<progressbar>, ["~> 0.9"])
      s.add_runtime_dependency(%q<sfl>, ["~> 2.0"])
      s.add_runtime_dependency(%q<taglib2>, ["< 0.2", ">= 0.1.3"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<nokogiri>, ["~> 1.5"])
      s.add_dependency(%q<progressbar>, ["~> 0.9"])
      s.add_dependency(%q<sfl>, ["~> 2.0"])
      s.add_dependency(%q<taglib2>, ["< 0.2", ">= 0.1.3"])
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<nokogiri>, ["~> 1.5"])
    s.add_dependency(%q<progressbar>, ["~> 0.9"])
    s.add_dependency(%q<sfl>, ["~> 2.0"])
    s.add_dependency(%q<taglib2>, ["< 0.2", ">= 0.1.3"])
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end
