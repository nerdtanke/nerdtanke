data.podcasts.each do |podcast|
  page "#{podcast.episode}.html", :proxy => "/_podcast.html", :ignore => true do
    @podcast = podcast
  end
end

page 'rss.xml', :layout => 'layout.xml'

# Methods defined in the helpers block are available in templates
helpers do
  def host(name)
    person = name.capitalize
    content_tag :div, :class => 'host' do
      image_tag("hosts/x2/#{name}.png", :alt => person) << content_tag(:div, person, :class => 'name')
    end
  end
  
  def podcasts
    data.podcasts.reverse.map(&Podcast.method(:new))
  end

  def render_podcast(podcast)
    html = content_tag :div, :class => 'podcast' do
      headline = content_tag :h2, "#{podcast.title} (#{podcast.german_date})"
      player = player(podcast)
      download = download(podcast)
      shownotes = shownotes(podcast.topics)
      
      headline + player + download + shownotes
    end
    seven_bit_umlauts(html)
  end

  def seven_bit_umlauts(text)
    text.
    gsub('ä', 'ae').
    gsub('ö', 'oe').
    gsub('ü', 'ue').
    gsub('Ä', 'Ae').
    gsub('Ö', 'Oe').
    gsub('Ü', 'Ue').
    gsub('ß', 'ss')
  end

  def player(podcast)
    filename = podcast.filename
    content_tag :div, :class => 'player' do
      audio_tag = content_tag :audio, :controls => 'controls' do
        [ podcast_source(filename, :ogg), podcast_source(filename, :mp3) ].join
      end
      link_to "Abspielen (#{podcast.duration})", '#', :class => 'play_link', 'data-audio' => CGI::escapeHTML(audio_tag)
    end
  end

  def download(podcast)
    content_tag :div, :class => 'download' do
      link_to "Download als MP3 (#{podcast.megabytes})", podcast_path(podcast.filename), :class => 'download_link' 
    end
  end

  def podcast_path(filename, format = :mp3)
    "podcasts/#{filename}.#{format}"
  end

  def podcast_source(filename, format)
    audio_type = { :ogg => 'audio/ogg', :mp3 => 'audio/mpeg' }[format]
    content_tag :source, :src => podcast_path(filename, format), :type => audio_type
  end

  def shownotes(topics)
    content_tag :div, :class => 'shownotes' do
      headline = content_tag :h4, 'Themen und Shownotes'
      timesheet = content_tag :ul do
        topics.collect do |topic|
          content_tag :li do
            title = "Ab #{topic.timestamp}: #{topic.label}"
            link = "(#{link_to topic.link_label, topic.url, :target => '_blank'})" if topic.url
            links = topic_links(topic.links) if topic.links.any?
            [ title, link, links ].compact.join ' '
          end
        end.join
      end
      headline + timesheet
    end
  end

  def topic_links(links)
    content_tag :ul do
      links.collect do |item|
        content_tag :li do
          help = "(#{item.help})" if item.help
          [ link_to(item.label, item.url, :target => '_blank'), help ].join ' '
        end
      end.join
    end
  end

  class Topic
    ATTRIBUTES = %w[ timestamp label url links ]
    attr_accessor *ATTRIBUTES

    def initialize(yaml)
      for attribute in ATTRIBUTES
        send "#{attribute}=", yaml[attribute]
      end
      self.links ||= []
    end

    def link_label
      url.match(%r{[^/]+://([^/]+)})[1].sub(%r{^www\.}, '')
    end
  end

  class Podcast
    ATTRIBUTES = %w[ episode label date filename filesize duration ]
    attr_accessor :topics, *ATTRIBUTES

    def initialize(yaml)
      self.topics = yaml.topics ? yaml.topics.map(&Topic.method(:new)) : []
      for attribute in ATTRIBUTES
        send "#{attribute}=", yaml[attribute]
      end
    end
    
    def regular?
      episode.is_a?(Numeric)
    end

    def title
      regular? ? "Episode #{episode}: #{label}" : label
    end
    
    def short_title
      regular? ? "##{episode}: #{label}" : label
    end
    
    def summary
      topics[1..-1].map(&:label).join ', ' if topics.size > 1
    end
    
    def url
      prefix = "www." if date < Date.parse('2011-08-10') # we are no longer using the www subdomain, but if we change the item UID, all items will pop up as new in feed readers
      "http://#{prefix}nerdtanke.de/#{path}"
    end
    
    def path
      "podcasts/#{filename}.mp3"
    end
    
    def megabytes
      size = filesize ? (filesize / (1024.0 ** 2)).round : '?'
      "#{size} MB"
    end
    
    def filename
      "nerdtanke-#{episode}"
    end
    
    def pub_date
      # no Date#rfc2822 in Ruby 1.8
      Time.parse(date.to_s).rfc2822
    end
    
    def german_date
      date.strftime "%d.%m.%Y"
    end
  end
end

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  # activate :minify_css
  
  # Minify Javascript on build
  # activate :minify_javascript
  
  # Enable cache buster
  # activate :cache_buster
  
  # Use relative URLs
  # activate :relative_assets
  
  # Compress PNGs after build
  # First: gem install middleman-smusher
  # require "middleman-smusher"
  # activate :smusher
  
  # Or use a different image path
  # set :http_path, "/Content/images/"
end
