import { BrowserRouter as Router, Routes, Route } from "react-router-dom";

import EventsList from "./pages/EventsList";
import EventDetail from "./pages/EventDetail";
import CreateEventForm from "./pages/CreateEventForm";
import SignIn from "./pages/SignIn";
import PrivateRoute from "./component/PrivateRoute.jsx";
import Navbar from "./component/Navbar.jsx";


function App() {
  return (
    <Router>
      <Navbar />
      <Routes>
        <Route path="/login" element={<SignIn />} />

        <Route
          path="/"
          element={
            <PrivateRoute>
              <EventsList />
            </PrivateRoute>
          }
        />
        <Route
          path="/events/new"
          element={
            <PrivateRoute>
              <CreateEventForm />
            </PrivateRoute>
          }
        />
        <Route
          path="/events/:id"
          element={
            <PrivateRoute>
              <EventDetail />
            </PrivateRoute>
          }
        />
      </Routes>
    </Router>
  );
}

export default App;
