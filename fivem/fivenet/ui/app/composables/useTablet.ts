import { createSharedComposable } from '@vueuse/core';
import { toggleTablet } from './nui';

const _useTablet = () => {
    const isTabletOpen = ref(false);

    watch(isTabletOpen, () => {
        toggleTablet(isTabletOpen.value);
    });

    return {
        isTabletOpen,
    };
};

export const useTablet = createSharedComposable(_useTablet);
