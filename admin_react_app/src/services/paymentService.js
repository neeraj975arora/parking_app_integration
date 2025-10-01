import api from './api';
import { API_ENDPOINTS } from '../utils/constants';

class PaymentService {
  // Get payment data based on user role
  async getPaymentData(user) {
    try {
      let response;
      
      if (user.role === 'super_admin') {
        // Super Admin: Get all session details from all parking lots
        response = await api.get(API_ENDPOINTS.ADMIN.ALL_SESSION_DETAILS);
      } else {
        // Regular Admin: Get session details for specific user
        response = await api.get(`${API_ENDPOINTS.ADMIN.SESSION_DETAILS}/${user.user_id}`);
      }
      const data = Array.isArray(response?.data) ? response.data : [];
      return data;
    } catch (error) {
      this.handlePaymentError(error);
    }
  }

  // Transform session data to payment records
  transformSessionsToPayments(sessions) {
    if (!Array.isArray(sessions)) return [];

    return sessions.map(session => this.transformSessionToPayment(session));
  }

  // Transform individual session to payment record
  transformSessionToPayment(session) {
    // Calculate payment amount based on duration and vehicle type (or use total_amount if provided)
    const baseRate = this.getVehicleRate(session.vehicle_type);
    const duration = session.duration_hrs || 0;
    const estimated = duration * baseRate;
    const amount = typeof session.amount_paid === 'number' && session.amount_paid > 0
      ? session.amount_paid
      : Math.round(estimated * 100) / 100;

    // Determine payment status
    const status = this.determinePaymentStatus(session);

    return {
      payment_id: `P${session.ticket_id || Math.random().toString(36).substr(2, 9)}`,
      vehicle_reg_no: session.vehicle_reg_no,
      amount: amount,
      date: session.payment_timestamp || session.end_time || session.start_time,
      duration: this.formatDuration(session.duration_hrs),
      status: status,
      session_id: session.ticket_id,
      lot_id: session.parkinglot_id,
      vehicle_type: session.vehicle_type,
      start_time: session.start_time,
      end_time: session.end_time
    };
  }

  // Get vehicle rate based on type
  getVehicleRate(vehicleType) {
    const rates = {
      'Car': 50,
      'car': 50,
      'Motorcycle': 30,
      'motorcycle': 30,
      'Bike': 30,
      'bike': 30,
      'Truck': 75,
      'truck': 75
    };
    
    return rates[vehicleType] || 50; // Default to car rate
  }

  // Determine payment status from session data
  determinePaymentStatus(session) {
    // Check for failed payment indicators first
    if (session.payment_failed || session.payment_error || session.status === 'failed') {
      return 'FAILED';
    }
    
    // Check if session is completed (has end_time)
    if (session.end_time !== null && session.end_time !== undefined) {
      return 'COMPLETED';
    }
    
    // Active sessions are pending payment
    return 'PENDING';
  }

  // Format duration for display
  formatDuration(hours) {
    if (!hours || hours === 0) return '0h 0m';
    
    const wholeHours = Math.floor(hours);
    const minutes = Math.round((hours - wholeHours) * 60);
    
    return `${wholeHours}h ${minutes}m`;
  }

  // Calculate payment KPIs
  calculatePaymentKPIs(paymentRecords) {
    if (!Array.isArray(paymentRecords)) {
      return {
        totalPayments: 0,
        completedPayments: 0,
        pendingPayments: 0,
        failedPayments: 0
      };
    }

    return {
      totalPayments: paymentRecords.length,
      completedPayments: paymentRecords.filter(p => p.status === 'COMPLETED').length,
      pendingPayments: paymentRecords.filter(p => p.status === 'PENDING').length,
      failedPayments: paymentRecords.filter(p => p.status === 'FAILED').length
    };
  }

  // Handle payment service errors
  handlePaymentError(error) {
    if (error.response) {
      const { status, data } = error.response;
      
      switch (status) {
        case 403:
          throw new Error('You are not authorized to view payment data');
        case 404:
          throw new Error('Payment data not found');
        default:
          throw new Error(data?.message || 'Failed to fetch payment data');
      }
    } else if (error.request) {
      throw new Error('Network error. Please check your connection');
    } else {
      throw new Error(error.message || 'An unexpected error occurred');
    }
  }

  // Export payment data to CSV
  exportToCSV(paymentRecords, filename = 'payment_records.csv') {
    if (!Array.isArray(paymentRecords) || paymentRecords.length === 0) {
      throw new Error('No payment data to export');
    }

    const headers = ['Payment ID', 'Vehicle', 'Amount', 'Date', 'Duration', 'Status'];
    const csvContent = [
      headers.join(','),
      ...paymentRecords.map(payment => [
        payment.payment_id,
        payment.vehicle_reg_no,
        `₹${payment.amount.toFixed(2)}`,
        new Date(payment.date).toLocaleDateString('en-IN'),
        payment.duration,
        payment.status
      ].join(','))
    ].join('\n');

    // Create and download CSV file
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    const url = URL.createObjectURL(blob);
    link.setAttribute('href', url);
    link.setAttribute('download', filename);
    link.style.visibility = 'hidden';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  }
}

// Create and export a singleton instance
const paymentService = new PaymentService();
export default paymentService;