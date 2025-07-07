package com.example.visionpark.activities;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import com.example.visionpark.R;
import com.google.android.material.button.MaterialButton;
import com.example.visionpark.utils.TokenManager;

public class SplashScreenActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash_screen);

        MaterialButton btnGetStarted = findViewById(R.id.btnGetStarted);
        btnGetStarted.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String token = TokenManager.getToken(SplashScreenActivity.this);
                Intent intent;
                if (token != null && !token.isEmpty()) {
                    intent = new Intent(SplashScreenActivity.this, HomeActivity.class);
                } else {
                    intent = new Intent(SplashScreenActivity.this, LoginActivity.class);
                }
                startActivity(intent);
                finish();
            }
        });
    }
} 