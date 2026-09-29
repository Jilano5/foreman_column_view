// The column definitions are published by the plugin in the Foreman app
// metadata, which is rendered in the props of the ReactApp component.
const readColumns = () => {
  const reactApp = document.querySelector(
    'foreman-react-component[name="ReactApp"]'
  );
  if (!reactApp) return undefined;
  try {
    const props = JSON.parse(reactApp.getAttribute('data-props'));
    return props?.metadata?.foreman_column_view?.columns || [];
  } catch (e) {
    return [];
  }
};

// Plugin modules are loaded asynchronously, normally once the page has been
// parsed; wait for it otherwise.
export const onColumnsReady = callback => {
  const columns = readColumns();
  if (columns !== undefined) {
    callback(columns);
    return;
  }
  document.addEventListener(
    'DOMContentLoaded',
    () => callback(readColumns() || []),
    { once: true }
  );
};

export default onColumnsReady;
