import React from 'react';
import { useState } from 'react';
import { useNavigate, Link as RouterLink } from 'react-router-dom';
import Container from '@mui/material/Container';
import Grid from '@mui/material/Grid';
import Typography from '@mui/material/Typography';
import TextField from '@mui/material/TextField';
import Button from '@mui/material/Button';
import Box from '@mui/material/Box';
import InputAdornment from '@mui/material/InputAdornment';
import IconButton from '@mui/material/IconButton';
import Visibility from '@mui/icons-material/Visibility';
import VisibilityOff from '@mui/icons-material/VisibilityOff';
import { login } from '../api';
import Link from '@mui/material/Link';

export default function Login(){
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const navigate = useNavigate();

  const handleSubmit = async () => {
    setError(null);
  if(!email || !password){ setError('Completa email y contraseña'); return; }
    setLoading(true);
    try{
      // Use /auth/login endpoint as documented in endpoints.md
      const res = await login({ email, password });

      const data = res && res.data ? res.data : res;
      
      // Verificar si la respuesta indica fallo
      if (data?.exito === false) {
        setError(data?.mensaje || 'Credenciales inválidas');
        setLoading(false);
        return;
      }
      
      // attempt to extract token and user from common shapes
      const token = data?.token || data?.authToken || data?.accessToken || data?.tokenJWT || data?.token_jwt;
      const user = data?.user || data?.usuario || data?.usuarioLogueado || data;

      if(token) localStorage.setItem('authToken', token);
      try{ localStorage.setItem('user', typeof user === 'string' ? user : JSON.stringify(user)); }catch(e){ /* ignore */ }

  // notify other parts of the app in this window that auth changed
  try{ window.dispatchEvent(new Event('authChanged')); }catch(e){}

  setLoading(false);
  // navigate home
  navigate('/');
    }catch(e){
      setLoading(false);
      const errorMsg = e.response?.data?.mensaje || 'Credenciales inválidas o error de conexión';
      setError(errorMsg);
    }
  };

  return (
    <Box>
      {/* Hero Section */}
      <Box 
        sx={{ 
          textAlign: 'center', 
          background: 'linear-gradient(135deg, #667EEA 0%, #764BA2 100%)',
          py: { xs: 4, sm: 6, md: 8 },
          boxShadow: '0 4px 20px rgba(102, 126, 234, 0.3)'
        }}
      >
        <Typography 
          variant="h2" 
          sx={{ 
            color: '#FFFFFF', 
            fontFamily: 'Lato, sans-serif', 
            fontWeight: 900,
            fontSize: { xs: '2rem', sm: '2.5rem', md: '3rem' }
          }}
        >
          Acceder
        </Typography>
        <Typography
          variant="h6"
          sx={{
            color: 'rgba(255, 255, 255, 0.9)',
            fontFamily: 'Open Sans, sans-serif',
            mt: 1,
            fontSize: { xs: '0.9rem', sm: '1rem', md: '1.1rem' }
          }}
        >
          Ingresa a tu cuenta para gestionar tus recetas
        </Typography>
      </Box>

      <Container maxWidth={false} disableGutters sx={{ py: 0, backgroundColor: '#F7FAFC', pb: 0 }}>
        <Grid container spacing={0} alignItems="stretch" sx={{ minHeight: '60vh', flexWrap: { xs: 'wrap', md: 'nowrap' } }}>
          <Grid item xs={12} md={6} sx={{ p: 0, m: 0 }}> 
            <Box 
              component="img" 
              src="/img/banner-2.jpg" 
              alt="Banner" 
              sx={{ 
                display: { xs: 'none', md: 'block' }, 
                width: '100%', 
                height: '100%', 
                objectFit: 'cover', 
                m: 0, 
                p: 0, 
                minWidth: { md: '50%' },
                filter: 'brightness(0.95)'
              }} 
            />
          </Grid>
          <Grid item xs={12} md={6} sx={{ display: 'flex', alignItems: 'center', minWidth: { md: '50%' }, p: { xs: 3, sm: 4, md: 6 } }}>
            <Box sx={{ width: '100%' }}>
              <Typography 
                variant="h3" 
                sx={{ 
                  fontFamily: 'Lato, sans-serif', 
                  fontWeight: 900, 
                  color: '#1A202C', 
                  mt: { xs: 0, md: '-1.5rem' }, 
                  fontSize: { xs: '1.6rem', sm: '1.8rem', md: '2rem' } 
                }}
              >
                Bienvenid@ 👋
              </Typography>
              <Box sx={{ mt: 3, width: '100%', maxWidth: 420, mx: { xs: 0, md: 0 } }}>
                <TextField 
                  fullWidth 
                  label="Email" 
                  variant="outlined" 
                  sx={{ 
                    mb: 2.5,
                    '& .MuiOutlinedInput-root': {
                      borderRadius: 2,
                      fontFamily: 'Open Sans, sans-serif',
                      '&.Mui-focused fieldset': {
                        borderColor: '#667EEA',
                      },
                    },
                    '& .MuiInputLabel-root.Mui-focused': {
                      color: '#667EEA',
                    },
                  }} 
                  value={email} 
                  onChange={(e)=> setEmail(e.target.value)} 
                />
                <TextField 
                  fullWidth 
                  label="Contraseña" 
                  type={showPassword? 'text' : 'password'} 
                  variant="outlined" 
                  sx={{ 
                    mb: 2,
                    '& .MuiOutlinedInput-root': {
                      borderRadius: 2,
                      fontFamily: 'Open Sans, sans-serif',
                      '&.Mui-focused fieldset': {
                        borderColor: '#667EEA',
                      },
                    },
                    '& .MuiInputLabel-root.Mui-focused': {
                      color: '#667EEA',
                    },
                  }} 
                  value={password} 
                  onChange={(e)=> setPassword(e.target.value)} 
                  InputProps={{ 
                    endAdornment: (
                      <InputAdornment position="end">
                        <IconButton 
                          aria-label="toggle password visibility" 
                          onClick={()=> setShowPassword(s => !s)} 
                          edge="end"
                          sx={{
                            color: '#667EEA',
                            '&:hover': {
                              backgroundColor: 'rgba(102, 126, 234, 0.1)'
                            }
                          }}
                        >
                          {showPassword ? <VisibilityOff /> : <Visibility />}
                        </IconButton>
                      </InputAdornment>
                    ) 
                  }} 
                />
                {error && (
                  <Typography 
                    color="error" 
                    sx={{ 
                      mb: 2, 
                      fontFamily: 'Open Sans, sans-serif',
                      fontSize: '0.875rem',
                      backgroundColor: 'rgba(245, 101, 101, 0.1)',
                      p: 1.5,
                      borderRadius: 1,
                      border: '1px solid rgba(245, 101, 101, 0.3)'
                    }}
                  >
                    {error}
                  </Typography>
                )}
                <Typography 
                  variant="body2" 
                  sx={{ 
                    fontFamily: 'Open Sans, sans-serif', 
                    fontWeight: 600,
                    color: '#4A5568',
                    mb: 2.5
                  }}
                >
                  ¿No tienes cuenta?{' '}
                  <Link 
                    component={RouterLink} 
                    to="/register" 
                    sx={{ 
                      color: '#667EEA',
                      textDecoration: 'none',
                      fontWeight: 700,
                      '&:hover': {
                        textDecoration: 'underline',
                        color: '#764BA2'
                      }
                    }}
                  >
                    Regístrate aquí
                  </Link>
                </Typography>
                <Box sx={{ mt: 3, display: 'flex', gap: 2 }}>
                  <Button 
                    variant="contained" 
                    fullWidth
                    sx={{ 
                      background: 'linear-gradient(135deg, #F093FB 0%, #F5576C 100%)',
                      color: '#FFFFFF',
                      fontFamily: 'Lato, sans-serif',
                      fontWeight: 700,
                      fontSize: { xs: '0.95rem', md: '1rem' },
                      py: { xs: 1.5, md: 1.8 },
                      borderRadius: 2,
                      textTransform: 'none',
                      boxShadow: '0 4px 15px rgba(240, 147, 251, 0.4)',
                      transition: 'all 0.3s ease',
                      '&:hover': {
                        transform: 'translateY(-2px)',
                        boxShadow: '0 6px 20px rgba(240, 147, 251, 0.6)'
                      },
                      '&:disabled': {
                        background: 'linear-gradient(135deg, rgba(240, 147, 251, 0.5) 0%, rgba(245, 87, 108, 0.5) 100%)',
                        color: 'rgba(255, 255, 255, 0.7)'
                      }
                    }} 
                    onClick={handleSubmit} 
                    disabled={loading}
                  >
                    {loading? 'Ingresando...' : 'Ingresar'}
                  </Button>
                </Box>
              </Box>
            </Box>
          </Grid>
        </Grid>
      </Container>
    </Box>
  );
}
