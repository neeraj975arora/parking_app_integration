package com.example.visionpark.utils;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Build;
import androidx.annotation.Nullable;
import androidx.security.crypto.EncryptedSharedPreferences;
import androidx.security.crypto.MasterKey;
import java.io.IOException;
import java.security.GeneralSecurityException;

public class TokenManager {
    private static final String PREF_NAME = "visionpark_prefs";
    private static final String KEY_TOKEN = "auth_token";

    private static SharedPreferences getPrefs(Context context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            try {
                MasterKey masterKey = new MasterKey.Builder(context)
                        .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
                        .build();
                return EncryptedSharedPreferences.create(
                        context,
                        PREF_NAME,
                        masterKey,
                        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
                        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
                );
            } catch (GeneralSecurityException | IOException e) {
                e.printStackTrace();
                // Fallback to regular SharedPreferences
            }
        }
        return context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE);
    }

    public static void saveToken(Context context, String token) {
        SharedPreferences.Editor editor = getPrefs(context).edit();
        editor.putString(KEY_TOKEN, token);
        editor.apply();
    }

    @Nullable
    public static String getToken(Context context) {
        return getPrefs(context).getString(KEY_TOKEN, null);
    }

    public static void clearToken(Context context) {
        SharedPreferences.Editor editor = getPrefs(context).edit();
        editor.remove(KEY_TOKEN);
        editor.apply();
    }
} 