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
          type: 'fixTablet';
          webUrl: string;
      }
    | {
          type: 'copyToClipboard';
          text: string;
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
        useTablet().isTabletOpen.value = false;

        tabletStore.registrationToken = event.data.data.token ?? '';
        tabletStore.username = event.data.data.username ?? '';

        useModal().open(TokenMgmtModal);
    } else if (event.data.type === 'openTablet') {
        tabletStore.setBaseUrl(event.data.webUrl);
        useModal().close();

        useTablet().isTabletOpen.value = true;
    } else if (event.data.type === 'closeTablet') {
        useTablet().isTabletOpen.value = false;
    } else if (event.data.type === 'fixTablet') {
        tabletStore.setBaseUrl(event.data.webUrl);

        tabletStore.setPath('/api/clear-site-data');

        useTimeoutFn(() => {
            logger.info('Refreshing tablet after site data clear ...');

            tabletStore.refreshTablet();
        }, 3000);
    } else if (event.data.type === 'copyToClipboard') {
        copyToClipboard(event.data.text);
    } else {
        logger.error('Message - Unknown message type received', event);
    }
}

// NUI Callbacks

export async function toggleTablet(state: boolean): Promise<void> {
    return await fetchNUI(state ? 'openTablet' : 'closeTablet', { ok: true });
}

export async function focusTablet(state: boolean): Promise<void> {
    return fetchNUI('focusTablet', { state: state });
}
