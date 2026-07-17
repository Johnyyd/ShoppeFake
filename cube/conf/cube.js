// cube.js configuration file
// Connects to SQL Server via environment variables configured in docker-compose.yml

module.exports = {
  driverFactory: () => ({ type: process.env.CUBEJS_DB_TYPE || 'mssql' }),
  apiSecret: process.env.CUBEJS_API_SECRET || 'super-secret-cube-api-key-2026',
  devServer: process.env.CUBEJS_DEV_MODE === 'true',
};
