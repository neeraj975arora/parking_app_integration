// KPI Calculation utilities for dashboard metrics

/**
 * Calculate total income from completed sessions
 * @param {Array} sessions - Array of session objects
 * @returns {number} Total income amount
 */
export const calculateTotalIncome = (sessions) => {
  if (!Array.isArray(sessions)) return 0;
  
  const total = sessions
    .filter(session => session.end_time !== null && session.duration_hrs)
    .reduce((total, session) => {
      // Calculate payment based on duration and vehicle type
      const duration = session.duration_hrs || 0;
      const baseRate = session.vehicle_type === 'car' ? 50 : 30; // ₹50/hr for car, ₹30/hr for motorcycle
      return total + (duration * baseRate);
    }, 0);
  
  return Math.round(total * 100) / 100; // Round to 2 decimal places
};

/**
 * Calculate total number of sessions (active + completed)
 * @param {Array} sessions - Array of session objects
 * @returns {number} Total session count
 */
export const calculateTotalSessions = (sessions) => {
  if (!Array.isArray(sessions)) return 0;
  return sessions.length;
};

/**
 * Calculate revenue per parking slot
 * @param {number} totalIncome - Total income amount
 * @param {number} totalParkingSlots - Total number of parking slots
 * @returns {number} Revenue per slot
 */
export const calculateRevenuePerSlot = (totalIncome, totalParkingSlots) => {
  if (!totalParkingSlots || totalParkingSlots === 0) return 0;
  const revenue = totalIncome / totalParkingSlots;
  return Math.round(revenue * 100) / 100; // Round to 2 decimal places
};

/**
 * Calculate number of active participants (ongoing sessions)
 * @param {Array} sessions - Array of session objects
 * @returns {number} Active participants count
 */
export const calculateActiveParticipants = (sessions) => {
  if (!Array.isArray(sessions)) return 0;
  return sessions.filter(session => session.end_time === null).length;
};

/**
 * Calculate average session time from completed sessions
 * @param {Array} sessions - Array of session objects
 * @returns {number} Average session time in hours
 */
export const calculateAverageSessionTime = (sessions) => {
  if (!Array.isArray(sessions)) return 0;
  
  const completedSessions = sessions.filter(
    session => session.end_time !== null && session.duration_hrs !== null
  );
  
  if (completedSessions.length === 0) return 0;
  
  const totalHours = completedSessions.reduce(
    (sum, session) => sum + (session.duration_hrs || 0),
    0
  );
  
  const average = totalHours / completedSessions.length;
  return Math.round(average * 100) / 100; // Round to 2 decimal places
};

/**
 * Calculate occupancy rate
 * @param {number} activeParticipants - Number of active participants
 * @param {number} totalParkingSlots - Total number of parking slots
 * @returns {number} Occupancy rate as percentage
 */
export const calculateOccupancyRate = (activeParticipants, totalParkingSlots) => {
  if (!totalParkingSlots || totalParkingSlots === 0) return 0;
  return Math.round((activeParticipants / totalParkingSlots) * 100);
};

/**
 * Calculate percentage trend between current and previous values
 * @param {number} currentValue - Current period value
 * @param {number} previousValue - Previous period value
 * @returns {number} Trend percentage
 */
export const calculateTrend = (currentValue, previousValue) => {
  if (!previousValue || previousValue === 0) {
    return currentValue > 0 ? 100 : 0;
  }
  return Math.round(((currentValue - previousValue) / previousValue) * 100);
};

/**
 * Calculate time-based trend for duration values
 * @param {number} currentHours - Current average time in hours
 * @param {number} previousHours - Previous average time in hours
 * @returns {string} Formatted time trend
 */
export const calculateTimeTrend = (currentHours, previousHours) => {
  if (!previousHours || previousHours === 0) {
    return currentHours > 0 ? '+100%' : '0%';
  }
  
  const trendPercent = Math.round(((currentHours - previousHours) / previousHours) * 100);
  return `${trendPercent > 0 ? '+' : ''}${trendPercent}%`;
};

/**
 * Calculate all dashboard KPIs from session data
 * @param {Array} sessions - Current period sessions
 * @param {Array} previousSessions - Previous period sessions (optional)
 * @param {number} totalParkingSlots - Total parking slots
 * @returns {Object} All calculated KPIs with trends
 */
