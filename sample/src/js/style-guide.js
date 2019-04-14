require('../style/reset.scss');
require('../style/layout.scss');
require('../style/input.scss');
require('../style/button.scss');
require('../style/style-guide.scss');

const { Elm } = require('../StyleGuide.elm');
const hljs = require("highlight.js/lib/highlight.js");
hljs.registerLanguage('elm', require('highlight.js/lib/languages/elm.js'));
hljs.registerLanguage('scss', require('highlight.js/lib/languages/scss.js'));
window.hljs = hljs;
require('highlight.js/styles/a11y-dark.css');

const app = Elm.StyleGuide.init({
  node: document.getElementById('elm'),
  flags: null
});
