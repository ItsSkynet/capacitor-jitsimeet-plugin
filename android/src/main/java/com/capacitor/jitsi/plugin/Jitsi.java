package com.capacitor.jitsi.plugin;

import java.net.URL;
import java.net.MalformedURLException;
import java.util.*;

import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;

import android.app.Activity;
import android.os.Bundle;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.getcapacitor.annotation.Permission;

import android.content.IntentFilter;
import android.content.Intent;
import android.Manifest;
import android.os.Build;

import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import timber.log.Timber;

import org.jitsi.meet.sdk.*;
import org.json.JSONException;

import static android.content.Context.RECEIVER_EXPORTED;

@CapacitorPlugin(
        name= "Jitsi",
        permissions={
                @Permission(strings = {Manifest.permission.RECORD_AUDIO}),
                @Permission(strings = {Manifest.permission.CAMERA}),
        }
)
public class Jitsi extends Plugin {
    private static final String TAG = "CapacitorJitsiMeet";
    private JitsiBroadcastReceiver receiver;
    private JitsiMeetUserInfo userInfo;

    @PluginMethod()
    public void joinConference(PluginCall call) throws JSONException {
        URL url = null;
        try {
            url = new URL(call.getString("url"));
        } catch (MalformedURLException e) {
            call.reject("Must provide an url");
            e.printStackTrace();
        }
        String roomName = call.getString("roomName");
        String token = call.getString("token");
        String displayName = call.getString("displayName");
        String subject = call.getString("subject", " ");
        String email = call.getString("email");
        String avatarURL = call.getString("avatarURL");
        Boolean startWithAudioMuted = call.getBoolean("startWithAudioMuted");
        Boolean startWithVideoMuted = call.getBoolean("startWithVideoMuted");
        JSObject featureFlags = call.getObject("featureFlags", new JSObject());
        JSObject configOverrides = call.getObject("configOverrides", new JSObject());

        receiver = new JitsiBroadcastReceiver();
        receiver.setModule(this);
        IntentFilter filter = new IntentFilter();
        filter.addAction("onConferenceWillJoin");
        filter.addAction("onConferenceJoined");
        filter.addAction("onConferenceLeft"); // intentionally uses the obsolete onConferenceLeft in order to be consistent with iOS deployment and broadcast to JS listeners
        filter.addAction("onChatMessageReceived");
        filter.addAction("onParticipantsInfoRetrieved");
        filter.addAction("onCustomButtonPressed");

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            getContext().registerReceiver(receiver, filter, RECEIVER_EXPORTED);
        } else {
            getContext().registerReceiver(receiver, filter);
        }
        if(roomName == null) {
            call.reject("Must provide an conference room name");
            return;
        }

        // assign user info
        userInfo = new JitsiMeetUserInfo();
        if (displayName != null) {
            userInfo.setDisplayName(displayName);
        }
        if (email != null) {
            userInfo.setEmail(email);
        }
        if (avatarURL != null && !avatarURL.isBlank()) {
            // try to assign avatar URL
            try {
                userInfo.setAvatar(new URL(avatarURL));
            } catch (MalformedURLException e) {
                e.printStackTrace();
            }
        }
        //Timber.tag(TAG).d("display url: " + call.getString("url"));

        JitsiMeetConferenceOptions.Builder builder = new JitsiMeetConferenceOptions.Builder()
                .setServerURL(url)
                .setRoom(roomName)
                .setToken(token)
                .setSubject(subject)
                .setUserInfo(userInfo);

        if (configOverrides.has("customToolbarButtons")) {
            try {
                ArrayList<Bundle> buttonsList = new ArrayList<>();
                JSONArray jsonButtons = configOverrides.getJSONArray("customToolbarButtons");

                for (int i = 0; i < jsonButtons.length(); i++) {
                    JSONObject button = jsonButtons.getJSONObject(i);
                    Bundle bundle = new Bundle();
                    Iterator<String> keysIt = button.keys();
                    while (keysIt.hasNext()) {
                        String key = keysIt.next();
                        Object value = button.get(key);
                        if (value instanceof Boolean) {
                            bundle.putBoolean(key, (Boolean) value);
                        } else if (value instanceof Integer) {
                            bundle.putInt(key, (Integer) value);
                        } else {
                            bundle.putString(key, value.toString());
                        }
                    }
                    buttonsList.add(bundle);
                }

                builder.setConfigOverride("customToolbarButtons", buttonsList);
            } catch (JSONException e) {
                Timber.tag(TAG).e(e, "❌ Failed to parse customToolbarButtons");
            }
        }


