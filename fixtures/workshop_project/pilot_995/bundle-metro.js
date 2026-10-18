// Matrix-only resolver; never copied into the product.
const path = require('path');
const { getDefaultConfig } = require('expo/metro-config');
const config = getDefaultConfig(__dirname);
const mode = process.env.EXPO_PUBLIC_API_MODE || 'mock';
const target = path.join(__dirname, mode === 'http' ? 'src/bootstrap/http-runtime.ts' : 'src/mocks/runtime.ts');
config.resolver.resolveRequest = (context, moduleName, platform) =>
  context.resolveRequest(context, moduleName === '@pilot/runtime' ? target : moduleName, platform);
module.exports = config;
