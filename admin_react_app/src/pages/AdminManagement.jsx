import React, { useState, useEffect } from 'react';
import { useAuth } from '../hooks/useAuth';
import KPICard from '../components/common/KPICard';
import LoadingSpinner from '../components/common/LoadingSpinner';
import Button from '../components/common/Button';
import Input from '../components/forms/Input';
import Select from '../components/forms/Select';
import { ConfirmationModal } from '../components/common/Modal';
import adminService from '../services/adminService';
import { calculateAdminKPIs, formatAdminStatus, formatAssignedLots } from '../utils/helpers';
import { validateName, validateEmail, validatePassword, validatePhone, validateRequired } from '../utils/validators';

const AdminManagement = () => {
  const { user } = useAuth();
  
  // State for admin data and KPIs
  const [adminData, setAdminData] = useState([]);
  const [kpis, setKpis] = useState({
    totalAdmins: 0,
    superAdmins: 0,
    regularAdmins: 0,
    totalLots: 0,
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // State for create admin form
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    password: '',
    phone_no: '',
    address: '',
    assigned_lots: [],
  });
  const [formErrors, setFormErrors] = useState({});
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitError, setSubmitError] = useState('');
  const [submitSuccess, setSubmitSuccess] = useState('');

  // State for edit admin
  const [editModal, setEditModal] = useState({ isOpen: false, admin: null, editedLots: [] });

  // State for admin table
  const [searchTerm, setSearchTerm] = useState('');
  const [deleteModal, setDeleteModal] = useState({ isOpen: false, admin: null });

  // Generate parking lots data (1-10 as available in database)
  const parkingLots = Array.from({ length: 10 }, (_, index) => ({
    value: index + 1,
    label: `Parking Lot P${index + 1}`
  }));

  // State for available lots
  const [availableLots, setAvailableLots] = useState(parkingLots);
  const [assignedLotsInfo, setAssignedLotsInfo] = useState({});

  // Fetch admin data on component mount
  useEffect(() => {
    fetchAdminData();
  }, []);

  // Update available lots when admin data changes
  useEffect(() => {
    if (adminData.length > 0) {
      const assignedInfo = {};
      const assignedLotIds = new Set();
      
      // Collect all assigned lots and their assignees
      adminData.forEach(admin => {
        if (admin.assigned_lots && Array.isArray(admin.assigned_lots)) {
          admin.assigned_lots.forEach(lot => {
            // Handle both old format (lotId) and new format (lot object with parkinglot_id)
            const lotId = typeof lot === 'object' ? lot.parkinglot_id : lot;
            assignedLotIds.add(lotId);
            if (!assignedInfo[lotId]) {
              assignedInfo[lotId] = [];
            }
            assignedInfo[lotId].push(admin.name || admin.username);
          });
        }
      });
      
      setAssignedLotsInfo(assignedInfo);
      
      // Filter available lots (only show unassigned lots)
      const available = parkingLots.filter(lot => !assignedLotIds.has(lot.value));
      setAvailableLots(available);
    } else {
      // If no admin data, all lots are available
      setAvailableLots(parkingLots);
      setAssignedLotsInfo({});
    }
  }, [adminData]);

  const fetchAdminData = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await adminService.getAllAdmins();
      setAdminData(data);
      
      // Calculate KPIs
      const calculatedKpis = calculateAdminKPIs(data, parkingLots.length);
      setKpis(calculatedKpis);
    } catch (err) {
      setError(err.message);
      console.error('Failed to fetch admin data:', err);
    } finally {
      setLoading(false);
    }
  };

  // Handle form input changes
  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value,
    }));
    
    // Clear field error when user starts typing
    if (formErrors[name]) {
      setFormErrors(prev => ({
        ...prev,
        [name]: '',
      }));
    }
    
    // Clear submit messages
    if (submitError) setSubmitError('');
    if (submitSuccess) setSubmitSuccess('');
  };

  // Handle assigned lots selection
  const handleLotsChange = (e) => {
    const { value } = e.target;
    const lotId = parseInt(value);
    
    setFormData(prev => ({
      ...prev,
      assigned_lots: prev.assigned_lots.includes(lotId)
        ? prev.assigned_lots.filter(id => id !== lotId)
        : [...prev.assigned_lots, lotId],
    }));
  };

  // Handle edit lots selection
  const handleEditLotsChange = (e) => {
    const { value } = e.target;
    const lotId = parseInt(value);
    
    setEditModal(prev => ({
      ...prev,
      editedLots: prev.editedLots.includes(lotId)
        ? prev.editedLots.filter(id => id !== lotId)
        : [...prev.editedLots, lotId],
    }));
  };

  // Validate create admin form
  const validateForm = () => {
    const errors = {};
    
    const nameValidation = validateName(formData.name);
    if (!nameValidation.isValid) {
      errors.name = nameValidation.message;
    }
    
    const emailValidation = validateEmail(formData.email);
    if (!emailValidation.isValid) {
      errors.email = emailValidation.message;
    }
    
    const passwordValidation = validatePassword(formData.password);
    if (!passwordValidation.isValid) {
      errors.password = passwordValidation.message;
    }
    
    const phoneValidation = validatePhone(formData.phone_no);
    if (!phoneValidation.isValid) {
      errors.phone_no = phoneValidation.message;
    }
    
    const addressValidation = validateRequired(formData.address, 'Address');
    if (!addressValidation.isValid) {
      errors.address = addressValidation.message;
    }
    
    const lotsValidation = validateRequired(formData.assigned_lots.length > 0, 'Assigned lots');
    if (!lotsValidation.isValid) {
      errors.assigned_lots = 'Please select at least one parking lot';
    }
    
    return {
      isValid: Object.keys(errors).length === 0,
      errors,
    };
  };

  // Handle form submission
  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // Validate form
    const validation = validateForm();
    if (!validation.isValid) {
      setFormErrors(validation.errors);
      return;
    }
    
    setIsSubmitting(true);
    setSubmitError('');
    setSubmitSuccess('');
    
    try {
      await adminService.createAdmin(formData);
      
      // Reset form
      setFormData({
        name: '',
        email: '',
        password: '',
        phone_no: '',
        address: '',
        assigned_lots: [],
      });
      setFormErrors({});
      setSubmitSuccess('Admin created successfully!');
      
      // Refresh admin data
      await fetchAdminData();
    } catch (error) {
      setSubmitError(error.message);
    } finally {
      setIsSubmitting(false);
    }
  };

  // Handle admin edit
  const handleEditAdmin = async () => {
    if (!editModal.admin) return;
    
    try {
      // Implement your edit API call here
      // await adminService.updateAdmin(editModal.admin.admin_id, {
      //   assigned_lots: editModal.editedLots
      // });
      
      setEditModal({ isOpen: false, admin: null, editedLots: [] });
      
      // Refresh admin data
      await fetchAdminData();
    } catch (error) {
      console.error('Failed to update admin:', error);
    }
  };

  // Handle admin deletion
  const handleDeleteAdmin = async () => {
    if (!deleteModal.admin) return;
    
    try {
      // Extract admin ID - try multiple possible field names
      const adminId = deleteModal.admin.admin_id || deleteModal.admin.user_id || deleteModal.admin.id;
      
      if (!adminId) {
        console.error('Admin ID not found. Available fields:', Object.keys(deleteModal.admin));
        throw new Error('Admin ID not found in admin data');
      }
      
      // Extract parking lot IDs from assigned lots
      const parkingLotIds = deleteModal.admin.assigned_lots ? 
        deleteModal.admin.assigned_lots.map(lot => {
          // Handle both object format {parkinglot_id: X} and direct ID format
          if (typeof lot === 'object' && lot.parkinglot_id) {
            return lot.parkinglot_id;
          } else if (typeof lot === 'number') {
            return lot;
          } else if (typeof lot === 'string') {
            return parseInt(lot, 10);
          }
          return lot;
        }).filter(id => id != null && !isNaN(id)) : [];
      
      console.log('Delete admin data:', {
        adminId: adminId,
        parkingLotIds: parkingLotIds,
        adminData: deleteModal.admin,
        assignedLots: deleteModal.admin.assigned_lots
      });
      
      if (parkingLotIds.length === 0) {
        throw new Error('No valid parking lot IDs found for this admin');
      }
      
      await adminService.deleteAdmin(adminId, parkingLotIds);
      setDeleteModal({ isOpen: false, admin: null });
      
      // Show success message
      setSubmitSuccess(`Admin "${deleteModal.admin?.name || deleteModal.admin?.username || 'Unknown'}" has been successfully deleted.`);
      setSubmitError(''); // Clear any previous errors
      
      // Clear success message after 5 seconds
      setTimeout(() => {
        setSubmitSuccess('');
      }, 5000);
      
      // Refresh admin data
      await fetchAdminData();
    } catch (error) {
      console.error('Failed to delete admin:', error);
      // Show error to user
      setSubmitError(error.message);
    }
  };

  // Open edit modal
  const openEditModal = (admin) => {
    // Extract lot IDs from assigned_lots (handle both old and new format)
    const lotIds = admin.assigned_lots ? admin.assigned_lots.map(lot => 
      typeof lot === 'object' ? lot.parkinglot_id : lot
    ) : [];
    
    setEditModal({
      isOpen: true,
      admin,
      editedLots: lotIds
    });
  };

  // Filter admins based on search term
  const filteredAdmins = adminData.filter(admin =>
    admin.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    admin.email?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    admin.role?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-blue-600 mb-2">Admin Management</h1>
        <p className="text-gray-600">
          This page is for Super Admins only and allows management of other admin accounts.
        </p>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6" data-testid="admin-kpi-cards">
        <KPICard
          title="Total Admins"
          value={kpis.totalAdmins}
          loading={loading}
          error={error ? 'Failed to load' : null}
        />
        <KPICard
          title="Super Admins"
          value={kpis.superAdmins}
          loading={loading}
          error={error ? 'Failed to load' : null}
        />
        <KPICard
          title="Regular Admins"
          value={kpis.regularAdmins}
          loading={loading}
          error={error ? 'Failed to load' : null}
        />
        <KPICard
          title="Total Lots"
          value={kpis.totalLots}
          loading={loading}
          error={error ? 'Failed to load' : null}
        />
      </div>

      {/* Two-Panel Layout */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-1">
        {/* Left Panel - Create New Admin */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <div className="flex items-center mb-6">
            <svg className="w-5 h-5 text-blue-600 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z" />
            </svg>
            <h2 className="text-lg font-semibold text-gray-900">Create New Admin</h2>
          </div>

          <form onSubmit={handleSubmit} className="space-y-4">
            <Input
              name="name"
              type="text"
              label="Name"
              value={formData.name}
              onChange={handleInputChange}
              placeholder="Enter admin name"
              required
              error={formErrors.name}
              className="text-gray-900"
            />

            <Input
              name="email"
              type="email"
              label="Email"
              value={formData.email}
              onChange={handleInputChange}
              placeholder="Enter email address"
              required
              error={formErrors.email}
              className="text-gray-900"
            />

            <Input
              name="password"
              type="password"
              label="Password"
              value={formData.password}
              onChange={handleInputChange}
              placeholder="Enter password"
              required
              error={formErrors.password}
              className="text-gray-900"
            />

            <Input
              name="phone_no"
              type="tel"
              label="Phone Number"
              value={formData.phone_no}
              onChange={handleInputChange}
              placeholder="Enter phone number"
              required
              error={formErrors.phone_no}
              className="text-gray-900"
            />

            <Input
              name="address"
              type="text"
              label="Address"
              value={formData.address}
              onChange={handleInputChange}
              placeholder="Enter address"
              required
              error={formErrors.address}
              className="text-gray-900"
            />

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Role
              </label>
              <div className="px-3 py-2 bg-gray-50 border border-gray-300 rounded-md">
                <span className="text-sm text-gray-600">Admin (Fixed)</span>
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Assigned Lots <span className="text-red-500">*</span>
              </label>
              
              {availableLots.length === 0 ? (
                <div className="bg-yellow-50 border border-yellow-200 rounded-md p-3">
                  <p className="text-sm text-yellow-700">
                    All parking lots are currently assigned. Please delete or reassign existing admin assignments to free up lots.
                  </p>
                </div>
              ) : (
                <>
                  <div className="space-y-2 max-h-32 overflow-y-auto border border-gray-300 rounded-md p-2">
                    {availableLots.map((lot) => (
                      <label key={lot.value} className="flex items-center">
                        <input
                          type="checkbox"
                          value={lot.value}
                          checked={formData.assigned_lots.includes(lot.value)}
                          onChange={handleLotsChange}
                          className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                        />
                        <span className="ml-2 text-sm text-gray-700">{lot.label}</span>
                      </label>
                    ))}
                  </div>
                  
                  {/* Show assigned lots information */}
                  {Object.keys(assignedLotsInfo).length > 0 && (
                    <div className="mt-2 p-2 bg-gray-50 rounded-md">
                      <p className="text-xs text-gray-600 mb-1 font-medium">Currently assigned lots:</p>
                      <div className="max-h-24 overflow-y-auto">
                        {Object.entries(assignedLotsInfo).map(([lotId, admins]) => {
                          const lot = parkingLots.find(l => l.value === parseInt(lotId));
                          return (
                            <p key={lotId} className="text-xs text-gray-500">
                              {lot?.label || `Lot ${lotId}`}: {admins.join(', ')}
                            </p>
                          );
                        })}
                      </div>
                    </div>
                  )}
                </>
              )}
              
              {formErrors.assigned_lots && (
                <p className="mt-1 text-sm text-red-600">{formErrors.assigned_lots}</p>
              )}
            </div>

            {submitError && (
              <div className="bg-red-50 border border-red-200 rounded-md p-3">
                <p className="text-sm text-red-600">{submitError}</p>
              </div>
            )}

            {submitSuccess && (
              <div className="bg-green-50 border border-green-200 rounded-md p-3">
                <p className="text-sm text-green-600">{submitSuccess}</p>
              </div>
            )}

            <Button
              type="submit"
              variant="primary"
              className="w-full"
              loading={isSubmitting}
              disabled={isSubmitting || availableLots.length === 0}
            >
              <svg className="w-4 h-4 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
              </svg>
              {isSubmitting ? 'Creating Admin...' : 'Create Admin'}
            </Button>
          </form>
        </div>

        {/* Right Panel - Existing Admins */}
        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-0">
          <div className="flex items-center justify-between mb-6">
            <div className="flex items-center">
              <svg className="w-5 h-5 text-blue-600 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
              </svg>
              <h2 className="text-lg font-semibold text-gray-900">Existing Admins</h2>
            </div>
          </div>

          {/* Search Bar */}
          <div className="mb-4">
            <Input
              type="text"
              placeholder="Search admins..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full text-gray-900"
            />
          </div>

          {/* Admin Table */}
          {loading ? (
            <div className="flex items-center justify-center h-64">
              <LoadingSpinner size="lg" />
            </div>
          ) : error ? (
            <div className="text-center py-8">
              <div className="text-red-600 mb-2">
                <svg className="w-12 h-12 mx-auto" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <p className="text-red-600 mb-4">{error}</p>
              <Button onClick={fetchAdminData} variant="outline">
                Retry
              </Button>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Name
                    </th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Role
                    </th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Assigned Lots
                    </th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Status
                    </th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Actions
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {filteredAdmins.length === 0 ? (
                    <tr>
                      <td colSpan="5" className="px-4 py-8 text-center text-gray-500">
                        {searchTerm ? 'No admins found matching your search.' : 'No admins found.'}
                      </td>
                    </tr>
                  ) : (
                    filteredAdmins.map((admin) => (
                      <tr key={admin.user_id} className="hover:bg-gray-50">
                        <td className="px-4 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                          {admin.name || admin.username}
                        </td>
                        <td className="px-4 py-4 whitespace-nowrap">
                          <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                            admin.role === 'super_admin' 
                              ? 'bg-purple-100 text-purple-800' 
                              : 'bg-blue-100 text-blue-800'
                          }`}>
                            {admin.role === 'super_admin' ? 'SUPER ADMIN' : 'ADMIN'}
                          </span>
                        </td>
                        <td className="px-4 py-4 whitespace-nowrap text-sm text-gray-500">
                          {formatAssignedLots(admin.assigned_lots)}
                        </td>
                        <td className="px-4 py-4 whitespace-nowrap">
                          <span className="inline-flex px-2 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800">
                            {formatAdminStatus(admin)}
                          </span>
                        </td>
                        <td className="px-4 py-4 whitespace-nowrap text-sm font-medium space-x-2">
                          <button 
                            onClick={() => openEditModal(admin)}
                            className="text-blue-600 hover:text-blue-900"
                          >
                            <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                            </svg>
                          </button>
                          <button 
                            onClick={() => setDeleteModal({ isOpen: true, admin })}
                            className="text-red-600 hover:text-red-900"
                          >
                            <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                            </svg>
                          </button>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>

      {/* Delete Confirmation Modal */}
      <ConfirmationModal
        isOpen={deleteModal.isOpen}
        onClose={() => setDeleteModal({ isOpen: false, admin: null })}
        onConfirm={handleDeleteAdmin}
        title="Delete Admin"
        message={`Are you sure you want to delete admin "${deleteModal.admin?.name || deleteModal.admin?.username || deleteModal.admin?.email || 'Unknown'}"? This action cannot be undone.`}
        confirmText="Delete"
        cancelText="Cancel"
        confirmVariant="danger"
      />

      {/* Edit Admin Modal */}
      <ConfirmationModal
        isOpen={editModal.isOpen}
        onClose={() => setEditModal({ isOpen: false, admin: null, editedLots: [] })}
        onConfirm={handleEditAdmin}
        title="Edit Admin Lots"
        message={
          <div className="space-y-4">
            <p>Edit assigned lots for {editModal.admin?.name || editModal.admin?.username}:</p>
            <div className="space-y-2 max-h-32 overflow-y-auto border border-gray-300 rounded-md p-2">
              {parkingLots.map((lot) => (
                <label key={lot.value} className="flex items-center">
                  <input
                    type="checkbox"
                    value={lot.value}
                    checked={editModal.editedLots.includes(lot.value)}
                    onChange={handleEditLotsChange}
                    className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                  />
                  <span className="ml-2 text-sm text-gray-700">{lot.label}</span>
                </label>
              ))}
            </div>
          </div>
        }
        confirmText="Save Changes"
        cancelText="Cancel"
        confirmVariant="primary"
      />
    </div>
  );
};

export default AdminManagement;