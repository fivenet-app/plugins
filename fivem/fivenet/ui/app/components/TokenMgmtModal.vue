<script lang="ts" setup>
import { copyToClipboard } from '../utils/clipboard';
import { useTabletStore } from '../stores/tablet';
import FiveNetLogo from './FiveNetLogo.vue';
import { fetchNUI, openURLInWindow } from '../composables/nui';

type TokenMgmtOverlayResult = 'dismiss' | 'registration' | 'resetPassword';

const open = defineModel<boolean>('open', { default: false });
const emit = defineEmits<{
    close: [result: TokenMgmtOverlayResult];
}>();

const tabletStore = useTabletStore();
const { registrationToken, username, baseUrl } = storeToRefs(tabletStore);

const { isTabletOpen } = useTablet();
const closeResult = ref<TokenMgmtOverlayResult>('dismiss');

watch(open, async () => {
    if (open.value === false) {
        emit('close', closeResult.value);
        closeResult.value = 'dismiss';

        await fetchNUI('exit', {});
    } else {
        closeResult.value = 'dismiss';
        isTabletOpen.value = false;
    }
});

const loading = ref(false);

async function resetPassword(): Promise<void> {
    loading.value = true;
    await fetchNUI('resetPassword', { ok: true }).finally(() => useTimeoutFn(() => (loading.value = false), 600));
}

async function openResetPassword(): Promise<void> {
    closeResult.value = 'resetPassword';
    open.value = false;
    tabletStore.setPath(`/auth/login?tab=forgotPassword&registrationToken=${registrationToken.value}#`);
    isTabletOpen.value = true;
}

async function openRegistration(): Promise<void> {
    closeResult.value = 'registration';
    open.value = false;
    tabletStore.setPath(`/auth/registration?registrationToken=${registrationToken.value}#`);
    isTabletOpen.value = true;
}
</script>

<template>
    <UModal v-model:open="open" :overlay="false" :close="false" :ui="{ content: 'w-full max-w-xl' }">
        <template #content>
            <UCard>
                <template #header>
                    <div class="flex items-center justify-between">
                        <FiveNetLogo class="h-5 w-5" />

                        <h3 class="text-2xl font-semibold leading-6 text-neutral-900 dark:text-white">
                            {{ username ? 'Konto-Verwaltung' : 'Konto-Erstellung' }}
                        </h3>

                        <UButton color="white" variant="ghost" icon="i-mdi-window-close" class="-my-1" @click="open = false" />
                    </div>
                </template>

                <UContainer class="flex flex-col gap-y-2">
                    <UFormGroup v-if="username" label="Dein Benutzername">
                        <div class="inline-flex w-full justify-center gap-2">
                            <div class="inline-flex gap-1.5">
                                <UInput
                                    disabled
                                    :model-value="username"
                                    block
                                    size="xl"
                                    class="flex-1"
                                    :ui="{ base: 'text-center text-white font-semibold' }"
                                />
                            </div>

                            <UButton
                                icon="i-mdi-clipboard-plus"
                                color="neutral"
                                size="xl"
                                label="Kopieren"
                                class="flex-1"
                                @click="copyToClipboard(username)"
                            />
                        </div>
                    </UFormGroup>

                    <UFormGroup v-if="registrationToken" label="Dein Registrierungstoken">
                        <div class="inline-flex w-full justify-center gap-2">
                            <div class="inline-flex gap-1.5">
                                <UInput
                                    disabled
                                    :model-value="registrationToken"
                                    size="xl"
                                    :ui="{ base: 'text-center text-white font-semibold' }"
                                />
                            </div>

                            <UButton
                                icon="i-mdi-clipboard-plus"
                                color="neutral"
                                size="xl"
                                label="Kopieren"
                                class="flex-1"
                                @click="copyToClipboard(registrationToken)"
                            />
                        </div>
                    </UFormGroup>

                    <UAlert
                        icon="i-mdi-information"
                        :description="
                            username
                                ? registrationToken
                                    ? 'Nutze diesen Token, um dein Passwort zurückzusetzen.'
                                    : 'Dein FiveNet-Konto wurde mit diesem Nutzernamen erstellt.'
                                : 'Nutze diesen Token, um dein FiveNet-Konto zu erstellen.'
                        "
                    />

                    <UButton
                        v-if="username && registrationToken"
                        color="warning"
                        block
                        icon="i-mdi-lock-question"
                        label="Setze nun hier dein Passwort zurück!"
                        :loading="loading"
                        size="md"
                        @click="openResetPassword"
                    />
                    <UButton
                        v-else-if="username"
                        icon="i-mdi-lock-question"
                        color="warning"
                        :disabled="!!registrationToken"
                        block
                        label="Passwort vergessen? Hier zurücksetzen"
                        :loading="loading"
                        size="md"
                        @click="resetPassword"
                    />
                    <UButton v-else block color="green" icon="i-mdi-user-add" label="Konto erstellen" size="md" @click="openRegistration()" />

                    <UButton
                        v-if="baseUrl"
                        trailing-icon="i-mdi-link-variant"
                        block
                        variant="outline"
                        size="sm"
                        class="flex-1"
                        :ui="{ base: 'text-center text-white font-semibold' }"
                        @click="openURLInWindow(baseUrl)"
                    >
                        <span>FiveNet URL:</span>
                        <span class="font-mono">{{ baseUrl }}</span>
                    </UButton>
                </UContainer>

                <template #footer>
                    <UFieldGroup class="inline-flex w-full">
                        <UButton color="neutral" block class="flex-1" label="Schließen" @click="open = false" />
                    </UFieldGroup>
                </template>
            </UCard>
        </template>
    </UModal>
</template>
