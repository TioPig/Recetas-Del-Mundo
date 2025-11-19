import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Box from '@mui/material/Box';
import './styles/style.css';
import Header from './components/Header';
import Home from './components/Home';
import Login from './components/Login';
import Register from './components/Register';
import Paises from './components/Paises';
import Categorias from './components/Categorias';
import RecetasByCategoria from './components/RecetasByCategoria';
import RecetasByPais from './components/RecetasByPais';
import SearchResults from './components/SearchResults';
import UserFavoritos from './components/UserFavoritos';
import UserRecetas from './components/UserRecetas';
import NuevaReceta from './components/NuevaReceta';
import Ajustes from './components/Ajustes';
import DebugLikes from './components/DebugLikes';
import AdminPanel from './components/AdminPanel';
import DonacionSuccess from './components/DonacionSuccess';
import DonacionCanceled from './components/DonacionCanceled';
import Footer from './components/Footer';

function App() {
  return (
    <BrowserRouter>
      <Box sx={{ minHeight: '100vh', display: 'flex', flexDirection: 'column' }}>
        <Header />
        <Box component="main" sx={{ flex: 1 }}>
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/login" element={<Login />} />
            <Route path="/register" element={<Register />} />
            <Route path="/registro" element={<Register />} />
            <Route path="/paises" element={<Paises />} />
            <Route path="/paises/:id" element={<RecetasByPais />} />
            <Route path="/categorias" element={<Categorias />} />
            <Route path="/categorias/:id" element={<RecetasByCategoria />} />
            <Route path="/buscar" element={<SearchResults />} />
            <Route path="/mi/favoritos" element={<UserFavoritos />} />
            <Route path="/mi/recetas" element={<UserRecetas />} />
            <Route path="/mis-recetas" element={<UserRecetas />} />
            <Route path="/nueva-receta" element={<NuevaReceta />} />
            <Route path="/ajustes" element={<Ajustes />} />
            <Route path="/admin" element={<AdminPanel />} />
            <Route path="/donacion/success" element={<DonacionSuccess />} />
            <Route path="/donacion/cancel" element={<DonacionCanceled />} />
            <Route path="/donacion/canceled" element={<DonacionCanceled />} /> {/* Ruta legacy por si acaso */}
            <Route path="/debug/likes" element={<DebugLikes />} />
          </Routes>
        </Box>
        <Footer />
      </Box>
    </BrowserRouter>
  );
}

export default App;
