import type { CodegenConfig } from '@graphql-codegen/cli';

const config: CodegenConfig = {
  overwrite: true,
  schema: 'http://192.168.1.6:8080/graphql',
  documents: ['src/**/*.{ts,tsx}'],
  ignoreNoDocuments: true,
  generates: {
    'src/graphql/__generated__/': {
      plugins: [],
      preset: 'client',
      config: {
        scalars: {
          UUID: 'string',
          Date: 'string',
          DateTime: 'string',
          BigDecimal: 'string'
        }
      }
    }
  }
};

export default config;
