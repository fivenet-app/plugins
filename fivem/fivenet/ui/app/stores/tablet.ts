import { defineStore } from 'pinia';
import { getParentResourceName } from '../composables/nui';

type TabletColors = { primary: string; gray: string };

export const useTabletStore = defineStore(
    'tablet',
    () => {
        // Tablet
        const initiated = ref(false);
        const turnedOn = ref(true);
        const baseUrl = ref<string>();
        const path = ref('');
        const folded = ref(true);
        const color = ref<TabletColors>({
            primary: 'blue',
            gray: 'neutral',
        });

        // Token Mgmt
        const username = ref('');
        const registrationToken = ref('');

        function setBaseUrl(url: string): void {
            // Remove last slash
            baseUrl.value = url.replace(/\/$/g, '');
        }

        function setPath(value: string): void {
            // Remove first slash
            path.value = value.replace(/^\//g, '');
        }

        function refreshTablet(): void {
            const previousBaseUrl = baseUrl.value;
            baseUrl.value = '';
            path.value = '';

            useTimeoutFn(() => {
                baseUrl.value = previousBaseUrl;
                path.value = `?refreshApp=true&nui=${getParentResourceName()}`;
            }, 100);
        }

        function setPaletteVars(root: HTMLElement, uiColor: 'primary' | 'neutral', colorName: string): void {
            for (const shade of [50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950]) {
                root.style.setProperty(`--ui-color-${uiColor}-${shade}`, `var(--color-${colorName}-${shade})`);
                root.style.setProperty(`--ui-color-${uiColor}-${shade}-rgb`, `var(--color-${colorName}-${shade}-rgb)`);
            }

            root.style.setProperty(`--ui-color-${uiColor}`, `var(--color-${colorName}-500)`);
            root.style.setProperty(`--ui-color-${uiColor}-rgb`, `var(--color-${colorName}-500-rgb)`);
        }

        function setTabletColors(colors?: TabletColors): void {
            if (colors) color.value = colors;

            const primary = color.value.primary;
            const gray = color.value.gray;

            const appConfig = useAppConfig();
            appConfig.ui.colors.primary = primary;
            appConfig.ui.colors.neutral = gray;

            const root = document.documentElement;

            setPaletteVars(root, 'primary', primary);
            setPaletteVars(root, 'neutral', gray);
        }

        return {
            initiated,
            turnedOn,
            baseUrl,
            path,
            folded,
            username,
            registrationToken,
            setBaseUrl,
            setPath,
            refreshTablet,
            setTabletColors,
        };
    },
    {
        persist: {
            pick: ['color', 'folded'],
        },
    },
);

if (import.meta.hot) {
    import.meta.hot.accept(acceptHMRUpdate(useTabletStore, import.meta.hot));
}
