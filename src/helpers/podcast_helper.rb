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

    %w[ episode label date filename filesize duration ].each do |attribute|
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
    html = tag :div, :class => 'podcast' do
      headline = tag(:h2) do
        html = ''
        html << "Episode #{podcast.episode}: " if podcast.episode
        html << "#{podcast.label} (#{podcast.date})"
        html
      end
      player = player(podcast)
      download = download(podcast)
      shownotes = shownotes(podcast.topics)
      
      headline + player + download + shownotes
    end
    haml_concat seven_bit_umlauts(html)
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
    tag :div, :class => 'player' do
      audio_tag = tag :audio, :controls => 'controls' do
        [ podcast_source(filename, :ogg), podcast_source(filename, :mp3) ].join
      end
      link "Abspielen (#{podcast.duration})", '#', :class => 'play_link', 'data-audio' => CGI::escapeHTML(audio_tag)
    end
  end

  def download(podcast)
    tag :div, :class => 'download' do
      link "Download als MP3 (#{podcast.filesize})", podcast_path(podcast.filename), :class => 'download_link' 
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
          [ link(item.label, item.url, :target => '_blank'), help ].join ' '
        end
      end.join
    end
  end

end
