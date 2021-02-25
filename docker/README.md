# Nginx configuration snippet

It is tested for angular application.

```conf
server {
  ....
  # to disable showwing nginx version
  server_tokens off;
  # config to don't allow the browser to render the page inside an frame or iframe
  add_header X-Frame-Options DENY;
  # when serving user-supplied content, include a X-Content-Type-Options: nosniff header along with the Content-Type: header,
  # to disable content-type sniffing on some browsers.
  add_header X-Content-Type-Options nosniff;
  # This header enables the Cross-site scripting (XSS) filter built into most recent web browsers.
  # It's usually enabled by default anyway, so the role of this header is to re-enable the filter for
  # this particular website if it was disabled by the user.
  add_header X-XSS-Protection "1; mode=block";
  # with Content Security Policy (CSP) enabled(and a browser that supports it(http://caniuse.com/#feat=contentsecuritypolicy),
  # you can tell the browser that it can only download content from the domains you explicitly allow
  add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://www.google-analytics.com https://www.googletagmanager.com; img-src 'self' https://www.google-analytics.com/collect https://*.blob.core.windows.net data:; style-src 'self' 'unsafe-inline'; font-src 'self'; connect-src 'self' https://www.google-analytics.com https://geoip-db.com; object-src 'none'";
  # Refferer-Policy
  add_header Referrer-Policy same-origin;
  # Strict Trasport Security
  add_header Strict-Transport-Security 'max-age=31536000; includeSubDomains; preload';
  # Feature-Policy
  add_header Feature-Policy "geolocation 'self' https://geoip-db.com; microphone 'none'; camera 'none'; payment 'none'";
  ...
  }
```
The site configuation could be valited by several sites. One of the most popular and recommended sites is <a href="https://securityheaders.com/">https://securityheaders.com/</a>
