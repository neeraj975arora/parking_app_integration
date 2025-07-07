package com.example.visionpark.activities;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Toast;
import com.example.visionpark.R;
import com.google.android.material.button.MaterialButton;
import android.widget.TextView;
import android.widget.EditText;
import com.example.visionpark.utils.TokenManager;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.http.Body;
import retrofit2.http.POST;
import android.util.Patterns;

// Retrofit API interface
interface RegisterApi {
    @POST("/auth/register")
    Call<RegisterResponse> register(@Body RegisterRequest request);
}

class RegisterRequest {
    String user_name;
    String user_email;
    String user_password;
    String user_phone_no;
    String user_address;
    RegisterRequest(String name, String email, String password, String phone, String address) {
        this.user_name = name;
        this.user_email = email;
        this.user_password = password;
        this.user_phone_no = phone;
        this.user_address = address;
    }
}

class RegisterResponse {
    String message;
    // Add other fields if needed
}

public class RegistrationActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_registration);

        MaterialButton btnRegister = findViewById(R.id.btnRegister);
        EditText etName = findViewById(R.id.etName);
        EditText etEmail = findViewById(R.id.etEmail);
        EditText etPassword = findViewById(R.id.etPassword);
        EditText etPhone = findViewById(R.id.etPhone);
        EditText etAddress = findViewById(R.id.etAddress);

        btnRegister.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String name = etName.getText().toString().trim();
                String email = etEmail.getText().toString().trim();
                String password = etPassword.getText().toString().trim();
                String phone = etPhone.getText().toString().trim();
                String address = etAddress.getText().toString().trim();
                if (name.isEmpty() || email.isEmpty() || password.isEmpty() || phone.isEmpty() || address.isEmpty()) {
                    Toast.makeText(RegistrationActivity.this, "Please fill all fields", Toast.LENGTH_SHORT).show();
                    return;
                }
                // Email format validation (Toast only)
                if (!Patterns.EMAIL_ADDRESS.matcher(email).matches()) {
                    Toast.makeText(RegistrationActivity.this, "Please enter a valid email", Toast.LENGTH_SHORT).show();
                    return;
                }
                // Password length validation (Toast only)
                if (password.length() < 4) {
                    Toast.makeText(RegistrationActivity.this, "Password must be at least 4 characters", Toast.LENGTH_SHORT).show();
                    return;
                }
                Retrofit retrofit = new Retrofit.Builder()
                        .baseUrl("http://10.0.2.2/") // Updated to use nginx proxy
                        .addConverterFactory(GsonConverterFactory.create())
                        .build();
                RegisterApi api = retrofit.create(RegisterApi.class);
                RegisterRequest request = new RegisterRequest(name, email, password, phone, address);
                api.register(request).enqueue(new Callback<RegisterResponse>() {
                    @Override
                    public void onResponse(Call<RegisterResponse> call, Response<RegisterResponse> response) {
                        if (response.isSuccessful()) {
                            Toast.makeText(RegistrationActivity.this, "Registration successful! Please login.", Toast.LENGTH_SHORT).show();
                            Intent intent = new Intent(RegistrationActivity.this, LoginActivity.class);
                            startActivity(intent);
                            finish();
                        } else {
                            Toast.makeText(RegistrationActivity.this, "Registration failed: " + response.message(), Toast.LENGTH_SHORT).show();
                        }
                    }
                    @Override
                    public void onFailure(Call<RegisterResponse> call, Throwable t) {
                        Toast.makeText(RegistrationActivity.this, "Registration failed: " + t.getMessage(), Toast.LENGTH_SHORT).show();
                    }
                });
            }
        });

        TextView tvLogin = findViewById(R.id.tvLogin);
        tvLogin.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(RegistrationActivity.this, LoginActivity.class);
                startActivity(intent);
                finish();
            }
        });
    }
} 