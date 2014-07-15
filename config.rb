###
# Compass
###

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", :layout => false
#
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", :locals => {
#  :which_fake_page => "Rendering a fake page with a local variable" }

###
# Helpers
###

activate :directory_indexes

# Automatic image dimensions on image_tag helper
activate :automatic_image_sizes

# Reload the browser automatically whenever files change
# configure :development do
#   activate :livereload
# end

# Methods defined in the helpers block are available in templates
helpers do
   def table_of_contents
     return sitemapGen()
   end

   def sitemapGen()
    html = '<ul>'
    html << '<li class="toc-header">Pages</li>'
    resources = sitemap.resources.sort_by { |resource| resource.data["title"] or "" }
    for resource in resources
      if resource.ext == '.html'
        html << '<li>' << link_to(resource.data['title'], resource.url) << '</li>'
      end
    end
    return html << '</ul>'
   end

   def crafting_recipe(crafting, items, output)
        html = '<div class="crafting_table"><table class="crafting_grid">'
        for row in crafting do
            html << '<tr>'
            for item in row.split("") do
                html << '<td>' << link_to(image_tag('crafting_images/all_vanilla/' << items[item][1] << '.png'), 'http://minecraft.gamepedia.com/' << items[item][1]) << '</td>'
            end
            html << '</tr>'
        end
        html << '</table>'
        html << image_tag('arrow-facing-right.png', :class => 'crafting_arrow') << '<div class="crafting_output">' << image_tag('crafting_images/all_refined_relocation' << output[0] << '.png') << '</div>'
        html << '</div>'
        return html
   end
end

set :markdown_engine, :kramdown
set :markdown, :input => 'GFM'

activate :relative_assets
set :relative_links, true

set :css_dir, 'stylesheets'

set :js_dir, 'javascript'

set :images_dir, 'images'

activate :deploy do |deploy|
    deploy.method = :git
    deploy.branch = "master"
    deploy.commit_message = "Deploy source to pages with " << `git rev-parse HEAD` # git rev-parse HEAD returns the last commit hash.
end

# Build-specific configuration
configure :build do
   # For example, change the Compass output style for deployment
   activate :minify_css

   # Minify Javascript on build
   activate :minify_javascript

   activate :imageoptim do |options|

   end

   # Enable cache buster
   # activate :asset_hash

   # Use relative URLs
   # activate :relative_assets

   # Or use a different image path
   # set :http_prefix, "/Content/images/"
 end
