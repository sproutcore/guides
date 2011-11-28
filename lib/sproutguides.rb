require 'redcarpet'

module Sproutguides

  class HTMLRenderer < Redcarpet::Render::HTML

    PARAGRAPH_WITH_PREFIX = /^(?:([A-Z ]+): )?(.*)$/m

    def paragraph(text)
      prefix, text = *text.match(PARAGRAPH_WITH_PREFIX)
      p = super(text)
      p.sub('<p>', "<p id='#{unique_id}' class='#{prefix}'>")
    end

    private

    def unique_id
      @unique_id ||= -1
      @unique_id += 1
      "paragraph-#{@unique_id}"
    end
  end 

end
