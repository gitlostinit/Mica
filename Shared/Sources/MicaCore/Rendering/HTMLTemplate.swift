import Foundation

public enum HTMLTemplate {

    public static func wrap(_ body: String, title: String) -> String {
        """
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <title>\(escapeHTML(title))</title>
          <style>\(css)</style>
        </head>
        <body>
          <article class="markdown-body">
            \(body)
          </article>
        </body>
        </html>
        """
    }

    private static func escapeHTML(_ s: String) -> String {
        s.replacingOccurrences(of: "&", with: "&amp;")
         .replacingOccurrences(of: "<", with: "&lt;")
         .replacingOccurrences(of: ">", with: "&gt;")
    }

    static let css = """
    :root {
      --bg: #ffffff;
      --bg-secondary: #f6f8fa;
      --text: #1f2328;
      --text-muted: #656d76;
      --border: #d0d7de;
      --link: #0969da;
      --link-wikilink: #7c5cbf;
      --code-bg: #f6f8fa;
      --mark-bg: #fff3b0;
      --callout-note: #448aff;
      --callout-tip: #00bcd4;
      --callout-warning: #ff9100;
      --callout-danger: #ff1744;
      --callout-success: #4caf50;
      --callout-question: #9c27b0;
      --callout-bug: #f44336;
      --callout-example: #7e57c2;
      --callout-quote: #9e9e9e;
    }
    @media (prefers-color-scheme: dark) {
      :root {
        --bg: #0d1117;
        --bg-secondary: #161b22;
        --text: #e6edf3;
        --text-muted: #848d97;
        --border: #30363d;
        --link: #58a6ff;
        --link-wikilink: #c084fc;
        --code-bg: #161b22;
        --mark-bg: #5a4f1a;
      }
    }
    * { box-sizing: border-box; }
    html { font-size: 16px; }
    body {
      background: var(--bg);
      color: var(--text);
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", system-ui, sans-serif;
      line-height: 1.7;
      margin: 0;
      padding: 0;
    }
    article.markdown-body {
      max-width: 780px;
      margin: 0 auto;
      padding: 2rem 1.5rem 4rem;
    }
    h1, h2, h3, h4, h5, h6 {
      font-weight: 600;
      line-height: 1.3;
      margin: 1.5em 0 0.5em;
    }
    h1 { font-size: 2em; border-bottom: 1px solid var(--border); padding-bottom: .3em; }
    h2 { font-size: 1.5em; border-bottom: 1px solid var(--border); padding-bottom: .3em; }
    h3 { font-size: 1.25em; }
    p { margin: 0.8em 0; }
    a { color: var(--link); text-decoration: none; }
    a:hover { text-decoration: underline; }
    a.wikilink { color: var(--link-wikilink); }
    a.wikilink::before { content: "[["; opacity: .5; font-size: .85em; }
    a.wikilink::after  { content: "]]"; opacity: .5; font-size: .85em; }
    mark { background: var(--mark-bg); border-radius: 2px; padding: 0 2px; }
    code {
      background: var(--code-bg);
      border: 1px solid var(--border);
      border-radius: 4px;
      font-family: "SF Mono", ui-monospace, monospace;
      font-size: .875em;
      padding: .1em .4em;
    }
    pre {
      background: var(--code-bg);
      border: 1px solid var(--border);
      border-radius: 8px;
      overflow-x: auto;
      padding: 1rem;
    }
    pre code { background: none; border: none; padding: 0; font-size: .875em; }
    blockquote {
      border-left: 3px solid var(--border);
      color: var(--text-muted);
      margin: 1em 0;
      padding: .5em 1em;
    }
    table { border-collapse: collapse; width: 100%; margin: 1em 0; }
    th, td { border: 1px solid var(--border); padding: .5em .75em; text-align: left; }
    th { background: var(--bg-secondary); font-weight: 600; }
    ul, ol { padding-left: 2em; margin: .5em 0; }
    li { margin: .2em 0; }
    hr { border: none; border-top: 1px solid var(--border); margin: 2em 0; }
    img { max-width: 100%; border-radius: 6px; }
    .callout {
      border-left: 4px solid;
      border-radius: 6px;
      background: var(--bg-secondary);
      margin: 1em 0;
      overflow: hidden;
    }
    .callout-title {
      display: flex;
      align-items: center;
      gap: .5em;
      font-weight: 600;
      font-size: .95em;
      padding: .6em 1em;
    }
    .callout-body { padding: .5em 1em .75em; }
    .callout-body > *:last-child { margin-bottom: 0; }
    """
}
