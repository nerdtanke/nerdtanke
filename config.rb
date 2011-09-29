class Topic
  ATTRIBUTES = %w[ timestamp label url links ]
  attr_accessor *ATTRIBUTES

  def initialize(yaml)
    ATTRIBUTES.each do |attribute|
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
    ATTRIBUTES.each do |attribute|
      send "#{attribute}=", yaml[attribute]
    end
  end
  
  def self.all(data)
    data.podcasts.reverse.map(&Podcast.method(:new))
  end
  
  def ==(other)
    other.episode == episode
  end
  
  def regular?
    episode.is_a?(Numeric)
  end

  def title(options = {})
    title = options[:quotes] ? %{"#{label}"} : label
    regular? ? "Episode #{episode}: #{title}" : label
  end
  
  def short_title
    regular? ? "##{episode}: #{label}" : label
  end
  
  def long_title
    "#{title} (#{german_date})"
  end
  
  def summary
    topics[1..-1].map(&:label).join ', ' if topics.size > 1
  end
  
  def page
    "#{episode}.html"
  end
      
  def url
    prefix = "www." if date < Date.parse('2011-08-10') # we are no longer using the www subdomain, but if we change the item UID, all items will pop up as new in feed readers
    "http://#{prefix}nerdtanke.de/#{path}"
  end
  
  def path(format = 'mp3')
    "podcasts/#{filename}.#{format}"
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

  def social_overview
    topic_labels = topics[1..-1].map(&:label).join ', '
    "#{title(:quotes => true)}. Diese Woche mit dabei: #{topic_labels}"
  end

  def unsynced_lyrics
    topics.map do |topic|
      "Ab #{topic.timestamp}: #{topic.label}"
    end.join "\n"
  end
end

# Routes
Podcast.all(data).each do |podcast|
  page "/#{podcast.page}", :proxy => "_podcast.html", :ignore => true do
    @podcast = podcast
  end
end
page 'rss.xml', :layout => 'layout.xml'
page 'overview.html', :layout => 'layout.plain'

# Methods defined in the helpers block are available in templates
helpers do
  def host(name)
    person = name.capitalize
    content_tag :div, :class => 'host' do
      image_tag("hosts/x2/#{name}.png", :alt => person) << content_tag(:div, person, :class => 'name')
    end
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
    content_tag :div, :class => 'player' do
      audio_tag = content_tag :audio, :controls => 'controls' do
        [ source_tag(podcast, :ogg), source_tag(podcast, :mp3) ].join
      end
      link_to "Abspielen (#{podcast.duration})", '#', :class => 'play_link', 'data-audio' => CGI::escapeHTML(audio_tag)
    end
  end

  def source_tag(podcast, format)
    audio_type = { :ogg => 'audio/ogg', :mp3 => 'audio/mpeg' }[format]
    content_tag :source, :src => podcast.path(format), :type => audio_type
  end
  
  def page_title
    @podcast ? "Die Nerdtanke – #{@podcast.title}" : "Die Nerdtanke"
  end
end

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  activate :minify_css
  
  # Minify Javascript on build
  # activate :minify_javascript
  
  # Enable cache buster
  # activate :cache_buster
  
  # Use relative URLs
  activate :relative_assets
  
  # Compress PNGs after build
  # First: gem install middleman-smusher
  # require "middleman-smusher"
  # activate :smusher
  
  # Or use a different image path
  # set :http_path, "/Content/images/"
end
