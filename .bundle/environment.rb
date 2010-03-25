# DO NOT MODIFY THIS FILE

require 'digest/sha1'
require 'rubygems'

module Gem
  class Dependency
    if !instance_methods.map { |m| m.to_s }.include?("requirement")
      def requirement
        version_requirements
      end
    end
  end
end

module Bundler
  module SharedHelpers

    def default_gemfile
      gemfile = find_gemfile
      gemfile or raise GemfileNotFound, "The default Gemfile was not found"
      Pathname.new(gemfile)
    end

    def in_bundle?
      find_gemfile
    end

  private

    def find_gemfile
      return ENV['BUNDLE_GEMFILE'] if ENV['BUNDLE_GEMFILE']

      previous = nil
      current  = File.expand_path(Dir.pwd)

      until !File.directory?(current) || current == previous
        filename = File.join(current, 'Gemfile')
        return filename if File.file?(filename)
        current, previous = File.expand_path("..", current), current
      end
    end

    def clean_load_path
      # handle 1.9 where system gems are always on the load path
      if defined?(::Gem)
        me = File.expand_path("../../", __FILE__)
        $LOAD_PATH.reject! do |p|
          next if File.expand_path(p).include?(me)
          p != File.dirname(__FILE__) &&
            Gem.path.any? { |gp| p.include?(gp) }
        end
        $LOAD_PATH.uniq!
      end
    end

    def reverse_rubygems_kernel_mixin
      # Disable rubygems' gem activation system
      ::Kernel.class_eval do
        if private_method_defined?(:gem_original_require)
          alias rubygems_require require
          alias require gem_original_require
        end

        undef gem
      end
    end

    def cripple_rubygems(specs)
      reverse_rubygems_kernel_mixin

      executables = specs.map { |s| s.executables }.flatten

     :: Kernel.class_eval do
        private
        def gem(*) ; end
      end
      Gem.source_index # ensure RubyGems is fully loaded

      ::Kernel.send(:define_method, :gem) do |dep, *reqs|
        if executables.include? File.basename(caller.first.split(':').first)
          return
        end
        opts = reqs.last.is_a?(Hash) ? reqs.pop : {}

        unless dep.respond_to?(:name) && dep.respond_to?(:requirement)
          dep = Gem::Dependency.new(dep, reqs)
        end

        spec = specs.find  { |s| s.name == dep.name }

        if spec.nil?
          e = Gem::LoadError.new "#{dep.name} is not part of the bundle. Add it to Gemfile."
          e.name = dep.name
          e.version_requirement = dep.requirement
          raise e
        elsif dep !~ spec
          e = Gem::LoadError.new "can't activate #{dep}, already activated #{spec.full_name}. " \
                                 "Make sure all dependencies are added to Gemfile."
          e.name = dep.name
          e.version_requirement = dep.requirement
          raise e
        end

        true
      end

      # === Following hacks are to improve on the generated bin wrappers ===

      # Yeah, talk about a hack
      source_index_class = (class << Gem::SourceIndex ; self ; end)
      source_index_class.send(:define_method, :from_gems_in) do |*args|
        source_index = Gem::SourceIndex.new
        source_index.spec_dirs = *args
        source_index.add_specs(*specs)
        source_index
      end

      # OMG more hacks
      gem_class = (class << Gem ; self ; end)
      gem_class.send(:define_method, :bin_path) do |name, *args|
        exec_name, *reqs = args

        spec = nil

        if exec_name
          spec = specs.find { |s| s.executables.include?(exec_name) }
          spec or raise Gem::Exception, "can't find executable #{exec_name}"
        else
          spec = specs.find  { |s| s.name == name }
          exec_name = spec.default_executable or raise Gem::Exception, "no default executable for #{spec.full_name}"
        end

        gem_bin = File.join(spec.full_gem_path, spec.bindir, exec_name)
        gem_from_path_bin = File.join(File.dirname(spec.loaded_from), spec.bindir, exec_name)
        File.exist?(gem_bin) ? gem_bin : gem_from_path_bin
      end
    end

    extend self
  end
end

