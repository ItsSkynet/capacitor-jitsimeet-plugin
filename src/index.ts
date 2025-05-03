import { registerPlugin } from '@capacitor/core';

import type { CapacitorJitsiMeetPlugin } from './definitions';

const CapacitorJitsiMeetPlugin = registerPlugin<CapacitorJitsiMeetPlugin>('CapacitorJitsimeetPlugin', {
  web: () => import('./web').then((m) => new m.CapacitorJitsimeetPluginWeb()),
});

export * from './definitions';
export { CapacitorJitsiMeetPlugin };