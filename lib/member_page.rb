require 'scraped'

class MemberPage < Scraped::HTML
  field :name do
    noko.xpath('//div[contains(@class, "distrito")]/following-sibling::div/h1/text()')
        .text
        .tidy
  end
  field :phone do
    noko.xpath('//div[contains(@class, "verticalPad") and contains(.,"Teléfono")]/text()')
        .text
        .split(':')
        .last
        .tidy
  end

  field :email do
    noko.at_xpath('//div[contains(@class, "verticalPad")]/a[@href[contains(.,"contacto")]]/text()')
        .text
        .tidy
  end
end
