class Member
  def initialize(response:, noko:)
    @response = response
    @noko = noko
  end

  def to_h
    section = MemberSection.new(response: response, noko: noko)
    [
      section,
      MemberPage.new(response: Scraped::Request.new(url: section.source).response)
    ].map(&:to_h).reduce(&:merge)
  end

  private

  attr_reader :response, :noko
end