module Bundler
  LOCKED_BY    = '0.9.13'
  FINGERPRINT  = "cdaa710f78078fb603050912e360861f7991e448"
  AUTOREQUIRES = {:default=>[["rake", false], ["rack", false], ["acts_as_taggable", false], ["gem_plugin", false], ["hpricot", false], ["httpauth", false], ["jviney-acts_as_taggable_on_steroids", false], ["libxml-ruby", false], ["mime-types", false], ["mongrel", false], ["mongrel_cluster", false], ["mysql", false], ["nokogiri", false], ["rails", false], ["rspec-rails", false]]}
  SPECS        = [
        {:loaded_from=>"/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/specifications/rake-0.8.7.gemspec", :name=>"rake", :load_paths=>["/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/gems/rake-0.8.7/lib"]},
        {:loaded_from=>"/Users/woolley/.rvm/gems/ruby-1.8.7-p174%global/specifications/activesupport-2.3.5.gemspec", :name=>"activesupport", :load_paths=>["/Users/woolley/.rvm/gems/ruby-1.8.7-p174%global/gems/activesupport-2.3.5/lib"]},
        {:loaded_from=>"/Users/woolley/.rvm/gems/ruby-1.8.7-p174%global/specifications/rack-1.0.1.gemspec", :name=>"rack", :load_paths=>["/Users/woolley/.rvm/gems/ruby-1.8.7-p174%global/gems/rack-1.0.1/lib"]},
        {:loaded_from=>"/Users/woolley/.rvm/gems/ruby-1.8.7-p174%global/specifications/actionpack-2.3.5.gemspec", :name=>"actionpack", :load_paths=>["/Users/woolley/.rvm/gems/ruby-1.8.7-p174%global/gems/actionpack-2.3.5/lib"]},
        {:loaded_from=>"/Users/woolley/.rvm/gems/ruby-1.8.7-p174%global/specifications/actionmailer-2.3.5.gemspec", :name=>"actionmailer", :load_paths=>["/Users/woolley/.rvm/gems/ruby-1.8.7-p174%global/gems/actionmailer-2.3.5/lib"]},
        {:loaded_from=>"/Users/woolley/.rvm/gems/ruby-1.8.7-p174%global/specifications/activerecord-2.3.5.gemspec", :name=>"activerecord", :load_paths=>["/Users/woolley/.rvm/gems/ruby-1.8.7-p174%global/gems/activerecord-2.3.5/lib"]},
        {:loaded_from=>"/Users/woolley/.rvm/gems/ruby-1.8.7-p174%global/specifications/activeresource-2.3.5.gemspec", :name=>"activeresource", :load_paths=>["/Users/woolley/.rvm/gems/ruby-1.8.7-p174%global/gems/activeresource-2.3.5/lib"]},
        {:loaded_from=>"/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/specifications/acts_as_taggable-2.0.2.gemspec", :name=>"acts_as_taggable", :load_paths=>["/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/gems/acts_as_taggable-2.0.2/lib"]},
        {:loaded_from=>"/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/specifications/cgi_multipart_eof_fix-2.5.0.gemspec", :name=>"cgi_multipart_eof_fix", :load_paths=>["/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/gems/cgi_multipart_eof_fix-2.5.0/lib"]},
        {:loaded_from=>"/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/specifications/daemons-1.0.10.gemspec", :name=>"daemons", :load_paths=>["/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/gems/daemons-1.0.10/lib"]},
        {:loaded_from=>"/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/specifications/fastthread-1.0.7.gemspec", :name=>"fastthread", :load_paths=>["/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/gems/fastthread-1.0.7/lib", "/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/gems/fastthread-1.0.7/ext"]},
        {:loaded_from=>"/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/specifications/gem_plugin-0.2.3.gemspec", :name=>"gem_plugin", :load_paths=>["/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/gems/gem_plugin-0.2.3/lib"]},
        {:loaded_from=>"/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/specifications/hpricot-0.8.2.gemspec", :name=>"hpricot", :load_paths=>["/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/gems/hpricot-0.8.2/lib"]},
        {:loaded_from=>"/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/specifications/httpauth-0.1.gemspec", :name=>"httpauth", :load_paths=>["/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/gems/httpauth-0.1/lib"]},
        {:loaded_from=>"/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/specifications/jviney-acts_as_taggable_on_steroids-1.1.gemspec", :name=>"jviney-acts_as_taggable_on_steroids", :load_paths=>["/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/gems/jviney-acts_as_taggable_on_steroids-1.1/lib"]},
        {:loaded_from=>"/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/specifications/libxml-ruby-1.1.2.gemspec", :name=>"libxml-ruby", :load_paths=>["/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/gems/libxml-ruby-1.1.2/lib", "/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/gems/libxml-ruby-1.1.2/ext/libxml"]},
        {:loaded_from=>"/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/specifications/mime-types-1.15.gemspec", :name=>"mime-types", :load_paths=>["/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/gems/mime-types-1.15/lib"]},
        {:loaded_from=>"/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/specifications/mongrel-1.1.5.gemspec", :name=>"mongrel", :load_paths=>["/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/gems/mongrel-1.1.5/lib", "/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/gems/mongrel-1.1.5/ext"]},
        {:loaded_from=>"/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/specifications/mongrel_cluster-1.0.5.gemspec", :name=>"mongrel_cluster", :load_paths=>["/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/gems/mongrel_cluster-1.0.5/lib"]},
        {:loaded_from=>"/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/specifications/mysql-2.8.1.gemspec", :name=>"mysql", :load_paths=>["/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/gems/mysql-2.8.1/lib", "/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/gems/mysql-2.8.1/ext"]},
        {:loaded_from=>"/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/specifications/nokogiri-1.4.1.gemspec", :name=>"nokogiri", :load_paths=>["/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/gems/nokogiri-1.4.1/lib", "/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/gems/nokogiri-1.4.1/ext"]},
        {:loaded_from=>"/Users/woolley/.rvm/gems/ruby-1.8.7-p174%global/specifications/rails-2.3.5.gemspec", :name=>"rails", :load_paths=>["/Users/woolley/.rvm/gems/ruby-1.8.7-p174%global/gems/rails-2.3.5/lib"]},
        {:loaded_from=>"/Users/woolley/.rvm/gems/ruby-1.8.7-p174%global/specifications/rspec-1.3.0.gemspec", :name=>"rspec", :load_paths=>["/Users/woolley/.rvm/gems/ruby-1.8.7-p174%global/gems/rspec-1.3.0/lib"]},
        {:loaded_from=>"/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/specifications/rspec-rails-1.3.2.gemspec", :name=>"rspec-rails", :load_paths=>["/Users/woolley/.rvm/gems/ruby-1.8.7-p174%pulse/gems/rspec-rails-1.3.2/lib"]},
      ].map do |hash|
    if hash[:virtual_spec]
      spec = eval(hash[:virtual_spec], binding, "<virtual spec for '#{hash[:name]}'>")
    else
      dir = File.dirname(hash[:loaded_from])
      spec = Dir.chdir(dir){ eval(File.read(hash[:loaded_from]), binding, hash[:loaded_from]) }
    end
    spec.loaded_from = hash[:loaded_from]
    spec.require_paths = hash[:load_paths]
    spec
  end

  extend SharedHelpers

  def self.configure_gem_path_and_home(specs)
    # Fix paths, so that Gem.source_index and such will work
    paths = specs.map{|s| s.installation_path }
    paths.flatten!; paths.compact!; paths.uniq!; paths.reject!{|p| p.empty? }
    ENV['GEM_PATH'] = paths.join(File::PATH_SEPARATOR)
    ENV['GEM_HOME'] = paths.first
    Gem.clear_paths
  end

  def self.match_fingerprint
    print = Digest::SHA1.hexdigest(File.read(File.expand_path('../../Gemfile', __FILE__)))
    unless print == FINGERPRINT
      abort 'Gemfile changed since you last locked. Please `bundle lock` to relock.'
    end
  end

  def self.setup(*groups)
    match_fingerprint
    clean_load_path
    cripple_rubygems(SPECS)
    configure_gem_path_and_home(SPECS)
    SPECS.each do |spec|
      Gem.loaded_specs[spec.name] = spec
      $LOAD_PATH.unshift(*spec.require_paths)
    end
  end

  def self.require(*groups)
    groups = [:default] if groups.empty?
    groups.each do |group|
      (AUTOREQUIRES[group.to_sym] || []).each do |file, explicit|
        if explicit
          Kernel.require file
        else
          begin
            Kernel.require file
          rescue LoadError
          end
        end
      end
    end
  end

  # Setup bundle when it's required.
  setup
end
