import TokenMgmtModal from '../components/TokenMgmtModal.vue';
import { useTablet } from './useTablet';

const logger = useLogger('🎮 NUI');

export function getParentResourceName(): string {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    return (window as any).GetParentResourceName ? (window as any).GetParentResourceName() : 'fivenet';
}

const focusNUITargets = ['input', 'textarea'];

/**
 *
 * @param event FocusEvent `focusin`/`focusout` event
 * @returns void promise
 */
export async function onFocusHandler(event: FocusEvent): Promise<void> {
    if (event.target === window) {
        return;
    }

    const element = event.target as HTMLElement;
    if (!focusNUITargets.includes(element.tagName.toLowerCase())) {
        return;
    }
    event.stopPropagation();
    logger.debug('focus handler event:', event.type, element.tagName.toLowerCase());

    focusTablet(event.type === 'focusin');
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
          type: 'closeTablet';
      }
    | {
          type: 'tabletfix';
          webUrl: string;
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

export async function onNUIMessage(event: MessageEvent<NUIMessage>): Promise<void> {
    if (!event.data || !event.data.type) {
        return;
    }

    const tabletStore = useTabletStore();

    if (event.data.type === 'token') {
        tabletStore.setBaseUrl(event.data.webUrl);
        useTablet().setTabletOpen(false, true);

        tabletStore.registrationToken = event.data.data.token ?? '';
        tabletStore.username = event.data.data.username ?? '';

        useModal().open(TokenMgmtModal);
    } else if (event.data.type === 'openTablet') {
        tabletStore.setBaseUrl(event.data.webUrl);
        useModal().close();

        useTablet().setTabletOpen(true, true);
    } else if (event.data.type === 'closeTablet') {
        useTablet().setTabletOpen(false, true);
    } else if (event.data.type === 'tabletfix') {
        tabletStore.setBaseUrl(event.data.webUrl);
        tabletStore.setPath('/api/clear-site-data');

        useTimeoutFn(() => {
            logger.info('Refreshing tablet after site data clear ...');

            tabletStore.refreshTablet();
        }, 3000);
    } else if (event.data.type === 'copyToClipboard') {
        copyToClipboard(event.data.text);
    } else if (event.data.type === 'setTabletColors') {
        const appConfig = useAppConfig();
        appConfig.ui.primary = event.data.data.primary;
        appConfig.ui.gray = event.data.data.gray;
    } else if (event.data.type === 'openURLInWindow') {
        openURLInWindow(event.data.url);
    } else {
        logger.error('Message - Unknown message type received', event);
    }
}

// NUI Callbacks

export function openURLInWindow(url: string): void {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    if (!(window as any).invokeNative) {
        return;
    }

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (window as any).invokeNative('openUrl', url);
}

export async function toggleTablet(state: boolean): Promise<void> {
    return await fetchNUI(state ? 'openTablet' : 'closeTablet', { ok: true });
}

export async function focusTablet(state: boolean): Promise<void> {
    return fetchNUI('focusTablet', { state: state });
}
