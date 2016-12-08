require 'scraped'

class MemberPage < Scraped::HTML
  field :name do
    noko.xpath('//div[@class="col-sm-12 col-md-2 distrito"]/following-sibling::div[@class="col-sm-12 col-md-4"]/h1/text()')
        .text
        .tidy
  end
  field :phone do
    noko.xpath('//div[@class="col-sm-12 col-md-2 verticalPad" and contains(.,"Teléfono")]/text()')
        .text
        .split(':')
        .last
        .tidy
  end

  field :email do
    noko.at_xpath('//div[@class="col-sm-12 col-md-2 verticalPad"]/a[@href[contains(.,"contacto")]]/text()')
        .text
        .tidy
  end
end
