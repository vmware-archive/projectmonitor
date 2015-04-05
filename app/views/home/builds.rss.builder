xml.instruct!
xml.rss version: '2.0' do
  xml.channel do
    xml.title 'Project Monitor'
    xml.link root_url
    xml.description 'Most recent builds and their status'

    @projects.each do |project|
      xml.item do
        xml.title "#{project.name} #{project.status.in_words}"
        xml.link project.status.url
        xml.guid project.code
        xml.description static_status_messages_for(project).join('. ') + '.'
        xml.pubDate project.status.published_at
      end
    end
  end
end
