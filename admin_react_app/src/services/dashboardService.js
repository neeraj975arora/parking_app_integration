import api from './api';
import { API_ENDPOINTS, USER_ROLES } from '../utils/constants';

/**
 * Fetch session details based on user role
 * @param {Object} user - User object with role and user_id
 * @returns {Promise<{sessions: Array}>} Session data
 */
export const fetchSessionDetails = async (user) => {
  try {
    if (!user) return { sessions: [] };

    let endpoint;
    if (user.role === USER_ROLES.SUPER_ADMIN) {
      // Super admin can access all sessions
      endpoint = API_ENDPOINTS.ADMIN.ALL_SESSION_DETAILS;
    } else if (user.role === USER_ROLES.ADMIN) {
      // Regular admin can only access their own sessions
      endpoint = `${API_ENDPOINTS.ADMIN.SESSION_DETAILS}/${user.user_id}`;
    } else {
      throw new Error(`Invalid user role: ${user.role}`);
    }

    const { data } = await api.get(endpoint);
    return { sessions: Array.isArray(data) ? data : [] };
  } catch (error) {
    console.error('Error fetching session details from API:', error);
    throw error;
  }
};

/**
 * Fetch admin lots information based on user role
 * @param {number} adminId - Admin user ID
 * @param {string} role - User role (super_admin or admin)
 * @returns {Promise<Array>} Array of assigned parking lots
 */
export const fetchAdminLots = async (adminId, role) => {
  try {
    if (!adminId) return [];

    if (role === USER_ROLES.SUPER_ADMIN) {
      // Super admin can access all admin assignments
      const { data } = await api.get(API_ENDPOINTS.ADMIN.ALL_ADMIN_LOTS);
      // API returns {meta: {total}, data: [{admin_id, admin_name, assigned_lots: [{parkinglot_id, ...}]}]}
      const assignments = Array.isArray(data?.data) ? data.data : [];
      const lotIds = new Set();
      assignments.forEach(a => (a.assigned_lots || []).forEach(lot => lotIds.add(lot.parkinglot_id)));
      return Array.from(lotIds).map(id => ({ parkinglot_id: id }));
    } else if (role === USER_ROLES.ADMIN) {
      // Regular admin can only access their own assigned lots
      const { data } = await api.get(`/admin/admin_lots/${adminId}`);
      // API returns object with assigned_lots: [{ parkinglot_id, parking_name, location, parking_type, assigned_date }]
      return Array.isArray(data?.assigned_lots) ? data.assigned_lots : [];
    } else {
      throw new Error(`Invalid user role: ${role}`);
    }
  } catch (error) {
    console.error('Error fetching admin lots from API:', error);
    return [];
  }
};

/**
 * Fetch detailed admin information with assigned lots
 */
export const fetchAdminDetails = async (adminId) => {
  try {
    if (!adminId) return null;

    const { data } = await api.get(`/admin/admin_lots/${adminId}`);
    
    // Return the admin data with the new structure
    return {
      admin_id: data.admin_id,
      admin_name: data.admin_name,
      admin_email: data.admin_email,
      admin_phone_no: data.admin_phone_no,
      admin_address: data.admin_address,
      joining_date: data.joining_date,
      status: data.status,
      assigned_lots: Array.isArray(data.assigned_lots) ? data.assigned_lots : [],
      // Future fields
      permissions: data.permissions,
      shift_timings: data.shift_timings
    };
  } catch (error) {
    console.error('Error fetching admin details from API:', error);
    return null;
  }
};

/**
 * Fetch parking lot statistics (total slots, available slots, occupied slots)
 * @param {number} lotId - Parking lot ID
 * @returns {Promise<Object>} Parking lot statistics
 */
const fetchParkingLotStats = async (lotId) => {
  try {
    const { data } = await api.get(`/parking/lots/${lotId}/stats`);
    return data;
  } catch (error) {
    console.error(`Error fetching stats for parking lot ${lotId}:`, error);
    return null;
  }
};

/**
 * Calculate total parking slots for user's assigned lots
 * @param {Array} adminLots - Array of assigned parking lots
 * @returns {Promise<number>} Total parking slots
 */
const calculateTotalParkingSlots = async (adminLots) => {
  try {
    if (!Array.isArray(adminLots) || adminLots.length === 0) {
      return 0;
    }

    // Fetch stats for all assigned lots
    const statsPromises = adminLots.map(lot => 
      fetchParkingLotStats(lot.parkinglot_id)
    );
    
    const statsResults = await Promise.all(statsPromises);
    
    // Sum up total slots from all lots
    const totalSlots = statsResults.reduce((sum, stats) => {
      return sum + (stats?.total_slots || 0);
    }, 0);
    
    return totalSlots;
  } catch (error) {
    console.error('Error calculating total parking slots:', error);
    return 0;
  }
};

/**
 * Generate revenue chart data from mock sessions
 */
export const generateRevenueChartData = (sessions) => {
  // Group sessions by date and calculate daily revenue (with fallback estimation)
  const revenueByDate = {};
  
  const estimateAmount = (s) => {
    // Check if amount_paid exists (from database)
    if (typeof s.amount_paid === 'number' && s.amount_paid > 0) return s.amount_paid;
    // Fallback: calculate from duration and vehicle type
    const duration = typeof s.duration_hrs === 'number' ? s.duration_hrs : 0;
    if (duration <= 0) return 0;
    
    // Normalize vehicle type case for consistent comparison
    const vehicleType = (s.vehicle_type || '').toLowerCase();
    const rate = vehicleType === 'car' ? 50 : 30;
    return Math.round(duration * rate * 100) / 100;
  };
  
  sessions.forEach(session => {
    if (session.end_time) {
      const date = new Date(session.start_time).toLocaleDateString('en-IN', {
        month: 'short',
        day: 'numeric'
      });
      const amount = estimateAmount(session);
      if (!amount) return;
      
      if (revenueByDate[date]) {
        revenueByDate[date] += amount;
      } else {
        revenueByDate[date] = amount;
      }
    }
  });

  return Object.entries(revenueByDate).map(([period, revenue]) => ({
    period,
    revenue: Math.round(revenue * 100) / 100
  }));
};

/**
 * Get dashboard data with proper role-based access and safe defaults
 * @param {Object} user - User object with role and user_id
 * @returns {Promise<Object>} Dashboard data object
 */
export const getDashboardData = async (user) => {
  try {
    if (!user) {
      throw new Error('User object is required');
    }

    // Validate user role
    if (![USER_ROLES.SUPER_ADMIN, USER_ROLES.ADMIN].includes(user.role)) {
      throw new Error(`Invalid user role: ${user.role}`);
    }

    // Fetch data based on user role
    const [sessionData, adminLots] = await Promise.all([
      fetchSessionDetails(user),
      fetchAdminLots(user.user_id, user.role)
    ]);

    // Debug logging
    console.log('Dashboard data fetch results:', {
      sessionData: sessionData,
      adminLots: adminLots,
      sessionCount: sessionData.sessions?.length || 0,
      adminLotsCount: adminLots?.length || 0
    });

    // Calculate total parking slots from actual lot data
    const totalParkingSlots = await calculateTotalParkingSlots(adminLots);
    
    // Generate revenue chart data
    const revenueData = generateRevenueChartData(sessionData.sessions || []);
    
    return {
      sessions: sessionData.sessions || [],
      adminLots: adminLots || [],
      revenueData,
      totalParkingSlots
    };
  } catch (error) {
    console.error('Dashboard data fetch failed:', error.message);
    throw error;
  }
};

// MOCK CODE REMOVED - Use real backend API only
// getFallbackDashboardData(user) { ... }