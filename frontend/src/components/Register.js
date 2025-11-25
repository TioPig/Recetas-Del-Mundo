import React from 'react';
import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import Container from '@mui/material/Container';
import Typography from '@mui/material/Typography';
import TextField from '@mui/material/TextField';
import Button from '@mui/material/Button';
import Box from '@mui/material/Box';
import Grid from '@mui/material/Grid';
import InputAdornment from '@mui/material/InputAdornment';
import IconButton from '@mui/material/IconButton';
import Visibility from '@mui/icons-material/Visibility';
import VisibilityOff from '@mui/icons-material/VisibilityOff';
import { register } from '../api';

export default function Register(){
  const [nombre, setNombre] = useState('');
  const [apellido, setApellido] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [password2, setPassword2] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [showPassword2, setShowPassword2] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const navigate = useNavigate();

  useEffect(() => {
    // Redirigir al inicio si ya está autenticado
    const token = localStorage.getItem('authToken');
    if (token && token !== 'null' && token !== 'undefined' && token.trim() !== '') {
      navigate('/');
    }
  }, [navigate]);

  const handleRegister = async () => {
    setError(null);
    if(!nombre || !apellido || !email || !password){ 
      setError('Completa todos los campos requeridos'); 
      return; 
    }
    if(password !== password2){ 
      setError('Las contraseñas no coinciden'); 
      return; 
    }
    setLoading(true);
    try{
      // Enviar en el formato que espera el backend
      const payload = { 
        nombre, 
        apellido, 
        email, 
        password 
      };
      const response = await register(payload);
      setLoading(false);
      
      // Verificar si el registro fue exitoso
      if (response.data && response.data.exito) {
        navigate('/login');
      } else {
        setError(response.data?.mensaje || 'Error al crear la cuenta');
      }
    }catch(e){
      setLoading(false);
      const errorMsg = e.response?.data?.mensaje || 'Error al crear la cuenta. Intenta de nuevo.';
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
          Crear cuenta
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
          Únete a nuestra comunidad de amantes de la cocina
        </Typography>
      </Box>

      <Container maxWidth={false} disableGutters sx={{ py: 0, backgroundColor: '#F7FAFC', pb: 0 }}>
        <Grid container spacing={0} alignItems="stretch" sx={{ minHeight: '70vh', flexWrap: { xs: 'wrap', md: 'nowrap' } }}>
          <Grid item xs={12} md={6} sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', p: { xs: 3, sm: 4, md: 6 }, minWidth: { md: '50%' }, mx: { xs: 'auto', md: 0 } }}>
            <Box sx={{ width: '100%', maxWidth: 500 }}>
              <Typography
                variant="h5"
                sx={{
                  fontFamily: 'Lato, sans-serif',
                  fontWeight: 900,
                  color: '#1A202C',
                  mb: 3,
                  fontSize: { xs: '1.3rem', md: '1.5rem' }
                }}
              >
                Información de la cuenta
              </Typography>
              
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2.5 }}>
                <TextField 
                  label="Nombre" 
                  value={nombre} 
                  onChange={(e)=> setNombre(e.target.value)} 
                  fullWidth 
                  required
                  sx={{
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
                />
                <TextField 
                  label="Apellido" 
                  value={apellido} 
                  onChange={(e)=> setApellido(e.target.value)} 
                  fullWidth 
                  required
                  sx={{
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
                />
                <TextField 
                  label="Email" 
                  value={email} 
                  onChange={(e)=> setEmail(e.target.value)} 
                  type="email" 
                  fullWidth 
                  required
                  sx={{
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
                />
                <TextField 
                  label="Contraseña" 
                  value={password} 
                  onChange={(e)=> setPassword(e.target.value)} 
                  type={showPassword ? 'text' : 'password'}
                  fullWidth 
                  required
                  InputProps={{
                    endAdornment: (
                      <InputAdornment position="end">
                        <IconButton
                          onClick={() => setShowPassword(s => !s)}
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
                  sx={{
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
                />
                <TextField 
                  label="Confirmar Contraseña" 
                  value={password2} 
                  onChange={(e)=> setPassword2(e.target.value)} 
                  type={showPassword2 ? 'text' : 'password'}
                  fullWidth 
                  required
                  InputProps={{
                    endAdornment: (
                      <InputAdornment position="end">
                        <IconButton
                          onClick={() => setShowPassword2(s => !s)}
                          edge="end"
                          sx={{
                            color: '#667EEA',
                            '&:hover': {
                              backgroundColor: 'rgba(102, 126, 234, 0.1)'
                            }
                          }}
                        >
                          {showPassword2 ? <VisibilityOff /> : <Visibility />}
                        </IconButton>
                      </InputAdornment>
                    )
                  }}
                  sx={{
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
                />
                
                {error && (
                  <Typography 
                    color="error" 
                    sx={{ 
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
                
                <Box sx={{ display: 'flex', gap: 2, mt: 1, flexDirection: { xs: 'column', sm: 'row' } }}>
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
                    onClick={handleRegister} 
                    disabled={loading}
                  >
                    {loading? 'Creando...' : 'Crear cuenta'}
                  </Button>
                  <Button 
                    variant="outlined" 
                    fullWidth
                    onClick={()=> navigate('/login')}
                    sx={{
                      borderColor: '#667EEA',
                      color: '#667EEA',
                      fontFamily: 'Lato, sans-serif',
                      fontWeight: 700,
                      fontSize: { xs: '0.95rem', md: '1rem' },
                      py: { xs: 1.5, md: 1.8 },
                      borderRadius: 2,
                      textTransform: 'none',
                      transition: 'all 0.3s ease',
                      '&:hover': {
                        borderColor: '#764BA2',
                        backgroundColor: 'rgba(102, 126, 234, 0.08)',
                        transform: 'translateY(-2px)'
                      }
                    }}
                  >
                    Volver
                  </Button>
                </Box>
              </Box>
            </Box>
          </Grid>
          
          <Grid item xs={12} md={6} sx={{ p: 0, m: 0, minWidth: { md: '50%' } }}>
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
                filter: 'brightness(0.95)'
              }} 
            />
          </Grid>
        </Grid>
      </Container>
    </Box>
  );
}
