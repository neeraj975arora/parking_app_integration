import api from './api';
import { API_ENDPOINTS } from '../utils/constants';

class ClosureService {
  // Get closure data for daily closure page using total_due endpoint
  async getClosureData(date) {
    try {
      const response = await api.get(API_ENDPOINTS.ADMIN.TOTAL_DUE);
      console.log('Total Due API Response:', response.data); // Debug log
      
      // The API returns: { date, outstanding_amount, today_collection }
      return response.data;
    } catch (error) {
      console.error('API call failed:', error.message);
      throw error;
    }
  }

  // Finalize daily closure with payment amount using /admin/closure endpoint
  async finalizeClosureData(paymentAmount, date) {
    try {
      const targetDate = date || new Date().toISOString().split('T')[0];
      const response = await api.post(API_ENDPOINTS.ADMIN.CLOSURE, {
        date: targetDate,
        payment_made: paymentAmount
      });
      console.log('Finalize Closure API Response:', response.data); // Debug log
      
      // The API returns: { opening_balance, today_collection, payment_made, closing_balance }
      return response.data;
    } catch (error) {
      console.error('API call failed:', error.message);
      throw error;
    }
  }

  // Calculate closure metrics from API data
  calculateClosureMetrics(closureData) {
    if (!closureData) {
      return {
        outstandingAmount: closureData.opening_balance || 0,
        todayCollection: closureData.today_collection || 0,
        totalDue: closureData.total_due || 0,
        amountPaid: closureData.amount_paid || 0,
        newOutstanding: closureData.new_outstanding || 0,
        date: new Date().toISOString().split('T')[0],
        status: 'pending'
      };
    }

    console.log('Raw closure data for metrics:', closureData); // Debug log

    // Handle both field naming conventions
    const outstandingAmount = closureData.opening_balance || closureData.outstanding_amount || 0;
    const todayCollection = closureData.today_collection || closureData.today_collection || 0;
    const totalDue = closureData.total_due || (outstandingAmount + todayCollection);
    const amountPaid = closureData.amount_paid || closureData.payment_made || 0;
    const newOutstanding = closureData.new_outstanding || Math.max(0, totalDue - amountPaid);

    return {
      outstandingAmount,
      todayCollection,
      totalDue,
      amountPaid,
      newOutstanding,
      date: closureData.date || new Date().toISOString().split('T')[0],
      status: closureData.status || (amountPaid > 0 ? 'completed' : 'pending')
    };
  }

  // Validate payment amount input (compatible with helper function)
  validatePaymentAmount(amount) {
    const numAmount = parseFloat(amount);
    
    if (isNaN(numAmount)) {
      return { isValid: false, error: 'Please enter a valid payment amount' };
    }
    
    if (numAmount < 0) {
      return { isValid: false, error: 'Payment amount cannot be negative' };
    }
    
    if (numAmount > 1000000) {
      return { isValid: false, error: 'Payment amount seems too large. Please verify.' };
    }
    
    return { isValid: true, value: numAmount };
  }

  // Handle closure service errors
  handleClosureError(error) {
    if (error.response) {
      const { status, data } = error.response;
      
      switch (status) {
        case 403:
          throw new Error('You are not authorized to access closure data');
        case 404:
          throw new Error('Closure data not found');
        case 400:
          throw new Error(data?.message || 'Invalid closure request');
        default:
          throw new Error(data?.message || 'Failed to process closure operation');
      }
    } else if (error.request) {
      throw new Error('Network error. Please check your connection');
    } else {
      throw new Error(error.message || 'An unexpected error occurred');
    }
  }

  // MOCK CODE REMOVED - Use real backend API only
  // getMockClosureData() { ... }
  // simulateClosureFinalization(paymentAmount) { ... }

  // Get closure history for reporting
  async getClosureHistory(startDate, endDate) {
    try {
      const response = await api.get(API_ENDPOINTS.ADMIN.CLOSURE, {
        params: { start_date: startDate, end_date: endDate }
      });
      return response.data;
    } catch (error) {
      console.error('API call failed:', error.message);
      throw error;
    }
  }

  // MOCK CODE REMOVED - Use real backend API only
  // getMockClosureHistory(startDate, endDate) { ... }
}

// Create and export a singleton instance
const closureService = new ClosureService();
export default closureService;