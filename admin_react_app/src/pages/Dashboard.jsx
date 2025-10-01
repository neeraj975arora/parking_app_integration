import React, { useState, useEffect, useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';
import { KPICard, Button, ErrorDisplay, KPICardSkeleton, ChartSkeleton } from '../components/common';
import { RevenueChart } from '../components/dashboard';
import { calculateDashboardKPIs } from '../utils/kpiCalculations';
import { getDashboardData } from '../services/dashboardService';
import { USER_ROLES } from '../utils/constants';

const Dashboard = () => {
  const { user } = useAuth();
  const navigate = useNavigate();
  
  // State management
  const [dashboardData, setDashboardData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Fetch dashboard data on component mount
  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        setError(null);
        const data = await getDashboardData(user);
        setDashboardData(data);
      } catch (err) {
        setError(err.message);
        console.error('Dashboard data fetch error:', err);
      } finally {
        setLoading(false);
      }
    };

    if (user) {
      fetchData();
    }
  }, [user]);

  // Memoize expensive KPI calculations
  const kpis = useMemo(() => {
    if (!dashboardData) return null;
    return calculateDashboardKPIs(dashboardData.sessions, [], dashboardData.totalParkingSlots);
  }, [dashboardData]);

  // Memoize quick actions based on user role
  const quickActions = useMemo(() => {
    const commonActions = [
      { label: 'Live Sessions', path: '/live-sessions', icon: '🚗', color: 'blue' },
      { label: 'Payment Collection', path: '/payment-collection', icon: '💰', color: 'green' },
      { label: 'Daily Closure', path: '/daily-closure', icon: '📊', color: 'purple' }
    ];

    if (user?.role === USER_ROLES.SUPER_ADMIN) {
      return [
        ...commonActions,
        { label: 'Admin Management', path: '/admin-management', icon: '👥', color: 'indigo' },
        { label: 'Settings', path: '/settings', icon: '⚙️', color: 'gray' }
      ];
    }

    return commonActions;
  }, [user?.role]);

  // Retry function for error recovery
  const handleRetry = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await getDashboardData(user);
      setDashboardData(data);
    } catch (err) {
      setError(err.message);
      console.error('Dashboard data fetch error:', err);
    } finally {
      setLoading(false);
    }
  };

  // Loading state with skeleton
  if (loading) {
    return (
      <div className="p-6 space-y-8 bg-gray-50 min-h-screen">
        {/* Header Skeleton */}
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-8">
          <div className="space-y-2">
            <div className="h-8 bg-gray-200 rounded w-48 animate-pulse"></div>
            <div className="h-4 bg-gray-200 rounded w-64 animate-pulse"></div>
          </div>
          <div className="h-4 bg-gray-200 rounded w-24 animate-pulse self-start sm:self-center"></div>
        </div>

        {/* Quick Actions Skeleton */}
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <div className="h-6  bg-gray-200 rounded w-32 mb-6 animate-pulse"></div>
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4">
            {[...Array(5)].map((_, i) => (
              <div key={i} className="h-24 bg-gray-100 rounded-xl animate-pulse"></div>
            ))}
          </div>
        </div>

        {/* KPI Cards Skeleton */}
        <div className="space-y-4">
          <div className="h-6 bg-gray-200 rounded w-48 mb-2 animate-pulse"></div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
            {[...Array(6)].map((_, i) => (
              <KPICardSkeleton key={i} />
            ))}
          </div>
        </div>

        {/* Chart Skeleton */}
        <ChartSkeleton />
      </div>
    );
  }

  // Error state
  if (error && !dashboardData) {
    return (
      <div className="p-6 bg-gray-50 min-h-screen flex items-center justify-center">
        <ErrorDisplay
          error={error}
          type="network"
          onRetry={handleRetry}
          showRetry={true}
        />
      </div>
    );
  }

  return (
    <div className="p-6 space-y-8 bg-gray-50 min-h-screen">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Dashboard Overview</h1>
          <p className="text-gray-600 mt-1">
            Welcome back, <span className="font-medium text-blue-600">{user?.username || user?.user_email}</span>
          </p>
        </div>
        <div className="bg-white px-3 py-1.5 rounded-lg border border-gray-200 shadow-xs inline-flex self-start sm:self-center">
          <span className="text-sm text-gray-500">Role: </span>
          <span className="text-sm font-medium text-blue-600 ml-1 capitalize">{user?.role?.toLowerCase().replace('_', ' ')}</span>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
        <h2 className="text-lg font-semibold text-gray-900 mb-6">Quick Actions</h2>
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4">
          {quickActions.map((action) => (
            <button
              key={action.path}
              onClick={() => navigate(action.path)}
              className={`flex flex-col items-center p-4 h-auto rounded-xl border border-gray-100 bg-white hover:shadow-md transition-all duration-200 hover:-translate-y-0.5 focus:outline-none focus:ring-2 focus:ring-${action.color}-500 focus:ring-opacity-50`}
            >
              <span className="text-2xl mb-2">{action.icon}</span>
              <span className="text-sm text-white font-medium text-center">{action.label}</span>
            </button>
          ))}
        </div>
      </div>

      {/* KPI Cards */}
      {kpis && (
        <div className="space-y-4">
          <h2 className="text-lg font-semibold text-gray-900">Performance Metrics</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
            <KPICard
              title="Total Income"
              value={kpis.totalIncome.value}
              subtitle={kpis.totalIncome.subtitle}
              trend={kpis.totalIncome.trend}
              valueType="currency"
              icon="💰"
              accentColor="green"
            />
            <KPICard
              title="Total Sessions"
              value={kpis.totalSessions.value}
              subtitle={kpis.totalSessions.subtitle}
              trend={kpis.totalSessions.trend}
              valueType="number"
              icon="🚗"
              accentColor="blue"
            />
            <KPICard
              title="Revenue per Slot"
              value={kpis.revenuePerSlot.value}
              subtitle={kpis.revenuePerSlot.subtitle}
              trend={kpis.revenuePerSlot.trend}
              valueType="currency"
              icon="📊"
              accentColor="purple"
            />
            <KPICard
              title="Active Participants"
              value={kpis.activeParticipants.value}
              subtitle={kpis.activeParticipants.subtitle}
              trend={kpis.activeParticipants.trend}
              valueType="number"
              icon="👥"
              accentColor="indigo"
            />
            <KPICard
              title="Average Session Time"
              value={kpis.averageSessionTime.value}
              subtitle={kpis.averageSessionTime.subtitle}
              trend={kpis.averageSessionTime.trend}
              valueType="duration"
              icon="⏱️"
              accentColor="amber"
            />
            <KPICard
              title="Occupancy Rate"
              value={kpis.occupancyRate.value}
              subtitle={kpis.occupancyRate.subtitle}
              trend={kpis.occupancyRate.trend}
              valueType="percentage"
              icon="🏢"
              accentColor="teal"
            />
          </div>
        </div>
      )}

      {/* Revenue Chart */}
      {dashboardData?.revenueData && (
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <RevenueChart 
            data={dashboardData.revenueData}
            title="Revenue Trends"
            height={350}
          />
        </div>
      )}

      {/* Summary Information */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <h2 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
            <span className="w-2 h-5 bg-blue-500 rounded-full mr-2"></span>
            Session Overview
          </h2>
          <div className="space-y-4">
            <div className="flex justify-between items-center p-3 bg-blue-50 rounded-lg">
              <span className="text-sm font-medium text-gray-700">Total Sessions</span>
              <span className="text-lg font-bold text-blue-600">{dashboardData?.sessions?.length || 0}</span>
            </div>
            <div className="flex justify-between items-center p-3 bg-green-50 rounded-lg">
              <span className="text-sm font-medium text-gray-700">Active Sessions</span>
              <span className="text-lg font-bold text-green-600">{dashboardData?.sessions?.filter(s => !s.end_time).length || 0}</span>
            </div>
            <div className="flex justify-between items-center p-3 bg-purple-50 rounded-lg">
              <span className="text-sm font-medium text-gray-700">Completed Sessions</span>
              <span className="text-lg font-bold text-purple-600">{dashboardData?.sessions?.filter(s => s.end_time).length || 0}</span>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
          <h2 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
            <span className="w-2 h-5 bg-green-500 rounded-full mr-2"></span>
            System Information
          </h2>
          <div className="space-y-4">
            <div className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
              <span className="text-sm font-medium text-gray-700">Total Parking Slots</span>
              <span className="text-lg font-bold text-gray-700">{dashboardData?.totalParkingSlots || 0}</span>
            </div>
            <div className="flex justify-between items-center p-3 bg-amber-50 rounded-lg">
              <span className="text-sm font-medium text-gray-700">Admin Lots</span>
              <span className="text-lg font-bold text-amber-600">{dashboardData?.adminLots?.length || 0}</span>
            </div>
            <div className="flex justify-between items-center p-3 bg-indigo-50 rounded-lg">
              <span className="text-sm font-medium text-gray-700">Data Source</span>
              <span className="text-sm font-bold text-green-600">
                Live API
              </span>
            </div> 
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;