module ApplicationHelper
  def react_component(component_name, props = {}, options = {})
    ReactComponent.new(component_name).render(props, options)
  end
end
