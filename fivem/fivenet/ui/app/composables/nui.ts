import { useTablet } from './useTablet';
import { useTokenMgmtOverlay } from './useTokenMgmtOverlay';

const logger = useLogger('🎮 NUI');

export function getParentResourceName(): string {
    return (window as any).GetParentResourceName ? (window as any).GetParentResourceName() : 'fivenet';
}

const focusNUITargets = ['input', 'textarea'];
const focusSource = 'outer';
let textInputFocused = false;
let focusUpdateQueued = false;
let focusRevision = 0;
let focusSession: number | undefined;

function isNUITextTarget(target: EventTarget | null): target is HTMLElement {
    if (!(target instanceof HTMLElement)) return false;

    return focusNUITargets.includes(target.tagName.toLowerCase());
}

function sendFocusState(state: boolean, force = false): void {
    if (!force && state === textInputFocused) return;

    textInputFocused = state;
    focusRevision += 1;
    void focusTablet(state, focusRevision, focusSource);
}

function updateNUIInputFocus(): void {
    if (focusUpdateQueued) return;

    focusUpdateQueued = true;
    queueMicrotask(() => {
        focusUpdateQueued = false;
        sendFocusState(isNUITextTarget(document.activeElement));
    });
}

export function syncNUIInputFocus(): void {
    sendFocusState(isNUITextTarget(document.activeElement), true);
}

export function setNUIFocusSession(session: number): void {
    focusSession = session;
    focusRevision = 0;
}

/**
 *
 * @param event FocusEvent `focusin`/`focusout` event
 * @returns void promise
 */
export function onFocusHandler(event: FocusEvent): void {
    if (!isNUITextTarget(event.target) && !isNUITextTarget(document.activeElement)) return;

    event.stopPropagation();
    logger.debug('focus handler event:', event.type);
    updateNUIInputFocus();
}

type NUIRequest = boolean | string | object;
type NUIResponse = boolean | string | object;

export async function fetchNUI<T = NUIRequest, V = NUIResponse>(method: string, data: T): Promise<V> {
    const body = JSON.stringify(data);
    logger.debug(`Fetch ${method}:`, body);
    const resp = await fetch(`https://${getParentResourceName()}/${method}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body,
    });

    const parsed = resp.json();
    return parsed as V;
}

export type NUIMessage =
    | {
          type: 'token';
          webUrl: string;
          data: {
              username?: string;
              token?: string;
          };
      }
    // Tablet
    | {
          type: 'openTablet';
          webUrl: string;
          data: string;
      }
    | {
          type: 'navigateTo';
          route: string;
      }
    | {
          type: 'fivenetReady';
      }
    | {
          type: 'setLocale';
          locale: string;
      }
    | {
          type: 'closeTablet';
      }
    | {
          type: 'tabletfix';
          webUrl: string;
      }
    | {
          type: 'syncFocus';
          session: number;
      }
    | {
          type: 'copyToClipboard';
          text: string;
      }
    | {
          type: 'setTabletColors';
          data: {
              primary: string;
              gray: string;
          };
      }
    | {
          type: 'openURLInWindow';
          url: string;
      }
    | {
          type: undefined;
      };

export async function onNUIMessage(
    event: MessageEvent<NUIMessage>,
    onLocaleChange?: (locale: string) => void | Promise<void>,
): Promise<void> {
    if (!event.data || !event.data.type) {
        return;
    }

    const tabletStore = useTabletStore();

    if (event.data.type === 'token') {
        tabletStore.setBaseUrl(event.data.webUrl);
        useTablet().setTabletOpen(false, true);

        tabletStore.registrationToken = event.data.data.token ?? '';
        tabletStore.username = event.data.data.username ?? '';

        useTokenMgmtOverlay().open();
    } else if (event.data.type === 'openTablet') {
        tabletStore.setBaseUrl(event.data.webUrl);
        useTokenMgmtOverlay().close();

        useTablet().setTabletOpen(true, true);
    } else if (event.data.type === 'navigateTo') {
        tabletStore.navigateTo(event.data.route);
        useTokenMgmtOverlay().close();
        useTablet().setTabletOpen(true, true);
    } else if (event.data.type === 'fivenetReady') {
        // Handled by Tablet.vue after verifying the iframe source.
        return;
    } else if (event.data.type === 'setLocale') {
        await onLocaleChange?.(event.data.locale);
    } else if (event.data.type === 'closeTablet') {
        useTablet().setTabletOpen(false, true);
    } else if (event.data.type === 'tabletfix') {
        tabletStore.setBaseUrl(event.data.webUrl);
        tabletStore.setPath('/api/clear-site-data');
        tabletStore.reload();

        useTimeoutFn(() => {
            logger.info('Refreshing tablet after site data clear ...');

            tabletStore.refreshTablet();
        }, 3000);
    } else if (event.data.type === 'syncFocus') {
        setNUIFocusSession(event.data.session);
        syncNUIInputFocus();
    } else if (event.data.type === 'copyToClipboard') {
        copyToClipboard(event.data.text);
    } else if (event.data.type === 'setTabletColors') {
        tabletStore.setTabletColors(event.data.data);
    } else if (event.data.type === 'openURLInWindow') {
        openURLInWindow(event.data.url);
    } else {
        logger.error('Message - Unknown message type received', event);
    }
}

export async function getLocale(): Promise<{ locale: string }> {
    return fetchNUI('getLocale', {});
}

// NUI Callbacks

export function openURLInWindow(url: string): void {
    if (!(window as any).invokeNative) {
        return;
    }

    (window as any).invokeNative('openUrl', url);
}

export async function toggleTablet(state: boolean): Promise<void> {
    return await fetchNUI(state ? 'openTablet' : 'closeTablet', { ok: true });
}

export async function focusTablet(state: boolean, revision?: number, source?: string): Promise<void> {
    return fetchNUI('focusTablet', { state: state, revision: revision, source: source, session: focusSession });
}
