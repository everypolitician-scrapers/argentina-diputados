class Member
  def to_h
    {
      MemberSection.new(response: response),
      MemberPage.new(response: Scraped::Request.new(url: section.source).response)
    }.map(&:to_h).reduce(&:merge)
  end
end
