import { registerPlugin } from '@capacitor/core';

import type { CapacitorJitsimeetPluginPlugin } from './definitions';

const CapacitorJitsimeetPlugin = registerPlugin<CapacitorJitsimeetPluginPlugin>('CapacitorJitsimeetPlugin', {
  web: () => import('./web').then((m) => new m.CapacitorJitsimeetPluginWeb()),
});

export * from './definitions';
export { CapacitorJitsimeetPlugin };
