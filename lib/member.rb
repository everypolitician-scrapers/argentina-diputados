require 'scraped'

class Member < Scraped::HTML
  field :section do
    @section ||= MemberSection.new(response: response, noko: noko)
  end

  field :page do
    @page ||= MemberPage.new(response: Scraped::Request.new(url: section.source).response)
  end
end
