module Jekyll

  class TagIndex < Page
  
    def initialize(site, base, dir, tag, posts)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      tag_title_prefix = site.config['tag_title_prefix'] || 'Posts tagged <strong>'
      tag_title_suffix = site.config['tag_title_suffix'] || '</strong>'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'tag_index.html')
      self.data['tag'] = tag
      self.data['title'] = "#{tag_title_prefix}#{tag}#{tag_title_suffix}"
      self.data['posts'] = posts.reverse
    end
    
  end
  
  class TagGenerator < Generator
    safe true
    
    def generate(site)
      if site.layouts.key? 'tag_index'
        dir = site.config['tag_dir'] || 'tag'
        site.tags.keys.each do |tag|
          write_tag_index(site, File.join(dir, tag), tag)
        end
      end
    end
    
    def write_tag_index(site, dir, tag)
      list = posts_with_tag(site, tag)
      index = TagIndex.new(site, site.source, dir, tag, list)
      index.render(site.layouts, site.site_payload)
      index.write(site.dest)
      site.pages << index
    end
    
    def posts_with_tag(site, tag)
      site.posts.select { |post| post.tags.include?(tag) }
    end
    
  end
  
end
