// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
    telemetry: {
        enabled: false,
    },
    ssr: false,

    modules: ['@nuxt/eslint', '@nuxt/ui', '@nuxt/fonts', '@vueuse/nuxt', '@pinia/nuxt', 'pinia-plugin-persistedstate/nuxt'],

    future: {
        compatibilityVersion: 4,
    },

    fonts: {
        families: [{ name: 'DM Sans', weights: [100, 200, 300, 400, 500, 600, 700, 800, 900], global: true }],
    },

    colorMode: {
        preference: 'dark',
    },

    devtools: {
        enabled: true,
    },

    app: {
        baseURL: '/ui/.output/public',
    },

    ui: {
        safelistColors: ['primary', 'secondary', 'tertiary', 'info', 'success', 'warning', 'error', 'gray'],
    },

    icon: {
        collections: ['mdi'],
        provider: 'iconify',
        fallbackToApi: false,
        clientBundle: {
            scan: true,
            sizeLimitKb: 512,
        },
    },

    piniaPluginPersistedstate: {
        storage: 'localStorage',
    },

    compatibilityDate: '2025-01-13',
});
