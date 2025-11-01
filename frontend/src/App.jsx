import { BrowserRouter as Router, Routes, Route } from "react-router-dom";

import EventsList from "./pages/EventsList";
import EventDetail from "./pages/EventDetail";
import CreateEventForm from "./pages/CreateEventForm";
import Navbar from "./component/Navbar.jsx";

function App() {
  return (
    <Router>
      <Navbar />
      <Routes>
        <Route path="/" element={<EventsList />} />
        <Route path="/events/new" element={<CreateEventForm />} />
        <Route path="/events/:id" element={<EventDetail />} />
      </Routes>
    </Router>
  );
}

export default App;
