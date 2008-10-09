module InPlaceForm
  class StaticContentProxy
    def initialize static_content, form_builder
      @static_content = static_content
      @form_builder   = form_builder
    end
    
    def method_missing *args
      @static_content
    end
  end
end

class InPlaceFormBuilder < ActionView::Helpers::FormBuilder
  def initialize object_name, object, template, options, proc
    @static = options.delete(:static)
    super
  end
  def static static_content
    @static ?InPlaceForm::StaticContentProxy.new(static_content, self) :  self
  end
end
