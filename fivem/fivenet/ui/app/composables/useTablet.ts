import { createSharedComposable } from '@vueuse/core';
import { toggleTablet } from './nui';

const _useTablet = () => {
    const isTabletOpen = ref(false);
    let suppressNextToggle = false;

    watch(isTabletOpen, () => {
        if (suppressNextToggle) {
            suppressNextToggle = false;
            return;
        }

        toggleTablet(isTabletOpen.value);
    });

    function setTabletOpen(state: boolean, silent = false): void {
        suppressNextToggle = silent;
        isTabletOpen.value = state;
    }

    return {
        isTabletOpen,
        setTabletOpen,
    };
};

export const useTablet = createSharedComposable(_useTablet);
