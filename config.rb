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
# activate :automatic_image_sizes

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
    html << "<li class='header'>Pages</li>"
    html << getListElementForResource(sitemap.find_resource_by_destination_path("/index.html"))
    html << getSitemapForResource(sitemap.find_resource_by_destination_path("/index.html"))
    return html << '</ul>'
   end

    def getSitemapForResource(resource)
        html = ''

        if resource.children.length > 0
            if resource.url != "/"
                html << '<ul>'
            end

            children = resource.children
            children.sort_by! { |child| -child.children.length } # Make resources who have children appear first
            begin
                children.sort_by! { |child| child.data.sort_order || children.length }
            rescue
                children.sort_by! { |child| child.data.title || "" }
            end

            children.each do |child|
                if !child.data.title
                    next
                end
                childHtml = getSitemapForResource(child)
                html << '<li>'

                if child.path.include?("index") && child.children.length > 0 # Is parent
                    checkedStr = ''
                    if child == current_page || child.children.include?(current_page)
                        checkedStr = 'checked'
                    end

                    html << "<input #{checkedStr} type='checkbox' id='checkbox_#{child.path}' />"
                    html << "<label for='checkbox_#{child.path}'>#{getResourceLink(child)}</label>"
                else
                    html << link_to(child.data.title, child.url)
                end

                html << childHtml
                html << '</li>'
            end

            if resource.url != "/"
                html << '</ul>'
            end
        end

        return html == "<ul></ul>" ? "" : html # Checks if all children were skipped
    end

  def getListElementForResource(resource)
    return '<li>' << getResourceLink(resource) << '</li>'
  end

  def getResourceLink(resource)
    if resource.data["nolink"]
        return !resource.data['title'] ? resource.path : resource.data['title']
    else
        return link_to(!resource.data['title'] ? resource.path : resource.data['title'], resource.url);
    end
  end

  def generate_recipes(crafting_recipes)
    html = ''
    for recipe in crafting_recipes["recipes"] do
      html << crafting_recipe(recipe)
    end
    return html
  end

   def crafting_recipe(crafting_recipe)
    html = '<table class="crafting_table"><tr class="crafting_name"><td colspan="4">' + (crafting_recipe["name"] || "Crafting Recipe") + '</td></tr><tr><td><table class="crafting_grid">'
        for rowCounter in 0..2 do # 3 rows
            row = crafting_recipe["rows"][rowCounter]
            if row != nil
              html << '<tr>'
              for counter in 0..2 do # 3 items pwer row
                begin
                  if row[counter] != nil
                    html << '<td class="item_slot">' + link_to(row[counter]["displayName"], row[counter]["wikiLink"]) + '</td>'
                  end
                rescue Exception => e
                  html << '<td class="item_slot"></td>'
                end
              end
              html << "</tr>"
            end
        end

        html << "</table></td>"

        html << "<td><table><tr><td class='crafting_arrow'></td></tr></table></td>"

        html << "<td><table><tr><td class='item_slot round_corners'>" << link_to(crafting_recipe["output"]["displayName"]) << "</td></tr></table></td>"

        html << "</tr></table>"
        return html
   end

   def link(link_content, link_id)
    # return "<a href='#{links[link_id]}'>#{link_content}</a>"
    return link_to(link_content, links[link_id])
   end
end

set :markdown_engine, :kramdown
set :markdown, :input => 'GFM'

activate :relative_assets
set :relative_links, true

set :css_dir, 'stylesheets'
set :js_dir, 'javascript'
set :images_dir, 'images'

