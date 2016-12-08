require 'scraped'

class Member < Scraped::HTML
  field :member_section do
    @member_section ||= MemberSection.new(response: response, noko: noko)
  end

  field :member_page do
    @member_page ||= MemberPage.new(response: Scraped::Request.new(url: member_section.source).response)
  end
end
