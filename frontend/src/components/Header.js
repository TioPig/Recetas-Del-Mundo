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
import AddIcon from '@mui/icons-material/Add';
import MenuIcon from '@mui/icons-material/Menu';
import Avatar from '@mui/material/Avatar';
import Drawer from '@mui/material/Drawer';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import Divider from '@mui/material/Divider';
import HomeIcon from '@mui/icons-material/Home';
import PublicIcon from '@mui/icons-material/Public';
import CategoryIcon from '@mui/icons-material/Category';
import LoginIcon from '@mui/icons-material/Login';
import PersonAddIcon from '@mui/icons-material/PersonAdd';
import CloseIcon from '@mui/icons-material/Close';
import FavoriteIcon from '@mui/icons-material/Favorite';
import AdminPanelSettingsIcon from '@mui/icons-material/AdminPanelSettings';
import UserSidebar from './UserSidebar';
import { isAuthenticated, isAdmin, createDonationSession } from '../api';

export default function Header(){
  const [q, setQ] = useState('');
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [isAuthLocal, setIsAuthLocal] = useState(isAuthenticated());
  const [isAdminLocal, setIsAdminLocal] = useState(isAdmin());
  const navigate = useNavigate();

  useEffect(()=>{
    const onStorage = (e) => {
      if(e.key === 'authToken' || e.key === 'user'){
        setIsAuthLocal(isAuthenticated());
        setIsAdminLocal(isAdmin());
      }
    };
    window.addEventListener('storage', onStorage);
    const onAuthChanged = () => {
      setIsAuthLocal(isAuthenticated());
      setIsAdminLocal(isAdmin());
    };
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

  const handleDonate = async () => {
    if (!isAuthLocal) {
      alert('Debes iniciar sesión para donar');
      navigate('/login');
      return;
    }

    try {
      const response = await createDonationSession(5.00); // Monto por defecto $5
      
      // Si hay URL de Stripe, abrir sesión de pago
      if (response.data && response.data.url) {
        window.open(response.data.url, '_blank');
      } 
      // Si no hay URL pero se creó la donación (modo sin Stripe configurado)
      else if (response.data && response.data.donacion) {
        const message = response.data.note || 'Donación registrada. Stripe no está configurado en el servidor.';
        alert(`✅ ${message}\n\nDonación ID: ${response.data.donacion.idDonacion}\nMonto: $${response.data.donacion.amount} ${response.data.donacion.currency}`);
      }
    } catch (error) {
      console.error('Error al crear sesión de donación:', error);
      const errorMsg = error.response?.data?.mensaje || error.message || 'Error al procesar la donación.';
      alert(`❌ ${errorMsg}`);
    }
  };

  const handleMobileMenuClose = () => {
    setMobileMenuOpen(false);
  };

  const menuItems = [
    { text: 'Inicio', icon: <HomeIcon />, path: '/' },
    { text: 'Países', icon: <PublicIcon />, path: '/paises' },
    { text: 'Categorías', icon: <CategoryIcon />, path: '/categorias' },
  ];

  return (
    <>
      <AppBar position="static" sx={{ backgroundColor: '#F75442' }}>
        <Toolbar>
          {/* Mobile Menu Button */}
          <IconButton
            color="inherit"
            edge="start"
            onClick={() => setMobileMenuOpen(true)}
            sx={{ mr: 2, display: { md: 'none' } }}
          >
            <MenuIcon />
          </IconButton>

          {/* Logo */}
          <Box sx={{ flexGrow: 1 }}>
            <RouterLink to="/" style={{ textDecoration: 'none', color: 'inherit' }}>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                <Box sx={{ display: 'flex', flexDirection: 'column', lineHeight: 1 }}>
                  <Typography 
                    variant="h5" 
                    component="div" 
                    sx={{ 
                      fontWeight: 700, 
                      color: '#2F4295', 
                      fontFamily: 'Roboto, sans-serif', 
                      fontSize: { xs: '1rem', sm: '1.2rem', md: '1.6rem' } 
                    }}
                  >
                    Recetas
                  </Typography>
                  <Typography 
                    variant="subtitle2" 
                    sx={{ 
                      fontWeight: 700, 
                      color: '#2F4295', 
                      fontFamily: 'Roboto, sans-serif', 
                      fontSize: { xs: '0.75rem', sm: '0.9rem', md: '1.1rem' } 
                    }}
                  >
                    Del mundo
                  </Typography>
                </Box>
                <Box 
                  component="img" 
                  src="/img/cheems-waso.png" 
                  alt="logo" 
                  sx={{ height: { xs: 28, sm: 32, md: 36 }, width: 'auto' }} 
                />
              </Box>
            </RouterLink>
          </Box>

          {/* Search Bar - Hidden on mobile */}
          <Box 
            component="form" 
            onSubmit={submitSearch} 
            sx={{ mr: 2, display: { xs: 'none', sm: 'flex' }, alignItems: 'center' }}
          >
            <TextField 
              size="small" 
              placeholder="Buscar recetas..." 
              value={q} 
              onChange={(e)=>setQ(e.target.value)} 
              InputProps={{ 
                endAdornment: (
                  <InputAdornment position="end">
                    <IconButton type="submit" edge="end" aria-label="buscar">
                      <SearchIcon />
                    </IconButton>
                  </InputAdornment>
                ) 
              }} 
              sx={{ 
                backgroundColor: 'rgba(255,255,255,0.9)', 
                borderRadius: 1, 
                minWidth: { sm: 150, md: 200 },
                '& .MuiInputBase-input': { fontFamily: 'Lato, sans-serif' } 
              }} 
            />
          </Box>

          {/* Desktop Menu */}
          <Box sx={{ display: { xs: 'none', md: 'flex' }, alignItems: 'center', gap: 1 }}>
            <Button color="inherit" component={RouterLink} to="/" sx={{ fontFamily: 'Lato, sans-serif' }}>
              Inicio
            </Button>
            <Button color="inherit" component={RouterLink} to="/paises" sx={{ fontFamily: 'Lato, sans-serif' }}>
              Países
            </Button>
            <Button color="inherit" component={RouterLink} to="/categorias" sx={{ fontFamily: 'Lato, sans-serif' }}>
              Categorías
            </Button>
            <Button 
              variant="contained" 
              startIcon={<FavoriteIcon />}
              sx={{ 
                ml: 1, 
                backgroundColor: '#F75442', 
                '&:hover': { backgroundColor: '#d64032' },
                fontFamily: 'Lato, sans-serif'
              }}
              onClick={handleDonate}
            >
              Donar
            </Button>
            
            {isAdminLocal && (
              <Button 
                variant="contained" 
                component={RouterLink} 
                to="/admin" 
                startIcon={<AdminPanelSettingsIcon />}
                sx={{ 
                  ml: 1, 
                  backgroundColor: '#673AB7', 
                  '&:hover': { backgroundColor: '#512DA8' },
                  fontFamily: 'Lato, sans-serif'
                }}
              >
                Admin
              </Button>
            )}
            
            {isAuthLocal ? (
              <>
                <Button 
                  variant="contained" 
                  component={RouterLink} 
                  to="/nueva-receta" 
                  startIcon={<AddIcon />}
                  sx={{ 
                    ml: 1, 
                    backgroundColor: '#2F4295', 
                    '&:hover': { backgroundColor: '#1e2a5e' },
                    fontFamily: 'Lato, sans-serif'
                  }}
                >
                  Añadir Receta
                </Button>
                <IconButton onClick={()=> setSidebarOpen(true)} sx={{ ml: 1 }}>
                  <Avatar alt="user" src="/img/user-cheems.png" />
                </IconButton>
              </>
            ) : (
              <>
                <Button color="inherit" component={RouterLink} to="/login" sx={{ fontFamily: 'Lato, sans-serif' }}>
                  Acceder
                </Button>
                <Button 
                  variant="outlined" 
                  component={RouterLink} 
                  to="/registro" 
                  sx={{ 
                    ml: 1, 
                    borderColor: 'white', 
                    color: 'white',
                    '&:hover': { borderColor: 'white', backgroundColor: 'rgba(255,255,255,0.1)' },
                    fontFamily: 'Lato, sans-serif'
                  }}
                >
                  Registrarse
                </Button>
              </>
            )}
          </Box>

          {/* Mobile User Avatar/Actions */}
          <Box sx={{ display: { xs: 'flex', md: 'none' }, alignItems: 'center' }}>
            {isAuthLocal ? (
              <IconButton onClick={()=> setSidebarOpen(true)} sx={{ color: 'white' }}>
                <Avatar alt="user" src="/img/user-cheems.png" sx={{ width: 32, height: 32 }} />
              </IconButton>
            ) : (
              <IconButton component={RouterLink} to="/login" sx={{ color: 'white' }}>
                <LoginIcon />
              </IconButton>
            )}
          </Box>
        </Toolbar>
      </AppBar>

      {/* Mobile Drawer Menu */}
      <Drawer
        anchor="left"
        open={mobileMenuOpen}
        onClose={handleMobileMenuClose}
        sx={{ display: { xs: 'block', md: 'none' } }}
      >
        <Box sx={{ width: 280 }}>
          {/* Header del Drawer */}
          <Box sx={{ p: 2, backgroundColor: '#F75442', color: 'white', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <Typography variant="h6" sx={{ fontFamily: 'Lato, sans-serif', fontWeight: 700 }}>
              Menú
            </Typography>
            <IconButton onClick={handleMobileMenuClose} sx={{ color: 'white' }}>
              <CloseIcon />
            </IconButton>
          </Box>

          <Divider />

          {/* Search en móvil */}
          <Box sx={{ p: 2 }}>
            <Box component="form" onSubmit={(e) => { submitSearch(e); handleMobileMenuClose(); }}>
              <TextField 
                fullWidth
                size="small" 
                placeholder="Buscar recetas..." 
                value={q} 
                onChange={(e)=>setQ(e.target.value)} 
                InputProps={{ 
                  endAdornment: (
                    <InputAdornment position="end">
                      <IconButton type="submit" edge="end">
                        <SearchIcon />
                      </IconButton>
                    </InputAdornment>
                  ) 
                }} 
              />
            </Box>
          </Box>

          <Divider />

          {/* Menu Items */}
          <List>
            {menuItems.map((item) => (
              <ListItem key={item.text} disablePadding>
                <ListItemButton 
                  component={RouterLink} 
                  to={item.path}
                  onClick={handleMobileMenuClose}
                >
                  <ListItemIcon>{item.icon}</ListItemIcon>
                  <ListItemText primary={item.text} />
                </ListItemButton>
              </ListItem>
            ))}
          </List>

          <Divider />

          {/* Auth Section */}
          <List>
            <ListItem disablePadding>
              <ListItemButton 
                onClick={() => {
                  handleMobileMenuClose();
                  handleDonate();
                }}
                sx={{ backgroundColor: '#FFF5F5' }}
              >
                <ListItemIcon>
                  <FavoriteIcon sx={{ color: '#F75442' }} />
                </ListItemIcon>
                <ListItemText 
                  primary="Donar" 
                  primaryTypographyProps={{ fontWeight: 600, color: '#F75442' }}
                />
              </ListItemButton>
            </ListItem>
            {isAdminLocal && (
              <ListItem disablePadding>
                <ListItemButton 
                  component={RouterLink} 
                  to="/admin"
                  onClick={handleMobileMenuClose}
                  sx={{ backgroundColor: '#F3E5F5' }}
                >
                  <ListItemIcon>
                    <AdminPanelSettingsIcon sx={{ color: '#673AB7' }} />
                  </ListItemIcon>
                  <ListItemText 
                    primary="Panel Admin" 
                    primaryTypographyProps={{ fontWeight: 600, color: '#673AB7' }}
                  />
                </ListItemButton>
              </ListItem>
            )}
            {isAuthLocal ? (
              <ListItem disablePadding>
                <ListItemButton 
                  component={RouterLink} 
                  to="/nueva-receta"
                  onClick={handleMobileMenuClose}
                  sx={{ backgroundColor: '#F6F0E0' }}
                >
                  <ListItemIcon>
                    <AddIcon sx={{ color: '#F75442' }} />
                  </ListItemIcon>
                  <ListItemText 
                    primary="Añadir Receta" 
                    primaryTypographyProps={{ fontWeight: 600, color: '#F75442' }}
                  />
                </ListItemButton>
              </ListItem>
            ) : (
              <>
                <ListItem disablePadding>
                  <ListItemButton 
                    component={RouterLink} 
                    to="/login"
                    onClick={handleMobileMenuClose}
                  >
                    <ListItemIcon>
                      <LoginIcon />
                    </ListItemIcon>
                    <ListItemText primary="Acceder" />
                  </ListItemButton>
                </ListItem>
                <ListItem disablePadding>
                  <ListItemButton 
                    component={RouterLink} 
                    to="/registro"
                    onClick={handleMobileMenuClose}
                  >
                    <ListItemIcon>
                      <PersonAddIcon />
                    </ListItemIcon>
                    <ListItemText primary="Registrarse" />
                  </ListItemButton>
                </ListItem>
              </>
            )}
          </List>
        </Box>
      </Drawer>

      <UserSidebar 
        open={sidebarOpen} 
        onClose={()=> setSidebarOpen(false)} 
        onLogout={() => {
          try{ localStorage.removeItem('authToken'); localStorage.removeItem('user'); }catch(e){}
          setSidebarOpen(false);
          setIsAuthLocal(false);
          setIsAdminLocal(false);
          navigate('/');
        }} 
      />
    </>
  );
}
