module PodcastHelper

  class Topic
    attr_reader :timestamp, :label, :url, :links

    def initialize(timestamp, label, url = nil, &block)
      @timestamp = timestamp
      @label = label
      @url = url
      @links = []
      instance_eval(&block) if block_given?
    end

    def link_label
      url.match(%r{[^/]+://([^/]+)})[1].sub(%r{^www\.}, '')
    end

    def link(label, url, help = nil)
      @links << OpenStruct.new(:label => label, :url => url, :help => help)
    end
  end

  class Podcast
    def initialize(&block)
      @topics = []
      instance_eval(&block)
    end

    attr_reader :topics

    %w[ episode label date filename filesize ].each do |attribute|
      define_method attribute do |*method_args|
        instance_variable_get("@#{attribute}") or instance_variable_set("@#{attribute}", method_args.first)
      end
    end
    
    def topic(*args, &block)
      @topics << Topic.new(*args, &block)
    end
  end

  def podcast(*args, &block)
    render_podcast Podcast.new(*args, &block)
  end

  def render_podcast(podcast)
    html = tag :div, :class => 'podcast section' do
      headline = tag(:h2) { "Episode #{podcast.episode}: #{podcast.label} (#{podcast.date})" }
      player = player(podcast.filename)
      download = download(podcast.filename, podcast.filesize)
      shownotes = shownotes(podcast.topics)
      
      headline + player + download + shownotes
    end
    haml_concat html
  end

  def player(filename)
    tag :div, :class => 'player' do
      tag :audio, :controls => 'controls', :preload => 'none' do
        [ podcast_source(filename, :ogg), podcast_source(filename, :mp3) ].join
      end
    end
  end

  def download(filename, filesize)
    tag :div, :class => 'download' do
      link "Download als MP3 (#{filesize})", podcast_path(filename), :class => 'download_link' 
    end
  end

  def podcast_path(filename, format = :mp3)
    "podcasts/#{filename}.#{format}"
  end

  def podcast_source(filename, format)
    audio_type = { :ogg => 'audio/ogg', :mp3 => 'audio/mpeg' }[format]
    tag :source, :src => podcast_path(filename, format), :type => audio_type
  end
  
  def shownotes(topics)
    tag :div, :class => 'shownotes' do
      headline = tag(:h4) { 'Themen und Shownotes' }
      timesheet = tag :ul do
        topics.collect do |topic|
          tag :li do
            title = "Ab #{topic.timestamp}: #{topic.label}"
            link = "(#{link topic.link_label, topic.url, :target => '_blank'})" if topic.url
            links = topic_links(topic.links) if topic.links.any?
            [ title, link, links ].compact.join ' '
          end
        end.join
      end
      headline + timesheet
    end
  end

  def topic_links(links)
    tag :ul do
      links.collect do |item|
        tag :li do
          help = "(#{item.help})" if item.help
          [ link(item.label, item.url), help ].join ' '
        end
      end.join
    end
  end

end
