import { WebPlugin } from '@capacitor/core';

import type { CapacitorJitsimeetPluginPlugin } from './definitions';

export class CapacitorJitsimeetPluginWeb extends WebPlugin implements CapacitorJitsimeetPluginPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
