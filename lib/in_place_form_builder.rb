module InPlaceForm
  class FieldContext
    attr_reader :field_name
    
    def initialize field_name, form_builder
      @field_name = field_name
      @form_builder = form_builder
    end
    
    def static static_content_generator = nil
      # simply forward receiver on as result of method call if no static work to be done
      return self unless @form_builder.static?
      InPlaceForm::StaticContentProxy.new(static_content(static_content_generator), self)
    end
    
    def static_content static_content_generator = nil
      static_content_generator ||= lambda { |object, field_name| object.send(field_name) }
      case static_content_generator
        when String
          static_content_generator
        when Proc
          static_content_generator.call(@form_builder.object, field_name)
      end
    end
    
    def method_missing method_name, *args
      return static_content if @form_builder.static?
      @form_builder.send method_name, field_name, *args
    end
  end
  
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
    @static = options.delete :static
    super
  end
  
  def static?
    @static
  end
  
  def field field_name
    InPlaceForm::FieldContext.new field_name, self
  end
  
end
