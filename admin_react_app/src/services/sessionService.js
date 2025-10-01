import api from './api';
import { API_ENDPOINTS, USER_ROLES } from '../utils/constants';

/**
 * Check out a vehicle from parking session
 * @param {string} ticketId - The ticket ID to check out
 * @param {string} paymentMethod - The payment method (cash, digital, or card)
 * @returns {Promise} API response
 */
export const checkOutVehicle = async (ticketId, paymentMethod = 'digital') => {
  try {
    console.log('checkOutVehicle called with:', { ticketId, paymentMethod });
    
    const requestData = {
      ticket_id: ticketId,
      payment_method: paymentMethod
    };
    
    console.log('Sending checkout request:', requestData);
    
    const response = await api.post(API_ENDPOINTS.ADMIN.SESSION_CHECKOUT, requestData);
    return response.data;
  } catch (error) {
    console.error('Error checking out vehicle:', error);
    
    // Handle 403 error specifically
    if (error.response?.status === 403) {
      throw new Error('Access denied: Insufficient permissions to check out vehicle');
    }
    
    // Handle other errors
    if (error.response?.status === 404) {
      throw new Error('Ticket not found or already checked out');
    }
    
    throw new Error(error.response?.data?.message || 'Failed to check out vehicle');
  }
};

/**
 * Get active sessions for live monitoring
 * @param {Object} user - Current user object
 * @returns {Promise} Active sessions data
 */
export const getActiveSessions = async (user) => {
  try {
    if (!user) return { activeSessions: [], stats: { activeParticipants: 0, totalRevenue: 0, avgSessionTime: '0h 0m', occupancyRate: 0 }, recentActivity: [] };

    // Fetch sessions based on role
    const { data } = user.role === USER_ROLES.SUPER_ADMIN
      ? await api.get(API_ENDPOINTS.ADMIN.ALL_SESSION_DETAILS)
      : await api.get(`${API_ENDPOINTS.ADMIN.SESSION_DETAILS}/${user.user_id}`);

    const sessions = Array.isArray(data) ? data : [];
    const now = Date.now();

    const toHsl = (str) => {
      let hash = 0;
      for (let i = 0; i < str.length; i++) hash = str.charCodeAt(i) + ((hash << 5) - hash);
      const h = Math.abs(hash) % 360; return `hsl(${h}, 70%, 55%)`;
    };
    const formatDuration = (hours) => {
      if (!hours || hours <= 0) return '0h 0m';
      const whole = Math.floor(hours); const mins = Math.round((hours - whole) * 60); return `${whole}h ${mins}m`;
    };

    // Active sessions are those without end_time
    const active = sessions.filter(s => !s.end_time).map(s => {
      const startMs = new Date(s.start_time).getTime();
      const elapsedHours = Math.max(0, (now - startMs) / (1000 * 60 * 60));
      return {
        ticket_id: s.ticket_id,
        participant_name: s.participant_name || s.vehicle_reg_no || 'Participant',
        vehicle_reg_no: s.vehicle_reg_no,
        parkinglot_id: s.parkinglot_id,
        start_time: s.start_time,
        duration: formatDuration(elapsedHours),
        vehicle_type: s.vehicle_type,
        avatar_color: toHsl(s.vehicle_reg_no || s.ticket_id || String(startMs))
      };
    });

    // Stats
    const activeParticipants = active.length;
    const avgSessionTimeHours = activeParticipants > 0
      ? active.reduce((sum, p) => {
          const start = new Date(p.start_time).getTime();
          return sum + Math.max(0, (now - start) / (1000 * 60 * 60));
        }, 0) / activeParticipants
      : 0;
    const totalRevenue = active.reduce((sum, p) => {
      const start = new Date(p.start_time).getTime();
      const hrs = Math.max(0, (now - start) / (1000 * 60 * 60));
      // Normalize vehicle type case for consistent comparison
      const vehicleType = (p.vehicle_type || '').toLowerCase();
      const rate = vehicleType === 'car' ? 50 : 30;
      return sum + hrs * rate;
    }, 0);
    // TODO: Get actual total slots from parking lot API
    // For now, use a reasonable default based on active sessions
    const estimatedTotalSlots = Math.max(activeParticipants * 2, 50);
    const occupancyRate = Math.min(100, Math.round((activeParticipants / estimatedTotalSlots) * 100));

    // Generate recent activity from session data
    const recentActivity = sessions
      .filter(s => s.end_time) // Only completed sessions
      .sort((a, b) => new Date(b.end_time) - new Date(a.end_time))
      .slice(0, 10)
      .map(s => ({
        type: 'leave',
        message: `Vehicle ${s.vehicle_reg_no} checked out`,
        time: new Date(s.end_time).toLocaleTimeString(),
        timestamp: s.end_time
      }));

    return {
      activeSessions: active,
      stats: {
        activeParticipants,
        totalRevenue: Math.round(totalRevenue * 100) / 100,
        avgSessionTime: formatDuration(avgSessionTimeHours),
        occupancyRate
      },
      recentActivity
    };
  } catch (error) {
    console.error('Error fetching active sessions:', error);
    throw error;
  }
};

// MOCK CODE REMOVED - Use real backend API only
// getMockActiveSessions() { ... }