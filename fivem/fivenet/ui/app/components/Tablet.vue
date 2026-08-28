<!-- eslint-disable vue/multi-word-component-names -->
<script lang="ts" setup>
import '~/assets/css/herofull-pattern.css';
import { useTabletStore } from '../stores/tablet';
import { useTablet } from '../composables/useTablet';
import { getParentResourceName, toggleTablet } from '../composables/nui';
import { useTokenMgmtOverlay } from '../composables/useTokenMgmtOverlay';

const tokenMgmtOverlay = useTokenMgmtOverlay();
const { t } = useI18n();

const tabletStore = useTabletStore();
const { refreshTablet } = tabletStore;
const { initiated, turnedOn, baseUrl, path, folded } = storeToRefs(tabletStore);

const { isTabletOpen } = useTablet();
watch(isTabletOpen, async () => {
    if (!isTabletOpen.value) {
        await toggleTablet(isTabletOpen.value);
    } else {
        tokenMgmtOverlay.close();

        if (initiated.value === false) {
            initiated.value = true;

            setIframeURL();
        }

        turnedOn.value = true;
    }
});

const tabletIframe = useTemplateRef('tabletIframe');

function navigateTabletTo(route: string) {
    if (!tabletIframe.value) {
        return;
    }

    tabletIframe.value.contentWindow?.postMessage({ type: 'navigateTo', route: route }, baseUrl.value ?? '');
}

watch([baseUrl, path], setIframeURL);

function setIframeURL(): void {
    if (!tabletIframe.value) {
        return;
    }

    const p = path.value ? '/' + path.value : `?nui=${getParentResourceName()}`;
    tabletIframe.value.src = `${baseUrl.value}${p}`;
}

const sizeClasses = computed(() => {
    if (!folded.value) {
        return '!h-full !min-h-[800px] !max-h-[80%] !w-full !min-w-[750px] !max-w-[92%] left-1/2 -translate-x-1/2';
    }
    return '!h-[80%] !min-h-[800px] !max-h-[80%] !w-[30%] !min-w-[750px] right-[50px]';
});

const modalRef = useTemplateRef('modalRef');

onClickOutside(modalRef, (event) => {
    const element = event.target as HTMLElement;
    if (element.tagName.toLowerCase() !== 'html') {
        return;
    }

    isTabletOpen.value = false;
});
</script>

<template>
    <div
        ref="modalRef"
        :class="[
            'flex-1 flex-row',
            'absolute top-1/2 -translate-y-1/2 transform',
            sizeClasses,
            isTabletOpen ? 'flex' : 'hidden',
        ]"
    >
        <div class="relative w-full flex-1 rounded-[calc(var(--ui-radius)*2)] shadow-lg ring ring-[var(--ui-border)]">
            <div class="relative size-full rounded border-[14px] border-neutral-800 bg-neutral-800 transform-flat">
                <UTooltip :text="t('tablet.close')" class="absolute -top-[32px] right-[24px] w-[64px]">
                    <UButton
                        class="rounded-t-lg rounded-b-none shadow-none ring-0"
                        color="primary"
                        icon="i-mdi-close"
                        block
                        @click="isTabletOpen = false"
                    />
                </UTooltip>

                <UTooltip :text="t('tablet.reload')" class="absolute -end-[32px] top-[100px] h-[44px]">
                    <UButton
                        class="rounded-e-lg rounded-l-none border-none shadow-none ring-0 dark:hover:bg-neutral-700"
                        color="gray"
                        icon="i-mdi-refresh"
                        @click="refreshTablet()"
                    />
                </UTooltip>

                <UTooltip
                    :text="folded ? t('tablet.expand') : t('tablet.collapse')"
                    class="absolute -end-[32px] top-[154px] h-[44px]"
                >
                    <UButton
                        class="rounded-e-lg rounded-l-none shadow-none ring-0 dark:hover:bg-neutral-700"
                        :color="folded ? 'gray' : 'white'"
                        :icon="folded ? 'i-mdi-phone-rotate-landscape' : 'i-mdi-phone-rotate-portrait'"
                        @click="folded = !folded"
                    />
                </UTooltip>

                <UTooltip
                    :text="turnedOn ? t('tablet.powerOff') : t('tablet.powerOn')"
                    class="absolute -end-[20px] top-[262px] h-[64px]"
                >
                    <UButton
                        class="w-[20px] rounded-e-lg rounded-l-none shadow-none ring-0"
                        :class="turnedOn ? 'dark:hover:bg-neutral-700' : 'hover:bg-orange-500 dark:hover:bg-orange-500'"
                        :color="turnedOn ? 'gray' : 'orange'"
                        block
                        @click="turnedOn = !turnedOn"
                    />
                </UTooltip>

                <div class="relative size-full overflow-hidden rounded border-2 border-neutral-900 bg-neutral-900">
                    <iframe
                        ref="tabletIframe"
                        sandbox="allow-forms allow-modals allow-same-origin allow-scripts"
                        allow="autoplay *; clipboard-read *; clipboard-write *"
                        class="hero absolute inset-0 block size-full border-0 bg-neutral-900"
                        :class="turnedOn ? '' : 'screenOff opacity-0'"
                    />
                </div>

                <UButton
                    class="absolute -bottom-3 left-1/2 !h-[8px] w-52 -translate-x-1/2 rounded-b-xl bg-neutral-300 shadow-none"
                    size="xs"
                    @click="
                        turnedOn = true;
                        navigateTabletTo('/overview');
                    "
                />
            </div>
        </div>
    </div>
</template>

<style lang="scss">
@keyframes turnoff {
    50% {
        transform: scale(1, 0.02);
        opacity: 0.8;
    }
    55%,
    100% {
        transform: scale(0, 0);
        opacity: 0.3;
    }
}

.screenOff {
    animation: turnoff 1s linear forwards;
}
</style>
