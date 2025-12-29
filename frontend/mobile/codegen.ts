import type { CodegenConfig } from '@graphql-codegen/cli';

const config: CodegenConfig = {
  overwrite: true,
  schema: process.env.EXPO_PUBLIC_GRAPHQL_URL,
  documents: ['src/**/*.{ts,tsx}'],
  ignoreNoDocuments: true,
  generates: {
    'src/graphql/__generated__/': {
      plugins: [],
      preset: 'client',
      presetConfig: {
        fragmentMasking: false
      },
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
