module.exports = {
    // ... Otras configuraciones de Webpack ...
    performance: {
      assetFilter: function (assetFilename) {
        return !/\.ts$/.test(assetFilename);
      },
    },
    // ... Resto de la configuración ...
  };
  