        if(startWithAudioMuted != null){
            builder.setAudioMuted(startWithAudioMuted);
        }
        if(startWithVideoMuted != null){
            builder.setVideoMuted(startWithVideoMuted);
        }

        // default PiP is off, but allowing user to overrides it by providing the featureFlag below
        builder.setFeatureFlag("pip.enabled", false);

        // general settings can be overridden by subsequent featureFlags settings
        if(call.getBoolean("chatEnabled") != null){
            builder.setFeatureFlag("chat.enabled", call.getBoolean("chatEnabled"));
        }
        if(call.getBoolean("inviteEnabled") != null){
            builder.setFeatureFlag("invite.enabled", call.getBoolean("inviteEnabled"));
        }

        // setfeatureFlag() provides finer control, and will override some of the setFeatureFlag methods above
        Iterator<String> keys = featureFlags.keys();
        while(keys.hasNext()) {
            String key = keys.next();
            // Can only be bool, int or string according to
            // the overloads of setFeatureFlag.

            if (featureFlags.get(key) != null) {
                if (featureFlags.get(key) instanceof Boolean) {
                    builder.setFeatureFlag(key, (Boolean) featureFlags.get(key));
                } else if (featureFlags.get(key) instanceof Integer) {
                    builder.setFeatureFlag(key, (Integer) featureFlags.get(key));
                } else if (featureFlags.get(key) instanceof String) {
                    builder.setFeatureFlag(key, (String) featureFlags.get(key));
                } else {
                    builder.setFeatureFlag(key, featureFlags.get(key).toString());
                }
            }
        }

        keys = configOverrides.keys();
        while(keys.hasNext()) {
            String key = keys.next();
            // Can only be bool, int or string according to
            // the overloads of setFeatureFlag.

            // Чтобы не задвоить customToolbarButtons
            if (key.equals("customToolbarButtons")) continue;

            if (configOverrides.get(key) != null) {
                if (configOverrides.get(key) instanceof Boolean) {
                    builder.setConfigOverride(key, (Boolean) configOverrides.get(key));
                } else if (configOverrides.get(key) instanceof Integer) {
                    builder.setConfigOverride(key, (Integer) configOverrides.get(key));
                } else if (configOverrides.get(key) instanceof String[]) {
                    builder.setConfigOverride(key, (String[]) configOverrides.get(key));
                } else {
                    builder.setConfigOverride(key, configOverrides.get(key).toString());
                }
            }
        }
        JitsiMeetConferenceOptions options = builder.build();
        JitsiActivity.launch(getActivity(), options);

        JSObject ret = new JSObject();
        ret.put("success", true);
        call.resolve(ret);
    }

    @PluginMethod()
    public void leaveConference(PluginCall call) {
        Intent leaveBroadcastIntent = BroadcastIntentHelper.buildHangUpIntent();
        LocalBroadcastManager.getInstance(getContext()).sendBroadcast(leaveBroadcastIntent);

        JSObject ret = new JSObject();
        ret.put("success", true);
        call.resolve(ret);
    }

    @PluginMethod()
    public void enterPictureInPictureMode(PluginCall call) {
        Intent pipIntent = new Intent("enterPiPMode");
        LocalBroadcastManager.getInstance(getContext()).sendBroadcast(pipIntent);

        JSObject ret = new JSObject();
        ret.put("success", true);
        call.resolve(ret);
    }

    public void onEventReceived(String eventName, String data) {
        bridge.triggerWindowJSEvent(eventName, data);
        if(eventName.equals("onConferenceJoined")) {
            Intent retrieveParticipantsIntent = BroadcastIntentHelper.buildRetrieveParticipantsInfo("retrieveSelfInfo");
            LocalBroadcastManager.getInstance(getContext()).sendBroadcast(retrieveParticipantsIntent);
        }
        if(eventName.equals("onConferenceLeft")) {
            if (receiver != null) {
                getContext().unregisterReceiver(receiver);
                receiver = null;
            }
        }
    }
}