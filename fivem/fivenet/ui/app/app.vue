<script lang="ts" setup>
import Tablet from './components/Tablet.vue';
import { useTokenMgmtOverlay } from './composables/useTokenMgmtOverlay';
import { useTablet } from './composables/useTablet';
import { useTabletStore } from './stores/tablet';

const tokenMgmtOverlay = useTokenMgmtOverlay();

onMounted(async () => {
    if (!import.meta.client) {
        return;
    }

    // NUI message handling
    window.addEventListener('message', onNUIMessage);
    window.addEventListener('focusin', onFocusHandler, true);
    window.addEventListener('focusout', onFocusHandler, true);
});

onBeforeUnmount(async () => {
    if (!import.meta.client) {
        return;
    }

    // NUI message handling
    window.removeEventListener('message', onNUIMessage);
    window.removeEventListener('focusin', onFocusHandler);
    window.removeEventListener('focusout', onFocusHandler);
});

const { isTabletOpen } = useTablet();

const devMode = import.meta.dev;
if (devMode) {
    useTabletStore().setBaseUrl('https://demo.fivenet.app');
}
</script>

<template>
    <div>
        <NuxtRouteAnnouncer />

        <Tablet v-model="isTabletOpen" />

        <NuxtPage />

        <UButtonGroup v-if="devMode" class="absolute bottom-8 left-1/2 -translate-x-1/2 transform">
            <UButton label="Token Mgmt" @click="tokenMgmtOverlay.open()" />
            <UButton label="Tablet" @click="isTabletOpen = true" />
        </UButtonGroup>

        <UOverlayProvider />
    </div>
</template>
