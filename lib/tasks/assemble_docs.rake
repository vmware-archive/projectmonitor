desc "Assemble dynamic markdown doc(s) from component docs"
task :assemble_docs => :environment do
  output_text = ''
  output_file = Rails.root.join('docs', 'adding_a_project.md')
  adding_a_file_directory = Rails.root.join('docs', 'adding_a_project')
  Dir[adding_a_file_directory.join('*.md')].each do |file|
    output_text << File.read(file)
  end
  File.write(output_file, output_text)
end
