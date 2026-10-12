const LegacyBridge = {
  searchRows(parameters, receive) {
    fetch('/legacy/searchRows', {
      method: 'POST', headers: {'Content-Type': 'application/json'},
      body: JSON.stringify(parameters)
    }).then(response => response.json()).then(receive);
  }
};
