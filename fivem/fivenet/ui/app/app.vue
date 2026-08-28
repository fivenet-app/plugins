<script lang="ts" setup>
import Tablet from './components/Tablet.vue';
import { useTokenMgmtOverlay } from './composables/useTokenMgmtOverlay';
import { useTablet } from './composables/useTablet';
import { useTabletStore } from './stores/tablet';
import { getLocale, onNUIMessage, type NUIMessage } from './composables/nui';

const tokenMgmtOverlay = useTokenMgmtOverlay();
const { setLocale } = useI18n();
type LocaleCode = Parameters<typeof setLocale>[0];

function applyLocale(locale: string): Promise<void> {
    const localeCode: LocaleCode = locale === 'de' ? 'de' : 'en';
    return setLocale(localeCode);
}

const handleNUIMessage = (event: MessageEvent<NUIMessage>): void => {
    void onNUIMessage(event, applyLocale);
};

onMounted(async () => {
    if (!import.meta.client) return;

    // NUI message handling
    window.addEventListener('message', handleNUIMessage);
    window.addEventListener('focusin', onFocusHandler, true);
    window.addEventListener('focusout', onFocusHandler, true);
});

onBeforeUnmount(async () => {
    if (!import.meta.client) return;

    // NUI message handling
    window.removeEventListener('message', handleNUIMessage);
    window.removeEventListener('focusin', onFocusHandler);
    window.removeEventListener('focusout', onFocusHandler);
});

onMounted(async () => {
    try {
        const response = await getLocale();
        await applyLocale(response.locale);
    } catch {
        // The NUI callback is unavailable when running the frontend outside FiveM.
        await applyLocale('en');
    }
});

const { isTabletOpen } = useTablet();

const tabletStore = useTabletStore();

onKeyStroke('Escape', (e) => {
    if (!isTabletOpen.value) return;

    e.preventDefault();
    isTabletOpen.value = false;
});

const devMode = import.meta.dev;
if (devMode) {
    tabletStore.setBaseUrl('https://demo.fivenet.app');
}

onBeforeMount(() => tabletStore.setTabletColors());
</script>

<template>
    <div>
        <UApp>
            <NuxtRouteAnnouncer />

            <Tablet v-model="isTabletOpen" />

            <NuxtPage />

            <UFieldGroup v-if="devMode" class="absolute bottom-8 left-1/2 -translate-x-1/2 transform">
                <UButton label="Token Mgmt" icon="i-mdi-account-key" @click="tokenMgmtOverlay.open()" />
                <UButton label="Tablet" icon="i-mdi-tablet" @click="isTabletOpen = true" />
            </UFieldGroup>
        </UApp>
    </div>
</template>
