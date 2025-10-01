import React, { useState, useEffect } from 'react';
import { useAuth } from '../hooks/useAuth';
import { KPICard, LoadingSpinner } from '../components/common';
import { ParticipantCard, ActivityFeed } from '../components/sessions';
import { getActiveSessions, checkOutVehicle } from '../services/sessionService';
import { debounce } from '../utils/helpers';

const LiveSessions = () => {
  const { user } = useAuth();
  
  // State management
  const [sessionData, setSessionData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [filteredParticipants, setFilteredParticipants] = useState([]);

  // Fetch active sessions data
  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        setError(null);
        const data = await getActiveSessions(user);
        setSessionData(data);
        setFilteredParticipants(data.activeSessions);
      } catch (err) {
        setError(err.message);
        console.error('Error fetching active sessions:', err);
      } finally {
        setLoading(false);
      }
    };

    if (user) {
      fetchData();
    }
  }, [user]);

  // Filter participants based on search term
  useEffect(() => {
    if (!sessionData) return;

    const filtered = sessionData.activeSessions.filter(participant =>
      participant.participant_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      participant.vehicle_reg_no.toLowerCase().includes(searchTerm.toLowerCase())
    );
    setFilteredParticipants(filtered);
  }, [searchTerm, sessionData]);

  // Debounced search handler
  const debouncedSearch = debounce((value) => {
    setSearchTerm(value);
  }, 300);

  // Handle vehicle check out
  const handleCheckOut = async (ticketId, paymentMethod = 'digital') => {
    try {
      await checkOutVehicle(ticketId, paymentMethod);
      
      // Find the participant being checked out
      const participant = sessionData.activeSessions.find(p => p.ticket_id === ticketId);
      
      // Remove the participant from the list
      setSessionData(prev => ({
        ...prev,
        activeSessions: prev.activeSessions.filter(p => p.ticket_id !== ticketId),
        stats: {
          ...prev.stats,
          activeParticipants: prev.stats.activeParticipants - 1
        },
        // Add checkout activity to recent activity
        recentActivity: [
          {
            type: 'leave',
            message: `Participant left (Vehicle: ${participant?.vehicle_reg_no})`,
            time: 'Just now',
            timestamp: new Date().toISOString()
          },
          ...prev.recentActivity.slice(0, 9) // Keep only 10 most recent
        ]
      }));

      // Show success message (you could add a toast notification here)
      console.log('Vehicle checked out successfully');
    } catch (error) {
      console.error('Failed to check out vehicle:', error);
      alert(error.message || 'Failed to check out vehicle');
      throw error;
    }
  };

  // Handle activity updates from ActivityFeed
  const handleActivityUpdate = (newActivity) => {
    setSessionData(prev => ({
      ...prev,
      recentActivity: [newActivity, ...prev.recentActivity.slice(0, 9)]
    }));
  };

  // Calculate session duration timer
  const [currentTime, setCurrentTime] = useState(new Date());
  
  useEffect(() => {
    const timer = setInterval(() => {
      setCurrentTime(new Date());
    }, 1000);

    return () => clearInterval(timer);
  }, []);

  // Format session duration timer
  const formatSessionDuration = () => {
    const hours = String(currentTime.getHours()).padStart(2, '0');
    const minutes = String(currentTime.getMinutes()).padStart(2, '0');
    const seconds = String(currentTime.getSeconds()).padStart(2, '0');
    return `${hours}:${minutes}:${seconds}`;
  };

  // Loading state
  if (loading) {
    return (
      <div className="p-6">
        <div className="flex items-center justify-center h-64">
          <LoadingSpinner size="lg" />
        </div>
      </div>
    );
  }

  // Error state
  if (error) {
    return (
      <div className="p-6">
        <div className="bg-red-50 border border-red-200 rounded-lg p-6 text-center">
          <h2 className="text-lg font-semibold text-red-800 mb-2">Error Loading Live Sessions</h2>
          <p className="text-red-600">{error}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Live Sessions</h1>
          <p className="text-gray-600">Monitor active parking sessions in real-time</p>
        </div>
        <div className="flex items-center space-x-2">
          <div className="w-3 h-3 bg-green-500 rounded-full animate-pulse"></div>
          <span className="text-sm text-green-600 font-medium">Active Session</span>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6" data-testid="live-sessions-kpi-cards">
        <KPICard
          title="Active Participants"
          value={sessionData?.stats.activeParticipants}
          subtitle="+3 from last hour"
          trend={12}
          valueType="number"
        />
        <KPICard
          title="Total Revenue"
          value={sessionData?.stats.totalRevenue}
          subtitle="+12%"
          trend={12}
          valueType="currency"
        />
        <KPICard
          title="Avg. Session Time"
          value={sessionData?.stats.avgSessionTime}
          subtitle="-8%"
          trend={-8}
          valueType="text"
        />
        <KPICard
          title="Occupancy Rate"
          value={sessionData?.stats.occupancyRate}
          subtitle="+5%"
          trend={5}
          valueType="percentage"
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Current Participants */}
        <div className="lg:col-span-2">
          <div className="bg-white rounded-lg shadow-sm border border-gray-200">
            <div className="p-6 border-b border-gray-200">
              <h2 className="text-lg font-semibold text-gray-900 mb-4">Current Participants</h2>
              
              {/* Search Bar */}
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <svg className="h-5 w-5 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                  </svg>
                </div>
                <input
                  type="text"
                  placeholder="Search by vehicle ID or name..."
                  className="block text-gray-900 w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md leading-5 bg-white placeholder-gray-500 focus:outline-none focus:placeholder-gray-400 focus:ring-1 focus:ring-blue-500 focus:border-blue-500"
                  onChange={(e) => debouncedSearch(e.target.value)}
                />
              </div>
            </div>

            {/* Participants List */}
            <div className="p-6">
              <div className="space-y-3">
                {filteredParticipants.length > 0 ? (
                  filteredParticipants.map((participant) => (
                    <ParticipantCard
                      key={participant.ticket_id}
                      participant={participant}
                      onCheckOut={handleCheckOut}
                    />
                  ))
                ) : (
                  <div className="text-center py-8 text-gray-500">
                    {searchTerm ? 'No participants found matching your search.' : 'No active participants.'}
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>

        {/* Sidebar */}
        <div className="space-y-6">
          {/* Session Duration Timer */}
          <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6 text-center">
            <div className="text-3xl font-mono font-bold text-gray-900 mb-2">
              {formatSessionDuration()}
            </div>
            <p className="text-sm text-gray-600">Session Duration</p>
          </div>

          {/* Recent Activity Feed */}
          <ActivityFeed
            user={user}
            activities={sessionData?.recentActivity || []}
            onActivityUpdate={handleActivityUpdate}
          />
        </div>
      </div>
    </div>
  );
};

export default LiveSessions;