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

        function setTabletColors(colors?: TabletColors): void {
            if (colors) color.value = colors;

            const primary = color.value.primary;
            const gray = color.value.gray;

            const appConfig = useAppConfig();
            appConfig.ui.colors.primary = primary;
            appConfig.ui.colors.neutral = gray;

            const root = document.documentElement;

            root.style.setProperty('--ui-color-primary-50-rgb', `var(--color-${primary}-50-rgb)`);
            root.style.setProperty('--ui-color-primary-100-rgb', `var(--color-${primary}-100-rgb)`);
            root.style.setProperty('--ui-color-primary-200-rgb', `var(--color-${primary}-200-rgb)`);
            root.style.setProperty('--ui-color-primary-300-rgb', `var(--color-${primary}-300-rgb)`);
            root.style.setProperty('--ui-color-primary-400-rgb', `var(--color-${primary}-400-rgb)`);
            root.style.setProperty('--ui-color-primary-500-rgb', `var(--color-${primary}-500-rgb)`);
            root.style.setProperty('--ui-color-primary-600-rgb', `var(--color-${primary}-600-rgb)`);
            root.style.setProperty('--ui-color-primary-700-rgb', `var(--color-${primary}-700-rgb)`);
            root.style.setProperty('--ui-color-primary-800-rgb', `var(--color-${primary}-800-rgb)`);
            root.style.setProperty('--ui-color-primary-900-rgb', `var(--color-${primary}-900-rgb)`);
            root.style.setProperty('--ui-color-primary-950-rgb', `var(--color-${primary}-950-rgb)`);
            root.style.setProperty('--ui-color-primary-rgb', `var(--color-${primary}-500-rgb)`);

            root.style.setProperty('--ui-color-neutral-50-rgb', `var(--color-${gray}-50-rgb)`);
            root.style.setProperty('--ui-color-neutral-100-rgb', `var(--color-${gray}-100-rgb)`);
            root.style.setProperty('--ui-color-neutral-200-rgb', `var(--color-${gray}-200-rgb)`);
            root.style.setProperty('--ui-color-neutral-300-rgb', `var(--color-${gray}-300-rgb)`);
            root.style.setProperty('--ui-color-neutral-400-rgb', `var(--color-${gray}-400-rgb)`);
            root.style.setProperty('--ui-color-neutral-500-rgb', `var(--color-${gray}-500-rgb)`);
            root.style.setProperty('--ui-color-neutral-600-rgb', `var(--color-${gray}-600-rgb)`);
            root.style.setProperty('--ui-color-neutral-700-rgb', `var(--color-${gray}-700-rgb)`);
            root.style.setProperty('--ui-color-neutral-800-rgb', `var(--color-${gray}-800-rgb)`);
            root.style.setProperty('--ui-color-neutral-900-rgb', `var(--color-${gray}-900-rgb)`);
            root.style.setProperty('--ui-color-neutral-950-rgb', `var(--color-${gray}-950-rgb)`);
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
