module SiteHelper

  def host(name)
    person = name.capitalize
    tag :div, :class => 'host' do
      img("hosts/x2/#{name}.png", :alt => person) + tag(:div, :class => 'name') { person }
    end
  end

end