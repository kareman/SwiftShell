# Jekyll Module to create monthly archive pages
#
# Shigeya Suzuki, November 2013
# Copyright notice (MIT License) attached at the end of this file
#

#
# This code is based on the following works:
#   https://gist.github.com/ilkka/707909
#   https://gist.github.com/ilkka/707020
#   https://gist.github.com/nlindley/6409459
#

#
# Archive will be written as #{archive_path}/#{year}/#{month}/index.html
# archive_path can be configured in 'path' key in 'monthly_archive' of
# site configuration file. 'path' is default null.
#

module Jekyll

  # Generator class invoked from Jekyll
  class ArchiveGenerator < Generator
    def generate(site)
      # get posts grouped by month and year
      year_month_posts = posts_group_by_year_and_month(site)
      year_month_posts.each_with_index do |(ym, list), index|
        # initialize previous / next

        # get previous year & month if they exist
        previousYear = (index > 0) && year_month_posts.keys[index - 1][0] || nil
        previousMonth = previousYear && year_month_posts.keys[index - 1][1] || nil

        # get next year & month if they exist
        nextYear = (index < year_month_posts.length - 1) && year_month_posts.keys[index + 1][0] || nil
        nextMonth = nextYear && year_month_posts.keys[index + 1][1] || nil

        site.pages << MonthlyArchivePage.new(site, archive_base(site),
                                             ym[0], ym[1], list,
                                             previousYear, previousMonth,
                                             nextYear, nextMonth)
      end

      year_posts = posts_group_by_year(site)
      year_posts.each_with_index do |(year, list), index|
        # initialize previous / next
        previousYear = (index > 0) && year_posts.keys[index - 1] || nil
        nextYear = (index < year_posts.length - 1) && year_posts.keys[index + 1] || nil

        site.pages << YearlyArchivePage.new(site, archive_base(site),
                                             year, list,
                                             previousYear, nextYear)
      end
    end

    def posts_group_by_year_and_month(site)
      site.posts.each.group_by { |post| [post.date.year, post.date.month] }
    end

    def posts_group_by_year(site)
      site.posts.each.group_by { |post| post.date.year }
    end

    def archive_base(site)
      site.config['monthly_archive'] && site.config['monthly_archive']['path'] || ''
    end
  end

  # Actual page instances
  class MonthlyArchivePage < Page

    ATTRIBUTES_FOR_LIQUID = %w[
      year,
      month,
      date,
      content
    ]

    def initialize(site, dir, year, month, posts, previousYear, previousMonth, nextYear, nextMonth)
      @site = site
      @dir = dir
      @year = year
      @month = month
      @archive_dir_name = '%04d/%02d' % [year, month]
      @date = Date.new(@year, @month)
      @layout =  site.config['monthly_archive'] && site.config['monthly_archive']['layout'] || 'monthly_archive'
      @previousArchive = previousYear && '%04d/%02d' % [previousYear, previousMonth] || nil
      @nextArchive = nextYear && '%04d/%02d' % [nextYear, nextMonth] || nil
      self.ext = '.html'
      self.basename = 'index'
      self.data = {
          'layout' => @layout,
          'type' => 'archive',
          'title' => "Monthly archive for #{month}/#{year}",
          'posts' => posts.reverse,
          'previousArchive' => @previousArchive,
          'nextArchive' => @nextArchive
      }
    end

    def render(layouts, site_payload)
      payload = {
          'page' => self.to_liquid,
          'paginator' => pager.to_liquid
      }.merge(site_payload)
      do_layout(payload, layouts)
    end

    def to_liquid(attr = nil)
      self.data.merge({
           'content' => self.content,
           'date' => @date,
           'month' => @month,
           'year' => @year
       })
    end

    def destination(dest)
      File.join('/', dest, @dir, @archive_dir_name, 'index.html')
    end

  end

  class YearlyArchivePage < MonthlyArchivePage

    def initialize(site, dir, year, posts, previousYear, nextYear)
      @site = site
      @dir = dir
      @year = year
      @archive_dir_name = '%04d' % [year]
      @date = Date.new(@year)
      @layout =  site.config['monthly_archive'] && site.config['monthly_archive']['year_layout'] || 'yearly_archive'
      @previousArchive = previousYear && '%04d' % [previousYear] || nil
      @nextArchive = nextYear && '%04d' % [nextYear] || nil
      self.ext = '.html'
      self.basename = 'index'
      self.data = {
          'layout' => @layout,
          'type' => 'archive',
          'title' => "Archive for #{year}",
          'posts' => posts.reverse,
          'previousArchive' => @previousArchive,
          'nextArchive' => @nextArchive
      }
    end

  end

end

# The MIT License (MIT)
#
# Copyright (c) 2013 Shigeya Suzuki
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
