require 'zurb-foundation'

spec = Gem::Specification.find_by_name("zurb-foundation")
set :js_assets_paths, [File.join(spec.gem_dir, "js")]

activate :directory_indexes

activate :blog

set :blog_name, "Deep Thoughts"
set :blog_author, "Nick Adams"
set :blog_avatar, "http://www.gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50"
set :top_nav_title, { :title => "Home", :target => "index.html" }
set :top_nav_items, [
  { :title => "About Me", :target => "about-me.html" },
  { :title => "Archives", :target => "archives.html" }
  # { :title => "Other Page", :target => "other-page.html" }
]

helpers do
  def page_title
    title = blog_name.dup
    if current_page.data.title
      title << ": #{current_page.data.title}"
    elsif is_blog_article?
      title << ": #{current_article.title}"
    end
    title
  end

  def link_to_with_active(title, url, class_name = 'active')
    active_class = (current_resource == sitemap.find_resource_by_path(url)) ? class_name : ''
    link_to(title, url, :class => active_class)
  end
end