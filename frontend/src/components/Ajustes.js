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
    <Box sx={{ minHeight: '100vh', backgroundColor: '#f5f5f5' }}>
      {/* Hero Section */}
      <Box 
        sx={{ 
          backgroundColor: '#F6F0E0',
          py: { xs: 3, sm: 4, md: 5 },
          borderBottom: '3px solid #F75442'
        }}
      >
        <Container maxWidth="lg">
          <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 2 }}>
            <SettingsIcon sx={{ fontSize: { xs: 32, sm: 40, md: 48 }, color: '#F75442' }} />
            <Typography 
              variant="h3" 
              component="h1"
              sx={{ 
                fontFamily: 'Lato, sans-serif', 
                fontWeight: 700,
                color: '#6b4f34',
                fontSize: { xs: '1.75rem', sm: '2.5rem', md: '3rem' },
                textAlign: 'center'
              }}
            >
              Configuración de Cuenta
            </Typography>
          </Box>
        </Container>
      </Box>

      <Container maxWidth="md" sx={{ py: { xs: 2, sm: 3, md: 4 }, px: { xs: 2, sm: 3 } }}>
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
          autoHideDuration={6000}
          onClose={() => setSuccess(false)}
          anchorOrigin={{ vertical: 'top', horizontal: 'center' }}
        >
          <Alert severity="success" sx={{ width: '100%' }}>
            ¡Datos actualizados exitosamente!
          </Alert>
        </Snackbar>

        {/* Información Personal */}
        <Paper elevation={2} sx={{ p: { xs: 2, sm: 3 }, mb: { xs: 2, sm: 3 }, borderRadius: 2 }}>
          <Box sx={{ display: 'flex', alignItems: 'center', mb: 3 }}>
            <PersonIcon sx={{ mr: 1, color: '#F75442', fontSize: { xs: 20, sm: 24 } }} />
            <Typography 
              variant="h6" 
              sx={{ 
                fontFamily: 'Lato, sans-serif', 
                fontWeight: 600,
                color: '#6b4f34',
                fontSize: { xs: '1.1rem', sm: '1.25rem' }
              }}
            >
              Información Personal
            </Typography>
          </Box>

            <Grid container spacing={2}>
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
                      '&.Mui-focused fieldset': {
                        borderColor: '#F75442',
                      },
                    },
                    '& .MuiInputLabel-root.Mui-focused': {
                      color: '#F75442',
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
                      '&.Mui-focused fieldset': {
                        borderColor: '#F75442',
                      },
                    },
                    '& .MuiInputLabel-root.Mui-focused': {
                      color: '#F75442',
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
                    startAdornment: <EmailIcon sx={{ mr: 1, color: '#666' }} />,
                  }}
                  sx={{
                    '& .MuiOutlinedInput-root': {
                      '&.Mui-focused fieldset': {
                        borderColor: '#F75442',
                      },
                    },
                    '& .MuiInputLabel-root.Mui-focused': {
                      color: '#F75442',
                    },
                  }}
                />
              </Grid>
            </Grid>

            <Divider sx={{ my: 3 }} />

            {/* Botón para actualizar información personal */}
            <Box sx={{ display: 'flex', gap: 2, justifyContent: 'flex-end' }}>
              <Button
                variant="contained"
                disabled={loading}
                startIcon={<SaveIcon />}
                onClick={handleUpdatePersonalInfo}
                sx={{
                  backgroundColor: '#F75442',
                  px: { xs: 3, sm: 4 },
                  py: 1,
                  fontSize: { xs: '0.9rem', sm: '1rem' },
                  '&:hover': {
                    backgroundColor: '#d64032'
                  }
                }}
              >
                {loading ? 'Guardando...' : 'Actualizar Información'}
              </Button>
            </Box>
          </Paper>

          {/* Cambiar Contraseña */}
          <Paper elevation={2} sx={{ p: { xs: 2, sm: 3 }, mb: { xs: 2, sm: 3 }, borderRadius: 2 }}>
            <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
              <LockIcon sx={{ mr: 1, color: '#F75442', fontSize: { xs: 20, sm: 24 } }} />
              <Typography 
                variant="h6" 
                sx={{ 
                  fontFamily: 'Lato, sans-serif', 
                  fontWeight: 600,
                  color: '#6b4f34',
                  fontSize: { xs: '1.1rem', sm: '1.25rem' }
                }}
              >
                Cambiar Contraseña
              </Typography>
            </Box>

            <Typography 
              variant="body2" 
              sx={{ mb: 2, color: '#666', fontSize: { xs: '0.875rem', sm: '0.95rem' } }}
            >
              Completa todos los campos para cambiar tu contraseña
            </Typography>

            <Grid container spacing={2}>
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
                      '&.Mui-focused fieldset': {
                        borderColor: '#F75442',
                      },
                    },
                    '& .MuiInputLabel-root.Mui-focused': {
                      color: '#F75442',
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
                      '&.Mui-focused fieldset': {
                        borderColor: '#F75442',
                      },
                    },
                    '& .MuiInputLabel-root.Mui-focused': {
                      color: '#F75442',
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
                      '&.Mui-focused fieldset': {
                        borderColor: '#F75442',
                      },
                    },
                    '& .MuiInputLabel-root.Mui-focused': {
                      color: '#F75442',
                    },
                  }}
                />
              </Grid>
            </Grid>

            <Divider sx={{ my: 3 }} />

            {/* Botón para actualizar contraseña */}
            <Box sx={{ display: 'flex', gap: 2, justifyContent: 'flex-end' }}>
              <Button
                variant="contained"
                disabled={loading}
                startIcon={<LockIcon />}
                onClick={handleUpdatePassword}
                sx={{
                  backgroundColor: '#F75442',
                  px: { xs: 3, sm: 4 },
                  py: 1,
                  fontSize: { xs: '0.9rem', sm: '1rem' },
                  '&:hover': {
                    backgroundColor: '#d64032'
                  }
                }}
              >
                {loading ? 'Actualizando...' : 'Cambiar Contraseña'}
              </Button>
            </Box>
          </Paper>

          {/* Botón Volver */}
          <Box sx={{ display: 'flex', justifyContent: 'center', mt: 3 }}>
            <Button
              variant="outlined"
              onClick={handleCancel}
              sx={{
                color: '#6b4f34',
                borderColor: '#6b4f34',
                px: { xs: 4, sm: 5 },
                py: 1.5,
                fontSize: { xs: '0.9rem', sm: '1rem' },
                '&:hover': {
                  borderColor: '#6b4f34',
                  backgroundColor: 'rgba(107, 79, 52, 0.04)'
                }
              }}
            >
              Volver al Inicio
            </Button>
          </Box>
      </Container>
    </Box>
  );
}
