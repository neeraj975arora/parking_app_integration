// Email validation
export const validateEmail = (email) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  
  if (!email) {
    return { isValid: false, message: 'Email is required' };
  }
  
  if (!emailRegex.test(email)) {
    return { isValid: false, message: 'Please enter a valid email address' };
  }
  
  return { isValid: true, message: '' };
};

// Password validation
export const validatePassword = (password) => {
  if (!password) {
    return { isValid: false, message: 'Password is required' };
  }
  
  if (password.length < 6) {
    return { isValid: false, message: 'Password must be at least 6 characters long' };
  }
  
  return { isValid: true, message: '' };
};

// Role validation
export const validateRole = (role) => {
  const validRoles = ['admin', 'super_admin'];
  
  if (!role) {
    return { isValid: false, message: 'Role is required' };
  }
  
  if (!validRoles.includes(role)) {
    return { isValid: false, message: 'Please select a valid role' };
  }
  
  return { isValid: true, message: '' };
};

// Name validation
export const validateName = (name) => {
  if (!name) {
    return { isValid: false, message: 'Name is required' };
  }
  
  if (name.length < 2) {
    return { isValid: false, message: 'Name must be at least 2 characters long' };
  }
  
  return { isValid: true, message: '' };
};

// Phone number validation
export const validatePhoneNumber = (phone) => {
  const phoneRegex = /^[\+]?[1-9][\d]{0,15}$/;
  
  if (!phone) {
    return { isValid: false, message: 'Phone number is required' };
  }
  
  // Remove spaces, dashes, and parentheses for validation
  const cleanPhone = phone.replace(/[\s\-\(\)]/g, '');
  
  if (cleanPhone.length < 10) {
    return { isValid: false, message: 'Phone number must be at least 10 digits' };
  }
  
  if (!phoneRegex.test(cleanPhone)) {
    return { isValid: false, message: 'Please enter a valid phone number' };
  }
  
  return { isValid: true, message: '' };
};

// Phone number validation
export const validatePhone = (phone) => {
  const phoneRegex = /^[6-9]\d{9}$/;
  
  if (!phone) {
    return { isValid: false, message: 'Phone number is required' };
  }
  
  if (!phoneRegex.test(phone)) {
    return { isValid: false, message: 'Please enter a valid 10-digit phone number' };
  }
  
  return { isValid: true, message: '' };
};

// Generic required field validation
export const validateRequired = (value, fieldName) => {
  if (!value || (typeof value === 'string' && value.trim() === '')) {
    return { isValid: false, message: `${fieldName} is required` };
  }
  
  return { isValid: true, message: '' };
};

// Validate login form (role is auto-determined, not validated)
export const validateLoginForm = (credentials) => {
  const errors = {};
  
  const emailValidation = validateEmail(credentials.user_email);
  if (!emailValidation.isValid) {
    errors.user_email = emailValidation.message;
  }
  
  const passwordValidation = validatePassword(credentials.user_password);
  if (!passwordValidation.isValid) {
    errors.user_password = passwordValidation.message;
  }
  
  // Remove role validation - role is auto-determined from email
  
  return {
    isValid: Object.keys(errors).length === 0,
    errors,
  };
};