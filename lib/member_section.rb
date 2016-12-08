require 'scraped'

class MemberSection < Scraped::HTML
  field :id do
    noko.attr('href').split("/").last
  end

  field :name do
    member_page.name
  end

  field :sort_name do
    noko.text.tidy
  end

  field :email do
    member_page.email
  end

  field :phone do
    member_page.phone
  end

  field :district do
    noko.xpath('following::td')[0].text.tidy
  end

  field :mandate_start do
    date_from(noko.xpath('following::td')[1].text.tidy).to_s
  end

  field :mandate_end do
    date_from(noko.xpath('following::td')[2].text.tidy).to_s
  end

  field :party do
    noko.xpath('following::td')[3].text.tidy
  end

  field :term do
    133
  end

  field :source do
     URI.join(url, noko.attr('href')).to_s
  end

  field :start_date do
    mandate_start if mandate_start > '2015-01-01'
  end

  field :end_date do
    mandate_end if mandate_end < '2015-12-31'
  end

  field :image do
    noko.css('.imge-circle/@src').text
  end

  private

  def date_from(str)
    return if str.to_s.empty?
    Date.parse str
  end

  def mandate_start
    date_from(noko.xpath('following::td')[1].text.tidy).to_s
  end

  def mandate_end
    date_from(noko.xpath('following::td')[2].text.tidy).to_s
  end

  def member_page
    @member_page ||= MemberPage.new(response: Scraped::Request.new(url: source).response)
  end
end
