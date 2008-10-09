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

module InPlaceFormBuilderHelper
  def self.included base
    base.helper InPlaceFormBuilderViewHelper
    super
  end
  
  module InPlaceFormBuilderViewHelper
    # This method is lifted essentially wholesale from
    # ActionView::Helpers::FormHelper
    # The underlying method could use some refactoring
    # so I don't have to duplicate so much.
    def form_for(record_or_name_or_array, *args, &proc)
      raise ArgumentError, "Missing block" unless block_given?
    
      options = args.extract_options!
    
      case record_or_name_or_array
      when String, Symbol
        object_name = record_or_name_or_array
      when Array
        object = record_or_name_or_array.last
        object_name = ActionController::RecordIdentifier.singular_class_name(object)
        apply_form_for_options!(record_or_name_or_array, options)
        args.unshift object
      else
        object = record_or_name_or_array
        object_name = ActionController::RecordIdentifier.singular_class_name(object)
        apply_form_for_options!([object], options)
        args.unshift object
      end
      
      static = options[:static]
      url = options.delete(:url) || {}
      html_options = options.delete(:html) || {}
      form_contents = fields_for(object_name, *(args << options), &proc)
      if static
        form_contents
      else
        concat(form_tag(url, html_options), proc.binding)
        form_contents
        concat('</form>', proc.binding)
      end
    end
  end
end
