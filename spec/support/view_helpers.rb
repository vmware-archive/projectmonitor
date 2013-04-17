module ViewHelpers
  def page
    @page ||= Capybara.string(rendered)
  end
end


