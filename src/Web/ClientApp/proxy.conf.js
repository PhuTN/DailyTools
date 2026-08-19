const { env } = require('process');

const target =
  env["services__webapi__https__0"] ||
  env["services__webapi__http__0"] ||
  "https://localhost:7250"; // Cổng dự phòng khi chạy thủ công

const PROXY_CONFIG = [
  {
    context: [
      "/api",
      "/openapi",
      "/scalar",
      "/weatherforecast",
      "/WeatherForecast"
    ],
    target: target,
    secure: false,
  }
];

module.exports = PROXY_CONFIG;