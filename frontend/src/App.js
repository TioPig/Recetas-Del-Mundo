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
            <Route path="/paises" element={<Paises />} />
            <Route path="/paises/:id" element={<RecetasByPais />} />
            <Route path="/categorias" element={<Categorias />} />
            <Route path="/categorias/:id" element={<RecetasByCategoria />} />
            <Route path="/buscar" element={<SearchResults />} />
            <Route path="/mi/favoritos" element={<UserFavoritos />} />
            <Route path="/mi/recetas" element={<UserRecetas />} />
          </Routes>
        </Box>
        <Footer />
      </Box>
    </BrowserRouter>
  );
}

export default App;
