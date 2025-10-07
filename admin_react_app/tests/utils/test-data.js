import users from '../fixtures/users.json' assert { type: 'json' };

export const apiEndpoints = {
  login: '/auth/login',
  dashboard: '/admin/sessions/details/all',
  adminManagement: '/admin/admin_lots/all',
  liveSessions: '/admin/sessions/details/all',
  paymentCollection: '/admin/total_due',
  dailyClosure: '/admin/closure',
  assignLot: '/admin/assign_lot',
  removeAssignment: '/admin/remove_assignment',
  checkin: '/admin/session/checkin',
  checkout: '/admin/session/checkout',
  finalizeClosure: '/admin/finalize_closure',
};

export const testUrls = {
  login: '/login',
  dashboard: '/dashboard',
  adminManagement: '/admin-management',
  liveSessions: '/live-sessions',
  paymentCollection: '/payment-collection',
  dailyClosure: '/daily-closure',
  settings: '/settings',
};

export const testCredentials = {
  superAdmin: {
    email: 'superadmin@parking.com',
    password: 'password123',
    role: 'super_admin'
  },
  admin: {
    email: 'admin10@parking.com',
    password: 'password123',
    role: 'admin'
  },
  invalid: {
    email: 'invalid@email.com',
    password: 'wrongpassword'
  }
};

export { users };