config[:links] = {
  'disguise' => "/block_extenders/block_extenders.html#disguising",
  'filter' => "/filtering.html",

  'regular-block-extender' => "/block_extenders/block_extender_regular.html",
  'filtered-block-extender' => "/block_extenders/block_extender_filtered.html",
  'advanced-block-extender' => "/block_extenders/block_extender_advanced.html",
  'advanced-filtered-block-extender' => "/block_extenders/block_extender_advanced_filtered.html",
  'wireless-block-extender' => "/block_extenders/block_extender_wireless.html",

  'regular-buffer' => "/buffers/buffer_regular.html",
  'filtered-buffer' => "/buffers/buffer_filtered.html",
  'advanced-buffer' => "/buffers/buffer_advanced.html",

  'relocator' => "/relocators/index.html"
}

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

   activate :favicon_maker, :icons => {
    "favicon_template.png" => [
        { icon: "apple-touch-icon-152x152-precomposed.png" },             # Same as apple-touch-icon-57x57.png, for retina iPad with iOS7.
        { icon: "apple-touch-icon-144x144-precomposed.png" },             # Same as apple-touch-icon-57x57.png, for retina iPad with iOS6 or prior.
        { icon: "apple-touch-icon-120x120-precomposed.png" },             # Same as apple-touch-icon-57x57.png, for retina iPhone with iOS7.
        { icon: "apple-touch-icon-114x114-precomposed.png" },             # Same as apple-touch-icon-57x57.png, for retina iPhone with iOS6 or prior.
        { icon: "apple-touch-icon-76x76-precomposed.png" },               # Same as apple-touch-icon-57x57.png, for non-retina iPad with iOS7.
        { icon: "apple-touch-icon-72x72-precomposed.png" },               # Same as apple-touch-icon-57x57.png, for non-retina iPad with iOS6 or prior.
        { icon: "apple-touch-icon-60x60-precomposed.png" },               # Same as apple-touch-icon-57x57.png, for non-retina iPhone with iOS7.
        { icon: "apple-touch-icon-57x57-precomposed.png" },               # iPhone and iPad users can turn web pages into icons on their home screen. Such link appears as a regular iOS native application. When this happens, the device looks for a specific picture. The 57x57 resolution is convenient for non-retina iPhone with iOS6 or prior. Learn more in Apple docs.
        { icon: "apple-touch-icon-precomposed.png", size: "57x57" },      # Same as apple-touch-icon.png, expect that is already have rounded corners (but neither drop shadow nor gloss effect).
        { icon: "apple-touch-icon.png", size: "57x57" },                  # Same as apple-touch-icon-57x57.png, for "default" requests, as some devices may look for this specific file. This picture may save some 404 errors in your HTTP logs. See Apple docs
        { icon: "favicon-196x196.png" },                                  # For Android Chrome M31+.
        { icon: "favicon-160x160.png" },                                  # For Opera Speed Dial (up to Opera 12; this icon is deprecated starting from Opera 15), although the optimal icon is not square but rather 256x160. If Opera is a major platform for you, you should create this icon yourself.
        { icon: "favicon-96x96.png" },                                    # For Google TV.
        { icon: "favicon-32x32.png" },                                    # For Safari on Mac OS.
        { icon: "favicon-16x16.png" },                                    # The classic favicon, displayed in the tabs.
        { icon: "favicon.png", size: "16x16" },                           # The classic favicon, displayed in the tabs.
        { icon: "favicon.ico", size: "64x64,32x32,24x24,16x16" },         # Used by IE, and also by some other browsers if we are not careful.
        { icon: "mstile-70x70.png", size: "70x70" },                      # For Windows 8 / IE11.
        { icon: "mstile-144x144.png", size: "144x144" },
        { icon: "mstile-150x150.png", size: "150x150" },
        { icon: "mstile-310x310.png", size: "310x310" },
        { icon: "mstile-310x150.png", size: "310x150" }
      ]
  }

   # activate :imageoptim do |options|
   #  options.pngcrush_options = { :chunks => [''], :fix => false }
   # end

   # Enable cache buster
   # activate :asset_hash

   # Use relative URLs
   # activate :relative_assets

   # Or use a different image path
   # set :http_prefix, "/Content/images/"
 end
