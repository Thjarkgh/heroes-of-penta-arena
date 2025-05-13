import { BrowserRouter, Routes, Route } from 'react-router-dom';
// import { AuthProvider } from './contexts/AuthContext';
// import ProtectedRoute from './components/ProtectedRoute';
// import Layout from './components/Layout';
// import LoginPage from './pages/LoginPage';
// import SkpProofComponent from './pages/SkpProofComponent';
import GameManager from './pages/GameUI/GameManager';
import './index.css'; // Import global styles

function App() {
  return (
    // <AuthProvider>
      <BrowserRouter>
        <Routes>

            <Route index element={<GameManager />} /> {/* Default page */}
            <Route path="*" element={<div>Not Found</div>} /> {/* Catch-all inside protected */}
        </Routes>
      </BrowserRouter>
    // </AuthProvider>
  );
}

export default App;

//<Route path="/login" element={<LoginPage />} />
//<Route
//  path="/*" // All other routes are protected
//  element={
//    <ProtectedRoute>
//      <Layout />{/* Layout wraps protected pages */}
//    </ProtectedRoute>
//  }
//>

//             {/* Nested routes relative to Layout */}
        //    <Route path="user-history" element={<UserHistoryPage />} />
          //  <Route path="user-history/:memberpressId" element={<UserHistoryPage />} />
            //<Route path="membership-history" element={<MembershipHistoryPage />} />
           // <Route path="membership-history/:memberpressMembershipId" element={<MembershipHistoryPage />} />
//</Route>