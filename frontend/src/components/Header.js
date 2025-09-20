import React, { useState, useEffect } from 'react';
import { Link as RouterLink, useNavigate } from 'react-router-dom';
import AppBar from '@mui/material/AppBar';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import Button from '@mui/material/Button';
import Box from '@mui/material/Box';
import TextField from '@mui/material/TextField';
import InputAdornment from '@mui/material/InputAdornment';
import IconButton from '@mui/material/IconButton';
import SearchIcon from '@mui/icons-material/Search';
import Avatar from '@mui/material/Avatar';
import UserSidebar from './UserSidebar';
import { isAuthenticated } from '../api';

export default function Header(){
  const [q, setQ] = useState('');
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [isAuthLocal, setIsAuthLocal] = useState(isAuthenticated());
  const navigate = useNavigate();

  useEffect(()=>{
    const onStorage = (e) => {
      if(e.key === 'authToken' || e.key === 'user'){
        setIsAuthLocal(isAuthenticated());
      }
    };
    window.addEventListener('storage', onStorage);
    const onAuthChanged = () => setIsAuthLocal(isAuthenticated());
    window.addEventListener('authChanged', onAuthChanged);
    return () => {
      window.removeEventListener('storage', onStorage);
      window.removeEventListener('authChanged', onAuthChanged);
    };
  }, []);

  const submitSearch = (e) => {
    e?.preventDefault();
    if(!q || q.trim()==='') return;
    navigate(`/buscar?q=${encodeURIComponent(q.trim())}`);
  };

  return (
    <AppBar position="static" sx={{ backgroundColor: '#F75442' }}>
      <Toolbar>
        <Box sx={{ flexGrow: 1 }}>
          <RouterLink to="/" style={{ textDecoration: 'none', color: 'inherit' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginLeft: 12 }}>
              <div style={{ display: 'flex', flexDirection: 'column', lineHeight: 1 }}>
                <Typography variant="h5" component="div" sx={{ fontWeight: 700, color: '#2F4295', fontFamily: 'Roboto, sans-serif', fontSize: { xs: '1.2rem', md: '1.6rem' } }}>Recetas</Typography>
                <Typography variant="subtitle2" sx={{ fontWeight: 700, color: '#2F4295', fontFamily: 'Roboto, sans-serif', fontSize: { xs: '0.9rem', md: '1.1rem' } }}>Del mundo</Typography>
              </div>
              <Box component="img" src="/img/cheems-waso.png" alt="logo" sx={{ height: 36, width: 'auto' }} />
            </div>
          </RouterLink>
        </Box>
        <Box component="form" onSubmit={submitSearch} sx={{ mr: 2, display: { xs: 'none', sm: 'flex' }, alignItems: 'center' }}>
          <TextField size="small" placeholder="Buscar recetas..." value={q} onChange={(e)=>setQ(e.target.value)} InputProps={{ endAdornment: (
            <InputAdornment position="end">
              <IconButton type="submit" edge="end" aria-label="buscar">
                <SearchIcon />
              </IconButton>
            </InputAdornment>
          ) }} sx={{ backgroundColor: 'rgba(255,255,255,0.9)', borderRadius: 1, minWidth: 200, '& .MuiInputBase-input': { fontFamily: 'Lato, sans-serif' } }} />
        </Box>
        <Button color="inherit" component={RouterLink} to="/" sx={{ fontFamily: 'Lato, sans-serif' }}>Inicio</Button>
        <Button color="inherit" component={RouterLink} to="/paises" sx={{ fontFamily: 'Lato, sans-serif' }}>Países</Button>
        <Button color="inherit" component={RouterLink} to="/categorias" sx={{ fontFamily: 'Lato, sans-serif' }}>Categorías</Button>
        {isAuthLocal ? (
          <IconButton onClick={()=> setSidebarOpen(true)} sx={{ ml: 1 }}>
            <Avatar alt="user" src="/img/user-cheems.png" />
          </IconButton>
        ) : (
          <Button color="inherit" component={RouterLink} to="/login" sx={{ fontFamily: 'Lato, sans-serif' }}>Acceder</Button>
        )}
        <UserSidebar open={sidebarOpen} onClose={()=> setSidebarOpen(false)} onLogout={() => {
          try{ localStorage.removeItem('authToken'); localStorage.removeItem('user'); }catch(e){}
          setSidebarOpen(false);
          setIsAuthLocal(false);
          navigate('/');
        }} />
      </Toolbar>
    </AppBar>
  );
}
