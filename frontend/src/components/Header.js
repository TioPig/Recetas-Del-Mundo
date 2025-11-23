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
import KeyboardArrowDownIcon from '@mui/icons-material/KeyboardArrowDown';
import Paper from '@mui/material/Paper';
import Grid from '@mui/material/Grid';
import MenuList from '@mui/material/MenuList';
import MenuItem from '@mui/material/MenuItem';
import UserSidebar from './UserSidebar';
import AuthPromptDialog from './AuthPromptDialog';
import DonationAmountDialog from './DonationAmountDialog';
import { isAuthenticated, isAdmin, createDonationSession, getPaises, getCategorias } from '../api';

export default function Header(){
  const [q, setQ] = useState('');
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [authPromptOpen, setAuthPromptOpen] = useState(false);
  const [donationDialogOpen, setDonationDialogOpen] = useState(false);
  const [isAuthLocal, setIsAuthLocal] = useState(isAuthenticated());
  const [isAdminLocal, setIsAdminLocal] = useState(isAdmin());
  const [paisesMenuOpen, setPaisesMenuOpen] = useState(false);
  const [categoriasMenuOpen, setCategoriasMenuOpen] = useState(false);
  const [paises, setPaises] = useState([]);
  const [categorias, setCategorias] = useState([]);
  const [paisesCloseTimeout, setPaisesCloseTimeout] = useState(null);
  const [categoriasCloseTimeout, setCategoriasCloseTimeout] = useState(null);
  const navigate = useNavigate();

  // Funciones para manejar la apertura/cierre con delay de los mega menús
  const handlePaisesMouseEnter = () => {
    if (paisesCloseTimeout) {
      clearTimeout(paisesCloseTimeout);
      setPaisesCloseTimeout(null);
    }
    setPaisesMenuOpen(true);
    setCategoriasMenuOpen(false); // Cerrar el otro menú
    if (categoriasCloseTimeout) {
      clearTimeout(categoriasCloseTimeout);
      setCategoriasCloseTimeout(null);
    }
  };

  const handlePaisesMouseLeave = () => {
    const timeout = setTimeout(() => {
      setPaisesMenuOpen(false);
    }, 300); // 300ms de delay antes de cerrar
    setPaisesCloseTimeout(timeout);
  };

  const handleCategoriasMouseEnter = () => {
    if (categoriasCloseTimeout) {
      clearTimeout(categoriasCloseTimeout);
      setCategoriasCloseTimeout(null);
    }
    setCategoriasMenuOpen(true);
    setPaisesMenuOpen(false); // Cerrar el otro menú
    if (paisesCloseTimeout) {
      clearTimeout(paisesCloseTimeout);
      setPaisesCloseTimeout(null);
    }
  };

  const handleCategoriasMouseLeave = () => {
    const timeout = setTimeout(() => {
      setCategoriasMenuOpen(false);
    }, 300); // 300ms de delay antes de cerrar
    setCategoriasCloseTimeout(timeout);
  };

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
      // Limpiar timeouts al desmontar
      if (paisesCloseTimeout) clearTimeout(paisesCloseTimeout);
      if (categoriasCloseTimeout) clearTimeout(categoriasCloseTimeout);
    };
  }, [paisesCloseTimeout, categoriasCloseTimeout]);

  // Cargar países y categorías para el megamenu
  useEffect(() => {
    getPaises().then(r => setPaises(Array.isArray(r.data) ? r.data : [])).catch(() => {});
    getCategorias().then(r => setCategorias(Array.isArray(r.data) ? r.data : [])).catch(() => {});
  }, []);

  const submitSearch = (e) => {
    e?.preventDefault();
    if(!q || q.trim()==='') return;
    navigate(`/buscar?q=${encodeURIComponent(q.trim())}`);
  };

  const handleDonate = async () => {
    if (!isAuthLocal) {
      setAuthPromptOpen(true);
      return;
    }

    // Abrir modal de selección de monto
    setDonationDialogOpen(true);
  };

  const handleDonationConfirm = async (amount) => {
    try {
      const response = await createDonationSession(amount);
      
      // Si hay URL de Stripe, redirigir a la sesión de pago
      if (response.data && response.data.url) {
        window.location.href = response.data.url; // Redirige en la misma ventana
      } 
      // Si no hay URL pero se creó la donación (modo sin Stripe configurado)
      else if (response.data && response.data.donacion) {
        const message = response.data.note || 'Donación registrada. Stripe no está configurado en el servidor.';
        alert(`✅ ${message}\n\nDonación ID: ${response.data.donacion.idDonacion}\nMonto: $${response.data.donacion.amount} ${response.data.donacion.currency}`);
        setDonationDialogOpen(false);
      }
    } catch (error) {
      console.error('Error al crear sesión de donación:', error);
      const errorMsg = error.response?.data?.mensaje || error.message || 'Error al procesar la donación.';
      alert(`❌ ${errorMsg}`);
      setDonationDialogOpen(false);
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
      <AppBar 
        position="static" 
        elevation={4}
        sx={{ 
          background: 'linear-gradient(135deg, #4FACFE 0%, #00F2FE 100%)',
          boxShadow: '0 4px 20px rgba(79, 172, 254, 0.3)'
        }}
      >
        <Toolbar sx={{ py: { xs: 0.5, md: 1 } }}>
          {/* Mobile Menu Button */}
          <IconButton
            color="inherit"
            edge="start"
            onClick={() => setMobileMenuOpen(true)}
            sx={{ 
              mr: 2, 
              display: { lg: 'none' },
              backgroundColor: 'rgba(255,255,255,0.2)',
              '&:hover': { backgroundColor: 'rgba(255,255,255,0.3)' }
            }}
          >
            <MenuIcon />
          </IconButton>

          {/* Logo */}
          <Box sx={{ flexGrow: 1 }}>
            <RouterLink to="/" style={{ textDecoration: 'none', color: 'inherit' }}>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
                <Box 
                  component="img" 
                  src="/img/cheems-waso.png" 
                  alt="logo" 
                  sx={{ 
                    height: { xs: 40, sm: 50, md: 60 }, 
                    width: 'auto',
                    borderRadius: '50%',
                    border: '3px solid white',
                    boxShadow: '0 2px 8px rgba(0,0,0,0.2)',
                    transition: 'transform 0.3s',
                    '&:hover': { transform: 'scale(1.05)' }
                  }} 
                />
                <Typography 
                  variant="h5" 
                  component="div" 
                  sx={{ 
                    fontWeight: 900, 
                    color: 'white', 
                    fontFamily: 'Lato, sans-serif', 
                    fontSize: { xs: '1.2rem', sm: '1.5rem', md: '1.8rem' },
                    textShadow: '2px 2px 4px rgba(0,0,0,0.2)'
                  }}
                >
                  Recetas del Mundo
                </Typography>
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
                backgroundColor: 'white',
                borderRadius: '50px', 
                minWidth: { sm: 200, md: 280 },
                '& .MuiOutlinedInput-root': {
                  borderRadius: '50px',
                  fontFamily: 'Open Sans, sans-serif',
                  '& fieldset': { border: 'none' },
                  boxShadow: '0 4px 12px rgba(0,0,0,0.1)'
                },
                '& .MuiInputBase-input': { 
                  fontFamily: 'Open Sans, sans-serif',
                  color: '#1A202C'
                }
              }} 
            />
          </Box>

          {/* Desktop Menu */}
          <Box sx={{ display: { xs: 'none', lg: 'flex' }, alignItems: 'center', gap: 1, position: 'relative' }}>
            <Button 
              color="inherit" 
              component={RouterLink} 
              to="/" 
              sx={{ 
                fontFamily: 'Open Sans, sans-serif',
                fontWeight: 600,
                fontSize: '1rem',
                px: 2,
                py: 0.8,
                borderRadius: '8px',
                transition: 'all 0.3s',
                '&:hover': { 
                  backgroundColor: 'rgba(255,255,255,0.2)',
                  transform: 'translateY(-2px)'
                }
              }}
            >
              Inicio
            </Button>

            {/* Países Megamenu */}
            <Box 
              onMouseEnter={handlePaisesMouseEnter}
              onMouseLeave={handlePaisesMouseLeave}
              sx={{ position: 'relative' }}
            >
              <Button 
                color="inherit" 
                endIcon={<KeyboardArrowDownIcon />}
                sx={{ 
                  fontFamily: 'Open Sans, sans-serif',
                  fontWeight: 600,
                  fontSize: '1rem',
                  px: 2,
                  py: 0.8,
                  borderRadius: '8px',
                  transition: 'all 0.3s',
                  '&:hover': { 
                    backgroundColor: 'rgba(255,255,255,0.2)',
                    transform: 'translateY(-2px)'
                  }
                }}
              >
                Países
              </Button>
              {paisesMenuOpen && (
                <Paper 
                  elevation={8}
                  sx={{ 
                    position: 'absolute',
                    top: '100%',
                    left: 0,
                    mt: 1,
                    minWidth: 600,
                    maxWidth: 800,
                    zIndex: 1300,
                    borderRadius: 2,
                    overflow: 'hidden',
                    boxShadow: '0 8px 32px rgba(0,0,0,0.15)'
                  }}
                >
                  <Box sx={{ p: 3 }}>
                    <Typography 
                      variant="h6" 
                      sx={{ 
                        mb: 2, 
                        fontFamily: 'Lato, sans-serif',
                        fontWeight: 900,
                        color: '#1A202C',
                        borderBottom: '2px solid #667EEA',
                        pb: 1
                      }}
                    >
                      Recetas por País
                    </Typography>
                    <Grid container spacing={1}>
                      {paises.slice(0, 12).map(pais => (
                        <Grid item xs={6} sm={4} key={pais.idPais}>
                          <MenuItem
                            component={RouterLink}
                            to={`/paises/${pais.idPais}`}
                            onClick={() => setPaisesMenuOpen(false)}
                            sx={{
                              borderRadius: 1,
                              fontFamily: 'Open Sans, sans-serif',
                              transition: 'all 0.2s',
                              '&:hover': {
                                backgroundColor: 'rgba(102, 126, 234, 0.1)',
                                transform: 'translateX(5px)',
                                color: '#667EEA'
                              }
                            }}
                          >
                            {pais.nombre}
                          </MenuItem>
                        </Grid>
                      ))}
                    </Grid>
                    <Button
                      component={RouterLink}
                      to="/paises"
                      fullWidth
                      onClick={() => setPaisesMenuOpen(false)}
                      sx={{
                        mt: 2,
                        background: 'linear-gradient(135deg, #667EEA 0%, #764BA2 100%)',
                        color: 'white',
                        fontFamily: 'Open Sans, sans-serif',
                        fontWeight: 600,
                        py: 1,
                        borderRadius: 2,
                        textTransform: 'none',
                        fontSize: '0.95rem',
                        boxShadow: '0 4px 12px rgba(102, 126, 234, 0.3)',
                        transition: 'all 0.3s ease',
                        '&:hover': { 
                          background: 'linear-gradient(135deg, #764BA2 0%, #667EEA 100%)',
                          transform: 'translateY(-2px)',
                          boxShadow: '0 6px 16px rgba(102, 126, 234, 0.4)'
                        }
                      }}
                    >
                      Ver todos los países →
                    </Button>
                  </Box>
                </Paper>
              )}
            </Box>

            {/* Categorías Megamenu */}
            <Box 
              onMouseEnter={handleCategoriasMouseEnter}
              onMouseLeave={handleCategoriasMouseLeave}
              sx={{ position: 'relative' }}
            >
              <Button 
                color="inherit" 
                endIcon={<KeyboardArrowDownIcon />}
                sx={{ 
                  fontFamily: 'Open Sans, sans-serif',
                  fontWeight: 600,
                  fontSize: '1rem',
                  px: 2,
                  py: 0.8,
                  borderRadius: '8px',
                  transition: 'all 0.3s',
                  '&:hover': { 
                    backgroundColor: 'rgba(255,255,255,0.2)',
                    transform: 'translateY(-2px)'
                  }
                }}
              >
                Categorías
              </Button>
              {categoriasMenuOpen && (
                <Paper 
                  elevation={8}
                  sx={{ 
                    position: 'absolute',
                    top: '100%',
                    left: 0,
                    mt: 1,
                    minWidth: 500,
                    maxWidth: 700,
                    zIndex: 1300,
                    borderRadius: 2,
                    overflow: 'hidden',
                    boxShadow: '0 8px 32px rgba(0,0,0,0.15)'
                  }}
                >
                  <Box sx={{ p: 3 }}>
                    <Typography 
                      variant="h6" 
                      sx={{ 
                        mb: 2, 
                        fontFamily: 'Lato, sans-serif',
                        fontWeight: 900,
                        color: '#1A202C',
                        borderBottom: '2px solid #667EEA',
                        pb: 1
                      }}
                    >
                      Categorías de Recetas
                    </Typography>
                    <Grid container spacing={1}>
                      {categorias.map(categoria => {
                        const catId = categoria.idCat ?? categoria.idCategoria ?? categoria.id;
                        return (
                          <Grid item xs={6} sm={4} key={catId || categoria.nombre}>
                            <MenuItem
                              component={RouterLink}
                              to={`/categorias/${catId}`}
                              onClick={() => setCategoriasMenuOpen(false)}
                              sx={{
                                borderRadius: 1,
                                fontFamily: 'Open Sans, sans-serif',
                                transition: 'all 0.2s',
                                '&:hover': {
                                  backgroundColor: 'rgba(102, 126, 234, 0.1)',
                                  transform: 'translateX(5px)',
                                  color: '#667EEA'
                                }
                              }}
                            >
                              {categoria.nombre}
                            </MenuItem>
                          </Grid>
                        );
                      })}
                    </Grid>
                    <Button
                      component={RouterLink}
                      to="/categorias"
                      fullWidth
                      onClick={() => setCategoriasMenuOpen(false)}
                      sx={{
                        mt: 2,
                        background: 'linear-gradient(135deg, #667EEA 0%, #764BA2 100%)',
                        color: 'white',
                        fontFamily: 'Open Sans, sans-serif',
                        fontWeight: 600,
                        py: 1,
                        borderRadius: 2,
                        textTransform: 'none',
                        fontSize: '0.95rem',
                        boxShadow: '0 4px 12px rgba(102, 126, 234, 0.3)',
                        transition: 'all 0.3s ease',
                        '&:hover': { 
                          background: 'linear-gradient(135deg, #764BA2 0%, #667EEA 100%)',
                          transform: 'translateY(-2px)',
                          boxShadow: '0 6px 16px rgba(102, 126, 234, 0.4)'
                        }
                      }}
                    >
                      Ver todas las categorías →
                    </Button>
                  </Box>
                </Paper>
              )}
            </Box>

            <Button 
              variant="contained" 
              startIcon={<FavoriteIcon />}
              sx={{ 
                ml: 1, 
                backgroundColor: 'white',
                color: '#F56565',
                fontFamily: 'Roboto, sans-serif',
                fontWeight: 700,
                borderRadius: '50px',
                px: 2.5,
                boxShadow: '0 4px 12px rgba(245, 101, 101, 0.2)',
                '&:hover': { 
                  backgroundColor: 'rgba(255,255,255,0.9)',
                  transform: 'translateY(-2px)',
                  boxShadow: '0 6px 16px rgba(245, 101, 101, 0.3)'
                }
              }}
              onClick={handleDonate}
            >
              Donar
            </Button>
            
            {isAuthLocal ? (
              <>
                <Button 
                  variant="contained" 
                  component={RouterLink} 
                  to="/nueva-receta" 
                  startIcon={<AddIcon />}
                  sx={{ 
                    ml: 1, 
                    background: 'linear-gradient(135deg, #F093FB, #F5576C)',
                    fontFamily: 'Roboto, sans-serif',
                    fontWeight: 700,
                    borderRadius: '50px',
                    px: 2.5,
                    whiteSpace: 'nowrap',
                    boxShadow: '0 4px 12px rgba(240, 147, 251, 0.3)',
                    '&:hover': { 
                      background: 'linear-gradient(135deg, #F5576C, #F093FB)',
                      transform: 'translateY(-2px)',
                      boxShadow: '0 6px 16px rgba(240, 147, 251, 0.4)'
                    }
                  }}
                >
                  Añadir Receta
                </Button>
                <IconButton 
                  onClick={()=> setSidebarOpen(true)} 
                  sx={{ 
                    ml: 1,
                    transition: 'transform 0.3s',
                    '&:hover': { transform: 'scale(1.1)' }
                  }}
                >
                  <Avatar 
                    alt="user" 
                    src="/img/user-cheems.png"
                    sx={{
                      width: 45,
                      height: 45,
                      border: '3px solid white',
                      boxShadow: '0 2px 8px rgba(0,0,0,0.2)'
                    }}
                  />
                </IconButton>
              </>
            ) : (
              <>
                <Button 
                  color="inherit" 
                  component={RouterLink} 
                  to="/login" 
                  sx={{ 
                    fontFamily: 'Open Sans, sans-serif',
                    fontWeight: 600,
                    fontSize: '1rem',
                    px: 2,
                    py: 0.8,
                    borderRadius: '8px',
                    transition: 'all 0.3s',
                    '&:hover': { 
                      backgroundColor: 'rgba(255,255,255,0.2)',
                      transform: 'translateY(-2px)'
                    }
                  }}
                >
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
          <Box sx={{ display: { xs: 'flex', lg: 'none' }, alignItems: 'center' }}>
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
        sx={{ display: { xs: 'block', lg: 'none' } }}
      >
        <Box sx={{ width: 280 }}>
          {/* Header del Drawer */}
          <Box sx={{ p: 2, background: 'linear-gradient(135deg, #4FACFE 0%, #00F2FE 100%)', color: 'white', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <Typography variant="h6" sx={{ fontFamily: 'Lato, sans-serif', fontWeight: 700 }}>
              Menú
            </Typography>
            <IconButton onClick={handleMobileMenuClose} sx={{ color: 'white' }}>
              <CloseIcon />
            </IconButton>
          </Box>

          <Divider />

          {/* Search en móvil - solo cuando no se muestra en el header */}
          <Box sx={{ p: 2, display: { xs: 'block', sm: 'none' } }}>
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

          <Divider sx={{ display: { xs: 'block', sm: 'none' } }} />

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
                  <FavoriteIcon sx={{ color: '#F56565' }} />
                </ListItemIcon>
                <ListItemText 
                  primary="Donar" 
                  primaryTypographyProps={{ fontWeight: 600, color: '#F56565' }}
                />
              </ListItemButton>
            </ListItem>
            {isAuthLocal ? (
              <ListItem disablePadding>
                <ListItemButton 
                  component={RouterLink} 
                  to="/nueva-receta"
                  onClick={handleMobileMenuClose}
                  sx={{ backgroundColor: 'rgba(240, 147, 251, 0.1)' }}
                >
                  <ListItemIcon>
                    <AddIcon sx={{ color: '#F093FB' }} />
                  </ListItemIcon>
                  <ListItemText 
                    primary="Añadir Receta" 
                    primaryTypographyProps={{ fontWeight: 600, color: '#F093FB' }}
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

      <AuthPromptDialog 
        open={authPromptOpen} 
        onClose={() => setAuthPromptOpen(false)} 
      />

      <DonationAmountDialog
        open={donationDialogOpen}
        onClose={() => setDonationDialogOpen(false)}
        onConfirm={handleDonationConfirm}
      />
    </>
  );
}
