require File.join(File.dirname(__FILE__), 'test_helper')

class RendererController < ActionController::Base
  def render_template
    eval(params[:eval])
    render :inline => params[:template]
  end
end

class RendererControllerTest < ActionController::TestCase
  
  def test_static_form_should_include_static_fields
    get :render_template,
      :eval => '@post = Post.new',
      :template => <<-END_TEMPLATE
        <%- form_for @post, :builder => InPlaceFormBuilder do |f| -%>
        <h1><%= f.field(:title).static('static content').text_field -%></h1>
        <%- end -%>
        END_TEMPLATE
    assert_select 'h1>input[type=text]'
  end

  def test_dynamic_form_should_include_editable_fields
    get :render_template,
      :eval => '@post = Post.new',
      :template => <<-END_TEMPLATE
        <%- form_for @post, :builder => InPlaceFormBuilder, :static => true do |f| -%>
        <h1><%= f.field(:title).static('static content').text_field -%></h1>
        <%- end -%>
        END_TEMPLATE
    assert_select 'h1', 'static content'
  end
  
  def test_static_is_optional
    get :render_template,
      :eval => '@post = Post.new',
      :template => <<-END_TEMPLATE
        <%- form_for @post, :builder => InPlaceFormBuilder do |f| -%>
        <h1><%= f.field(:title).text_field -%></h1>
        <%- end -%>
        END_TEMPLATE
    assert_select 'h1>input[type=text]'
  end
  
  def test_static_should_render_field_value
    get :render_template,
      :eval => '@post = Post.new(:title => "post title")',
      :template => <<-END_TEMPLATE
        <%- form_for @post, :builder => InPlaceFormBuilder, :static => true do |f| -%>
        <h1><%= f.field(:title).text_field -%></h1>
        <%- end -%>
        END_TEMPLATE
    assert_select 'h1', 'post title'
  end
  
  def test_should_accept_field_options
    get :render_template,
      :eval => '@post = Post.new',
      :template => <<-END_TEMPLATE
        <%- form_for @post, :builder => InPlaceFormBuilder do |f| -%>
        <h1><%= f.field(:title).text_field(:class => :mandatory) -%></h1>
        <%- end -%>
        END_TEMPLATE
    assert_select 'h1>input[class=mandatory]'
  end
end
