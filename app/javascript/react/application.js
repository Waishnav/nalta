import React from "react";
import ReactDOM from "react-dom/client";
import { intersection, keys, assign, omit } from "lodash-es";

const CLASS_ATTRIBUTE_NAME = "data-react-class";
const PROPS_ATTRIBUTE_NAME = "data-react-props";

const ReactComponent = {
  registeredComponents: {},
  componentRoots: {},

  render(node, component) {
    const propsJson = node.getAttribute(PROPS_ATTRIBUTE_NAME);
    const props = propsJson && JSON.parse(propsJson);

    const reactElement = React.createElement(component, props);
    const root = ReactDOM.createRoot(node);

    root.render(reactElement);

    return root;
  },

  registerComponents(components) {
    const collisions = intersection(
      keys(this.registeredComponents),
      keys(components)
    );
    if (collisions.length > 0) {
      console.error(
        `Following components are already registered: ${collisions}`
      );
    }

    assign(this.registeredComponents, omit(components, collisions));
    return true;
  },

  mountComponents() {
    const { registeredComponents } = this;
    const toMount = document.querySelectorAll(`[${CLASS_ATTRIBUTE_NAME}]`);

    for (let i = 0; i < toMount.length; i += 1) {
      const node = toMount[i];
      const className = node.getAttribute(CLASS_ATTRIBUTE_NAME);
      const component = registeredComponents[className];

      if (component) {
        if (node.innerHTML.length === 0) {
          const root = this.render(node, component);

          this.componentRoots = { ...this.componentRoots, [className]: root };
        }
      } else {
        console.error(
          `Can not render a component that has not been registered: ${className}`
        );
      }
    }
  },

  setup(components = {}) {
    if (typeof window.ReactComponent === "undefined") {
      window.ReactComponent = this;
    }

    window.ReactComponent.registerComponents(components);
    window.ReactComponent.mountComponents();
  },
};

export default ReactComponent;
