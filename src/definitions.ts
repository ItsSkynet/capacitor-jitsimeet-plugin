export interface CapacitorJitsiMeetPlugin {
  joinRoom(options: { 
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
    featureFlags?: any,
    configOverrides?: any
  }): Promise<{ 
    success?: boolean 
  }>;

  leaveRoom(options?: {}): Promise<{
    success?: string 
  }>;
}
