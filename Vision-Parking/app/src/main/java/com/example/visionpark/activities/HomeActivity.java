package com.example.visionpark.activities;

import android.content.Intent;
import android.os.Bundle;
import androidx.annotation.NonNull;
import androidx.appcompat.app.ActionBarDrawerToggle;
import androidx.appcompat.app.AppCompatActivity;
import androidx.drawerlayout.widget.DrawerLayout;
import com.google.android.material.appbar.MaterialToolbar;
import com.google.android.material.bottomnavigation.BottomNavigationView;
import com.google.android.material.navigation.NavigationView;
import android.view.MenuItem;
import android.widget.Toast;
import com.example.visionpark.R;
import com.example.visionpark.utils.TokenManager;
import android.view.View;
import android.widget.TextView;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.LatLng;

public class HomeActivity extends AppCompatActivity implements OnMapReadyCallback {
    private DrawerLayout drawerLayout;
    private NavigationView navigationView;
    private BottomNavigationView bottomNavigationView;
    private MaterialToolbar topAppBar;
    private ActionBarDrawerToggle drawerToggle;
    private GoogleMap mMap;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);

        drawerLayout = findViewById(R.id.drawer_layout);
        navigationView = findViewById(R.id.navigation_view);
        bottomNavigationView = findViewById(R.id.bottomNavigationView);
        topAppBar = findViewById(R.id.topAppBar);

        // Set up toolbar with hamburger icon
        setSupportActionBar(topAppBar);
        drawerToggle = new ActionBarDrawerToggle(this, drawerLayout, topAppBar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
        drawerLayout.addDrawerListener(drawerToggle);
        drawerToggle.syncState();

        // Set username in drawer header
        View headerView = navigationView.getHeaderView(0);
        TextView tvUserName = headerView.findViewById(R.id.tvUserName);
        android.content.SharedPreferences prefs = getSharedPreferences("visionpark_prefs", MODE_PRIVATE);
        String username = prefs.getString("username", "User");
        tvUserName.setText(username);

        // Navigation drawer item selection
        navigationView.setNavigationItemSelectedListener(new NavigationView.OnNavigationItemSelectedListener() {
            @Override
            public boolean onNavigationItemSelected(@NonNull MenuItem item) {
                int id = item.getItemId();
                if (id == R.id.nav_logout) {
                    TokenManager.clearToken(HomeActivity.this);
                    Intent intent = new Intent(HomeActivity.this, LoginActivity.class);
                    intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
                    startActivity(intent);
                    finish();
                    return true;
                } else {
                    // Handle other drawer items (show Toast for now)
                    Toast.makeText(HomeActivity.this, item.getTitle() + " clicked", Toast.LENGTH_SHORT).show();
                }
                drawerLayout.closeDrawers();
                return true;
            }
        });

        // Bottom navigation item selection
        bottomNavigationView.setOnNavigationItemSelectedListener(new BottomNavigationView.OnNavigationItemSelectedListener() {
            @Override
            public boolean onNavigationItemSelected(@NonNull MenuItem item) {
                if (item.getItemId() == R.id.nav_profile) {
                    Intent intent = new Intent(HomeActivity.this, ProfileActivity.class);
                    startActivity(intent);
                    return true;
                }
                // Handle other bottom nav items (show Toast for now)
                Toast.makeText(HomeActivity.this, item.getTitle() + " selected", Toast.LENGTH_SHORT).show();
                return true;
            }
        });

        // Initialize Google Map
        SupportMapFragment mapFragment = (SupportMapFragment) getSupportFragmentManager().findFragmentById(R.id.mapFragment);
        if (mapFragment != null) {
            mapFragment.getMapAsync(this);
        }
    }

    @Override
    public void onMapReady(GoogleMap googleMap) {
        mMap = googleMap;
        // Move camera to a default location (e.g., New Delhi)
        LatLng defaultLocation = new LatLng(28.6139, 77.2090);
        mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(defaultLocation, 12f));
    }
} 