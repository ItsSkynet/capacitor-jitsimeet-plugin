export interface CapacitorJitsimeetPluginPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
