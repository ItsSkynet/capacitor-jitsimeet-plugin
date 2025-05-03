import { WebPlugin } from '@capacitor/core';

import type { CapacitorJitsiMeetPlugin } from './definitions';


export class JitsiMeet extends WebPlugin implements CapacitorJitsiMeetPlugin {
  // @ts-ignore
  async joinRoom(options: {
    roomName: string,
    url: string,
    token?: string,
    channelLastN?: string,
    displayName?: string,
    subject?: string,
    email?: string,
    avatarURL?: string,
    startWithAudioMuted?: boolean,
    startWithVideoMuted?: boolean,
    chatEnabled?: boolean,
    inviteEnabled?: boolean,
    callIntegrationEnabled?: boolean,
    recordingEnabled?: boolean,
    liveStreamingEnabled?: boolean,
    screenSharingEnabled?: boolean,
    featureFlags?: any,
    configOverrides?: any
  }): Promise<{
    success?: boolean
  }> {
    throw this.unavailable('Could not join room due to SDK error');
  };

  // @ts-ignore
  async leaveRoom(options?: {}): Promise<{ success?: boolean; }> {
    throw this.unavailable('Could not leave room due to SDK error or Room was not initialized');
  };
}

const JitsiMeetPlugin = new JitsiMeet();

export { JitsiMeetPlugin };