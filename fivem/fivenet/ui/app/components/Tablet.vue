<!-- eslint-disable vue/multi-word-component-names -->
<script lang="ts" setup>
import '~/assets/css/herofull-pattern.css';
import { useTabletStore } from '../stores/tablet';
import { useTablet } from '../composables/useTablet';
import { getParentResourceName, toggleTablet } from '../composables/nui';

const modal = useModal();

const tabletStore = useTabletStore();
const { refreshTablet } = tabletStore;
const { initiated, turnedOn, baseUrl, path, folded } = storeToRefs(tabletStore);

const { isTabletOpen } = useTablet();
watch(isTabletOpen, async () => {
    if (!isTabletOpen.value) {
        await toggleTablet(isTabletOpen.value);
    } else {
        modal.close();

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
            'rounded-[calc(var(--ui-radius)*2)] shadow-lg ring ring-[var(--ui-border)]',
            sizeClasses,
            isTabletOpen ? 'flex' : 'hidden',
        ]"
    >
        <div class="relative w-full flex-1 rounded border-[14px] border-gray-800 bg-gray-800">
            <UTooltip text="Neuladen" class="absolute -start-[32px] top-[124px] h-[40px]">
                <UButton class="rounded-r-none rounded-s-lg" color="white" icon="i-mdi-refresh" @click="refreshTablet()" />
            </UTooltip>

            <UTooltip :text="folded ? 'Aufklappen' : 'Zuklappen'" class="absolute -start-[32px] top-[174px] h-[40px]">
                <UButton
                    class="rounded-r-none rounded-s-lg"
                    :color="folded ? 'white' : 'black'"
                    icon="i-mdi-screen-rotation"
                    @click="folded = !folded"
                />
            </UTooltip>

            <UTooltip text="Schließen" class="absolute -top-[32px] right-[24px] w-[64px]">
                <UButton
                    class="rounded-b-none rounded-t-lg"
                    color="primary"
                    icon="i-mdi-close"
                    block
                    @click="isTabletOpen = false"
                />
            </UTooltip>

            <UTooltip :text="turnedOn ? 'Ausschalten' : 'Einschalten'" class="absolute -end-[32px] top-[142px] h-[64px]">
                <UButton
                    class="rounded-e-lg rounded-l-none"
                    :color="turnedOn ? 'white' : 'orange'"
                    icon="i-mdi-power-standby"
                    block
                    @click="turnedOn = !turnedOn"
                />
            </UTooltip>

            <div class="size-full overflow-hidden rounded border-2 border-gray-900 bg-gray-900">
                <iframe
                    ref="tabletIframe"
                    sandbox="allow-forms allow-modals allow-same-origin allow-scripts"
                    allow="autoplay *; clipboard-read *; clipboard-write *;"
                    class="hero size-full bg-gray-900"
                    :class="turnedOn ? '' : 'screenOff opacity-0'"
                />
            </div>

            <UButton
                class="absolute -bottom-3 left-1/2 !h-[8px] w-52 -translate-x-1/2 rounded-b-xl bg-gray-300"
                size="xs"
                @click="
                    turnedOn = true;
                    navigateTabletTo('/overview');
                "
            />
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
