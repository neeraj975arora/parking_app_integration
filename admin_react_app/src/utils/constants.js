// API Configuration
export const API_BASE_URL = 'http://localhost:80'


// User Roles
export const USER_ROLES = {
  ADMIN: "admin",
  SUPER_ADMIN: "super_admin",
};

// Local Storage Keys
export const STORAGE_KEYS = {
  AUTH_TOKEN: "auth_token",
  AUTH_USER: "auth_user",
};

// Navigation Sections
export const NAV_SECTIONS = {
  MAIN: "MAIN",
  ADMINISTRATION: "ADMINISTRATION",
  OPERATIONS: "OPERATIONS",
  ACCOUNT: "ACCOUNT",
};

// API Endpoints
export const API_ENDPOINTS = {
  AUTH: {
    LOGIN: "/auth/login",
  },
  ADMIN: {
    ALL_SESSION_DETAILS: "/admin/sessions/details/all", // super_admin -> GET
    SESSION_DETAILS: "/admin/sessions/details",        // admin -> GET /admin/sessions/details/:user_id
    CREATE: "/admin/assign_lot",                       // super_admin -> POST (create admin)
    ASSIGN_LOT: "/admin/assign_lot",
    REMOVE_ASSIGNMENT: "/admin/remove_assignment",
    ALL_ADMIN_LOTS: "/admin/admin_lots/all",
    CLOSURE: "/admin/closure",                         // GET for data, POST for create/update/finalize
    TOTAL_DUE: "/admin/total_due",
    SESSION_CHECKIN: "/admin/session/checkin",
    SESSION_CHECKOUT: "/admin/session/checkout",
  },
};

// Demo Credentials (matching backend seed data)
export const DEMO_CREDENTIALS = {
  SUPER_ADMIN: {
    user_email: "superadmin@parking.com",
    user_password: "password123",
    role: USER_ROLES.SUPER_ADMIN,
    label: "Super Admin",
  },
  ADMIN: {
    user_email: "admin10@parking.com",
    user_password: "password123",
    role: USER_ROLES.ADMIN,
    label: "Admin",
  },
};
