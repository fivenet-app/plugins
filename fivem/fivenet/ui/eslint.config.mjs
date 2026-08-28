// @ts-check
import eslintPluginPrettierRecommended from 'eslint-plugin-prettier/recommended';
import typescriptEslint from '@typescript-eslint/eslint-plugin';
import typescriptParser from '@typescript-eslint/parser';
// @ts-ignore no types available yet
import pluginVue from 'eslint-plugin-vue';

export default [
    {
        ignores: ['gen/', 'proto/'],
    },
    ...pluginVue.configs['flat/recommended'],
    eslintPluginPrettierRecommended,
    {
        files: ['**/*.{ts,tsx}'],
        languageOptions: {
            parser: typescriptParser,
        },
    },
    {
        files: ['**/*.vue'],
        languageOptions: {
            parserOptions: {
                parser: typescriptParser,
            },
        },
    },
    {
        plugins: {
            '@typescript-eslint': typescriptEslint,
        },
        rules: {
            'no-console': 0,
            'require-await': 0,
            'no-restricted-syntax': ['error', 'IfStatement > ExpressionStatement > AssignmentExpression'],
            '@typescript-eslint/no-unused-vars': [
                'warn',
                {
                    argsIgnorePattern: '^_',
                    varsIgnorePattern: '^_',
                    caughtErrorsIgnorePattern: '^_',
                },
            ],
            'vue/no-unused-vars': [
                'warn',
                {
                    ignorePattern: '^_',
                },
            ],
            '@typescript-eslint/unified-signatures': 'off',
            '@typescript-eslint/no-unused-expressions': 'off',
        },
    },
    {
        files: ['app/pages/**', 'app/layouts/**'],
        rules: {
            'vue/multi-word-component-names': 'off',
        },
    },
];
