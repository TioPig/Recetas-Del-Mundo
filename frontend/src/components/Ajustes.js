import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import Container from '@mui/material/Container';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import TextField from '@mui/material/TextField';
import Button from '@mui/material/Button';
import Paper from '@mui/material/Paper';
import Grid from '@mui/material/Grid';
import Alert from '@mui/material/Alert';
import Snackbar from '@mui/material/Snackbar';
import Divider from '@mui/material/Divider';
import Avatar from '@mui/material/Avatar';
import IconButton from '@mui/material/IconButton';
import InputAdornment from '@mui/material/InputAdornment';
import SettingsIcon from '@mui/icons-material/Settings';
import PersonIcon from '@mui/icons-material/Person';
import EmailIcon from '@mui/icons-material/Email';
import LockIcon from '@mui/icons-material/Lock';
import SaveIcon from '@mui/icons-material/Save';
import Visibility from '@mui/icons-material/Visibility';
import VisibilityOff from '@mui/icons-material/VisibilityOff';
import { updateUsuario, login } from '../api';

export default function Ajustes() {
  const navigate = useNavigate();
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState(false);

  // Estados para el formulario
  const [nombre, setNombre] = useState('');
  const [apellido, setApellido] = useState('');
  const [email, setEmail] = useState('');
  const [passwordActual, setPasswordActual] = useState('');
  const [passwordNueva, setPasswordNueva] = useState('');
  const [passwordConfirmar, setPasswordConfirmar] = useState('');

  // Estados para mostrar/ocultar contraseñas
  const [showPasswordActual, setShowPasswordActual] = useState(false);
  const [showPasswordNueva, setShowPasswordNueva] = useState(false);
  const [showPasswordConfirmar, setShowPasswordConfirmar] = useState(false);

  useEffect(() => {
    // Verificar autenticación y cargar datos del usuario
    const userData = JSON.parse(localStorage.getItem('user') || 'null');
    if (!userData) {
      navigate('/login');
      return;
    }
    
    setUser(userData);
    setNombre(userData.nombre || userData.name || '');
    setApellido(userData.apellido || userData.lastName || '');
    setEmail(userData.email || userData.correo || userData.mail || '');
  }, [navigate]);

  const handleUpdatePersonalInfo = async () => {
    setError('');
    setSuccess(false);

    // Validaciones básicas
    if (!nombre.trim()) {
      setError('El nombre es obligatorio');
      return;
    }
    if (!apellido.trim()) {
      setError('El apellido es obligatorio');
      return;
    }
    if (!email.trim()) {
      setError('El email es obligatorio');
      return;
    }

    // Validación de email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      setError('El formato del email no es válido');
      return;
    }

    setLoading(true);

    try {
      const userId = user.id_usr || user.idUsr || user.id;

      const updateData = {
        nombre: nombre.trim(),
        apellido: apellido.trim(),
        email: email.trim(),
      };

      const response = await updateUsuario(userId, updateData);
      
      // Verificar si la respuesta indica fallo
      if (response.data?.exito === false) {
        const errorMsg = response.data?.mensaje || 'Error al actualizar la información personal';
        if (errorMsg?.toLowerCase().includes('email')) {
          setError('Este email ya está registrado por otro usuario');
        } else {
          setError(errorMsg);
        }
        setLoading(false);
        return;
      }

      if (response.data) {
        // Actualizar localStorage con los nuevos datos
        const updatedUser = {
          ...user,
          nombre: nombre.trim(),
          apellido: apellido.trim(),
          email: email.trim()
        };
        localStorage.setItem('user', JSON.stringify(updatedUser));
        setUser(updatedUser);

        setSuccess(true);
        setTimeout(() => setSuccess(false), 3000);
      }
    } catch (err) {
      console.error('Error al actualizar información personal:', err);
      const errorMessage = err.response?.data?.mensaje || err.response?.data?.message || err.message;
      
      if (err.response?.status === 400 && errorMessage?.toLowerCase().includes('email')) {
        setError('Este email ya está registrado por otro usuario');
      } else {
        setError(errorMessage || 'Error al actualizar la información personal. Por favor, intenta de nuevo.');
      }
    } finally {
      setLoading(false);
    }
  };

  const handleUpdatePassword = async () => {
    setError('');
    setSuccess(false);

    // Validación de contraseñas
    if (!passwordActual) {
      setError('Debes ingresar tu contraseña actual');
      return;
    }
    if (!passwordNueva) {
      setError('Debes ingresar una nueva contraseña');
      return;
    }
    if (!passwordConfirmar) {
      setError('Debes confirmar la nueva contraseña');
      return;
    }
    if (passwordNueva !== passwordConfirmar) {
      setError('Las contraseñas nuevas no coinciden');
      return;
    }
    if (passwordNueva.length < 6) {
      setError('La contraseña nueva debe tener al menos 6 caracteres');
      return;
    }

    setLoading(true);

    try {
      // PASO 1: Verificar que la contraseña actual sea correcta haciendo login
      try {
        await login({
          email: email,
          password: passwordActual
        });
      } catch (loginErr) {
        console.error('Error al verificar contraseña actual:', loginErr);
        setError('La contraseña actual es incorrecta');
        setLoading(false);
        return;
      }

      // PASO 2: Si el login fue exitoso, proceder a actualizar la contraseña
      const userId = user.id_usr || user.idUsr || user.id;

      const updateData = {
        nombre: nombre.trim(),
        apellido: apellido.trim(),
        email: email.trim(),
        password: passwordNueva
      };

      const response = await updateUsuario(userId, updateData);
      
      // Verificar si la respuesta indica fallo
      if (response.data?.exito === false) {
        setError(response.data?.mensaje || 'Error al actualizar la contraseña');
        setLoading(false);
        return;
      }

      if (response.data) {
        setSuccess(true);
        setPasswordActual('');
        setPasswordNueva('');
        setPasswordConfirmar('');
        setTimeout(() => setSuccess(false), 3000);
      }
    } catch (err) {
      console.error('Error al actualizar contraseña:', err);
      const errorMessage = err.response?.data?.mensaje || err.response?.data?.message || err.message;
      setError(errorMessage || 'Error al actualizar la contraseña. Por favor, intenta de nuevo.');
    } finally {
      setLoading(false);
    }
  };

  const handleCancel = () => {
    navigate('/');
  };

  if (!user) {
    return null;
  }

  return (
    <Box sx={{ minHeight: '100vh', backgroundColor: '#F7FAFC' }}>
      {/* Hero Section */}
      <Box 
        sx={{ 
          background: 'linear-gradient(135deg, #667EEA 0%, #764BA2 100%)',
          py: { xs: 4, sm: 5, md: 6 },
          boxShadow: '0 4px 20px rgba(102, 126, 234, 0.3)'
        }}
      >
        <Container maxWidth="lg">
          <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 2 }}>
            <SettingsIcon sx={{ fontSize: { xs: 36, sm: 44, md: 52 }, color: 'white' }} />
            <Typography 
              variant="h3" 
              component="h1"
              sx={{ 
                fontFamily: 'Lato, sans-serif', 
                fontWeight: 900,
                color: 'white',
                fontSize: { xs: '1.75rem', sm: '2.5rem', md: '3rem' },
                textAlign: 'center'
              }}
            >
              Configuración de Cuenta
            </Typography>
          </Box>
        </Container>
      </Box>

      <Container maxWidth="lg" sx={{ py: { xs: 2, sm: 3, md: 4 }, px: { xs: 2, sm: 3 } }}>
        {error && (
          <Alert 
            severity="error" 
            sx={{ mb: 3 }} 
            onClose={() => setError('')}
          >
            {error}
          </Alert>
        )}

        <Snackbar
          open={success}
          autoHideDuration={3000}
          onClose={() => setSuccess(false)}
          anchorOrigin={{ vertical: 'bottom', horizontal: 'center' }}
        >
          <Alert 
            severity="success" 
            variant="filled"
            sx={{ 
              width: '100%',
              fontFamily: 'Open Sans, sans-serif',
              fontWeight: 600
            }}
          >
            ¡Datos actualizados exitosamente!
          </Alert>
        </Snackbar>

        {/* Información Personal */}
        <Paper 
          elevation={0} 
          sx={{ 
            p: { xs: 2.5, sm: 3.5 }, 
            mb: { xs: 2, sm: 3 }, 
            borderRadius: 3,
            border: '1px solid #E2E8F0',
            boxShadow: '0 4px 12px rgba(102, 126, 234, 0.08)'
          }}
        >
          <Box sx={{ display: 'flex', alignItems: 'center', mb: 3 }}>
            <PersonIcon sx={{ mr: 1.5, color: '#667EEA', fontSize: { xs: 24, sm: 28 } }} />
            <Typography 
              variant="h6" 
              sx={{ 
                fontFamily: 'Lato, sans-serif', 
                fontWeight: 900,
                color: '#1A202C',
                fontSize: { xs: '1.2rem', sm: '1.35rem' }
              }}
            >
              Información Personal
            </Typography>
          </Box>

            <Grid container spacing={2.5}>
              <Grid item xs={12} sm={6}>
                <TextField
                  fullWidth
                  label="Nombre"
                  value={nombre}
                  onChange={(e) => setNombre(e.target.value)}
                  required
                  variant="outlined"
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
                      fontFamily: 'Open Sans, sans-serif',
                      fontWeight: 600
                    },
                  }}
                />
              </Grid>

              <Grid item xs={12} sm={6}>
                <TextField
                  fullWidth
                  label="Apellido"
                  value={apellido}
                  onChange={(e) => setApellido(e.target.value)}
                  required
                  variant="outlined"
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
                      fontFamily: 'Open Sans, sans-serif',
                      fontWeight: 600
                    },
                  }}
                />
              </Grid>

              <Grid item xs={12}>
                <TextField
                  fullWidth
                  label="Email"
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                  variant="outlined"
                  InputProps={{
                    startAdornment: <EmailIcon sx={{ mr: 1, color: '#718096' }} />,
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
                      fontFamily: 'Open Sans, sans-serif',
                      fontWeight: 600
                    },
                  }}
                />
              </Grid>
            </Grid>

            <Divider sx={{ my: 3, borderColor: '#E2E8F0' }} />

            {/* Botón para actualizar información personal */}
            <Box sx={{ display: 'flex', gap: 2, justifyContent: 'flex-end' }}>
              <Button
                variant="contained"
                disabled={loading}
                startIcon={<SaveIcon />}
                onClick={handleUpdatePersonalInfo}
                sx={{
                  background: 'linear-gradient(135deg, #F093FB 0%, #F5576C 100%)',
                  color: 'white',
                  fontFamily: 'Open Sans, sans-serif',
                  fontWeight: 700,
                  borderRadius: 50,
                  px: { xs: 3, sm: 4 },
                  py: 1.2,
                  fontSize: { xs: '0.9rem', sm: '1rem' },
                  '&:hover': {
                    background: 'linear-gradient(135deg, #F5576C 0%, #F093FB 100%)',
                    transform: 'translateY(-2px)',
                    boxShadow: '0 4px 12px rgba(240, 147, 251, 0.4)'
                  },
                  '&.Mui-disabled': {
                    background: '#E2E8F0',
                    color: '#A0AEC0'
                  },
                  transition: 'all 0.3s ease'
                }}
              >
                {loading ? 'Guardando...' : 'Actualizar Información'}
              </Button>
            </Box>
          </Paper>

          {/* Cambiar Contraseña */}
          <Paper 
            elevation={0} 
            sx={{ 
              p: { xs: 2.5, sm: 3.5 }, 
              mb: { xs: 2, sm: 3 }, 
              borderRadius: 3,
              border: '1px solid #E2E8F0',
              boxShadow: '0 4px 12px rgba(102, 126, 234, 0.08)'
            }}
          >
            <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
              <LockIcon sx={{ mr: 1.5, color: '#667EEA', fontSize: { xs: 24, sm: 28 } }} />
              <Typography 
                variant="h6" 
                sx={{ 
                  fontFamily: 'Lato, sans-serif', 
                  fontWeight: 900,
                  color: '#1A202C',
                  fontSize: { xs: '1.2rem', sm: '1.35rem' }
                }}
              >
                Cambiar Contraseña
              </Typography>
            </Box>

            <Typography 
              variant="body2" 
              sx={{ 
                mb: 2.5, 
                color: '#718096', 
                fontSize: { xs: '0.875rem', sm: '0.95rem' },
                fontFamily: 'Open Sans, sans-serif'
              }}
            >
              Completa todos los campos para cambiar tu contraseña
            </Typography>

            <Grid container spacing={2.5}>
              <Grid item xs={12}>
                <TextField
                  fullWidth
                  label="Contraseña Actual"
                  type={showPasswordActual ? 'text' : 'password'}
                  value={passwordActual}
                  onChange={(e) => setPasswordActual(e.target.value)}
                  variant="outlined"
                  InputProps={{
                    endAdornment: (
                      <InputAdornment position="end">
                        <IconButton
                          onClick={() => setShowPasswordActual(!showPasswordActual)}
                          edge="end"
                        >
                          {showPasswordActual ? <VisibilityOff /> : <Visibility />}
                        </IconButton>
                      </InputAdornment>
                    ),
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
                      fontFamily: 'Open Sans, sans-serif',
                      fontWeight: 600
                    },
                  }}
                />
              </Grid>

              <Grid item xs={12} sm={6}>
                <TextField
                  fullWidth
                  label="Nueva Contraseña"
                  type={showPasswordNueva ? 'text' : 'password'}
                  value={passwordNueva}
                  onChange={(e) => setPasswordNueva(e.target.value)}
                  variant="outlined"
                  helperText="Mínimo 6 caracteres"
                  InputProps={{
                    endAdornment: (
                      <InputAdornment position="end">
                        <IconButton
                          onClick={() => setShowPasswordNueva(!showPasswordNueva)}
                          edge="end"
                        >
                          {showPasswordNueva ? <VisibilityOff /> : <Visibility />}
                        </IconButton>
                      </InputAdornment>
                    ),
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
                      fontFamily: 'Open Sans, sans-serif',
                      fontWeight: 600
                    },
                  }}
                />
              </Grid>

              <Grid item xs={12} sm={6}>
                <TextField
                  fullWidth
                  label="Confirmar Nueva Contraseña"
                  type={showPasswordConfirmar ? 'text' : 'password'}
                  value={passwordConfirmar}
                  onChange={(e) => setPasswordConfirmar(e.target.value)}
                  variant="outlined"
                  InputProps={{
                    endAdornment: (
                      <InputAdornment position="end">
                        <IconButton
                          onClick={() => setShowPasswordConfirmar(!showPasswordConfirmar)}
                          edge="end"
                        >
                          {showPasswordConfirmar ? <VisibilityOff /> : <Visibility />}
                        </IconButton>
                      </InputAdornment>
                    ),
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
                      fontFamily: 'Open Sans, sans-serif',
                      fontWeight: 600
                    },
                  }}
                />
              </Grid>
            </Grid>

            <Divider sx={{ my: 3, borderColor: '#E2E8F0' }} />

            {/* Botón para actualizar contraseña */}
            <Box sx={{ display: 'flex', gap: 2, justifyContent: 'flex-end' }}>
              <Button
                variant="contained"
                disabled={loading}
                startIcon={<LockIcon />}
                onClick={handleUpdatePassword}
                sx={{
                  background: 'linear-gradient(135deg, #F093FB 0%, #F5576C 100%)',
                  color: 'white',
                  fontFamily: 'Open Sans, sans-serif',
                  fontWeight: 700,
                  borderRadius: 50,
                  px: { xs: 3, sm: 4 },
                  py: 1.2,
                  fontSize: { xs: '0.9rem', sm: '1rem' },
                  '&:hover': {
                    background: 'linear-gradient(135deg, #F5576C 0%, #F093FB 100%)',
                    transform: 'translateY(-2px)',
                    boxShadow: '0 4px 12px rgba(240, 147, 251, 0.4)'
                  },
                  '&.Mui-disabled': {
                    background: '#E2E8F0',
                    color: '#A0AEC0'
                  },
                  transition: 'all 0.3s ease'
                }}
              >
                {loading ? 'Actualizando...' : 'Cambiar Contraseña'}
              </Button>
            </Box>
          </Paper>

          {/* Botón Volver */}
          <Box sx={{ display: 'flex', justifyContent: 'center', mt: 4 }}>
            <Button
              variant="outlined"
              onClick={handleCancel}
              sx={{
                color: '#667EEA',
                borderColor: '#667EEA',
                fontFamily: 'Open Sans, sans-serif',
                fontWeight: 600,
                borderRadius: 50,
                px: { xs: 4, sm: 5 },
                py: 1.5,
                fontSize: { xs: '0.9rem', sm: '1rem' },
                '&:hover': {
                  borderColor: '#764BA2',
                  backgroundColor: 'rgba(102, 126, 234, 0.05)',
                  transform: 'translateY(-2px)'
                },
                transition: 'all 0.3s ease'
              }}
            >
              Volver al Inicio
            </Button>
          </Box>
      </Container>
    </Box>
  );
}
