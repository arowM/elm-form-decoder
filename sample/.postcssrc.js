module.exports =
  {
    "modules": true,
    "plugins": {
      "autoprefixer": {},
      "postcss-flexbugs-fixes": {},
      "postcss-modules": {
        "generateScopedName": "[name]__[local]",
        "getJSON": () => null,
      }
    }
  }
