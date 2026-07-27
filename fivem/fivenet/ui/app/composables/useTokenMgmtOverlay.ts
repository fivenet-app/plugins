import TokenMgmtModal from '../components/TokenMgmtModal.vue';

function createTokenMgmtOverlay() {
    return useOverlay().create(TokenMgmtModal);
}

let tokenMgmtOverlay: ReturnType<typeof createTokenMgmtOverlay> | undefined;

export function useTokenMgmtOverlay(): ReturnType<typeof createTokenMgmtOverlay> {
    tokenMgmtOverlay ??= createTokenMgmtOverlay();

    return tokenMgmtOverlay;
}
