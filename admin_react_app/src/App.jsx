import React, { Suspense } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
import { routes, redirects } from './routes';
import LoadingSpinner from './components/common/LoadingSpinner';
import ErrorBoundary from './components/common/ErrorBoundary';
import AdminLayout from './layouts/AdminLayout';
import ProtectedRoute from './guards/ProtectedRoute';
import RoleBasedRoute from './guards/RoleBasedRoute';
import './App.css';

function App() {
  return (
    <ErrorBoundary>
      <AuthProvider>
        <Router>
          <div className="App">
            <Suspense fallback={<LoadingSpinner fullScreen text="Loading application..." />}>
              <Routes>
                {/* Public Routes */}
                {routes
                  .filter(route => route.public)
                  .map(route => (
                    <Route
                      key={route.path}
                      path={route.path}
                      element={
                        <ErrorBoundary>
                          <route.component />
                        </ErrorBoundary>
                      }
                    />
                  ))
                }

                {/* Protected Routes with Admin Layout */}
                <Route 
                  path="/" 
                  element={
                    <ProtectedRoute>
                      <AdminLayout />
                    </ProtectedRoute>
                  }
                >
                  {/* Index route redirects to dashboard */}
                  <Route index element={<Navigate to={redirects.afterLogin} replace />} />

                  {routes
                    .filter(route => route.protected)
                    .map(route => (
                      <Route
                        key={route.path}
                        path={route.path}
                        element={
                          <ErrorBoundary>
                            {route.roleBasedRoute ? (
                              <RoleBasedRoute roles={route.roles}>
                                <route.component />
                              </RoleBasedRoute>
                            ) : (
                              <route.component />
                            )}
                          </ErrorBoundary>
                        }
                      />
                    ))
                  }
                </Route>

                {/* Catch all route - redirect to dashboard */}
                <Route path="*" element={<Navigate to={redirects.afterLogin} replace />} />
              </Routes>
            </Suspense>
          </div>
        </Router>
      </AuthProvider>
    </ErrorBoundary>
  );
}

export default App;
