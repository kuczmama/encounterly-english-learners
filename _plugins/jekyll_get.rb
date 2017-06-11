# https://github.com/18F/jekyll-get/blob/master/_plugins/jekyll_get.rb
require 'json'
require 'hash-joiner'
require 'open-uri'

module Jekyll_Get
  class Generator < Jekyll::Generator
    safe true
    priority :highest

    def generate(site)
      config = site.config['jekyll_get']
      if !config
        return
      end
      if !config.kind_of?(Array)
        config = [config]
      end
      config.map do |d|
        begin
          target = site.data[d['name']]
          source = JSON.load(open(d['site']))
          if target
            HashJoiner.deep_merge target, source
          else
            site.data[d['name']] = source
          end
          if d['cache']
            data_source = (site.config['data_source'] || '_data')
            path = "#{data_source}/#{d['name']}.json"
            open(path, 'wb') do |file|
              file << JSON.generate(site.data[d['name']])
            end
          end
        rescue
          next
        end
      end
      # Generate some new posts with the data
      site.data['events'].each do |event|
        time = Time.at(event['time'] / 1000)
        file = "_posts/#{time.strftime("%F")}-tokyo-english-learners.markdown"
        #file = "_posts/#{time.strftime("%F")}-#{event['name'].downcase.gsub('[^\x00-\x7F]','').gsub('-',' ').gsub(/\s+/, ' ').gsub(' ','-').gsub('.','').gsub(':','&#58')}.markdown"
        `touch #{file}`
        %x(cat > #{file} <<EOF
---
layout: post
title:  "#{event['name']}"
date:   #{time}
categories: jekyll update
---
<a href="#{event['link']}">View on Meetup.com</a>
<div>
#{event['description'].gsub("<img\ src=\".*\.jpegh","<img src=\"")}
</div>
<a href="#{event['link']}">View on Meetup.com</a>
EOF)
        #{}`touch _posts/#{Time.at(event.time / 1000).strftime("%y-%m-%d")}-#{event.name}.markdown`
      end
      
      #[{{site.data.events[0].name}}]({{site.data.events[0].link}}) 
    end
  end
end