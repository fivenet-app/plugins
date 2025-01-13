import { defineStore } from 'pinia';
import { getParentResourceName } from '../composables/nui';

export interface TabletStore {
    // Tablet
    initiated: boolean;
    turnedOn: boolean;
    baseUrl: string | undefined;
    path: string | undefined;
    folded: boolean;

    // Token Mgmt
    username: string;
    registrationToken: string;
}

export const useTabletStore = defineStore('tablet', {
    state: () =>
        ({
            initiated: false,
            turnedOn: true,
            baseUrl: undefined,
            path: '',
            folded: true,

            username: '',
            registrationToken: '',
        }) as TabletStore,
    persist: {
        pick: ['folded'],
    },
    actions: {
        setBaseUrl(url: string): void {
            // Remove last slash
            this.baseUrl = url.replace(/\/$/g, '');
        },
        setPath(path: string): void {
            // Remove first slash
            this.path = path.replace(/^\//g, '');
        },
        refreshTablet(): void {
            const baseUrl = this.baseUrl;
            this.baseUrl = '';
            this.path = '';

            useTimeoutFn(() => {
                this.baseUrl = baseUrl;
                this.path = `?refreshApp=true&nui=${getParentResourceName()}`;
            }, 100);
        },
    },
});

if (import.meta.hot) {
    import.meta.hot.accept(acceptHMRUpdate(useTabletStore, import.meta.hot));
}
