guard 'coffeescript', input: 'spec/javascripts', output: 'spec/javascripts/compiled'
guard 'coffeescript', input: 'app/assets/javascripts', output: 'assets'

guard 'livereload' do
  watch(%r{app/views/.+\.(erb|haml|slim)$})
  watch(%r{(app|vendor)(/assets/\w+/(.+\.(css|sass|scss|js|html|coffee|eco))).*}) { |m| "/assets/#{m[3]}" }
end

guard 'ctags-bundler', :src_path => ["app", "lib", "spec/support"] do
  watch(/^(app|lib|spec\/support)\/.*\.rb$/)
  watch('Gemfile.lock')
end
