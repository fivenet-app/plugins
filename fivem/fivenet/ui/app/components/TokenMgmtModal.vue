<script lang="ts" setup>
import { useTabletStore } from '../stores/tablet';
import FiveNetLogo from './FiveNetLogo.vue';
import { fetchNUI } from '../composables/nui';

const { isOpen } = useModal();

const tabletStore = useTabletStore();
const { registrationToken, username, baseUrl } = storeToRefs(tabletStore);

const { isTabletOpen } = useTablet();

watch(isOpen, async () => {
    if (isOpen.value === false) {
        await fetchNUI('exit', {});
    } else {
        isTabletOpen.value = false;
    }
});

function openURLInWindow(url: string): void {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    if (!(window as any).invokeNative) {
        return;
    }

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (window as any).invokeNative('openUrl', url);
}

const loading = ref(false);

async function resetPassword(): Promise<void> {
    loading.value = true;
    await fetchNUI('resetPassword', { ok: true }).finally(() => useTimeoutFn(() => (loading.value = false), 600));
}

async function openResetPassword(): Promise<void> {
    isOpen.value = false;
    tabletStore.setPath(`/auth/login?tab=forgotPassword&registrationToken=${registrationToken.value}#`);
    isTabletOpen.value = true;
}

async function openRegistration(): Promise<void> {
    isOpen.value = false;
    tabletStore.setPath(`/auth/registration?registrationToken=${registrationToken.value}#`);
    isTabletOpen.value = true;
}
</script>

<template>
    <UModal :overlay="false" :ui="{ width: 'w-full max-w-xl' }">
        <UCard :ui="{ ring: '', divide: 'divide-y divide-gray-100 dark:divide-gray-800' }">
            <template #header>
                <div class="flex items-center justify-between">
                    <FiveNetLogo class="h-5 w-5" />

                    <h3 class="text-2xl font-semibold leading-6 text-gray-900 dark:text-white">
                        {{ username ? 'Konto-Verwaltung' : 'Konto-Erstellung' }}
                    </h3>

                    <UButton color="white" variant="ghost" icon="i-mdi-window-close" class="-my-1" @click="isOpen = false" />
                </div>
            </template>

            <UContainer class="flex flex-col gap-y-2">
                <UFormGroup v-if="username" label="Dein Benutzername">
                    <div class="inline-flex w-full justify-center gap-2">
                        <UInput
                            disabled
                            :model-value="username"
                            block
                            size="xl"
                            class="flex-1"
                            :ui="{ base: 'text-center text-white font-semibold' }"
                        />

                        <UButton
                            icon="i-mdi-clipboard-plus"
                            color="black"
                            size="xl"
                            label="Kopieren"
                            @click="username ? copyToClipboard(username) : copyToClipboard(registrationToken)"
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
                            color="black"
                            size="xl"
                            label="Kopieren"
                            @click="username ? copyToClipboard(username) : copyToClipboard(registrationToken)"
                        />
                    </div>
                </UFormGroup>

                <UAlert
                    icon="i-mdi-information"
                    :description="
                        username
                            ? 'Dein FiveNet-Konto wurde mit diesem Nutzernamen erstellt.'
                            : 'Nutze den Token, um dein FiveNet-Konto zu erstellen.'
                    "
                />

                <UButton
                    v-if="username && registrationToken"
                    icon="i-mdi-lock-question"
                    color="amber"
                    size="md"
                    block
                    :loading="loading"
                    @click="openResetPassword"
                >
                    Öffne Passwort vergessen Formular
                </UButton>
                <UButton
                    v-else-if="username"
                    icon="i-mdi-lock-question"
                    color="amber"
                    size="md"
                    block
                    :loading="loading"
                    :disabled="!!registrationToken"
                    @click="resetPassword"
                >
                    Passwort vergessen? Hier zurücksetzen
                </UButton>
                <UButton v-else icon="i-mdi-user-add" color="green" size="md" block @click="openRegistration()">
                    Öffne die Konto-Erstellung
                </UButton>

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
                    <span>{{ baseUrl }}</span>
                </UButton>
            </UContainer>

            <template #footer>
                <UButtonGroup class="inline-flex w-full">
                    <UButton color="black" block class="flex-1" @click="isOpen = false"> Schließen </UButton>
                </UButtonGroup>
            </template>
        </UCard>
    </UModal>
</template>
