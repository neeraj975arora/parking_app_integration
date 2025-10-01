import api from './api';
import { API_ENDPOINTS } from '../utils/constants';

class AdminService {
  // Create new admin with lot assignments
  // adminService.js - Fix createAdmin method
  async createAdmin(adminData) {
    try {
      const requestData = {
        name: adminData.name,
        email: adminData.email,
        password: adminData.password,
        role: 'admin',
        assigned_lots: adminData.assigned_lots,
        phone_no: adminData.phone_no,
        address: adminData.address
      };

      console.log('Creating admin with data:', requestData);
      console.log('Using endpoint:', API_ENDPOINTS.ADMIN.CREATE);

      const response = await api.post(API_ENDPOINTS.ADMIN.CREATE, requestData);

      console.log('Admin creation response:', response.data);
      return response.data;
    } catch (error) {
      console.error('Admin creation error:', error);
      if (error.response) {
        const { status, data } = error.response;
        console.error('Error response:', { status, data });
        
        switch (status) {
          case 400:
            throw new Error(data?.error || data?.message || 'Invalid admin data provided');
          case 403:
            throw new Error('You are not authorized to create admin accounts');
          case 409:
            throw new Error('An admin with this email already exists');
          default:
            throw new Error(data?.error || data?.message || 'Failed to create admin account');
        }
      } else if (error.request) {
        throw new Error('Network error. Please check your connection');
      } else {
        throw new Error(error.message || 'An unexpected error occurred');
      }
    }
  }

  // Get all admin data with assigned lots
  async getAllAdmins() {
    try {
      const response = await api.get(API_ENDPOINTS.ADMIN.ALL_ADMIN_LOTS);
      const payload = response?.data;
      const assignments = Array.isArray(payload?.data) ? payload.data : [];
      // Normalize to the shape expected by UI (array of admins)
      const admins = assignments.map((a) => ({
        admin_id: a.user_id, // Backend returns user_id, map it to admin_id
        user_id: a.user_id, // Keep user_id as well
        name: a.user_name, // Backend returns user_name
        username: a.user_name, // Add username as fallback
        email: a.user_email || undefined,
        phone_no: a.user_phone_no, // Backend returns user_phone_no
        role: 'admin',
        assigned_lots: Array.isArray(a.assigned_lots) ? a.assigned_lots : [],
        // Include additional fields for future use
        admin_phone_no: a.user_phone_no,
        admin_address: a.user_address,
        joining_date: a.joining_date,
        status: a.status,
        permissions: a.permissions,
        shift_timings: a.shift_timings
      }));
      return admins;
    } catch (error) {
      if (error.response) {
        const { status, data } = error.response;
        
        switch (status) {
          case 403:
            throw new Error('You are not authorized to view admin data');
          case 404:
            throw new Error('Admin data not found');
          default:
            throw new Error(data?.message || 'Failed to fetch admin data');
        }
      } else if (error.request) {
        throw new Error('Network error. Please check your connection');
      } else {
        throw new Error(error.message || 'An unexpected error occurred');
      }
    }
  }

  // Get single admin data with assigned lots
  async getAdminById(adminId) {
    try {
      const response = await api.get(`/admin/admin_lots/${adminId}`);
      const adminData = response?.data;
      
      // Return the admin data with the new structure
      return {
        admin_id: adminData.admin_id,
        admin_name: adminData.admin_name,
        admin_email: adminData.admin_email,
        admin_phone_no: adminData.admin_phone_no,
        admin_address: adminData.admin_address,
        joining_date: adminData.joining_date,
        status: adminData.status,
        assigned_lots: Array.isArray(adminData.assigned_lots) ? adminData.assigned_lots : [],
        // Future fields
        permissions: adminData.permissions,
        shift_timings: adminData.shift_timings
      };
    } catch (error) {
      if (error.response) {
        const { status, data } = error.response;
        
        switch (status) {
          case 403:
            throw new Error('You are not authorized to view admin data');
          case 404:
            throw new Error('Admin not found');
          default:
            throw new Error(data?.message || 'Failed to fetch admin data');
        }
      } else if (error.request) {
        throw new Error('Network error. Please check your connection');
      } else {
        throw new Error(error.message || 'An unexpected error occurred');
      }
    }
  }

  // Delete admin assignment
  async deleteAdmin(adminId, parkingLotIds = []) {
    try {
      // If no parking lot IDs provided, we can't delete anything
      if (!parkingLotIds || parkingLotIds.length === 0) {
        throw new Error('No parking lots assigned to this admin');
      }

      console.log('Sending delete request with data:', {
        admin_id: adminId,
        parking_lot_id: parkingLotIds
      });

      const response = await api.delete(API_ENDPOINTS.ADMIN.REMOVE_ASSIGNMENT, {
        data: { 
          admin_id: adminId,
          parking_lot_id: parkingLotIds
        }
      });
      
      console.log('Delete response:', response.data);
      return response.data;
    } catch (error) {
      console.error('Delete admin error:', error);
      if (error.response) {
        const { status, data } = error.response;
        console.error('Error response:', { status, data });
        
        switch (status) {
          case 400:
            throw new Error(data?.msg || data?.message || 'Invalid request data');
          case 403:
            throw new Error('You are not authorized to delete admin accounts');
          case 404:
            throw new Error('Admin assignment not found');
          default:
            throw new Error(data?.msg || data?.message || 'Failed to delete admin assignment');
        }
      } else if (error.request) {
        throw new Error('Network error. Please check your connection');
      } else {
        throw new Error(error.message || 'An unexpected error occurred');
      }
    }
  }

  // Get all session details (for Super Admin)
  async getAllSessionDetails() {
    try {
      const response = await api.get(API_ENDPOINTS.ADMIN.ALL_SESSION_DETAILS);
      return response.data;
    } catch (error) {
      if (error.response) {
        const { status, data } = error.response;
        
        switch (status) {
          case 403:
            throw new Error('You are not authorized to view session data');
          default:
            throw new Error(data?.message || 'Failed to fetch session data');
        }
      } else if (error.request) {
        throw new Error('Network error. Please check your connection');
      } else {
        throw new Error(error.message || 'An unexpected error occurred');
      }
    }
  }
}

// Create and export a singleton instance
const adminService = new AdminService();
export default adminService;