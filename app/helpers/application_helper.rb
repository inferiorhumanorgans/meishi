module ApplicationHelper
  ##
  # From Railscast 197: http://railscasts.com/episodes/197-nested-model-form-part-2
  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)", :class => 'add-on')
  end
  
  ##
  # From Railscast 197: http://railscasts.com/episodes/197-nested-model-form-part-2
  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")")
  end
  
  def navlink_toplevel(description, target_controller, url)
    content_tag :li, :class => ((target_controller =~ controller.controller_name) ? 'active' : '') do
      link_to description, url
    end
  end
end