export const calculateDashboardKPIs = (sessions, previousSessions = [], totalParkingSlots = 100) => {
  // Helper functions
  const calculateTotalIncome = (sessions) => {
    const estimateAmount = (s) => {
      // Check if amount_paid exists (from database)
      if (typeof s.amount_paid === 'number' && s.amount_paid > 0) return s.amount_paid;
      // Fallback: calculate from duration and vehicle type
      const duration = typeof s.duration_hrs === 'number' ? s.duration_hrs : 0;
      if (!s.end_time || duration <= 0) return 0;
      // Normalize vehicle type case for consistent comparison
      const vehicleType = (s.vehicle_type || '').toLowerCase();
      const rate = vehicleType === 'car' ? 50 : 30;
      return Math.round(duration * rate * 100) / 100;
    };
    return sessions
      .filter(s => !!s.end_time)
      .reduce((sum, s) => sum + estimateAmount(s), 0);
  };

  const calculateTotalSessions = (sessions) => sessions.length;

  const calculateRevenuePerSlot = (income, slots) => {
    if (slots <= 0) return 0;
    const revenue = income / slots;
    return Math.round(revenue * 100) / 100; // Round to 2 decimal places
  };

  const calculateActiveParticipants = (sessions) => 
    sessions.filter(s => !s.end_time).length;

  const calculateAverageSessionTime = (sessions) => {
    const completedSessions = sessions.filter(s => s.end_time && s.duration_hrs);
    if (completedSessions.length === 0) return 0;
    const average = completedSessions.reduce((sum, s) => sum + (s.duration_hrs || 0), 0) / completedSessions.length;
    return Math.round(average * 100) / 100; // Round to 2 decimal places
  };

  const calculateOccupancyRate = (active, totalSlots) => 
    totalSlots > 0 ? (active / totalSlots) * 100 : 0;

  const calculateTrend = (current, previous) => {
    if (previous === 0) return 'up';
    return current > previous ? 'up' : current < previous ? 'down' : 'neutral';
  };

  const calculateTimeTrend = (current, previous) => {
    if (previous === 0) return 'up';
    const diff = ((current - previous) / previous) * 100;
    return Math.abs(diff) < 5 ? 'neutral' : diff > 0 ? 'up' : 'down';
  };

  // Current period calculations
  const totalIncome = calculateTotalIncome(sessions);
  const totalSessions = calculateTotalSessions(sessions);
  const revenuePerSlot = calculateRevenuePerSlot(totalIncome, totalParkingSlots);
  const activeParticipants = calculateActiveParticipants(sessions);
  const averageSessionTime = calculateAverageSessionTime(sessions);
  const occupancyRate = calculateOccupancyRate(activeParticipants, totalParkingSlots);
  
  // Previous period calculations for trends
  const prevTotalIncome = calculateTotalIncome(previousSessions);
  const prevTotalSessions = calculateTotalSessions(previousSessions);
  const prevRevenuePerSlot = calculateRevenuePerSlot(prevTotalIncome, totalParkingSlots);
  const prevActiveParticipants = calculateActiveParticipants(previousSessions);
  const prevAverageSessionTime = calculateAverageSessionTime(previousSessions);
  const prevOccupancyRate = calculateOccupancyRate(prevActiveParticipants, totalParkingSlots);
  
  return {
    totalIncome: {
      value: totalIncome,
      trend: calculateTrend(totalIncome, prevTotalIncome),
      subtitle: 'Total revenue from completed sessions'
    },
    totalSessions: {
      value: totalSessions,
      trend: calculateTrend(totalSessions, prevTotalSessions),
      subtitle: 'All parking sessions (active + completed)'
    },
    revenuePerSlot: {
      value: revenuePerSlot,
      trend: calculateTrend(revenuePerSlot, prevRevenuePerSlot),
      subtitle: 'Average revenue per parking slot'
    },
    activeParticipants: {
      value: activeParticipants,
      trend: calculateTrend(activeParticipants, prevActiveParticipants),
      subtitle: 'Currently parked vehicles'
    },
    averageSessionTime: {
      value: averageSessionTime,
      trend: calculateTimeTrend(averageSessionTime, prevAverageSessionTime),
      subtitle: 'Mean duration of completed sessions'
    },
    occupancyRate: {
      value: occupancyRate,
      trend: calculateTrend(occupancyRate, prevOccupancyRate),
      subtitle: 'Current parking utilization'
    }
  };
};

/**
 * Get trend direction and color based on value
 * @param {number} trendValue - Trend percentage value
 * @returns {Object} Trend direction and color info
 */
export const getTrendInfo = (trendValue) => {
  if (trendValue > 0) {
    return { direction: 'up', color: 'green' };
  } else if (trendValue < 0) {
    return { direction: 'down', color: 'red' };
  }
  return { direction: 'neutral', color: 'gray' };
};