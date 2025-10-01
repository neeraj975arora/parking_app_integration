import api from "./api";
import { API_ENDPOINTS, STORAGE_KEYS } from "../utils/constants";
import { isTokenExpired } from "../utils/helpers";
// import mockApiService from './mockApiService';

class AuthService {
  // Login method
  // async login(credentials) {
  //   // Use mock API service if enabled
  //   if (mockApiService.isEnabled) {
  //     try {
  //       const data = await mockApiService.login(credentials);
        
    //     // Return structured user data for mock API
    //     return {
    //       access_token: data.access_token,
    //       user: {
    //         user_id: data.user_id,
    //         username: data.username,
    //         user_email: data.user_email,
    //         role: data.role,
    //         user_phone_no: data.user_phone_no,
    //         user_address: data.user_address,
    //         assigned_lots: data.assigned_lots, // For admin users
    //       },
    //     };
    //   } catch (error) {
    //     // Mock API error handling
    //     throw new Error(error.message || "Login failed");
    //   }
    // }
    async login(credentials) {
     try {
      const response = await api.post(API_ENDPOINTS.AUTH.LOGIN, {
        user_email: credentials.user_email,
        user_password: credentials.user_password,
        role: credentials.role,
      });

      const { data } = response;

      // Validate response structure
      if (!data.access_token || !data.user_id) {
        throw new Error("Invalid response from server");
      }

      // Return structured user data
      return {
        access_token: data.access_token,
        user: {
          user_id: data.user_id,
          username: data.username,
          user_email: data.user_email,
          role: data.role,
          user_phone_no: data.user_phone_no,
          user_address: data.user_address,
        },
      };
    } catch (error) {
      // Handle specific login errors
      if (error.response) {
        const { status, data } = error.response;

        switch (status) {
          case 400:
            throw new Error(data?.message || "Invalid login credentials");
          case 401:
            throw new Error("Invalid email, password, or role");
          case 403:
            throw new Error("Access denied for this role");
          case 429:
            throw new Error("Too many login attempts. Please try again later");
          default:
            throw new Error(data?.message || "Login failed. Please try again");
        }
      } else if (error.request) {
        throw new Error("Network error. Please check your connection");
      } else {
        throw new Error(error.message || "An unexpected error occurred");
      }
    }
  }

  // Logout method
  logout() {
    try {
      // Clear authentication data from localStorage
      localStorage.removeItem(STORAGE_KEYS.AUTH_TOKEN);
      localStorage.removeItem(STORAGE_KEYS.AUTH_USER);

      // Optional: Call logout endpoint if available
      // await api.post('/auth/logout');

      return { success: true };
    } catch (error) {
      console.error("Logout error:", error);
      // Even if logout API fails, clear local data
      localStorage.removeItem(STORAGE_KEYS.AUTH_TOKEN);
      localStorage.removeItem(STORAGE_KEYS.AUTH_USER);
      return { success: true };
    }
  }

  // Get current user from localStorage
  getCurrentUser() {
    try {
      const token = localStorage.getItem(STORAGE_KEYS.AUTH_TOKEN);
      const userStr = localStorage.getItem(STORAGE_KEYS.AUTH_USER);

      if (!token || !userStr || isTokenExpired(token)) {
        return null;
      }

      return JSON.parse(userStr);
    } catch (error) {
      console.error("Error getting current user:", error);
      return null;
    }
  }

  // Check if user is authenticated
  isAuthenticated() {
    const token = localStorage.getItem(STORAGE_KEYS.AUTH_TOKEN);
    const user = this.getCurrentUser();

    return Boolean(token && user && !isTokenExpired(token));
  }

  // Get current token
  getToken() {
    const token = localStorage.getItem(STORAGE_KEYS.AUTH_TOKEN);

    if (!token || isTokenExpired(token)) {
      return null;
    }

    return token;
  }

  // Refresh token (placeholder for future implementation)
  async refreshToken() {
    try {
      // This would be implemented if the backend supports token refresh
      // const response = await api.post('/auth/refresh');
      // const { access_token } = response.data;
      // localStorage.setItem(STORAGE_KEYS.AUTH_TOKEN, access_token);
      // return access_token;

      throw new Error("Token refresh not implemented");
    } catch (error) {
      console.error("Token refresh error:", error);
      // If refresh fails, logout user
      this.logout();
      throw error;
    }
  }

  // Check user role
  hasRole(requiredRole) {
    const user = this.getCurrentUser();
    if (!user) return false;

    // Super admin has access to everything
    if (user.role === "super_admin") return true;

    // Check specific role
    return user.role === requiredRole;
  }

  // Check if user has any of the specified roles
  hasAnyRole(roles) {
    const user = this.getCurrentUser();
    if (!user) return false;

    // Super admin has access to everything
    if (user.role === "super_admin") return true;

    return roles.includes(user.role);
  }
}

// Create and export a singleton instance
const authService = new AuthService();
export default authService;
