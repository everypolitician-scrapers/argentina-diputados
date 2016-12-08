require 'scraped'

class MembersPage < Scraped::HTML
  field :members do
    noko.css('#tablaPpal table td a[href*="/diputados/"]').map do |a|
      MemberSection.new(response: response, noko: a)
    end
  end
end
