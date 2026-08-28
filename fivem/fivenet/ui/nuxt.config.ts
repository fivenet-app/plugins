// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
    telemetry: {
        enabled: false,
    },
    ssr: false,

    modules: [
        '@nuxt/eslint',
        '@nuxt/ui',
        '@nuxt/fonts',
        '@vueuse/nuxt',
        '@pinia/nuxt',
        'pinia-plugin-persistedstate/nuxt',
        '@nuxtjs/i18n',
    ],

    css: ['~/assets/css/main.css', '~/assets/css/polyfills.css'],

    fonts: {
        provider: 'npm',
    },

    colorMode: {
        preference: 'dark',
    },

    devtools: {
        enabled: true,
    },

    app: {
        baseURL: '/ui/.output/public',
        head: {
            htmlAttrs: {
                class: 'polyfills',
            },
        },
    },

    ui: {
        theme: {
            colors: [
                // Theme colors
                'primary',
                'secondary',
                'success',
                'info',
                'warning',
                'error',
                // Palette colors
                'amber',
                'blue',
                'cyan',
                'emerald',
                'fuchsia',
                'green',
                'indigo',
                'lime',
                'orange',
                'pink',
                'purple',
                'red',
                'rose',
                'sky',
                'teal',
                'violet',
                'white',
                'yellow',
                // Gray Colors
                'gray',
                'neutral',
                'slate',
                'stone',
                'zinc',
                'taupe',
                'mauve',
                'mist',
                'olive',
            ],
        },
    },

    icon: {
        collections: ['mdi', 'flagpack'],
        provider: 'iconify',
        fallbackToApi: false,
        clientBundle: {
            scan: true,
            sizeLimitKb: 768,
            icons: [
                // Custom UI Icons (from app.config.ts)
                'mdi:sort',
                'mdi:sort-ascending',
                'mdi:sort-descending',
                // Nuxt UI Icons (from app.config.ts)
                'mdi:arrow-down',
                'mdi:arrow-left',
                'mdi:arrow-right',
                'mdi:arrow-up',
                'mdi:alert-circle',
                'mdi:check',
                'mdi:chevron-double-left',
                'mdi:chevron-double-right',
                'mdi:chevron-down',
                'mdi:chevron-left',
                'mdi:chevron-right',
                'mdi:chevron-up',
                'mdi:close',
                'mdi:content-copy',
                'mdi:check-circle-outline',
                'mdi:moon-waning-crescent',
                'mdi:drag-vertical',
                'mdi:dots-horizontal',
                'mdi:close-circle',
                'mdi:arrow-top-right',
                'mdi:eye',
                'mdi:eye-off',
                'mdi:file-document',
                'mdi:folder',
                'mdi:folder-open',
                'mdi:pound',
                'mdi:information',
                'mdi:white-balance-sunny',
                'mdi:loading',
                'mdi:menu',
                'mdi:minus',
                'mdi:menu-close',
                'mdi:menu-open',
                'mdi:plus',
                'mdi:reload',
                'mdi:magnify',
                'mdi:star-outline',
                'mdi:stop',
                'mdi:check-circle',
                'mdi:monitor',
                'mdi:lightbulb-variant',
                'mdi:upload',
                'mdi:alert',
            ],
        },
    },

    i18n: {
        strategy: 'no_prefix',
        defaultLocale: 'en',
        detectBrowserLanguage: false,
        parallelPlugin: true,
        compilation: {
            strictMessage: false,
        },

        locales: [
            {
                name: 'English',
                code: 'en',
                language: 'en',
                isCatchallLocale: true,
                file: 'en.json',
                icon: 'i-flagpack-gb-ukm',
            },
            {
                name: 'German',
                code: 'de',
                language: 'de',
                file: 'de.json',
                icon: 'i-flagpack-de',
            },
        ],
    },

    postcss: {
        plugins: {
            '../../../internal/postcss/postcss-color-mix-transparency-fallback': {},
            '../../../internal/postcss/postcss-viewport-unit-fixup': {},
            'postcss-preset-env': {
                stage: 2,
                features: {
                    'oklab-function': {
                        preserve: true,
                        enableProgressiveCustomProperties: true,
                        subFeatures: {
                            displayP3: false,
                        },
                    },
                    // Not in use by Nuxt UI (yet)
                    'random-function': false,
                    'sign-functions': false,
                    'stepped-value-functions': false,
                    'trigonometric-functions': false,
                },
                enableClientSidePolyfills: false,
                preserve: true,
                browsers: 'chrome >= 103',
            },
            '../../../internal/postcss/postcss-cef-fixup': {},
        },
    },

    sourcemap: {
        client: true,
        server: false,
    },

    piniaPluginPersistedstate: {
        storage: 'localStorage',
    },

    future: {
        compatibilityVersion: 4,
    },

    compatibilityDate: '2026-04-26',
});
