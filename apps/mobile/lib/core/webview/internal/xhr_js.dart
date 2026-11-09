// JS injected at document-start to intercept XHR and fetch responses.
// Results are forwarded to the '_wk_xhr' JS channel handled by WebViewCubit.
const String kXhrInterceptorJs = r'''
(function() {
  const _ch = '_wk_xhr';

  function _notify(url, method, status, body) {
    try {
      window.flutter_inappwebview.callHandler(_ch, JSON.stringify({
        url: url, method: method, status: status, body: body
      }));
    } catch (_) {}
  }

  // ── XHR ──────────────────────────────────────────────────────────────────
  const OrigXHR = window.XMLHttpRequest;
  function XHRProxy() {
    const xhr = new OrigXHR();
    let _method = 'GET', _url = '';

    const origOpen = xhr.open.bind(xhr);
    xhr.open = function(method, url) {
      _method = method; _url = url;
      return origOpen.apply(xhr, arguments);
    };

    xhr.addEventListener('loadend', function() {
      _notify(_url, _method, xhr.status, xhr.responseText);
    });

    return xhr;
  }
  XHRProxy.prototype = OrigXHR.prototype;
  window.XMLHttpRequest = XHRProxy;

  // ── fetch ────────────────────────────────────────────────────────────────
  const origFetch = window.fetch.bind(window);
  window.fetch = function(resource, init) {
    const url  = (typeof resource === 'string') ? resource : resource.url;
    const meth = (init && init.method) ? init.method.toUpperCase() : 'GET';
    return origFetch(resource, init).then(function(response) {
      response.clone().text().then(function(body) {
        _notify(url, meth, response.status, body);
      });
      return response;
    });
  };
})();
''';
