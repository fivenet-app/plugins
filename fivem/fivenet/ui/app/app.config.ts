export default defineAppConfig({
    // Nuxt UI app config
    ui: {
        primary: 'blue',
        gray: 'neutral',

        button: {
            default: {
                loadingIcon: 'i-mdi-loading',
            },
        },
        input: {
            default: {
                loadingIcon: 'i-mdi-loading',
            },
        },
        select: {
            default: {
                loadingIcon: 'i-mdi-loading',
                trailingIcon: 'i-mdi-chevron-down',
            },
        },
        selectMenu: {
            default: {
                selectedIcon: 'i-mdi-check',
            },
        },
        commandPalette: {
            default: {
                icon: 'i-mdi-search',
                loadingIcon: 'i-mdi-loading',
                selectedIcon: 'i-mdi-check',
                emptyState: {
                    icon: 'i-mdi-search',
                },
            },
        },
        accordion: {
            default: {
                openIcon: 'i-mdi-chevron-down',
            },
        },
        breadcrumb: {
            default: {
                divider: 'i-mdi-chevron-right',
            },
        },
        card: {
            header: {
                padding: 'px-2 py-3 sm:px-4',
            },
            body: {
                padding: 'px-2 py-3 sm:px-4',
            },
            footer: {
                padding: 'px-2 py-3 sm:px-4',
            },
        },
    },
});
