xml.instruct!
xml.rss :version => '2.0' do
  xml.channel do
    xml.title title
    xml.link root_url
    xml.description "Most recent builds and their status"

    @projects.each do |project|
        xml.item do
          xml.title "#{project.name} #{project.status.in_words}"
          xml.link project.status.url
          xml.description status_messages_for(project).map(&:last).join(". ") + "."
          xml.pubDate project.status.published_at
        end
    end
  end
end
