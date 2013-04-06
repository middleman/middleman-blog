require 'zurb-foundation'

spec = Gem::Specification.find_by_name("zurb-foundation")
set :js_assets_paths, [File.join(spec.gem_dir, "js")]

activate :directory_indexes

activate :blog

set :top_nav_title, { :title => "Home", :target => "index.html" }
set :top_nav_items, [
  { :title => "About Me", :target => "about-me.html" },
  { :title => "Archives", :target => "archives.html" }
  # { :title => "Other Page", :target => "other-page.html" }
]

helpers do
  def link_to_with_active(title, url, class_name = 'active')
    active_class = (current_resource == sitemap.find_resource_by_path(url)) ? class_name : ''
    link_to(title, url, :class => active_class)
  end
end