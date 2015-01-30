require 'japr'

module JAPR
  # LESS Converter
  class LessConverter < JAPR::Converter
    require 'less'

    def self.filetype
      '.less'
    end

    def convert
      return Less::Parser.new.parse(@content).to_css
    end
  end
  
  # Overrides for double quote
  class CssTagTemplate < JAPR::Template
    def html
      "<link href=\"/#{@path}/#{@filename}\" rel=\"stylesheet\" type=\"text/css\" />"
    end
  end
  class JavaScriptTagTemplate < JAPR::Template
    def html
      "<script src=\"/#{@path}/#{@filename}\" type=\"text/javascript\"></script>"
    end
  end
end
