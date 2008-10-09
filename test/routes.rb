ActionController::Routing::Routes.draw do |map|
  map.renderer '/renderer', :controller => 'renderer', :action => 'render_template', :conditions => { :method => :get }
  map.resources :posts
end
