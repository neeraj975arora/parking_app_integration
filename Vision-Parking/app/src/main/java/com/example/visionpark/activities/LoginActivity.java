package com.example.visionpark.activities;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.widget.Toast;
import com.example.visionpark.R;
import com.google.android.material.button.MaterialButton;
import android.widget.TextView;
import android.content.Intent;
import android.widget.EditText;
import com.example.visionpark.utils.TokenManager;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.http.Body;
import retrofit2.http.POST;
import retrofit2.http.Headers;
import com.google.gson.annotations.SerializedName;

// Retrofit API interface
interface AuthApi {
    @Headers("Content-Type: application/json")
    @POST("/auth/login")
    Call<LoginResponse> login(@Body LoginRequest request);
}

class LoginRequest {
    String user_email;
    String user_password;
    LoginRequest(String email, String password) {
        this.user_email = email;
        this.user_password = password;
    }
}

class LoginResponse {
    @SerializedName("access_token")
    String accessToken;
    @SerializedName("username")
    String username;
    @SerializedName("user_email")
    String userEmail;
    @SerializedName("user_id")
    int userId;
    @SerializedName("user_address")
    String userAddress;
    @SerializedName("user_phone_no")
    String userPhoneNo;
}

public class LoginActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);

        MaterialButton btnLogin = findViewById(R.id.btnLogin);
        TextView tvRegister = findViewById(R.id.tvRegister);
        EditText etEmail = findViewById(R.id.etEmail);
        EditText etPassword = findViewById(R.id.etPassword);

        btnLogin.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String email = etEmail.getText().toString().trim();
                String password = etPassword.getText().toString().trim();
                if (email.isEmpty() || password.isEmpty()) {
                    Toast.makeText(LoginActivity.this, "Please enter email and password", Toast.LENGTH_SHORT).show();
                    return;
                }
                Retrofit retrofit = new Retrofit.Builder()
                        .baseUrl("http://10.0.2.2/") // Updated to use nginx proxy
                        .addConverterFactory(GsonConverterFactory.create())
                        .build();
                AuthApi api = retrofit.create(AuthApi.class);
                LoginRequest request = new LoginRequest(email, password);
                api.login(request).enqueue(new Callback<LoginResponse>() {
                    @Override
                    public void onResponse(Call<LoginResponse> call, Response<LoginResponse> response) {
                        if (response.isSuccessful() && response.body() != null && response.body().accessToken != null) {
                            TokenManager.saveToken(LoginActivity.this, response.body().accessToken);
                            // Save user details
                            LoginResponse loginResp = response.body();
                            getSharedPreferences("visionpark_prefs", MODE_PRIVATE)
                                .edit()
                                .putString("username", loginResp.username)
                                .putString("user_email", loginResp.userEmail)
                                .putInt("user_id", loginResp.userId)
                                .putString("user_address", loginResp.userAddress)
                                .putString("user_phone_no", loginResp.userPhoneNo)
                                .apply();
                            Intent intent = new Intent(LoginActivity.this, HomeActivity.class);
                            startActivity(intent);
                            finish();
                        } else {
                            String errorBody = "";
                            try {
                                if (response.errorBody() != null) {
                                    errorBody = response.errorBody().string();
                                }
                            } catch (Exception e) {
                                errorBody += " [Exception reading errorBody: " + e.getMessage() + "]";
                            }
                            String message = "Login failed: HTTP " + response.code() + " " + response.message() + "\n" + errorBody;
                            Toast.makeText(LoginActivity.this, message, Toast.LENGTH_LONG).show();
                        }
                    }
                    @Override
                    public void onFailure(Call<LoginResponse> call, Throwable t) {
                        Toast.makeText(LoginActivity.this, "Login failed: " + t.getMessage(), Toast.LENGTH_SHORT).show();
                    }
                });
            }
        });

        tvRegister.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(LoginActivity.this, RegistrationActivity.class);
                startActivity(intent);
            }
        });
    }
} 